LONGITUDINAL ANALYSIS
FALL 2019

WEEKs 12-13: LONGITUDINAL MODELS FOR DICHOTOMOUS OUTCOMES

**use "PS2701.logit data.dta"

xtset subject year
gen civtreat=civiced*year

***POOLED LOGIT
logit voted contact civiced thermdif media year civtreat

**RANDOM EFFECTS LOGIT
xtlogit voted contact civiced thermdif media year civtreat

**RANDOM EFFECTS LOGIT WITH MELOGIT COMMAND
melogit voted contact civiced thermdif media year civtreat|| subject:  // RESULTS DIFFER SLIGHTLY BECAUSE OF NUMBER OF 'INTPOINTS' IN THE TWO METHODS 
 
 // -- CAN TRY DIFFERENT INTPOINTS WITH , intpoint (X) option

***TWO WAVE FE LOGIT 
 
tab year
keep if (year==1|year==5)              // SELECTS ONLY CASES IN YEARS 1 AND 5 FOR ILLUSTRATION PURPOSES
xtset subject year, delta(4)
egen votesum=sum(voted), by (subject)
tab votesum

***LOGIT WITH DIFFERENCE SCORES (LIKE FE LINEAR REGRESSION)

gen condif=contact-l.contact
gen thermdifdif=thermdif-l.thermdif
logit voted condif thermdifdif  if votesum==1   // predicts vote in year 5 only with difference scores from year 5-year 1
predict diffprob if e(sample)                   // generates predicted probability of Y=1 for the 48 cases
gen votedif=voted-l.voted                       // this is the "differenced" vote, which could theoretically have been used as the DV, as in linear FE
tab votedif if votesum==1                       // but you can see that the distribution of votedif is -1 and 1, which could just as easily be recoded to 0
												//	and 1
recode votedif (-1=0), gen (votedif2)
tab voted votedif2 if votesum==1                // and can see that there is a perfect correlation between "VOTED" and "VOTEDIF" among those who changed on
												// vote between years 1 and 5
logit votedif2 condif thermdifdif if votesum==1  // same results if you run logit on vote diff among those who changed

***FE LOGIT
xtlogit voted contact thermdif year, fe         // predicts vote in year 1 and in year 5 among same group, those who changed on vote from year 1-year 5
                                                // note exact same coefficients aside from the constant.  
												//The constant is different because it needs to take into account the "average" logit in year1 and then have
												//"year" add to that for all Xs=0 
predict feprob if e(sample)                     // generates predicted probably of Y=1 for the 96 cases
list diffprob feprob if year==5&e(sample)       // shows the exact same predicted probabilities for the year==5 individuals in the estimated sample, as it
												// should be since the models are exactly the same

xtlogit voted contact thermdif year civiced, fe // time-invariant variable drops out

xtlogit voted contact thermdif year c.year#i.civiced, fe  // time-invariant variable interacts with year to give the effect of the TIV on the difference in 
															// the DV over time

														  												  		  
																  
**FIXED EFFECTS LOGIT:  FULL SAMPLE, 5 TIME POINTS
***GET BACK 5 WAVE LOGIT DATA

xtset subject year
gen civtreat=civiced*year
egen votesum=sum(voted), by (subject)
tab votesum
xtlogit voted contact civiced thermdif year c.year#i.civiced, fe  // SEE HOW MANY CASES WE HAVE LOST??  ALL 600 OR SO OF THE NON-CHANGERS ON Y!
xtlogit voted contact civiced thermdif year c.year#i.civiced if votesum~=0&votesum~=5, fe 

**HYBRID MODEL WITH MEANS OF TIME-VARYING VARIABLES INCLUDED 

egen thermdifmn=mean(thermdif), by (subject)
gen thermmndev=thermdif-thermdifmn
egen contactmn=mean(contact), by (subject)
gen contactmndev=contact-contactmn

xtlogit voted contact thermdif civiced year // "NORMAL" RE
xtlogit voted contactmndev contactmn thermmndev thermdifmn civiced year // "HYBRID" RE

test thermmndev=thermdifmn  //SHOWS DIFFERENCE FROM WITHIN AND BETWEEN FOR THERMDIF
test contactmndev=contactmn  // SHOWS EQUIVALENCE OF WITHIN AND BETWEEN FOR CONTACT

***MELOGIT WITH RANDOM COEFFICIENT *AND* RANDOM INTERCEPT
melogit voted contact thermdif civiced year || subject: contact  


****GSEM VERSIONS
melogit voted contact thermdif civiced year ||subject:

