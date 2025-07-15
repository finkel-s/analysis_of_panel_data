PS2701 LONGITUDINAL ANALYSIS
WEEK 2:  FIXED EFFECTS AND FIRST DIFFERENCE MODELS FOR MULTIWAVE DATA

//START WITH KENYA 3 WAVE WIDE DATA


browse  //NOTE 401 PERSONS, THREE INDICATORS OF 'TIME-VARYING' VARIABLES (ONE FOR EACH WAVE), AND SEVERAL 'TIME-INVARIANT' VARIABLES

egen knowmean=rmean(know_w1 know_w2 know_w3)
tab knowmean  // GIVES THE AVERAGE KNOWLEDGE SCORE ACROSS THE THREE WAVES FOR ALL 401 INDIVIDUALS 
summarize knowmean


**MOST NON-STRUCTURAL EQUATION PANEL MODELS USE DATA IN 'LONG' FORM
keep newtreat_ww1 newtreat_ww2 newtreat_ww3 know_w1 know_w2 know_w3 knowmean sex id
reshape long newtreat_ww know_w , i(id) j(wave)
browse  //NOTE 1203 ROWS OF DATA: 401 CASES, THREE YEARS STACKED ON TOP OF ONE ANOTHER
        //NOTE KNOW_W NEWTREAT_WW AND WAVE CHANGE WITHIN CASES, SEX AND KNOWMEAN DO NOT

egen knowmean2=mean(know_w), by(id)  //NOTE DIFFERENCES BETWEEN 'RMEAN' AND 'MEAN' IN EGEN COMMAND
summarize knowmean2
corr knowmean2 knowmean


***LET'S GET THE FULL 'LONG DATA' AND USE THAT INSTEAD
//USE KENYA 3 WAVE LONG

***NOW WE WILL TELL STATA THAT THE DATA IS IN PANEL FORMAT AND THAT "ID" IS THE SUBJECT IDENTIFIER AND "WAVE" IS THE TIME IDENTIFIER

xtset id wave // NOTE IF NOT 1,2,3 FOR THE TIME VARIABLE, YOU CAN SPECIFY THE GAP BETWEEN WAVES IN YEARS/MONTHS OR WHATEVER METRIC

**ALSO CREATE A TIME COUNTER SO THAT WAVE1=0, WAVE2=1, WAVE3=2 -- USEFUL FOR TREATING FIRST WAVE AS A "BASELINE" OR FOR INCLUDING A TIME-TREND VARIABLE 
gen time=wave-1
tab time

***SOME SUMMARY STATISTICS ABOUT THE DATA
xtdes
xtsum  //NOTE DIFFERENCES BETWEEN 'OVERALL,' 'BETWEEN,' AND 'WITHIN' CONCEPTS


**FIXED EFFECTS MODEL
xtreg know_w totalce_w sex educ age, fe
estimates store fixed  //STORES THE ESTIMATES FOR LATER COMPARISON WITH OTHER MODELS
predict fixedu, u      //THE FIXED EFFECT ESTIMATE OF U, THE UNOBSERVED TIME-INVARIANT COMPONENT OF THE ERROR TERM
                       //NOTE THAT THIS (UNFORTUNATELY) ALSO CONTAINS ALL TIME-INVARIANT FACTORS INCLUDING SEX EDUC AND AGE
					   
egen knowmean2=mean(know_w), by(id)          //CREATES THE MEAN KNOWLEDGE SCORE FOR EACH PERSON
*egen totalce_mn=mean(totalce_w), by(id)      //CREATES THE MEAN CIVIC ED EXPOSURE SCORE FOR EACH PERSON (ALREADY IN DATA SET)

predict fixedpred, xb  //THE PREDICTED KNOWLEDGE SCORE IN THE FIXED EFFECTS MODEL AS A FUNCTION OF ALL X IN THE MODEL -- IN THIS CASE TOTALCE_W

