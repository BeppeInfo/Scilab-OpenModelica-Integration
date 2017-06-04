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
function [ok]=translator(filemo,Mblocks,model_flat_file)
    //Generate the flat model of the Modelica model given in the filemo file
    //and the Modelica libraries. Interface to the external tool
    //translator.
    // if <name> is the basename of filemo this function produces
    // - the flat Modelica model file in outpath+name+'f.mo'

    // TO DO : rename filename too generic
    TRANSLATOR_FILENAME = "omc";
    if getos() == "Windows" then
        TRANSLATOR_FILENAME = TRANSLATOR_FILENAME + ".exe";
    end

    [modelica_libs,modelica_directory] = getModelicaPath();

    mlibs = pathconvert(modelica_libs,%f,%t);
    filemo = pathconvert(filemo,%f,%t);
    model_flat_file = pathconvert(model_flat_file,%f,%t);

    molibs = [];

    for k = 1:size(Mblocks,"r")
        funam = stripblanks(Mblocks(k));
        [dirF, nameF, extF] = fileparts(funam);
        if (extF == ".mo") then
            molibs = [molibs; """" + funam + """"];
        else
            molibs = [molibs; """" + modelica_directory + funam + ".mo" + """"]
        end
    end

    // directories for translator libraries
    for k = 1:size(mlibs,"*")
        modelica_directories = mlibs(k);
        if modelica_directories<> [] then
            [dirF, nameF] = fileparts(modelica_directories);
            molibs = [molibs; """" + modelica_directories + filesep() + nameF + ".mo"""];
        end
    end

    translator_libs = strcat(" "+ molibs);

    // build the sequence of -lib arguments for translator
    if getos() == "Windows" then, Limit=1000;else, Limit=3500;end
    if (length(translator_libs)>Limit) then
        // OS limitation may restrict the length of shell command line
        // arguments. If there are too many .mo file we catenate them into a
        // single MYMOPACKAGE.mo file
        msg = _("There are too many Modelica files.\nIt would be better to define several \nModelica programs in a single file.")
        messagebox(msprintf(msg),"warning","modal")
        mymopac = pathconvert(outpath+"MYMOPACKAGE.mo",%f,%t);
        txt = [];
        for k = 1:size(molibs,"*")
            [pathx,fnamex,extensionx] = fileparts(molibs(k));
            if (fnamex <> "MYMOPACKAGE") then
                txt = [txt; mgetl(evstr(molibs(k)))];
            end
        end
        mputl(txt, mymopac);
        translator_libs= " """+mymopac+"""";
    end

    translator_libs = " """ + filemo + """ " + translator_libs;

    //Build the shell instruction for calling the translator

    exe = getomcpath() + TRANSLATOR_FILENAME
    exe = """" + pathconvert(getomcpath() + TRANSLATOR_FILENAME,%f,%t) + """ ";

    out = " """ + model_flat_file + """ " //flat modelica

    // Shell instruction for generating flat Modelica code and saving it to a file
    instr = exe + " " + translator_libs + " --modelicaOutput --useLocalDirection --reduceTerms > " + out;

//    if getos() == "Windows" then
//        mputl(instr,outpath+"/gent.bat")
//        instr = outpath + "/gent.bat";
//    end

    [rep,stat,err]=unix_g(instr);
    if stat <> 0 then
        messagebox(err, _("Modelica translator"), "error", "modal");
        ok=%f;
        return
    end

    ok = %t

endfunction
