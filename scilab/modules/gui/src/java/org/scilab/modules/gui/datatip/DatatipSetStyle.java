/*
 * Scilab ( http://www.scilab.org/ ) - This file is part of Scilab
 * Copyright (C) 2013 - Gustavo Barbosa Libotte <gustavolibotte@gmail.com>
 *
 * This file must be used under the terms of the CeCILL.
 * This source file is licensed as described in the file COPYING, which
 * you should have received as part of this distribution.  The terms
 * are also available at
 * http://www.cecill.info/licences/Licence_CeCILL_V2-en.txt
 *
 */

package org.scilab.modules.gui.datatip;

import static org.scilab.modules.graphic_objects.graphicObject.GraphicObjectProperties.*;
import org.scilab.modules.graphic_objects.graphicObject.GraphicObjectProperties;
import org.scilab.modules.graphic_objects.graphicController.GraphicController;
import org.scilab.modules.graphic_objects.graphicObject.GraphicObject;

import javax.swing.JOptionPane;

/**
 * Set the datatip style - marker, box, label
 * @author Gustavo Barbosa Libotte
 */
public class DatatipSetStyle {

    /**
    * Drag a datatip over a polyline using mouse
    *
    * @param polylineUID Polyline unique identifier.
    * @param t Integer to choose the marker style (1 = square | 2 = arrow).
    * @param boxed Boolean to show/hide datatip box.
    * @param labeled Boolean to show/hide datatip label.
    */
    public static void datatipSetStyle(int polylineUID, int t, boolean boxed, boolean labeled) {

        Integer[] childrenUID = (Integer[])GraphicController.getController().getProperty(polylineUID, GraphicObjectProperties.__GO_CHILDREN__);

        for (int i = 0 ; i < childrenUID.length ; i++) {

            Integer childrenType = (Integer)GraphicController.getController().getProperty(childrenUID[i], __GO_TYPE__);
            if (childrenType.equals(__GO_DATATIP__)) {

                if (t == 1) {

                    GraphicController.getController().setProperty(childrenUID[i], GraphicObjectProperties.__GO_MARK_STYLE__, 11);

                } else {

                    GraphicController.getController().setProperty(childrenUID[i], GraphicObjectProperties.__GO_MARK_STYLE__, 7);

                }

                GraphicController.getController().setProperty(childrenUID[i], GraphicObjectProperties.__GO_DATATIP_BOX_MODE__, boxed);
                GraphicController.getController().setProperty(childrenUID[i], GraphicObjectProperties.__GO_DATATIP_LABEL_MODE__, labeled);

            }

        }

    }

    /**
     * datatipSetStyle function GUI
     *
     * @return Integer related to the choice.
     */
    public static int datatipSetStyleWindow() {

        String datatipSetStyleOption = (String)JOptionPane.showInputDialog(null, "Please choose an option:", "datatipSetStyle Options",
                                       JOptionPane.QUESTION_MESSAGE, null, new Object[] {"Square marker, boxed label",
                                               "Square marker, simple label",
                                               "Square marker, unlabeled",
                                               "Arrow marker, boxed label",
                                               "Arrow marker, simple label",
                                               "Arrow marker, unlabeled"
                                                                                        }, "Square marker, boxed label");

        if (datatipSetStyleOption == "Square marker, boxed label") {
            return 1;
        } else if (datatipSetStyleOption == "Square marker, simple label") {
            return 2;
        } else if (datatipSetStyleOption == "Square marker, unlabeled") {
            return 3;
        } else if (datatipSetStyleOption == "Arrow marker, boxed label") {
            return 4;
        } else if (datatipSetStyleOption == "Arrow marker, simple label") {
            return 5;
        } else if (datatipSetStyleOption == "Arrow marker, unlabeled") {
            return 6;
        } else {
            return 0;
        }

    }

}