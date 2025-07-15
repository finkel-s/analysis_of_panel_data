#R Code for Asymmetric Fixed Effects Models for Panel Data
#Paul D. Allison
#31 December 2018

#Libraries
library(haven)
library(magrittr)
library(clubSandwich)
library(car)
library(plm)
library(tidyverse)
library(nlme)
library(survival)
#Section 2
nlsy <- read_dta(url("https://statisticalhorizons.com/wp-content/uploads/nlsy.dta"))
nlsy$antidiff <- nlsy$anti92 - nlsy$anti90
nlsy$selfdiff<-nlsy$self92-nlsy$self90
nlsy$povdiff<-nlsy$pov92-nlsy$pov90
#Table 1
table(nlsy$povdiff)
#Figure 1
hist(nlsy$selfdiff)
#Figure 2
hist(nlsy$antidiff)
nlsy$selfpos<- nlsy$selfdiff*(nlsy$selfdiff>0)
nlsy$selfneg<- -nlsy$selfdiff*(nlsy$selfdiff<0)
nlsy$povpos<- nlsy$povdiff*(nlsy$povdiff>0)
nlsy$povneg<- -nlsy$povdiff*(nlsy$povdiff<0)
#Table 2
ols<-lm(antidiff ~ selfdiff + povdiff, data = nlsy)
summary(ols)

#Section 3
#Table 3
ols3<-lm(antidiff ~ selfpos + selfneg +povpos + povneg, data = nlsy)
summary(ols3)
lht(ols3,"selfpos=-selfneg")

#Section 4
#Read wage data from the web in wide form:
wage<-read_dta(url("https://statisticalhorizons.com/wp-content/uploads/wagerate.dta"))

#Reshape to long form:
wage$id <- seq(1:nrow(wage)) # add id value
data.table::setDT(wage)
wage_long <- data.table::melt(wage, 
                              measure = patterns("^lwage","^mar","^edu","urb"), 
                              variable.name = "time",
                              value.name = c("wage","mar", "edu", "urb"))
wage_long %<>% arrange(id, time)

#Table 4
fe.plm <- plm(wage ~ mar + edu + urb + time,
              index = "id", model = "within", data = wage_long)
summary(fe.plm)
coef_test(fe.plm, vcov = "CR1S", cluster = wage_long$id, test = "naive-t")


#Create difference scores and decompose them
wage_long2 <- wage_long %>%
  group_by(id) %>%
  mutate(wagediff = wage-lag(wage), mardiff = mar-lag(mar), 
         edudiff = edu-lag(edu), urbdiff=urb-lag(urb)) %>% # Create first-difference scores for all variables
  mutate(marpos = mardiff*(mardiff>0), marneg = -mardiff*(mardiff<0), 
         urbpos = urbdiff*(urbdiff>0), urbneg = -urbdiff*(urbdiff<0))# Decompose difference scores into positive and negative components
wage_long2<-as.data.frame(wage_long2) 

#Table 5, left panel
wageols<-lm(wagediff ~ mardiff + edudiff +urbdiff + time, data = wage_long2)
summary(wageols)
coef_test(wageols, 
          vcov = "CR1S", cluster = wage_long2$id, test = "naive-t")

#Table 5, right panel
wage.fe <- plm(wagediff ~ mardiff + edudiff + urbdiff + time,
               index = "id", model = "within", data = wage_long2)
summary(wage.fe)
coef_test(wage.fe, vcov = "CR1S", cluster = wage_long2$id, test = "naive-t")

#Table 6, left panel
#Delete cases from time 1 with missing difference scores (gls won't tolerate NAs):
wage_long3<-na.omit(wage_long2)
#Then subtract 1 from time factor so it has values 1,2,3,4.  
wage_long3$time<-as.factor(as.numeric(as.character(wage_long3$time))-1)
gls.uns <- gls(wagediff ~ mardiff + edudiff + urbdiff + time,
               corr = corSymm(form = ~ 1 | id),       # unstructured covariance
               weights = varIdent(form = ~ 1 | time), # unstructured variance 
               data = wage_long3,
               method = "ML")
summary(gls.uns)
coef_test(gls.uns, vcov = "CR1S", cluster = wage_long3$id, test = "naive-t")

#Table 6, right panel
gls.toe2 <- gls(wagediff ~ mardiff + edudiff + urbdiff + time,
                corr = corARMA(form = ~ 1 | id, p = 0, q = 1),  
                data = wage_long3,
                method = "ML")
summary(gls.toe2)
coef_test(gls.toe2, vcov = "CR1S", cluster = wage_long3$id, test = "naive-t")

#Fully constrained GLS
gls.con <- gls(wagediff ~ mardiff + edudiff + urbdiff + time,
               corr = corARMA(value=-.9999,form = ~ 1 | id, p = 0, q = 1, fixed=T),  
               data = wage_long3, method = "ML")
