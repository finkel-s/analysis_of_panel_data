**PS2701 
**LONGITUDINAL ANALYSIS

*****FIXED EFFECTS MODELS*****

*EXAMPLE:  HYPOTHETICAL DATA ON REPRESSION AND DEMOCRACY, 200 COUNTRIES, 6 YEARS 1980-2005


**SHOW DATA IN 'WIDE' FORM
**use "repression.wide.dta", clear // 

browse  //NOTE 200 COUNTRIES, SIX YEARS OF INDICES ON REPRESSION AND DEMOCRACY, TWO 'TIME-INVARIANT' VARIABLES
egen repressmean=rmean(repress1980 repress1985 repress1990 repress1995 repress2000 repress2005)
tab repressmean  // GIVES THE AVERAGE REPRESSION SCORE FOR ALL 200 COUNTRIES
summarize repressmean


**MOST NON-SEM PANEL MODELS USE DATA IN 'LONG' FORM
reshape long repress democ, i(country) j(year)
browse  //NOTE 1200 ROWS OF DATA:  200 CASES, SIX YEARS STACKED ON TOP OF ONE ANOTHER
        //NOTE REPRESS,DEMOC AND YEAR CHANGE WITHIN CASES, COUNTRY, HOMOG, ECON AND REPRESSMEAN DO NOT

egen repressmean2=mean(repress), by(country)  //NOTE DIFFERENCES BETWEEN 'RMEAN' AND 'MEAN' IN EGEN COMMAND
summarize repressmean2

***NOW WE WILL TELL STATA THAT THE DATA IS IN PANEL FORMAT AND THAT "COUNTRY" IS THE SUBJECT IDENTIFIER AND "YEAR" IS THE TIME IDENTIFIER
***AND THAT THERE IS A FIVE YEAR GAP BETWEEN OBSERVATIONS

xtset country year, delta(5)

**ALSO CREATE A TIME COUNTER SO THAT 1980=1, 1985=2, 1990=3, AND SO ON 
gen yearnum=0
replace yearnum=1 if year==1980
replace yearnum=2 if year==1985
replace yearnum=3 if year==1990
replace yearnum=4 if year==1995
replace yearnum=5 if year==2000
replace yearnum=6 if year==2005
tab yearnum

***SOME SUMMARY STATISTICS ABOUT THE DATA
xtdes
xtsum  //NOTE DIFFERENCES BETWEEN 'OVERALL,' 'BETWEEN,' AND 'WITHIN' CONCEPTS


**FIXED EFFECTS MODEL
xtreg repress democ homog econ, fe
estimates store fixed  //STORES THE ESTIMATES FOR LATER COMPARISON WITH OTHER MODELS
predict fixedu, u      //THE FIXED EFFECT ESTIMATE OF U, THE UNOBSERVED TIME-INVARIANT COMPONENT OF THE ERROR TERM
                       //NOTE THAT THIS (UNFORTUNATELY) ALSO CONTAINS ALL TIME-INVARIANT FACTORS INCLUDING HOMOG AND ECON
					   
egen democmean2=mean(democ), by (country)         //CREATES THE MEAN DEMOCRACY SCORE FOR EACH COUNTRY
predict fixedpred, xb  //THE PREDICTED REPRESSION SCORE IN THE FIXED EFFECTS MODEL AS A FUNCTION OF ALL X IN THE MODEL -- IN THIS CASE DEMOC

//MANUAL CALCULATIONS OF THE UNIT EFFECT
gen manualunit=repressmean2-(3.230574-.1736*democmean2)  // AVERAGE Y - MEAN PREDICTED Y
egen fixedpredmn=mean(fixedpred), by (country)           // MEAN PREDICTED Y
gen fixedmanual=repressmean2-fixedpredmn                 // AVERAGE Y - MEAN PREDICTED Y
list fixedu manualunit fixedmanual in 1/30
tab fixedu
corr fixedu fixedpred  //UNOBSERVED TIME-INVARIANT FACTORS ARE CORRELATED WITH ALL OF THE X VARIABLES AT .26

**NOTE COMPOSITE ERROR TERM MADE UP OF U AND E
display .249^2/(.249^2+.305^2)  // = .40.  THIS IS THE PROPORTION OF THE ERROR VARIANCE THAT VARIANCE IN "U" MAKES UP:  HOW MUCH TOTAL
//VARIATION IN ERROR IS UNIT(GROUP)-LEVEL VARIATION, DESIGNATED AS "RHO" IN OUTPUT.  REMEMBER IT HAS *ALL* TIME-INVARIANT FACTORS IN U

******CALCULATE R-SQUARED VALUES MANUALLY

