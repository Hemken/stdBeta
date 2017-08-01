sysuse auto, clear
quietly regress price c.weight##c.weight

stdBeta
stdBetavars

stdBetavars, generate
