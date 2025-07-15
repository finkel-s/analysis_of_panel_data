PS2701
LONGITUDINAL ANALYSIS

WEEKS 11-12:  Latent Growth and Related SEM Models Models


***MIXED GROWTH MODEL WITH LONG DATA -- WHAT WE'VE DONE SO FAR

**use democracy1996-2002.long.dta

xtset cc_2 year, delta (2) 
gen yearnum2=yearnum-7
**Mixed Growth Model
mixed dg01i yearnum2 || cc_2: yearnum2 , mle cov(unstructured)
**Full Growth Model with Prior Democracy, Ethnic Fractionalization as Intercept and Slope Predictors
gen yrdemoc=yearnum2*l203  //CREATE NEW VARIABLES THAT INTERACT WITH TIME TO ENTER INTO XTMIXED
gen yrethnic=yearnum2*l225
mixed dg01i l203 l225 yearnum2 yrdemoc yrethnic || cc_2:  yearnum2 , cov (unstructured)

****LATENT GROWTH MODELS

**WIDE DATA VERSION
**use democracy1996-2002.wide.dta

**Latent Growth Model 
**DIAGRAM 1


sem (dg01i1 <- _cons@0, ) (dg01i2 <- _cons@0, ) (dg01i3 <- _cons@0, ) (dg01i4 <- _cons@0, ) (Intercept@1 -> dg01i1, ) (Intercept@1 -> dg01i2, ) /// 
(Intercept@1 -> dg01i3, ) (Intercept@1 -> dg01i4, ) (Slope@0 -> dg01i1, ) (Slope@2 -> dg01i2, ) (Slope@4 -> dg01i3, ) (Slope@6 -> dg01i4, ), /// 
covstruct(_lexogenous, diagonal) latent(Intercept Slope ) cov( e.dg01i1@var e.dg01i2@var e.dg01i3@var e.dg01i4@var Intercept*Slope) means( Intercept Slope) nocapslatent

estat gof, sta (all)

***not such a great model!
estat mindices
/// shows, e.g., that relaxing equal error variances might be appropriate, and there may be autocorrelated residuals in dg01i as well

** add autocorrelation:  plausible estimates and significant difference in chi-square
sem (dg01i1 <- _cons@0, ) (dg01i2 <- _cons@0, ) (dg01i3 <- _cons@0, ) (dg01i4 <- _cons@0, ) (Intercept@1 -> dg01i1, ) (Intercept@1 -> dg01i2, ) /// 
(Intercept@1 -> dg01i3, ) (Intercept@1 -> dg01i4, ) (Slope@0 -> dg01i1, ) (Slope@2 -> dg01i2, ) (Slope@4 -> dg01i3, ) (Slope@6 -> dg01i4, ), /// 
covstruct(_lexogenous, diagonal) latent(Intercept Slope ) cov( e.dg01i1@var e.dg01i2@var e.dg01i3@var e.dg01i4@var Intercept*Slope e.dg01i1*e.dg01i2@covar ///
e.dg01i2*e.dg01i3@covar e.dg01i3*e.dg01i4@covar) means( Intercept Slope) nocapslatent

* add heteroskedasticity and autocorrelation:  plausible estimates (?) and significant difference in chi-square
sem (dg01i1 <- _cons@0, ) (dg01i2 <- _cons@0, ) (dg01i3 <- _cons@0, ) (dg01i4 <- _cons@0, ) (Intercept@1 -> dg01i1, ) (Intercept@1 -> dg01i2, ) /// 
(Intercept@1 -> dg01i3, ) (Intercept@1 -> dg01i4, ) (Slope@0 -> dg01i1, ) (Slope@2 -> dg01i2, ) (Slope@4 -> dg01i3, ) (Slope@6 -> dg01i4, ), /// 
covstruct(_lexogenous, diagonal) latent(Intercept Slope ) cov( e.dg01i1 e.dg01i2 e.dg01i3 e.dg01i4 Intercept*Slope e.dg01i1*e.dg01i2@covar ///
e.dg01i2*e.dg01i3@covar e.dg01i3*e.dg01i4@covar) means( Intercept Slope) nocapslatent

***WOW!!

**Full Growth Model -- WITH ADDITIONAL PREDICTORS OF INTERCEPT AND SLOPE
**DIAGRAM 2 -- NOTE THIS ADDS THE "_CONS" TO THE PREDICTION OF INTERCEPT AND SLOPE TO GET MEANS OF EACH -- VERY IMPORTANT!!!

