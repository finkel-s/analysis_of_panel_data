use http://www.stata-press.com/data/r14/gsem_womenwk
generate selected = 0 if wage < .
generate notselected = 0 if wage >= .
recode selected .=1, gen(select2)
recode notselected .=1, gen(notselect2)
gsem (wage <- educ age  L) (selected <- married children educ age L@1,  ///
family(gaussian, udepvar(notselected))), var(L@1 e.wage@a e.selected@a)

***THIS USES A DICHOTOMOUS NOT-SELECTED VARIABLE, NOT THE CENSORED VERSION (BINARY DIAGRAM)
 gsem (married -> notselect2, family(binomial) link(probit)) (children -> notselect2, fami
> ly(binomial) link(probit)) (educ -> notselect2, family(binomial) link(probit)) (educ -> w
> age, ) (age -> notselect2, family(binomial) link(probit)) (age -> wage, ) (L@1 -> notsele
> ct2, family(binomial) link(probit)) (L -> wage, ), covstruct(_lexogenous, diagonal) laten
> t(L ) cov( e.wage@a L@1) nocapslatent

