PS2701
Fall 2019

SESSION 5:  	STRUCTURAL EQUATION MODELS 
				CROSS-LAG AND SYNCHRONOUS EFFECTS MODELS

EXAMPLE:  AMERICAN NATIONAL ELECTION STUDY PANEL, 2000-2002-2004

use "nes3wave.dta"

***CROSS-LAGGED MODELS


***TWO WAVE MODELS

***DIAGRAM 2
sem (pid2000 -> pid2002, ) (pid2000 -> app2002, ) (app2000 -> pid2002, ) (app2000 -> app2002, ) ///
, standardized cov( pid2000*app2000) nocapslatent
estat gof, sta(all)

estat eqgof // gives traditional R-squared type goodness of fit for each equation
estat mindices

***WITH CORRELATED ERROR DISTURBANCE AT WAVE 2

sem (pid2000 -> pid2002, ) (pid2000 -> app2002, ) (app2000 -> pid2002, ) (app2000 -> app2002, ) ///
, standardized cov( pid2000*app2000) cov (e.pid2002*e.app2002) nocapslatent

estat gof, sta(all)


*****THREE WAVE MODELS

sem (pid2002 -> pid2004) (pid2002 -> app2004) (app2002 -> app2004) (app2002 -> pid2004) (pid2000 -> pid2002, ) ///
(pid2000 -> app2002, ) (app2000 -> pid2002, ) (app2000 -> app2002, ) , cov( pid2000*app2000) ///
nocapslatent
estat gof, sta(all)

x2=310.2(6)

// get standardized solution without re-running the full model
sem, standardized


****ADDING COVARIANCES BETWEEN THE TIME 2 DISTURBANCES FOR APP-PID, AND TIME 3 DISTURBANCES FOR APP-PID
sem (pid2002 -> pid2004) (pid2002 -> app2004) (app2002 -> app2004) (app2002 -> pid2004) (pid2000 -> pid2002, ) ///
(pid2000 -> app2002, ) (app2000 -> pid2002, ) (app2000 -> app2002, ) ,  cov( pid2000*app2000) ///
cov(e.pid2002*e.app2002) cov (e.pid2004*e.app2004) nocapslatent
estat gof, sta(all)

x2=133.5 (4) : HUGE IMPROVEMENT IN FIT!

****ADDING EQUALITY CONSTRAINTS FOR STABILITIES
sem (pid2002@pidstab -> pid2004) (pid2002 -> app2004) (app2002@appstab -> app2004) (app2002 -> pid2004) (pid2000@pidstab -> pid2002, ) ///
(pid2000 -> app2002, ) (app2000 -> pid2002, ) (app2000@appstab -> app2002, ) ,  cov( pid2000*app2000) ///
cov(e.pid2002*e.app2002) cov (e.pid2004*e.app2004) nocapslatent
estat gof, sta(all)

x2=219.3 (6)  :  HUGE DECREASE IN FIT

****ADDING EQUALITY CONSTRAINTS FOR CROSS-LAG EFFECTS
sem (pid2002@pidstab -> pid2004) (pid2002@pidapp -> app2004) (app2002@appstab -> app2004) (app2002@apppid -> pid2004) (pid2000@pidstab -> pid2002, ) ///
(pid2000@pidapp -> app2002, ) (app2000@apppid -> pid2002, ) (app2000@appstab -> app2002, ) , cov( pid2000*app2000) ///
cov(e.pid2002*e.app2002) cov (e.pid2004*e.app2004) nocapslatent
estat gof, sta(all)

x2=252.6(8):  ANOTHER POOR FIT, WORSE THAN RELAXING EQUALITY CONSTRAINTS

****ADD EDUCATION AS EXOGENOUS VARIABLE AFFECTING ALL VARIABLES AT ALL TIMES

**WITH WAVE 2 AND WAVE 3 CONTEMPORANEOUS ERROR DISTURBANCE COVARIANCES (constrained to be equal)
**DIAGRAM 3
sem (pid2002 educ->pid2004) (pid2002 educ-> app2004) (app2002 educ -> app2004) (app2002 educ-> pid2004) (pid2000 educ-> pid2002, ) ///
(pid2000 educ-> app2002, ) (app2000  educ-> pid2002, ) (app2000 educ -> app2002, ) ///
(_cons educ->pid2000) (_cons educ->app2000) , cov(e.pid2000*e.app2000) cov(e.pid2002*e.app2002@disturb) ///
cov(e.pid2004*e.app2004@disturb) nocapslatent

X2=132.8(5)  :  HUGE IMPROVEMENT IN FIT


