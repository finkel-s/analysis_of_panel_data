PS2701-2015
LONGITUDINAL ANALYSIS

PANEL ATTRITION AND MISSING DATA

***USE CIVIC EDUCATION WIDE DATA


***  ATTRITION  -- first create some attrition in the Kenya data set at wave3

clonevar know3=know_w3
replace know3=. if know3==4&educ>4
gen w3miss=0
replace w3miss=1 if know3==.
corr educ w3miss
corr know3 w3miss
corr know_w3 w3miss


****SEM MODELS, MAR AND MNAR

***TWO WAVE MODELS

****LISTWISE DELETION
** DIAGRAM ATT-0 KNOWLEDGE, NO SELECTION MODEL

sem (know_w1 -> know3, ) (educ -> know3, ) (treat -> know3, ), nocapslatent

***MLMV ESTIMATION

sem (know_w1 -> know3, ) (educ -> know3, ) (treat -> know3, ), method(mlmv) nocapslatent

**FIGURE ATT-1 Heckman 2 Wave Selection Model
**use non-adaptive gauss-hermite integration for convergence

gsem (know_w1 -> know3, ) (educ -> know3, ) (educ -> w3miss, family(binomial) link(probit)) (U -> know3, ) /// 
(U@1 -> w3miss, family(binomial) link(probit)) (treat -> know3, ) (treat -> w3miss, family(binomial) link(probit)), /// 
covstruct(_lexogenous, diagonal) intmethod(ghermite) intpoints(10) difficult latent(U ) cov( U@1) nocapslatent


***EFFECT OF U ON OUTCOME MEANS:  UNOBSERVABLES THAT INFLUENCE MISSINGNESS ALSO INFLUENCE KNOWLEDGE POSITIVELY (I.E., MISSING INDIVIDUALS ARE MORE LIKELY TO BE KNOWLEDGEABLE
***CONTROLLING FOR THIS, WE SEE SLIGHTLY STRONGER EFFECTS OF CIVIC EDUCATION TREATMENT, EDUCATION AND PRIOR KNOWLEDGE ON KNOWLEDGE

**THREE WAVE ANALYSES, GROWTH CURVE MODELS WITH AND WITHOUT MNAR SELECTION

***LISTWISE DELETION LOSE 21 CASES 
sem (know_w1 <- _cons@0, ) (know_w2 <- _cons@0, ) (know3 <- _cons@0, ) (Intercept@1 -> know_w1, )  ///
(Intercept@1 -> know_w2, ) (Intercept@1 -> know3, ) (Slope@0 -> know_w1, ) (Slope@1 -> know_w2, ) /// 
(Slope@2 -> know3, ) (sex age  treat _cons -> Intercept, ) (sex age  treat _cons -> Slope, ),  difficult latent(Intercept Slope ) /// 
cov( e.know_w1@err e.know_w2@err e.know3@err e.Intercept*e.Slope) nocapslatent

***MLMV ESTIMATION: GROWTH CURVE MODEL, NO MNAR
**DIAGRAM ATT-3

sem (know_w1 <- _cons@0, ) (know_w2 <- _cons@0, ) (know3 <- _cons@0, ) (Intercept@1 -> know_w1, )  ///
(Intercept@1 -> know_w2, ) (Intercept@1 -> know3, ) (Slope@0 -> know_w1, ) (Slope@1 -> know_w2, ) /// 
(Slope@2 -> know3, ) (sex age  treat _cons -> Intercept, ) (sex age  treat _cons -> Slope, ),  method(mlmv) difficult latent(Intercept Slope ) /// 
cov( e.know_w1@err e.know_w2@err e.know3@err e.Intercept*e.Slope) nocapslatent

***DIGGLE-KENWARD PREDICTING WAVE 3 MISS WITH WAVE 2, KNOW2 AND OTHER IVS
**DIAGRAM ATT-4

sem (know_w1 <- _cons@0, ) (know_w2 <- _cons@0, ) (know3 <- _cons@0, ) (Intercept@1 -> know_w1, )  ///
(Intercept@1 -> know_w2, ) (Intercept@1 -> know3, ) (Slope@0 -> know_w1, ) (Slope@1 -> know_w2, ) /// 
(Slope@2 -> know3, ) (sex age  treat _cons -> Intercept, ) (sex age  treat _cons -> Slope, ) (w3miss=know_w2 treat age sex),  method(mlmv) difficult latent(Intercept Slope ) /// 
cov( e.know_w1@err e.know_w2@err e.know3@err e.Intercept*e.Slope sex*treat age*treat age*sex) nocapslatent

***SHARED PARAMETER MODEL
***DIAGRAM ATT-5

sem (know_w1 <- _cons@0, ) (know_w2 <- _cons@0, ) (know3 <- _cons@0, ) (Intercept@1 -> know_w1, ) /// 
 (Intercept@1 -> know_w2, ) (Intercept@1 -> know3, ) (Intercept-> w3miss, ) (Slope@0 -> know_w1, ) (Slope@1 -> know_w2, ) (Slope@2 -> know3, ) ///
 (Slope -> w3miss, ) (treat -> Intercept, ) (treat -> Slope, ) (sex -> Intercept, ) (sex -> Slope, ) (age -> Intercept, ) (age -> Slope, )  /// 
 (_cons -> Intercept, ) (_cons -> Slope, ) (_cons -> w3miss, ), method(mlmv) difficult latent(Intercept Slope ) /// 
 cov( e.know_w1@err e.know_w2@err e.know3@err e.Intercept*e.Slope sex*treat age*treat age*sex) nocapslatent



\
