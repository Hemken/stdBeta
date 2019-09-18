* Question:  should the coefficient of a (non-standardized)
* indicator variable change when a covariate is standardized?
* Answer:  if the indicator and the covariate appear together
* in an interaction term, then yes, the coeffcients for both
* first order terms change, even though only one of them is
* standardized.

* set up example
set obs 100
generate x1 = runiform(0,5)
generate ind3 = mod(_n,2)
generate y = 1 + 0.75*ind3 + 2*x1 + 0.5*x1*ind3 + rnormal()

* this regression should recover our coefficients
regress y ind3##c.x1

stdBeta, nodepvar

* graph this model
predict yhat
separate yhat, by(ind3)
line yhat0 yhat1 x1

* recreate standarized model
egen xstd = std(x1)
regress y ind3##c.xstd

* graph standardized model
predict y_xstd
separate y_xstd, by(ind3)
line y_xstd0 y_xstd1 xstd, name(stdized)

* Compare the two models, visually.
* Notice that the y scale is the same in both graphs (but not the x scale).
* Now note the size of the gap between the two lines above x==0 in each gap.
* Because there is an interaction (i.e. because the lines are NOT parallel),
* we see that the gap is bigger in the second graph than in the first (in
* this particular example - in general they are just different).  This is
* reflected in the changed coefficient for x1 in the comparison of the
* unstandardized and standardized coefficients.

* Go back to the coefficient table from the stdBeta command.  We see that the
* indicator changes when the covariate is recentered.