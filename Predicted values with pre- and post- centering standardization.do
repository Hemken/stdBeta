clear
sysuse auto
keep price weight displacement

summarize weight
local muw = r(mean)
local sdw = r(sd)

summarize displacement
local mud = r(mean)
local sdd = r(sd)

preserve
* Original
reg price c.weight##c.displacement
estimates store Original
nlcom _b[weight]/_b[displacement]
predict priceraw
label variable priceraw "Original"

gen wxd = weight*displacement
summ wxd
local muwxd = r(mean)
local sdwxd = r(sd)
egen swxd = std(wxd)

egen sweight = std(weight)
drop weight
rename sweight weight
egen sdisplacement = std(displacement)
drop displacement
rename sdisplacement displacement

* Varwise std
reg price c.weight##c.displacement
estimates store Varwise
nlcom _b[weight]/_b[displacement]
predict pricepost
label variable pricepost "Varwise"

* Termwise std
reg price weight disp swxd
estimates store Termwise
nlcom _b[weight]/_b[displacement]
predict pricepre
label variable pricepre "Termwise"

estimates table Original Varwise Termwise
graph matrix priceraw pricepre pricepost, half

restore

estimates restore Original
* Predicted values at the mean of weight and displacement
di _b[_cons] + _b[weight]*`muw' + _b[displacement]*`mud' + _b[weight*displacement]*`muw'*`mud'
* Total effect of weight at mean displacement
lincom weight + `mud'*_b[weight*displacement]
* Total effect of standardized weight at mean displacement
lincom (_b[weight] + `mud'*_b[weight*displacement])*`sdw'
quietly `e(cmdline)'
quietly margins, at(weight=(1760(77)4840) displacement=(100(100)300))
marginsplot, noci

* Total effect of displacement at mean weight
lincom displacement + `muw'*_b[weight*displacement]
* Difference of effects at mean
lincom (_b[weight] + _b[weight*displacement]*`mud') - (_b[displacement] + _b[weight*displacement]*`muw')
* Ratio of effects at the mean
nlcom (_b[weight] + _b[weight*displacement]*`mud')/(_b[displacement] + _b[weight*displacement]*`muw')

estimates restore Varwise
* Predicted values at the mean of weight and displacement
di _b[_cons] + _b[weight]*0 + _b[displacement]*0 + _b[weight*displacement]*0*0
* Total effect of standardized weight at mean displacement
lincom weight
* Ratio of effects at the mean
nlcom (_b[weight]/`sdw')/(_b[displacement]/`sdd')

estimate restore Termwise
di (`muw'*`mud' - `muwxd')/`sdwxd'
* Predicted values at the mean of weight and displacement
di _b[_cons] + _b[weight]*0 + _b[displacement]*0 + _b[swxd]*(`muw'*`mud' - `muwxd')/`sdwxd'
* Total effect of weight at mean displacement
lincom _b[weight]/`sdw' + _b[swxd]*`mud'/`sdwxd'
* Total effect of standardized weight at mean displacement
lincom (_b[weight]/`sdw' + _b[swxd]*`mud'/`sdwxd')*`sdw'
* Ratio of effects at the mean
nlcom (_b[weight]/`sdw' + _b[swxd]*`mud'/`sdwxd')/(_b[displacement]/`sdd'+ _b[swxd]*`muw'/`sdwxd')


* Predicted values at the 1 sd above the mean of weight and displacement
estimates restore Original
di _b[_cons] + _b[weight]*(`muw'+`sdw') + _b[displacement]*(`mud'+`sdd') + _b[weight*displacement]*(`muw'+`sdw')*(`mud'+`sdd')
nlcom (_b[weight] + _b[weight*displacement]*(`mud'+`sdd'))/(_b[displacement] + _b[weight*displacement]*(`muw'+`sdw'))
*di (_b[weight] + _b[weight*displacement]*(`mud'+`sdd'))

estimates restore Varwise
di _b[_cons] + _b[weight]*1 + _b[displacement]*1 + _b[weight*displacement]*1*1
nlcom (_b[weight]/`sdw'+_b[weight*displacement]/`sdw')/(_b[displacement]/`sdd'+_b[weight*displacement]/`sdd')


estimate restore Termwise
di (`muw'*`mud' - `muwxd')/`sdwxd'
di _b[_cons] + _b[weight]*1 + _b[displacement]*1 + _b[swxd]*((`muw'+`sdw')*(`mud'+`sdd') - `muwxd')/`sdwxd'
nlcom (_b[weight]/`sdw'+_b[swxd]*(`mud'+`sdd')/`sdwxd')/(_b[displacement]/`sdd'+_b[swxd]*(`muw'+`sdw')/`sdwxd')
*di (_b[weight]/`sdw'+_b[swxd]*(`mud'+`sdd')/`sdwxd')
