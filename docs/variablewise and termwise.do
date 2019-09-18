clear all
sysuse auto

egen zprice = std(price)

gen wxd = weight*displacement

egen zweight = std(weight)
egen zdisp = std(displacement)

egen z_wxd = std(wxd) // termwise
gen zw_zd = zweight*zdisp  // variablewise

regress zprice zweight zdisp z_wxd
est sto termwise
regress zprice zweight zdisp zw_zd
est sto varwise
est table termwise varwise, se
