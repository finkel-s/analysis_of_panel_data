PS2701-2019
LONGITUDINAL ANALYSIS

SESSION 1-1:  TWO WAVE FIRST DIFFERENCE MODELS

EXAMPLE:  KENYA CIVIC EDUCATION DATA (FOLLOWING FINKEL&SMITH 2011, AJPS)

//USE KENYA 3 WAVE "WIDE" DATA

*tabulations of treatment variables
tab1 newtreat_ww1 newtreat_ww2
sum newtreat_ww1 newtreat_ww2
**tabulations of knowlege variables
tab1 know_w1 know_w2
sum know_w1 know_w2
*generate difference scores
gen knowdif=know_w2-know_w1
gen treatdif=newtreat_ww2-newtreat_ww1
tab1 treatdif knowdif

**THE BASIC FD MODEL
regress knowdif treatdif
regress knowdif newtreat_ww2   // SAME THING


**WITH CONTROLS FOR TIME-VARYING AND TIME-INVARIANT VARIABLES, STABLE EFFECTS
gen intdif=interest_w2-interest_w1
gen sexdif=sex-sex
gen educdif=educ-educ

regress knowdif treatdif intdif sexdif educdif

***WITH CHANGING EFFECTS OF TIME-INVARIANT VARIABLES
regress knowdif treatdif intdif sex educ

// RESULTS:  SEX AND EDUCATION HAVE NEGATIVE EFFECTS ON CHANGE IN KNOWLEDGE, MEANING 
// WOMEN INCREASED MORE ON KNOWLEDGE THAN MEN, AND LESS EDUCATED INCREASED MORE THAN HIGHLY EDUCATED
tabstat knowdif, by(sex)
// OR:  SEX AND EDUCATION HAD GREATER EFFECTS ON *LEVELS* OF KNOWLEDGE AT TIME 1 THAN TIME 2
corr know_w1 sex
corr know_w2 sex
// OR:  SEX DIFFERENCES AND EDUCATION DIFFERENCES WERE STRONGER AT TIME 1 THAN TIME 2
tabstat know_w1 know_w2, by(sex)
***WITH CHANGING EFFECTS OF TIME-VARIANT VARIABLES
regress knowdif treatdif sex educ intdif  interest_w1

// NO DIFFERENCE IN THE INTEREST EFFECT OVER TIME

