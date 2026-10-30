clear all
set more off

global projects : environment projects
global storage  : environment storage
global data   "$storage/econ689_data/ps01/data"
global output "$storage/econ689_data/ps05/output"

capture mkdir "$storage/econ689_data/ps05"
capture mkdir "$output"

capture log close
log using "$output/ps05_aaroncoleman.log", text replace

use "$data/card.dta", clear


*2A

regress lwage educ exper expersq black south smsa smsa66 ///
    reg662 reg663 reg664 reg665 reg666 reg667 reg668 reg669

scalar SSR_u = e(rss)
scalar df_u = e(df_r)

generate byte sample_u = e(sample)

display "Unrestricted SSR = " %12.6f SSR_u
display "Residual degrees of freedom (N-K) = " %9.0f df_u


*2B

scalar J_regions = 8

test reg662 reg663 reg664 reg665 reg666 reg667 reg668 reg669

scalar F_regions = r(F)
scalar p_regions = r(p)

display "Number of restrictions = " J_regions
display "Region joint-test F = " %12.6f F_regions
display "Region joint-test p-value = " %12.8f p_regions


*2C
regress lwage educ exper expersq black south smsa smsa66 if sample_u == 1

scalar SSR_r = e(rss)
scalar F_SSR = ((SSR_r - SSR_u)/J_regions)/(SSR_u/df_u)

display "Restricted SSR = " %12.6f SSR_r
display "SSR-based F = " %12.6f F_SSR
display "Stata test F = " %12.6f F_regions
display "Difference between F statistics = " %21.15e (F_SSR - F_regions)

assert abs(F_SSR - F_regions) < 1e-8

display "When we have a level of 5%, we reject the null hypothesis which is 1966 region indicators are directly associated with log wages, when controlling for other variables."


*3A

clear

set seed 2026
set obs 500

generate double x1 = rnormal(0, 1)
generate double v  = rnormal(0, 1)
generate double x2 = 0.5*x1 + v
generate double x3 = rnormal(1, 1)
generate double u  = rnormal(0, 2)
generate double y  = 1 + x1 + 0.5*x2 - 0.5*x3 + u

summarize x1 v x2 x3 u y
regress y x1 x2 x3

display "Estimated intercept = " %12.6f _b[_cons]
display "Estimated beta1 = " %12.6f _b[x1]
display "Estimated beta2 = " %12.6f _b[x2]
display "Estimated beta3 = " %12.6f _b[x3]


*3B

scalar J_sim = 2

test (x1 = 1) (x2 + x3 = 0)

scalar F_sim = r(F)
scalar p_sim = r(p)

display "Number of restrictions = " J_sim
display "Residual degrees of freedom = " e(df_r)
display "Joint-test F = " %12.6f F_sim
display "Joint-test p-value = " %12.8f p_sim


*3C

matrix b = e(b)
matrix V = e(V)

matrix R = (1, 0, 0, 0 \ 0, 1, 1, 0)
matrix r = (1 \ 0)

matrix d = R*b' - r

matrix W = d' * invsym(R*V*R') * d
scalar F_matrix = W[1,1]/J_sim

matrix list b
matrix list V
matrix list R
matrix list r
matrix list d
matrix list W

display "Matrix-based F = " %12.6f F_matrix
display "Stata test F = " %12.6f F_sim
display "Difference = " %21.15e (F_matrix - F_sim)

assert abs(F_matrix - F_sim) < 1e-8

display "When at the 5% level, we fail to reject the null hypothesis: b1 = 1 and b2 + b3 = 0."

log close