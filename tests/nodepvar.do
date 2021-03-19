* No dependent variable transformation

clear all

which stdBeta

sysuse auto

* Interaction and categorical effects
regress mpg c.weight##i.foreign
stdBeta, nodepvar

* original
assert abs(el(r(coef),1,1) - (-.00597508)) <1e-6
assert abs(el(r(coef),3,1) - 9.2713327)    <1e-6
assert abs(el(r(coef),5,1) - (-.00445087)) <1e-6
assert abs(el(r(coef),6,1) - 39.646965)    <1e-6
* centered
assert abs(el(r(coef),1,3) - (-.00597508)) <1e-6
assert abs(el(r(coef),3,3) - (-4.1679012)) <1e-6
assert abs(el(r(coef),5,3) - (-.00445087)) <1e-6
assert abs(el(r(coef),6,3) - 21.605442)    <1e-6
* standardized
assert abs(el(r(coef),1,5) - (-4.6437965)) <1e-6
assert abs(el(r(coef),3,5) - (-4.1679012)) <1e-6
assert abs(el(r(coef),5,5) - (-3.4591904)) <1e-6
assert abs(el(r(coef),6,5) - 21.605442)    <1e-6