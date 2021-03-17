sysuse auto, clear
estimates clear

quietly regress price i.rep78 c.weight##c.disp

stdBeta
estimates dir

stdBeta, store // Original, Centered, Standardized
estimates dir
//estimates clear

//stdBeta, store(A B) // results given, stored
//estimates dir

stdBeta, store(A B C) // new stores attempt
estimates dir

stdBeta, store(A B C, replace) // stores replaced
estimates dir

//stdBeta, store // Original, Centered, Standardized
stdBeta, store( , replace) // stores replaced

estimates clear

