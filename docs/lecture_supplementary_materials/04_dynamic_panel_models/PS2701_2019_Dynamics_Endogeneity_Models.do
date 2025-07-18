PS2701
Longitudinal Analysis 

Week 4:	DYNAMIC PANEL AND ENDOGENOUS REGRESSOR MODELS

**USE DEMOCRACY.DTA -- 14 waves 1990-2003

****DYNAMIC PANEL MODELS
xtset cc_2 yearnum
tab yearnum, gen(yrr)                   //GENERATES THE YEAR DUMMY VARIABLES TO INCLUDE AS CONTROLS
reg d.dg02i ld.dg02i d.aid100 yrr*     //NOTE :  'D' STANDS FOR 'DIFFERENCE', 'L' FOR LAG.  SO THIS MODEL IS 
						                // 'DIFFERENCED DEMOCRACY' AS THE DV, 'LAG DIFFERENCED DEMOCRACY' 
						                // AND 'DIFFERENCED AID' AS THE IVS.  NO CORRECTION FOR ANDERSON-HSIAO BIAS HERE  

											
xtivreg dg02i aid100 (l1.dg02i =l2.dg02i) , fd first // THE DYNAMIC FIRST DIFFERENCES IV MODEL ("ANDERSON-HSIAO I")

//NOTE THAT WE LOSE 3 WAVES OF DATA THIS WAY BECAUSE WE ARE USING TWICE-LAGGED DIFFERENCES!!!  

*ALTERNATIVE ANDERSON-HSIAO IS TO USE THE LEVEL (NOT THE DIFFERENCE) IN TWICE LAGGED Y, WHICH SAVES ONE WAVE OF DATA.  

ivregress 2sls d.dg02i d.aid100 (LD.dg02i=L2.dg02i)

ivregress 2sls d.dg02i d.aid100 (LD.dg02i=L2.dg02i) yrr*



*ARANELLO-BOND MODEL

xtabond dg02i aid100 yrr3-yrr14, noconstant twostep            // THE DYNAMIC FIRST DIFFERENCES GMM MODEL ("ARANELLO-BOND") FOR VERSION 10
                                                               // WE DON'T USE YRR1 YRR2 DUE TO LAGGING AND DIFFERENCING


estat abond  //TESTS FOR NO SECOND-ORDER AUTOCORRELATION, AS REQUIRED BY A-B METHOD

estat sargan  //TESTS THE OVERIDENTIFYING RESTRICTIONS VIA SARGAN TEST -- NOTE:  CANNOT BE DONE WITH TWOSTEP 'ROBUST' OPTION BELOW

xtabond dg02i aid100 yrr3-yrr14, noconstant twostep  vce(robust) // THE "TWO STEP" ESTIMATOR WITH ROBUST STANDARD ERRORS
		


**ENDOGENOUS REGRESSOR MODELS


****WITHOUT DYNAMICS:  X AFFECTS Y AT SAME TIME POINT, AND X IS "PREDETERMINED" (SO RELATED TO E(T-1))
gen fhdif=d.dg02i
gen aiddif=d.aid100

****USE CONSTRUCTED FIRST DIFFERENCES, AND LAG X  AS THE INSTRUMENT FOR DIFFERENCED X
****THIS IS VALID (IF X IS PREDERMINED), SINCE X(T-1) IS UNRELATED TO E(T) AND E(T-1), THE FIRST DIFFERENCED ERROR TERM
****BUT X(T-1) WOULD BE RELATED TO E(T-2)

ivregress 2sls fhdif (aiddif=l.aid100) yrr* 
estat firststage                       //HORRIBLE FIRST STAGE ESTIMATES!!

****WITHOUT DYNAMICS: X AFFECTS Y AT SAME TIME POINT, AND X IS FULLY ENDOGENOUS (SO RELATED TO E(T)

****USE CONSTRUCTED FIRST DIFFERENCES, AND LAG(2) X AS THE INSTRUMENT FOR DIFFERENCED X
****THIS IS VALID (IF X IS FULLY ENDOGENOUS), SINCE X(T-2) IS UNRELATED TO E(T) AND E(T-1), THE FIRST DIFFERENCED ERROR TERM
****WE LOSE ANOTHER WAVE OF DATA, HOWEVER

ivregress 2sls fhdif (aiddif=l2.aid100) yrr* 
estat firststage                      //DECENT FIRST STAGE ESTIMATES 



****ARELLANO-BOND WITH ENDOGENOUS REGRESSORS

xtabond dg02i aid100 yrr3-yrr14, pre(aid100) noconstant twostep vce(robust)  // TREATS DEMOC AS PREDETERMINED
                                                              
xtabond dg02i yrr3-yrr14, pre(aid100,endogenous) noconstant twostep vce(robust) // TREATS DEMOC AS FULLY ENDOGENOUS
xtabond dg02i yrr3-yrr14, pre(aid100,endogenous) noconstant twostep 
estat abond
estat sargan
