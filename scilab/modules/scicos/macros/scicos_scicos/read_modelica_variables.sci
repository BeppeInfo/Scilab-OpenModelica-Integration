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
function [name,guid,in_refs,out_refs,x_refs,x_der_refs,g_refs,par_refs]=read_modelica_variables(model_desc_tree)
   
    name = model_desc_tree.root.attributes("modelName");
    guid = model_desc_tree.root.attributes("guid");

    in_refs=[]; x_refs=[]; x_der_refs=[]; par_refs=[]; out_refs=[];

    // Aquire number of model's event indicators (zero-crossings)
    zero_crossings_number = round(strtod(model_desc_tree.root.attributes("numberOfEventIndicators")));
    g_refs = zeros(1,zero_crossings_number);
    
    // Find model variables sub-node
    for i=1:length(model_desc_tree.root.children)
        child_node = model_desc_tree.root.children(i);
        if child_node.name == "ModelVariables" then
            model_vars = child_node;
        end
    end

    // Walks through every variable node and fill the different lists according to the properties of each one
    for i=1:length(model_vars.children)
        var_node = model_vars.children(i);
        var_attrs = var_node.attributes;
        var_ref = strtod(var_attrs("valueReference"));
        // Only continuous states, inputs and outputs considered
        if var_attrs("variability") == "continuous" then
            // States are internal (local or non-interfacing variables)
            if var_attrs("causality") == "local" then
                // State derivatives are calculated dynamically from current states
                // Model descriptions could also present internal calculated 
                // variables which are not state derivatives
                der_var_ref_str = var_node.children(1).attributes("derivative");
                if der_var_ref_str <> [] then
                    x_der_refs(1,$+1) = var_ref;
                    x_refs(1,$+1) = round(strtod(der_var_ref_str)) - 1;
                end
            // Input and output interfacing values
            elseif var_attrs("causality") == "input" then
                in_refs(1,$+1) = var_ref;
            elseif var_attrs("causality") == "output" then
                out_refs(1,$+1) = var_ref;
            end
        // Parameters are adjustable (in editor) values that remain the sames during the rest of simulation
        elseif var_attrs("variability") == "fixed" then
            if var_attrs("causality") == "parameter" then
                par_refs(1,$+1) = var_ref;
            end
        end
    end
    
endfunction 
