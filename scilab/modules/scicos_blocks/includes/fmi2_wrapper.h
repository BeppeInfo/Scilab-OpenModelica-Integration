/*  Scicos
*
*  Copyright (C) 2015 - Scilab Enterprises - Antoine ELIAS
*  Copyright (C) INRIA - METALAU Project <scicos@inria.fr>
*
* This program is free software; you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation; either version 2 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program; if not, write to the Free Software
* Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
*
* See the file ./license.txt
*/
/*--------------------------------------------------------------------------*/
#include <string.h>
#include <stdio.h>
#include <stdarg.h>

#include "scicos_block.h"
#include "scicos_malloc.h"
#include "scicos_free.h"
#ifdef _MSC_VER
#define scicos_print printf
#define SCICOS_BLOCK_EXPORT __declspec(dllexport)
#else
#include "scicos_print.h"
#define SCICOS_BLOCK_EXPORT
#endif

// Simple terminal message logging function
static void print_log_message( fmi2ComponentEnvironment componentEnvironment, fmi2String instanceName,
                               fmi2Status status, fmi2String category, fmi2String message, ... )
{
    char messageBuffer[ 1024 ];

    va_list args;
    va_start( args, message );
    vsnprintf( messageBuffer, 1024, (const char*) message, args );
    va_end( args );

    scicos_print( "%s - %d - %s - %s\n", instanceName, status, category, messageBuffer );
}

static void* scicos_calloc( size_t objects_number, size_t object_size )
{
    return scicos_malloc( objects_number * object_size );
}

// User provided functions for FMI2 data management
const fmi2CallbackFunctions functions = { .logger = print_log_message,
                                          .allocateMemory = scicos_calloc,
                                          .freeMemory = scicos_free,
                                          .stepFinished = NULL,
                                          .componentEnvironment = NULL };

