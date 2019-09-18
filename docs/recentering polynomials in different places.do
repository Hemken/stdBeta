sysuse auto, clear

postfile results c sd1 sd2 b1 b2 using "polynomial.dta", replace
summarize weight
local sd1 = r(sd)
generate wgt2 = weight*weight
summarize wgt2
local sd2 = r(sd)
regress price c.weight##c.weight
post results (0) (`sd1') (`sd2') (_b[weight]) (_b[c.weight#c.weight])

quietly forvalues c = 1760(15)4840 {
 preserve
 replace weight = weight - `c'
 summarize weight
 local sd1 = r(sd)
 replace wgt2 = weight*weight
 summarize wgt2
 local sd2 = r(sd)
 quietly regress price c.weight##c.weight
 post results (`c') (`sd1') (`sd2') (_b[weight]) (_b[c.weight#c.weight])
 restore
 }
 
postclose results

clear
use polynomial

graph matrix _all, half

generate stdb1 = b1*sd1
generate stdb2 = b2*sd2
scatter stdb2 stdb1

generate bratio = stdb1/stdb2
scatter bratio c
