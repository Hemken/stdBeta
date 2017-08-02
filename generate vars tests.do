sysuse auto, clear
estimates clear

quietly regress price i.foreign c.weight##c.disp

stdBetavars, generate

stdBetavars, generate(c z)

summarize c_price
replace c_price = 1
stdBetavars, generate(,replace)

summarize price cprice c_price
