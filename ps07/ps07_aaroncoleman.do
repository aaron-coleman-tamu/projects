clear all
set more off

global projects : environment projects
global storage  : environment storage
global data   "$storage/econ689_data/ps01/data"
global output "$storage/econ689_data/ps07/output"

capture mkdir "$storage/econ689_data/ps07"
capture mkdir "$output"

capture log close
log using "$output/ps07_aaroncoleman.log", text replace

use "$data/card.dta", clear


*2A

regress lwage educ exper expersq black south smsa

scalar b_educ_classical  = _b[educ]
scalar se_educ_classical = _se[educ]


generate byte sample_wage = e(sample)

regress lwage educ exper expersq black south smsa, vce(robust)

scalar b_educ_robust   = _b[educ]
scalar se_educ_robust  = _se[educ]
scalar se_south_robust = _se[south]

scalar se_percent_change = 100*(se_educ_robust/se_educ_classical - 1)

display "Classical education SE = " %12.8f se_educ_classical
display "Robust education SE = " %12.8f se_educ_robust
display "Percent change in education SE = " %9.4f se_percent_change
display "Education coefficient difference = " %21.15e (b_educ_robust - b_educ_classical)
display "vce(robust) implements HC1: HC0 multiplied by N/(N-K)."
display "HC0 weights equal 1 when i = j and 0 otherwise."

assert abs(b_educ_robust - b_educ_classical) < 1e-10


*2B

egen byte region_count = rownonmiss(reg661-reg669)
egen byte region_sum = rowtotal(reg661-reg669)

assert region_count == 9
assert region_sum == 1

generate byte region66 = .

forvalues j = 1/9 {
    assert inlist(reg66`j', 0, 1)
    replace region66 = `j' if reg66`j' == 1
}

tabulate region66

regress lwage educ exper expersq black south smsa if sample_wage == 1, vce(cluster region66)

scalar C = e(N_clust)
scalar df_cluster = e(df_r)
scalar se_educ_cluster = _se[educ]
scalar se_south_cluster = _se[south]
scalar tcrit_cluster = invttail(C - 1, .025)
scalar ci_educ_lower = _b[educ] - tcrit_cluster*se_educ_cluster
scalar ci_educ_upper = _b[educ] + tcrit_cluster*se_educ_cluster

display "Number of clusters = " C
display "Clustered residual degrees of freedom = " df_cluster
display "Clustered education SE = " %12.8f se_educ_cluster
display "Clustered south SE = " %12.8f se_south_cluster
display "95% t critical value = " %12.8f tcrit_cluster
display "Education CI lower bound = " %12.8f ci_educ_lower
display "Education CI upper bound = " %12.8f ci_educ_upper

lincom educ, level(95)

scalar ci_educ_stata_lower = r(lb)
scalar ci_educ_stata_upper = r(ub)

assert abs(ci_educ_lower - ci_educ_stata_lower) < 1e-10
assert abs(ci_educ_upper - ci_educ_stata_upper) < 1e-10

display "HC1 robust education SE = " %12.8f se_educ_robust
display "Clustered education SE = " %12.8f se_educ_cluster
display "HC1 robust south SE = " %12.8f se_south_robust
display "Clustered south SE = " %12.8f se_south_cluster


*2C

regress lwage educ exper expersq black south smsa, vce(robust)

nlcom (theta: -_b[exper]/(2*_b[expersq]))

matrix theta_b = r(b)
matrix theta_V = r(V)

scalar theta_hat = theta_b[1,1]
scalar se_theta_delta = sqrt(theta_V[1,1])

display "Estimated peak experience = " %12.8f theta_hat
display "Delta method SE = " %12.8f se_theta_delta

testnl -_b[exper]/(2*_b[expersq]) = 20

scalar W_nonlinear = r(chi2)
scalar p_nonlinear = r(p)

test exper + 40*expersq = 0

scalar F_linear = r(F)
scalar p_linear = r(p)
scalar df_linear = e(df_r)

display "Nonlinear Wald x^2(1) = " %12.8f W_nonlinear
display "Nonlinear test p value = " %12.8f p_nonlinear
display "Linear test F(1, N-K) = " %12.8f F_linear
display "Linear test denominator df = " df_linear
display "Linear test p value = " %12.8f p_linear


*2D

bootstrap b_educ=_b[educ] tp=(-_b[exper]/(2*_b[expersq])), ///
reps(1000) seed(689) ///
saving("$output/ps07_boot.dta", replace): ///
regress lwage educ exper expersq black south smsa

scalar se_educ_boot = _se[b_educ]
scalar se_theta_boot = _se[tp]

display "Robust education SE = " %12.8f se_educ_robust
display "Bootstrap education SE = " %12.8f se_educ_boot
display "Delta method peak experience SE = " %12.8f se_theta_delta
display "Bootstrap peak experience SE = " %12.8f se_theta_boot

use "$output/ps07_boot.dta", clear
describe

summarize tp, meanonly

scalar theta_boot_mean = r(mean)
scalar B_valid = r(N)

generate double theta_null = tp - theta_boot_mean + 20

scalar observed_distance = abs(theta_hat - 20)

count if !missing(theta_null) & abs(theta_null - 20) >= observed_distance
scalar B_extreme = r(N)

scalar p_boot = B_extreme/B_valid

display "Original peak experience estimate = " %12.8f theta_hat
display "Mean botstrap peak experience = " %12.8f theta_boot_mean
display "Valid bootstrap peak estmates = " B_valid
display "Draws at least as extreme = " B_extreme
display "Two-sided bootstrap p value = " %12.8f p_boot

summarize theta_null, meanonly
display "Mean - shifted null distribution = " %12.8f r(mean)
assert abs(r(mean) - 20) < 1e-10

if p_boot < .05 {
display "When at the interval of 5% confidence , we reject the H0 that peak experience = 20years"
}
else {
display "When at the interval of 5% confidence , we reject the H0 that peak experience = 20 years"
}

log close