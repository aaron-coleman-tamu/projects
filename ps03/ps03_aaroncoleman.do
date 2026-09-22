clear all
set more off

global projects: env projects
global storage: env storage
global code   "$projects/econ689/ps03"
global output "$projects/econ689/ps03/output"
capture mkdir "$projects/econ689/ps03"
capture mkdir "$output"
display "$projects"
display "$storage"
display "$code"
display "$output"

log using "$output/ps03_aaroncoleman.log", text replace

*P1

set seed 2026
set obs 500

generate double x1 = rnormal(2, 1)
generate double v = rnormal(0, 1)
generate double x2 = 0.5*x1 + v
generate double u = rnormal(0, 2)
generate double y = 3 + 2*x1 - x2 + u
summarize y x1 x2

twoway (scatter y x1, mcolor(navy)) (lfit y x1, lcolor(maroon) lwidth(medthick)), title("Oucome versus x1") xtitle("x1") ytitle("Outcome (y)") legend(order(1 "Observed values" 2 "Fitted line")) name(y_x1, replace)

twoway (scatter y x2, mcolor(green)) (lfit y x2, lcolor(maroon) lwidth(medthick)), title("Outcome versus x2") xtitle("x2") ytitle("Outcome (y)") legend(order(1 "Observed values" 2 "Fitted line")) name(y_x2, replace)
	

*P2

regress y x1 x2
scalar b0hat = _b[_cons]
scalar b1hat = _b[x1]
scalar b2hat = _b[x2]

display "Estimated intercept = " %9.4f b0hat
display "Estimated x1 coefficient = " %9.4f b1hat
display "Estimated x2 coefficient = " %9.4f b2hat

predict double yhat, xb
predict double ehat, residuals

generate double x1_ehat = x1*ehat
summarize x1_ehat, meanonly
display "Sum of x1 times residual = " %21.15e r(sum)

generate double x2_ehat = x2*ehat
summarize x2_ehat, meanonly
display "Sum of x2 times residual = " %21.15e r(sum)

twoway (scatter ehat x1, mcolor(navy)) (lfit ehat x1, lcolor(maroon) lwidth(medthick)), yline(0, lcolor(black) lpattern(dash)) title("OLS residuals versus x1") xtitle("x1") ytitle("OLS residual") legend(order(1 "Residuals" 2 "Fitted line")) name(ehat_x1, replace)

twoway (scatter ehat x2, mcolor(green)) (lfit ehat x2, lcolor(maroon) lwidth(medthick)), yline(0, lcolor(black) lpattern(dash)) title("OLS residuals versus x2") xtitle("x2") ytitle("OLS residual") legend(order(1 "Residuals" 2 "Fitted line")) name(ehat_x2, replace)
	
*P3

summarize ehat, meanonly
scalar sum_ehat = r(sum)
scalar mean_ehat = r(mean)
display "Sum of OLS residuals = " %21.15e sum_ehat
display "Mean of OLS residuals = " %21.15e mean_ehat
summarize yhat, meanonly
scalar yhatbar = r(mean)
summarize y, meanonly
scalar ybar = r(mean)


display "Mean of fitted values = " %12.8f yhatbar
display "Mean of actual y = " %12.8f ybar
display "Difference between means = " %21.15e (yhatbar-ybar)

histogram ehat, density xline(0, lcolor(maroon) lpattern(dash) lwidth(medthick)) title("Distribution of OLS residuals") xtitle("OLS residual") ytitle("Density") name(ehat_histogram, replace)

*P4

summarize x1, meanonly
scalar x1bar = r(mean)
summarize x2, meanonly
scalar x2bar = r(mean)
summarize y, meanonly
scalar ybar = r(mean)

scalar fitted_at_means = b0hat + b1hat*x1bar + b2hat*x2bar

display "Mean of x1 = " %12.8f x1bar
display "Mean of x2 = " %12.8f x2bar
display "Mean of y = " %12.8f ybar

display "Fitted value at the regressor means = " %12.8f fitted_at_means
display "Difference from mean of y = " %21.15e (fitted_at_means-ybar)

log close