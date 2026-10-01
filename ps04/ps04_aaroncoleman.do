clear all
set more off

capture graph close _all
global projects: env projects
global storage: env storage

global code   "$projects/econ689/ps04"
global output "$projects/econ689/ps04/output"
capture mkdir "$projects/econ689/ps04"
capture mkdir "$output"

display "$projects"
display "$storage"
display "$code"
display "$output"

log using "$output/ps04_aaroncoleman.log", text replace


*P1

set seed 2026
set obs 500

generate double x2 = rnormal(1, 1)
generate double v = rnormal(0, 1)
generate double x1 = 0.7*x2 + v
generate double u = rnormal(0, 2)
generate double y = 5 + 3*x1 - 2*x2 + u
summarize y x1 x2
regress y x1 x2

scalar b1_full = _b[x1]
display "Full-regression x1 coefficient = " %12.8f b1_full

*P2

regress y x2
predict double y_resid, residuals

regress x1 x2
predict double x1_resid, residuals

twoway (scatter y_resid x1_resid, mcolor(navy)) (lfit y_resid x1_resid, lcolor(maroon) lwidth(medthick)), title("Resid Y v. Resid X-1") xtitle("Resid X-1") ytitle("Resid Y") legend(order(1 "Resid Observations" 2 "Fitted line")) name(fwl_graph, replace)

regress y_resid x1_resid, noconstant
scalar b1_fwl = _b[x1_resid]

display "Full-regression x1 coefficient = " %12.8f b1_full
display "FWL x1 coefficient = " %12.8f b1_fwl
display "Difference between coefficients = " %21.15e (b1_full-b1_fwl)

log close