* version 1.8 13December2016
* Doug Hemken, Social Science Computing Coop
*    Univ of Wisc - Madison
// capture program drop stdBeta _est_move
program define stdBeta
	version 13
	syntax [, nodepvar store replace *] 
	// options for estimates table are allowed
	
	preserve

	capture estimates dir Original
	local clasho = "`r(names)'"
	if "`clasho'" == "Original" {
		display "Note:  found estimate store {it:Original}"
		tempname Original
		_est_move Original, to(`Original')
		}
	estimates store Original
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
			display "Failure to specify {cmd:nodepvar} where needed can produce meaningless results." 
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
	local clashc = "`r(names)'"
	if "`clashc'" == "Centered" {
		display "Note:  found estimate store {it:Centered}"
		tempname Centered
		_est_move Centered, to(`Centered')
		}
	estimates store Centered
	
	// rescale all centered continuous variables
	quietly foreach var in `vars' {
		summarize `var' if `touse'
		replace `var' = `var'/r(sd)
	}
	
	//re-estimate, standardized
	quietly `cmdline'
	capture estimates dir Standardized
	local clashs = "`r(names)'"
	if "`clashs'" == "Standardized" {
		display "Note:  found estimate store {it:Standardized}"
		tempname Standardized
		_est_move Standardized, to(`Standardized')
		}
	estimates store Standardized
	
	// report the results
	estimates table Original Centered Standardized, modelwidth(12) `options'
	
	// clean up
	quietly estimates restore Original
	if "`store'" == "" {
	// don't store, replace any previous stores
		estimates drop Original Centered Standardized
		if "`clasho'" != "" {
			display "Note:  restored estimate store {it:Original}"
			_est_move `Original', to(Original)
			}
		if "`clashc'" != "" {
			display "Note:  restored estimate store {it:Centered}"
			_est_move `Centered', to(Centered)
			}
		if "`clashs'" != "" {
			display "Note:  restored estimate store {it:Standardized}"
			_est_move `Standardized', to(Standardized)
			}
		}
	else if /*"`store'" != "" &*/ "`replace'" == "" & ("`clasho'"!="" | "`clashc'"!="" | "`clashs'"!="") {
		// warn if there is a name clash
		di "{error: estimate store(s) `clasho' `clashc' `clashs' cannot be overwritten}"
		di "   Try using the '{cmd:replace}' option,"
		di "   or using '{cmd:estimates drop `clasho' `clashc' `clashs'}'"
		if "`clasho'" != "" {
			_est_move `Original', to(Original)
			}
		if "`clashc'" != "" {
			_est_move `Centered', to(Centered)
			}
		if "`clashs'" != "" {
			_est_move `Standardized', to(Standardized)
			}
		exit
		}
	else /*if "`store'" != "" & "`replace'" != ""*/ {
	// keep new stores, drop the old ones
		display "stored new estimates {it:Original}, {it:Centered}, and {it:Standardized}"
		//estimates drop `Original' `Centered' `Standardized'
		}
	restore
end

* Move a previously named store to a new name
program define _est_move
	version 13
	syntax name(name=from id="store to move" local), to(name local)
	tempname current
	estimates store `current' // hold current estimates
	quietly estimates restore `from' //re-store
	estimates store `to'
	estimates drop `from'  // clear name
	quietly estimates restore `current'
	estimates drop `current'
end
