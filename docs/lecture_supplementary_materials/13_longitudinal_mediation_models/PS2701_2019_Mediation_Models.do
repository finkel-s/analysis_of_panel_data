PS2701
LONGITUDINAL ANALYSIS

I. LONGITUDINAL MEDIATION MODELS WITH LAG EFFECTS

**use Kenya civic education wide data -- check that it has interest_w as one of the variables

***1.  Simple Direct and Indirect Effects of Treatment on Wave 3 Political Interest
sem (interest_w3 <-treat)
/// Total Effect = .069
**Mediation:  Does Civic Education affect Interest in Wave 3 via its effect on Knowledge in Wave 2? So:  Treatment-->Knowledge -->Interest, 
              // and test using temporal lags to ensure causal direction

*DIAGRAM MED-LAG-1
sem (know_w2 -> interest_w3, ) (treat -> know_w2, ) (treat -> interest_w3, ), nocapslatent
estat teffects // GIVES INDIRECT EFFECTS AND 'MODERN' SIGNIFICANCE TEST OF THE INDIRECT EFFECT
sem, coeflegend // GIVES STATA NAMES FOR ALL THE EFFECTS
nlcom _b[know_w2:treat]* _b[interest_w3:know_w2] // GIVES THE MANUAL CALCULATION OF THE INDIRECT EFFECT
nlcom _b[know_w2:treat]* _b[interest_w3:know_w2]+_b[interest_w3:treat] 
		// GIVES THE MANUAL CALCULATION OF THE TOTAL EFFECT
		// WHICH IS THE SAME AS THE BIVARIATE REGRESSION EFFECT DEMONSTRATED EARLIER
		// SO:  ALTERNATIVE ESTIMATE OF INDIRECT EFFECT = TOTAL BIVARIATE EFFECT - DIRECT EFFECT IN THE MODEL WHICH CONTROLS FOR THE MEDIATOR
		// HERE:  .069-.035=.034

*DIAGRAM MED-LAG 2 :  3 WAVE CROSS-LAGGED MEDIATION MODEL
**EFFECT OF KNOWLEDGE ON INTEREST VIA MEDIA USE
sem (know_w1 -> know_w2, ) (know_w1 -> interest_w3, ) (know_w1@a -> media_w2, ) (know_w2 -> know_w3, ) /// 
(know_w2@a -> media_w3, ) (interest_w1 -> interest_w2, ) (interest_w2 -> interest_w3, ) (media_w1@b -> interest_w2, ) /// 
 (media_w1 -> media_w2, ) (media_w2@b -> interest_w3, ) (media_w2 -> media_w3, ), difficult /// 
 cov( know_w1*interest_w1 know_w1*media_w1 e.know_w2*e.interest_w2 e.know_w2*e.media_w2 e.know_w3*e.interest_w3 e.know_w3*e.media_w3 /// 
 media_w1*interest_w1 e.media_w2*e.interest_w2 e.media_w3*e.interest_w3) nocapslatent

estat teffects // NOTE SIGNIFICANT INDIRECT EFFECT 


*DIAGRAM MED-LAG 3:  SATURATED CROSS-LAGGED EFFECTS
sem (know_w1 -> know_w2, ) (know_w1 -> interest_w2, ) (know_w1@a -> media_w2, ) (know_w2 -> know_w3, ) /// 
(know_w2@a -> media_w3, ) (interest_w1@d -> know_w2, ) (interest_w1 -> interest_w2, ) (interest_w1@e -> media_w2, ) /// 
(interest_w2@d -> know_w3, ) (interest_w2 -> interest_w3, ) (interest_w2@e -> media_w3, ) (media_w1@c -> know_w2, ) /// 
(media_w1@b -> interest_w2, ) (media_w1 -> media_w2, ) (media_w2@c -> know_w3, ) (media_w2@b -> interest_w3, ) ///  
(media_w2 -> media_w3, ), difficult cov( know_w1*interest_w1 know_w1*media_w1 e.know_w2*e.interest_w2 e.know_w2*e.media_w2 /// 
e.know_w3*e.interest_w3 e.know_w3*e.media_w3 media_w1*interest_w1 e.media_w2*e.interest_w2 e.media_w3*e.interest_w3) nocapslatent

estat teffects

II. MULTILEVEL MEDIATION:  FOLLOWING PREACHER-ZYPHUR-ZHANG 2010

**use Kenya civic education long data -- check that it has interest_w as one of the variables

egen medmean=mean(media_w), by(id)
egen intmean=mean(interest_w), by(id)
egen knowmean=mean(know_w), by (id)
gen medmndev=media_w-medmean
gen intmndev=interest_w-intmean
gen knowmndev=know_w-knowmean

tab wave, gen(yrr)

***MULTILEVEL MEDIATION MODELS 

