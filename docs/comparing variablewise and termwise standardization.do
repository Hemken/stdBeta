* Interactions
sysuse auto, clear

egen sprice = std(price)

generate mxw = mpg*weight
egen smpg = std(mpg)
egen sweight = std(weight)
egen smxw = std(mxw) // termwise
generate stdmxw = smpg*sweight // variablewise

scatter smxw stdmxw // not a simple transformation!

graph matrix mpg smpg weight sweight mxw smxw stdmxw, half
graph matrix smpg sweight smxw stdmxw, half

regress price c.mpg##c.weight, beta // untransformed, and termwise
stdBeta // untransformed, centered, variablewise
regress sprice c.smpg##c.sweight, beta // variablewise, and ??
regress sprice smpg sweight stdmxw  // variablewise

regress sprice c.smpg c.sweight smxw, beta // termwise, and termwise

* Polynomials
sysuse auto, clear

egen sprice = std(price)

generate wgt2 = weight^2
egen sweight = std(weight)
egen swgt2 = std(wgt2)
generate stdwgt2 = sweight^2

scatter swgt2 stdwgt2

graph matrix sweight swgt2 stdwgt2, half

regress price c.weight##c.weight, beta
regress sprice c.sweight##c.sweight, beta

regress sprice sweight swgt2, beta
