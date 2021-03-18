*! version 3.1 17Mar2021
*! Doug Hemken, Social Science Computing Coop
*!    Univ of Wisc - Madison
 capture program drop stdBeta _est_move _recenter _rescale
program define stdBeta, rclass
	version 12
	syntax [, nodepvar STOREa STOREb(string) GENeratea GENerateb(string) *] 
	// options for estimates table are allowed as *
// display "Stata version " c(stata_version)
	
	if c(stata_version) < 16 {
		preserve
	}
	
// keep track of missing values
	tempvar touseo
	mark `touseo' if e(sample)
	
	if c(stata_version) >= 16  {
	    tempvar id
		quietly generate `id' = _n
        tempname cframe sframe
		quietly frame pwf
		frame copy `r(currentframe)' `cframe'
		frame copy `r(currentframe)' `sframe'
		quietly frlink 1:1 `id', frame(`cframe') 
		quietly frlink 1:1 `id', frame(`sframe') 
	}
//di "frames initialized"
	
// initialize estimate store names
	local O "Original"
	local C "Centered"
	local S "Standardized"

// check store and replace options
	if "`storea'" != "" {
		local store "store"
	} 
	else if "`storeb'" != "" {
		gettoken storeb replace : storeb, parse(",")
		local storeb : subinstr local storeb "," "", all
		local replace : subinstr local replace " " "", all
		local replace : subinstr local replace "," "", all
		if "`replace'" != "replace" & "`replace'" != "" {
			local replace ""
			di "{error: Warning: unrecognized option `replace'}"
			}
		if "`storeb'" == "" & "`replace'" == "replace" {
			local store "store"
			}
		else {
			local store "store"
			tokenize "`storeb'"
			if "`1'" != "" {
				local O `1'
				}
			if "`2'" != "" {
				local C `2'
				}
			if "`3'" != "" {
				local S `3'
				}
			}
	}
//di "estimate stores initialized"
	
// set prefixes for generated variables
	if "`generatea'" != "" {
		local prefixc "c_"
		local prefixz "z_"
		local generate "generate"
		}
	else if "`generateb'" != "" {
		gettoken generateb genreplace : generateb, parse(",")
		local generateb : subinstr local generateb "," "", all
		local genreplace : subinstr local genreplace " " "", all
		local genreplace : subinstr local genreplace "," "", all
		//di "genreplace: `genreplace'"
		if "`genreplace'" != "replace" & "`genreplace'" != "" {
			local genreplace ""
			di "{error: Warning: unrecognized option `genreplace'}"
			}
		tokenize "`generateb'"
		if "`1'" != "" {
			local prefixc `1'
			}
		else {
			local prefixc "c_"
			}
		if "`2'" != "" {
			local prefixz `2'
			}
		else {
			local prefixz "z_"
			}
		local generate "generate"
		}
//di "initialized newvar prefixes"

// handle original estimates
	capture estimates dir `O'
	local clasho = "`r(names)'"
	if "`clasho'" == "`O'" {
		display "Note:  found estimate store {it:`O'}"
		tempname Original
		_est_move `O', to(`Original')
		}
	estimates store `O'
//di "original estimates stored"

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
//di "variables to transform identified"

// center all continuous variables
// and re-estimate, centered
	if c(stata_version) < 16 {
		_recenter `vars' if `touseo', pre(`prefixc') `genreplace'
		quietly `cmdline'
	}
	else {
		frame `cframe': _recenter `vars' if `touseo' //, pre(`prefixc') `genreplace'
//di "recentered in cframe"
		if ("`generate'"=="generate") {
    		foreach var of varlist `vars' {
				if ("`genreplace'"=="replace") {
					drop `prefixc'`var'
				}
				frget `var', from(`cframe') prefix("`prefixc'")
			}
//di "recentered variables copied"
		}
		frame `cframe':	quietly `cmdline'
	}
//di "recentered estimation"

// handle centered estimates
	capture estimates dir `C'
	local clashc = "`r(names)'"
	if "`clashc'" == "`C'" {
		display "Note:  found estimate store {it:`C'}"
		tempname Centered
		_est_move `C', to(`Centered')
		}
	estimates store `C'
//di "recentered estimates stored"

// rescale all centered continuous variables
//re-estimate, standardized
	if c(stata_version) < 16 {
		_rescale `vars' if `touseo', pre(`prefixz') `genreplace'
		quietly `cmdline'
	}
	else {
		frame `sframe': _recenter `vars' if `touseo' //, pre(`prefixc') `genreplace'
		frame `sframe': _rescale `vars' if `touseo' //, pre(`prefixz') `genreplace'
//di "rescaled in sframe"
		if ("`generate'"=="generate") {
    		foreach var of varlist `vars' {
				if ("`genreplace'"=="replace") {
					drop `prefixc'`var'
				}
				frget `var', from(`cframe') prefix("`prefixc'")
			}
//di "rescaled variables copied"
		}
		frame `sframe': quietly `cmdline'
	}