// The computational function itself
SCICOS_BLOCK_EXPORT void BLOCK_FUNCTION_NAME(scicos_block* block, const int flag)
{    
    static fmi2Component model;
  
    double **y = block->outptr;
    double **u = block->inptr;
    
    fmi2EventInfo eventInfo;
    
    int i;
    int enterEventMode, terminateSimulation;   
    
    // Flag 4: State initialisation and memory allocation
    if( flag == 4 )
    {
        // Store FMI2 component in the work field
        model = fmi2Instantiate( MODEL_NAME,            // Instance name (TODO: solve block->label not updating its value)
                                 fmi2ModelExchange,     // Exported model type
                                 MODEL_GUID,            // Model GUID (TODO: solve block->uid not updating its value)
                                 "",                    // Optional FMU resources location
                                 &functions,            // User provided callbacks
                                 fmi2False,             // Interactive mode
                                 fmi2False );            // Logging On
        
        //Set_Jacobian_flag( 1 );                       // TODO: Enable jacobian calculation after it is fixed upstream (OMCompiler PR #1715)
    }
    else
    {
        fmi2Reset( model );
    }
    
    // Define simulation parameters. Internally calls state and event setting functions,
    // which should be called before any model evaluation/event processing ones
    fmi2SetupExperiment( model,                                   // FMI2 component
                         fmi2False,                               // Tolerance undefined
                         0.0,                                     // Tolerance value (not used)
                         0.0,                                     // Start time
                         fmi2False,                               // Stop time undefined
                         1.0 );                                   // Stop time (not used)
    
    // FMI2 component initialization
    fmi2EnterInitializationMode( model );
    
    if( block->nin > 0 )
    {
        for( i = 0; i < block->nin; i++ )
            inputsList[ i ] = (fmi2Real) u[ i ][ 0 ];
        fmi2SetReal( model, INPUT_REFS_LIST, block->nin, inputsList );
    }
    
    fmi2ExitInitializationMode( model );
    
    fmi2EnterContinuousTimeMode( model );

    if( flag != 4 )
    {
        fmi2SetTime( model, (fmi2Real) get_scicos_time() );
      
        fmi2SetContinuousStates( model, block->x, block->nx );
    
        fmi2GetEventIndicators( model, eventIndicatorsList, block->ng );
        // Inform the model about an accepted step
        // The second parameter informs that the model simulation won't be set to a prior time instant (fmi2False otherwise)
        fmi2CompletedIntegratorStep( model, fmi2True, &enterEventMode, &terminateSimulation );
        if( terminateSimulation ) set_block_error( -3 );
    }

    fmi2EnterEventMode( model );
    // Event iteration
    eventInfo.newDiscreteStatesNeeded = fmi2True;
    while( eventInfo.newDiscreteStatesNeeded == fmi2True )
    {
        // Update discrete states
        fmi2NewDiscreteStates( model, &eventInfo );
        if( eventInfo.terminateSimulation ) set_block_error( -3 );
    }

    fmi2EnterContinuousTimeMode( model );
    
    fmi2GetContinuousStates( model, statesList, block->nx );
    
    fmi2GetDerivatives( model, stateDerivativesList, block->nx );
    
    fmi2GetReal( model, OUTPUT_REFS_LIST, block->nout, outputsList );
    
    // Flag 0: Update continuous state
    if( flag == 0 )
    {
        // Output both residuals for implicit (DAE) solvers
        for( i = 0; i < block->nx; i++ )
        {
            block->res[ i ] = block->xd[ i ] - (double) stateDerivativesList[ i ];
        }
    }
    // Flag 1: Update output state
    else if( flag == 1 )
    {
        for( i = 0; i < block->nout; i++ )
        {
            y[ i ][ 0 ] = (double) outputsList[ i ];
        }
    }
    // Flag 2: Handle discrete internal events (implicit blocks do not handle external events for now)
    else if( flag == 2 || flag == 4 )
    {
        for( i = 0; i < block->nx; i++ )
        {
            block->x[ i ] = (double) statesList[ i ];
        }
    }
    // Flag 3: Update event output state (implicit blocks do not handle external events for now)
    else if( flag == 3 )
    {
    }
    // Flag 5: simulation end and memory deallocation
    else if( flag == 5 )
    {
        //fmi2Terminate( model );       // Terminate simulation for this component
        fmi2FreeInstance( model );    // Deallocate memory
    }
    // Flag 6: Output state initialisation
    else if( flag == 6 )
    {
    }
    // Flag 7: Define property of continuous time states (algebraic or differential states)
    else if( flag == 7 )
    {
        for( i = 0; i < block->nx; i++ )
            block->xprop[ i ] = 1;
    }
    // Flag 9: Zero crossing computation
    else if( flag == 9 )
    {
        // Get event indicators. If sign changes for one of block->g vector values, block->jroot
        // and block->nevptr will be automatically set before StateUpdate job
        for( i = 0; i < block->ng; i++ )
            block->g[ i ] = (double) eventIndicatorsList[ i ];
    }
    // Flag 10: Jacobian computation
    else if( flag == 10 )
    {
        fmi2Real dx = 1.0;      // State variation for discrete derivatives calculation
        int xd_mat_size = block->nx * block->nx;
      
        for( i = 0; i < block->nx; i++ )
        {
            fmi2GetDirectionalDerivative( model,
                                          STATE_REFS_LIST + i, 1,          // array and number of derivated state references
                                          STATE_DER_REFS_LIST, block->nx,  // array and number of derivative references
                                          &dx, stateDerivativesList );     // state deltas and resulting state derivatives
            
            // Fill matrix column top with acquired values
            for( i = 0; i < block->nx; i++ )
                block->res[ i * block->nx ] = (double) stateDerivativesList[ i ];
            
            fmi2GetDirectionalDerivative( model,
                                          STATE_REFS_LIST + i, 1,         // array and number of derivated state references
                                          OUTPUT_REFS_LIST, block->nout,  // array and number of output references
                                          &dx, outputsList );             // state deltas and resulting output derivatives
            
            // Fill matrix column bottom with acquired values
            for( i = 0; i < block->nx; i++ )
                block->res[ xd_mat_size + i * block->nx ] = (double) outputsList[ i ];
        }
        
        set_block_error( 0 );
    }
    
    return;
}
