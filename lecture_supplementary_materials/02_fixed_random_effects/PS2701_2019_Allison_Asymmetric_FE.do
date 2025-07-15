***Stata code for Asymmetric Fixed Effects Models for Panel Data
***Paul D. Allison
***31 December 2018

***Section 2
use "https://statisticalhorizons.com/wp-content/uploads/nlsy.dta", clear
generate antidiff=anti92-anti90
generate selfdiff=self92-self90
generate povdiff=pov92-pov90
***Table 1
table povdiff
***Figure 1
hist antidiff, freq discrete
***Figure 2
hist selfdiff, freq
***Table 2
regress antidiff selfdiff povdiff

***Section 3
generate selfpos=selfdiff*(selfdiff>0)
generate selfneg=-selfdiff*(selfdiff<0)
generate povpos=povdiff*(povdiff>0)
generate povneg=-povdiff*(povdiff<0)
***Table 3
regress antidiff selfpos selfneg povpos povneg
test selfpos=-selfneg
test povpos=-povneg

***Section 4
use "https://statisticalhorizons.com/wp-content/uploads/wagerate.dta", clear
gen id = _n
reshape long lwage mar edu urb, i(id) j(year)
xtset id year
***Table 4
xtreg lwage mar edu urb i.year, fe robust
***Table 5, left panel
***The next 4 commandsuse the d. operator to create difference scores.
***This requires the xtset command above. 
gen wagediff=d.lwage
gen mardiff=d.mar
gen edudiff=d.edu
gen urbdiff=d.urb
reg wagediff mardiff edudiff urbdiff i.year, cluster(id)
***Table 5, right panel
xtreg wagediff mardiff edudiff urbdiff i.year, fe robust
***Table 6, left panel
mixed wagediff mardiff edudiff urbdiff i.year || id:, ///
   nocon res(uns,t(year)) stddev robust
***Table 6, right panel
mixed wagediff mardiff edudiff urbdiff i.year || id:, ///
   nocon res(toeplitz1,t(year)) stddev robust
  
***Section 5
***Table 7
tab mardiff
tab urbdiff   
***Table 8 Not available in Stata   

***Section 6
use "https://statisticalhorizons.com/wp-content/uploads/wagerate.dta", clear
gen id = _n
reshape long lwage mar edu urb, i(id) j(year)
xtset id year
gen mardiff=d.mar
gen urbdiff=d.urb
replace mardiff=0 if mardiff==.
replace urbdiff=0 if urbdiff==.
gen marpos=mardiff*(mardiff>0)
gen marneg=-mardiff*(mardiff<0)
gen urbpos=urbdiff*(urbdiff>0)
gen urbneg=-urbdiff*(urbdiff<0)
***The next 4 commands generate the cumulative sums:
bysort id (year): gen marcumpos = sum(marpos)
bysort id (year): gen marcumneg = sum(marneg)
bysort id (year): gen urbcumpos = sum(urbpos)
bysort id (year): gen urbcumneg = sum(urbneg)
xtreg lwage marcumpos marcumneg urbcumpos urbcumneg edu i.year, fe robust


***Section 7
***Table 9
use "https://statisticalhorizons.com/wp-content/uploads/teenyrs5.dta", clear
xtset id year
clogit pov mother spouse inschool hours i.year, group(id) robust
gen spousediff=d.spouse
gen inschooldiff=d.inschool
gen hoursdiff=d.hours
replace spousediff=0 if spousediff==.
replace inschooldiff=0 if inschooldiff==.
replace hoursdiff=0 if hoursdiff==.
gen spousepos=spousediff*(spousediff>0)
gen spouseneg=-spousediff*(spousediff<0)
gen inschoolpos=inschooldiff*(inschooldiff>0)
gen inschoolneg=-inschooldiff*(inschooldiff<0)
gen hourspos=hoursdiff*(hoursdiff>0)
gen hoursneg=-hoursdiff*(hoursdiff<0)
bysort id (year): gen spousecumpos=sum(spousepos)
bysort id (year): gen spousecumneg=sum(spouseneg)
bysort id (year): gen inschoolcumpos=sum(inschoolpos)
bysort id (year): gen inschoolcumneg=sum(inschoolneg)
bysort id (year): gen hourscumpos=sum(hourspos)
bysort id (year): gen hourscumneg=sum(hoursneg)
clogit pov mother spousecumpos spousecumneg inschoolcumpos ///
 inschoolcumneg hourscumpos hourscumneg i.year, group(id) robust