//di "rescaled estimation"

// handle standardized estimates
	capture estimates dir `S'
	local clashs = "`r(names)'"
	if "`clashs'" == "`S'" {
		display "Note:  found estimate store {it:`S'}"
		tempname Standardized
		_est_move `S', to(`Standardized')
		}
	estimates store `S'
//di "rescaled estimates stored"
	
// report the results
	estimates table `O' `C' `S', modelwidth(12) `options'
	local names = "`r(names)'"
	matrix coef = r(coef)
	if ("`r(stats)'" != "") {
	    local stattbl = "stattbl"
	    matrix stats = r(stats)
	}
//di "the desired results"

// clean up
	quietly estimates restore `O'
	if "`store'" == "" {
	// don't store, replace any previous stores
		estimates drop `O' `C' `S'
		if "`clasho'" != "" {
			display "Note:  restored estimate store {it:`O'}"
			_est_move `Original', to(`O')
			}
		if "`clashc'" != "" {
			display "Note:  restored estimate store {it:`C'}"
			_est_move `Centered', to(`C')
			}
		if "`clashs'" != "" {
			display "Note:  restored estimate store {it:`S'}"
			_est_move `Standardized', to(`S')
			}
		}
	else if /*"`store'" != "" &*/ "`replace'" == "" & ("`clasho'"!="" | "`clashc'"!="" | "`clashs'"!="") {
	    // store, without replace
		// warn if there is a name clash
		di "{error: estimate store(s) `clasho' `clashc' `clashs' cannot be overwritten}"
		di "{error:   Try using the '{cmd:replace}' option,}"
		di "{error:   or using command '{cmd:estimates drop `clasho' `clashc' `clashs'}'}"
		if "`clasho'" != "" {
			display "Note:  restored estimate store {it:`O'}"
			_est_move `Original', to(`O')
			}
		if "`clashc'" != "" {
			display "Note:  restored estimate store {it:`C'}"
			_est_move `Centered', to(`C')
			}
		if "`clashs'" != "" {
			display "Note:  restored estimate store {it:`S'}"
			_est_move `Standardized', to(`S')
			}
		exit
		}
	else /*if "`store'" != "" & "`replace'" != ""*/ {
	    // store and replace
	// keep new stores, drop the old ones
		display "stored new estimates {it:`O'}, {it:`C'}, and {it:`S'}"
		}
//di "estimate store cleanup"

// save generated variables, pre Stata 16
	if (c(stata_version) < 16) {
	    quietly if "`generate'" != "" {
			tempfile newvars
			keep `prefixc'* `prefixz'*
			save `newvars'
			}
		}
		
// original data set
	if c(stata_version) < 16 {
		restore
	}
	else {
		frame drop `cframe'
		frame drop `sframe'
	}
//di "restore original data"

// merge any generated variables
	if (c(stata_version) < 16) {
	    	quietly if "`generate'" != "" {
		merge 1:1 _n using `newvars', update replace
		drop _merge
		}
	}
	
// return estimates tables returns	
	return local names = "`names'"
	return matrix coef = coef
	if ("`stattbl'" != ""){
	    	return matrix stats = stats
	}
end

* Move a previously named store to a new name
program define _est_move
	version 12
	syntax name(name=from id="store to move" local), to(name local)
	tempname current
	estimates store `current' // hold current estimates
	quietly estimates restore `from' //re-store
	estimates store `to'
	estimates drop `from'  // clear name
	quietly estimates restore `current'
	//estimates drop `current'
end

program define _recenter
	version 12
	syntax varlist [if], [pre(name) replace]
	quietly foreach var in `varlist' {
		summarize `var' `if'
		replace `var' = `var' - r(mean)
		if "`pre'" != "" {
			if "`replace'" == "" {
				generate `pre'`var' = `var'
			}
			else {
				replace `pre'`var' = `var'
			}
		}
	}
end

program define _rescale
	version 12
	syntax varlist [if], [pre(name) replace]
	quietly foreach var in `varlist' {
		summarize `var' `if'
		replace `var' = `var'/r(sd)
		if "`pre'" != "" {
			if "`replace'" == "" {
				generate `pre'`var' = `var'
			}
			else {
				replace `pre'`var' = `var'
			}
		}
	}
end
