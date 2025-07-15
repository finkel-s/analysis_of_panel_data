
PS2701
Longitudinal Analyis

Week 11: Multilevel Analysis of Repeated Cross-Sectional Data


***World Values Surveys, 97 countries, 6 waves from 1981-1984 to 2010-2014; 247 country-years 
***Download data here: https://www.dropbox.com/s/dwqtzl7xxiwavqz/WVS_Longitudinal_1981_2016_stata_v20180912.dta?dl=0

**Data prep:  Year and Country Dummies
tab S002, gen(wvv)
clonevar wave=S002
tab S003, gen(count)

**institutional distrust
recode E069_11 -5/-1=., gen(lowtrust)

egen ltrustcymn=mean(lowtrust), by(S025) // country-year average
egen ltrustcmn=mean(lowtrust), by(S003)  // country average
gen ltrustcymndv=ltrustcymn-ltrustcmn    // country-year deviation from country average
gen ltrustimndv=lowtrust-ltrustcymn      // individual deviation from country-year average
gen ltrusticmndv=lowtrust-ltrustcmn      // individual deviation from country average

**Data Prep:  Control Variables
recode X001 -5/-1=. 2=0, gen(male)
recode X003 -5/15=., gen(age)
recode X025 -5/-1=., gen(educ)
recode A170 -5/-1=., gen(lifesat)

egen educcymn=mean(educ), by(S025)     // country-year average
egen educcmn=mean(educ), by(S003)      // country average
gen educcymndv=educcymn-educcmn        //  country-year deviation from country average
gen educimndv=educ-educcymn            //  individual deviation from country-year average
gen educicmndv=educ-educcmn           // individual deviation from country average

**social distrust
recode A165 -5/-1=. 1=0 2=1, gen(lowsoctrst)




*****Social Trust as DV

**********Two level analysis -- individuals nested in countries

mixed lowsoctrst lowtrust ltrustcmn male age educ educcmn wvv* ||S003: , vce(robust)

*in mean deviated form at Level 1 to separate within and between effects

mixed lowsoctrst ltrusticmndv ltrustcmn male age educicmndv educcmn wvv* ||S003: , vce(robust)

**********Three level analysis -- individuals nested in country-years nested in country 

**Raw level 1 and level 2 country-year means with random effect at level 3 for country:  Equation 5 from Class PPT
mixed lowsoctrst lowtrust ltrustcymn male age educ educcymn wvv* ||S003: ||S025:, vce(robust)

***Raw level 1, Level 2 country-year means, and Level 3 country means: Equation 6d or 7d from Class PPT
mixed lowsoctrst lowtrust ltrustcymn ltrustcmn male age educ educcymn educcmn wvv* ||S003: ||S025:, vce(robust)
	
***Raw level 1, Level 3 country means, and Level 2 country-year mean deviations from country means: Equation 6e or 7e from Class PPT
mixed lowsoctrst lowtrust ltrustcymndv ltrustcmn male age educ educcymndv educcmn wvv* ||S003: ||S025:, vce(robust)

***Mean-deviated level 1, Level 3 country means, and Level 2 country-year mean deviations from country means: Equation 7f from Class PPT
mixed lowsoctrst ltrustimndv ltrustcymndv ltrustcmn male age educimndv educcymndv educcmn wvv* ||S003: ||S025:, vce(robust)

