set linesize 80
sysuse auto

// No problem
regress price weight displacement, beta
stdBeta
stdBeta, se stats(r2 F)

// comparing residuals from all three models
stdBeta, store
preserve
predict ro, resid
label variable ro "Original"
estimates restore Centered
foreach var of varlist price weight displacement {
	quietly summarize `var'
	replace `var' = `var' - r(mean)
	}
predict rc, resid
label variable rc "Centered"
estimates restore Standardized
foreach var of varlist price weight displacement {
	quietly summarize `var'
	replace `var' = `var'/r(sd)
	}
predict rz, resid
label variable rz "Standardized"
graph matrix ro rc rz, title("Residuals compared") scheme(sj)
restore
estimates restore Original
estimates drop _all

// -beta- and actually transforming the data disagree
regress price c.weight##c.displacement, beta
stdBeta

// -beta- uses the original coefficient, which is wrong
//    and skips the constant, which is also wrong
tabstat price weight, statistics(sd) save
matrix sigma = r(StatTotal) 
di _b[weight]*sigma[1,2]/sigma[1,1]
// not centered, not correct
display -.6695052*777.1936/2949.496
// centered, correct
display 2.1550417 *777.1936/2949.496

// centering the data helps, some
preserve
foreach var of varlist price weight displacement {
	quietly summarize `var'
	replace `var' = `var' - r(mean)
	}

// first order terms (main effects) are correct
//    but the interaction term is not
regress price c.weight##c.displacement, beta

// the interaction term is scaled with the wrong quantity,
//    the standard deviation of the product
generate wgtxdisp = weight*displacement
tabstat price wgtxdisp weight displacement, statistics(sd) save
matrix sigma = r(StatTotal) 
// sd of product, not correct
di _b[weight#displacement]*sigma[1,2]/sigma[1,1]
display .0143162 *78288.85/2949.496
// product of sds, correct
display .0143162 *777.1936*91.83722/2949.496
restore

// The other problem with -beta- is that it resolutely
//    ignores factor variables

regress price weight i.foreign, beta
stdBeta
// Long's -listcoef- gives us the correct information
//    for additive models, if we know where to look
listcoef, cons

// but once we introduce an interaction term, all bets (betas?)
//    are off
regress price c.weight##c.displacement i.foreign, beta
stdBeta
capture noisily listcoef  // does not support factor variables

// So the easiest thing for an analyst to do is divide the
//    independent variables into two piles:  continuous 
//    (regression, slope) variables versus binary (indicator,
//    intercept) variables.

// Want a different base category?
regress price c.weight##c.displacement ib1.foreign
stdBeta

// Want factor variables standardized?
//    For factors with more than two categories, you will
//    need to create multiple indictors, just like in the good
//    old days.
regress price c.weight##c.displacement foreign
stdBeta

// Polynomial terms should be specified as interactions
regress price c.weight##c.weight
stdBeta

// Note it is a mistake to include higher order terms
//    without lower order terms.  If the lower order
//    term is zero in the original model, it cannot be
//    zero in the centered model (unless the original model
//    IS the centered model, or the interaction coefficient
//    is zero).  -stdBeta- does not check for this.

// comparing residuals from models with a missing main effect
regress price c.weight c.weight#c.displacement
stdBeta, store
preserve
predict ro, resid
label variable ro "Original"
estimates restore Centered
foreach var of varlist price weight displacement {
	quietly summarize `var'
	replace `var' = `var' - r(mean)
	}
predict rc, resid
label variable rc "Centered"
estimates restore Standardized
foreach var of varlist price weight displacement {
	quietly summarize `var'
	replace `var' = `var'/r(sd)
	}
predict rz, resid
label variable rz "Standardized"
graph matrix ro rc rz, title("Missing Main Effect") scheme(sj)
restore
estimates restore Original
estimates drop _all

// Just standardize the independent variables
regress price c.weight##c.displacement i.foreign
stdBeta, nodepvar

//  This approach, simply transforming the continuous variables, generalizes
//    to Generalized Linear Models.

