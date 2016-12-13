{smcl}
{* *! version 1.8  13dec2016}{...}
{vieweralsosee "[R] regress, beta" "help regress"}{...}
{vieweralsosee "[R] estimates table" "help estimates table"}{...}
{viewerjumpto "Syntax" "stdBeta##syntax"}{...}
{viewerjumpto "Description" "stdBeta##description"}{...}
{viewerjumpto "Options" "stdBeta##options"}{...}
{viewerjumpto "Remarks" "stdBeta##remarks"}{...}
{viewerjumpto "Examples" "stdBeta##examples"}{...}
{title:Title}

{phang}
{bf:stdBeta} {hline 2} After estimating a regression model, calculate centered and standardized coefficients


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:stdBeta}
[{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt nodepvar}}do not center or rescale the dependent variable{p_end}
{synopt:{opt store}}store centered and standardized estimation results{p_end}
{synopt:{opt replace}}overwrite estimates already stored{p_end}
{synopt:{it:estimates_table_options}}output options to pass to {cmd:estimates table}{p_end}
{synoptline}
{p2colreset}{...}

{marker description}{...}
{title:Description}

{pstd}
{cmd:stdBeta} calculates centered and standardized coefficients, standard errors,
  and fit statistics, optionally storing the results as {cmd:estimates store}


{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opt nodepvar} suppresses centering and rescaling the dependent variable.

{phang}
{opt store} stores ereturn statistics for all three models.  These are
{cmd:estimates store}s name Original, Centered, and Standardized.

{phang}
{opt replace} if estimates stores named Original, Centered, or Standardized
already exist, and you want to store these estimates, you must replace them.

{phang}
{it:estimates_table_options} options passed to {cmd:estimates table} for
reporting.


{marker remarks}{...}
{title:Remarks}

{pstd}
For detailed information on stdBeta, see SJ ##.


{marker examples}{...}
{title:Examples}

{phang}{cmd:. regress price c.mpg##c.weight}{p_end}

{phang}{cmd:. stdBeta}{p_end}