***OVERALL:  SQUARED CORRELATION BETWEEN XB (PREDICTED Y) AND ACTUAL Y
corr fixedpred repress
display .3546^2   // EQUALS APPROXIMATELY .126
***BETWEEN:  SQUARED CORRELATION BETWEEN AVERAGE OF XB (PREDICTED Y) FOR EACH CASE OVER TIME AND AVERAGE OF Y FOR EACH CASE OVER TIME
corr fixedpredmn repressmean
display .6109^2  //EQUALS APPROXIMATELY .37
***WITHIN:  SQUARED CORRELATION BETWEEN "DEMEANED PREDICTED Y" FROM "DEMEANED ACTUAL Y" FOR EACH CASE
gen fprddemean=fixedpred-fixedpredmn
gen represdemean=repress-repressmean2
corr fprddemean represdemean
display .2208^2  //EQUALS APPROXIMATELY .048

****AND (AS YOU KNOW BY NOW), THE FIXED EFFECT MODEL IS A REGRESSION OF DEMEANED Y ON DEMEANED X
gen democdemean=democ-democmean2
regress represdemean democdemean

****GET THE TRUE CONSTANT BACK BY ADDING THE GRAND MEAN ON EACH SIDE
egen democmng=mean(democ)
egen repmng=mean(repress)
gen demdemeang=democdemean+democmng
gen repdemeang=represdemean+repmng
regress repdemeang demdemeang 

***IT IS ALSO THE SAME AS LEAST SQUARES WITH DUMMY VARIABLES
tab country, gen(countdum)
regress repress democ homog econ countdum*

*MATSIXE IN STATA SOMETIMES TOO SMALL TO DO THIS, SO NEED TO EXPAND IF NECESSARY
*set matsize 500
*regress repress democ homog econ countdum*  //NOTE THAT IT DROPPED 3 OF THE DUMMIES FOR COUNTRY INSTEAD OF HOMOG AND ECON AND GRAND MEAN, BUT THIS IS ARBITRARY
estimates store lsdv
estimates table fixed lsdv                        //COMPARES THE ESTIMATES -- NOTE THE EXACT SAME VALUE FOR DEMOC

***CAN ALSO USE THE 'AREG' PROCEDURES IN STATA FOR LSDV APPROACH 
areg repress democ homog econ, absorb (country)  //"ABSORB" SIGNIFIES WHAT VARIABLE YOU ARE GOING TO CREATE N-1 DUMMY VARIABLES OUT OF

***NOTE:  WHY IS R-SQUARED .49 IN THIS MODEL?  IT INCLUDES THE UNIT EFFECT IN THE PREDICTION!!!
xtreg repress democ,fe
predict fixedxbu, xbu
corr fixedxbu repress
display (.7063)^2  // EQUALS THE 'AREG' R-SQUARED, OR THE LSDV R-SQUARED

//MORE CONSERVATIVE ESTIMATION:  INCLUDE THE PANEL (CLUSTER) VERSION OF WHITE'S HETEROSKEDASTICITY "SANDWICH" CORRECTION

xtreg repress democ homog econ, fe vce (cluster country)

**AND JUST FOR THE RECORD: THE "BETWEEN" ESTIMATE THAT IGNORES WITHIN GROUP VARIATION ALTOGETHER

xtreg repress democ homog econ, be 

//OR MANUALLY:
regress repressmean2 democmean2 homog econ


**TWO-WAY FIXED EFFECTS INCLUDES TIME DUMMY VARIABLES
tab year, gen(year)
xtreg repress democ homog econ year1-year6, fe
estimates store fixed2way
estimates table fixed fixed2way  //WHY DO THEY DIFFER?



***FIRST DIFFERENCE MODELS
xtset country year, delta(5)
reg d.repress d.democ       // no standard error correction or year dummies
tab year, gen(yeardum)      // generates yeardum1, yeardum2, yeardum3, etc. for 1980, 1985....
reg d.repress d.democ yeardum2-yeardum6  // includes time dummies , no standard error correction

***TO DO CORRECTIONS AND MORE ADVANCED FD WORK, DOWNLOAD AND INSTALL "IVREG2, IVREG28, XTIVREG2, XTIVREG28, XTIVREG29" AFTER "NET SEARCH" FOR EACH ONE
xtivreg2 repress democ yeardum2-yeardum6, fd cluster(country)

xtreg repress democ yeardum2-yeardum6, vce(cluster country) fe  // shows differences between FE and FD in multiwave data


xtivreg2 repress democ if year<1990, fd cluster (country)  // two wave fd model for 1980-1985
xtreg repress democ year2 if year<1990, fe  vce(cluster country)  // two wave fe model for 1980-1985

*Allison Asymmetric Effects

gen repressdif=d.repress
gen democdif=d.democ
gen demdifpos=democdif*(democdif>0) //  This creates a variable with the amount of positive change if change>0, 0 otherwise
gen demdifneg=-democdif*(democdif<0) // This creates a variable with the (positive) amount of negative change if change>0, 0 otherwise 


reg d.repress d.democ yeardum2-yeardum6 
reg repressdif democdif yeardum2-yeardum6
reg repressdif demdifpos demdifneg yeardum2-yeardum6
test demdifpos = -demdifneg

keep if year<1990
