PS2701 LONGITUDINAL ANALYSIS
FINKEL


DEMONSTATION OF ODDS AND ENDS FROM SEM MODELING

use "nes3wave.2013.missing&multind.dta", clear

// A.  SEM ESTIMATION WITH MISSING VALUES


* FIRST USE THE 'ROWNOMISS' OPTION TO CREATE VARIABLES SIGNIFYING HOW MANY MISSING VALUES A CASE HAS ON ALL VARIABLE IN THE MODEL

egen nonmissall=rownonmiss(pid2000 pid2002 pid2004 app2000 app2002 app2004) 
egen nonmissall2=rownonmiss (pid2000 app2000)
egen nonmissall3=rownonmiss (pid2002 pid2004 app2002 app2004)
tab1 nonmissall nonmissall2 nonmissall3

*MODEL 1:  WITH LISTWISE DELETION -- AS WE HAVE BEEN DOING IT.  738 CASES NON-MISSING ON ALL SIX OBSERVED VARIABLES, SO ESTIMATE
* "if nonmissall==6" AND USE ML ESTIMATION OPTION (DEFAULT)
sem (pid2000 -> pid2002, ) (pid2000 -> app2002, ) (pid2002 -> pid2004, ) (pid2002 -> app2004, ) ///
(app2000 -> pid2002, ) (app2000 -> app2002, ) (app2002 -> pid2004, ) (app2002 -> app2004, )  /// 
if nonmissall==6, cov( pid2000*app2000 e.pid2002*e.app2002 e.pid2004*e.app2004) nocapslatent

estat gof, sta (all)

*MODEL 2:  USE ALL 1803 CASES THAT ARE PRESENT ON *AT LEAST ONE* VARIABLE (THIS IS DUBIOUS BUT JUST TO ILLUSTRATE HOW TO DO THIS)
*          NO INCLUSION OF AN 'IF' RESTRICTION, AND ESTIMATION WITH METHOD(mlmv)  -- "MAXIMUM LIKELIHOOD WITH MISSING VALUES"

sem (pid2000 -> pid2002, ) (pid2000 -> app2002, ) (pid2002 -> pid2004, ) (pid2002 -> app2004, ) ///
(app2000 -> pid2002, ) (app2000 -> app2002, ) (app2002 -> pid2004, ) (app2002 -> app2004, ),   ///
method(mlmv) cov( pid2000*app2000 e.pid2002*e.app2002 e.pid2004*e.app2004) nocapslatent

estat gof, sta (all)

*MODEL 3:  RESTRICT CASES TO BE PRESENT AT LEAST ON WAVE 1 EXOGENOUS VARIABLES AND AT LEAST ONE OTHER VARIABLE IN WAVES 2 OR 3 --
*          COMMON SENSE TO NOT IMPUTE WAVE 1 VALUES AND TO NOT IMPUTE IF CASE IS COMPLETELY MISSING ON ALL VARIABLES ASIDE FROM WAVE 1

sem (pid2000 -> pid2002, ) (pid2000 -> app2002, ) (pid2002 -> pid2004, ) (pid2002 -> app2004, ) ///
(app2000 -> pid2002, ) (app2000 -> app2002, ) (app2002 -> pid2004, ) (app2002 -> app2004, ) if nonmissall2==2&nonmissall3~=0,   ///
method(mlmv) cov( pid2000*app2000 e.pid2002*e.app2002 e.pid2004*e.app2004) nocapslatent

*****NOTE:  SEE SEM MANUAL SECTION 'INTRO 4:  SUBSTANTIVE CONCEPTS' AND EXAMPLE 26 FOR MORE ON MLMV ESTIMATION
*"For method MLMV to perform what might seem like magic, joint normality of all variables
*is assumed and missing values are assumed to be missing at random (MAR). MAR means
*either that the missing values are scattered completely at random throughout the data or that
*values more likely to be missing than others can be predicted by the variables in the model."

**THIS MAY BE A DUBIOUS ASSUMPTION, SO NEED TO THINK ABOUT IT.  IF PANEL ATTRITION ON SOME VARIABLE, E.G. IS RELATED TO THE EXPECTED VALUE OF THAT VARIABLE IN A GIVEN WAVE,
**YOU WILL HAVE PROBLEMS.  NORMALLY SCHOLARS ASSUME MAR AND THEN SHOW THAT CASES THAT EVENTUALLY DROPPED OUT WERE THE SAME ON WAVE 1 VALUES, DEMOGRAPHICS, ETC.
**AS THOSE CASES THAT STAYED IN.  WE WILL DISCUSS THIS FURTHER IN THE LAST WEEK OF THE COURSE.


// B.  COMPARISON OF STRUCTURAL EFFECTS BETWEEN GROUPS

**MODEL 1:  GROUP COMPARISON OF ALL STRUCTURAL EFFECTS FOR MEN AND WOMEN.  ALL STRUCTURAL EFFECTS CONTRAINED AS EQUAL FOR THE TWO GROUPS WITH "ginvariant (scoef)" 