***NOW ADD WAVE1 AND WAVE3 PID ERROR COVARIANCE
sem (pid2002 educ->pid2004) (pid2002 educ-> app2004) (app2002 educ -> app2004) (app2002 educ-> pid2004) (pid2000 educ-> pid2002, ) ///
(pid2000 educ-> app2002, ) (app2000  educ-> pid2002, ) (app2000 educ -> app2002, ) ///
(_cons educ->pid2000) (_cons educ->app2000) , cov(e.pid2000*e.app2000) cov(e.pid2002*e.app2002@disturb) ///
cov(e.pid2004*e.app2004@disturb) cov(e.pid2000*e.pid2004) nocapslatent

X2=109.8(4) : ANOTHER BIG IMPROVEMENT IN FIT

sem, standardized


** OR TRY DIRECT EFFECT OF PID2000->PID2004:  ANOTHER HUGE IMPROVEMENT!!
sem (pid2002 educ pid2000->pid2004) (pid2002 educ-> app2004) (app2002 educ -> app2004) (app2002 educ-> pid2004) (pid2000 educ-> pid2002, ) ///
(pid2000 educ-> app2002, ) (app2000  educ-> pid2002, ) (app2000 educ -> app2002, ) ///
(_cons educ->pid2000) (_cons educ->app2000) , cov(e.pid2000*e.app2000) cov(e.pid2002*e.app2002@disturb) ///
cov(e.pid2004*e.app2004@disturb) standardized

X2=36.81(4) : VERY GOOD RELATIVE FIT


**** SYNCHRONOUS EFFECTS MODELS



*****THREE WAVE MODELS
**Unconstrained synchronous effects only model : X2=176.5 (6)
 sem (pid2000 -> pid2002, ) (pid2002 -> pid2004, ) (pid2002 -> app2002, ) /// 
 (pid2004 -> app2004, ) (app2000 -> app2002, ) (app2002 -> pid2002, ) (app2002 -> app2004, ) /// 
 (app2004 -> pid2004, ), standardized cov( pid2000*app2000) nocapslatent


**Equality constraints in synch effects:  X2=178.6 (8), so better model than unconstrained
sem (pid2000 -> pid2002, ) (pid2002 -> pid2004, ) (pid2002@a -> app2002, ) (pid2004@a -> app2004, ) ///
(app2000 -> app2002, ) (app2002@b -> pid2002, ) (app2002 -> app2004, ) (app2004@b -> pid2004, ), ///
standardized cov( pid2000*app2000) nocapslatent
estat gof, sta(all)

**Add error covariances at time2 and time3, equated:  X(2)=157(7), so better model than model above that constrained these effects to 0
sem (pid2000 -> pid2002, ) (pid2002 -> pid2004, ) (pid2002@a -> app2002, ) (pid2004@a -> app2004, ) ///
(app2000 -> app2002, ) (app2002@b -> pid2002, ) (app2002 -> app2004, ) (app2004@b -> pid2004, ), ///
standardized cov( pid2000*app2000 e.pid2002*e.app2002@c e.pid2004*e.app2004@c) nocapslatent
estat gof, sta(all)

**add cross-lagged effects, equated (need to eliminate the error covariances to achieve identification)
***DIAGRAM 4
**X2=134(6) so appears to be the best model so far
sem (pid2000 -> pid2002, ) (pid2000@e -> app2002, ) (pid2002 -> pid2004, ) ///
(pid2002@a -> app2002, ) (pid2002@e -> app2004, ) (pid2004@a -> app2004, ) ///
(app2000@d -> pid2002, ) (app2000 -> app2002, ) (app2002@b -> pid2002, ) /// 
(app2002@d -> pid2004, ) (app2002 -> app2004, ) (app2004@b -> pid2004, ), /// 
standardized cov( pid2000*app2000) nocapslatent

***AND THE SUBSTANTIVE RESULTS MAKE GOOD SENSE:  SYNCH EFFECT OF PID ON APP, LAGGED EFFECT OF APP ON PID.
***BUT:
estat gof, sta(all)
estat mindices  // SHOWS THAT COVARIATION BETWEEN PID2000 AND PID2004 STILL UNEXPLAINED BY MODEL

***FINAL (?) MODEL:  ADD DIRECT EFFECT FROM PID2000->PID2004
sem (pid2000 -> pid2002, ) (pid2000 -> pid2004, ) (pid2000@e -> app2002, ) (pid2002 -> pid2004, ) (pid2002@a -> app2002, ) ///
 (pid2002@e -> app2004, ) (pid2004@a -> app2004, ) (app2000@d -> pid2002, ) (app2000 -> app2002, ) /// 
 (app2002@b -> pid2002, ) (app2002@d -> pid2004, ) (app2002 -> app2004, ) (app2004@b -> pid2004, ), /// 
 cov( pid2000*app2000) nocapslatent standardized
 estat gof, sta (all)
