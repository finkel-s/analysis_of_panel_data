PS2701
Longitudinal Analysis 

Weeks 8-9: FIXED, RANDOM AND DYNAMIC MODELS WITH THE STRUCTURAL EQUATION FRAMEWORK

*USE DEMOCRACY1996-2002.DTA
//drop cname year
//replace yearnum=1 if yearnum==7
//replace yearnum=2 if yearnum==9
//replace yearnum=3 if yearnum==11
//replace yearnum=4 if yearnum==13
//reshape wide dg01i dg02i prf01i pol05 aid100, i(cc_2) j(yearnum)


**use democracy1996-2002.wide.dta

***RANDOM EFFECTS 
     **NOTE EQUALITY CONSTRAINTS ON ALL COEFFICIENTS:  DEMOC EFFECT, U-TERM (Intercept) CONSTRAINED AT 1, EQUAL CONSTANTS, EQUAL ERROR VARIANCE
	 **THIS MAKES THE MODEL A POOLED MODEL WITH AN ADDED RANDOM INTERCEPT
	 
     **DIAGRAM 1
	 
sem (dg02i1 <- _cons@x, ) (dg02i2 <- _cons@x, ) (dg02i3 <- _cons@x, ) (dg02i4 <- _cons@x, ) (aid1001@c -> dg02i1, ) (aid1002@c -> dg02i2, ) (aid1003@c -> dg02i3, ) /// 
 (U@1 -> dg02i1,) (U@1 -> dg02i2, ) (U@1 -> dg02i3, ) (U@1 -> dg02i4, ) (aid1004@c -> dg02i4, ), covstruct(_lexogenous, diagonal) cov(_lexogenous*_oexogenous@0) /// 
 latent(U ) cov(e.dg02i1@e e.dg02i2@e e.dg02i3@e e.dg02i4@e) nocapslatent


     **DIAGRAM 2 -- ADDS ANOTHER TIME-INVARIANT INDEPENDENT VARIABLE

sem (dg02i1 <- _cons@x, ) (dg02i2 <- _cons@x, ) (dg02i3 <- _cons@x, ) (dg02i4 <- _cons@x, )  (aid1001@c -> dg02i1, ) (aid1002@c -> dg02i2, ) (aid1003@c -> dg02i3, ) /// 
(U@1 -> dg02i1,) (U@1 -> dg02i2, ) (U@1 -> dg02i3, ) (U@1 -> dg02i4, ) (aid1004@c -> dg02i4, ) (l225@h -> dg02i1, ) (l225@h -> dg02i2, ) (l225@h -> dg02i3, ) /// 
(l225@h -> dg02i4), covstruct(_lexogenous, diagonal) cov(_lexogenous*_oexogenous@0) latent(U ) cov( e.dg02i1@e e.dg02i2@e e.dg02i3@e e.dg02i4@e) nocapslatent


***FIXED EFFECTS
     **RELAXES THE CONSTRAINT THAT THE COVARIANCES BETWEEN LATENT EXOGENOUS AND OBSERVED EXOGENOUS IS 0
     **DIAGRAM 3 

sem (dg02i1 <- _cons@x, ) (dg02i2 <- _cons@x, ) (dg02i3 <- _cons@x, ) (dg02i4 <- _cons@x, ) (aid1001@c -> dg02i1, ) (aid1002@c -> dg02i2, ) (aid1003@c -> dg02i3, ) (U@1 -> dg02i1,) /// 
(U@1 -> dg02i2, ) (U@1 -> dg02i3, ) (U@1 -> dg02i4, ) (aid1004@c -> dg02i4, ), covstruct(_lexogenous, diagonal) latent(U ) /// 
cov(e.dg02i1@e e.dg02i2@e e.dg02i3@e e.dg02i4@e) nocapslatent



     ***NOTE: RANDOM EFFECTS MODEL 1:  CHI-SQUARE 123.85 with 26 df
	 *        FIXED EFFECTS MODEL  1: CHI-SQUARE  119.35 with 22 df
     *        CHI-SQUARE DIFFERENCE = 4.35 WITH 4 df, so FE model is NOT a significant improvement!	 

 dis chi2tail(4, 123.85-119.35)  // shows the insignificance of the improvement in fit
 
    ***WITH ADDITIONAL TIME-VARYING X