sem (dg01i1 <- _cons@0, ) (dg01i2 <- _cons@0, ) (dg01i3 <- _cons@0, ) (dg01i4 <- _cons@0, ) (_cons -> Intercept, ) /// 
(_cons -> Slope, ) (Intercept@1 -> dg01i1, ) (Intercept@1 -> dg01i2, ) (Intercept@1 -> dg01i3, ) (Intercept@1 -> dg01i4, ) /// 
 (l203 -> Intercept, ) (l203 -> Slope, ) (Slope@0 -> dg01i1, ) (Slope@2 -> dg01i2, ) (Slope@4 -> dg01i3, ) (Slope@6 -> dg01i4, ) /// 
 (l225 -> Intercept, ) (l225 -> Slope, ), latent(Intercept Slope ) cov( e.dg01i1@var e.dg01i2@var e.dg01i3@var e.dg01i4@var e.Intercept*e.Slope) nocapslatent


estat gof, sta (all)


****FURTHER EXTENTION:  RELAX TIME CONSTRAINTS AS 0, 2, 4, 6 -- IT IS POSSIBLE TO FREE *ONE* OF THE INNER PARAMETERS TO GET AT NON-LINEAR CHANGE! (AND FITS BETTER)


***LATENT GROWTH MEDIATION MODEL WITH INTERCEPT AND SLOPE AS PREDICTORS OF ANOTHER LEVEL 2 OUTCOME 
***DIAGRAM 3

egen prf01m=rmean(prf01i1 prf01i2 prf01i3 prf01i4)
sem (dg01i1 <- _cons@0, ) (dg01i2 <- _cons@0, ) (dg01i3 <- _cons@0, ) (dg01i4 <- _cons@0, ) (_cons -> Intercept, ) (_cons -> Slope, ) /// 
(_cons -> prf01m, ) (Intercept@1 -> dg01i1, ) (Intercept@1 -> dg01i2, ) (Intercept@1 -> dg01i3, ) ///
(Intercept@1 -> dg01i4, ) (Intercept -> prf01m, ) (l203 -> Intercept, ) (l203 -> Slope, ) (Slope@0 -> dg01i1, )  /// 
(Slope@4 -> dg01i2, ) (Slope@8 -> dg01i3, ) (Slope@12 -> dg01i4, ) (Slope -> prf01m, ) (l225 -> Intercept, )  /// 
(l225 -> Slope, ), latent(Intercept Slope ) cov( e.dg01i1@var e.dg01i2@var e.dg01i3@var e.dg01i4@var e.Intercept*e.Slope) nocapslatent


*****BIVARIATE LATENT GROWTH MODEL -- AID AND DEMOCRACY, EACH WITH THEIR OWN GROWTH CURVES WITH CORRELATED PARAMETERS
****DIAGRAM 4
sem (dg01i1 <- _cons@0, ) (dg01i2 <- _cons@0, ) (dg01i3 <- _cons@0, ) (dg01i4 <- _cons@0, ) (aid1001 <- _cons@0, ) /// 
 (Intercept@1 -> dg01i1, ) (Intercept@1 -> dg01i2, ) (Intercept@1 -> dg01i3, ) (Intercept@1 -> dg01i4, ) (aid1002 <- _cons@0, ) ///
 (Slope@0 -> dg01i1, ) (Slope@2 -> dg01i2, ) (Slope@4 -> dg01i3, ) (Slope@6 -> dg01i4, ) (aid1003 <- _cons@0, ) /// 
 (aid1004 <- _cons@0, ) (AidInt@1 -> aid1001, ) (AidInt@1 -> aid1002, ) (AidInt@1 -> aid1003, ) (AidInt@1 -> aid1004, ) /// 
 (AidSlope@0 -> aid1001, ) (AidSlope@2 -> aid1002, ) (AidSlope@4-> aid1003, ) (AidSlope@6 -> aid1004, ), ///
 covstruct(_lexogenous, diagonal) difficult latent(Intercept Slope AidInt AidSlope ) /// 
 cov( e.dg01i1@var e.dg01i2@var e.dg01i3@var e.dg01i4@var e.aid1001@p Intercept*Slope e.aid1002@p /// 
 e.aid1003@p e.aid1004@p AidInt*Intercept AidInt*Slope AidInt*AidSlope AidSlope*Intercept AidSlope*Slope) means( Intercept Slope AidInt AidSlope) nocapslatent

***ALSO CAN CORRELATE TIME-SPECIFIC ERRORS BETWEEN AID AND DEMORACY 
***ALSO CAN BUILD TOWARD "STRUCTURED RESIDUALS MODEL" OF CURRAN ET AL (2014) -- SEE POWERPOINT
***ALSO CAN BUILS TOWARD "AUTOREGRESSIVE LATENT TRAJECORY MODEL" OF BOLLEN BY ALLOWING LAGGED DEMOCRACY AND
   *LAGGED AID TO AFFECT FUTURE VALUES (SEE POWERPOINT, BUT NEED ALSO TO ATTEND TO "INITIAL CONDITIONS" PROBLEM)

