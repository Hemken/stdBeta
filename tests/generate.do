clear all
sysuse auto

*set type double

which stdBeta

regress mpg c.weight##c.displacement i.foreign

stdBeta, generate
stdBeta, generate(c z)

summarize c_mpg c_weight c_disp cmpg cweight cdisp
assert abs(r(mean)) < 1e-6

summarize z_mpg z_weight z_disp zmpg zweight zdisp
assert abs(r(sd)-1) < 1e-6
replace c_mpg = 1
stdBeta, generate( ,replace)

summarize c_mpg z_mpg
assert abs(r(mean)) < 1e-6
assert abs(r(sd)-1) < 1e-6