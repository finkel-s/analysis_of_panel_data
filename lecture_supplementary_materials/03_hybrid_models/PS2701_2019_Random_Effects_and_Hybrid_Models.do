PS2701-2019
Longitudinal Analysis
Week 3

RANDOM EFFECTS AND HYBRID MODELS

*USE KENYA LONG DATA

xtset id wave
xtreg know_w totalce_w sex educ age, fe  
estimates store fixed

**THE RANDOM EFFECTS MODEL
xtreg know_w totalce_w sex educ age, re theta
estimates store random
estimates table fixed random   //WHY DO THEY DIFFER?
xttest0                        //TEST OF THE OVERALL STATISTICAL SIGNIFICANCE OF THE "U"

xtreg know_w totalce_w sex educ age, re vce (cluster id) // CLUSTER ROBUST STANDARD ERRORS VERSION 

//RANDOM EFFECTS GLS:  WEIGHT DATA BY INVERSE OF THE ERROR COVARIANCE MATRIX TO GET EFFICIENT ESTIMATES
//ERROR VARIANCES:  SIGMA(U)^2 + SIGMA(EPSILON)^2
//ERROR COVARIANCES:  SIGMA(U)^2
//WEIGHTING BASED ON "THETA" = 1-[(SIGMA(EPSILON)/SQRT[(T*[SIGMA(U)^2)+SIGMA(EPSILON)^2]

//BUT WE DON'T KNOW EITHER OF THESE QUANTITIES, SO WE HAVE TO ESTIMATE THEM FROM OUR DATA -- "FEASIBLE GLS"

//WE CAN GET SIGMA(EPSILON) AS THE STANDARD ERROR OF ESTIMATE FROM THE FIXED EFFECT MODEL, SINCE U WAS DEMEANED OUT OF THE EQUATION
//WE CAN GET SIGMA(U) FROM THE DIFFERENCE BETWEEN THE TOTAL ERROR SIGMA IN THE BETWEEN REGRESSION AND SIGMA(EPSILON) FROM THE FIXED

xtreg know_w totalce_w sex educ age, be

//COMPUTATIONAL FORMULA:  THETA = 1 - SQRT(SIGMA (WITHIN)^2/(T*SIGMA(BETWEEN)^2)
display 1-((.822^2)/(3*.606^2))^.5
//SO:  THETA= .217
//AS THETA GETS CLOSE TO 1, THAT MEANS MORE OF ERROR VARIATION IS UNIT-LEVEL VARIATION.  AS THETA GETS CLOSE TO 0, NONE OF ERROR
//VARIATION IS UNIT-LEVEL VARIATION

**DO THE GLS MANUALLY:
//RANDOM EFFECTS GLS= Y(it)-THETA(Ybar(i))= B(X(it)-THETA(Xbar(i)) + (U(it)-THETA(Ubar(i))

*egen totalce_mn=mean(totalce_w), by (id).                 // ALREADY IN DATA SET
egen knowmean2=mean(know_w), by(id)
gen randy=know_w-.217*knowmean2                            //Y MINUS 'THETA-DEMEANED' Y
gen randx=totalce_w-.217*totalce_mn                        // X MINUS 'THETA-DEMEANED' X
gen randsex=.783*sex                                       // X MINUS 'THETA-DEMEANED' X, IN THIS CASE [SEX-.216*SEX=.784*SEX]
gen randeduc=.783*educ                                     //  X MINUS 'THETA-DEMEANED' X]
gen randage=.783*age                                       //  X MINUS 'THETA-DEMEANED' X]
regress randy randx randsex randeduc randage, vce(cluster id)

//NOTE R-SQUARED HERE IS IN TERMS OF THETA-CORRECTED Y, SO WILL NOT BE IDENTICAL TO TRUE ESTIMATE FROM RANDOM EFFECTS ESTIMATION
//NOTE ALSO:  IF THETA IS 1, THEN RANDOM AND FIXED EFFECTS ESTIMATES ARE IDENTICAL.  SO AS UNIT LEVEL ERROR VARIATION BECOMES LARGER AND 
//LARGER, YOU WOULD WANT TO USE THE PURE "WITHIN" ESTIMATOR TO GET RID OF THE UNIT EFFECT.  AS THETA APPROACHES ZERO,
//THE RANDOM EFFECTS ESTIMATE IS THE SAME AS WHAT OLS WOULD GIVE YOU.  SO IF THERE IS NO DISTINCT UNIT LEVEL VARIATION IN ERROR TERM, ALL OF IT IS 
//"PURE" RANDOM ERROR AND YOU DON'T NEED TO CONTROL FOR THE UNIT EFFECT AT ALL, SO OLS IS THE RESULT 

regress know_w totalce_w sex educ age // POOLED OLS GIVES EFFECT OF .17, SO RE AT .16 IS PRETTY CLOSE SINCE THETA IS SMALL. FE IS .129

***TEST FOR RANDOM VERSUS FIXED EFFECTS:  THE 'HAUSMAN' TEST
hausman fixed random

