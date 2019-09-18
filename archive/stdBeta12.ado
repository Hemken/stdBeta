* version 1.612 05April2016
* Doug Hemken, Social Science Computing Coop
*    Univ of Wisc - Madison
program define stdBeta12
	version 12
	syntax [, nodepvar replace store *] 
	// options for estimates table are allowed
	
	preserve
	
	// check that estimate storage names are not already in use
	quietly estimates dir
	local storenames "`r(names)' Original Centered Standardized"
	local storedups : list dups storenames
	if "`storedups'" != "" & "`replace'" == "" {
		di "{error: estimate store(s) `storedups' cannot be overwritten}"
		exit
		}
	estimates store Original
	tempvar touse
	mark `touse' if e(sample)
	
	// identify terms used in regression
	local cmd `e(cmd)'
	local cmdline `e(cmdline)'
	local dep `e(depvar)'
	local cols: colnames e(b)
	local cols: subinstr local cols "_cons" ""
	
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
	estimates store Centered
	
	// rescale all centered continuous variables
	quietly foreach var in `vars' {
		summarize `var' if `touse'
		replace `var' = `var'/r(sd)
	}
	
	//re-estimate, standardized
	quietly `cmdline'
	estimates store Standardized
	
	// report the results
	estimates table Original Centered Standardized, modelwidth(12) `options'
	
	// clean up
	quietly estimates restore Original
	if "`store'" == "" {
		estimates drop Original Centered Standardized
		}
	restore
end