//MANUAL CALCULATIONS OF THE UNIT EFFECT
gen manualunit=knowmean2-(2.572018+.1297814*totalce_mn)  // AVERAGE Y - MEAN PREDICTED Y
egen fixedpredmn=mean(fixedpred), by (id)                // MEAN PREDICTED Y
gen fixedmanual=knowmean2-fixedpredmn                 // AVERAGE Y - MEAN PREDICTED Y
list fixedu manualunit fixedmanual in 1/30
tab fixedu
corr fixedu fixedpred  //UNOBSERVED TIME-INVARIANT FACTORS ARE CORRELATED WITH ALL OF THE X VARIABLES AT .0726

**NOTE COMPOSITE ERROR TERM MADE UP OF U AND E
display .724^2/(.724^2+.822^2)  // = .437.  THIS IS THE PROPORTION OF THE ERROR VARIANCE THAT VARIANCE IN "U" MAKES UP:  HOW MUCH TOTAL
//VARIATION IN ERROR IS UNIT(GROUP)-LEVEL VARIATION, DESIGNATED AS "RHO" IN OUTPUT.  REMEMBER IT HAS *ALL* TIME-INVARIANT FACTORS IN U

******CALCULATE R-SQUARED VALUES MANUALLY

***OVERALL:  SQUARED CORRELATION BETWEEN XB (PREDICTED Y) AND ACTUAL Y
corr fixedpred know_w
display .1950^2   // EQUALS APPROXIMATELY .038 -- THE 'OVERALL' R-SQUARED REPORTED BY STATA

***BETWEEN:  SQUARED CORRELATION BETWEEN AVERAGE OF XB (PREDICTED Y) FOR EACH CASE OVER TIME AND AVERAGE OF Y FOR EACH CASE OVER TIME
corr fixedpredmn knowmean2
display .2353^2  //EQUALS APPROXIMATELY .055

***WITHIN:  SQUARED CORRELATION BETWEEN "DEMEANED PREDICTED Y" AND "DEMEANED ACTUAL Y" FOR EACH CASE
gen fprddemean=fixedpred-fixedpredmn
gen knowdemean=know_w-knowmean2
corr fprddemean knowdemean
display .1716^2  //EQUALS .029

****AND (AS YOU KNOW BY NOW), THE FIXED EFFECT MODEL IS A REGRESSION OF DEMEANED Y ON DEMEANED X
gen totalcedemean=totalce_w-totalce_mn
regress knowdemean totalcedemean

****GET THE TRUE CONSTANT BACK BY ADDING THE GRAND MEAN ON EACH SIDE
egen totalcemng=mean(totalce_w)
egen knowmng=mean(know_w)
gen totcedemeang=totalcedemean+totalcemng
gen knowdemeang=knowdemean+knowmng
regress knowdemeang totcedemeang

***IT IS ALSO THE SAME AS LEAST SQUARES WITH DUMMY VARIABLES
tab id, gen(iddum)

*MATSIZE IN STATA SOMETIMES TOO SMALL TO DO THIS, SO NEED TO EXPAND IF NECESSARY
set matsize 500
regress know_w totalce_w sex educ age iddum* //NOTE THAT IT DROPPED 4 OF THE DUMMIES FOR ID INSTEAD OF SEX EDUC AGE AND THE GRAND MEAN, BUT THIS IS ARBITRARY
estimates store lsdv
estimates table fixed lsdv                        //COMPARES THE ESTIMATES -- NOTE THE EXACT SAME VALUE FOR TOTALCE_W

**NOTE THAT THE EFFECTS LISTED FOR SEX EDUC AGE ARE NOT "REAL"!!!! 
**THEY ARE JUST STAND-INS FOR 3 UNIQUE IDS (347, 385, 401, ACTUALLY, WHOSE DUMMIES STATA RANDOMLY DROPPED)!!!!

***CAN ALSO USE THE 'AREG' PROCEDURES IN STATA FOR LSDV APPROACH 
areg know_w totalce_w sex educ age, absorb (id)  //"ABSORB" SIGNIFIES WHAT VARIABLE YOU ARE GOING TO CREATE N-1 DUMMY VARIABLES OUT OF

***NOTE:  WHY IS R-SQUARED .55 IN THIS MODEL?  IT INCLUDES THE UNIT EFFECT IN THE PREDICTION!!!
xtreg know_w totalce_w,fe
predict fixedxbu, xbu
corr fixedxbu know_w
display (.7441)^2  // EQUALS THE 'AREG' R-SQUARED OF .554, OR THE LSDV R-SQUARED

