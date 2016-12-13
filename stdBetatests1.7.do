
sysdir set PLUS "U:\Stata\ado\plus"
cd "z:\public_web\stataworkshops\stdbeta"

clear all
sysuse auto
regress price c.weight##c.weight
stdBeta

estimates dir // should be none

stdBeta, store

estimates dir // should be three

quietly regress price c.mpg##c.weight
capture noisily stdBeta // should fail
// "replace" without "store" enables
//   a new table, and removes estimate stores.
stdBeta, replace
estimates dir // none again

