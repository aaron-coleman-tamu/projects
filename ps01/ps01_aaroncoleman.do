clear all
set more off

* P1
global projects: env projects
global storage : env storage

global dataready "$storage/econ689_data/ps01/data"
global code      "$projects/econ689/ps01"
global output    "$projects/econ689/ps01/output"

capture mkdir "$storage/econ689_data"
capture mkdir "$storage/econ689_data/ps01"
capture mkdir "$dataready"
capture mkdir "$code"
capture mkdir "$output"

display "$storage"
display "$projects"
display "$dataready"
display "$code"
display "$output"

capture log close
log using "$output/ps01_aaroncoleman.log", text replace


*P2

*2a
clear
set obs 500
set seed 68901

generate double v = rnormal(8, 2.5)
generate double study_hours = max(0, v)

generate double w = rnormal(3, 0.45)
generate double prior_gpa = min(4, max(0, w))

generate double u = rnormal(0, 5)

generate double exam_score = 45 + 2.5*study_hours + 6*prior_gpa + u


*2b
summarize study_hours prior_gpa exam_score

*2c
regress exam_score study_hours
estimates store simple_model

*2d
predict double exam_hat_simple, xb
predict double residual_simple, residuals
summarize residual_simple
display "Mean of OLS residuals = " %21.15e r(mean)

*2e
regress exam_score study_hours prior_gpa
estimates store multiple_model

*2f
*(see written answers)

*2g
save "$dataready/ps01_simulated.dta", replace

*P3

use "$dataready/card.dta", clear

*3a
describe lwage educ exper expersq black south smsa nearc4
summarize lwage educ exper expersq black south smsa nearc4

count if !missing(lwage, educ, exper, expersq, black, south, smsa, nearc4)

display "Number of usable observations = " r(N)

*3b
regress lwage educ
estimates store card_simple

display "Approximate percentage effect = " %9.4f (100*_b[educ])

display "Exact percentage effect = " %9.4f (100*(exp(_b[educ])-1))

*3c
regress lwage educ exper expersq black south smsa
estimates store card_multiple

display "Controlled approximate percentage effect = " %9.4f (100*_b[educ])

display "Controlled exact percentage effect = " %9.4f (100*(exp(_b[educ])-1))

*3d
*(see table/written answers for calculations)

*3e
predict double lwage_hat_multiple, xb
predict double lwage_residual_multiple, residuals

summarize lwage_residual_multiple
display "Mean of multivariate residuals = " %21.15e r(mean)

*3f
regress educ nearc4
estimates store nearc4_model

* Close and save the completed text log
log close
