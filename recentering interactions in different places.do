sysuse auto, clear

postfile results c d sd1 sd2 sd3 b1 b2 b3 using "interaction.dta", replace
summarize weight
local sd1 = r(sd)
summarize mpg
local sd2 = r(sd)
generate wxm = weight*mpg
summarize wxm
local sd3 = r(sd)
regress price c.weight##c.mpg
post results (0) (0) (`sd1') (`sd2') (`sd3') (_b[weight]) (_b[mpg]) (_b[c.weight#c.mpg])

quietly forvalues c = 0(25)4840 {
	forvalues d = 0(2)41 {
		 preserve
		 replace weight = weight - `c'
		 summarize weight
		 local sd1 = r(sd)
		 replace mpg = mpg - `d'
		 summarize mpg
		 local sd2 = r(sd)
		 replace wxm = weight*mpg
		 summarize wxm
		 local sd3 = r(sd)
		 regress price c.weight##c.mpg
		 post results (`c') (`d') (`sd1') (`sd2') (`sd3') (_b[weight]) (_b[mpg]) (_b[c.weight#c.mpg])
		 restore
	}
 }
 
postclose results

clear
use interaction

graph matrix _all, half

gen stdb1 = b1*sd1
gen stdb2 = b2*sd2
gen stdb3 = b3*sd3
graph matrix stdb1 stdb2 stdb3, half

twoway (contourline stdb3 stdb2 stdb1, interp(none) levels(7) minmax)

generate b1ratio = stdb1/stdb3
generate b2ratio = stdb2/stdb3
scatter b1ratio b2ratio

list b1ratio b2ratio if c==3025 & d ==22
