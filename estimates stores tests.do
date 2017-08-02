sysuse auto, clear
estimates clear

quietly regress price i.foreign c.weight##c.disp

*stdBeta
*estimates dir

stdBetavars
estimates dir

stdBetavars, store // Original, Centered, Standardized
estimates dir
estimates clear

stdBetavars, store(A B) // results given, stored
estimates dir

stdBetavars, store(A B C) // new stores attempt
estimates dir

stdBetavars, store(A B C, replace) // stores replaced
estimates dir

stdBetavars, store // Original, Centered, Standardized
stdBetavars, store( , replace) // stores replaced

estimates clear

