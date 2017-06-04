//  Scicos
//
//  Copyright (C) INRIA - METALAU Project <scicos@inria.fr>
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
//
// See the file ../license.txt
//
function [name,guid,nipar,nrpar,nopar,nz,nx,nx_der,nx_ns,nin,nout,nm,ng,dep_u]=reading_incidence(model_desc_file)
    // this function creates the matrix dep_u given by the xml format.
    // It is used for modelica compiler.
    // number of lines represents the number of input, number of columns represents the number of outputs.

    model_desc_tree = xmlRead(model_desc_file);
    [name,guid,in_refs,out_refs,x_refs,x_der_refs,g_refs,par_refs] = read_modelica_variables(model_desc_tree);
    
    nipar = 0; nopar = 0; nz = 0; nx_ns = 0; nm = 0;
    nin = length(in_refs);
    nx = length(x_refs);
    nx_der = length(x_der_refs);
    nout = length(out_refs);
    nrpar = length(par_refs);
    ng = length(g_refs);
    
    // Output includes state, so is it always depends on existing input
    if nin > 0 then
        dep_u=%t
    else
        dep_u=%f
    end

    // remind taht inputs are numbered according to their position in the
    // diagram and not in the Modelica block.InPutPortx.viis the x-th
    // input in the whole diagram!

endfunction
