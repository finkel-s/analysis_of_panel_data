PS2701 
LONGITUDINAL ANALYSIS

MULTILEVEL GSEM MODELS ("GENERALIZED STRUCTURAL EQUATION MODELS")


******GSEM

/// USES LONG FORM DATA TO ESTIMATE MULTILEVEL MODELS WITH RANDOM EFFECTS -- NO TRICKS NECESSARY!
/// NOTE:  MANY OF THE MODELS (RE, FE, GROWTH) HERE ASIDE FROM RANDOM COEFFICIENT AND HYBRID MODELS CAN BE ESTIMATED WITH 
/// WIDE FORM DATA ALSO, BUT ALL EQUATIONS MUST BE SPECIFIED ON AN EQUATION-BY-EQUATION BASIS AS WE SAW EARLIER IN THE SEMESTER
/// LONG-FORM IS MORE PARSIMONIOUS, CAN MAKE USE OF THE ADVANTAGES OF SEM WITHOUT THE "CLUTTER".  
/// BUT MORE DIFFICULT (THOUGH NOT IMPOSSIBLE) TO MODEL EQUATION-BY-EQUATION DIFFERENCES, CONSTRAINTS
/// THAT CAPTURE VARIATION IN EFFECTS OVER TIME, ETC.

**use democracy.1996-2992.long.dta


***RANDOM EFFECTS

***Linear Model with Random Effect
***DIAGRAM 5

gsem (aid100 -> dg01i, ) (l203 -> dg01i, ) (l225 -> dg01i, ) (M1[cc_2] -> dg01i, ), covstruct(_lexogenous, diagonal) latent(M1 ) nocapslatent


****Multilevel Model Version:  Level 1 and Level2 effects
**     Note that the time-invariant variables now predict the random intercept, as in Multilevel model Level 2 equation

gsem (aid100 -> dg01i, ) (l203 -> M1[cc_2], ) (l225 -> M1[cc_2], ) (M1[cc_2] -> dg01i, ), ///
latent(M1 ) nocapslatent

****Hybrid Model
***DIAGRAM 5a

egen aidmean=mean(aid100), by (cc_2) 
gen aiddvmean=aid100-aidmean
gen yearnum2=yearnum-7
quietly tab yearnum2, gen (yrr)

gsem (aiddvmean -> dg01i, ) (aidmean -> M2[cc_2], ) (M2[cc_2] -> dg01i, ) (yrr3 -> dg01i, ) (yrr2 -> dg01i, ) /// 
(yrr4 -> dg01i, ) (l225 -> M2[cc_2], ) (l203 -> M2[cc_2], ), latent(M2 ) nocapslatent


****test RE assumption with test
test aiddvmean=aidmean


****HYBRID MODEL WITH LATENT 'BETWEEN' EFFECT  
**DIAGRAM 6
gsem (aid100 -> dg01i, ) (M3[cc_2] -> aid100, ) (M3[cc_2] -> M2[cc_2], ) (M2[cc_2] -> dg01i, ) (yrr3 -> dg01i, ) /// 
(yrr2 -> dg01i, ) (yrr4 -> dg01i, ) (l225 -> M2[cc_2], ) (l203 -> M2[cc_2], ), covstruct(_lexogenous, diagonal) difficult latent(M3 M2 ) nocapslatent


***NOTE:  THIS DOES NOT CONVERGE USING THE MEAN-DEVIATED VERSION OF AID, SO YOU CAN FIND THE EFFECT WITH POST-ESTIMATION MANIPULATION

gsem, coeflegend                              // This gives you the STATA internal language it uses to refer to each estimated coefficient
lincom aid100+_b[M2[cc_2]:M3[cc_2]]           // in this case the "between" effect is referred to as _b[M2...], 
											 //  and adding this to the "within" effect gives the true "between" effect in the hybrid model
											 // note difference between the latent variable estimate of the between effect and the "cluster mean" estimate
											// NOTE: THIS IS NOT EQUIVALENT IN MPLUS, WHICH PROVIDES THE TRUE BETWEEN EFFECT IN TWO-LEVEL MODELS
											 