sem (dg02i1 <- _cons@x, ) (dg02i2 <- _cons@x, ) (dg02i3 <- _cons@x, ) (dg02i4 <- _cons@x, ) (aid1001@c prf01i1@j -> dg02i1, ) (aid1002@c prf01i2@j -> dg02i2, ) ///
 (aid1003@c prf01i3@j -> dg02i3, ) (U@1 -> dg02i1,) (U@1 -> dg02i2, ) (U@1 -> dg02i3, ) (U@1 -> dg02i4, ) (aid1004@c prf01i4@j-> dg02i4, ), /// 
 covstruct(_lexogenous, diagonal) latent(U ) cov(e.dg02i1@e e.dg02i2@e e.dg02i3@e e.dg02i4@e) nocapslatent


** TO ADD TIME EFFECTS:  JUST LET THE INTERCEPTS (_cons) OF THE OUTCOMES VARY TO CAPTURE CHANGES ACROSS SAMPLE AT GIVEN POINTS IN TIME
***RE model with time-varying intercepts

 sem (dg02i1 <- _cons, ) (dg02i2 <- _cons, ) (dg02i3 <- _cons, ) (dg02i4 <- _cons, ) (aid1001@c -> dg02i1, ) (aid1002@c -> dg02i2, ) (aid1003@c -> dg02i3, ) /// 
 (U@1 -> dg02i1,) (U@1 -> dg02i2, ) (U@1 -> dg02i3, ) (U@1 -> dg02i4, ) (aid1004@c -> dg02i4, ), covstruct(_lexogenous, diagonal) cov(_lexogenous*_oexogenous@0) /// 
 latent(U ) cov(e.dg02i1@e e.dg02i2@e e.dg02i3@e e.dg02i4@e) nocapslatent
 
	
	****RE CHI SQUARE WITHOUT TIME-VARYING INTERCEPTS: 123.85 with 26 df
	****RE CHI SQUARE WITH TIME-VARYING INTERCEPTS:    110.64 WITH 23 df

dis chi2tail(3, 123.85- 110.64)  // shows the significance of the improvement in fit
	
	
    **NOTE LARGE IMPROVEMENT IN FIT WITH VARYING INTERCEPTS, OR WHAT WOULD BE REPRESENTED BY TIME DUMMY VARIABLES IN ECONOMETRIC FORMULATIONS
	
***FE model with time-varying intercepts

sem (dg02i1 <- _cons, ) (dg02i2 <- _cons, ) (dg02i3 <- _cons, ) (dg02i4 <- _cons, ) (aid1001@c -> dg02i1, ) (aid1002@c -> dg02i2, ) (aid1003@c -> dg02i3, ) (U@1 -> dg02i1,) /// 
(U@1 -> dg02i2, ) (U@1 -> dg02i3, ) (U@1 -> dg02i4, ) (aid1004@c -> dg02i4, ), covstruct(_lexogenous, diagonal) latent(U ) /// 
cov(e.dg02i1@e e.dg02i2@e e.dg02i3@e e.dg02i4@e) nocapslatent

	****FE CHI SQUARE WITH TIME-VARYING INTERCEPTS:    106.31 WITH 19 df

	****FE CHI SQUARE WITHOUT TIME-VARYING INTERCEPTS:  119.34 WITH 22 df
	
	**NOTE IMPROVEMENT OVER FE WITHOUT TIME-VARYING INTERCEPTS, BUT STILL NO IMPROVEMENT OVER RE MODEL WITH TIME-VARYING INTERCEPTS

	
	**TO ALLOW FOR UNOBSERVABLES TO INFLUENCE CHANGES IN THE OUTCOME -- NOT ONLY LEVELS -- OVER U-TERM EFFECTS TO VARY OVER TIME
	**USE RE MODEL AS EXAMPLE :  RELAX CONSTRAINTS THAT U EFFECTS ARE 1
	
sem (dg02i1 <- _cons, ) (dg02i2 <- _cons, ) (dg02i3 <- _cons, ) (dg02i4 <- _cons, ) (aid1001@c -> dg02i1, ) (aid1002@c -> dg02i2, ) (aid1003@c -> dg02i3, ) /// 
 (U@1 -> dg02i1,) (U -> dg02i2, ) (U -> dg02i3, ) (U -> dg02i4, ) (aid1004@c -> dg02i4, ), covstruct(_lexogenous, diagonal) cov(_lexogenous*_oexogenous@0) /// 
 latent(U ) cov(e.dg02i1@e e.dg02i2@e e.dg02i3@e e.dg02i4@e) nocapslatent
 
   ***ORIGINAL RE TIME-VARYING INTERCEPT WITH CONSTANT U EFFECT:  		110.64 WITH 23 df
   **CHI-SQUARE RE TIME-VARYING INTERCEPT WITH NON-CONSTANT U EFFECT:   105.15 WITH 20 df
  
