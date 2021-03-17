sysuse auto, clear
estimates clear

quietly regress price i.foreign c.weight##c.disp

stdBeta, generate

stdBeta, generate(c z)

summarize c_price
replace c_price = 1
stdBeta, generate(,replace)

summarize price cprice c_price