***1.  NO SEPARATION OF BETWEEN AND WITHIN EFFECTS:  Leads to biases in indirect effects to extent that within/between effects differ
***DIAGRAM MED-ML-1
gsem (educ -> know_w, ) (educ -> interest_w, ) (know_w -> interest_w, ) (yrr3 -> know_w, ) /// 
(yrr3 -> interest_w, ) (yrr2 -> know_w, ) (yrr2 -> interest_w, ), nocapslatent

 **indirect effect of education on interest is .2*.098
 
 **to calculate significance of the indirect effect, use nlcom (teffects not yet available in GSEM)
 
gsem, coeflegend // THIS TELLS YOU WHAT THE COEFFICIENTS ARE CALLED IN STATA INTERNAL NOTATION
nlcom _b[interest_w:know_w]*_b[know_w:educ]

 **to calculate total effect -- the direct plus indirect effect = .016+(.2*.098)
 
nlcom _b[interest_w:know_w]*_b[know_w:educ] + _b[interest_w:educ]


***2. BETWEEN AND WITHIN EFFECTS USING OBSERVED GROUP MEANS ON LEVEL 1 VARIABLES
***DIAGRAM MED-ML-2

gsem (educ -> knowmean, ) (educ -> intmean, ) (knowmndev -> intmndev, ) (knowmean -> intmean, ) /// 
(yrr3 -> knowmndev, ) (yrr3 -> intmndev, ) (yrr2 -> knowmndev, ) (yrr2 -> intmndev, ), nocapslatent

***DIAGRAM MED-ML-2A  -- USE A LEVEL 2 RANDOM EFFECT FOR INTEREST
gsem (educ -> knowmean, ) (educ -> M1[id], ) (knowmndev -> interest_w, ) (knowmean -> M1[id], ) /// 
(M1[id] -> interest_w, ) (yrr3 -> knowmndev, ) (yrr3 -> interest_w, ) (yrr2 -> knowmndev, ) (yrr2 -> interest_w, ), latent(M1 ) nocapslatent

 **indirect effect of education on interest is .2*.156

gsem, coeflegend
nlcom  _b[M1[id]:knowmean]*_b[knowmean:educ]

  **total effect is .005+ (.2*.156)

nlcom  _b[M1[id]:knowmean]*_b[knowmean:educ] + _b[M1[id]:educ]

***3.  BETWEEN AND WITHIN EFFECTS USING MSEM WITH RANDOM LEVEL 2 VARIABLES FOR KNOWLEDGE AND INTEREST
***DIAGRAM MED-ML-3
gsem (educ -> M2[id], ) (educ -> M1[id], ) (know_w -> interest_w, ) (M2[id]@1 -> interest_w,)  /// 
(M1[id]@1 -> know_w, ) (M1[id] -> M2[id], ) (yrr3 -> know_w, ) (yrr3 -> interest_w, ) (yrr2 -> know_w, ) (yrr2 -> interest_w, ), latent(M2 M1 ) nocapslatent

 **indirect effect of education on interest:  calculate the true between effect and multiply by effect of education on knowledge
 
gsem, coeflegend
nlcom  _b[M2[id]:M1[id]]+ _b[interest_w:know_w] // gives true between effect (by adding the true "contextual" effect to the within effect)
nlcom (_b[M2[id]:M1[id]]+ _b[interest_w:know_w])* _b[M1[id]:educ] // gives indirect effect

 **total effect :  add the direct effect of education  (smaller here because the direct effect is negative)
nlcom (_b[M2[id]:M1[id]]+ _b[interest_w:know_w])* _b[M1[id]:educ] + _b[M2[id]:educ]

 
 ***LAST POINTS:  ASSUMPTIONS OF ALL MEDIATION MODELS
 1)  NO HIDDEN CONFOUNDERS -- UNOBSERVABLES INFLUENCING X AND M, M AND Y.  SENSITIVITY ANALYSIS.  CAN FIX COVARIANCES OF DISTURBANCES IN SEM TO VARIOUS LEVELS AND TEST
 2)  NO INTERACTION BETWEEN X AND M -- X-MEDIATOR INTERACTION.  MODERN APPROACH LINKS INTERACTION EFFECTS TO POTENTIAL OUTCOMES RUBIN-HOLLAND CAUSAL MODEL.  NO TIME TO DISCUSS BUT
 MUTHEN ASPAROUHOV ARTICLE DISCUSSES THIS WELL, AND 'MEDEFF' ROUTINE IN STATA, 'MEDSENS' FOR SENSITIVITY ANALYSIS CAN IMPLEMENT IT WITH DICHOTOMOUS TREATMENT VARIABLE
 3)  CAN HAVE RANDOM EFFECTS ASSOCIATED WITH LEVEL 1 PARAMETERS, IN WHICH CASE INDIRECT EFFECTS ARE CALCULATED USING THE MEAN OF THE ESTIMATED RANDOM EFFECT