dis chi2tail(3, 110.64- 105.615)  // shows the insignificance of the improvement in fit

	
*******************************************************************************************************************************
**REPLICATE THESE MODELS IN XTREG WITH LONG FORM DATA (DEMOCRACY1996-2002.LONG.DTA)
xtset cc_2 yearnum
tab yearnum, gen(yrr)
**RE
xtreg dg02i aid100, mle
**RE WITH ADDITIONAL TIME-INVARIANT VARIABLE
xtreg dg02i aid100 l225, mle
**FE
xtreg dg02i aid100, fe
**FE WITH ADDITIONAL TIME-VARIANT VARIABLE
xtreg dg02i aid100 prf01i, fe
***TWO WAY MODELS(TIME VARYING INTERCEPTS)
xtreg dg02i aid100 yrr*, mle
xtreg dg02i aid100 yrr*, fe
********************************************************************************************************************************


*** SEM VERSIONS OF 4 WAVE DYNAMIC PANEL MODEL:  USE democracy1996-2002.wide.dta again
 ****Use Polity version of Democracy Scale (DG01i)

******Model 1:  Contemporaneous Effect of Aid on Democracy 
******DIAGRAM 4
sem (dg01i1@w -> dg01i2, ) (dg01i2@w -> dg01i3, ) (dg01i3@w -> dg01i4, ) (aid1001@c -> dg01i1, ) (aid1002@c -> dg01i2, ) (aid1003@c -> dg01i3, ) ///
(U@1 -> dg01i1, ) (U@1 -> dg01i2, ) (U@1 -> dg01i3, ) (U@1 -> dg01i4, ) (aid1004@c -> dg01i4, ), covstruct(_lexogenous, diagonal) /// 
cov(_lexogenous*_oexogenous@0) difficult latent(U ) cov( e.dg01i1@e e.dg01i2@e e.dg01i3@e aid1001*aid1002 aid1001*aid1003 aid1001*aid1004 /// 
aid1002*aid1003 aid1002*aid1004 aid1003*aid1004 U*aid1001 U*aid1002 U*aid1003 U*aid1004 e.dg01i4@e) nocapslatent


*****MODEL 2:  Full Dynamic Panel Model with Lagged Reciprocal Effects
******DIAGRAM 5

sem (aid1001@b -> aid1002, ) (aid1001@d -> dg01i2, ) (aid1002@b -> aid1003, ) (aid1002@d -> dg01i3, ) (aid1003@b -> aid1004, ) ///
(aid1003@d -> dg01i4, ) (dg01i1@n -> aid1002, ) (dg01i1@a -> dg01i2, ) (dg01i2@n -> aid1003, ) (dg01i2@a -> dg01i3, ) ///
(dg01i3@n -> aid1004, ) (dg01i3@a -> dg01i4, ) (U@1 -> dg01i2, ) (U@1 -> dg01i3, ) (U@1 -> dg01i4, ) (U2@1 -> aid1002, ) ///
(U2@1 -> aid1003, ) (U2@1 -> aid1004, ), covstruct(_lexogenous, diagonal) cov(_lexogenous*_oexogenous@0) difficult latent(U U2 ) ///
cov( e.aid1002@f e.aid1003@f e.aid1004@f dg01i1*aid1001 e.dg01i2@e e.dg01i3@e e.dg01i4@e U*dg01i1 U*U2 U2*aid1001) ///
means( U@0 U2@0) nocapslatent 

*****Model 3:  Sequential Exogeneity, Lagged Effects -- Allison et al (2017), Single Equation Method (see Powerpoint)
******DIAGRAM 6

sem (aid1001@c -> dg01i2, ) (aid1002@c -> dg01i3, ) (aid1003@c -> dg01i4, ) (aid1004) (dg01i1@a -> dg01i2,) ///
 (dg01i2@a -> dg01i3, ) (dg01i3@a -> dg01i4, ) (U@1 -> dg01i2, ) (U@1 -> dg01i3, ) (U@1 -> dg01i4, ) (ERR2@1 -> dg01i2, ), ///
 covstruct(_lexogenous, diagonal) cov(_lexogenous*_oexogenous@0) latent(U ERR2 ) cov( aid1001*aid1002 aid1001*aid1003 aid1001*aid1004 aid1002*aid1003 ///
 aid1002*aid1004 aid1003*aid1004 aid1003*U dg01i1*aid1001 dg01i1*aid1002 dg01i1*aid1003 dg01i1*aid1004 e.dg01i2@0 U*aid1001 U*aid1002 U*aid1004 U*dg01i1 ERR2*aid1003) means( ERR2@0) nocapslatent




