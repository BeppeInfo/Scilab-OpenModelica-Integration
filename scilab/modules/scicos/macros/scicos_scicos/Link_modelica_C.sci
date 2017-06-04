//  Scicos
//
//  Copyright (C) INRIA - METALAU Project <scicos@inria.fr>
//  Copyright (C) DIGITEO - 2010 - Allan CORNET
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
// -----------------------------------------------------------------------------
function ok = Link_modelica_C(model_C_file)
    model_C_file = pathconvert(model_C_file, %f, %t);
    [model_path, model_name, ext] = fileparts(model_C_file);

    [version, opts] = getversion();
    compiler = opts(1);
    if opts(2) == "x64" then
        arch = "64";
    else
        arch = "32";
    end

    model_libs_path = strsubst(model_path, "\", "/") + model_name + "/binaries/";
    if getos() == "Windows" then
        model_libs_path = model_libs_path + "win" + arch + "/";
    else
        model_libs_path = model_libs_path + "linux" + arch + "/";
    end

    model_include_path = strsubst(model_path, "\", "/") + model_name + "/sources/include/fmi2/";

    // add linked libraries list
    model_libs = [ model_libs_path + model_name + getdynlibext() ];

    // add modelica_libs to the list of directories to be searched for *.h
    ldflags = "";
    cflags = "";
    files_found = findfiles(model_include_path, "*.h");
    if files_found <> [] then
        cflags = " -I" + model_include_path;
    end

    old_linked_libs = link();
    ulink(old_linked_libs);

    // build shared library with the C code
    ok = buildnewblock(model_name, model_name, "", "", model_libs, TMPDIR, ldflags, cflags);

endfunction
// -----------------------------------------------------------------------------
