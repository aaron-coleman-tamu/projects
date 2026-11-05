clear all
set more off

global projects : environment projects
global storage  : environment storage
global data   "$storage/econ689_data/ps01/data"
global output "$storage/econ689_data/ps06/output"

capture mkdir "$storage/econ689_data/ps06"
capture mkdir "$output"

capture log close
log using "$output/ps06_aaroncoleman.log", text replace

use "$data/card.dta", clear


*3B

describe lwage educ exper expersq south
tabulate south, missing

scalar J = 4
scalar K = 4

regress lwage educ exper expersq

scalar SSR_r = e(rss)
scalar N_total = e(N)

generate byte sample_pooled = e(sample)
regress lwage educ exper expersq if sample_pooled == 1 & south == 0

scalar SSR_1 = e(rss)
scalar N_1 = e(N)

regress lwage educ exper expersq if sample_pooled == 1 & south == 1

scalar SSR_2 = e(rss)
scalar N_2 = e(N)

assert N_total == N_1 + N_2

scalar SSR_u = SSR_1 + SSR_2
scalar df_u = N_total - 2*K

scalar F_SSR = ((SSR_r - SSR_u)/J)/(SSR_u/df_u)
scalar p_SSR = Ftail(J, df_u, F_SSR)

display "Pooled SSR (when restricted) = " %12.6f SSR_r
display "Outside South SSR = " %12.6f SSR_1
display "South SSR = " %12.6f SSR_2
display "Combind SSR (when unrestricted) = " %12.6f SSR_u
display "Total observations = " %9.0f N_total
display "Unrestricted residual df = " %9.0f df_u
display "Number of restrictions = " J
display "SSR based F = " %12.6f F_SSR
display "SSR based p value = " %12.6e p_SSR


*3C

generate double south_educ   = south*educ
generate double south_exper  = south*exper
generate double south_expersq = south*expersq

regress lwage educ exper expersq south /// 
south_educ south_exper south_expersq if sample_pooled == 1

scalar SSR_interacted = e(rss)

display "Interacted model SSR = " %12.6f SSR_interacted
display "Sum of regional SSRs = " %12.6f SSR_u
display "SSR difference = " %21.15e (SSR_interacted - SSR_u)

assert abs(SSR_interacted - SSR_u) < 1e-8

test south south_educ south_exper south_expersq

scalar F_interacted = r(F)
scalar p_interacted = r(p)

display "Interacted-model test F = " %12.6f F_interacted
display "SSR based F = " %12.6f F_SSR
display "F difference = " %21.15e (F_interacted - F_SSR)
display "Joint-test p value = " %12.6e p_interacted
display "SSR based p value = " %12.6e p_SSR

assert abs(F_interacted - F_SSR) < 1e-8

scalar educ_outside = _b[educ]
scalar educ_south   = _b[educ] + _b[south_educ]
scalar educ_difference = _b[south_educ]

display "Education slope outside South = " %12.6f educ_outside
display "Education slope in South = " %12.6f educ_south
display "South minus outside education slope = " %12.6f educ_difference

display "When we have a 5% level, we reject the null hypothesis with the three slopes across the regions."
display "The estimated slop of education is higher in South and are descriptive OLS connections."

log close