// =============================================================================
// Scilab ( http://www.scilab.org/ ) - This file is part of Scilab
// Copyright (C) 2013 - Scilab Enterprises - Paul Bignier
//
//  This file is distributed under the same license as the Scilab package.
// =============================================================================

// <-- ENGLISH IMPOSED -->
// <-- XCOS TEST -->

// Import diagram
assert_checktrue(importXcosDiagram("SCI/modules/xcos/tests/unit_tests/Solvers/DDaskr_RLC_test.zcos"));

// Redefining messagebox() to avoid popup
prot = funcprot();
funcprot(0);
function messagebox(msg, msg_title)
 disp(msg);
endfunction
funcprot(prot);

for i=2:3

    // Start by updating the clock block period (sampling)
    Context.per = 5*10^-i;
    Info = scicos_simulate(scs_m, list(), Context);

    // Modify solver + run DDaskr + save results
    scs_m.props.tol(6) = 102;     // Solver
    scicos_simulate(scs_m, Info); // DDaskr
    ddaskrval = res.values;       // Results
    time = res.time;              // Time

    // Modify solver + run IDA + save results
    scs_m.props.tol(6) = 100;     // Solver
    scicos_simulate(scs_m, Info); // IDA
    idaval = res.values;          // Results

    // Compare results
    compa = abs(ddaskrval-idaval);

    // Extract mean, standard deviation, maximum
    mea = mean(compa);
    [maxi, indexMaxi] = max(compa);
    stdeviation = st_deviation(compa);

    // Verifying closeness of the results
    assert_checktrue(maxi <= 10^-(i+4));
    assert_checktrue(mea <= 10^-(i+4));
    assert_checktrue(stdeviation <= 10^-(i+4));

end