gsem (contact year -> voted, family(binomial) link(logit)) (thermdif -> voted, family(binomial) link(logit)) (civiced -> voted, family(binomial) link(logit)) /// 
(M1[subject] -> voted, family(binomial) link(logit)), covstruct(_lexogenous, diagonal) latent(M1 ) nocapslatent

***OR MULTILEVEL VERSION -- SEE DIAGRAM 1 RELOGIT.STEM
gsem (M1[subject] -> voted, family(binomial) link(logit)) (contact -> voted, family(binomial) link(logit)) /// 
 (thermdif-> voted, family(binomial) link(logit)) (civiced -> M1[subject], ) (year -> voted, family(binomial) link(logit)), latent(M1 ) nocapslatent

***HYBRID VERSION -- SEE DIAGRAM 2 RE-HYBRID LOGIT
melogit voted contactmndev contactmn thermmndev thermdifmn civiced year || subject: // "HYBRID" RE

gsem (M1[subject] -> voted, family(binomial) link(logit)) (contactmndev -> voted, family(binomial) link(logit)) ///
(thermmndev -> voted, family(binomial) link(logit)) (civiced -> M1[subject], ) (year -> voted, family(binomial) /// 
link(logit)) (contactmn -> M1[subject], ) (thermdifmn -> M1[subject], ), latent(M1 ) nocapslatent

***ML-SEM VERSION WITH LATENT MEAN FOR CONTACT -- SEE DIAGRAM 3 ML-SEM VERSION OF HYBRID

gsem (M1[subject] -> voted, family(binomial) link(logit)) (contact -> voted, family(binomial) link(logit)) ///
(M2[subject] -> M1[subject], ) (M2[subject] -> contact, ) (civiced -> M1[subject], ) (year -> voted, family(binomial) /// 
link(logit)), covstruct(_lexogenous, diagonal) latent(M1 M2 ) nocapslatent

**NOTE TRUE BETWEEN EFFECT IS:
nlcom _b[voted:contact]+ _b[M1[subject]:M2[subject]]  // = 2.84 attenuated from the cluster-mean version above (2.61, or 2.77 without thermdif)

test  _b[voted:contact]= _b[voted:contact]+ _b[M1[subject]:M2[subject]] // still not significant diffs between within and between


**RE LOGIT WITH CIVIC ED INFLUENCING THE RANDOM TIME TREND-- SEE DIAGRAM 4 RE LOGIT W-RANDOM TIME TREND&IVS

melogit voted contact contact thermdif civiced year civtreat || subject: year, cov(unstructured) // RE with random time trend & iv predicting time trend

gsem (M1[subject] -> voted, family(binomial) link(logit)) (contact -> voted, family(binomial) link(logit)) /// 
(thermdif-> voted, family(binomial) link(logit)) (civiced -> M1[subject], ) (civiced -> M2[subject], ) /// 
(year -> voted, family(binomial) link(logit)) (M2[subject]#c.year -> voted), latent(M1 M2 ) cov( e.M2[subject]*e.M1[subject]) nocapslatent

**FULL ML-SEM MODEL WITH THREE RANDOM EFFECTS PLUS COVARIANCES AT BETWEEN LEVEL -- SEE DIAGRAM 5 ML-SEM WITH CONTACT AND 3 RE

gsem (M3[subject] -> contact, ) (M1[subject] -> voted, family(binomial) link(logit)) /// 
(contact -> voted, family(binomial) link(logit)) (year -> voted, family(binomial) link(logit)) /// 
(M2[subject]#c.contact -> voted), covstruct(_lexogenous, diagonal) latent(M3 M2 M1 ) /// 
cov( M3[subject]*M2[subject] M3[subject]*M1[subject] M2[subject]*M1[subject]) nocapslatent


**************GEE MODELS 

***GEE MODEL:  TAKES CLUSTERING OF OBSERVATIONS INTO ACCOUNT TO ESTIMATE EFFECTS OF IVS ON 'MARGINAL' (POPULATION-AVERAGED) DISTRIBUTION OF Y

xtgee voted contact civiced thermdif media year civtreat, family(binomial) link(logit) corr (exchangeable)
estat wcorr

***GEE MODEL ESTIMATED IN XTLOGIT -- identical estimates if use "pa" option (for "population averaged")

xtlogit voted contact civiced thermdif media year civtreat, pa

***GEE MODEL WITH AR1 ERRORS

xtgee voted contact civiced thermdif media year civtreat, family(binomial) link(logit) corr (ar1)
estat wcorr

***GEE MODEL WITH UNSTRUCTURED ERRORS
xtgee voted contact civiced thermdif media year civtreat, family(binomial) link(logit) corr (unstructured)
estat wcorr