***TWO-WAY FIXED AND RANDOM EFFECTS MODEL WITH TIME (WAVE) DUMMY VARIABLES:  USE POLITICAL PARTICIPATION AGAIN TO ILLUSTRATE
tab wave, gen(wavv)
xtreg polpart_w totalce_w sex educ age wavv2 wavv3, fe vce(cluster id)
xtreg polpart_w totalce_w sex educ age wavv2 wavv3, fe  //WITHOUT CLUSTER ROBUST STANDARD ERRORS BECAUSE OF LIMITATIONS OF HAUSMAN TEST IN STATA
estimates store fixed2way    

xtreg polpart_w totalce_w sex educ age wavv2 wavv3, re vce(cluster id)
xtreg polpart_w totalce_w sex educ age wavv2 wavv3, re  //WITHOUT CLUSTER ROBUST STANDARD ERRORS BECAUSE OF LIMITATIONS OF HAUSMAN TEST IN STATA

estimates store rand2way
estimates table fixed2way rand2way 
hausman fixed2way rand2way

***FINALLY, TEST ASSUMPTIONS ABOUT ERROR TERM STRUCTURE IN RANDOM EFFECTS MODEL:  TOTAL ERROR CORRELATIONS ARE CONSTANT 
//AND RANDOM ERROR CORRELATIONS ARE ZERO
xtreg know_w totalce_w sex educ age, re vce(cluster id)
predict randtotres, ue
predict randerror, e

keep randtotres randerror id wave
reshape wide randtotres randerror, i(id) j(wave)  

corr randtotres*  //SUGGESTS THAT ASSUMPTION OF 'EXCHANGEABLE' TOTAL ERROR TERM MAY NOT BE CORRECT
corr randerror*  // SUGGESTS THAT ASSUMPTION OF NON-AUTOCORRELATED ERRORS MAY NOT BE CORRECT


***HYBRID MODELS

**GET BACK KENYA LONG DATA AFTER CLEARING WORKING DATA
xtset id wave
tab wave, gen(wavv)

**1.  PLUEMPER-TRAUGER FIXED EFFECTS VARIANCE DECOMPOSITION:  RUN FIXED EFFECTS ON THE TIME-VARYING FACTORS, THEN A 
**                       BETWEEN REGRESSION ON THE ESTIMATE OF THE UNIT EFFECT FROM STEP 1 USING THE TIME-INVARIANT FACTORS
**                       THEN PLUG BACK INTO AN ORDINARY OLS MODEL WITH TIME-INVARIANT, TIME-VARYING AND THE RESIDUAL FROM 
**                       STEP 2 AS INDEPENDENT VARIABLES.  LOGIC:  STEP 2 GIVES YOU THE PURE UNIT EFFECT SEPARATE FROM THE
**                       TIME-INVARIANTS AND STEP 3 PUTS ALL VARIABLES INTO THE MODEL TO GET EFFECT OF DEMEANED TIME-VARYING
**                       FACTORS, EFFECT OF TIME-INVARIANT FACTORS, AND THE UNIT EFFECT ON Y WITH CORRECT S.E.S AND ADJUSTED
**                       FOR INTERCORRELATION OF ALL VARIABLES
**                       ASSUMPTION: TIME-INVARIANT FACTORS UNRELATED TO ERROR TERM, WHICH IS THE TRUE UNIT EFFECT
**Step 1:  Fixed Effects
xtreg polpart_w totalce_w wavv2 wavv3,fe

**Step 2:  "Between" -Type Regression on the Predicted Unit Effects from Step 1
predict fixedu, u
reg fixedu sex educ age
predict step2resid, resid

*Step 3:  All variables in an OLS including the residual from Step 2
regress polpart_w totalce_w sex educ age wavv2 wavv3 step2resid, vce(cluster id)

//NOTE:  IF YOU WANT TO USE THIS METHOD, THERE IS A STATA 'ADO' FILE FOR IT ON PLUMPER WEB SITE SO NO NEED TO DO IT MANUALLY


*****BELL-JONES MULTILEVEL HYBRID MODEL

**	CONTROL FOR POSSIBLE CORRELATION BETWEEN X AND U IN RE MODEL BY INCLUDING THE MEAN OF THE TIME-VARYING INDEPENDENT VARIABLE(S)
*egen totalce_mn=mean(totalce_w), by (id).                 // ALREADY IN DATA SET

xtreg polpart_w totalce_w sex educ age wavv2 wavv3, re vce(cluster id)
xtreg polpart_w totalce_w totalce_mn sex educ age wavv2 wavv3, re vce(cluster id)

***SHOW THE EQUIVALENCE OF THIS MODEL TO INCLUSION OF BOTH FE AND BE EFFECTS OF X SIMULTANEOUSLY
gen totcemeandev=totalce_w-totalce_mn

xtreg polpart_w totcemeandev wavv2 wavv3, fe
xtreg polpart_w totalce_mn sex educ age, be

xtreg polpart_w totcemeandev totalce_mn sex educ age wavv2 wavv3, re vce (cluster id)

***AND THEN THE SAME IDEA AS IN THE HAUSMAN TEST FOR TESTING THE RE MODEL:  DOES THE ASSUMPTION OF EQUAL FE (WITHIN EFFECT) AND BE (BETWEEN) EFFECT HOLD?

test totcemeandev=totalce_mn