//MORE CONSERVATIVE ESTIMATION:  INCLUDE THE PANEL (CLUSTER) VERSION OF WHITE'S HETEROSKEDASTICITY "SANDWICH" CORRECTION

xtreg know_w totalce_w, fe vce (cluster id)

**AND JUST FOR THE RECORD: THE "BETWEEN" ESTIMATE THAT IGNORES WITHIN GROUP VARIATION ALTOGETHER

xtreg know_w totalce_w sex educ age, be 

//OR MANUALLY:
regress knowmean2 totalce_mn sex educ age


**TWO-WAY FIXED EFFECTS INCLUDES TIME DUMMY VARIABLES
tab wave, gen(wavv)
xtreg know_w totalce_w wavv2 wavv3, fe
estimates store fixed2way
estimates table fixed fixed2way  //WHY DO THEY DIFFER?

***LET'S TRY ANOTHER DEPENDENT VARIABLE -- POLITICAL PARTICIPATION
xtreg polpart_w totalce_w, fe               // HERE THERE IS NO EFFECT *WITHOUT* THE TIME EFFECT INCLUDED
xtreg polpart_w totalce_w wavv2 wavv3, fe  // BUT INCLUDING THE TIME EFFECTS SHOWS THAT EXPOSURE *DOES* LEAD TO GREATER PARTICIPATION 
                                           // (OR LESS OF A DECLINE OVER TIME) FOR INDIVIDUALS EXPOSED THAN NOT-EXPOSED 

***FIRST DIFFERENCE MODELS
xtset id wave
reg d.know_w d.totalce_w       // no standard error correction or wave dummies
reg d.know_w d.totalce_w wavv2 wavv3  // includes wave dummies , no standard error correction

***TO DO CORRECTIONS AND MORE ADVANCED FD WORK, DOWNLOAD AND INSTALL "IVREG2, XTIVREG2, AND RANKTEST" AFTER "NET SEARCH" FOR EACH ONE
xtivreg2 know_w totalce_w  wavv2 wavv3, fd cluster(id)

xtreg know_w totalce_w wavv2 wavv3, vce(cluster id) fe  // shows differences between FE and FD in multiwave data

****same for participation as the DV
xtivreg2 polpart_w totalce_w  wavv2 wavv3, fd cluster(id)

xtreg polpart_w totalce_w wavv2 wavv3, vce(cluster id) fe  // shows differences between FE and FD in multiwave data


*****Allison (2019) Asymmetric FE (FD), 2 wave analysis:  Does going to new workshops lead to *greater* positive change 
*****in PARTICIPATION and KNOWLEDGE than going to fewer workships leads to negative change?

gen partdif=d.polpart_w
gen knowdif=d.know_w
gen totrtdif=d.totalce_w
gen totdfpos=totrtdif*(totrtdif>0) //  This creates a variable with the amount of positive change if change>0, 0 otherwise
gen totdfneg=-totrtdif*(totrtdif<0) // This creates a variable with the (positive) amount of negative change if change>0, 0 otherwise 
tab totrtdif wave
tab totdfpos wave
tab totdfneg wave
gen intdif=d.interest_w
gen intdfpos=intdif*(intdif>0)  // The same for positive change in political interest
gen intdfneg=-intdif*(intdif<0) //.  The same for negative change in political interest


reg partdif totrtdif  if wave>2         // Standard difference regression, 2 wave
reg partdif totdfpos totdfneg if wave>2  // Asymmetric difference regression, 2 wave
reg partdif totdfpos totdfneg intdfpos intdfneg wavv3 if wave>2 // Asymmetric difference regression with asymmetric covariate effect 
                                                                // of political interest

test totdfpos = -totdfneg // Are the positive and negative effects of equal magnitude?  If so, symmetric effects.  If not, asymmetric effects.
test intdfpos =  -intdfneg 

***Same for Knowledge
reg knowdif totdfpos totdfneg if wave>2
reg knowdif totdfpos totdfneg intdfpos intdfneg wavv3 if wave>2

test totdfpos = -totdfneg // Are the positive and negative effects of equal magnitude?  If so, symmetric effects.  If not, asymmetric effects.
test intdfpos =  -intdfneg 




