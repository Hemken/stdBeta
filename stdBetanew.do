* version 1.8 12December2016
* Doug Hemken, Social Science Computing Coop
*    Univ of Wisc - Madison
capture program drop stdBetanew
program define stdBetanew
	version 13
	syntax [, nodepvar replace store *] 
	// options for estimates table are allowed
	
	preserve
	// check that estimate storage names are not already in use
	//quietly estimates dir
	//local storenames "`r(names)' Original Centered Standardized"
	//local storedups : list dups storenames
	//if "`storedups'" != "" & "`replace'" == "" {
	//	di "{error: estimate store(s) `storedups' cannot be overwritten}"
	//	exit
	//	}
	capture estimates dir Original
	local clashO = "`r(names)'"
	if "`clashO'" == "Original" {
		tempname swapO Original
		estimates store `swapO' // current
		quietly estimates restore Original //re-store
		estimates store `Original'
		estimates drop Original // clear name
		quietly estimates restore `swapO' // rename
		estimates store Original
		}
	else {
		estimates store Original
		}
	tempvar touse
	mark `touse' if e(sample)
	
	// identify terms used in regression
	local cmd `e(cmd)'
	local cmdline `e(cmdline)'
	local dep `e(depvar)'
	local cols: colnames e(b)
	local cols: subinstr local cols "_cons" "", all
	
	// identify continuous variables
	local vars: subinstr local cols "#" " ", all
	foreach var of local vars {
		_ms_parse_parts `var'
		if "`r(type)'" == "variable" & "`r(op)'" == "" {
			local list `list' `var'
			}	
		}
	unopvarlist `list'
	
	// exclude the dependent variable for some models
	if "`e(cmd)'" == "regress" {
		if "`depvar'" == "" {
			local vars `e(depvar)' `r(varlist)'
			}
			else {
				local vars `r(varlist)'
			}
		}
		else if "`e(cmd)'" == "logit" | "`e(cmd)'" == "logistic" {
			local vars `r(varlist)'
		}
		else if "`e(cmd)'" == "glm" {
			if "`e(varfunct)'" == "Gaussian" & "`e(linkt)'" == "Identity" {
				if "`depvar'" == "" {
					local vars `e(depvar)' `r(varlist)'
					}
				else {
					local vars `r(varlist)'
				}
				}
				else if "`e(varfunct)'" == "Bernoulli" & "`e(linkt)'" == "Logit" {
					local vars `r(varlist)'
				}
		}
		else {
			display "Failure to specify {cmd: nodepvar} where needed can cause errors." 
			if "`depvar'" == "" {
					local vars `e(depvar)' `r(varlist)'
					}
				else {
					local vars `r(varlist)'
				}
			}
	
	// center all continuous variables
	quietly foreach var in `vars' {
		summarize `var' if `touse'
		replace `var' = `var' - r(mean)
	}
	// re-estimate, centered
	quietly `cmdline'
	capture estimates dir Centered
	local clashC = "`r(names)'"
	if "`clashC'" == "Centered" {
		tempname swapC Centered
		estimates store `swapC' // current
		quietly estimates restore Centered //re-store
		estimates store `Centered'
		estimates drop Centered // clear name
		quietly estimates restore `swapC' // rename
		estimates store Centered
		}
	else {
		estimates store Centered
		}
	
	// rescale all centered continuous variables
	quietly foreach var in `vars' {
		summarize `var' if `touse'
		replace `var' = `var'/r(sd)
	}
	
	//re-estimate, standardized
	quietly `cmdline'
	capture estimates dir Standardized
	local clashO = "`r(names)'"
	if "`clashO'" == "Standardized" {
		tempname swapS Standardized
		estimates store `swapS' // current
		quietly estimates restore Standardized //re-store
		estimates store `Standardized'
		estimates drop Standardized // clear name
		quietly estimates restore `swapS' // rename
		estimates store Standardized
		}
	else {
		estimates store Standardized
		}
	
	// report the results
	estimates table Original Centered Standardized, modelwidth(12) `options'
	
	// clean up
	quietly estimates restore Original
	if "`store'" == "" {
		estimates drop Original Centered Standardized
		if "`swapO'" != "" {
			quietly estimates restore `Original'
			estimates store Original
			}
		if "`swapC'" != "" {
			quietly estimates restore `Centered'
			estimates store Centered
			}
		if "`swapS'" != "" {
			quietly estimates restore `Standardized'
			estimates store Standardized
			}
		}
	restore
end
