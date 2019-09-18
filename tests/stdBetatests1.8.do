
sysdir set PLUS "U:\Stata\ado\plus"
cd "z:\public_web\stataworkshops\stdbeta"
clear all
estimates drop _all

run "stdBetanew.do"

sysuse auto
quietly regress price c.weight##c.weight
estimates store model1, title("Model 1")
quietly regress price c.mpg##c.weight
estimates store model2, title("Model 2")

stdBeta2
estimates dir // two

stdBeta2, store
estimates dir // should be five

estimates restore model1
stdBeta2 // polynomial model
estimates dir // shows five, 4 parms
// previous stores intact: (not poly)
estimates table Original Centered Standardized

stdBeta2, store // does not replace stores, error
estimates dir // shows five, 4 parms


stdBeta2, replace // not actually used! without store
estimates dir // five models, 4 parms

stdBeta2, store replace
estimates dir // five models, 3 parms
