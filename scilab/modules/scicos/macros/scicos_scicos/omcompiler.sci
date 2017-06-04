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

function  ok = omcompiler(model_flat_file, Jacobian, model_C_file, model_desc_file)
    //Scilab interface with external tool modelicac

    OMC_FILENAME = "omc";
    if getos() == "Windows" then
        OMC_FILENAME = OMC_FILENAME + ".exe";
    end

    [model_path, model_name, C_ext] = fileparts(model_C_file);
    [model_path, model_flat_name, flat_ext] = fileparts(model_flat_file);

    model_flat_script = pathconvert(model_path + model_name + ".mos", %f, %t);
    model_flat_package = pathconvert(model_path + model_name + ".fmu", %f, %t);

    current_dir = pwd();
    chdir( model_path );

    rmdir( model_name );

    if getos() == "Windows" then
        extract_cmd = strsubst(pathconvert(SCI+"/tools/zip/unzip.exe",%F),"\","/") + " -o -d " + model_name + " ";
    else
        extract_cmd = "unzip -o -d " + model_name + " ";
    end

    // Generate OpenModelica script file (builds FMU package with partial derivative support and unzips it)
    compile_commands = [];
    compile_commands($ + 1) = "setModelicaPath(""" + strsubst(model_path,"\","/") + """); getErrorString();"
    if getos() == "Windows" then
        compile_commands($ + 1) = "setCommandLineOptions(""+target=msvc""); getErrorString();";
    end
    if Jacobian then
        compile_commands($ + 1) = "setDebugFlags(""fmuExperimental""); getErrorString();";
    end
    compile_commands($ + 1) = "setDebugFlags(""initialization""); getErrorString();";
    compile_commands($ + 1) = "loadFile(""" + model_flat_name + flat_ext + """); getErrorString();";
    compile_commands($ + 1) = "buildModelFMU(" + model_name + ",version=""2.0"",fmuType=""me"",platforms={""static""}); getErrorString();";
    compile_commands($ + 1) = "system(""" + extract_cmd + strsubst(model_flat_package,"\","/") + """); getErrorString();";
    mputl( compile_commands, model_flat_script );

    exe = """" + pathconvert(getomcpath() + OMC_FILENAME, %f, %t) + """";

    model_flat_script = """" + model_flat_script + """";

    instr = strcat([exe, model_flat_script], " ");

//    if getos() == "Windows" then
//        mputl(instr, model_path + "genm.bat");
//        instr = model_path + "genm.bat";
//    end

    [rep,stat,err] = unix_g(instr);

    chdir( current_dir );

    if stat <> 0 then
        messagebox(err, _("Modelica compiler"), "error", "modal");
        ok=%f;
        return
    end

    //Modelica library C code wrapper for the simulation function
    fmi2_wrapper_code = generate_fmi2_wrapper(model_desc_file);
    mputl(fmi2_wrapper_code, model_C_file);

endfunction

function code = generate_fmi2_wrapper(model_desc_file)
    // Get variable references lists from description file
    model_desc_tree = xmlRead(model_desc_file);
    [name,guid,in_refs,out_refs,x_refs,x_der_refs,g_refs,par_refs] = read_modelica_variables(model_desc_tree);

    if length(in_refs) == 0 then in_refs = [ 0 ]; end
    if length(out_refs) == 0 then out_refs = [ 0 ]; end
    if length(x_refs) == 0 then x_refs = [ 0 ]; end
    if length(x_der_refs) == 0 then x_der_refs = [ 0 ]; end
    if length(g_refs) == 0 then g_refs = [ 0 ]; end

    // Generate C code for specific fixed size variables lists and append generic FMI2 wrapper code
    code = [
               "#include ""fmi2Functions.h""",
               "#include ""fmi2FunctionTypes.h""",
               "#include ""fmi2TypesPlatform.h""",
               "",
               strcat(["static fmi2Real inputsList[ ", string(length(in_refs)), " ] = { 0.0 };"]),
               strcat(["static const fmi2ValueReference INPUT_REFS_LIST[ ", string(length(in_refs)), " ] = { ", strcat(string(in_refs), ","), " };"]),
               strcat(["static fmi2Real statesList[ ", string(length(x_refs)), " ] = { 0.0 };"]),
               strcat(["static const fmi2ValueReference STATE_REFS_LIST[ ", string(length(x_refs)), " ] = { ", strcat(string(x_refs), ","), " };"]),
               strcat(["static fmi2Real stateDerivativesList[ ", string(length(x_der_refs)), " ] = { 0.0 };"]),
               strcat(["static const fmi2ValueReference STATE_DER_REFS_LIST[ ", string(length(x_der_refs)), " ] = { ", strcat(string(x_der_refs), ","), " };"]),
               strcat(["static fmi2Real outputsList[ ", string(length(out_refs)), " ] = { 0.0 };"]),
               strcat(["static const fmi2ValueReference OUTPUT_REFS_LIST[ ", string(length(out_refs)), " ] = { ", strcat(string(out_refs), ","), " };"]),
               strcat(["static fmi2Real eventIndicatorsList[ ", string(length(g_refs)), " ] = { 0.0 };"]),
               "",
               strcat(["#define BLOCK_FUNCTION_NAME ", name]),
               strcat(["#define MODEL_NAME ", """" + name + """"]),
               strcat(["#define MODEL_GUID ", """" + guid + """"]),
               "",
               "#include ""fmi2_wrapper.h"""
           ];

endfunction