test aid100=aid100+_b[M2[cc_2]:M3[cc_2]] 	 // Tests whether "within" and "between" effects are equal


****LATENT GROWTH MODELS IN GSEM

**Latent Growth Model:  Intercept and Slope Only
***DIAGRAM 7

gsem (yearnum2 -> dg01i, ) (M1[cc_2] -> dg01i, ) (M2[cc_2]#c.yearnum2 -> dg01i), covstruct(_lexogenous, diagonal) /// 
latent(M1 M2 ) cov( M2[cc_2]*M1[cc_2]) nocapslatent

**equivalence in "mixed"
mixed dg01i yearnum2 || cc_2: yearnum2 , mle cov(unstructured)

***Full Growth Model with Prior Democracy, Ethnic Fractionalization as Intercept and Slope Predictors
***DIAGRAM 8

gsem (yearnum2 -> dg01i, ) (M1[cc_2] -> dg01i, ) (l203 -> M1[cc_2], ) (l203 -> M2[cc_2], ) (l225 -> M1[cc_2], ) /// 
(l225 -> M2[cc_2], ) (M2[cc_2]#c.yearnum2 -> dg01i), latent(M1 M2 ) cov( e.M2[cc_2]*e.M1[cc_2]) nocapslatent

**equivalence in "mixed"
gen yeardemoc=yearnum2*l203
gen yearethnic=yearnum2*l225
mixed dg01i yearnum2 l203 l225 yeardemoc yearethnic || cc_2: yearnum2 , mle cov(unstructured)

***RANDOM COEFFICIENT MODEL -- WITH AID100

***DIAGRAM 9

gsem (aid100 -> dg01i, ) (M1[cc_2] -> dg01i, ) (l203 -> M1[cc_2], ) (l203 -> M2[cc_2], ) (l225 -> M1[cc_2], ) /// 
(l225 -> M2[cc_2], ) (M2[cc_2]#c.aid100 -> dg01i), latent(M1 M2 ) cov( e.M2[cc_2]*e.M1[cc_2]) nocapslatent

**equivalence in "mixed"
 
gen aiddemoc=aid100*l203
gen aidethnic=aid100*l225
mixed dg01i aid100 l203 l225 aiddemoc aidethnic || cc_2: aid100 , mle cov(unstructured)


****DIAGRAM 10:  FULL MULTILEVEL SEM RANDOM COEFFICIENT MODEL

gsem (aid100 -> dg01i, ) (M1[cc_2] -> dg01i, ) (l203 -> M1[cc_2], ) (l203 -> M2[cc_2], ) (l203 -> M3[cc_2], ) /// 
(l225 ->M1[cc_2], ) (l225 -> M2[cc_2], ) (l225 -> M3[cc_2], ) (M3[cc_2] -> aid100, ) (yrr2 -> dg01i, ) (yrr3 -> dg01i, ) /// 
 (yrr4 -> dg01i, ) (M2[cc_2]#c.aid100 -> dg01i), latent(M1 M2 M3 ) cov( e.M2[cc_2]*e.M1[cc_2] e.M3[cc_2]*e.M1[cc_2] e.M3[cc_2]*e.M2[cc_2]) nocapslatent


***DIAGRAM 11:  ALTERNATIVE BETWEEN AND WITHIN EFFECTS, NO RANDOM COEFFICIENT
gsem (aid100 -> dg01i, ) (M1[cc_2] -> dg01i, ) (l203 -> M1[cc_2], ) (l203 -> M3[cc_2], ) (l225 -> M1[cc_2],) /// 
(l225 -> M3[cc_2], ) (M3[cc_2] -> aid100, ) (M3[cc_2] -> M1[cc_2], ) (yrr2 -> dg01i, ) (yrr3 -> dg01i, ) (yrr4 -> dg01i, ), difficult latent(M1 M3 ) nocapslatent


*****LATENT BETWEEN EFFECTS NOT POSSIBLE IN "MIXED" -- MAJOR ADVANTAGE OF GSEM !!!!