summary(gls.con)
coef_test(gls.con, vcov = "CR1S", cluster = wage_long3$id, test = "naive-t")

#Section 5
#Table 7
table(wage_long3$urbdiff)
table(wage_long3$mardiff)

#Table 8
gls.con2 <- gls(wagediff ~ marpos + marneg + edudiff + urbpos + urbneg + time,
                corr = corARMA(value=-.9999,form = ~ 1 | id, p = 0, q = 1, fixed=T),  
                data = wage_long3, method = "ML")
summary(gls.con2)
coef_test(gls.con2, vcov = "CR1S", cluster = wage_long3$id, test = "naive-t")
lht(gls.con2,"urbpos=-urbneg")
lht(gls.con2,"marpos=-marneg")


#Section 6

#Read 5-period data from the web in wide form:
wage<-read_dta(url("https://statisticalhorizons.com/wp-content/uploads/wagerate.dta"))
wage$id <- seq(1:nrow(wage)) # add id variable

#Convert to long form:
wage.long<- wage %>%
  gather(Key, Value, -id, -male, -i) %>%
  separate(Key, into=c("var", "time"), sep = "(?<=[A-Za-z])(?=[0-9])") %>%
  spread(var, Value)

#Create difference scores, decompose them, and cumulate them:
wage.long2 <- wage.long %>%
  group_by(id) %>%
  mutate(wagediff = lwage-lag(lwage), mardiff = mar-lag(mar), 
         edudiff = edu-lag(edu), urbdiff = urb-lag(urb)) %>% # Create first-difference scores for all variables
  mutate(marpos = mardiff*(mardiff>0), marneg = -mardiff*(mardiff<0),
         urbpos = urbdiff*(urbdiff>0), urbneg = -urbdiff*(urbdiff<0)) %>% # Decompose difference scores into positive and negative components
  replace(is.na(.), 0) %>% # ATTN: this makes all missing values zero, not just the NAs from t=1.
  mutate(marcumpos = cumsum(marpos), marcumneg = cumsum(marneg), 
         urbcumpos = cumsum(urbpos), urbcumneg = cumsum(urbneg)) #Generate cumulative values of the difference scores:
wage.long2<-as.data.frame(wage.long2)

#Estimate fixed effects model:
wage.fe <- plm(lwage ~ marcumpos + marcumneg + edu + urbcumpos + urbcumneg + time, index = "id", model = "within", data = wage.long2)
summary(wage.fe)
coef_test(wage.fe, vcov = "CR1S", cluster = wage.long2$id,  test = "z")
lht(wage.fe,"urbcumpos=-urbcumneg")
lht(wage.fe,"marcumpos=-marcumneg")


#Section 7
#Read 5-period data from the web in wide form:
teenpov<-read_dta(url("https://statisticalhorizons.com/wp-content/uploads/teenpov.dta"))
#Convert data to long form:
teenpov.long<- teenpov %>%
  gather(Key, Value, -id, -black,-age) %>%
  separate(Key, into=c("var", "time"), sep = "(?<=[A-Za-z])(?=[0-9])") %>%
  spread(var, Value)

#Table 9, Estimate symmetric fixed effects
teenpov.fe<- clogit(pov~mother+spouse+inschool+hours+time+strata(id),
                    data=teenpov.long)
summary(teenpov.fe)

#Create variables for asymmetric model
teenpov.long2 <- teenpov.long %>%
  group_by(id) %>%
  mutate(spousediff = spouse-lag(spouse), schooldiff = inschool-lag(inschool), 
         hoursdiff = hours-lag(hours)) %>% # Create first-difference scores for all variables
  mutate(spousepos = spousediff*(spousediff>0), spouseneg = -spousediff*(spousediff<0), 
         schoolpos = schooldiff*(schooldiff>0), schoolneg = -schooldiff*(schooldiff<0),
         hourspos=hoursdiff*(hoursdiff>0),hoursneg=-hoursdiff*(hoursdiff<0)) %>% # Decompose difference scores into positive and negative components
  replace(is.na(.), 0) %>% # ATTN: this makes all missing values zero, not just the NAs from t=1.
  mutate(spousecumpos = cumsum(spousepos), spousecumneg = cumsum(spouseneg), 
         schoolcumpos = cumsum(schoolpos), schoolcumneg = cumsum(schoolneg),
         hourscumpos = cumsum(hourspos),   hourscumneg = cumsum(hoursneg)) #Generate cumulative values of the difference scores:

#Table 10 - Estimate asymmetric fixed effects model
teenpov.fe2<- clogit(pov~mother+spousecumpos+spousecumneg+schoolcumpos+schoolcumneg+
                       hourscumpos+hourscumneg+time+strata(id), data=teenpov.long2)
summary(teenpov.fe2)
lht(teenpov.fe2,"spousecumpos=-spousecumneg")
lht(teenpov.fe2,"schoolcumpos=-schoolcumneg")
lht(teenpov.fe2,"hourscumpos=-hourscumneg")


