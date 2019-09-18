clear all

sysuse auto
regress price c.weight##c.displacement
stdBeta