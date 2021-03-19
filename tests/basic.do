clear all

which stdBeta

sysuse auto

* Interaction and categorical effects
regress mpg c.weight##c.displacement i.foreign
stdBeta
* original
assert abs(el(r(coef),1,1) - (-.00948233)) <1e-6
assert abs(el(r(coef),2,1) - (-.05186621)) <1e-6
assert abs(el(r(coef),3,1) - .00001474)    <1e-6
assert abs(el(r(coef),5,1) - (-2.6920178)) <1e-6
assert abs(el(r(coef),6,1) - 51.253243)    <1e-6
* centered
assert abs(el(r(coef),1,3) - (-.00657444)) <1e-6
assert abs(el(r(coef),2,3) - (-.0073634 )) <1e-6
assert abs(el(r(coef),3,3) - .00001474)    <1e-6
assert abs(el(r(coef),5,3) - (-2.6920178)) <1e-6
assert abs(el(r(coef),6,3) - (-.12835829)) <1e-6
* standardized
assert abs(el(r(coef),1,5) - (-.88317447 )) <1e-6
assert abs(el(r(coef),2,5) - (-.11688425 )) <1e-6
assert abs(el(r(coef),3,5) - .18182978)     <1e-6
assert abs(el(r(coef),5,5) - (-.46530402))  <1e-6
assert abs(el(r(coef),6,5) - ( -.0221862))  <1e-6

* Polynomial effects
regress mpg c.weight##c.weight i.foreign
stdBeta
* original
assert abs(el(r(coef),1,1) - (-.01657294)) <1e-6
assert abs(el(r(coef),2,1) - (1.591e-06))  <1e-6
assert abs(el(r(coef),4,1) - (-2.2035002)) <1e-6
assert abs(el(r(coef),5,1) - 56.538839)    <1e-6
* centered
assert abs(el(r(coef),1,3) - (-.00696409)) <1e-6
assert abs(el(r(coef),2,3) - (1.591e-06))  <1e-6
assert abs(el(r(coef),4,3) - (-2.2035002)) <1e-6
assert abs(el(r(coef),5,3) - (-.29302227)) <1e-6
* standardized
assert abs(el(r(coef),1,5) - (-.93551887)) <1e-6
assert abs(el(r(coef),2,5) - (.16612291))  <1e-6
assert abs(el(r(coef),4,5) - (-.38086577)) <1e-6
assert abs(el(r(coef),5,5) - (-.05064768)) <1e-6
