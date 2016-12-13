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

run "stdBetanew.do"

stdBeta2
estimates dir // none
stdBeta2, replace // not actually used!
estimates dir // none
stdBeta2, store
estimates dir // should be three

quietly regress price c.weight##c.weight
stdBeta2 // works
estimates dir // shows three
// previous stores intact:
estimates table Original Centered Standardized
stdBeta2, store // replaces stores
estimates dir // shows three
// verify these are the new stores:
estimates table Original Centered Standardized