sem (pid2000 -> pid2002, ) (pid2000 -> app2002, ) (pid2002 -> pid2004, ) (pid2002 -> app2004, ) (app2000 -> pid2002, ) ///
(app2000 -> app2002, ) (app2002 -> pid2004, ) (app2002 -> app2004, ) ///
if nonmissall==6, group(male) ginvariant(scoef) cov( pid2000*app2000 e.pid2002*e.app2002 e.pid2004*e.app2004) nocapslatent

***chi2(16)  =    156.78
estat ginvariant  // tests the constraints that each structural constraint is valid

**MODEL 2:  GROUP COMPARISON WITH NO EQUALITY CONSTRAINTS ACROSS GROUPS
sem (pid2000 -> pid2002, ) (pid2000 -> app2002, ) (pid2002 -> pid2004, ) (pid2002 -> app2004, ) (app2000 -> pid2002, ) ///
(app2000 -> app2002, ) (app2002 -> pid2004, ) (app2002 -> app2004, ) ///
if nonmissall==6, group(male) cov( pid2000*app2000 e.pid2002*e.app2002 e.pid2004*e.app2004) nocapslatent

***chi2(8)   =    139.13


**YOU CAN CONSTRAIN AND UNCONSTRAIN INDIVIDUAL COEFFICIENTS AS YOU LIKE

**IF ALL COEFFICIENTS ARE CONSTRAINED BUT YOU WANT TO ALLOW, E.G. THE CROSS-LAGGED EFFECTS FROM APP2000-PID2002 TO VARY BETWEEN GROUPS, THEN SEPARATE THE
**GROUPS FOR THAT EFFECT ONLY AND GIVE IT A DIFFERENT 'CONSTRAINT' LABEL -- LIKE I SHOW BELOW WITH "(0: app2000@a1 ->pid2002) and (1:app2000@a2 ->pid2002)":

sem (pid2000 -> pid2002, ) (pid2000 -> app2002, ) (pid2002 -> pid2004, ) (pid2002 -> app2004, ) (0: app2000@a1 -> pid2002, ) (1: app2000@a2 -> pid2002, ) ///
(app2000 -> app2002, ) (app2002 -> pid2004, ) (app2002 -> app2004, ) ///
if nonmissall==6, group(male) ginvariant(scoef) cov( pid2000*app2000 e.pid2002*e.app2002 e.pid2004*e.app2004) nocapslatent

***RESULTS BELOW:  THE LACK OF A STAR IN THE FIRST COLUMN MEANS THE EFFECTS WERE *NOT* CONSTRAINED BETWEEN GROUPS 0 AND 1

Structural    
pid2002 <-  
pid2000 
[*]    .8093484   .0226015    35.81   0.000     .7650504    .8536464
app2000 
0     .1837403   .0365685     5.02   0.000     .1120673    .2554132
1      .139572   .0361064     3.87   0.000     .0688048    .2103392
_cons 
0     .2380379   .0984129     2.42   0.016     .0451522    .4309236
1     .2545706   .1014955     2.51   0.012     .0556432     .453498
------------+----------------------------------------------------------------

**and chi-square=155.84 (15), so constrained is better in this case

***AND IF ALL COEFFICIENTS ARE UNCONSTRAINED BUT YOU WANT TO CONSTRAIN ONE OR MORE, THEN SEPARATE THE GROUPS FOR THAT EFFECT ONLY AND GIVE IT A CONSTRAINT:

sem (pid2000 -> pid2002, ) (pid2000 -> app2002, ) (pid2002 -> pid2004, ) (pid2002 -> app2004, ) (0: app2000@a -> pid2002, ) (1: app2000@a -> pid2002, ) ///
(app2000 -> app2002, ) (app2002 -> pid2004, ) (app2002 -> app2004, ) ///
if nonmissall==6, group(male) cov( pid2000*app2000 e.pid2002*e.app2002 e.pid2004*e.app2004) nocapslatent

***RESULTS BELOW:  A STAR IN THE FIRST COLUMN MEANS THE EFFECTS WERE CONSTRAINED BETWEEN GROUPS 0 AND 1
( 1)  [pid2002]0bn.male#c.app2000 - [pid2002]1.male#c.app2000 = 0

          OIM
Coef.   Std. Err.      z    P>z     [95% Conf. Interval]

Structural    
pid2002 <-  
pid2000 
0     .813024   .0287429    28.29   0.000     .7566889    .8693591
1     .8020951   .0285979    28.05   0.000     .7460443    .8581459
app2000 
[*]    .1630625   .0291232     5.60   0.000     .1059821     .220143
_cons 
0     .2788346   .0964714     2.89   0.004     .0897541     .467915
1     .2140025   .0999994     2.14   0.032     .0180072    .4099978
------------+----------------------------------------------------------------

**and chi-square=141.2 (9), so constrained model is better in this case too (compare to full unconstrained model above)

			 
