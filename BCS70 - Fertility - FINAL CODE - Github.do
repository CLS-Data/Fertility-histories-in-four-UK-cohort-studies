
global raw "[insert file path to folder with raw data]"
global derived "[insert file path to folder for derived data]"


clear all
set maxvar 30000
set more off


***********BCS70 fertility**********


**# Bookmark #1
*******************************************************************************
****************************** AGE 26 ***************************************** 
*******************************************************************************

//we start at age 26 as previous sweep was age 16 so too early for fertility questions for most respondents
//there are some direct questions about whether has children and how many, but not info on each individual child, such as age and sex. We therefore use the household grid for this information, although keeping in mind that not all children may be in the household.   


*****AGE 26 (1996)
use "$raw\bcs96x.dta", clear
//N=9,003

keep bcsid b960322 b960319 b960321 b960338 b960343 b960348 b960353 b960358 b960363 b960368 b960373 b960378 b960415 b960340 b960345 b960350 b960355 b960360 b960365 b960370 b960375 b960412 b960341 b960346 b960351 b960356 b960361 b960366 b960371 b960376 b960413 b960333 b960334 b960335 b960336 haschild ownkid adopkid fostkid stepkid numkids


gen BCSAGE26SURVEY=1
label var BCSAGE26SURVEY "Whether took part in age 26 survey"


//whether has a partner or spouse living in household (age 26)
fre b960321 //living with partner or spouse
recode b960321 (3=0 "No") (1/2=1 "Yes") (-8=.), gen(partner)
label var partner "Whether has a partner in HH (age 26)"
label define partner 0 "No" 1 "Yes" -100 "no participation in sweep" -99 "information not provided", replace
label values partner partner
fre partner
drop b960321


//marital status and partnership (age 26)
fre b960322 //marital
gen marital=.
replace marital=3 if b960322==1|b960322==4|b960322==5|b960322==6
replace marital=2 if (b960322==1|b960322==4|b960322==5|b960322==6) & partner==1
replace marital=1 if b960322==2|b960322==3
label define marital 3 "Single" 2 "Single cohabiting with partner" 1 "Married" -100 "no participation in sweep" -99 "information not provided", replace
label values marital marital
label variable marital "Marital status (age 26)" 
fre marital
drop b960322


//currently in relationship (age 26)
fre b960319
drop b960319


//age of CM years (age 26)
fre b960338
rename b960338 cmagey
label var cmagey "CM age at interview"


*HOUSEHOLD GRID (row format) (age 26)

//relationship to CM (age 26)
fre b960343 b960348 b960353 b960358 b960363 b960368 b960373 b960378 b960415

fre b960343 b960348 b960353 b960358 b960363 b960368 b960373 b960378 b960415 //1=Lawful Spouse, 2=Live-in partner, 3=Own Child, 4=Adopted Child, 5= foster Child, 6=Stepchild/Partner's Child (age 26)
rename (b960343 b960348 b960353 b960358 b960363 b960368 b960373 b960378 b960415) (hhrel2 hhrel3 hhrel4 hhrel5 hhrel6 hhrel7 hhrel8 hhrel9 hhrel10)

//sex of HH member (age 26)
fre b960340 b960345 b960350 b960355 b960360 b960365 b960370 b960375 b960412
rename (b960340 b960345 b960350 b960355 b960360 b960365 b960370 b960375 b960412) (hhsex2 hhsex3 hhsex4 hhsex5 hhsex6 hhsex7 hhsex8 hhsex9 hhsex10)

//age of HH member (years) (age 26)
fre b960341 b960346 b960351 b960356 b960361 b960366 b960371 b960376 b960413
rename (b960341 b960346 b960351 b960356 b960361 b960366 b960371 b960376 b960413) (hhage2 hhage3 hhage4 hhage5 hhage6 hhage7 hhage8 hhage9 hhage10)




//OTHER QUESTIONS ABOUT OWN OR PARTNER'S CHILDREN (age 26)

fre  b960333 b960334 b960335 b960336 
describe b960333 b960334 b960335 b960336 
/*
b960333         byte    %8.0g      b960333    Number of natural children
b960334         byte    %8.0g      b960334    No natural children
b960335         byte    %8.0g      b960335    Is partner other parent of all/some CM's children
b960336         byte    %8.0g      b960336    Do all your children live with you?
*/

drop b960336

fre  haschild ownkid adopkid fostkid stepkid numkids
describe  haschild ownkid adopkid fostkid stepkid numkids
/*
haschild        byte    %8.0g      haschild   R has natural child
ownkid          byte    %8.0g      ownkid     total number of own children in household
adopkid         byte    %8.0g      adopkid    total number of adopted children in household
fostkid         byte    %8.0g      fostkid    total number of foster children in household
stepkid         byte    %8.0g      stepkid    total number of stepchildren in household
numkids         byte    %8.0g      numkids    No of natural children
*/



*----------------------------------------------------------*
*** BIOLOGICAL CHILDREN (age 26)
fre b960334 b960333 

cap drop anybiochildren
gen anybiochildren=.
replace anybiochildren=1 if inrange(b960333,1,5)
replace anybiochildren=0 if b960334==1
label variable anybiochildren "Whether has had any bio children (age 26)"
label define yesno 0 "No" 1 "Yes" -100 "no participation in sweep" -99 "information not provided", replace
label values anybiochildren yesno
fre anybiochildren //27% yes

cap drop biochild_tot
gen biochild_tot=.
replace biochild_tot=b960333
replace biochild_tot=0 if b960334==1
label define biochild_tot 0 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values biochild_tot biochild_tot
label variable biochild_tot "Number of bio children (age 26)"
fre biochild_tot


foreach C in 2 3 4 5 6 7 8 9 10 {
*own children in HH grid (age 26)
cap drop biochildhh`C'
gen biochildhh`C'=0
replace biochildhh`C'=1 if hhrel`C'==3
label define biochildhh`C' 1 "Bio child in HH", replace
label values biochildhh`C' biochildhh`C'
label var biochildhh`C' "`C' Bio child in HH"
fre biochildhh`C'
}

cap drop biochildhh_total
gen biochildhh_total=biochildhh2 +biochildhh3 +biochildhh4 +biochildhh5 +biochildhh6 +biochildhh7 +biochildhh8 +biochildhh9 +biochildhh10
replace biochildhh_total=0 if b960334==1
replace biochildhh_total=. if biochild_tot==.
fre biochildhh_total
label variable biochildhh_total "Number of bio children in HH (HH grid data) (age 26)"
label define biochildhh_total 0 "None of the biological children live in household" -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildhh_total biochildhh_total
fre biochildhh_total


//biological children not in household (age 26)
cap drop biochildnonhh_total
gen biochildnonhh_total=biochild_tot-biochildhh_total
replace biochildnonhh_total=-10 if anybiochildren==0
fre biochildnonhh_total
label variable biochildnonhh_total "Number of bio children not in HH (age 26)"
label define biochildnonhh_total 0 "All biological children live in household" -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildnonhh_total biochildnonhh_total
fre biochildnonhh_total


replace biochildhh_total=-10 if anybiochildren==0 //coding this -10 after calculation of non-HH children as doing earlier would mess up calculation of non-HH children.
fre biochildhh_total
fre biochildhh_total if biochildhh_total!=-10

//note that we did not identify additional children in HH grid that were not reported as pregnancies



//whether a previous partner is parent to any children (age 26)
fre b960335
cap drop biochildprevany
gen biochildprevany=.
replace biochildprevany=1 if (b960335==1|b960335==3|b960335==4)
replace biochildprevany=0 if b960335==2
replace biochildprevany=-10 if anybiochildren==0
replace biochildprevany=. if anybiochildren==.
label variable biochildprevany "Any children with a previous partner"
label define biochildprevany 1 "Previous partner(s) parent to all or some biological children" 0 "Current partner is parent to all biological children" -10 "No biological children"  -100 "no participation in sweep" -99 "information not provided", replace
label values biochildprevany biochildprevany
fre biochildprevany




*----------------------------------------------------------*
*** SEX OF BIOLOGICAL CHILDREN (age 26)
//we use HH grid data as no info in pregnancy data

foreach C in 2 3 4 5 6 7 8 9 10 {

*sex of biological hh children (age 26)
cap drop biochildhhboy`C'
gen biochildhhboy`C'=0
replace biochildhhboy`C'=1 if hhsex`C'==1 & hhrel`C'==3
label define biochildhhboy`C' 1 "Boy", replace
label values biochildhhboy`C' biochildhhboy`C'
label var biochildhhboy`C' "`C' hh biological child is a boy"
fre biochildhhboy`C'

cap drop biochildhhgirl`C'
gen biochildhhgirl`C'=0
replace biochildhhgirl`C'=1 if hhsex`C'==2 & hhrel`C'==3
label define biochildhhgirl`C' 1 "girl", replace
label values biochildhhgirl`C' biochildhhgirl`C'
label var biochildhhgirl`C' "`C' hh biological child is a girl"
fre biochildhhgirl`C'
}



***COMPUTE total number of biological girls and boys reported in hh grid (age 26)
cap drop biochildhhboy_total
gen biochildhhboy_total=biochildhhboy2 +biochildhhboy3 +biochildhhboy4 +biochildhhboy5 +biochildhhboy6 +biochildhhboy7 +biochildhhboy8 +biochildhhboy9 +biochildhhboy10
label variable biochildhhboy_total "Total number of bio boys in household (HH grid data)"
fre biochildhhboy_total
rename biochildhhboy_total biochildboy_total
replace biochildboy_total=-10 if anybiochildren==0
replace biochildboy_total=. if anybiochildren==.
label define biochildboy_total 0 "Girls only" -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values biochildboy_total biochildboy_total
label variable biochildboy_total "Total number of biological boys"

cap drop biochildhhgirl_total
gen biochildhhgirl_total=biochildhhgirl2 +biochildhhgirl3 +biochildhhgirl4 +biochildhhgirl5 +biochildhhgirl6 +biochildhhgirl7 +biochildhhgirl8 +biochildhhgirl9 +biochildhhgirl10
label variable biochildhhgirl_total "Total number of bio girls in household (HH grid data)"
fre biochildhhgirl_total
rename biochildhhgirl_total biochildgirl_total
replace biochildgirl_total=-10 if anybiochildren==0
replace biochildgirl_total=. if anybiochildren==.
label define biochildgirl_total 0 "Boys only" -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values biochildgirl_total biochildgirl_total
label variable biochildgirl_total "Total number of biological girls"





*----------------------------------------------------------*
*** AGE OF BIOLOGICAL CHILDREN (age 26)
//we use HH grid data as no info in pregnancy data

foreach C in 2 3 4 5 6 7 8 9 10 {
cap drop biohhage`C'
gen biohhage`C'=.
replace biohhage`C'=hhage`C' if hhrel`C'==3
replace biohhage`C'=. if hhage`C'==-3
fre biohhage`C'
}


*** COMPUTE age of eldest and youngest biological child (age 26)
cap drop biochildy_eldest //years
gen biochildy_eldest = max(biohhage2,biohhage3,biohhage4,biohhage5,biohhage6,biohhage7,biohhage8,biohhage9,biohhage10)
replace biochildy_eldest=-10 if anybiochildren==0
replace biochildy_eldest=. if anybiochildren==.
label define biochildy_eldest -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildy_eldest biochildy_eldest
label var biochildy_eldest "Age in years of eldest biological child"
fre biochildy_eldest


cap drop biochildy_youngest //years
gen biochildy_youngest = min(biohhage2,biohhage3,biohhage4,biohhage5,biohhage6,biohhage7,biohhage8,biohhage9,biohhage10)
replace biochildy_youngest=-10 if anybiochildren==0
replace biochildy_youngest=. if anybiochildren==.
label define biochildy_youngest -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildy_youngest biochildy_youngest
label var biochildy_youngest "Age in years of youngest biological child"
fre biochildy_youngest




*----------------------------------------------------------*
*** CM AGE AT BIRTH OF BIOLOGICAL CHILDREN (age 26)

foreach C in 2 3 4 5 6 7 8 9 10 {

//cm age in whole years at birth of child (age 26)
cap drop cmageybirth`C'
gen cmageybirth`C' = cmagey-biohhage`C' 
fre cmageybirth`C'
label var cmageybirth`C' "`C' Age of CM in years at birth of biological child `C'"
fre cmageybirth`C'
}

***COMPUTE age of cohort member at birth of eldest and youngest child in years (age 26)
cap drop cmageybirth_eldest //years
gen cmageybirth_eldest = min(cmageybirth2,cmageybirth3,cmageybirth4,cmageybirth5,cmageybirth6,cmageybirth7,cmageybirth8,cmageybirth9,cmageybirth10)
replace cmageybirth_eldest=-10 if anybiochildren==0
replace cmageybirth_eldest=. if anybiochildren==.
label define cmageybirth_eldest -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values cmageybirth_eldest cmageybirth_eldest
label var cmageybirth_eldest "CM age in years at birth of eldest biological child"
fre cmageybirth_eldest

cap drop cmageybirth_youngest //years
gen cmageybirth_youngest = max(cmageybirth2,cmageybirth3,cmageybirth4,cmageybirth5,cmageybirth6,cmageybirth7,cmageybirth8,cmageybirth9,cmageybirth10)
replace cmageybirth_youngest=-10 if anybiochildren==0
replace cmageybirth_youngest=. if anybiochildren==.
label define cmageybirth_youngest -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values cmageybirth_youngest cmageybirth_youngest
label var cmageybirth_youngest "CM age in years at birth of youngest biological child"
fre cmageybirth_youngest




*----------------------------------------------------------*
***NON BIOLOGICAL CHILDREN (age 26)
fre adopkid fostkid stepkid 

cap drop nonbiochild_tot
gen nonbiochild_tot=adopkid + fostkid + stepkid 
label define nonbiochild_tot 0 "No non-biological children in HH" -100 "no participation in sweep" -99 "information not provided", replace 
label values nonbiochild_tot nonbiochild_tot
label variable nonbiochild_tot "Number of non-bio children in HH (age 26)"
fre nonbiochild_tot

cap drop anynonbio
recode nonbiochild_tot (0=0 "No") (1/5=1 "Yes"), gen(anynonbio)
label variable anynonbio "Whether has any non-bio children in HH (age 26)"
label define anynonbio 0 "No" 1 "Yes" -100 "no participation in sweep" -99 "information not provided", replace 
fre anynonbio

fre adopkid
cap drop adopt_tot
gen adopt_tot=adopkid
label define adopt_tot 0 "No adopted children in HH" -100 "no participation in sweep" -99 "information not provided", replace 
label values adopt_tot adopt_tot
label variable adopt_tot "Number of adopted children in HH (age 26)"
fre adopt_tot

fre fostkid
cap drop foster_tot
gen foster_tot=fostkid
label define foster_tot 0 "No foster children in HH" -100 "no participation in sweep" -99 "information not provided", replace 
label values foster_tot foster_tot
label variable foster_tot "Number of foster children in HH (age 26)"
fre foster_tot

fre stepkid
cap drop step_tot
gen step_tot=stepkid
label define step_tot 0 "No stepchildren in HH" -100 "no participation in sweep" -99 "information not provided", replace 
label values step_tot step_tot
label variable step_tot "Number of stepchildren in HH (age 26)"
fre step_tot

drop numkids adopkid fostkid stepkid 


foreach C in 2 3 4 5 6 7 8 9 10 {
*age of nonbio children
cap drop nonbiochildagey`C'
clonevar nonbiochildagey`C' = hhage`C' if inrange(hhrel`C',4,6) & inrange(hhage`C',0,100) 
label var nonbiochildagey`C' "`C' Age in years of non-biological child"
fre nonbiochildagey`C'

*sex of nonbio children
cap drop nonbiochildsex`C'
clonevar nonbiochildsex`C' = hhsex`C' if inrange(hhrel`C',4,6)
label var nonbiochildsex`C' "`C' Sex of non-biological child"
fre nonbiochildsex`C'
}



***COMPUTE age of youngest and oldest non-biological child (age 26)
cap drop nonbiochildy_eldest //years
gen nonbiochildy_eldest = max(nonbiochildagey2, nonbiochildagey3, nonbiochildagey4, nonbiochildagey5, nonbiochildagey6, nonbiochildagey7, nonbiochildagey8, nonbiochildagey9, nonbiochildagey10)
replace nonbiochildy_eldest=-10 if anynonbio==0
replace nonbiochildy_eldest=. if (BCSAGE26SURVEY==.)
replace nonbiochildy_eldest=. if nonbiochildy_eldest==50
label define nonbiochildy_eldest -10 "No non-biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values nonbiochildy_eldest nonbiochildy_eldest
label var nonbiochildy_eldest "Age in years of eldest non-biological child"
fre nonbiochildy_eldest

cap drop nonbiochildy_youngest //years
gen nonbiochildy_youngest = min(nonbiochildagey2, nonbiochildagey3, nonbiochildagey4, nonbiochildagey5, nonbiochildagey6, nonbiochildagey7, nonbiochildagey8, nonbiochildagey9, nonbiochildagey10)
replace nonbiochildy_youngest=-10 if anynonbio==0
replace nonbiochildy_youngest=. if (BCSAGE26SURVEY==.)
replace nonbiochildy_youngest=. if nonbiochildy_youngest==50
label define nonbiochildy_youngest -10 "No non-biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values nonbiochildy_youngest nonbiochildy_youngest
label var nonbiochildy_youngest "Age in years of youngest non-biological child"
fre nonbiochildy_youngest




***COMPUTE total number of non-biological boys and girls (age 26)
//nonbiochildsex: 1=boy 2=girl
cap drop nonbiochildboy_total
egen nonbiochildboy_total = anycount(nonbiochildsex2 nonbiochildsex3 nonbiochildsex4 nonbiochildsex5 nonbiochildsex6 nonbiochildsex7 nonbiochildsex8 nonbiochildsex9 nonbiochildsex10), values(1)
replace nonbiochildboy_total=-10 if anynonbio==0 //no non-biologial children
replace nonbiochildboy_total=. if (BCSAGE26SURVEY==.)
label define nonbiochildboy_total 0 "Girls only" -10 "No non-biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values nonbiochildboy_total nonbiochildboy_total
label var nonbiochildboy_total "Total number of non-biological children who are boys"
fre nonbiochildboy_total

cap drop nonbiochildgirl_total
egen nonbiochildgirl_total = anycount(nonbiochildsex2 nonbiochildsex3 nonbiochildsex4 nonbiochildsex5 nonbiochildsex6 nonbiochildsex7 nonbiochildsex8 nonbiochildsex9 nonbiochildsex10), values(2)
replace nonbiochildgirl_total=-10 if anynonbio==0 //no non-biologial children
replace nonbiochildgirl_total=. if (BCSAGE26SURVEY==.)
label define nonbiochildgirl_total 0 "Boys only" -10 "No non-biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values nonbiochildgirl_total nonbiochildgirl_total
label var nonbiochildgirl_total "Total number of non-biological children who are girls"
fre nonbiochildgirl_total 



*----------------------------------------------------------*
***BIOLOGICAL AND NON-BIOLOGICAL CHILDREN (age 26)
cap drop anychildren
gen anychildren=.
replace anychildren=1 if anybio==1|anynonbio==1
replace anychildren=0 if anybio==0 & anynonbio==0
label define anychildren 0 "No" 1 "Yes" -100 "no participation in sweep" -99 "information not provided", replace
label values anychildren anychildren
label var anychildren "Whether has any children (bio or non-bio) (age 26)"
fre anychildren

cap drop children_tot
gen children_tot=biochild_tot + nonbiochild_tot
label define children_tot 0 "No children (biological or non-biological)" -100 "no participation in sweep" -99 "information not provided", replace
label values children_tot children_tot
label var children_tot "Number of children (bio or non-bio) (age 26)"
fre children_tot




***COMPUTE youngest and oldest biological or non-biological children (age 26)

//create temporary recoded variables 
foreach X of varlist biochildy_eldest nonbiochildy_eldest biochildy_youngest nonbiochildy_youngest {
cap drop `X'_R
clonevar `X'_R = `X'
replace `X'_R=. if `X'_R==-10	
fre `X'_R
}

cap drop childy_eldest //years
gen childy_eldest = max(biochildy_eldest_R, nonbiochildy_eldest_R)
replace childy_eldest=-10 if anybiochildren==0 & anynonbio==0
replace childy_eldest=. if (BCSAGE26SURVEY==.)
replace childy_eldest=. if childy_eldest==30 //one child (this is a biological child) is age 37 which cannot be right so coded as missing
label define childy_eldest -10 "No children (biological or non-biological)" -100 "no participation in sweep" -99 "information not provided", replace
label values childy_eldest childy_eldest
label var childy_eldest "Age in years of eldest child (biological or non-biological)"
fre childy_eldest

cap drop childy_youngest //years
gen childy_youngest = min(biochildy_youngest_R, nonbiochildy_youngest_R)
replace childy_youngest=-10 if anybiochildren==0 & anynonbio==0
replace childy_youngest=. if (BCSAGE26SURVEY==.)
label define childy_youngest -10 "No children (biological or non-biological)" -100 "no participation in sweep" -99 "information not provided", replace
label values childy_youngest childy_youngest
label var childy_youngest "Age in years of youngest child (biological or non-biological)"
fre childy_youngest

drop biochildy_eldest_R nonbiochildy_eldest_R biochildy_youngest_R nonbiochildy_youngest_R



***COMPUTE total number of male biological or non-biological children (age 26)
foreach X of varlist biochildboy_total biochildgirl_total nonbiochildboy_total nonbiochildgirl_total {
cap drop `X'_R
clonevar `X'_R = `X'
replace `X'_R=0 if `X'_R==-10	
}

fre biochildboy_total_R biochildgirl_total_R nonbiochildboy_total_R nonbiochildgirl_total_R

cap drop childboy_total
gen childboy_total = biochildboy_total_R + nonbiochildboy_total_R
replace childboy_total=-10 if anybiochildren==0 & anynonbio==0  //no bio or non-bio children
replace childboy_total=. if anybiochildren==.|anynonbio==.  //no bio or non-bio children
replace childboy_total=. if (BCSAGE26SURVEY==.)
label define childboy_total 0 "Girls only" -10 "No children (biological or non-biological)" -100 "no participation in sweep" -99 "information not provided", replace
drop biochildboy_total_R  nonbiochildboy_total_R
label values childboy_total childboy_total
label var childboy_total "Total number of children who are boys (biological or non-biological)"
fre childboy_total 


cap drop childgirl_total
gen childgirl_total = biochildgirl_total_R + nonbiochildgirl_total_R
replace childgirl_total=-10 if anybiochildren==0 & anynonbio==0  //no bio or non-bio children
replace childgirl_total=. if anybiochildren==.|anynonbio==.  //no bio or non-bio children
replace childgirl_total=. if (BCSAGE26SURVEY==.)
label define childgirl_total 0 "Boys only" -10 "No children (biological or non-biological)" -100 "no participation in sweep" -99 "information not provided", replace
drop biochildgirl_total_R  nonbiochildgirl_total_R
label values childgirl_total childgirl_total
label var childgirl_total "Total number of children who are girls (biological or non-biological)"
fre childgirl_total 





***************** PARTNER AND CHILD COMBO (age 26) ******************

//partner and biological children (age 26)
cap drop partnerchildbio
gen partnerchildbio=.
replace partnerchildbio=1 if anybiochildren==0 & partner==0 //no partner and no children
replace partnerchildbio=2 if anybiochildren==0 & partner==1 //partner but no children
replace partnerchildbio=3 if anybiochildren==1 & partner==0 //no partner but children
replace partnerchildbio=4 if anybiochildren==1 & partner==1 //partner and children
label define partnerchildbio 1 "No partner or children" 2 "Partner and no children" 3 "Children and no partner" 4 "Partner and children" -100 "no participation in sweep" -99 "information not provided", replace
label values partnerchildbio partnerchildbio
label var partnerchildbio "Whether has partner and/or any bio children (age 26)"
fre partnerchildbio

//partner and any bio or nonbio children (age 26)
cap drop partnerchildany
gen partnerchildany=.
replace partnerchildany=1 if anychildren==0 & partner==0 //no partner and no children
replace partnerchildany=2 if anychildren==0 & partner==1 //partner but no children
replace partnerchildany=3 if anychildren==1 & partner==0 //no partner but children
replace partnerchildany=4 if anychildren==1 & partner==1 //partner and children
label define partnerchildany 1 "No partner or children" 2 "Partner and no children" 3 "Children and no partner" 4 "Partner and children" -100 "no participation in sweep" -99 "information not provided", replace
label values partnerchildany partnerchildany
label var partnerchildany "Whether has partner and/or any bio or non-bio children (age 26)"
fre partnerchildany


clonevar BCSID=bcsid
 
order bcsid BCSID BCSAGE26SURVEY partner marital anybiochildren biochild_tot biochildhh_total biochildnonhh_total anynonbio nonbiochild_tot adopt_tot foster_tot step_tot anychildren children_tot partnerchildbio partnerchildany 



//add suffix _26 to denote varabels are from age 26 sweep
foreach var of varlist _all {	
rename `var' `var'_26		
if inlist("`var'", "skip_bcsid") {				
}
}
rename bcsid_26 bcsid
rename BCSID_26 BCSID


save "$derived\BCS70_fertility_age26.dta", replace
use "$derived\BCS70_fertility_age26.dta", clear






        

**# Bookmark #2
*******************************************************************************
****************************** AGE 30 ***************************************** 
*******************************************************************************
//N=11,261
//note: asks about all pregnancies ever.
//note: we do not know the biological child's household grid number at age 30
	
use "$raw\bcs2000.dta", clear
keep bcsid intdate dmsex marstat2 dmsppart othrela hhsize everpreg prega prega2 prega3 prega4 prega5 prega6 prega7 prega8 prega11 prega12 prega16 prega17 prega21 prega22 prega23 prega26 prega27 prega31 prega36 pregc pregc2 pregc3 pregc4 pregc5 pregc6 pregc7 pregc8 pregc11 pregc12 pregc16 pregc17 pregc21 pregc22 pregc23 pregc26 pregc27 pregc31 pregc36 pregem pregem2 pregem3 pregem4 pregem5 pregem6 pregem7 pregem8 pregem11 pregem12 pregem16 pregem17 pregem21 pregem22 pregem23 pregem26 pregem27 pregem31 pregem36 pregey pregey2 pregey3 pregey4 pregey5 pregey6 pregey7 pregey8 pregey11 pregey12 pregey16 pregey17 pregey21 pregey22 pregey23 pregey26 pregey27 pregey31 pregey36 prege prege2 prege3 prege4 prege5 prege6 prege7 prege8 prege11 prege12 prege16 prege17 prege21 prege22 prege23 prege26 prege27 prege31 prege36 whopara whopara2 whopara3 whopara4 whopara5 whopara6 whopara7 whopara8 whopar12 whopar14 whopar22 whopar24 whopar32 whopar34 whopar36 whopar42 whopar44 whopar52 whopar62 wherkid wherkid2 wherkid3 wherkid4 wherkid5 wherkid6 wherkid7 wherkid8 wherki11 wherki12 wherki16 wherki17 wherki21 wherki22 wherki23 wherki26 wherki27 wherki31 wherki36 reltoke2 reltoke3 reltoke4 reltoke5 reltoke6 reltoke7 reltoke8 reltoke9 reltok10 age2 age3 age4 age5 age6 age7 age8 age9 age10 sex2 sex3 sex4 sex5 sex6 sex7 sex8 sex9 sex10 numadch anychd chd16f chd13f chdage3 chdage4 chd5_16 chd16 chd0_6 ownchild 


gen BCSAGE30SURVEY=1
label var BCSAGE30SURVEY "Whether took part in age 30 survey"


*interview date (age 30)
fre intdate

cap drop intyear
gen intyear = real(substr(intdate, -4, 4))
label var intyear "Interview year (age 30)"
label define intyear -100 "no participation in sweep" -99 "information not provided", replace
label values intyear intyear
fre intyear

cap drop intmonth
gen intmonth = real(substr(intdate, -6, 2))
label var intmonth "Interview month (age 30)"
label define intmonth 1 "January" 2	"February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "	October" 11 "November" 12 "December" -100 "no participation in sweep" -99 "information not provided", replace
label values intmonth intmonth
fre intmonth


//whether has a partner or spouse living in household (age 30)
fre dmsppart
recode dmsppart (2=0 "No") (1=1 "Yes"), gen(partner)
label var partner "Whether CM has current partner in hhld (age 30)"
label define partner 0 "No" 1 "Yes" -100 "no participation in sweep" -99 "information not provided", replace
label values partner partner
fre partner
drop dmsppart

fre othrela

//marital status (age 30)
fre marstat2
cap drop marital
gen marital=.
replace marital=3 if marstat2==1|marstat2==4|marstat2==5|marstat2==6
replace marital=2 if (marstat2==1|marstat2==4|marstat2==5|marstat2==6) & partner==1
replace marital=1 if marstat2==2|marstat2==3
label define marital 3 "Single non-cohabiting" 2 "Single cohabiting with partner" 1 "Married" -100 "no participation in sweep" -99 "information not provided", replace
label values marital marital
label variable marital "Marital status (age 30)" 
fre marital


//renaming hh grid variables (age 30)
rename (reltoke2 reltoke3 reltoke4 reltoke5 reltoke6 reltoke7 reltoke8 reltoke9 reltok10) (hhrel2 hhrel3 hhrel4 hhrel5 hhrel6 hhrel7 hhrel8 hhrel9 hhrel10)
rename (age2 age3 age4 age5 age6 age7 age8 age9 age10) (hhage2 hhage3 hhage4 hhage5 hhage6 hhage7 hhage8 hhage9 hhage10)
rename (sex2 sex3 sex4 sex5 sex6 sex7 sex8 sex9 sex10) (hhsex2 hhsex3 hhsex4 hhsex5 hhsex6 hhsex7 hhsex8 hhsex9 hhsex10)





//RENAMING PREGNANCY DATA VARIABLES (age 30)

//renaming baby 1 variables 
foreach X of varlist prega pregc pregem pregey prege whopara wherkid {
	rename	`X' `X'1
	} 

//RENAMING VARIABLES TO PREGNANCY AND BABY ORDER (system is pregnancy 1 baby 1=11, pregnancy 1 baby 2=12 (i.e.twins), pregnancy 2 baby 1=21, etc)

//outcome of pregnancy (age 30)
rename (prega1 prega2 prega3 prega4 prega5 prega6 prega7 prega8 prega11 prega12 prega16 prega17 prega21 prega22 prega23 prega26 prega27 prega31 prega36) (prego11 prego12 prego13 prego14 prego15 prego21 prego22 prego23 prego31 prego32 prego41 prego42 prego51 prego52 prego53 prego61 prego62 prego71 prego81)

//child's sex (age 30)
rename (pregc1 pregc2 pregc3 pregc4 pregc5 pregc6 pregc7 pregc8 pregc11 pregc12 pregc16 pregc17 pregc21 pregc22 pregc23 pregc26 pregc27 pregc31 pregc36) (pregs11 pregs12 pregs13 pregs14 pregs15 pregs21 pregs22 pregs23 pregs31 pregs32 pregs41 pregs42 pregs51 pregs52 pregs53 pregs61 pregs62 pregs71 pregs81)

//month of birth (age 30)
rename (pregem1 pregem2 pregem3 pregem4 pregem5 pregem6 pregem7 pregem8 pregem11 pregem12 pregem16 pregem17 pregem21 pregem22 pregem23 pregem26 pregem27 pregem31 pregem36) (pregm11 pregm12 pregm13 pregm14 pregm15 pregm21 pregm22 pregm23 pregm31 pregm32 pregm41 pregm42 pregm51 pregm52 pregm53 pregm61 pregm62 pregm71 pregm81)

//year of birth (age 30)
rename (pregey1 pregey2 pregey3 pregey4 pregey5 pregey6 pregey7 pregey8 pregey11 pregey12 pregey16 pregey17 pregey21 pregey22 pregey23 pregey26 pregey27 pregey31 pregey36) (pregy11 pregy12 pregy13 pregy14 pregy15 pregy21 pregy22 pregy23 pregy31 pregy32 pregy41 pregy42 pregy51 pregy52 pregy53 pregy61 pregy62 pregy71 pregy81)
	
//date of birth (day.month.year) (age 30)
rename (prege1 prege2 prege3 prege4 prege5 prege6 prege7 prege8 prege11 prege12 prege16 prege17 prege21 prege22 prege23 prege26 prege27 prege31 prege36) (pregdmy11 pregdmy12 pregdmy13 pregdmy14 pregdmy15 pregdmy21 pregdmy22 pregdmy23 pregdmy31 pregdmy32 pregdmy41 pregdmy42 pregdmy51 pregdmy52 pregdmy53 pregdmy61 pregdmy62 pregdmy71 pregdmy81)
	
//whether current partner is child's other parent (age 30)
rename (whopara1 whopara2 whopara3 whopara4 whopara5 whopara6 whopara7 whopara8 whopar12 whopar14 whopar22 whopar24 whopar32 whopar34 whopar36 whopar42 whopar44 whopar52 whopar62) (pregpar11 pregpar12 pregpar13 pregpar14 pregpar15 pregpar21 pregpar22 pregpar23 pregpar31 pregpar32 pregpar41 pregpar42 pregpar51 pregpar52 pregpar53 pregpar61 pregpar62 pregpar71 pregpar81)
fre pregpar11 pregpar12 pregpar13 pregpar14 pregpar15 pregpar21 pregpar22 pregpar23 pregpar31 pregpar32 pregpar41 pregpar42 pregpar51 pregpar52 pregpar53 pregpar61 pregpar62 pregpar71 pregpar81

//where child lives	(age 30)
rename (wherkid1 wherkid2 wherkid3 wherkid4 wherkid5 wherkid6 wherkid7 wherkid8 wherki11 wherki12 wherki16 wherki17 wherki21 wherki22 wherki23 wherki26 wherki27 wherki31 wherki36) (preghh11 preghh12 preghh13 preghh14 preghh15 preghh21 preghh22 preghh23 preghh31 preghh32 preghh41 preghh42 preghh51 preghh52 preghh53 preghh61 preghh62 preghh71 preghh81)



*-------------------------------------------------------------------*

//ever pregnant (age 30)
fre everpreg
replace everpreg=. if everpreg>2
replace everpreg=0 if everpreg==2
fre everpreg


*RECODE variables to missing if not a live birth (age 30)
foreach C in 11 12 13 14 15 21 22 23 31 32 41 42 51 52 53 61 62 71 81 {
foreach X of varlist pregs`C' pregm`C' pregy`C' pregpar`C' preghh`C' {

replace	`X'=. if prego`C'!=1

replace prego`C'=. if prego`C'!=1|everpreg==.
label define prego`C' 1 "Live birth", replace
label values prego`C' prego`C'
fre pregs`C' pregm`C' pregy`C' pregpar`C' preghh`C'

//recode to missing and other adjustments (age 30)
replace	pregs`C'=. if pregs`C'==9|pregs`C'==.|everpreg==. //sex 1=boy 2=girl
replace	pregm`C'=. if pregm`C'>12 //we keep missing as (.) data for month of birth
replace	pregy`C'=. if pregy`C'==9998|pregy`C'==9999 //we keep missing data as (.) for year of birth
replace	pregpar`C'=. if pregpar`C'==8|pregpar`C'==9|everpreg==. //other parent 1=current partner 2=not current partner
replace	pregpar`C'=2 if partner==0 & othrela==2 & prego`C'==1 //recoding other parent to not current partner if there is no current partner in HH and no other non-resident partner
replace	preghh`C'=. if preghh`C'==8|preghh`C'==9|preghh`C'==.|everpreg==. //whether in household

fre prego`C' pregs`C' pregm`C' pregy`C' pregpar`C' preghh`C'

}
}




******************************************************************
****BIOLOGICAL CHILDREN (age 30)********************************* 
******************************************************************

***COMPUTE whether ever had any biological children (live births) (age 30)
cap drop anybiochildren
egen anybiochildren=anycount(prego11 prego12 prego13 prego14 prego15 prego21 prego22 prego23 prego31 prego32 prego41 prego42 prego51 prego52 prego53 prego61 prego62 prego71 prego81), values(1)
replace anybiochildren=1 if inrange(anybiochildren,1,20)
replace anybiochildren=. if everpreg==.
label variable anybiochildren "Whether CM has had any biological children"
label define yesno 0 "No" 1 "Yes" -100 "no participation in sweep" -99 "information not provided", replace
label values anybiochildren yesno
fre anybiochildren 

***COMPUTE total number of biological children (age 30)
cap drop biochild_tot
egen biochild_tot =anycount(prego11 prego12 prego13 prego14 prego15 prego21 prego22 prego23 prego31 prego32 prego41 prego42 prego51 prego52 prego53 prego61 prego62 prego71 prego81), values(1)
replace biochild_tot=. if everpreg==.
label define biochild_tot 0 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values biochild_tot biochild_tot
label variable biochild_tot "Total number of biological children"
fre biochild_tot



*-------------------------------------------------------------------*
*** WHERE BIOLOGICAL CHILDREN LIVE (age 30)
//preghh: 1=living with CM 2=living elsewhere 3=child not living


***COMPUTE total number of biological children not in household (=2) (age 30)
cap drop biochildnonhh_total
egen biochildnonhh_total = anycount(preghh11 preghh12 preghh13 preghh14 preghh15 preghh21 preghh22 preghh23 preghh31 preghh32 preghh41 preghh42 preghh51 preghh52 preghh53 preghh61 preghh62 preghh71 preghh81), values(2)
replace biochildnonhh_total=. if everpreg==.
replace biochildnonhh_total=-10 if anybiochildren==0
label variable biochildnonhh_total "Total number of bio children not in household"
fre biochildnonhh_total
label define biochildnonhh_total 0 "All biological children live in household" -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildnonhh_total biochildnonhh_total
fre biochildnonhh_total

***COMPUTE total number of biological children living in household (=1) (age 30)
cap drop biopreghh_total
egen biopreghh_total = anycount(preghh11 preghh12 preghh13 preghh14 preghh15 preghh21 preghh22 preghh23 preghh31 preghh32 preghh41 preghh42 preghh51 preghh52 preghh53 preghh61 preghh62 preghh71 preghh81), values(1)
replace biopreghh_total=. if everpreg==.
label variable biopreghh_total "Total number of bio children in household (pregnancy data)"
fre biopreghh_total
label values biopreghh_total biopreghh_total
fre biopreghh_total




*****************************************************************
*** ADJUSTING FOR NUMBER OF EXTRA BIOLOGICAL CHILDREN IN HOUSEHOLD NOT REPORTED AS PREGNANCY (age 30)
*****************************************************************

foreach C in 2 3 4 5 6 7 8 9 10 {
*biological child in hh grid
cap drop biochildhh`C'
gen biochildhh`C'=0
replace biochildhh`C'=1 if hhrel`C'==3
label define biochildhh`C' 1 "biological child", replace
label values biochildhh`C' biochildhh`C'
label var biochildhh`C' "`C' is a hh biological child"
fre biochildhh`C'
}

***COMPUTE total number of biological children reported in hh grid (age 30)
cap drop biochildhh_total
gen biochildhh_total=biochildhh2 +biochildhh3 +biochildhh4 +biochildhh5 +biochildhh6 +biochildhh7 +biochildhh8 +biochildhh9 +biochildhh10
replace biochildhh_total=.  if hhsize==.
replace biochildhh_total=. if   anybiochildren==. 
label variable biochildhh_total "Total number of bio children in household (HH grid data)"
fre biochildhh_total

clonevar biohhgrid_total = biochildhh_total //creating a variable for the original hhgrid total number of bio children




//computing difference in pregnancy data and household data (age 30)

cap drop biochild_tot_miss
gen biochild_tot_miss=1 if biochild_tot==. //this creates a missing values flag for this variable

replace biochild_tot=0 if biochild_tot==. // this bit is important as crucial for the inclusion of all HH grid data in adjustments for extra children 

fre biochild_tot biochildhh_total
tab biochild_tot biochildhh_total, mi
cap drop difference
gen difference=biochild_tot - biochildhh_total
//replace difference=-10 if anybiochildren==0
fre difference

//creating a variable that flags CMs with differences
cap drop biochild_extra_flag
gen biochild_extra_flag=.
label var biochild_extra_flag "Flag: More bio children reported in HH grid than in pregnancy data"
replace biochild_extra_flag=1 if inrange(difference, -5,-1)
replace biochild_extra_flag=0 if inrange(difference, 0,20)
label define biochild_extra_flag 1 "Yes" 0 "No" -100 "no participation in sweep" -99 "information not provided", replace
label values biochild_extra_flag biochild_extra_flag

fre biochild_extra_flag

//creating variable to use for adjustment of total children
cap drop bioextra
gen bioextra=difference
replace bioextra=0 if inrange(difference,0,10)
replace bioextra=1 if difference==-1
replace bioextra=2 if difference==-2
replace bioextra=3 if difference==-3
replace bioextra=4 if difference==-4
replace bioextra=5 if difference==-5
replace bioextra=6 if difference==-6
replace bioextra=7 if difference==-7
fre bioextra



******ADJUSTING (age 30)
cap drop bioextra_miss
gen bioextra_miss=1 if bioextra==. //missing values flag 
fre bioextra_miss
replace bioextra=0 if bioextra==.

fre biochild_tot_miss //already created a missing flag for this

//TOTAL NUMBER OF CHILDREN (age 30)
fre biochild_tot bioextra
replace biochild_tot=biochild_tot + bioextra
replace biochild_tot=. if biochild_tot_miss== 1 //& bioextra_miss==1
fre biochild_tot

//ANY BIO CHILDREN (age 30)
cap drop anybiochildren
gen anybiochildren=.
replace anybiochildren=1 if inrange(biochild_tot,1,20)
replace anybiochildren=0 if biochild_tot==0
label define yesno 0 "No" 1 "Yes" -100 "no participation in sweep" -99 "information not provided", replace
label values anybiochildren yesno
fre anybiochildren

//WHERE LIVE (age 30)
fre biopreghh_total biochildhh_total
cap drop biohh_total
gen biohh_total=.
replace biohh_total=biopreghh_total if biopreghh_total==biochildhh_total
replace biohh_total=biochildhh_total if biohh_total==.
replace biohh_total=biopreghh_total if biohh_total==.
fre biohh_total
drop biochildhh_total
rename biohh_total biochildhh_total
label variable biochildhh_total "Total number of bio children in household"
replace biochildhh_total=-10 if anybiochildren==0
replace biochildhh_total=. if anybiochildren==.
label define biochildhh_total 0 "None of the biological children live in household" -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildhh_total biochildhh_total
fre biochildhh_total

cap drop biochildnonhh_total
gen biochildnonhh_total= biochild_tot-biochildhh_total 
replace biochildnonhh_total=-10 if anybiochildren==0
label variable biochildnonhh_total "Total number of bio children not in household"
fre biochildnonhh_total
label define biochildnonhh_total 0 "All biological children live in household" -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildnonhh_total biochildnonhh_total
fre biochildnonhh_total




*****************************************************************
*** OTHER PARENT OF BIOLOGICAL CHILDREN (age 30)
*****************************************************************
//pregpar: 1=yes 2=no //current partner is child's other parent

***COMPUTE number of biological children whose parent is previous partner (age 30)
cap drop biochildprev_total
egen biochildprev_total = anycount(pregpar11 pregpar12 pregpar13 pregpar14 pregpar15 pregpar21 pregpar22 pregpar23 pregpar31 pregpar32 pregpar41 pregpar42 pregpar51 pregpar52 pregpar53 pregpar61 pregpar62 pregpar71 pregpar81), values(2)
replace biochildprev_total=. if anybiochildren==. 
replace biochildprev_total=-10 if anybiochildren==0 //no children
label define biochildprev_total 0 "Current partner is parent to all biological children" -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildprev_total biochildprev_total
label variable biochildprev_total "Total number of biological children had with a previous partner"
fre biochildprev_total

//whether a previous partner is parent to any children (age 30)
cap drop biochildprevany
gen biochildprevany=.
replace biochildprevany=1 if inrange(biochildprev_total,1,10)
replace biochildprevany=0 if biochildprev_total==0
replace biochildprevany=-10 if biochildprev_total==-10
label variable biochildprevany "Any children with a previous partner"
label define biochildprevany 1 "Previous partner(s) parent to all or some biological children" 0 "Current partner is parent to all biological children" -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildprevany biochildprevany
fre biochildprevany





*************************************************************
*** SEX OF BIOLOGICAL CHILDREN (age 30)
*************************************************************

//PREGNANCY DATA (age 30)

//sex 1=boy 2=girl

***COMPUTE total number of biological boy and girl children (age 30)
cap drop biochildboy_total
egen biochildboy_total = anycount(pregs11 pregs12 pregs13 pregs14 pregs15 pregs21 pregs22 pregs23 pregs31 pregs32 pregs41 pregs42 pregs51 pregs52 pregs53 pregs61 pregs62 pregs71 pregs81), values(1)
replace biochildboy_total=. if everpreg==.
replace biochildboy_total=-10 if anybiochildren==0 //no children
label define biochildboy_total 0 "Girls only" -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values biochildboy_total biochildboy_total
label var biochildboy_total "Total number of biological children who are boys"
fre biochildboy_total 

cap drop biochildgirl_total
egen biochildgirl_total = anycount(pregs11 pregs12 pregs13 pregs14 pregs15 pregs21 pregs22 pregs23 pregs31 pregs32 pregs41 pregs42 pregs51 pregs52 pregs53 pregs61 pregs62 pregs71 pregs81), values(2)
replace biochildgirl_total=. if everpreg==.
replace biochildgirl_total=-10 if anybiochildren==0 //no children
label define biochildgirl_total 0 "Boys only" -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values biochildgirl_total biochildgirl_total
label var biochildgirl_total "Total number of biological children who are girls"
fre biochildgirl_total 



*----------------------------------------------------------*
******ADJUSTING PREVIOUS VARIABLES ADDING THE EXTRA GIRLS AND BOYS IDENTIFIED IN HH GRID BUT NOT INCLUDED IN PREGNANCY DATA (age 30)

foreach C in 2 3 4 5 6 7 8 9 10 {

*sex of biological hh children (age 30)
cap drop biochildhhboy`C'
gen biochildhhboy`C'=0
replace biochildhhboy`C'=1 if hhsex`C'==1 & hhrel`C'==3
label define biochildhhboy`C' 1 "Boy", replace
label values biochildhhboy`C' biochildhhboy`C'
label var biochildhhboy`C' "`C' hh biological child is a boy"
fre biochildhhboy`C'

cap drop biochildhhgirl`C'
gen biochildhhgirl`C'=0
replace biochildhhgirl`C'=1 if hhsex`C'==2 & hhrel`C'==3
label define biochildhhgirl`C' 1 "girl", replace
label values biochildhhgirl`C' biochildhhgirl`C'
label var biochildhhgirl`C' "`C' hh biological child is a girl"
fre biochildhhgirl`C'
}


***COMPUTE total number of biological girls and boys reported in hh grid (age 30)
cap drop biochildhhboy_total
gen biochildhhboy_total=biochildhhboy2 +biochildhhboy3 +biochildhhboy4 +biochildhhboy5 +biochildhhboy6 +biochildhhboy7 +biochildhhboy8 +biochildhhboy9 +biochildhhboy10
replace biochildhhboy_total=.  if hhsize==.
replace biochildhhboy_total=.  if anybiochildren==.
label variable biochildhhboy_total "Total number of bio boys in household (HH grid data)"
fre biochildhhboy_total

cap drop biochildhhgirl_total
gen biochildhhgirl_total=biochildhhgirl2 +biochildhhgirl3 +biochildhhgirl4 +biochildhhgirl5 +biochildhhgirl6 +biochildhhgirl7 +biochildhhgirl8 +biochildhhgirl9 +biochildhhgirl10
replace biochildhhgirl_total=.  if hhsize==.
replace biochildhhgirl_total=.  if anybiochildren==.
label variable biochildhhgirl_total "Total number of bio girls in household (HH grid data)"
fre biochildhhgirl_total



//computing difference in pregnancy data and household data (age 30)
fre biochildboy_total biochildgirl_total //pregnancies
fre biochildhhboy_total biochildhhgirl_total //hh grid

cap drop biochildboy_tot_miss
gen biochildboy_tot_miss=1 if biochildboy_total==. //this creates a missing values flag for this variable
cap drop biochildgirl_tot_miss
gen biochildgirl_tot_miss=1 if biochildgirl_total==. //this creates a missing values flag for this variable

replace biochildboy_total=0 if biochildboy_total==.|biochildboy_total==-10 // this bit is important as crucial for the inclusion of all HH grid data in adjustments for extra children 
replace biochildgirl_total=0 if biochildgirl_total==.|biochildgirl_total==-10 // this bit is important as crucial for the inclusion of all HH grid data in adjustments for extra children 

fre biochildboy_total biochildhhboy_total
tab biochildboy_total biochildhhboy_total, mi
cap drop diff_boy
gen diff_boy=biochildboy_total - biochildhhboy_total
fre diff_boy

fre biochildgirl_total biochildhhgirl_total
tab biochildgirl_total biochildhhgirl_total, mi
cap drop diff_girl
gen diff_girl=biochildgirl_total - biochildhhgirl_total
fre diff_girl

//creating a variable that flags CMs with differences (age 30)
cap drop bioboy_extra_flag
gen bioboy_extra_flag=.
label var bioboy_extra_flag "Flag: More bio boys reported in HH grid than in pregnancy data"
replace bioboy_extra_flag=1 if inrange(diff_boy, -5,-1)
fre bioboy_extra_flag //applies to 65 

cap drop biogirl_extra_flag
gen biogirl_extra_flag=.
label var biogirl_extra_flag "Flag: More bio girls reported in HH grid than in pregnancy data"
replace biogirl_extra_flag=1 if inrange(diff_girl, -5,-1)
fre biogirl_extra_flag //applies to 71 
 

//creating variable to use for adjustment of total boys and girls (age 30)
cap drop bioextraboy
gen bioextraboy=difference
replace bioextraboy=0 if inrange(diff_boy,0,10)
replace bioextraboy=1 if diff_boy==-1
replace bioextraboy=2 if diff_boy==-2
replace bioextraboy=3 if diff_boy==-3
replace bioextraboy=4 if diff_boy==-4
replace bioextraboy=5 if diff_boy==-5
replace bioextraboy=6 if diff_boy==-6
replace bioextraboy=7 if diff_boy==-7
fre bioextraboy

cap drop bioextragirl
gen bioextragirl=difference
replace bioextragirl=0 if inrange(diff_girl,0,10)
replace bioextragirl=1 if diff_girl==-1
replace bioextragirl=2 if diff_girl==-2
replace bioextragirl=3 if diff_girl==-3
replace bioextragirl=4 if diff_girl==-4
replace bioextragirl=5 if diff_girl==-5
replace bioextragirl=6 if diff_girl==-6
replace bioextragirl=7 if diff_girl==-7
fre bioextragirl


******ADJUSTING (age 30)

//first doing some missing value flags
cap drop bioextraboy_miss
gen bioextraboy_miss=1 if bioextraboy==. //missing values flag 
fre bioextraboy_miss
replace bioextraboy=0 if bioextraboy==.

cap drop bioextragirl_miss
gen bioextragirl_miss=1 if bioextragirl==. //missing values flag 
fre bioextragirl_miss
replace bioextragirl=0 if bioextragirl==.

fre biochildboy_tot_miss //already created a missing flag for this
fre biochildgirl_tot_miss //already created a missing flag for this


//TOTAL NUMBER OF BOYS AND GIRLS (age 30)
fre biochildboy_total bioextraboy
replace biochildboy_total=biochildboy_total + bioextraboy
replace biochildboy_total=. if biochildboy_tot_miss== 1 
replace biochildboy_total=-10 if biochild_tot==0
replace biochildboy_total=. if anybiochildren==.
fre biochildboy_total

fre biochildgirl_total bioextragirl
replace biochildgirl_total=biochildgirl_total + bioextragirl
replace biochildgirl_total=. if biochildgirl_tot_miss== 1 
replace biochildgirl_total=-10 if biochild_tot==0
replace biochildgirl_total=. if anybiochildren==.
fre biochildgirl_total





*************************************************************
*** AGES OF BIOLOGICAL CHILDREN AND COHORT MEMBER AGE AT BIRTH (age 30)
*************************************************************

***COMPUTE current age in whole years of each biochild from birth year and month, and interview month and year. And age of cohort member at birth of child in whole years (age 30).

//interview date (age 30)
fre intyear
fre intmonth
cap drop intym
gen intym = ym(intyear,intmonth)
label var intym "Interview date - months since Jan 1960"
fre intym

//cohort member birthdate (age 30)
cap drop cmbirthy
gen cmbirthy=1970
label var cmbirthy "Birth year of CM"
fre cmbirthy

cap drop cmbirthm
gen cmbirthm=4
label var cmbirthm "Birth month of CM"
fre cmbirthm

cap drop cmbirthym
gen cmbirthym = ym(cmbirthy,cmbirthm)
label var cmbirthym "CM birth date - months since Jan 1960"
fre cmbirthym

//CM age in years (age 30)
cap drop cmagey
gen cmagey=(intym-cmbirthym)/12
replace cmagey = floor(cmagey)
fre cmagey 
label var cmagey "CM age at interview"



foreach C in 11 12 13 14 15 21 22 23 31 32 41 42 51 52 53 61 62 71 81 {

fre pregy`C'
fre pregm`C'
cap drop biochildym`C'
gen biochildym`C' = ym(pregy`C',pregm`C') 
label var biochildym`C' "`C' Date of birth of biological child - months since Jan 1960"
fre biochildym`C'

//child's age in whole years at interview (age 30)
cap drop biochildagey`C'
gen biochildagey`C' = (intym-biochildym`C')/12
fre biochildagey`C'
replace biochildagey`C' = floor(biochildagey`C')
label var biochildagey`C' "`C' Age in whole years of biological child"
fre biochildagey`C'

//cm age in whole years at birth of child (age 30)
cap drop cmageybirth`C'
gen cmageybirth`C' = (biochildym`C'-cmbirthym)/12
fre cmageybirth`C'
replace cmageybirth`C' = floor(cmageybirth`C')
label var cmageybirth`C' "`C' Age of CM in years at birth of biological child `C'"
fre cmageybirth`C'

}



*----------------------------------------------------------*
******VARIABLES FOR AGES OF EXTRA CHILDREN IDENTIFIED IN HH GRID BUT NOT INCLUDED IN PREGNANCY DATA (age 30)

*ages of extra children in hh (age 30)
foreach C in 2 3 4 5 6 7 8 9 10 {
cap drop biohhage`C' //coded 0 or 1
gen biohhage`C'=.
replace biohhage`C'=hhage`C' if hhrel`C'==3 & biochild_extra_flag==1
label var biohhage`C' "`C' hh biological child age"
fre biohhage`C'
}

*----------------------------------------------------------*
***COMPUTE age of eldest and youngest child in years (age 30)
cap drop biochildy_eldest //years
gen biochildy_eldest = max(biochildagey11, biochildagey12, biochildagey13, biochildagey14, biochildagey15, biochildagey21, biochildagey22, biochildagey23, biochildagey31, biochildagey32, biochildagey41, biochildagey42, biochildagey51, biochildagey52, biochildagey53, biochildagey61, biochildagey62, biochildagey71, biochildagey81,biohhage2,biohhage3,biohhage4,biohhage5,biohhage6,biohhage7,biohhage8,biohhage9,biohhage10)
replace biochildy_eldest=-10 if anybiochildren==0
replace biochildy_eldest=. if biochild_tot_miss== 1 
label define biochildy_eldest -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildy_eldest biochildy_eldest
label var biochildy_eldest "Age in years of eldest biological child"
fre biochildy_eldest

cap drop biochildy_youngest //years
gen biochildy_youngest = max(biochildagey11, biochildagey12, biochildagey13, biochildagey14, biochildagey15, biochildagey21, biochildagey22, biochildagey23, biochildagey31, biochildagey32, biochildagey41, biochildagey42, biochildagey51, biochildagey52, biochildagey53, biochildagey61, biochildagey62, biochildagey71, biochildagey81,biohhage2,biohhage3,biohhage4,biohhage5,biohhage6,biohhage7,biohhage8,biohhage9,biohhage10)
replace biochildy_youngest=-10 if anybiochildren==0
replace biochildy_youngest=. if biochild_tot_miss== 1 
label define biochildy_eldest -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildy_youngest biochildy_eldest
label var biochildy_youngest "Age in years of youngest biological child"
fre biochildy_youngest 




*----------------------------------------------------------*
******VARIABLES FOR AGES OF CM AT BIRTH OF EXTRA CHILDREN IDENTIFIED IN HH GRID BUT NOT INCLUDED IN PREGNANCY DATA (age 30)

*age of Cm at birth of extra children in hh grid (age 30)
foreach C in 2 3 4 5 6 7 8 9 10 {
cap drop cmagebirth_hhextra`C'
gen cmagebirth_hhextra`C'=cmagey-biohhage`C' if biochild_extra_flag==1
fre cmagebirth_hhextra`C'
}

***COMPUTE age of cohort member at birth of eldest and youngest child in years (age 30)
cap drop cmageybirth_eldest //years
gen cmageybirth_eldest = min(cmageybirth11, cmageybirth12, cmageybirth13, cmageybirth14, cmageybirth15, cmageybirth21, cmageybirth22, cmageybirth23, cmageybirth31, cmageybirth32, cmageybirth41, cmageybirth42, cmageybirth51, cmageybirth52, cmageybirth53, cmageybirth61, cmageybirth62, cmageybirth71, cmageybirth81, cmagebirth_hhextra2,cmagebirth_hhextra3,cmagebirth_hhextra4,cmagebirth_hhextra5,cmagebirth_hhextra6,cmagebirth_hhextra7,cmagebirth_hhextra8,cmagebirth_hhextra9,cmagebirth_hhextra10)
replace cmageybirth_eldest=-10 if anybiochildren==0
replace cmageybirth_eldest=. if biochild_tot_miss== 1
label define cmageybirth_eldest -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values cmageybirth_eldest cmageybirth_eldest
label var cmageybirth_eldest "CM age in years at birth of eldest biological child"
fre cmageybirth_eldest

cap drop cmageybirth_youngest //years
gen cmageybirth_youngest = max(cmageybirth11, cmageybirth12, cmageybirth13, cmageybirth14, cmageybirth15, cmageybirth21, cmageybirth22, cmageybirth23, cmageybirth31, cmageybirth32, cmageybirth41, cmageybirth42, cmageybirth51, cmageybirth52, cmageybirth53, cmageybirth61, cmageybirth62, cmageybirth71, cmageybirth81, cmagebirth_hhextra3,cmagebirth_hhextra4,cmagebirth_hhextra5,cmagebirth_hhextra6,cmagebirth_hhextra7,cmagebirth_hhextra8,cmagebirth_hhextra9,cmagebirth_hhextra10)
replace cmageybirth_youngest=-10 if anybiochildren==0
replace cmageybirth_youngest=. if biochild_tot_miss== 1
fre cmageybirth_youngest
label define cmageybirth_youngest -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values cmageybirth_youngest cmageybirth_youngest
label var cmageybirth_youngest "CM age in years at birth of youngest biological child"
fre cmageybirth_youngest







******************************************************************
**** NON BIOLOGICAL CHILDREN (age 30) *****************************
******************************************************************
//derived from the household grid

*RECODE on non-biological children variables (age 30)
foreach C in 2 3 4 5 6 7 8 9 10 {

*non-biological and type (age 30)
cap drop nonbiochild`C'
gen nonbiochild`C'=.
replace nonbiochild`C'=1 if inrange(hhrel`C',4,7)
label define nonbiochild`C' 1 "Non-biological child", replace
label values nonbiochild`C' nonbiochild`C'
label var nonbiochild`C' "`C' is a non-biological"
fre nonbiochild`C'

cap drop step`C'
gen step`C'=.
replace step`C'=1 if inrange(hhrel`C',5,6)
label define step`C' 1 "Step child", replace
label values step`C' step`C'
label var step`C' "`C' is a stepchild"
fre step`C'

cap drop adopt`C'
gen adopt`C'=.
replace adopt`C'=1 if hhrel`C'==4
label define adopt`C' 1 "Adopted", replace
label values adopt`C' adopt`C'
label var adopt`C' "`C' is adopted"
fre adopt`C'

cap drop foster`C'
gen foster`C'=.
replace foster`C'=1 if hhrel`C'==7
label define foster`C' 1 "foster", replace
label values foster`C' foster`C'
label var foster`C' "`C' is foster"
fre foster`C'

*age of nonbio children (age 30)
cap drop nonbiochildagey`C'
clonevar nonbiochildagey`C' = hhage`C' if inrange(hhrel`C',4,7) & hhage`C'<100 
label var nonbiochildagey`C' "`C' Age in years of non-biological child"
fre nonbiochildagey`C'

*sex of nonbio children (age 30)
cap drop nonbiochildsex`C'
clonevar nonbiochildsex`C' = hhsex`C' if inrange(hhrel`C',4,7)
label var nonbiochildsex`C' "`C' Sex of non-biological child"
fre nonbiochildsex`C'

}

***COMPUTE whether has any non-biologial children (age 30)
cap drop anynonbio
egen anynonbio= anycount(nonbiochild2 nonbiochild3 nonbiochild4 nonbiochild5 nonbiochild6 nonbiochild7 nonbiochild8 nonbiochild9 nonbiochild10), values(1)
replace anynonbio=1 if inrange(anynonbio,1,20)
replace anynonbio=. if hhsize==.
label variable anynonbio "Whether CM has any non-biological children in household"
label define yesno 0 "No" 1 "Yes" -100 "no participation in sweep" -99 "information not provided", replace
label values anynonbio yesno
fre anynonbio 


***COMPUTE total number of non-biologial children in household (age 30)
//number of all non-biological (age 30)
cap drop nonbiochild_tot
egen nonbiochild_tot = anycount(nonbiochild2 nonbiochild3 nonbiochild4 nonbiochild5 nonbiochild6 nonbiochild7 nonbiochild8 nonbiochild9 nonbiochild10), values(1)
replace nonbiochild_tot=. if hhsize==.
label define nonbiochild_tot 0 "No non-biological children in HH" -100 "no participation in sweep" -99 "information not provided", replace 
label values nonbiochild_tot nonbiochild_tot
label variable nonbiochild_tot "Total number of non-biological children in household"
fre nonbiochild_tot

//number of adopted (age 30)
cap drop adopt_tot
egen adopt_tot = anycount(adopt2 adopt3 adopt4 adopt5 adopt6 adopt7 adopt8 adopt9 adopt10), values(1)
replace adopt_tot=. if hhsize==.
label define adopt_tot 0 "No adopted children in HH" -100 "no participation in sweep" -99 "information not provided", replace 
label values adopt_tot adopt_tot
label variable adopt_tot "Total number of adopted children in household"
fre adopt_tot

//number of foster (age 30)
cap drop foster_tot
egen foster_tot = anycount(foster2 foster3 foster4 foster5 foster6 foster7 foster8 foster9 foster10), values(1)
replace foster_tot=. if hhsize==.
label define foster_tot 0 "No foster children in HH" -100 "no participation in sweep" -99 "information not provided", replace 
label values foster_tot foster_tot
label variable foster_tot "Total number of foster children in household"
fre foster_tot

//number of stepchildren (age 30)
cap drop step_tot
egen step_tot = anycount(step2 step3 step4 step5 step6 step7 step8 step9 step10), values(1)
replace step_tot=. if hhsize==.
label define step_tot 0 "No stepchildren in HH" -100 "no participation in sweep" -99 "information not provided", replace 
label values step_tot step_tot
label variable step_tot "Total number of stepchildren in household"
fre step_tot




***COMPUTE age of youngest and oldest non-biological child (age 30)
cap drop nonbiochildy_eldest //years
gen nonbiochildy_eldest = max(nonbiochildagey2, nonbiochildagey3, nonbiochildagey4, nonbiochildagey5, nonbiochildagey6, nonbiochildagey7, nonbiochildagey8, nonbiochildagey9, nonbiochildagey10)
replace nonbiochildy_eldest=. if hhsize==.
replace nonbiochildy_eldest=-10 if anynonbio==0
label define nonbiochildy_eldest -10 "No non-biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values nonbiochildy_eldest nonbiochildy_eldest
label var nonbiochildy_eldest "Age in years of eldest non-biological child"
fre nonbiochildy_eldest

cap drop nonbiochildy_youngest //years
gen nonbiochildy_youngest = min(nonbiochildagey2, nonbiochildagey3, nonbiochildagey4, nonbiochildagey5, nonbiochildagey6, nonbiochildagey7, nonbiochildagey8, nonbiochildagey9, nonbiochildagey10)
replace nonbiochildy_youngest=. if hhsize==.
replace nonbiochildy_youngest=-10 if anynonbio==0
label define nonbiochildy_eldest -10 "No non-biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values nonbiochildy_youngest nonbiochildy_eldest
label var nonbiochildy_youngest "Age in years of youngest non-biological child"
fre nonbiochildy_youngest 



***COMPUTE total number of non-biological boys and girls (age 30)
//nonbiochildsex: 1=boy 2=girl
cap drop nonbiochildboy_total
egen nonbiochildboy_total = anycount(nonbiochildsex2 nonbiochildsex3 nonbiochildsex4 nonbiochildsex5 nonbiochildsex6 nonbiochildsex7 nonbiochildsex8 nonbiochildsex9 nonbiochildsex10), values(1)
replace nonbiochildboy_total=-10 if anynonbio==0 //no non-biologial children
replace nonbiochildboy_total=. if hhsize==.
label define nonbiochildboy_total 0 "Girls only" -10 "No non-biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values nonbiochildboy_total nonbiochildboy_total
label var nonbiochildboy_total "Total number of non-biological children who are boys"
fre nonbiochildboy_total 

cap drop nonbiochildgirl_total
egen nonbiochildgirl_total = anycount(nonbiochildsex2 nonbiochildsex3 nonbiochildsex4 nonbiochildsex5 nonbiochildsex6 nonbiochildsex7 nonbiochildsex8 nonbiochildsex9 nonbiochildsex10), values(2)
replace nonbiochildgirl_total=. if hhsize==.
replace nonbiochildgirl_total=-10 if anynonbio==0 //no non-biologial children
label define nonbiochildgirl_total 0 "Boys only" -10 "No non-biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values nonbiochildgirl_total nonbiochildgirl_total
label var nonbiochildgirl_total "Total number of non-biological children who are girls"
fre nonbiochildgirl_total 






******************************************************************
**** BIOLOGICAL AND non-biological CHILDREN (age 30) **************
******************************************************************

***COMPUTE whether has any biological or non-biological (age 30)
cap drop anychildren
gen anychildren=.
replace anychildren=1 if anynonbio==1|anybiochildren==1
replace anychildren=0 if anynonbio==0 & anybiochildren==0
replace anychildren=. if anybiochildren==.|anynonbio==.
label define anychildren 0 "No" 1 "Yes" -100 "no participation in sweep" -99 "information not provided", replace
label values anychildren anychildren
label var anychildren "Whether CM has any children (biological or non-biological)"
fre anychildren 

***COMPUTE total number of biological and non-biological children (age 30)
cap drop children_tot
gen children_tot=biochild_tot + nonbiochild_tot
fre children_tot
label define children_tot 0 "No children (biological or non-biological)" -100 "no participation in sweep" -99 "information not provided", replace
label values children_tot children_tot
label var children_tot "Total number of children (biological or non-biological)"
fre children_tot



***COMPUTE youngest and oldest biological or non-biological children (age 30)

//create temporary recoded variables 
foreach X of varlist biochildy_eldest nonbiochildy_eldest biochildy_youngest nonbiochildy_youngest {
cap drop `X'_R
clonevar `X'_R = `X'
replace `X'_R=. if `X'_R==-10	
fre `X'_R
}

cap drop childy_eldest //years
gen childy_eldest = max(biochildy_eldest_R, nonbiochildy_eldest_R)
replace childy_eldest=-10 if anybiochildren==0 & anynonbio==0
replace childy_eldest=. if anybiochildren==.|anynonbio==.
label define childy_eldest -10 "No children (biological or non-biological)" -100 "no participation in sweep" -99 "information not provided", replace
label values childy_eldest childy_eldest
label var childy_eldest "Age in years of eldest child (biological or non-biological)"
fre childy_eldest

cap drop childy_youngest //years
gen childy_youngest = min(biochildy_youngest_R, nonbiochildy_youngest_R)
replace childy_youngest=-10 if anybiochildren==0 & anynonbio==0
replace childy_youngest=. if anybiochildren==.|anynonbio==.
label define childy_youngest -10 "No children (biological or non-biological)" -100 "no participation in sweep" -99 "information not provided", replace
label values childy_youngest childy_youngest
label var childy_youngest "Age in years of youngest child (biological or non-biological)"
fre childy_youngest

drop biochildy_eldest_R nonbiochildy_eldest_R biochildy_youngest_R nonbiochildy_youngest_R



***COMPUTE total number of male biological or non-biological children (age 30)
cap drop biochildboy_total_R
clonevar biochildboy_total_R = biochildboy_total 
replace biochildboy_total_R=0 if biochildboy_total==-10
fre biochildboy_total_R

cap drop nonbiochildboy_total_R
clonevar nonbiochildboy_total_R = nonbiochildboy_total 
replace nonbiochildboy_total_R=0 if nonbiochildboy_total==-10
fre nonbiochildboy_total_R

cap drop childboy_total
gen childboy_total = biochildboy_total_R + nonbiochildboy_total_R
drop biochildboy_total_R nonbiochildboy_total_R
replace childboy_total=-10 if anybiochildren==0 & anynonbio==0  //no bio or non-bio children
label define childboy_total 0 "Girls only" -10 "No children (biological or non-biological)" -100 "no participation in sweep" -99 "information not provided", replace
label values childboy_total childboy_total
label var childboy_total "Total number of children who are boys (biological or non-biological)"
fre childboy_total 



***COMPUTE total number of female biological or non-biological children (age 30)
cap drop biochildgirl_total_R
clonevar biochildgirl_total_R = biochildgirl_total 
replace biochildgirl_total_R=0 if biochildgirl_total==-10
fre biochildgirl_total_R

cap drop nonbiochildgirl_total_R
clonevar nonbiochildgirl_total_R = nonbiochildgirl_total 
replace nonbiochildgirl_total_R=0 if nonbiochildgirl_total==-10
fre nonbiochildgirl_total_R

cap drop childgirl_total
gen childgirl_total = biochildgirl_total_R + nonbiochildgirl_total_R
drop biochildgirl_total_R nonbiochildgirl_total_R
replace childgirl_total=-10 if anybiochildren==0 & anynonbio==0  //no bio or non-bio children
label define childgirl_total 0 "Boys only" -10 "No children (biological or non-biological)" -100 "no participation in sweep" -99 "information not provided", replace
label values childgirl_total childgirl_total
label var childgirl_total "Total number of children who are girls (biological or non-biological)"
fre childgirl_total 




******************************************************************
***************** PARTNER AND CHILD COMBO (age 30) ******************
******************************************************************

//partner and biological children (age 30)
cap drop partnerchildbio
gen partnerchildbio=.
replace partnerchildbio=1 if anybiochildren==0 & partner==0 //no partner and no children
replace partnerchildbio=2 if anybiochildren==0 & partner==1 //partner but no children
replace partnerchildbio=3 if anybiochildren==1 & partner==0 //no partner but children
replace partnerchildbio=4 if anybiochildren==1 & partner==1 //partner and children
label define partnerchildbio 1 "No partner or children" 2 "Partner and no children" 3 "Children and no partner" 4 "Partner and children" -100 "no participation in sweep" -99 "information not provided", replace
label values partnerchildbio partnerchildbio
label var partnerchildbio "Whether has partner and/or any biological children"
fre partnerchildbio

//partner and any bio or nonbio children (age 30)
cap drop partnerchildany
gen partnerchildany=.
replace partnerchildany=1 if anychildren==0 & partner==0 //no partner and no children
replace partnerchildany=2 if anychildren==0 & partner==1 //partner but no children
replace partnerchildany=3 if anychildren==1 & partner==0 //no partner but children
replace partnerchildany=4 if anychildren==1 & partner==1 //partner and children
label define partnerchildany 1 "No partner or children" 2 "Partner and no children" 3 "Children and no partner" 4 "Partner and children" -100 "no participation in sweep" -99 "information not provided", replace
label values partnerchildany partnerchildany
label var partnerchildany "Whether has partner and/or any biological or non-biological children"
fre partnerchildany



*----------------------------------------------------------------------------*

//add suffix _30 to denote varabels are from age 30 sweep
foreach var of varlist _all {	
rename `var' `var'_30		
if inlist("`var'", "skip_bcsid") {				
}
}
rename bcsid_30 bcsid


save "$derived\BCS70_fertility_age30.dta", replace
use "$derived\BCS70_fertility_age30.dta", clear








**# Bookmark #3
*******************************************************************************
****************************** AGE 34 ***************************************** 
*******************************************************************************

use "$raw\bcs_2004_followup.dta", clear

//N=9,665	
//note: it asks about pregnancies since last interview/since age 16. So this could be a sweep previous to age 30.
//note: we use household grid data to figure out who other parent of biological child is

keep bcsid b7rage11 b7intmon b7intyr bd7spphh b7marst2 b7othrea b7everpg b7preg11 b7preg12 b7preg13 b7preg21 b7preg22 b7preg23 b7preg31 b7preg32 b7preg41 b7preg51 b7preg61 b7preg71 b7preg81 b7prgc11 b7prgc12 b7prgc13 b7prgc21 b7prgc22 b7prgc23 b7prgc31 b7prgc32 b7prgc41 b7prgc51 b7prgc61 b7prgc71 b7prgc81 b7prgm11 b7prgm12 b7prgm13 b7prgm21 b7prgm22 b7prgm23 b7prgm31 b7prgm32 b7prgm41 b7prgm51 b7prgm61 b7prgm71 b7prgm81 b7prgy11 b7prgy12 b7prgy13 b7prgy21 b7prgy22 b7prgy23 b7prgy31 b7prgy32 b7prgy41 b7prgy51 b7prgy61 b7prgy71 b7prgy81 b7livh11 b7livh12 b7livh13 b7livh21 b7livh22 b7livh23 b7livh31 b7livh32 b7livh41 b7livh51 b7livh61 b7livh71 b7livh81 b7lhhn11 b7lhhn12 b7lhhn13 b7livhn21 b7livhn22 b7livhn23 b7lihn31 b7lihn32 b7lihn41 b7lihn51 b7lihn61 b7lihn71 b7wpar02 b7wpar03 b7wpar04 b7wpar05 b7wpar06 b7wpar07 b7wpar08 b7wpar09 b7wpar10 b7rtok12 b7rtok13 b7rtok14 b7rtok15 b7rtok16 b7rtok17 b7rtok18 b7rtok19 b7rtok20 b7rage12 b7rage13 b7rage14 b7rage15 b7rage16 b7rage17 b7rage18 b7rage19 b7rage20 b7pmth2 b7pmth3 b7pmth4 b7pmth5 b7pmth6 b7pmth7 b7pmth8 b7pmth9 b7pmth10 b7sex12 b7sex13 b7sex14 b7sex15 b7sex16 b7sex17 b7sex18 b7sex19 b7sex20 bd7nchhh bd7ochhh bd7nach b7chchk b7abch91 b7achge b7abhd91 b7chchk2 b7abch92 b7achge2 b7abhd92 b7chchk3 b7abch93 b7achge3 b7abhd93 b7chchk4 b7abch94 b7achge4 b7abhd94 b7chchk5 b7abch95 b7achge5 b7abhd95 b7wpra11 b7wpra12 b7wpra21 b7wpra22 b7wpra23 b7wpra31 b7wpra32 b7wpra41 b7wpra51 b7wpra61


gen BCSAGE34SURVEY=1
label var BCSAGE34SURVEY "Whether took part in age 34 survey"


//interview date (age 34)
fre b7intmon b7intyr
rename (b7intmon b7intyr) (intmonth intyear)

label var intyear "Interview year (age 34)"
label define intyear -100 "no participation in sweep" -99 "information not provided", replace
label values intyear intyear

label var intmonth "Interview month (age 34)"
label define intmonth 1 "January" 2	"February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "	October" 11 "November" 12 "December" -100 "no participation in sweep" -99 "information not provided", replace
label values intmonth intmonth

//cohort members age (age 34)
fre b7rage11
rename b7rage11 cmagey
label var cmagey "CM age at interview"

//whether lives with spouse or partner (age 34)
rename bd7spphh partner
replace partner=. if partner==-6
label var partner "Whether CM has current partner in hhld"
label define partner 0 "No" 1 "Yes" -100 "no participation in sweep" -99 "information not provided", replace
label values partner partner
fre partner

//marital staus (age 34)
fre b7marst2

gen marital=.
replace marital=3 if b7marst2==1|b7marst2==4|b7marst2==5|b7marst2==6
replace marital=2 if (b7marst2==1|b7marst2==4|b7marst2==5|b7marst2==6) & partner==1
replace marital=1 if b7marst2==2|b7marst2==3
label define marital 3 "Single non-cohabiting" 2 "Single cohabiting with partner" 1 "Married" -100 "no participation in sweep" -99 "information not provided", replace
label values marital marital
label variable marital "Marital status (age 34)" 
fre marital


*------------------------------------------------------------------------*
//RENAMING PREGNANCY DATA VARIABLES (age 34)

//pregnant since last interview (age 34)
fre b7everpg
rename b7everpg pregsincelast
replace pregsincelast=. if pregsincelast<0
replace pregsincelast=0 if pregsincelast==2
fre pregsincelast

//outcome of pregnancy (age 34)
rename (b7preg11 b7preg12 b7preg13 b7preg21 b7preg22 b7preg23 b7preg31 b7preg32 b7preg41 b7preg51 b7preg61 b7preg71 b7preg81) (prego11 prego12 prego13 prego21 prego22 prego23 prego31 prego32 prego41 prego51 prego61 prego71 prego81)

//child's sex (age 34)
rename (b7prgc11 b7prgc12 b7prgc13 b7prgc21 b7prgc22 b7prgc23 b7prgc31 b7prgc32 b7prgc41 b7prgc51 b7prgc61 b7prgc71 b7prgc81) (pregs11 pregs12 pregs13 pregs21 pregs22 pregs23 pregs31 pregs32 pregs41 pregs51 pregs61 pregs71 pregs81)

//child's month of birth (age 34)
rename (b7prgm11 b7prgm12 b7prgm13 b7prgm21 b7prgm22 b7prgm23 b7prgm31 b7prgm32 b7prgm41 b7prgm51 b7prgm61 b7prgm71 b7prgm81) (pregm11 pregm12 pregm13 pregm21 pregm22 pregm23 pregm31 pregm32 pregm41 pregm51 pregm61 pregm71 pregm81)

//year of birth (age 34)
rename (b7prgy11 b7prgy12 b7prgy13 b7prgy21 b7prgy22 b7prgy23 b7prgy31 b7prgy32 b7prgy41 b7prgy51 b7prgy61 b7prgy71 b7prgy81) (pregy11 pregy12 pregy13 pregy21 pregy22 pregy23 pregy31 pregy32 pregy41 pregy51 pregy61 pregy71 pregy81)

//whether child lives in household (age 34)
rename (b7livh11 b7livh12 b7livh13 b7livh21 b7livh22 b7livh23 b7livh31 b7livh32 b7livh41 b7livh51 b7livh61 b7livh71 b7livh81) (preghh11 preghh12 preghh13 preghh21 preghh22 preghh23 preghh31 preghh32 preghh41 preghh51 preghh61 preghh71 preghh81)

//child's person number from HH grid (age 34)
rename (b7lhhn11 b7lhhn12 b7lhhn13 b7livhn21 b7livhn22 b7livhn23 b7lihn31 b7lihn32 b7lihn41 b7lihn51 b7lihn61 b7lihn71) (pnum11 pnum12 pnum13 pnum21 pnum22 pnum23 pnum31 pnum32 pnum41 pnum51 pnum61 pnum71)
cap drop pnum81
gen pnum81=. //we generate this as this is not in data




*------------------------------------------------------------------------*
//RENAMING ABSENT CHILD DATA VARIABLES (age 34)

***children outside household reported in previous sweeps (absent child data) (age 34)
rename (b7chchk b7abch91 b7achge b7abhd91 b7chchk2 b7abch92 b7achge2 b7abhd92 b7chchk3 b7abch93 b7achge3 b7abhd93 b7chchk4 b7abch94 b7achge4 b7abhd94 b7chchk5 b7abch95 b7achge5 b7abhd95) (absbio1 abssex1 absage1 abslive1 absbio2 abssex2 absage2 abslive2 absbio3 abssex3 absage3 abslive3 absbio4 abssex4 absage4 abslive4 absbio5 abssex5 absage5 abslive5)


*------------------------------------------------------------------------*
//whether current parent is child's other natural parent (age 34) // note: having to use information from household grid on person mumber and for each person number, whether or not child is current partner's child (code to 0 or 1 or missing values (.0) for those who have refused (-9))

foreach num in 11 12 13 21 22 23 31 32 41 51 61 71 81 {

cap drop pregpar`num'
gen pregpar`num'=.
label var pregpar`num' "Whether current partner/spouse is child's other parent"
label define pregpar`num' 1 "Yes" 2 "No", replace
label values pregpar`num' pregpar`num'

replace pregpar`num'=1 if pnum`num'==2 & b7wpar02==1
replace pregpar`num'=2 if pnum`num'==2 & b7wpar02==2
replace pregpar`num'=1 if pnum`num'==3 & b7wpar03==1
replace pregpar`num'=2 if pnum`num'==3 & b7wpar03==2
replace pregpar`num'=1 if pnum`num'==4 & b7wpar04==1
replace pregpar`num'=2 if pnum`num'==4 & b7wpar04==2
replace pregpar`num'=1 if pnum`num'==5 & b7wpar05==1
replace pregpar`num'=2 if pnum`num'==5 & b7wpar05==2
replace pregpar`num'=1 if pnum`num'==6 & b7wpar06==1
replace pregpar`num'=2 if pnum`num'==6 & b7wpar06==2
replace pregpar`num'=1 if pnum`num'==7 & b7wpar07==1
replace pregpar`num'=2 if pnum`num'==7 & b7wpar07==2
replace pregpar`num'=1 if pnum`num'==8 & b7wpar08==1
replace pregpar`num'=2 if pnum`num'==8 & b7wpar08==2
replace pregpar`num'=1 if pnum`num'==9 & b7wpar09==1
replace pregpar`num'=2 if pnum`num'==9 & b7wpar09==2
replace pregpar`num'=1 if pnum`num'==10 & b7wpar10==1
replace pregpar`num'=2 if pnum`num'==10 & b7wpar10==2

fre pregpar`num'
}

*------------------------------------------------------------------------*


*RECODE all variables to missing if not a live birth (age 34)
foreach C in 11 12 13 21 22 23 31 32 41 51 61 71 81 {
foreach X of varlist pregs`C' pregm`C' pregy`C' pregpar`C' preghh`C' {
replace	`X'=. if prego`C'!=1

replace prego`C'=. if prego`C'!=1|pregsincelast==0
label define prego`C' 1 "Live birth", replace
label values prego`C' prego`C'
replace	pregs`C'=. if pregs`C'==-1|pregs`C'==.|pregsincelast==. //sex
replace	pregm`C'=. if pregm`C'<0 
replace	pregy`C'=. if pregy`C'<0
replace	pregpar`C'=. if pregpar`C'<0 | pregsincelast==.
replace	pregpar`C'=2 if partner==0 & b7othrea==2 & prego`C'==1
replace	preghh`C'=. if preghh`C'<0|pregsincelast==.

fre prego`C' pregs`C' pregm`C' pregy`C' pregpar`C' preghh`C'
}
}



*---------------------------------------------------*
//HH grid variable rename (age 34)
rename (b7rtok12 b7rtok13 b7rtok14 b7rtok15 b7rtok16 b7rtok17 b7rtok18 b7rtok19 b7rtok20) (hhrel2 hhrel3 hhrel4 hhrel5 hhrel6 hhrel7 hhrel8 hhrel9 hhrel10) //relationship to cm

rename (b7rage12 b7rage13 b7rage14 b7rage15 b7rage16 b7rage17 b7rage18 b7rage19 b7rage20) (hhage2 hhage3 hhage4 hhage5 hhage6 hhage7 hhage8 hhage9 hhage10) //age in years

rename (b7pmth2 b7pmth3 b7pmth4 b7pmth5 b7pmth6 b7pmth7 b7pmth8 b7pmth9 b7pmth10) (hhagebm2 hhagebm3 hhagebm4 hhagebm5 hhagebm6 hhagebm7 hhagebm8 hhagebm9 hhagebm10) //birth month

rename (b7sex12 b7sex13 b7sex14 b7sex15 b7sex16 b7sex17 b7sex18 b7sex19 b7sex20) (hhsex2 hhsex3 hhsex4 hhsex5 hhsex6 hhsex7 hhsex8 hhsex9 hhsex10) //sex




*---------------------------------------------------*
//ADDING SUFFIX 34 BEFORE MERGING WITH PREVIOUS SWEEP (age 34)
foreach var of varlist _all {	
rename `var' `var'_34		
if inlist("`var'", "skip_bcsid") {				
}
}
rename bcsid_34 bcsid


*---------------------------------------------------*
//MERGING ON PREVIOUS SWEEP AS WE NEED TO ADD NEW CHILDREN TO PREVIOUS ONES (age 34)
//merge on age 26 and 30
merge 1:1 bcsid using  "$derived\BCS70_fertility_age26.dta"
drop _merge
merge 1:1 bcsid using "$derived\BCS70_fertility_age30.dta" 
drop _merge



*-------------------------------------------------------------------*
***COMPUTE current age in whole years  of each biochild from birth year and month, and interview month and year. And age of cohort member at birth of child in whole years.

//interview date (age 34)
fre intyear_34
fre intmonth_34
cap drop intym_34
gen intym_34 = ym(intyear_34,intmonth_34)
label var intym_34 "Interview date - months since Jan 1960"
fre intym_34

//cohort member birthdate (age 34)
cap drop cmbirthy_34
gen cmbirthy_34=1970
label var cmbirthy_34 "Birth year of CM"
fre cmbirthy_34

cap drop cmbirthm_34
gen cmbirthm_34=4
label var cmbirthm_34 "Birth month of CM"
fre cmbirthm_34

cap drop cmbirthym_34
gen cmbirthym_34 = ym(cmbirthy_34,cmbirthm_34)
label var cmbirthym_34 "CM birth date - months since Jan 1960"
fre cmbirthym_34

//CM age in years (age 34)
cap drop cmagey_34
gen cmagey_34=(intym_34-cmbirthym_34)/12
replace cmagey_34 = floor(cmagey_34)
label var cmagey_34 "CM age at interview"
fre cmagey_34 



//new children at age 34 since last interview (age 34)
foreach C in 11_34 12_34 13_34 21_34 22_34 23_34 31_34 32_34 41_34 51_34 61_34 71_34 81_34 {

cap drop biochildym`C'
gen biochildym`C' = ym(pregy`C',pregm`C') 
label var biochildym`C' "`C' Date of birth of biological child - months since Jan 1960"
fre biochildym`C'

//child's age in whole years at interview (age 34)
cap drop biochildagey`C'
gen biochildagey`C' = (intym_34-biochildym`C')/12
fre biochildagey`C'
replace biochildagey`C' = floor(biochildagey`C')
label var biochildagey`C' "`C' Age in whole years of biological child"
fre biochildagey`C'

//cm age in whole years at birth of child (age 34)
cap drop cmageybirth`C'
gen cmageybirth`C' = (biochildym`C'-cmbirthym_34)/12
fre cmageybirth`C'
replace cmageybirth`C' = floor(cmageybirth`C')
label var cmageybirth`C' "`C' Age of CM in years at birth of biological child `C'"
fre cmageybirth`C'

}



*** ADJUSTING AGE OF PREVIOUSLY REPORTED CHILDREN TO DATE OF INTERVIEW (age 34)

*** AGE 26 CHILDREN: children reported previously at age 26 updated with their age at 34
foreach C in 2_26 3_26 4_26 5_26 6_26 7_26 8_26 9_26 10_26 {

//child's age in whole years at age 34 interview
cap drop biochildagey`C'
gen biochildagey`C'=biohhage`C' + (cmagey_34-cmagey_26)
label var biochildagey`C' "`C' Age in whole years of biological child"
fre biochildagey`C'
}


//***AGE 30 CHILDREN: children reported previously at age 30 updated with their age at 34
foreach C in 11 12 13 14 15 21 22 23 31 32 41 42 51 52 53 61 62 71 81 {

//child's age in whole years at age 34 interview
cap drop biochildagey`C'_30
gen biochildagey`C'_30 = (intym_34-biochildym`C'_30)/12
fre biochildagey`C'_30
replace biochildagey`C'_30 = floor(biochildagey`C'_30)
label var biochildagey`C'_30 "`C' Age in whole years of biological child"
fre biochildagey`C'_30
}




******************************************************************
****BIOLOGICAL CHILDREN (age 34)********************************* 
******************************************************************

***COMPUTE total number of biological children (age 34)
//this is just temporary as these will be added to last interview
cap drop anybiochildren_34
egen anybiochildren_34 =anycount(prego11_34  prego12_34  prego13_34  prego21_34  prego22_34  prego23_34  prego31_34  prego32_34  prego41_34  prego51_34  prego61_34  prego71_34  prego81_34), values(1)
replace anybiochildren_34=. if pregsincelast_34==.
label variable anybiochildren_34 "Total number of biological children since last at age 34"
fre anybiochildren_34


//Figuring out which data to add the new children to

*since sweep 16
cap drop preg_16_34
gen preg_16_34=.
replace preg_16_34=1 if anybiochildren_26==. &  anybiochildren_30==. &  anybiochildren_34!=.
fre preg_16_34 //N=302

cap drop sweep16_34
gen sweep16_34=.
replace sweep16_34=1 if BCSAGE26SURVEY_26==. &  BCSAGE30SURVEY_30==. &  BCSAGE34SURVEY_34!=.
fre sweep16_34 //N=258

*since sweep 26
cap drop preg_26_34
gen preg_26_34=.
replace preg_26_34=1 if anybiochildren_26!=. & anybiochildren_30==. & anybiochildren_34!=.
fre preg_26_34 //N=374

cap drop sweep26_34
gen sweep26_34=.
replace sweep26_34=1 if BCSAGE26SURVEY_26!=. & BCSAGE30SURVEY_30==. & BCSAGE34SURVEY_34!=.
fre sweep26_34 //N=405

*since sweep 30
cap drop preg_30_34
gen preg_30_34=.
replace preg_30_34=1 if anybiochildren_30!=. & anybiochildren_34!=.
fre preg_30_34 //N=8964

cap drop sweep30_34
gen sweep30_34=.
replace sweep30_34=1 if BCSAGE30SURVEY_30!=. & BCSAGE34SURVEY_34!=.
fre sweep30_34 //N=9002



***COMPUTE total number of biological children (age 34)
//since age 16
cap drop biochild_total_A
egen biochild_total_A =anycount(prego11_34  prego12_34  prego13_34  prego21_34  prego22_34  prego23_34  prego31_34  prego32_34  prego41_34  prego51_34  prego61_34  prego71_34  prego81_34), values(1)
replace biochild_total_A=. if sweep16_34==.|preg_16_34==. 
replace biochild_total_A= biochild_total_A
fre biochild_total_A //N=258

//since age 26
cap drop biochild_total_B
egen biochild_total_B =anycount(prego11_34  prego12_34  prego13_34  prego21_34  prego22_34  prego23_34  prego31_34  prego32_34  prego41_34  prego51_34  prego61_34  prego71_34  prego81_34), values(1)
replace biochild_total_B=. if sweep26_34==.|preg_26_34==. 
replace biochild_total_B= biochild_total_B + biochild_tot_26
fre biochild_total_B //N=372

//since age 30
cap drop biochild_total_C
egen biochild_total_C =anycount(prego11_34  prego12_34  prego13_34  prego21_34  prego22_34  prego23_34  prego31_34  prego32_34  prego41_34  prego51_34  prego61_34  prego71_34  prego81_34), values(1)
replace biochild_total_C=. if sweep30_34==.|preg_30_34==. 
replace biochild_total_C= biochild_total_C + biochild_tot_30
fre biochild_total_C //N=8964



// COMPUTE age 34 total children
fre biochild_total_A biochild_total_B biochild_total_C

cap drop included
gen included=.
replace included=1 if biochild_total_A!=.
replace included=1 if biochild_total_B!=.
replace included=1 if biochild_total_C!=.
fre included //N=9,594

cap drop biochild_tot_34
egen biochild_tot_34=rowtotal(biochild_total_A biochild_total_B biochild_total_C)
replace biochild_tot_34=. if included==.
fre biochild_tot_34
label define biochild_tot_34 0 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values biochild_tot_34 biochild_tot_34
label variable biochild_tot_34 "Total number of biological children"
fre biochild_tot_34 //N=9,594
fre biochild_tot_30
fre biochild_tot_26




*-----------------------------------------------------*
*** CHECKING EXTRA BIOLOGICAL CHILDREN IN HOUSEHOLD NOT REPORTED AS PREGNANCY (age 34)

***COMPUTE total number of biological children reported in hh grid (age 34)
cap drop biochildhh_total_34
egen biochildhh_total_34 = anycount(hhrel2_34 hhrel3_34 hhrel4_34 hhrel5_34 hhrel6_34 hhrel7_34 hhrel8_34 hhrel9_34 hhrel10_34), values(3)
replace biochildhh_total_34=. if (BCSAGE34SURVEY==.| hhrel2_34==-6)
replace biochildhh_total_34=. if biochild_tot_34==.
 //code to missing if not in age 34 sweep or didn't complete HH grid
label variable biochildhh_total_34 "Total number of biological children in HH grid age 34"
fre biochildhh_total_34


fre bd7nchhh //the already derived measure for number of own children in HH is completely consistent with our derived measure above


clonevar biohhgrid_total_34 = biochildhh_total_34 //creating a variable for the original hhgrid total number of bio children


//computing difference in pregnancy data and household data (age 34)

cap drop biochild_tot_miss_34
gen biochild_tot_miss_34=1 if biochild_tot_34==. //this creates a missing values flag for this variable

replace biochild_tot_34=0 if biochild_tot_34==. // this bit is important as crucial for the inclusion of all HH grid data in adjustments for extra children 

fre biochild_tot_34 biochildhh_total_34
tab biochild_tot_34 biochildhh_total_34, mi
cap drop difference_34
gen difference_34=biochild_tot_34 - biochildhh_total_34
fre difference_34


//creating a variable that flags CMs with differences
cap drop biochild_extra_flag_34
gen biochild_extra_flag_34=.
label var biochild_extra_flag_34 "Flag: More bio children reported in HH grid than in pregnancy data"
replace biochild_extra_flag_34=1 if inrange(difference_34, -10,-1)
replace biochild_extra_flag_34=0 if inrange(difference_34, 0,20)
label define biochild_extra_flag_34 1 "Yes" 0 "No" -100 "no participation in sweep" -99 "information not provided", replace
label values biochild_extra_flag_34 biochild_extra_flag_34
fre biochild_extra_flag_34 //applies to 384

//creating variable to use for adjustment of total children
cap drop bioextra_34
gen bioextra_34=difference_34
replace bioextra_34=0 if inrange(difference_34,0,10)
replace bioextra_34=1 if difference_34==-1
replace bioextra_34=2 if difference_34==-2
replace bioextra_34=3 if difference_34==-3
replace bioextra_34=4 if difference_34==-4
replace bioextra_34=5 if difference_34==-5
replace bioextra_34=6 if difference_34==-6
replace bioextra_34=7 if difference_34==-7
fre bioextra_34



******ADJUSTING 
cap drop bioextra_miss_34
gen bioextra_miss_34=1 if bioextra_34==. //missing values flag 
fre bioextra_miss_34
replace bioextra_34=0 if bioextra_34==.

fre biochild_tot_miss_34 //already created a missing flag for this

//TOTAL NUMBER OF CHILDREN (age 34)
fre biochild_tot_34 bioextra_34
replace biochild_tot_34=biochild_tot_34 + bioextra_34
replace biochild_tot_34=. if biochild_tot_miss_34== 1 
fre biochild_tot_34

//ANY BIO CHILDREN (age 34)
cap drop anybiochildren_34
gen anybiochildren_34=.
replace anybiochildren_34=1 if inrange(biochild_tot_34,1,20)
replace anybiochildren_34=0 if biochild_tot_34==0
label define yesno 0 "No" 1 "Yes" -100 "no participation in sweep" -99 "information not provided", replace
label values anybiochildren_34 yesno
fre anybiochildren_34


//WHERE LIVE (age 34)

*in household (age 34)
fre biochildhh_total_34

*not in household (age 34)
fre biochild_tot_34 biochildhh_total_34
cap drop biochildnonhh_total_34
gen biochildnonhh_total_34=biochild_tot_34-biochildhh_total_34
replace biochildnonhh_total_34=-10 if anybiochildren_34==0
label variable biochildnonhh_total_34 "Total number of bio children not in household age 34"
label define biochildnonhh_total_34 0 "All biological children live in household" -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildnonhh_total_34 biochildnonhh_total_34
fre biochildnonhh_total_34

*recoding and labelling biochildhh_total_34 (age 34)
replace biochildhh_total_34=-10 if anybiochildren_34==0
replace biochildhh_total_34=. if anybiochildren_34==.
label define biochildhh_total_34  0 "None of the biological children live in household" -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildhh_total_34 biochildhh_total_34
fre biochildhh_total_34





*******************************************************
*** OTHER PARENT OF CHILDREN IS CURRENT PARTNER (age 34)
*******************************************************
//notes: In pregnancy data we only have this information for new children reported at age 34 sweep, which are either new children they had since age 30, or all children they ever had if non-participation at age 30. So for children reported in pregnancy data at age 30, we don't have direct information on whether CM is still with the same partner. However, what we can derive is whether partner is parent to children living in household as this is captured in HH grid. We can then use information on new children reported as pregnancies at age 34, and who do not live in HH, and who the other parent is, and data on other absent children at age 34 reported in pregnancy data at age 30 who live with other parent, although for a very small number who live with spouse parter, with flatmates or uni halls of resident, or other, we don't know who their other parent is. However, the inaccuracy is tolerably in order to get an overall better measure that capture all biological children.     

fre partner_34
fre b7othrea
fre b7othrea_34
//partner_34==0 & b7othrea==2

***children in household (household data) (age 34)
foreach C in 2_34 3_34 4_34 5_34 6_34 7_34 8_34 9_34  {
cap drop biochildhhpar`C'
gen biochildhhpar`C'=.
replace biochildhhpar`C'=1 if b7wpar0`C'==1 & hhrel`C'==3
replace biochildhhpar`C'=2 if (b7wpar0`C'==2)|(partner_34==0 & b7othrea_34==2) & hhrel`C'==3
label var biochildhhpar`C' "`C' Current partner/spouse is household child's other biological parent"
label define biochildhhpar`C' 1 "Yes current partner" 2 "No not current partner" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildhhpar`C' biochildhhpar`C'
fre biochildhhpar`C'
}
//we do this separately for hh member number 10 because of variable name of b7wpar not having a 0 here
foreach C in 10_34  {
cap drop biochildhhpar`C'
gen biochildhhpar`C'=.
replace biochildhhpar`C'=1 if b7wpar`C'==1 & hhrel`C'==3
replace biochildhhpar`C'=2 if (b7wpar`C'==2)|(partner_34==0 & b7othrea_34==2) & hhrel`C'==3
label var biochildhhpar`C' "`C' Current partner/spouse is biological parent to child living in household"
label define biochildhhpar`C' 1 "Yes current partner" 2 "No not current partner" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildhhpar`C' biochildhhpar`C'
fre biochildhhpar`C'
}


***children outside household (pregnancy data new children) (age 34)
rename (b7wpra11 b7wpra12 b7wpra21 b7wpra22 b7wpra23 b7wpra31 b7wpra32 b7wpra41 b7wpra51 b7wpra61) (pregabspar11_34 pregabspar12_34 pregabspar21_34 pregabspar22_34 pregabspar23_34 pregabspar31_34 pregabspar32_34 pregabspar41_34 pregabspar51_34 pregabspar61_34)

foreach C in 11_34 12_34 21_34 22_34 23_34 31_34 32_34 41_34 51_34 61_34 {
cap drop bionewnonhhpar`C'
gen bionewnonhhpar`C'=.
replace bionewnonhhpar`C'=1 if pregabspar`C'==1 & preghh`C'==2
replace bionewnonhhpar`C'=2 if (pregabspar`C'==2)|(partner_34==0 & b7othrea_34==2) & preghh`C'==2
label define bionewnonhhpar`C' 1 "Yes current partner" 2 "No not current partner"
label var bionewnonhhpar`C' "`C' Current partner is biological parent to new biological child not in household"
fre bionewnonhhpar`C'
}



//absent child is biological child (age 34)
foreach C in 1 2 3 4 5 {
replace absbio`C'_34=. if absbio`C'_34==2|absbio`C'_34==-8|absbio`C'_34==-1
fre absbio`C'_34
}

//who parent is to absent biological child's biological parent (age 34)
foreach C in 1 2 3 4 5 {
cap drop absbiopar`C'_34
gen absbiopar`C'_34=.
replace absbiopar`C'_34=2 if abslive`C'_34==5 & absbio`C'_34==1 //they live with previous partner
replace absbiopar`C'_34=2 if inrange(abslive`C'_34,2,6) & absbio`C'_34==1 & partner_34==0 & othrela==2 //there is no current parter in HH or non-res
replace absbiopar`C'_34=. if inrange(abslive`C'_34,2,4)|abslive`C'_34==6 & absbio`C'_34==1
//adjusting to misssing for the small number of families (N=31) with absent cildren and where we don't know who the other parent is as these are not living with other parent. 
label var absbiopar`C' "`C' Current parter is absent biological child's biological parent"
label define absbiopar`C' 1 "Yes current partner" 2 "No not current partner"
fre absbiopar`C'_34
}



//PREVIOUS PARTNER IS PARENT (age 34)

***COMPUTE number of children whose parent is previous partner (age 34)
cap drop biochildprev_total_34
egen biochildprev_total_34 = anycount(biochildhhpar2_34 biochildhhpar3_34 biochildhhpar4_34 biochildhhpar5_34 biochildhhpar6_34 biochildhhpar7_34 biochildhhpar8_34 biochildhhpar9_34 biochildhhpar10_34 bionewnonhhpar11_34 bionewnonhhpar12_34 bionewnonhhpar21_34 bionewnonhhpar22_34 bionewnonhhpar23_34 bionewnonhhpar31_34 bionewnonhhpar32_34 bionewnonhhpar41_34 bionewnonhhpar51_34 bionewnonhhpar61_34 absbiopar1_34 absbiopar2_34 absbiopar3_34 absbiopar4_34 absbiopar5_34), values(2)
replace biochildprev_total_34=-10 if anybiochildren_34==0 
replace biochildprev_total_34=. if (BCSAGE34SURVEY==.| hhrel2_34==-6)
replace biochildprev_total_34=. if anybiochildren_34==. 
replace biochildprev_total_34=. if (abslive1_34==2|abslive1_34==3|abslive1_34==4|abslive1_34==6|abslive1_34==9) | (abslive2_34==2|abslive2_34==3|abslive2_34==4|abslive2_34==6|abslive2_34==9) | (abslive3_34==2|abslive3_34==3|abslive3_34==4|abslive3_34==6|abslive3_34==9) |(abslive4_34==2|abslive4_34==3|abslive4_34==4|abslive4_34==6|abslive4_34==9) |(abslive5_34==2|abslive5_34==3|abslive5_34==4|abslive5_34==6|abslive5_34==9) //adjusting to misssing for families  with absent children and where we don't know who the other parent is as these are not living with other parent. Note that there are none here. 
replace biochildprev_total_34=-10 if anybiochildren_34==0 
label define biochildprev_total_34 0 "Currrent partner is parent to all biological children" -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildprev_total_34 biochildprev_total_34
label var biochildprev_total_34 "Total number of biological children had with a previous partner"
fre biochildprev_total_34


//whether a previous partner is parent to any children (age 34)
cap drop biochildprevany_34
gen biochildprevany_34=.
replace biochildprevany_34=1 if inrange(biochildprev_total_34,1,10)
replace biochildprevany_34=0 if biochildprev_total_34==0
replace biochildprevany_34=-10 if biochildprev_total_34==-10
label variable biochildprevany_34 "Any children with a previous partner"
label define biochildprevany_34 1 "Previous partner(s) parent to all or some biological children" 0 "Current partner is parent to all biological children" -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildprevany_34 biochildprevany_34
fre biochildprevany_34




****************************************************
*** SEX OF BIOLOGICAL CHILDREN (age 34)
****************************************************

*BOYS (age 34)
cap drop Rbiochildboy_total_26
clonevar Rbiochildboy_total_26 = biochildboy_total_26
replace Rbiochildboy_total_26=0 if Rbiochildboy_total_26==-10

cap drop Rbiochildboy_total_30
clonevar Rbiochildboy_total_30 = biochildboy_total_30
replace Rbiochildboy_total_30=0 if Rbiochildboy_total_30==-10


//since age 30
cap drop biochildboy_total_B
egen biochildboy_total_B =anycount(pregs11_34 pregs12_34 pregs13_34 pregs21_34 pregs22_34 pregs23_34 pregs31_34 pregs32_34 pregs41_34 pregs51_34 pregs61_34 pregs71_34 pregs81_34), values(1)
replace biochildboy_total_B=. if sweep30_34==.|preg_30_34==. 
replace biochildboy_total_B= biochildboy_total_B + Rbiochildboy_total_30
fre biochildboy_total_B //N=8964
//since age 26
cap drop biochildboy_total_C
egen biochildboy_total_C =anycount(pregs11_34 pregs12_34 pregs13_34 pregs21_34 pregs22_34 pregs23_34 pregs31_34 pregs32_34 pregs41_34 pregs51_34 pregs61_34 pregs71_34 pregs81_34), values(1)
replace biochildboy_total_C=. if sweep26_34==.|preg_26_34==. 
replace biochildboy_total_C= biochildboy_total_C + Rbiochildboy_total_26
fre biochildboy_total_C //N=372
//since age 16
cap drop biochildboy_total_D
egen biochildboy_total_D =anycount(pregs11_34 pregs12_34 pregs13_34 pregs21_34 pregs22_34 pregs23_34 pregs31_34 pregs32_34 pregs41_34 pregs51_34 pregs61_34 pregs71_34 pregs81_34), values(1)
replace biochildboy_total_D=. if sweep16_34==.|preg_16_34==. 
replace biochildboy_total_D=biochildboy_total_D
fre biochildboy_total_D //N=258


// COMPUTE age 34 total boys
fre biochildboy_total_D biochildboy_total_B biochildboy_total_C

cap drop biochildboy_total_34
egen biochildboy_total_34=rowtotal(biochildboy_total_D biochildboy_total_B biochildboy_total_C)
replace biochildboy_total_34=. if included==.
fre biochildboy_total_34
label define biochildboy_total_34 0 "Girls only" -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildboy_total_34 biochildboy_total_34
label variable biochildboy_total_34 "Total number of biological boys"
fre biochildboy_total_34 //N=9,594


*----------------------------------------------------------------*


*GIRLS (age 34)
cap drop Rbiochildgirl_total_26
clonevar Rbiochildgirl_total_26 = biochildgirl_total_26
replace Rbiochildgirl_total_26=0 if Rbiochildgirl_total_26==-10

cap drop Rbiochildgirl_total_30
clonevar Rbiochildgirl_total_30 = biochildgirl_total_30
replace Rbiochildgirl_total_30=0 if Rbiochildgirl_total_30==-10


//since age 30
cap drop biochildgirl_total_B
egen biochildgirl_total_B =anycount(pregs11_34 pregs12_34 pregs13_34 pregs21_34 pregs22_34 pregs23_34 pregs31_34 pregs32_34 pregs41_34 pregs51_34 pregs61_34 pregs71_34 pregs81_34), values(2)
replace biochildgirl_total_B=. if sweep30_34==.|preg_30_34==. 
replace biochildgirl_total_B= biochildgirl_total_B + Rbiochildgirl_total_30
fre biochildgirl_total_B //N=8964
//since age 26
cap drop biochildgirl_total_C
egen biochildgirl_total_C =anycount(pregs11_34 pregs12_34 pregs13_34 pregs21_34 pregs22_34 pregs23_34 pregs31_34 pregs32_34 pregs41_34 pregs51_34 pregs61_34 pregs71_34 pregs81_34), values(2)
replace biochildgirl_total_C=. if sweep26_34==.|preg_26_34==. 
replace biochildgirl_total_C= biochildgirl_total_C + Rbiochildgirl_total_26
fre biochildgirl_total_C //N=372
//since age 16
cap drop biochildgirl_total_D
egen biochildgirl_total_D =anycount(pregs11_34 pregs12_34 pregs13_34 pregs21_34 pregs22_34 pregs23_34 pregs31_34 pregs32_34 pregs41_34 pregs51_34 pregs61_34 pregs71_34 pregs81_34), values(2)
replace biochildgirl_total_D=. if sweep16_34==.|preg_16_34==. 
replace biochildgirl_total_D=biochildgirl_total_D
fre biochildgirl_total_D //N=258


// COMPUTE age 34 total girls
fre biochildgirl_total_D biochildgirl_total_B biochildgirl_total_C

cap drop biochildgirl_total_34
egen biochildgirl_total_34=rowtotal(biochildgirl_total_D biochildgirl_total_B biochildgirl_total_C)
replace biochildgirl_total_34=. if included==.
fre biochildgirl_total_34
label define biochildgirl_total_34 0 "Boys only" -10 "No biological children"  -100 "no participation in sweep" -99 "information not provided", replace
label values biochildgirl_total_34 biochildgirl_total_34
label variable biochildgirl_total_34 "Total number of biological girls"
fre biochildgirl_total_34 //N=9,594




*** CHECKING EXTRA BOYS AND GIRLS IN HOUSEHOLD NOT REPORTED AS PREGNANCY (age 34)

foreach C in 2_34 3_34 4_34 5_34 6_34 7_34 8_34 9_34 10_34 {
*biological boys in hh grid (age 34)
cap drop bioboyhh`C'
gen bioboyhh`C'=0
replace bioboyhh`C'=1 if hhrel`C'==3 & hhsex`C'==1
label define bioboyhh`C' 1 "biological boy", replace
label values bioboyhh`C' bioboyhh`C'
label var bioboyhh`C' "`C' is a hh biological boy"
fre bioboyhh`C'
}

foreach C in 2_34 3_34 4_34 5_34 6_34 7_34 8_34 9_34 10_34 {
*biological girls in hh grid (age 34)
cap drop biogirlhh`C'
gen biogirlhh`C'=0
replace biogirlhh`C'=1 if hhrel`C'==3 & hhsex`C'==2
label define biogirlhh`C' 1 "biological girl", replace
label values biogirlhh`C' biogirlhh`C'
label var biogirlhh`C' "`C' is a hh biological girl"
fre biogirlhh`C'
}



***COMPUTE total number of biological boys and girls reported in hh grid (age 34)

//boys (age 34)
cap drop bioboyhh_total_34
gen bioboyhh_total_34=bioboyhh2_34+bioboyhh3_34+bioboyhh4_34+bioboyhh5_34+bioboyhh6_34+bioboyhh7_34+bioboyhh8_34+bioboyhh9_34+bioboyhh10_34
label variable bioboyhh_total_34 "Total number of bio boys in household (HH grid data)"
replace bioboyhh_total_34=. if (BCSAGE34SURVEY==.| hhrel2_34==-6) //code to . if missing HH grid
replace bioboyhh_total_34=. if anybiochildren_34==.
fre bioboyhh_total_34

//girls (age 34)
cap drop biogirlhh_total_34
gen biogirlhh_total_34=biogirlhh2_34+biogirlhh3_34+biogirlhh4_34+biogirlhh5_34+biogirlhh6_34+biogirlhh7_34+biogirlhh8_34+biogirlhh9_34+biogirlhh10_34
label variable biogirlhh_total_34 "Total number of bio girls in household (HH grid data)"
replace biogirlhh_total_34=. if (BCSAGE34SURVEY==.| hhrel2_34==-6) //code to . if missing HH grid
replace biogirlhh_total_34=. if anybiochildren_34==.
fre biogirlhh_total_34



//computing difference in pregnancy data and household data (age 34)

fre biochildboy_total_34 biochildgirl_total_34
fre bioboyhh_total_34 biogirlhh_total_34 

cap drop biochildboy_tot_miss_34
gen biochildboy_tot_miss_34=1 if biochildboy_total_34==. //this creates a missing values flag for this variable
cap drop biochildgirl_tot_miss_34
gen biochildgirl_tot_miss_34=1 if biochildgirl_total_34==. //this creates a missing values flag for this variable

replace biochildboy_total_34=0 if biochildboy_total_34==.|biochildboy_total_34==-10 // this bit is important as crucial for the inclusion of all HH grid data in adjustments for extra children 
replace biochildgirl_total_34=0 if biochildgirl_total_34==.|biochildgirl_total_34==-10 // this bit is important as crucial for the inclusion of all HH grid data in adjustments for extra children 


fre biochildboy_total_34
fre bioboyhh_total_34

fre biochildgirl_total_34
fre biogirlhh_total_34

cap drop diffboy_34
gen diffboy_34=biochildboy_total_34-bioboyhh_total_34
fre diffboy_34

cap drop diffgirl_34
gen diffgirl_34=biochildgirl_total_34-biogirlhh_total_34
fre diffgirl_34



//extra boys identified and to be added to (age 34)
cap drop bioextraboy_34
gen bioextraboy_34=diffboy_34
replace bioextraboy_34=0 if inrange(diffboy_34,0,10)
replace bioextraboy_34=1 if diffboy_34==-1
replace bioextraboy_34=2 if diffboy_34==-2
replace bioextraboy_34=3 if diffboy_34==-3
replace bioextraboy_34=4 if diffboy_34==-4
replace bioextraboy_34=5 if diffboy_34==-5
replace bioextraboy_34=6 if diffboy_34==-6
fre bioextraboy_34

//extra girls identified and to be added to (age 34)
cap drop bioextragirl_34
gen bioextragirl_34=diffgirl_34
replace bioextragirl_34=0 if inrange(diffgirl_34,0,10)
replace bioextragirl_34=1 if diffgirl_34==-1
replace bioextragirl_34=2 if diffgirl_34==-2
replace bioextragirl_34=3 if diffgirl_34==-3
replace bioextragirl_34=4 if diffgirl_34==-4
replace bioextragirl_34=5 if diffgirl_34==-5
replace bioextragirl_34=6 if diffgirl_34==-6
fre bioextragirl_34



******ADJUSTING (age 34)

//first doing some missing value flags
cap drop bioextraboy_miss_34
gen bioextraboy_miss_34=1 if bioextraboy_34==. //missing values flag 
fre bioextraboy_miss_34
replace bioextraboy_34=0 if bioextraboy_34==.

cap drop bioextragirl_miss_34
gen bioextragirl_miss_34=1 if bioextragirl_34==. //missing values flag 
fre bioextragirl_miss_34
replace bioextragirl_34=0 if bioextragirl_34==.


//TOTAL NUMBER OF BOYS AND GIRLS (age 34)

//boys (age 34)
fre biochildboy_total_34 bioextraboy_34
replace biochildboy_total_34=biochildboy_total_34+bioextraboy_34
replace biochildboy_total_34=. if biochildboy_tot_miss_34==1 
replace biochildboy_total_34=. if anybiochildren_34==.
fre biochildboy_total_34

//girls (age 34)
fre biochildgirl_total_34
replace biochildgirl_total_34=biochildgirl_total_34+bioextragirl_34
replace biochildgirl_total_34=. if biochildgirl_tot_miss_34==1 //&bioextragirl_miss_34==1
replace biochildgirl_total_34=. if anybiochildren_34==.
fre biochildgirl_total_34


//check that new total is similar to the variable => yes good match
cap drop total_new_34
gen total_new_34=biochildboy_total_34+biochildgirl_total_34
fre total_new_34
fre biochild_tot_34

//coding no children as -10
replace biochildboy_total_34=-10 if anybiochildren_34==0
fre biochildboy_total_34

replace biochildgirl_total_34=-10 if anybiochildren_34==0
fre biochildgirl_total_34






*********************************************************
*** AGES OF BIOLOGICAL CHILDREN (age 34)
*********************************************************

//1. we have already updated ages of pregnancy childrens ages previously.
fre biochildagey2_26 biochildagey3_26 biochildagey4_26 biochildagey5_26 biochildagey6_26 biochildagey7_26 biochildagey8_26 biochildagey9_26 biochildagey10_26

fre biochildagey11_30 biochildagey12_30 biochildagey13_30 biochildagey14_30 biochildagey15_30 biochildagey21_30 biochildagey22_30 biochildagey23_30 biochildagey31_30 biochildagey32_30 biochildagey41_30 biochildagey42_30 biochildagey51_30 biochildagey52_30 biochildagey53_30 biochildagey61_30 biochildagey62_30 biochildagey71_30 biochildagey81_30

fre biochildagey11_34 biochildagey12_34 biochildagey13_34 biochildagey21_34 biochildagey22_34 biochildagey23_34 biochildagey31_34 biochildagey32_34 biochildagey41_34 biochildagey51_34 biochildagey61_34 biochildagey71_34 biochildagey81_34


//2. now update ages of extra HH grid children identified at 30 
 
// time in years since last interview at age 30 to be added to HH grid bio children's ages 
cap drop addtime
gen addtime=(intym_34-intym_30)/12
replace addtime=round(addtime, 1)
fre addtime 

foreach C in 2_30 3_30 4_30 5_30 6_30 7_30 8_30 9_30 10_30 {
cap drop Rbiohhage`C'
gen Rbiohhage`C'=.
replace Rbiohhage`C'=hhage`C' if hhrel`C'==3 & biochild_extra_flag_30==1
replace Rbiohhage`C'=(Rbiohhage`C' + addtime)
fre Rbiohhage`C'
} 
 

//3. identify additional children in HH grid at age 34
***COMPUTE age of eldest and youngest child in years from HH grid data at age 34 for CM's with a flag for having more children in HH grid than in preg data.
foreach C in 2_34 3_34 4_34 5_34 6_34 7_34 8_34 9_34 10_34 {
cap drop biohhage`C'
gen biohhage`C'=.
replace biohhage`C'=hhage`C' if hhrel`C'==3 & biochild_extra_flag_34==1
replace biohhage`C'=. if hhage`C'<0 //missing data coded to .
fre biohhage`C'
}

fre biohhage2_34 biohhage3_34 biohhage4_34 biohhage5_34 biohhage6_34 biohhage7_34 biohhage8_34 biohhage9_34 biohhage10_34



//THEN DO FINAL AGE OF CHILDREN MEASURE
*--------------------------------------------------------------------*
*** COMPUTE age of eldest and youngest biological child (age 34)

cap drop biochildy_eldest_34 //years
gen biochildy_eldest_34 = max(biochildagey2_26,biochildagey3_26,biochildagey4_26,biochildagey5_26,biochildagey6_26,biochildagey7_26,biochildagey8_26,biochildagey9_26,biochildagey10_26,biochildagey11_30,biochildagey12_30,biochildagey13_30,biochildagey14_30,biochildagey15_30,biochildagey21_30,biochildagey22_30,biochildagey23_30,biochildagey31_30,biochildagey32_30,biochildagey41_30,biochildagey42_30,biochildagey51_30,biochildagey52_30,biochildagey53_30,biochildagey61_30,biochildagey62_30,biochildagey71_30,biochildagey81_30,biochildagey11_34,biochildagey12_34,biochildagey13_34,biochildagey21_34,biochildagey22_34,biochildagey23_34,biochildagey31_34,biochildagey32_34,biochildagey41_34,biochildagey51_34,biochildagey61_34,biochildagey71_34,biochildagey81_34,biohhage2_34,biohhage3_34,biohhage4_34,biohhage5_34,biohhage6_34,biohhage7_34,biohhage8_34,biohhage9_34,biohhage10_34, Rbiohhage2_30,Rbiohhage3_30,Rbiohhage4_30,Rbiohhage5_30,Rbiohhage6_30,Rbiohhage7_30,Rbiohhage8_30,Rbiohhage9_30,Rbiohhage10_30)
replace biochildy_eldest_34=-10 if anybiochildren_34==0
replace biochildy_eldest_34=. if biochild_tot_miss_34== 1
label define biochildy_eldest_34 -10 "No biological children"  -100 "no participation in sweep" -99 "information not provided", replace
label values biochildy_eldest_34 biochildy_eldest_34
label var biochildy_eldest_34 "Age in years of eldest biological child"
fre biochildy_eldest_34


cap drop biochildy_youngest_34 //years
gen biochildy_youngest_34 = min(biochildagey2_26,biochildagey3_26,biochildagey4_26,biochildagey5_26,biochildagey6_26,biochildagey7_26,biochildagey8_26,biochildagey9_26,biochildagey10_26,biochildagey11_30,biochildagey12_30,biochildagey13_30,biochildagey14_30,biochildagey15_30,biochildagey21_30,biochildagey22_30,biochildagey23_30,biochildagey31_30,biochildagey32_30,biochildagey41_30,biochildagey42_30,biochildagey51_30,biochildagey52_30,biochildagey53_30,biochildagey61_30,biochildagey62_30,biochildagey71_30,biochildagey81_30,biochildagey11_34,biochildagey12_34,biochildagey13_34,biochildagey21_34,biochildagey22_34,biochildagey23_34,biochildagey31_34,biochildagey32_34,biochildagey41_34,biochildagey51_34,biochildagey61_34,biochildagey71_34,biochildagey81_34,biohhage2_34,biohhage3_34,biohhage4_34,biohhage5_34,biohhage6_34,biohhage7_34,biohhage8_34,biohhage9_34,biohhage10_34, Rbiohhage2_30,Rbiohhage3_30,Rbiohhage4_30,Rbiohhage5_30,Rbiohhage6_30,Rbiohhage7_30,Rbiohhage8_30,Rbiohhage9_30,Rbiohhage10_30)
replace biochildy_youngest_34=-10 if anybiochildren_34==0
replace biochildy_youngest_34=. if biochild_tot_miss_34== 1
label define biochildy_youngest_34 -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildy_youngest_34 biochildy_youngest_34
label var biochildy_youngest_34 "Age in years of youngest biological child"
fre biochildy_youngest_34





*************************************************************
******** AGE OF COHORT MEMBER AGE AT BIRTH (age 34) *******
*************************************************************

//generating variables for the extra HH grid children at age 30 and 34 to include in final code below.  We subtract childs age from cohort members age at the sweep.

foreach C in 2_34 3_34 4_34 5_34 6_34 7_34 8_34 9_34 10_34 {
cap drop cmagebirth_hhextra`C'
gen cmagebirth_hhextra`C'=cmagey_34-biohhage`C' if biochild_extra_flag_34==1
fre cmagebirth_hhextra`C'
}

foreach C in 2_30 3_30 4_30 5_30 6_30 7_30 8_30 9_30 10_30 {
cap drop cmagebirth_hhextra`C'
gen cmagebirth_hhextra`C'=cmagey_30-biohhage`C' if biochild_extra_flag_30==1
fre cmagebirth_hhextra`C'
}


***COMPUTE age of cohort member at birth of eldest and youngest child in years (age 34)
cap drop cmageybirth_eldest_34 //years
gen cmageybirth_eldest_34 = min(cmageybirth2_26,cmageybirth3_26,cmageybirth4_26,cmageybirth5_26,cmageybirth6_26,cmageybirth7_26,cmageybirth8_26,cmageybirth9_26,cmageybirth10_26,cmageybirth11_30,cmageybirth12_30,cmageybirth13_30,cmageybirth14_30,cmageybirth15_30,cmageybirth21_30,cmageybirth22_30,cmageybirth23_30,cmageybirth31_30,cmageybirth32_30,cmageybirth41_30,cmageybirth42_30,cmageybirth51_30,cmageybirth52_30,cmageybirth53_30,cmageybirth61_30,cmageybirth62_30,cmageybirth71_30,cmageybirth81_30,cmageybirth11_34,cmageybirth12_34,cmageybirth13_34,cmageybirth21_34,cmageybirth22_34,cmageybirth23_34,cmageybirth31_34,cmageybirth32_34,cmageybirth41_34,cmageybirth51_34,cmageybirth61_34,cmageybirth71_34,cmageybirth81_34,cmagebirth_hhextra2_34,cmagebirth_hhextra3_34,cmagebirth_hhextra4_34,cmagebirth_hhextra5_34,cmagebirth_hhextra6_34,cmagebirth_hhextra7_34,cmagebirth_hhextra8_34,cmagebirth_hhextra9_34,cmagebirth_hhextra10_34,cmagebirth_hhextra2_30,cmagebirth_hhextra3_30,cmagebirth_hhextra4_30,cmagebirth_hhextra5_30,cmagebirth_hhextra6_30,cmagebirth_hhextra7_30,cmagebirth_hhextra8_30,cmagebirth_hhextra9_30,cmagebirth_hhextra10_30)
replace cmageybirth_eldest_34=-10 if anybiochildren_34==0
replace cmageybirth_eldest_34=. if biochild_tot_miss_34==1
label define cmageybirth_eldest_34 -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values cmageybirth_eldest_34 cmageybirth_eldest_34
label var cmageybirth_eldest_34 "CM age in years at birth of eldest biological child"
fre cmageybirth_eldest_34


cap drop cmageybirth_youngest_34 //years
gen cmageybirth_youngest_34 = max(cmageybirth2_26,cmageybirth3_26,cmageybirth4_26,cmageybirth5_26,cmageybirth6_26,cmageybirth7_26,cmageybirth8_26,cmageybirth9_26,cmageybirth10_26,cmageybirth11_30,cmageybirth12_30,cmageybirth13_30,cmageybirth14_30,cmageybirth15_30,cmageybirth21_30,cmageybirth22_30,cmageybirth23_30,cmageybirth31_30,cmageybirth32_30,cmageybirth41_30,cmageybirth42_30,cmageybirth51_30,cmageybirth52_30,cmageybirth53_30,cmageybirth61_30,cmageybirth62_30,cmageybirth71_30,cmageybirth81_30,cmageybirth11_34,cmageybirth12_34,cmageybirth13_34,cmageybirth21_34,cmageybirth22_34,cmageybirth23_34,cmageybirth31_34,cmageybirth32_34,cmageybirth41_34,cmageybirth51_34,cmageybirth61_34,cmageybirth71_34,cmageybirth81_34,cmagebirth_hhextra2_34,cmagebirth_hhextra3_34,cmagebirth_hhextra4_34,cmagebirth_hhextra5_34,cmagebirth_hhextra6_34,cmagebirth_hhextra7_34,cmagebirth_hhextra8_34,cmagebirth_hhextra9_34,cmagebirth_hhextra10_34,cmagebirth_hhextra2_30,cmagebirth_hhextra3_30,cmagebirth_hhextra4_30,cmagebirth_hhextra5_30,cmagebirth_hhextra6_30,cmagebirth_hhextra7_30,cmagebirth_hhextra8_30,cmagebirth_hhextra9_30,cmagebirth_hhextra10_30)
replace cmageybirth_youngest_34=-10 if anybiochildren_34==0
replace cmageybirth_youngest_34=. if biochild_tot_miss_34==1
label define cmageybirth_youngest_34 -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values cmageybirth_youngest_34 cmageybirth_youngest_34
label var cmageybirth_youngest_34 "CM age in years at birth of youngest biological child"
fre cmageybirth_youngest_34




************************** NON BIOLOGICAL CHILDREN (age 34) *****************************
//derived from the household grid and already renamed above

*RECODE on non-biological children variables (age 34)
foreach C in 2_34 3_34 4_34 5_34 6_34 7_34 8_34 9_34 10_34 {

*non-biological and type (age 34)
cap drop nonbiochild`C'
gen nonbiochild`C'=.
replace nonbiochild`C'=1 if inrange(hhrel`C',4,7)
label define nonbiochild`C' 1 "Non-biological child" 0 "No non-biological child", replace
label values nonbiochild`C' nonbiochild`C'
label var nonbiochild`C' "`C' is a non-biological"
fre nonbiochild`C'

cap drop step`C'
gen step`C'=.
replace step`C'=1 if inrange(hhrel`C',5,6)
label define step`C' 1 "Step child", replace
label values step`C' step`C'
label var step`C' "`C' is a stepchild"
fre step`C'

cap drop adopt`C'
gen adopt`C'=.
replace adopt`C'=1 if hhrel`C'==4
label define adopt`C' 1 "Adopted", replace
label values adopt`C' adopt`C'
label var adopt`C' "`C' is adopted"
fre adopt`C'

cap drop foster`C'
gen foster`C'=.
replace foster`C'=1 if hhrel`C'==7
label define foster`C' 1 "foster", replace
label values foster`C' foster`C'
label var foster`C' "`C' is foster"
fre foster`C'

*age of nonbio children (age 34)
cap drop nonbiochildagey`C'
clonevar nonbiochildagey`C' = hhage`C' if inrange(hhrel`C',4,7) & hhage`C'<100 
label var nonbiochildagey`C' "`C' Age in years of non-biological child"
fre nonbiochildagey`C'

*sex of nonbio children (age 34)
cap drop nonbiochildsex`C'
clonevar nonbiochildsex`C' = hhsex`C' if inrange(hhrel`C',4,7)
label var nonbiochildsex`C' "`C' Sex of non-biological child"
fre nonbiochildsex`C'
}


***COMPUTE whether has any non-biologial children in household (age 34)
cap drop anynonbio_34
egen anynonbio_34=anycount(nonbiochild2_34 nonbiochild3_34 nonbiochild4_34 nonbiochild5_34 nonbiochild6_34 nonbiochild7_34 nonbiochild8_34 nonbiochild9_34 nonbiochild10_34), values(1)
replace anynonbio_34=1 if inrange(anynonbio_34,1,20)
replace anynonbio_34=. if (BCSAGE34SURVEY==.| hhrel2_34==-6)
label variable anynonbio_34 "Whether CM has any non-biological children in household"
label define yesno 0 "No" 1 "Yes" -100 "no participation in sweep" -99 "information not provided", replace
label values anynonbio_34 yesno
fre anynonbio_34 
fre anynonbio_30 


***COMPUTE total number of non-biologial children in household (age 34)

//number of all non-biological (age 34)
cap drop nonbiochild_tot_34
egen nonbiochild_tot_34 = anycount(nonbiochild2_34 nonbiochild3_34 nonbiochild4_34 nonbiochild5_34 nonbiochild6_34 nonbiochild7_34 nonbiochild8_34 nonbiochild9_34 nonbiochild10_34), values(1)
replace nonbiochild_tot_34=. if (BCSAGE34SURVEY==.| hhrel2_34==-6)
label define nonbiochild_tot_34 0 "No non-biological children in HH" -100 "no participation in sweep" -99 "information not provided", replace 
label values nonbiochild_tot_34 nonbiochild_tot_34
label variable nonbiochild_tot_34 "Total number of non-biological children in household"
fre nonbiochild_tot_34

fre bd7ochhh //note that our derived measure for number of non-biological children in household is perfectly consistent with that already derived in the dataset.

//number of adopted (age 34)
cap drop adopt_tot_34
egen adopt_tot_34 = anycount(adopt2_34 adopt3_34 adopt4_34 adopt5_34 adopt6_34 adopt7_34 adopt8_34 adopt9_34 adopt10_34), values(1)
replace adopt_tot_34=. if (BCSAGE34SURVEY==.| hhrel2_34==-6)
label define adopt_tot_34 0 "No adopted children in HH" -100 "no participation in sweep" -99 "information not provided", replace 
label values adopt_tot_34 adopt_tot_34
label variable adopt_tot_34 "Total number of adopted children in household"
fre adopt_tot_34

//number of foster (age 34)
cap drop foster_tot_34
egen foster_tot_34 = anycount(foster2_34 foster3_34 foster4_34 foster5_34 foster6_34 foster7_34 foster8_34 foster9_34 foster10_34), values(1)
replace foster_tot_34=. if (BCSAGE34SURVEY==.| hhrel2_34==-6)
label define foster_tot_34 0 "No foster children in HH" -100 "no participation in sweep" -99 "information not provided", replace 
label values foster_tot_34 foster_tot_34
label variable foster_tot_34 "Total number of foster children in household"
fre foster_tot_34

//number of stepchildren (age 34)
cap drop step_tot_34
egen step_tot_34 = anycount(step2_34 step3_34 step4_34 step5_34 step6_34 step7_34 step8_34 step9_34 step10_34), values(1)
replace step_tot_34=. if (BCSAGE34SURVEY==.| hhrel2_34==-6)
label define step_tot_34 0 "No stepchildren in HH" -100 "no participation in sweep" -99 "information not provided", replace 
label values step_tot_34 step_tot_34
label variable step_tot_34 "Total number of stepchildren in household"
fre step_tot_34




***COMPUTE age of youngest and oldest non-biological child (age 34)
cap drop nonbiochildy_eldest_34 //years
gen nonbiochildy_eldest_34 = max(nonbiochildagey2_34, nonbiochildagey3_34, nonbiochildagey4_34, nonbiochildagey5_34, nonbiochildagey6_34, nonbiochildagey7_34, nonbiochildagey8_34, nonbiochildagey9_34, nonbiochildagey10_34)
replace nonbiochildy_eldest_34=-10 if anynonbio_34==0
replace nonbiochildy_eldest_34=. if (BCSAGE34SURVEY==.| hhrel2_34==-6)
label define nonbiochildy_eldest_34 -10 "No non-biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values nonbiochildy_eldest_34 nonbiochildy_eldest_34
label var nonbiochildy_eldest_34 "Age in years of eldest non-biological child"
fre nonbiochildy_eldest_34

cap drop nonbiochildy_youngest_34 //years
gen nonbiochildy_youngest_34 = min(nonbiochildagey2_34, nonbiochildagey3_34, nonbiochildagey4_34, nonbiochildagey5_34, nonbiochildagey6_34, nonbiochildagey7_34, nonbiochildagey8_34, nonbiochildagey9_34, nonbiochildagey10_34)
replace nonbiochildy_youngest_34=-10 if anynonbio_34==0
replace nonbiochildy_youngest_34=. if (BCSAGE34SURVEY==.| hhrel2_34==-6)
label define nonbiochildy_youngest_34 -10 "No non-biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values nonbiochildy_youngest_34 nonbiochildy_youngest_34
label var nonbiochildy_youngest_34 "Age in years of youngest non-biological child"
fre nonbiochildy_youngest_34




***COMPUTE total number of non-biological boys and girls (age 34)
//nonbiochildsex: 1=boy 2=girl

cap drop nonbiochildboy_total_34
egen nonbiochildboy_total_34 = anycount(nonbiochildsex2_34 nonbiochildsex3_34 nonbiochildsex4_34 nonbiochildsex5_34 nonbiochildsex6_34 nonbiochildsex7_34 nonbiochildsex8_34 nonbiochildsex9_34 nonbiochildsex10_34), values(1)
replace nonbiochildboy_total_34=-10 if anynonbio_34==0 //no non-biologial children
replace nonbiochildboy_total_34=. if (BCSAGE34SURVEY==.| hhrel2_34==-6)
label define nonbiochildboy_total_34 0 "Girls only" -10 "No non-biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values nonbiochildboy_total_34 nonbiochildboy_total_34
label var nonbiochildboy_total_34 "Total number of non-biological children who are boys"
fre nonbiochildboy_total_34 

cap drop nonbiochildgirl_total_34
egen nonbiochildgirl_total_34 = anycount(nonbiochildsex2_34 nonbiochildsex3_34 nonbiochildsex4_34 nonbiochildsex5_34 nonbiochildsex6_34 nonbiochildsex7_34 nonbiochildsex8_34 nonbiochildsex9_34 nonbiochildsex10_34), values(2)
replace nonbiochildgirl_total_34=-10 if anynonbio_34==0 //no non-biologial children
replace nonbiochildgirl_total_34=. if (BCSAGE34SURVEY==.| hhrel2_34==-6)
label define nonbiochildgirl_total_34 0 "Boys only" -10 "No non-biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values nonbiochildgirl_total_34 nonbiochildgirl_total_34
label var nonbiochildgirl_total_34 "Total number of non-biological children who are girls"
fre nonbiochildgirl_total_34 





*************************************************************
**** BIOLOGICAL AND NON BIOLOGICAL CHILDREN (age 34) ****
*************************************************************

***COMPUTE whether has any biological or non-biological (age 34)
cap drop anychildren_34
gen anychildren_34=.
replace anychildren_34=1 if anynonbio_34==1|anybiochildren_34==1
replace anychildren_34=0 if anynonbio_34==0 & anybiochildren_34==0
label define anychildren_34 0 "No" 1 "Yes" -100 "no participation in sweep" -99 "information not provided", replace
label values anychildren_34 anychildren_34
label values anychildren_34 anychildren_34
label var anychildren_34 "Whether CM has any children (biological or non-biological)"
fre anychildren_34 
fre anychildren_30


***COMPUTE total number of biological and non-biological children (age 34)
cap drop children_tot_34
gen children_tot_34=biochild_tot_34 + nonbiochild_tot_34
fre children_tot_34
label define children_tot_34 0 "No children (biological or non-biological)" -100 "no participation in sweep" -99 "information not provided", replace
label values children_tot_34 children_tot_34
label var children_tot_34 "Total number of children (biological or non-biological)"
fre children_tot_34
fre children_tot_30




***COMPUTE youngest and oldest biological or non-biological children (age 34)

//create temporary recoded variables 
foreach X of varlist biochildy_eldest_34 nonbiochildy_eldest_34 biochildy_youngest_34 nonbiochildy_youngest_34 {
cap drop `X'_R
clonevar `X'_R = `X'
replace `X'_R=. if `X'_R==-10	
fre `X'_R
}

cap drop childy_eldest_34 //years
gen childy_eldest_34 = max(biochildy_eldest_34_R, nonbiochildy_eldest_34_R)
replace childy_eldest_34=-10 if anybiochildren_34==0 & anynonbio_34==0
replace childy_eldest_34=. if (BCSAGE34SURVEY==.| hhrel2_34==-6)
replace childy_eldest_34=. if childy_eldest_34==30 //one child (this is a biological child) is age 37 which cannot be right so coded as missing
label define childy_eldest_34 -10 "No children (biological or non-biological)" -100 "no participation in sweep" -99 "information not provided", replace
label values childy_eldest_34 childy_eldest_34
label var childy_eldest_34 "Age in years of eldest child (biological or non-biological)"
fre childy_eldest_34


cap drop childy_youngest_34 //years
gen childy_youngest_34 = min(biochildy_youngest_34_R, nonbiochildy_youngest_34_R)
replace childy_youngest_34=-10 if anybiochildren_34==0 & anynonbio_34==0
replace childy_youngest_34=. if (BCSAGE34SURVEY==.| hhrel2_34==-6)
label define childy_youngest_34 -10 "No children (biological or non-biological)" -100 "no participation in sweep" -99 "information not provided", replace
label values childy_youngest_34 childy_youngest_34
label var childy_youngest_34 "Age in years of youngest child (biological or non-biological)"
fre childy_youngest_34

drop biochildy_eldest_34_R nonbiochildy_eldest_34_R biochildy_youngest_34_R nonbiochildy_youngest_34_R



***COMPUTE total number of male biological or non-biological children (age 34)
foreach X of varlist biochildboy_total_34 biochildgirl_total_34 nonbiochildboy_total_34 nonbiochildgirl_total_34 {
cap drop `X'_R
clonevar `X'_R = `X'
replace `X'_R=0 if `X'_R==-10	
}

fre biochildboy_total_34_R biochildgirl_total_34_R nonbiochildboy_total_34_R nonbiochildgirl_total_34_R

cap drop childboy_total_34
gen childboy_total_34 = biochildboy_total_34_R + nonbiochildboy_total_34_R
replace childboy_total_34=-10 if anybiochildren_34==0 & anynonbio_34==0  //no bio or non-bio children
replace childboy_total_34=. if anybiochildren_34==.|anynonbio_34==.  //no bio or non-bio children
replace childboy_total_34=. if (BCSAGE34SURVEY==.| hhrel2_34==-6)
label define childboy_total_34 0 "Girls only" -10 "No children (biological or non-biological)" -100 "no participation in sweep" -99 "information not provided", replace
drop biochildboy_total_34_R  nonbiochildboy_total_34_R
label values childboy_total_34 childboy_total_34
label var childboy_total_34 "Total number of children who are boys (biological or non-biological)"
fre childboy_total_34 

cap drop childgirl_total_34
gen childgirl_total_34 = biochildgirl_total_34_R + nonbiochildgirl_total_34_R
replace childgirl_total_34=-10 if anybiochildren_34==0 & anynonbio_34==0  //no bio or non-bio children
replace childgirl_total_34=. if anybiochildren_34==.|anynonbio_34==.  //no bio or non-bio children
replace childgirl_total_34=. if (BCSAGE34SURVEY==.| hhrel2_34==-6)
label define childgirl_total_34 0 "Boys only" -10 "No children (biological or non-biological)" -100 "no participation in sweep" -99 "information not provided", replace
drop biochildgirl_total_34_R  nonbiochildgirl_total_34_R
label values childgirl_total_34 childgirl_total_34
label var childgirl_total_34 "Total number of children who are girls (biological or non-biological)"
fre childgirl_total_34 





****COMPUTE partner child combo (age 34)

//partner and biological children (age 34)
cap drop partnerchildbio_34
gen partnerchildbio_34=.
replace partnerchildbio_34=1 if anybiochildren_34==0 & partner_34==0 //no partner and no children
replace partnerchildbio_34=2 if anybiochildren_34==0 & partner_34==1 //partner but no children
replace partnerchildbio_34=3 if anybiochildren_34==1 & partner_34==0 //no partner but children
replace partnerchildbio_34=4 if anybiochildren_34==1 & partner_34==1 //partner and children
label define partnerchildbio_34 1 "No partner or children" 2 "Partner and no children" 3 "Children and no partner" 4 "Partner and children" -100 "no participation in sweep" -99 "information not provided", replace
label values partnerchildbio_34 partnerchildbio_34
label var partnerchildbio_34 "Whether has partner and/or any biological children"
fre partnerchildbio_34


//partner and any bio or nonbio children (age 34)
cap drop partnerchildany_34
gen partnerchildany_34=.
replace partnerchildany_34=1 if anychildren_34==0 & partner_34==0 //no partner and no children
replace partnerchildany_34=2 if anychildren_34==0 & partner_34==1 //partner but no children
replace partnerchildany_34=3 if anychildren_34==1 & partner_34==0 //no partner but children
replace partnerchildany_34=4 if anychildren_34==1 & partner_34==1 //partner and children
label define partnerchildany_34 1 "No partner or children" 2 "Partner and no children" 3 "Children and no partner" 4 "Partner and children" -100 "no participation in sweep" -99 "information not provided", replace
label values partnerchildany_34 partnerchildany_34
label var partnerchildany_34 "Whether has partner and/or any biological or non-biological children"


save "$derived\BCS70_fertility_age34.dta", replace

use "$derived\BCS70_fertility_age34.dta", clear







**# Bookmark #4
*******************************************************************************
****************************** AGE 38 ***************************************** 
*******************************************************************************
  
use "$derived\BCS70_fertility_age34.dta", clear //age 26, 30 and 34 fertility data

merge 1:1 bcsid ///
using "$raw\bcs_2008_followup", keepusing (B8INTM B8INTY bd8spphh b8ms b8othrea b8hhsize b8everpg b8preg11 b8preg12 b8preg13 b8preg21 b8preg22 b8preg31 b8preg32 b8preg41 b8preg42 b8preg43 b8preg44 b8preg51 b8preg61 b8preg62 b8preg71 b8preg81 b8prgc11 b8prgc12 b8prgc13 b8prgc21 b8prgc22 b8prgc31 b8prgc32 b8prgc41 b8prgc42 b8prgc43 b8prgc44 b8prgc51 b8prgc61 b8prgc62 b8prgc71 b8prgc81 b8prgm11 b8prgm12 b8prgm13 b8prgm21 b8prgm22 b8prgm31 b8prgm32 b8prgm41 b8prgm42 b8prgm43 b8prgm44 b8prgm51 b8prgm61 b8prgm62 b8prgm71 b8prgm81 b8prgy11 b8prgy12 b8prgy13 b8prgy21 b8prgy22 b8prgy31 b8prgy32 b8prgy41 b8prgy42 b8prgy43 b8prgy44 b8prgy51 b8prgy61 b8prgy62 b8prgy71 b8prgy81 b8lhhn11 b8lhhn12 b8lhhn13 b8lhhn21 b8lhhn22 b8lhhn31 b8lhhn32 b8lhhn41 b8lhhn42 b8lhhn43 b8lhhn44 b8lhhn51 b8lhhn61 b8lhhn62 b8lhhn71 b8lhhn81 b8whpa02 b8whpa03 b8whpa04 b8whpa05 b8whpa06 b8whpa07 b8whpa08 b8whpa09 b8whpa10 b8whpa11 b8whpa12 b8whpa13 b8whpa14 b8whpa15 b8whpa16 b8whpa17 b8whpa18 b8whpa19 b8whpa20 b8whpa21 b8livh11 b8livh12 b8livh13 b8livh21 b8livh22 b8livh31 b8livh32 b8livh41 b8livh42 b8livh43 b8livh44 b8livh51 b8livh61 b8livh62 b8livh71 b8livh81 b8rtok02 b8rtok03 b8rtok04 b8rtok05 b8rtok06 b8rtok07 b8rtok08 b8rtok09 b8rtok10 b8rtok11 b8rtok12 b8pmth02 b8pmth03 b8pmth04 b8pmth05 b8pmth06 b8pmth07 b8pmth08 b8pmth09 b8pmth10 b8pmth11 b8pmth12 b8pyr02 b8pyr03 b8pyr04 b8pyr05 b8pyr06 b8pyr07 b8pyr08 b8pyr09 b8pyr10 b8pyr11 b8pyr12 b8rage02 b8rage03 b8rage04 b8rage05 b8rage06 b8rage07 b8rage08 b8rage09 b8rage10 b8rage11 b8rage12 b8sex02 b8sex03 b8sex04 b8sex05 b8sex06 b8sex07 b8sex08 b8sex09 b8sex10 b8sex11 b8sex12 b8nadp03 b8nadp04 b8nadp05 b8nadp06 b8nadp07 b8nadp08 b8nadp09 b8nadp10 b8nadp11 b8nadp12 b8whyl02 b8whyl03 b8whyl04 b8whyl05 b8whyl06 b8whyl07 b8whyl08 b8whyl09 b8whyl10 b8whyl11 b8whyl12 b8noth02 b8noth03 b8noth04 b8noth05 b8noth06 b8noth07 b8noth08 b8noth09 b8noth16 b8noth17 b8noth18 b8noth19 b8noth20 b8noth21 b8abdm01 b8abdy01 b8abdm03 b8abdy03 b8abdm04 b8abdy04 b8abdm05 b8abdy05 b8abdm06 b8abdy06 b8abdm07 b8abdy07 b8abdm08 b8abdy08 b8abdm09 b8abdy09 b8abdm10 b8abdy10 b8abdm11 b8abdy11 b8abdm12 b8abdy12 b8abdm13 b8abdy13 b8abdm14 b8abdy14 b8abdm15 b8abdy15 b8abdm16 b8abdy16 b8abdm17 b8abdy17 b8abdm18 b8abdy18 b8abdm19 b8abdy19 b8abdm20 b8abdy20 b8abdm21 b8abdy21 bd8spphh b8numch b8numadh b8anychd b8anyfst b8numadp b8chd006 b8ownchd bd8nchhh bd8ochhh b8abre02 b8abre03 b8abre04 b8abre05 b8abre06 b8abre07 b8abre08 b8abre09 b8abre16 b8abre17 b8abre18 b8abre19 b8abre20 b8abre21 b8abpn02 b8abpn03 b8abpn04 b8abpn05 b8abpn06 b8abpn07 b8abpn08 b8abpn09 b8abpn16 b8abpn17 b8abpn18 b8abpn19 b8abpn20 b8abpn21 b8cmchhm)
drop _merge


gen BCSAGE38SURVEY=1 if B8INTY!=.  //age 38 survey participation
label var BCSAGE38SURVEY "Whether took part in age 38 survey"


****************************** AGE 38 ***************************************** 
*******************************************************************************
//N=8,874
//note: it asks about pregnancies since last interview/since age 16. So this could be any previous sweep.


//interview date (age 38)
fre B8INTM B8INTY
rename (B8INTM B8INTY) (intmonth_38 intyear_38)

label var intyear_38 "Interview year (age 38)"
label define intyear_38 -100 "no participation in sweep" -99 "information not provided", replace
label values intyear_38 intyear_38
fre intyear_38


label var intmonth_38 "Interview month (age 30=8)"
label define intmonth_38 1 "January" 2	"February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "	October" 11 "November" 12 "December" -100 "no participation in sweep" -99 "information not provided", replace
label values intmonth_38 intmonth_38

//whether lives with spouse or partner (age 38)
fre bd8spphh
rename bd8spphh partner_38
replace partner_38=. if partner_38<0
label var partner_38 "Whether CM has current partner in hhld"
label define partner_38 0 "No" 1 "Yes" -100 "no participation in sweep" -99 "information not provided", replace
label values partner_38 partner_38
fre partner_38

//marital status (age 38)
fre b8ms
cap drop marital_38
gen marital_38=.
replace marital_38=3 if b8ms==1|b8ms==4|b8ms==5|b8ms==6
replace marital_38=2 if (b8ms==1|b8ms==4|b8ms==5|b8ms==6) & partner_38==1
replace marital_38=1 if b8ms==2|b8ms==3
label define marital_38 3 "Single non-cohabiting" 2 "Single cohabiting with partner" 1 "Married" -100 "no participation in sweep" -99 "information not provided", replace
label values marital_38 marital_38
label variable marital_38 "Marital status (age 38)" 
fre marital_38




*********RENAMING, RECODING AND PREPPING USE VARIABLES********* 

//PREGNANCY DATA (age 38)

//pregnant since last interview (age 38)
fre b8everpg
rename b8everpg pregsincelast_38
replace pregsincelast_38=. if pregsincelast_38<0
replace pregsincelast_38=0 if pregsincelast_38==2
fre pregsincelast_38

//outcome of pregnancy (age 38)
rename (b8preg11 b8preg12 b8preg13 b8preg21 b8preg22 b8preg31 b8preg32 b8preg41 b8preg42 b8preg43 b8preg44 b8preg51 b8preg61 b8preg62 b8preg71 b8preg81) (prego11_38 prego12_38 prego13_38 prego21_38 prego22_38 prego31_38 prego32_38 prego41_38 prego42_38 prego43_38 prego44_38 prego51_38 prego61_38 prego62_38 prego71_38 prego81_38)

//child's sex (age 38)
rename (b8prgc11 b8prgc12 b8prgc13 b8prgc21 b8prgc22 b8prgc31 b8prgc32 b8prgc41 b8prgc42 b8prgc43 b8prgc44 b8prgc51 b8prgc61 b8prgc62 b8prgc71 b8prgc81) ///
(pregs11_38 pregs12_38 pregs13_38 pregs21_38 pregs22_38 pregs31_38 pregs32_38 pregs41_38 pregs42_38 pregs43_38 pregs44_38 pregs51_38 pregs61_38 pregs62_38 pregs71_38 pregs81_38)

//child's month of birth (age 38)
rename (b8prgm11 b8prgm12 b8prgm13 b8prgm21 b8prgm22 b8prgm31 b8prgm32 b8prgm41 b8prgm42 b8prgm43 b8prgm44 b8prgm51 b8prgm61 b8prgm62 b8prgm71 b8prgm81) ///
(pregm11_38 pregm12_38 pregm13_38 pregm21_38 pregm22_38 pregm31_38 pregm32_38 pregm41_38 pregm42_38 pregm43_38 pregm44_38 pregm51_38 pregm61_38 pregm62_38 pregm71_38 pregm81_38)

//child's year of birth (age 38)
rename ///
(b8prgy11 b8prgy12 b8prgy13 b8prgy21 b8prgy22 b8prgy31 b8prgy32 b8prgy41 b8prgy42 b8prgy43 b8prgy44 b8prgy51 b8prgy61 b8prgy62 b8prgy71 b8prgy81) ///
(pregy11_38 pregy12_38 pregy13_38 pregy21_38 pregy22_38 pregy31_38 pregy32_38 pregy41_38 pregy42_38 pregy43_38 pregy44_38 pregy51_38 pregy61_38 pregy62_38 pregy71_38 pregy81_38) 



*RECODE all variables to missing if not a live birth (age 38)
foreach C in 11_38 12_38 13_38 21_38 22_38 31_38 32_38 41_38 42_38 43_38 44_38 51_38 61_38 62_38 71_38 81_38 {
foreach X of varlist pregs`C' pregm`C' pregy`C' {
replace	`X'=. if prego`C'!=1|pregsincelast_38==0
label define prego`C' 1 "Live birth", replace
label values prego`C' prego`C'
replace	pregs`C'=. if pregs`C'==-1|pregs`C'==.|pregsincelast_38==. //sex
replace	pregm`C'=. if pregm`C'<0
replace	pregy`C'=. if pregy`C'<0

fre prego`C' pregs`C' pregm`C' pregy`C'
}
}



//HH GRID (age 38)
rename ///
(b8lhhn11 b8lhhn12 b8lhhn13 b8lhhn21 b8lhhn22 b8lhhn31 b8lhhn32 b8lhhn41 b8lhhn42 b8lhhn43 b8lhhn44 b8lhhn51 b8lhhn61 b8lhhn62 b8lhhn71 b8lhhn81) ///
(pnum11_38 pnum12_38 pnum13_38 pnum21_38 pnum22_38 pnum31_38 pnum32_38 pnum41_38 pnum42_38 pnum43_38 pnum44_38 pnum51_38 pnum61_38 pnum62_38 pnum71_38 pnum81_38) 

rename (b8rtok02 b8rtok03 b8rtok04 b8rtok05 b8rtok06 b8rtok07 b8rtok08 b8rtok09 b8rtok10 b8rtok11 b8rtok12) (hhrel2_38 hhrel3_38 hhrel4_38 hhrel5_38 hhrel6_38 hhrel7_38 hhrel8_38 hhrel9_38 hhrel10_38 hhrel11_38 hhrel12_38) //relationship to cm

rename (b8sex02 b8sex03 b8sex04 b8sex05 b8sex06 b8sex07 b8sex08 b8sex09 b8sex10 b8sex11 b8sex12) (hhsex2_38 hhsex3_38 hhsex4_38 hhsex5_38 hhsex6_38 hhsex7_38 hhsex8_38 hhsex9_38 hhsex10_38 hhsex11_38 hhsex12_38) //sex of person

rename (b8rage02 b8rage03 b8rage04 b8rage05 b8rage06 b8rage07 b8rage08 b8rage09 b8rage10 b8rage11 b8rage12) (hhage2_38 hhage3_38 hhage4_38 hhage5_38 hhage6_38 hhage7_38 hhage8_38 hhage9_38 hhage10_38 hhage11_38 hhage12_38) //age in years

rename (b8pmth02 b8pmth03 b8pmth04 b8pmth05 b8pmth06 b8pmth07 b8pmth08 b8pmth09 b8pmth10 b8pmth11 b8pmth12) (hhagebm2_38 hhagebm3_38 hhagebm4_38 hhagebm5_38 hhagebm6_38 hhagebm7_38 hhagebm8_38 hhagebm9_38 hhagebm10_38 hhagebm11_38 hhagebm12_38) //birth month

rename (b8pyr02 b8pyr03 b8pyr04 b8pyr05 b8pyr06 b8pyr07 b8pyr08 b8pyr09 b8pyr10 b8pyr11 b8pyr12) (hhageby2_38 hhageby3_38 hhageby4_38 hhageby5_38 hhageby6_38 hhageby7_38 hhageby8_38 hhageby9_38 hhageby10_38 hhageby11_38 hhageby12_38) //birth year



//ABSENT CHILD GRID (age 38)
rename (b8abre02 b8abre03 b8abre04 b8abre05 b8abre06 b8abre07 b8abre08 b8abre09 b8abre16 b8abre17 b8abre18 b8abre19 b8abre20 b8abre21) (absrel02_38 absrel03_38 absrel04_38 absrel05_38 absrel06_38 absrel07_38 absrel08_38 absrel09_38 absrel16_38 absrel17_38 absrel18_38 absrel19_38 absrel20_38 absrel21_38)

rename (b8abpn02 b8abpn03 b8abpn04 b8abpn05 b8abpn06 b8abpn07 b8abpn08 b8abpn09 b8abpn16 b8abpn17 b8abpn18 b8abpn19 b8abpn20 b8abpn21) (abspnum02_38 abspnum03_38 abspnum04_38 abspnum05_38 abspnum06_38 abspnum07_38 abspnum08_38 abspnum09_38 abspnum16_38 abspnum17_38 abspnum18_38 abspnum19_38 abspnum20_38 abspnum21_38)




***COMPUTE current age in whole years and whole months (respectively) of each biochild from birth year and month, and interview month and year. And age of cohort member at birth of child in whole years and in months as well. (age 38)

//interview date (age 38)
fre intyear_38
fre intmonth_38
cap drop intym_38
gen intym_38 = ym(intyear_38,intmonth_38)
label var intym_38 "Interview date - months since Jan 1960"
fre intym_38

//cohort member birthdate (age 38)
cap drop cmbirthy_38
gen cmbirthy_38=1970
label var cmbirthy_38 "Birth year of CM"
fre cmbirthy_38

cap drop cmbirthm_38
gen cmbirthm_38=4
label var cmbirthm_38 "Birth month of CM"
fre cmbirthm_38

cap drop cmbirthym_38
gen cmbirthym_38 = ym(cmbirthy_38,cmbirthm_38)
label var cmbirthym_38 "CM birth date - months since Jan 1960"
fre cmbirthym_38

//CM age in years (age 38)
cap drop cmagey_38
gen cmagey_38=(intym_38-cmbirthym_38)/12
replace cmagey_38 = floor(cmagey_38)
fre cmagey_38 
label var cmagey_38 "CM age at interview"


foreach C in 11_38 12_38 13_38 21_38 22_38 31_38 32_38 41_38 42_38 43_38 44_38 51_38 61_38 62_38 71_38 81_38 {

cap drop biochildym`C'
gen biochildym`C' = ym(pregy`C',pregm`C') 
label var biochildym`C' "`C' Date of birth of biological child - months since Jan 1960"
fre biochildym`C'

//child's age in whole years at interview (age 38)
cap drop biochildagey`C'
gen biochildagey`C' = (intym_38-biochildym`C')/12
fre biochildagey`C'
replace biochildagey`C' = floor(biochildagey`C')
replace biochildagey`C' =0 if biochildagey`C'<0
label var biochildagey`C' "`C' Age in whole years of biological child"
fre biochildagey`C'

//cm age in whole years at birth of child (age 38)
cap drop cmageybirth`C'
gen cmageybirth`C' = (biochildym`C'-cmbirthym_38)/12
fre cmageybirth`C'
replace cmageybirth`C' = floor(cmageybirth`C')
label var cmageybirth`C' "`C' Age of CM in years at birth of biological child `C'"
fre cmageybirth`C'
}




*** ADJUSTING AGE OF PREVIOUSLY REPORTED CHILDREN TO DATE OF INTERVIEW (age 38)

*** AGE 26 CHILDREN: children reported previously at age 26 updated with their age at 34
foreach C in 2_26 3_26 4_26 5_26 6_26 7_26 8_26 9_26 10_26 {

//child's age in whole years at age 38 interview
cap drop biochildagey`C'
gen biochildagey`C'=biohhage`C' + (cmagey_38-cmagey_26)
label var biochildagey`C' "`C' Age in whole years of biological child"
fre biochildagey`C'
}


//***AGE 30 CHILDREN: children reported previously at age 30 updated with their age at 34
foreach C in 11 12 13 14 15 21 22 23 31 32 41 42 51 52 53 61 62 71 81 {

//child's age in whole years at age 38 interview
cap drop biochildagey`C'_30
gen biochildagey`C'_30 = (intym_38-biochildym`C'_30)/12
fre biochildagey`C'_30
replace biochildagey`C'_30 = floor(biochildagey`C'_30)
label var biochildagey`C'_30 "`C' Age in whole years of biological child"
fre biochildagey`C'_30
}


//***AGE 34 CHILDREN: children reported previously at age 34 updated with their age at 38
foreach C in 11 12 13 21 22 23 31 32 41 51 61 71 81 {

//child's age in whole years at age 34 interview
cap drop biochildagey`C'_34
gen biochildagey`C'_34 = (intym_38-biochildym`C'_34)/12
fre biochildagey`C'_34
replace biochildagey`C'_34 = floor(biochildagey`C'_34)
label var biochildagey`C'_34 "`C' Age in whole years of biological child"
fre biochildagey`C'_34
}





******************************************************************
****BIOLOGICAL CHILDREN (age 38)********************************* 
******************************************************************

***COMPUTE total number of biological children (age 38)
//this is just temporary as these will be added to last interview
cap drop anybiochildren_38
egen anybiochildren_38 =anycount(prego11_38 prego12_38 prego13_38 prego21_38 prego22_38 prego31_38 prego32_38 prego41_38 prego42_38 prego43_38 prego44_38 prego51_38 prego61_38 prego62_38 prego71_38 prego81_38), values(1)
replace anybiochildren_38=. if pregsincelast_38==.
label variable anybiochildren_38 "Total number of biological children since last at age 38"
fre anybiochildren_38 //N=8,853


//Figuring out which data to add the new children to (age 38)
fre BCSAGE34SURVEY_34 BCSAGE26SURVEY_26 BCSAGE30SURVEY_30 BCSAGE38SURVEY
rename BCSAGE38SURVEY BCSAGE38SURVEY_38

*since sweep 16
cap drop preg_16_38
gen preg_16_38=.
replace preg_16_38=1 if anybiochildren_26==. &  anybiochildren_30==. &  anybiochildren_34==. &  anybiochildren_38!=.
fre preg_16_38 //N=207

cap drop sweep16_38
gen sweep16_38=.
replace sweep16_38=1 if BCSAGE26SURVEY_26==. &  BCSAGE30SURVEY_30==. &  BCSAGE34SURVEY_34==. &  BCSAGE38SURVEY_38!=.
fre sweep16_38 //N=161


*since sweep 26
cap drop preg_26_38
gen preg_26_38=.
replace preg_26_38=1 if anybiochildren_26!=. & anybiochildren_30==. &  anybiochildren_34==. & anybiochildren_38!=.
fre preg_26_38 //N=131

cap drop sweep26_38
gen sweep26_38=.
replace sweep26_38=1 if BCSAGE26SURVEY_26!=. & BCSAGE30SURVEY_30==. &  BCSAGE34SURVEY_34==. & BCSAGE38SURVEY_38!=.
fre sweep26_38 //N=143


*since sweep 30
cap drop preg_30_38
gen preg_30_38=.
replace preg_30_38=1 if anybiochildren_30!=. &  anybiochildren_34==. & anybiochildren_38!=.
fre preg_30_38 //N=767

cap drop sweep30_38
gen sweep30_38=.
replace sweep30_38=1 if BCSAGE30SURVEY_30!=. &  BCSAGE34SURVEY_34==. & BCSAGE38SURVEY_38!=.
fre sweep30_38 //N=771


*since sweep 34
cap drop preg_34_38
gen preg_34_38=.
replace preg_34_38=1 if anybiochildren_34!=. & anybiochildren_38!=.
fre preg_34_38 //N=7748

cap drop sweep34_38
gen sweep34_38=.
replace sweep34_38=1 if BCSAGE34SURVEY_34!=. & BCSAGE38SURVEY_38!=.
fre sweep34_38 //N=7799



***COMPUTE total number of biological children (age 38)
//since age 16
cap drop biochild_total_A
egen biochild_total_A =anycount(prego11_38 prego12_38 prego13_38 prego21_38 prego22_38 prego31_38 prego32_38 prego41_38 prego42_38 prego43_38 prego44_38 prego51_38 prego61_38 prego62_38 prego71_38 prego81_38), values(1)
replace biochild_total_A=. if sweep16_38==.|preg_16_38==. 
replace biochild_total_A= biochild_total_A
fre biochild_total_A //N=158

//since age 26
cap drop biochild_total_B
egen biochild_total_B =anycount(prego11_38 prego12_38 prego13_38 prego21_38 prego22_38 prego31_38 prego32_38 prego41_38 prego42_38 prego43_38 prego44_38 prego51_38 prego61_38 prego62_38 prego71_38 prego81_38), values(1)
replace biochild_total_B=. if sweep26_38==.|preg_26_38==. 
replace biochild_total_B= biochild_total_B + biochild_tot_26
fre biochild_total_B //N=128

//since age 30
cap drop biochild_total_C
egen biochild_total_C =anycount(prego11_38 prego12_38 prego13_38 prego21_38 prego22_38 prego31_38 prego32_38 prego41_38 prego42_38 prego43_38 prego44_38 prego51_38 prego61_38 prego62_38 prego71_38 prego81_38), values(1)
replace biochild_total_C=. if sweep30_38==.|preg_30_38==. 
replace biochild_total_C= biochild_total_C + biochild_tot_30
fre biochild_total_C //N=763

//since age 34
cap drop biochild_total_D
egen biochild_total_D =anycount(prego11_38 prego12_38 prego13_38 prego21_38 prego22_38 prego31_38 prego32_38 prego41_38 prego42_38 prego43_38 prego44_38 prego51_38 prego61_38 prego62_38 prego71_38 prego81_38), values(1)
replace biochild_total_D=. if sweep34_38==.|preg_34_38==. 
replace biochild_total_D= biochild_total_D + biochild_tot_34
fre biochild_total_D //N=7748




// COMPUTE age 38 total children
fre biochild_total_A biochild_total_B biochild_total_C biochild_total_D

cap drop included
gen included=.
replace included=1 if biochild_total_A!=.
replace included=1 if biochild_total_B!=.
replace included=1 if biochild_total_C!=.
replace included=1 if biochild_total_D!=.
fre included //N=8,392

cap drop biochild_tot_38
egen biochild_tot_38=rowtotal(biochild_total_A biochild_total_B biochild_total_C biochild_total_D)
replace biochild_tot_38=. if included==.
fre biochild_tot_38
label define biochild_tot_38 0 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values biochild_tot_38 biochild_tot_38
label variable biochild_tot_38 "Total number of biological children"
fre biochild_tot_38 //N=9,392
fre biochild_tot_34
fre biochild_tot_30
fre biochild_tot_26



*-----------------------------------------------------*
*** CHECKING EXTRA BIOLOGICAL CHILDREN IN HOUSEHOLD NOT REPORTED AS PREGNANCY (age 38)

***COMPUTE total number of biological children reported in hh grid (age 38)
cap drop biochildhh_total_38
egen biochildhh_total_38 = anycount(hhrel2_38 hhrel3_38 hhrel4_38 hhrel5_38 hhrel6_38 hhrel7_38 hhrel8_38 hhrel9_38 hhrel10_38 hhrel11_38 hhrel12_38), values(4)
replace biochildhh_total_38=. if (BCSAGE38SURVEY_38==.| b8hhsize==-1)
replace biochildhh_total_38=. if  anybiochildren_38==.
 //code to missing if not in age 38 sweep or didn't complete HH grid
label variable biochildhh_total_38 "Total number of biological children in HH grid age 38"
fre biochildhh_total_38


clonevar biohhgrid_total_38 = biochildhh_total_38 //creating a variable for the original hhgrid total number of bio children


//computing difference in pregnancy data and household data

cap drop biochild_tot_miss_38
gen biochild_tot_miss_38=1 if biochild_tot_38==. //this creates a missing values flag for this variable

replace biochild_tot_38=0 if biochild_tot_38==. // this bit is important as crucial for the inclusion of all HH grid data in adjustments for extra children 

fre biochild_tot_38 biochildhh_total_38
tab biochild_tot_38 biochildhh_total_38, mi
cap drop difference_38
gen difference_38=biochild_tot_38 - biochildhh_total_38
fre difference_38


//creating a variable that flags CMs with differences
cap drop biochild_extra_flag_38
gen biochild_extra_flag_38=.
label var biochild_extra_flag_38 "Flag: More bio children reported in HH grid than in pregnancy data"
replace biochild_extra_flag_38=1 if inrange(difference_38, -10,-1)
replace biochild_extra_flag_38=0 if inrange(difference_38, 0,20)
label define biochild_extra_flag_38 1 "Yes" 0 "No" -100 "no participation in sweep" -99 "information not provided", replace
label values biochild_extra_flag_38 biochild_extra_flag_38
fre biochild_extra_flag_38 //applies to 117 CMs 

//creating variable to use for adjustment of total children
cap drop bioextra_38
gen bioextra_38=difference_38
replace bioextra_38=0 if inrange(difference_38,0,10)
replace bioextra_38=1 if difference_38==-1
replace bioextra_38=2 if difference_38==-2
replace bioextra_38=3 if difference_38==-3
replace bioextra_38=4 if difference_38==-4
replace bioextra_38=5 if difference_38==-5
replace bioextra_38=6 if difference_38==-6
replace bioextra_38=7 if difference_38==-7
fre bioextra_38



******ADJUSTING 
cap drop bioextra_miss_38
gen bioextra_miss_38=1 if bioextra_38==. //missing values flag 
fre bioextra_miss_38
replace bioextra_38=0 if bioextra_38==.

fre biochild_tot_miss_38 //already created a missing flag for this

//TOTAL NUMBER OF CHILDREN (age 38)
fre biochild_tot_38 bioextra_38
replace biochild_tot_38=biochild_tot_38 + bioextra_38
replace biochild_tot_38=. if biochild_tot_miss_38== 1 //& bioextra_miss_38==1
fre biochild_tot_38

//ANY BIO CHILDREN (age 38)
cap drop anybiochildren_38
gen anybiochildren_38=.
replace anybiochildren_38=1 if inrange(biochild_tot_38,1,20)
replace anybiochildren_38=0 if biochild_tot_38==0
label define yesno 0 "No" 1 "Yes" -100 "no participation in sweep" -99 "information not provided", replace
label values anybiochildren_38 yesno
fre anybiochildren_38



//WHERE LIVE (age 38)

*in household (age 38)
fre biochildhh_total_38

*not in household (age 38)
fre biochild_tot_38 biochildhh_total_38
cap drop biochildnonhh_total_38
gen biochildnonhh_total_38=biochild_tot_38-biochildhh_total_38
replace biochildnonhh_total_38=-10 if anybiochildren_38==0
label variable biochildnonhh_total_38 "Total number of bio children not in household age 38"
label define biochildnonhh_total_38 0 "All biological children live in household" -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildnonhh_total_38 biochildnonhh_total_38
fre biochildnonhh_total_38

*recoding and labelling biochildhh_total_38
replace biochildhh_total_38=-10 if anybiochildren_38==0
replace biochildhh_total_38=. if anybiochildren_38==.
label define biochildhh_total_38 0 "None of the biological children live in household" -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildhh_total_38 biochildhh_total_38
fre biochildhh_total_38






*******************************************************
*** OTHER PARENT OF CHILDREN IS CURRENT PARTNER (age 38)
*******************************************************
*** OTHER PARENT OF BIOLOGICAL CHILDREN

fre b8othrea // 2 no non-residential relationship 
fre partner_38 //0 no partner

*children in household (age 38) (we use HH grid data as we cannot use pregnancy data as we don't know parental status of children reported in previous sweeps)
foreach C in 2 3 4 5 6 7 8 9 {
cap drop biochildhhpar`C'_38
gen biochildhhpar`C'_38=.
replace biochildhhpar`C'_38=1 if b8whpa0`C'==1 & hhrel`C'_38==4
replace biochildhhpar`C'_38=2 if (b8whpa0`C'==2)|(partner_38==0 & b8othrea==2) & hhrel`C'_38==4
label var biochildhhpar`C'_38 "`C'_38 Who is other parent to biologial child in household"
label define biochildhhpar`C'_38 1 "Current partner" 2 "Previous partner", replace
label values biochildhhpar`C'_38 biochildhhpar`C'_38
fre biochildhhpar`C'_38
}

foreach C in 10 11 12 {
cap drop biochildhhpar`C'_38
gen biochildhhpar`C'_38=.
replace biochildhhpar`C'_38=1 if b8whpa`C'==1 & hhrel`C'_38==4
replace biochildhhpar`C'_38=2 if (b8whpa`C'==2)|(partner_38==0 & b8othrea==2) & hhrel`C'_38==4
label var biochildhhpar`C'_38 "`C'_38 Who is other parent to biologial child in household"
label define biochildhhpar`C'_38 1 "Current partner" 2 "Previous partner", replace
label values biochildhhpar`C'_38 biochildhhpar`C'
fre biochildhhpar`C'_38
}


*children outside household (age 38) (we use absent child grid, which includes new and previously reported children)
foreach C in 02_38 03_38 04_38 05_38 06_38 07_38 08_38 09_38 16_38 17_38 18_38 19_38 20_38 21_38 {

cap drop absbiopar`C'
gen absbiopar`C'=.
label var absbiopar`C' "Who other parent to biological child not living in household"
label define absbiopar`C' 1 "Current partner" 2 "Previous partner", replace
label values absbiopar`C' absbiopar`C'

//current partner
replace absbiopar`C'=1 if abspnum`C'==2 & absrel`C'==4 & b8whpa02==1
replace absbiopar`C'=1 if abspnum`C'==3 & absrel`C'==4 & b8whpa03==1
replace absbiopar`C'=1 if abspnum`C'==4 & absrel`C'==4 & b8whpa04==1
replace absbiopar`C'=1 if abspnum`C'==5 & absrel`C'==4 & b8whpa05==1
replace absbiopar`C'=1 if abspnum`C'==6 & absrel`C'==4 & b8whpa06==1
replace absbiopar`C'=1 if abspnum`C'==7 & absrel`C'==4 & b8whpa07==1
replace absbiopar`C'=1 if abspnum`C'==8 & absrel`C'==4 & b8whpa08==1
replace absbiopar`C'=1 if abspnum`C'==9 & absrel`C'==4 & b8whpa09==1
replace absbiopar`C'=1 if abspnum`C'==16 & absrel`C'==4 & b8whpa16==1
replace absbiopar`C'=1 if abspnum`C'==17 & absrel`C'==4 & b8whpa17==1
replace absbiopar`C'=1 if abspnum`C'==18 & absrel`C'==4 & b8whpa18==1
replace absbiopar`C'=1 if abspnum`C'==19 & absrel`C'==4 & b8whpa19==1
replace absbiopar`C'=1 if abspnum`C'==20 & absrel`C'==4 & b8whpa20==1
replace absbiopar`C'=1 if abspnum`C'==21 & absrel`C'==4 & b8whpa21==1

//previous partner
replace absbiopar`C'=2 if (abspnum`C'==2 & absrel`C'==4 & b8whpa02==2) 
replace absbiopar`C'=2 if (abspnum`C'==3 & absrel`C'==4 & b8whpa03==2) 
replace absbiopar`C'=2 if (abspnum`C'==4 & absrel`C'==4 & b8whpa04==2) 
replace absbiopar`C'=2 if (abspnum`C'==5 & absrel`C'==4 & b8whpa05==2) 
replace absbiopar`C'=2 if (abspnum`C'==6 & absrel`C'==4 & b8whpa06==2) 
replace absbiopar`C'=2 if (abspnum`C'==7 & absrel`C'==4 & b8whpa07==2) 
replace absbiopar`C'=2 if (abspnum`C'==8 & absrel`C'==4 & b8whpa08==2) 
replace absbiopar`C'=2 if (abspnum`C'==9 & absrel`C'==4 & b8whpa09==2) 
replace absbiopar`C'=2 if (abspnum`C'==16 & absrel`C'==4 & b8whpa16==2) 
replace absbiopar`C'=2 if (abspnum`C'==17 & absrel`C'==4 & b8whpa17==2) 
replace absbiopar`C'=2 if (abspnum`C'==18 & absrel`C'==4 & b8whpa18==2) 
replace absbiopar`C'=2 if (abspnum`C'==19 & absrel`C'==4 & b8whpa19==2) 
replace absbiopar`C'=2 if (abspnum`C'==20 & absrel`C'==4 & b8whpa20==2) 
replace absbiopar`C'=2 if (abspnum`C'==21 & absrel`C'==4 & b8whpa21==2) 

fre absbiopar`C'
}



***COMPUTE number of children whose parent is PREVIOUS partner (age 38)
cap drop biochildprev_total_38
egen biochildprev_total_38 = anycount(biochildhhpar2_38 biochildhhpar3_38 biochildhhpar4_38 biochildhhpar5_38 biochildhhpar6_38 biochildhhpar7_38 biochildhhpar8_38 biochildhhpar9_38 biochildhhpar10_38 biochildhhpar11_38 biochildhhpar12_38 absbiopar02_38 absbiopar03_38 absbiopar04_38 absbiopar05_38 absbiopar06_38 absbiopar07_38 absbiopar08_38 absbiopar09_38 absbiopar16_38 absbiopar17_38 absbiopar18_38 absbiopar19_38 absbiopar20_38 absbiopar21_38), values(2)
fre biochildprev_total_38 
replace biochildprev_total_38=. if BCSAGE38SURVEY_38==.|b8cmchhm==-1
replace biochildprev_total_38=-10 if anybiochildren_38==0 
label define biochildprev_total_38 0 "Current partner is parent to all biological children" -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildprev_total_38 biochildprev_total_38
label var biochildprev_total_38 "Total number of biological children had with a previous partner"
fre biochildprev_total_38 
fre biochildprev_total_34
fre biochildprev_total_30


//whether a previous partner is parent to any children (age 38)
cap drop biochildprevany_38
gen biochildprevany_38=.
replace biochildprevany_38=1 if inrange(biochildprev_total_38,1,10)
replace biochildprevany_38=0 if biochildprev_total_38==0
replace biochildprevany_38=-10 if biochildprev_total_38==-10
label variable biochildprevany_38 "Any children with a previous partner"
label define biochildprevany_38 1 "Previous partner(s) parent to all or some biological children" 0 "Current partner is parent to all biological children" -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildprevany_38 biochildprevany_38
fre biochildprevany_38 if biochildprevany_38!=-10

fre biochildprevany_34 if biochildprevany_34!=-10
fre biochildprevany_30 if biochildprevany_30!=-10
fre biochildprevany_26 if biochildprevany_26!=-10


****************************************************
*** SEX OF BIOLOGICAL CHILDREN (age 38)
****************************************************

*BOYS (age 38)
cap drop Rbiochildboy_total_26
clonevar Rbiochildboy_total_26 = biochildboy_total_26
replace Rbiochildboy_total_26=0 if Rbiochildboy_total_26==-10

cap drop Rbiochildboy_total_30
clonevar Rbiochildboy_total_30 = biochildboy_total_30
replace Rbiochildboy_total_30=0 if Rbiochildboy_total_30==-10

cap drop Rbiochildboy_total_34
clonevar Rbiochildboy_total_34 = biochildboy_total_34
replace Rbiochildboy_total_34=0 if Rbiochildboy_total_34==-10


//since age 34
cap drop biochildboy_total_A
egen biochildboy_total_A =anycount(pregs11_38 pregs12_38 pregs13_38 pregs21_38 pregs22_38 pregs31_38 pregs32_38 pregs41_38 pregs42_38 pregs43_38 pregs44_38 pregs51_38 pregs61_38 pregs62_38 pregs71_38 pregs81_38), values(1)
replace biochildboy_total_A=. if sweep34_38==.|preg_34_38==. 
replace biochildboy_total_A= biochildboy_total_A + Rbiochildboy_total_34
fre biochildboy_total_A //N=7748

//since age 30
cap drop biochildboy_total_B
egen biochildboy_total_B =anycount(pregs11_38 pregs12_38 pregs13_38 pregs21_38 pregs22_38 pregs31_38 pregs32_38 pregs41_38 pregs42_38 pregs43_38 pregs44_38 pregs51_38 pregs61_38 pregs62_38 pregs71_38 pregs81_38), values(1)
replace biochildboy_total_B=. if sweep30_38==.|preg_30_38==. 
replace biochildboy_total_B= biochildboy_total_B + Rbiochildboy_total_30
fre biochildboy_total_B //N=763

//since age 26
cap drop biochildboy_total_C
egen biochildboy_total_C =anycount(pregs11_38 pregs12_38 pregs13_38 pregs21_38 pregs22_38 pregs31_38 pregs32_38 pregs41_38 pregs42_38 pregs43_38 pregs44_38 pregs51_38 pregs61_38 pregs62_38 pregs71_38 pregs81_38), values(1)
replace biochildboy_total_C=. if sweep26_38==.|preg_26_38==. 
replace biochildboy_total_C= biochildboy_total_C + Rbiochildboy_total_26
fre biochildboy_total_C //N=128

//since age 16
cap drop biochildboy_total_D
egen biochildboy_total_D =anycount(pregs11_38 pregs12_38 pregs13_38 pregs21_38 pregs22_38 pregs31_38 pregs32_38 pregs41_38 pregs42_38 pregs43_38 pregs44_38 pregs51_38 pregs61_38 pregs62_38 pregs71_38 pregs81_38), values(1)
replace biochildboy_total_D=. if sweep16_38==.|preg_16_38==. 
replace biochildboy_total_D=biochildboy_total_D
fre biochildboy_total_D //N=158


// COMPUTE age 34 total boys
fre biochildboy_total_A biochildboy_total_B biochildboy_total_C biochildboy_total_D

cap drop biochildboy_total_38
egen biochildboy_total_38=rowtotal(biochildboy_total_A biochildboy_total_B biochildboy_total_C biochildboy_total_D)
replace biochildboy_total_38=. if included==.
fre biochildboy_total_38
label define biochildboy_total_38 0 "Girls only" -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildboy_total_38 biochildboy_total_38
label variable biochildboy_total_38 "Total number of biological boys"
fre biochildboy_total_38 //N=8,797




*GIRLS (age 38)
cap drop Rbiochildgirl_total_26
clonevar Rbiochildgirl_total_26 = biochildgirl_total_26
replace Rbiochildgirl_total_26=0 if Rbiochildgirl_total_26==-10

cap drop Rbiochildgirl_total_30
clonevar Rbiochildgirl_total_30 = biochildgirl_total_30
replace Rbiochildgirl_total_30=0 if Rbiochildgirl_total_30==-10

cap drop Rbiochildgirl_total_34
clonevar Rbiochildgirl_total_34 = biochildgirl_total_34
replace Rbiochildgirl_total_34=0 if Rbiochildgirl_total_34==-10


//since age 34
cap drop biochildgirl_total_A
egen biochildgirl_total_A =anycount(pregs11_38 pregs12_38 pregs13_38 pregs21_38 pregs22_38 pregs31_38 pregs32_38 pregs41_38 pregs42_38 pregs43_38 pregs44_38 pregs51_38 pregs61_38 pregs62_38 pregs71_38 pregs81_38), values(2)
replace biochildgirl_total_A=. if sweep34_38==.|preg_34_38==. 
replace biochildgirl_total_A= biochildgirl_total_A + Rbiochildgirl_total_34
fre biochildgirl_total_A //N=7748

//since age 30
cap drop biochildgirl_total_B
egen biochildgirl_total_B =anycount(pregs11_38 pregs12_38 pregs13_38 pregs21_38 pregs22_38 pregs31_38 pregs32_38 pregs41_38 pregs42_38 pregs43_38 pregs44_38 pregs51_38 pregs61_38 pregs62_38 pregs71_38 pregs81_38), values(2)
replace biochildgirl_total_B=. if sweep30_38==.|preg_30_38==. 
replace biochildgirl_total_B= biochildgirl_total_B + Rbiochildgirl_total_30
fre biochildgirl_total_B //N=763

//since age 26
cap drop biochildgirl_total_C
egen biochildgirl_total_C =anycount(pregs11_38 pregs12_38 pregs13_38 pregs21_38 pregs22_38 pregs31_38 pregs32_38 pregs41_38 pregs42_38 pregs43_38 pregs44_38 pregs51_38 pregs61_38 pregs62_38 pregs71_38 pregs81_38), values(2)
replace biochildgirl_total_C=. if sweep26_38==.|preg_26_38==. 
replace biochildgirl_total_C= biochildgirl_total_C + Rbiochildgirl_total_26
fre biochildgirl_total_C //N=128

//since age 16
cap drop biochildgirl_total_D
egen biochildgirl_total_D =anycount(pregs11_38 pregs12_38 pregs13_38 pregs21_38 pregs22_38 pregs31_38 pregs32_38 pregs41_38 pregs42_38 pregs43_38 pregs44_38 pregs51_38 pregs61_38 pregs62_38 pregs71_38 pregs81_38), values(2)
replace biochildgirl_total_D=. if sweep16_38==.|preg_16_38==. 
replace biochildgirl_total_D=biochildgirl_total_D
fre biochildgirl_total_D //N=158


// COMPUTE age 34 total girls
fre biochildgirl_total_A biochildgirl_total_B biochildgirl_total_C biochildgirl_total_D

cap drop biochildgirl_total_38
egen biochildgirl_total_38=rowtotal(biochildgirl_total_A biochildgirl_total_B biochildgirl_total_C biochildgirl_total_D)
replace biochildgirl_total_38=. if included==.
fre biochildgirl_total_38
label define biochildgirl_total_38 0 "Boys only" -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildgirl_total_38 biochildgirl_total_38
label variable biochildgirl_total_38 "Total number of biological girls"
fre biochildgirl_total_38 //N=8,797




*** CHECKING EXTRA BOYS AND GIRLS IN HOUSEHOLD NOT REPORTED AS PREGNANCY (age 38)

foreach C in 2_38 3_38 4_38 5_38 6_38 7_38 8_38 9_38 10_38 11_38 12_38 {
*biological boys in hh grid (age 38)
cap drop bioboyhh`C'
gen bioboyhh`C'=0
replace bioboyhh`C'=1 if hhrel`C'==4 & hhsex`C'==1
label define bioboyhh`C' 1 "biological boy", replace
label values bioboyhh`C' bioboyhh`C'
label var bioboyhh`C' "`C' is a hh biological boy"
fre bioboyhh`C'
}

foreach C in 2_38 3_38 4_38 5_38 6_38 7_38 8_38 9_38 10_38 11_38 12_38 {
*biological girls in hh grid (age 38)
cap drop biogirlhh`C'
gen biogirlhh`C'=0
replace biogirlhh`C'=1 if hhrel`C'==4 & hhsex`C'==2
label define biogirlhh`C' 1 "biological girl", replace
label values biogirlhh`C' biogirlhh`C'
label var biogirlhh`C' "`C' is a hh biological girl"
fre biogirlhh`C'
}



***COMPUTE total number of biological boys and girls reported in hh grid (age 38)

//boys (age 38)
cap drop bioboyhh_total_38
gen bioboyhh_total_38=bioboyhh2_38+bioboyhh3_38+bioboyhh4_38+bioboyhh5_38+bioboyhh6_38+bioboyhh7_38+bioboyhh8_38+bioboyhh9_38+bioboyhh10_38+bioboyhh11_38+bioboyhh12_38
label variable bioboyhh_total_38 "Total number of bio boys in household (HH grid data)"
//replace bioboyhh_total=-10 if bioboyhh_total==0 & anybiochildren==0
replace bioboyhh_total_38=. if (BCSAGE38SURVEY_38==.| b8hhsize==-1) //code to . if missing HH grid
replace bioboyhh_total_38=. if anybiochildren_38==.
fre bioboyhh_total_38

//girls (age 38)
cap drop biogirlhh_total_38
gen biogirlhh_total_38=biogirlhh2_38+biogirlhh3_38+biogirlhh4_38+biogirlhh5_38+biogirlhh6_38+biogirlhh7_38+biogirlhh8_38+biogirlhh9_38+biogirlhh10_38+biogirlhh11_38+biogirlhh12_38
label variable biogirlhh_total_38 "Total number of bio girls in household (HH grid data)"
//replace biogirlhh_total=-10 if biogirlhh_total==0 & anybiochildren==0
replace biogirlhh_total_38=. if (BCSAGE38SURVEY_38==.| b8hhsize==-1) //code to . if missing HH grid
replace biogirlhh_total_38=. if anybiochildren_38==.
fre biogirlhh_total_38



//computing difference in pregnancy data and household data (age 38)

fre biochildboy_total_38 biochildgirl_total_38
fre bioboyhh_total_38 biogirlhh_total_38 

cap drop biochildboy_tot_miss_38
gen biochildboy_tot_miss_38=1 if biochildboy_total_38==. //this creates a missing values flag for this variable
cap drop biochildgirl_tot_miss_38
gen biochildgirl_tot_miss_38=1 if biochildgirl_total_38==. //this creates a missing values flag for this variable

replace biochildboy_total_38=0 if biochildboy_total_38==.|biochildboy_total_38==-10 // this bit is important as crucial for the inclusion of all HH grid data in adjustments for extra children 
replace biochildgirl_total_38=0 if biochildgirl_total_38==.|biochildgirl_total_38==-10 // this bit is important as crucial for the inclusion of all HH grid data in adjustments for extra children 


fre biochildboy_total_38
fre bioboyhh_total_38

fre biochildgirl_total_38
fre biogirlhh_total_38

cap drop diffboy_38
gen diffboy_38=biochildboy_total_38-bioboyhh_total_38
fre diffboy_38

cap drop diffgirl_38
gen diffgirl_38=biochildgirl_total_38-biogirlhh_total_38
fre diffgirl_38



//extra boys identified and to be added to (age 38)
cap drop bioextraboy_38
gen bioextraboy_38=diffboy_38
replace bioextraboy_38=0 if inrange(diffboy_38,0,10)
replace bioextraboy_38=1 if diffboy_38==-1
replace bioextraboy_38=2 if diffboy_38==-2
replace bioextraboy_38=3 if diffboy_38==-3
replace bioextraboy_38=4 if diffboy_38==-4
replace bioextraboy_38=5 if diffboy_38==-5
replace bioextraboy_38=6 if diffboy_38==-6
fre bioextraboy_38

//extra girls identified and to be added to (age 38)
cap drop bioextragirl_38
gen bioextragirl_38=diffgirl_38
replace bioextragirl_38=0 if inrange(diffgirl_38,0,10)
replace bioextragirl_38=1 if diffgirl_38==-1
replace bioextragirl_38=2 if diffgirl_38==-2
replace bioextragirl_38=3 if diffgirl_38==-3
replace bioextragirl_38=4 if diffgirl_38==-4
replace bioextragirl_38=5 if diffgirl_38==-5
replace bioextragirl_38=6 if diffgirl_38==-6
fre bioextragirl_38



******ADJUSTING 

//first doing some missing value flags
cap drop bioextraboy_miss_38
gen bioextraboy_miss_38=1 if bioextraboy_38==. //missing values flag 
fre bioextraboy_miss_38
replace bioextraboy_38=0 if bioextraboy_38==.

cap drop bioextragirl_miss_38
gen bioextragirl_miss_38=1 if bioextragirl_38==. //missing values flag 
fre bioextragirl_miss_38
replace bioextragirl_38=0 if bioextragirl_38==.


//TOTAL NUMBER OF BOYS AND GIRLS (age 38)

//boys (age 38)
fre biochildboy_total_38 bioextraboy_38
replace biochildboy_total_38=biochildboy_total_38+bioextraboy_38
replace biochildboy_total_38=. if biochildboy_tot_miss_38==1 //& bioextraboy_miss_38==1
replace biochildboy_total_38=. if anybiochildren_38==.
fre biochildboy_total_38

//girls (age 38)
fre biochildgirl_total_38
replace biochildgirl_total_38=biochildgirl_total_38+bioextragirl_38
replace biochildgirl_total_38=. if biochildgirl_tot_miss_38==1 //&bioextragirl_miss_38==1
replace biochildgirl_total_38=. if anybiochildren_38==.
fre biochildgirl_total_38


//check that new total is similar to the variable => yes good match
cap drop total_new_38
gen total_new_38=biochildboy_total_38+biochildgirl_total_38
fre total_new_38
fre biochild_tot_38

//coding no children as -10
replace biochildboy_total_38=-10 if anybiochildren_38==0

replace biochildgirl_total_38=-10 if anybiochildren_38==0
fre biochildgirl_total_38




*********************************************************
*** AGES OF BIOLOGICAL CHILDREN (age 38)
*********************************************************

//1. we have already updated ages of pregnancy childrens ages previously.
fre biochildagey2_26 biochildagey3_26 biochildagey4_26 biochildagey5_26 biochildagey6_26 biochildagey7_26 biochildagey8_26 biochildagey9_26 biochildagey10_26

fre biochildagey11_30 biochildagey12_30 biochildagey13_30 biochildagey14_30 biochildagey15_30 biochildagey21_30 biochildagey22_30 biochildagey23_30 biochildagey31_30 biochildagey32_30 biochildagey41_30 biochildagey42_30 biochildagey51_30 biochildagey52_30 biochildagey53_30 biochildagey61_30 biochildagey62_30 biochildagey71_30 biochildagey81_30

fre biochildagey11_34 biochildagey12_34 biochildagey13_34 biochildagey21_34 biochildagey22_34 biochildagey23_34 biochildagey31_34 biochildagey32_34 biochildagey41_34 biochildagey51_34 biochildagey61_34 biochildagey71_34 biochildagey81_34

fre biochildagey11_38 biochildagey12_38 biochildagey13_38 biochildagey21_38 biochildagey22_38 biochildagey31_38 biochildagey32_38 biochildagey41_38 biochildagey42_38 biochildagey43_38 biochildagey44_38 biochildagey51_38 biochildagey61_38 biochildagey62_38 biochildagey71_38 biochildagey81_38



//2. now update ages of extra HH grid children identified at 30 and 34 
 
// time in years since last interview at age 30 to be added to HH grid bio children's ages 
cap drop addtime
gen addtime=(intym_38-intym_30)/12
replace addtime=round(addtime, 1)
fre addtime 

foreach C in 2_30 3_30 4_30 5_30 6_30 7_30 8_30 9_30 10_30 {
cap drop Rbiohhage`C'
gen Rbiohhage`C'=.
replace Rbiohhage`C'=hhage`C' if hhrel`C'==3 & biochild_extra_flag_30==1
replace Rbiohhage`C'=(Rbiohhage`C' + addtime)
fre Rbiohhage`C'
} 
 

// time in years since last interview at age 34 to be added to HH grid bio children's ages 
cap drop addtime
gen addtime=(intym_38-intym_34)/12
replace addtime=round(addtime, 1)
fre addtime 

foreach C in 2_34 3_34 4_34 5_34 6_34 7_34 8_34 9_34 10_34 {
cap drop Rbiohhage`C'
gen Rbiohhage`C'=.
replace Rbiohhage`C'=hhage`C' if hhrel`C'==3 & biochild_extra_flag_34==1
replace Rbiohhage`C'=. if hhage`C'<0 
replace Rbiohhage`C'=(Rbiohhage`C' + addtime)
fre Rbiohhage`C'
} 
 
 
//3. identify additional children in HH grid at age 38
***COMPUTE age of eldest and youngest child in years from HH grid data at age 38 for CM's with a flag for having more children in HH grid than in preg data.
foreach C in 2_38 3_38 4_38 5_38 6_38 7_38 8_38 9_38 10_38 11_38 12_38 {
cap drop biohhage`C'
gen biohhage`C'=.
replace biohhage`C'=hhage`C' if hhrel`C'==4 & biochild_extra_flag_38==1
replace biohhage`C'=. if hhage`C'<0
fre biohhage`C'
}
 
 

//THEN DO FINAL AGE OF CHILDREN MEASURE
*--------------------------------------------------------------------*
*** COMPUTE age of eldest and youngest biological child (age 38)
cap drop biochildy_eldest_38 //years
gen biochildy_eldest_38 = max(biochildagey2_26,biochildagey3_26,biochildagey4_26,biochildagey5_26,biochildagey6_26,biochildagey7_26,biochildagey8_26,biochildagey9_26,biochildagey10_26,biochildagey11_30,biochildagey12_30,biochildagey13_30,biochildagey14_30,biochildagey15_30,biochildagey21_30,biochildagey22_30,biochildagey23_30,biochildagey31_30,biochildagey32_30,biochildagey41_30,biochildagey42_30,biochildagey51_30,biochildagey52_30,biochildagey53_30,biochildagey61_30,biochildagey62_30,biochildagey71_30,biochildagey81_30,biochildagey11_34,biochildagey12_34,biochildagey13_34,biochildagey21_34,biochildagey22_34,biochildagey23_34,biochildagey31_34,biochildagey32_34,biochildagey41_34,biochildagey51_34,biochildagey61_34,biochildagey71_34,biochildagey81_34,biochildagey11_38,biochildagey12_38,biochildagey13_38,biochildagey21_38,biochildagey22_38,biochildagey31_38,biochildagey32_38,biochildagey41_38,biochildagey42_38,biochildagey43_38,biochildagey44_38,biochildagey51_38,biochildagey61_38,biochildagey62_38,biochildagey71_38,biochildagey81_38,Rbiohhage2_30,Rbiohhage3_30,Rbiohhage4_30,Rbiohhage5_30,Rbiohhage6_30,Rbiohhage7_30,Rbiohhage8_30,Rbiohhage9_30,Rbiohhage10_30,Rbiohhage2_34,Rbiohhage3_34,Rbiohhage4_34,Rbiohhage5_34,Rbiohhage6_34,Rbiohhage7_34,Rbiohhage8_34,Rbiohhage9_34,Rbiohhage10_34,biohhage2_38,biohhage3_38,biohhage4_38,biohhage5_38,biohhage6_38,biohhage7_38,biohhage8_38,biohhage9_38,biohhage10_38,biohhage11_38,biohhage12_38)
replace biochildy_eldest_38=-10 if anybiochildren_38==0
replace biochildy_eldest_38=. if anybiochildren_38==.
label define biochildy_eldest_38 -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildy_eldest_38 biochildy_eldest_38
label var biochildy_eldest_38 "Age in years of eldest biological child"
fre biochildy_eldest_38 if BCSAGE38SURVEY==1	


cap drop biochildy_youngest_38 //years
gen biochildy_youngest_38 = min(biochildagey2_26,biochildagey3_26,biochildagey4_26,biochildagey5_26,biochildagey6_26,biochildagey7_26,biochildagey8_26,biochildagey9_26,biochildagey10_26,biochildagey11_30,biochildagey12_30,biochildagey13_30,biochildagey14_30,biochildagey15_30,biochildagey21_30,biochildagey22_30,biochildagey23_30,biochildagey31_30,biochildagey32_30,biochildagey41_30,biochildagey42_30,biochildagey51_30,biochildagey52_30,biochildagey53_30,biochildagey61_30,biochildagey62_30,biochildagey71_30,biochildagey81_30,biochildagey11_34,biochildagey12_34,biochildagey13_34,biochildagey21_34,biochildagey22_34,biochildagey23_34,biochildagey31_34,biochildagey32_34,biochildagey41_34,biochildagey51_34,biochildagey61_34,biochildagey71_34,biochildagey81_34,biochildagey11_38,biochildagey12_38,biochildagey13_38,biochildagey21_38,biochildagey22_38,biochildagey31_38,biochildagey32_38,biochildagey41_38,biochildagey42_38,biochildagey43_38,biochildagey44_38,biochildagey51_38,biochildagey61_38,biochildagey62_38,biochildagey71_38,biochildagey81_38,Rbiohhage2_30,Rbiohhage3_30,Rbiohhage4_30,Rbiohhage5_30,Rbiohhage6_30,Rbiohhage7_30,Rbiohhage8_30,Rbiohhage9_30,Rbiohhage10_30,Rbiohhage2_34,Rbiohhage3_34,Rbiohhage4_34,Rbiohhage5_34,Rbiohhage6_34,Rbiohhage7_34,Rbiohhage8_34,Rbiohhage9_34,Rbiohhage10_34,biohhage2_38,biohhage3_38,biohhage4_38,biohhage5_38,biohhage6_38,biohhage7_38,biohhage8_38,biohhage9_38,biohhage10_38,biohhage11_38,biohhage12_38)
replace biochildy_youngest_38=-10 if anybiochildren_38==0
replace biochildy_youngest_38=. if anybiochildren_38==.
label define biochildy_youngest_38 -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildy_youngest_38 biochildy_youngest_38
label var biochildy_youngest_38 "Age in years of youngest biological child"
fre biochildy_youngest_38




*************************************************************
******** AGE OF COHORT MEMBER AGE AT BIRTH (age 38) *******
*************************************************************

//generating variables for the extra HH grid children at age 30, 34 and 38 to include in final code below.  We subtract childs age from cohort members age at the sweep.

foreach C in 2_38 3_38 4_38 5_38 6_38 7_38 8_38 9_38 10_38 11_38 12_38 {
cap drop cmagebirth_hhextra`C'
gen cmagebirth_hhextra`C'=cmagey_38-biohhage`C' if biochild_extra_flag_38==1
fre cmagebirth_hhextra`C'
}

foreach C in 2_34 3_34 4_34 5_34 6_34 7_34 8_34 9_34 10_34 {
cap drop cmagebirth_hhextra`C'
gen cmagebirth_hhextra`C'=cmagey_34-biohhage`C' if biochild_extra_flag_34==1
fre cmagebirth_hhextra`C'
}

foreach C in 2_30 3_30 4_30 5_30 6_30 7_30 8_30 9_30 10_30 {
cap drop cmagebirth_hhextra`C'
gen cmagebirth_hhextra`C'=cmagey_30-biohhage`C' if biochild_extra_flag_30==1
fre cmagebirth_hhextra`C'
}


***COMPUTE age of cohort member at birth of eldest and youngest child in years (age 38)
cap drop cmageybirth_eldest_38 //years
gen cmageybirth_eldest_38 = min(cmageybirth2_26,cmageybirth3_26,cmageybirth4_26,cmageybirth5_26,cmageybirth6_26,cmageybirth7_26,cmageybirth8_26,cmageybirth9_26,cmageybirth10_26,cmageybirth11_30,cmageybirth12_30,cmageybirth13_30,cmageybirth14_30,cmageybirth15_30,cmageybirth21_30,cmageybirth22_30,cmageybirth23_30,cmageybirth31_30,cmageybirth32_30,cmageybirth41_30,cmageybirth42_30,cmageybirth51_30,cmageybirth52_30,cmageybirth53_30,cmageybirth61_30,cmageybirth62_30,cmageybirth71_30,cmageybirth81_30,cmageybirth11_34,cmageybirth12_34,cmageybirth13_34,cmageybirth21_34,cmageybirth22_34,cmageybirth23_34,cmageybirth31_34,cmageybirth32_34,cmageybirth41_34,cmageybirth51_34,cmageybirth61_34,cmageybirth71_34,cmageybirth81_34, cmageybirth11_38,cmageybirth12_38,cmageybirth13_38,cmageybirth21_38,cmageybirth22_38,cmageybirth31_38,cmageybirth32_38,cmageybirth41_38,cmageybirth42_38,cmageybirth43_38,cmageybirth44_38,cmageybirth51_38,cmageybirth61_38,cmageybirth62_38,cmageybirth71_38,cmageybirth81_38, cmagebirth_hhextra2_30,cmagebirth_hhextra3_30,cmagebirth_hhextra4_30,cmagebirth_hhextra5_30,cmagebirth_hhextra6_30,cmagebirth_hhextra7_30,cmagebirth_hhextra8_30,cmagebirth_hhextra9_30,cmagebirth_hhextra10_30, cmagebirth_hhextra2_34,cmagebirth_hhextra3_34,cmagebirth_hhextra4_34,cmagebirth_hhextra5_34,cmagebirth_hhextra6_34,cmagebirth_hhextra7_34,cmagebirth_hhextra8_34,cmagebirth_hhextra9_34,cmagebirth_hhextra10_34, cmagebirth_hhextra2_38,cmagebirth_hhextra3_38,cmagebirth_hhextra4_38,cmagebirth_hhextra5_38,cmagebirth_hhextra6_38,cmagebirth_hhextra7_38,cmagebirth_hhextra8_38,cmagebirth_hhextra9_38,cmagebirth_hhextra10_38,cmagebirth_hhextra11_38,cmagebirth_hhextra12_38)
replace cmageybirth_eldest_38=-10 if anybiochildren_38==0
replace cmageybirth_eldest_38=. if anybiochildren_38==.
label define cmageybirth_eldest_38 -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values cmageybirth_eldest_38 cmageybirth_eldest_38
label var cmageybirth_eldest_38 "CM age in years at birth of eldest biological child"
fre cmageybirth_eldest_38 if BCSAGE38SURVEY==1	


***COMPUTE age of cohort member at birth of youngest and youngest child in years (age 38)
cap drop cmageybirth_youngest_38 //years
gen cmageybirth_youngest_38 = max(cmageybirth2_26,cmageybirth3_26,cmageybirth4_26,cmageybirth5_26,cmageybirth6_26,cmageybirth7_26,cmageybirth8_26,cmageybirth9_26,cmageybirth10_26,cmageybirth11_30,cmageybirth12_30,cmageybirth13_30,cmageybirth14_30,cmageybirth15_30,cmageybirth21_30,cmageybirth22_30,cmageybirth23_30,cmageybirth31_30,cmageybirth32_30,cmageybirth41_30,cmageybirth42_30,cmageybirth51_30,cmageybirth52_30,cmageybirth53_30,cmageybirth61_30,cmageybirth62_30,cmageybirth71_30,cmageybirth81_30,cmageybirth11_34,cmageybirth12_34,cmageybirth13_34,cmageybirth21_34,cmageybirth22_34,cmageybirth23_34,cmageybirth31_34,cmageybirth32_34,cmageybirth41_34,cmageybirth51_34,cmageybirth61_34,cmageybirth71_34,cmageybirth81_34, cmageybirth11_38,cmageybirth12_38,cmageybirth13_38,cmageybirth21_38,cmageybirth22_38,cmageybirth31_38,cmageybirth32_38,cmageybirth41_38,cmageybirth42_38,cmageybirth43_38,cmageybirth44_38,cmageybirth51_38,cmageybirth61_38,cmageybirth62_38,cmageybirth71_38,cmageybirth81_38, cmagebirth_hhextra2_30,cmagebirth_hhextra3_30,cmagebirth_hhextra4_30,cmagebirth_hhextra5_30,cmagebirth_hhextra6_30,cmagebirth_hhextra7_30,cmagebirth_hhextra8_30,cmagebirth_hhextra9_30,cmagebirth_hhextra10_30, cmagebirth_hhextra2_34,cmagebirth_hhextra3_34,cmagebirth_hhextra4_34,cmagebirth_hhextra5_34,cmagebirth_hhextra6_34,cmagebirth_hhextra7_34,cmagebirth_hhextra8_34,cmagebirth_hhextra9_34,cmagebirth_hhextra10_34, cmagebirth_hhextra2_38,cmagebirth_hhextra3_38,cmagebirth_hhextra4_38,cmagebirth_hhextra5_38,cmagebirth_hhextra6_38,cmagebirth_hhextra7_38,cmagebirth_hhextra8_38,cmagebirth_hhextra9_38,cmagebirth_hhextra10_38,cmagebirth_hhextra11_38,cmagebirth_hhextra12_38)
replace cmageybirth_youngest_38=-10 if anybiochildren_38==0
replace cmageybirth_youngest_38=. if anybiochildren_38==.
label define cmageybirth_youngest_38 -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values cmageybirth_youngest_38 cmageybirth_youngest_38
label var cmageybirth_youngest_38 "CM age in years at birth of youngest biological child"
fre cmageybirth_youngest_38 if BCSAGE38SURVEY==1	




************************** NON BIOLOGICAL CHILDREN (age 38) *****************************
//derived from the household grid and already renamed above


*RECODE on non-biological children variables (age 38)
foreach C in 2_38 3_38 4_38 5_38 6_38 7_38 8_38 9_38 10_38 11_38 12_38 {

*non-biological and type (age 38)
cap drop nonbiochild`C'
gen nonbiochild`C'=.
replace nonbiochild`C'=1 if inrange(hhrel`C',5,8)
label define nonbiochild`C' 1 "Non-biological child" 0 "No non-biological child", replace
label values nonbiochild`C' nonbiochild`C'
label var nonbiochild`C' "`C' is a non-biological"
fre nonbiochild`C'

cap drop step`C'
gen step`C'=.
replace step`C'=1 if inrange(hhrel`C',6,7)
label define step`C' 1 "Step child", replace
label values step`C' step`C'
label var step`C' "`C' is a stepchild"
fre step`C'

cap drop adopt`C'
gen adopt`C'=.
replace adopt`C'=1 if hhrel`C'==5
label define adopt`C' 1 "Adopted", replace
label values adopt`C' adopt`C'
label var adopt`C' "`C' is adopted"
fre adopt`C'

cap drop foster`C'
gen foster`C'=.
replace foster`C'=1 if hhrel`C'==8
label define foster`C' 1 "foster", replace
label values foster`C' foster`C'
label var foster`C' "`C' is foster"
fre foster`C'


*age of nonbio children (age 38)
cap drop nonbiochildagey`C'
clonevar nonbiochildagey`C' = hhage`C' if inrange(hhrel`C',4,7) & hhage`C'<100 
label var nonbiochildagey`C' "`C' Age in years of non-biological child"
fre nonbiochildagey`C'

*sex of nonbio children (age 38)
cap drop nonbiochildsex`C'
clonevar nonbiochildsex`C' = hhsex`C' if inrange(hhrel`C',5,8)
label var nonbiochildsex`C' "`C' Sex of non-biological child"
fre nonbiochildsex`C'

}




***COMPUTE whether has any non-biologial children in household (age 38)
cap drop anynonbio_38
egen anynonbio_38=anycount(nonbiochild2_38 nonbiochild3_38 nonbiochild4_38 nonbiochild5_38 nonbiochild6_38 nonbiochild7_38 nonbiochild8_38 nonbiochild9_38 nonbiochild10_38 nonbiochild11_38 nonbiochild12_38), values(1)
replace anynonbio_38=1 if inrange(anynonbio_38,1,20)
replace anynonbio_38=. if BCSAGE38SURVEY_38==.|b8cmchhm==-1
label variable anynonbio_38 "Whether CM has any non-biological children in household"
label define yesno 0 "No" 1 "Yes" -100 "no participation in sweep" -99 "information not provided", replace
label values anynonbio_38 yesno
fre anynonbio_38 
fre anynonbio_34 
fre anynonbio_30

***COMPUTE total number of non-biologial children in household (age 38)

//number of all non-biological (age 38)
cap drop nonbiochild_tot_38
egen nonbiochild_tot_38 = anycount(nonbiochild2_38 nonbiochild3_38 nonbiochild4_38 nonbiochild5_38 nonbiochild6_38 nonbiochild7_38 nonbiochild8_38 nonbiochild9_38 nonbiochild10_38 nonbiochild11_38 nonbiochild12_38), values(1)
replace nonbiochild_tot_38=. if BCSAGE38SURVEY_38==.|b8cmchhm==-1
label define nonbiochild_tot_38 0 "No non-biological children in HH" -100 "no participation in sweep" -99 "information not provided", replace 
label values nonbiochild_tot_38 nonbiochild_tot_38
label variable nonbiochild_tot_38 "Total number of non-biological children in household"
fre nonbiochild_tot_38
fre nonbiochild_tot_34
fre nonbiochild_tot_30

fre bd8ochhh //note that our derived measure for number of non-biological children in household is perfectly consistent with that already derived in the dataset.

//number of adopted (age 38)
cap drop adopt_tot_38
egen adopt_tot_38 = anycount(adopt2_38 adopt3_38 adopt4_38 adopt5_38 adopt6_38 adopt7_38 adopt8_38 adopt9_38 adopt10_38 adopt11_38 adopt12_38), values(1)
replace adopt_tot_38=. if BCSAGE38SURVEY_38==.|b8cmchhm==-1
label define adopt_tot_38 0 "No adopted children in HH" -100 "no participation in sweep" -99 "information not provided", replace 
label values adopt_tot_38 adopt_tot_38
label variable adopt_tot_38 "Total number of adopted children in household"
fre adopt_tot_38

//number of foster (age 38)
cap drop foster_tot_38
egen foster_tot_38 = anycount(foster2_38 foster3_38 foster4_38 foster5_38 foster6_38 foster7_38 foster8_38 foster9_38 foster10_38 foster11_38 foster12_38), values(1)
replace foster_tot_38=. if BCSAGE38SURVEY_38==.|b8cmchhm==-1
label define foster_tot_38 0 "No foster children in HH" -100 "no participation in sweep" -99 "information not provided", replace 
label values foster_tot_38 foster_tot_38
label variable foster_tot_38 "Total number of foster children in household"
fre foster_tot_38

//number of stepchildren
cap drop step_tot_38
egen step_tot_38 = anycount(step2_38 step3_38 step4_38 step5_38 step6_38 step7_38 step8_38 step9_38 step10_38 step11_38 step12_38), values(1)
replace step_tot_38=. if BCSAGE38SURVEY_38==.|b8cmchhm==-1
label define step_tot_38 0 "No stepchildren in HH" -100 "no participation in sweep" -99 "information not provided", replace 
label values step_tot_38 step_tot_38
label variable step_tot_38 "Total number of stepchildren in household"
fre step_tot_38


***COMPUTE age of youngest and oldest non-biological child (age 38)
cap drop nonbiochildy_eldest_38 //years
gen nonbiochildy_eldest_38 = max(nonbiochildagey2_38, nonbiochildagey3_38, nonbiochildagey4_38, nonbiochildagey5_38, nonbiochildagey6_38, nonbiochildagey7_38, nonbiochildagey8_38, nonbiochildagey9_38, nonbiochildagey10_38, nonbiochildagey11_38, nonbiochildagey12_38)
replace nonbiochildy_eldest_38=-10 if anynonbio_38==0
replace nonbiochildy_eldest_38=. if BCSAGE38SURVEY_38==.|b8cmchhm==-1
label define nonbiochildy_eldest_38 -10 "No non-biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values nonbiochildy_eldest_38 nonbiochildy_eldest_38
label var nonbiochildy_eldest_38 "Age in years of youngest non-biological child"
fre nonbiochildy_eldest_38

cap drop nonbiochildy_youngest_38 //years
gen nonbiochildy_youngest_38 = min(nonbiochildagey2_38, nonbiochildagey3_38, nonbiochildagey4_38, nonbiochildagey5_38, nonbiochildagey6_38, nonbiochildagey7_38, nonbiochildagey8_38, nonbiochildagey9_38, nonbiochildagey10_38, nonbiochildagey11_38, nonbiochildagey12_38)
replace nonbiochildy_youngest_38=-10 if anynonbio_38==0
replace nonbiochildy_youngest_38=. if BCSAGE38SURVEY_38==.|b8cmchhm==-1
label define nonbiochildy_youngest_38 -10 "No non-biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values nonbiochildy_youngest_38 nonbiochildy_youngest_38
label var nonbiochildy_youngest_38 "Age in years of youngest non-biological child"
fre nonbiochildy_youngest_38



***COMPUTE total number of non-biological boys and girls (age 38)
cap drop nonbiochildboy_total_38
egen nonbiochildboy_total_38 = anycount(nonbiochildsex2_38 nonbiochildsex3_38 nonbiochildsex4_38 nonbiochildsex5_38 nonbiochildsex6_38 nonbiochildsex7_38 nonbiochildsex8_38 nonbiochildsex9_38 nonbiochildsex10_38 nonbiochildsex11_38 nonbiochildsex12_38), values(1)
replace nonbiochildboy_total_38=-10 if anynonbio_38==0 //no non-biologial children
replace nonbiochildboy_total_38=. if BCSAGE38SURVEY_38==.|b8cmchhm==-1
label define nonbiochildboy_total_38 0 "Girls only" -10 "No non-biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values nonbiochildboy_total_38 nonbiochildboy_total_38
label var nonbiochildboy_total_38 "Total number of non-biological children who are boys"
fre nonbiochildboy_total_38 

cap drop nonbiochildgirl_total_38
egen nonbiochildgirl_total_38 = anycount(nonbiochildsex2_38 nonbiochildsex3_38 nonbiochildsex4_38 nonbiochildsex5_38 nonbiochildsex6_38 nonbiochildsex7_38 nonbiochildsex8_38 nonbiochildsex9_38 nonbiochildsex10_38 nonbiochildsex11_38 nonbiochildsex12_38), values(2)
replace nonbiochildgirl_total_38=-10 if anynonbio_38==0 //no non-biologial children
replace nonbiochildgirl_total_38=. if BCSAGE38SURVEY_38==.|b8cmchhm==-1
label define nonbiochildgirl_total_38 0 "Boys only" -10 "No non-biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values nonbiochildgirl_total_38 nonbiochildgirl_total_38
label var nonbiochildgirl_total_38 "Total number of non-biological children who are girls"
fre nonbiochildgirl_total_38 





********************** BIOLOGICAL AND NON BIOLOGICAL CHILDREN (age 38) ******************

***COMPUTE whether has any biological or non-biological (age 38)
cap drop anychildren_38
gen anychildren_38=.
replace anychildren_38=1 if anynonbio_38==1|anybiochildren_38==1
replace anychildren_38=0 if anynonbio_38==0 & anybiochildren_38==0
replace anychildren_38=. if BCSAGE38SURVEY_38==.|b8cmchhm==-1
label define anychildren_38 0 "No" 1 "Yes" -100 "no participation in sweep" -99 "information not provided", replace
label values anychildren_38 anychildren_38
label values anychildren_38 anychildren_38
label var anychildren_38 "Whether CM has any children (biological or non-biological)"
fre anychildren_38 

***COMPUTE total number of biological and non-biological children (age 38)
cap drop children_tot_38
gen children_tot_38=biochild_tot_38 + nonbiochild_tot_38
replace children_tot_38=. if BCSAGE38SURVEY_38==.|b8cmchhm==-1
label define children_tot_38 0 "No children (biological or non-biological)" -100 "no participation in sweep" -99 "information not provided", replace
label values children_tot_38 children_tot_38
label var children_tot_38 "Total number of children (biological or non-biological)"
fre children_tot_38



***COMPUTE youngest and oldest biological or non-biological children (age 38)

//create temporary recoded variable
foreach X of varlist biochildy_eldest_38 nonbiochildy_eldest_38 biochildy_youngest_38 nonbiochildy_youngest_38 {
cap drop `X'_R
clonevar `X'_R = `X'
replace `X'_R=0 if `X'_R==-10	
fre `X'_R
}

cap drop childy_eldest_38 //years
gen childy_eldest_38 = max(biochildy_eldest_38_R, nonbiochildy_eldest_38_R)
replace childy_eldest_38=-10 if anybiochildren_38==0 & anynonbio_38==0
replace childy_eldest_38=. if BCSAGE38SURVEY_38==.|b8cmchhm==-1
label define childy_eldest_38 -10 "No children (biological or non-biological)" -100 "no participation in sweep" -99 "information not provided", replace
label values childy_eldest_38 childy_eldest_38
label var childy_eldest_38 "Age in years of eldest child (biological or non-biological)"
fre childy_eldest_38

cap drop childy_youngest_38 //years
gen childy_youngest_38 = min(biochildy_youngest_38_R, nonbiochildy_youngest_38_R)
replace childy_youngest_38=-10 if anybiochildren_38==0 & anynonbio_38==0
replace childy_youngest_38=. if BCSAGE38SURVEY_38==.|b8cmchhm==-1
label define childy_youngest_38 -10 "No children (biological or non-biological)" -100 "no participation in sweep" -99 "information not provided", replace
label values childy_youngest_38 childy_youngest_38
label var childy_youngest_38 "Age in years of youngest child (biological or non-biological)"
fre childy_youngest_38

drop biochildy_eldest_38_R nonbiochildy_eldest_38_R biochildy_youngest_38_R nonbiochildy_youngest_38_R



***COMPUTE total number of male biological or non-biological children (age 38)

//create temporary recoded variable
foreach X of varlist biochildboy_total_38 biochildgirl_total_38 nonbiochildboy_total_38 nonbiochildgirl_total_38 {
cap drop `X'_R
clonevar `X'_R = `X'
replace `X'_R=0 if `X'_R==-10	
}

cap drop childboy_total_38
gen childboy_total_38 = biochildboy_total_38_R + nonbiochildboy_total_38_R
replace childboy_total_38=-10 if anybiochildren_38==0 & anynonbio_38==0  //no bio or non-bio children
replace childboy_total_38=. if anybiochildren_38==.|anynonbio_38==.  //no bio or non-bio children
replace childboy_total_38=. if BCSAGE38SURVEY_38==.|b8cmchhm==-1
label define childboy_total_38 0 "Girls only" -10 "No children (biological or non-biological)" -100 "no participation in sweep" -99 "information not provided", replace
label values childboy_total_38 childboy_total_38
drop biochildboy_total_38_R  nonbiochildboy_total_38_R
label values childboy_total_38 childboy_total_38
label var childboy_total_38 "Total number of children who are boys (biological or non-biological)"
fre childboy_total_38 


cap drop childgirl_total_38
gen childgirl_total_38 = biochildgirl_total_38_R + nonbiochildgirl_total_38_R
replace childgirl_total_38=-10 if anybiochildren_38==0 & anynonbio_38==0  //no bio or non-bio children
replace childgirl_total_38=. if anybiochildren_38==.|anynonbio_38==.  //no bio or non-bio children
replace childgirl_total_38=. if BCSAGE38SURVEY_38==.|b8cmchhm==-1
label define childgirl_total_38 0 "Boys only" -10 "No children (biological or non-biological)" -100 "no participation in sweep" -99 "information not provided", replace
drop biochildgirl_total_38_R  nonbiochildgirl_total_38_R
label values childgirl_total_38 childgirl_total_38
label var childgirl_total_38 "Total number of children who are girls (biological or non-biological)"
fre childgirl_total_38 




****COMPUTE partner child combo (age 38)

//partner and biological children (age 38)
cap drop partnerchildbio_38
gen partnerchildbio_38=.
replace partnerchildbio_38=1 if anybiochildren_38==0 & partner_38==0 //no partner and no children
replace partnerchildbio_38=2 if anybiochildren_38==0 & partner_38==1 //partner but no children
replace partnerchildbio_38=3 if anybiochildren_38==1 & partner_38==0 //no partner but children
replace partnerchildbio_38=4 if anybiochildren_38==1 & partner_38==1 //partner and children
label define partnerchildbio_38 1 "No partner or children" 2 "Partner and no children" 3 "Children and no partner" 4 "Partner and children" -100 "no participation in sweep" -99 "information not provided", replace
label values partnerchildbio_38 partnerchildbio_38
label var partnerchildbio_38 "Whether has partner and/or any biological children"
fre partnerchildbio_38
fre partnerchildbio_34
fre partnerchildbio_30

//partner and any bio or nonbio children (age 38)
cap drop partnerchildany_38
gen partnerchildany_38=.
replace partnerchildany_38=1 if anychildren_38==0 & partner_38==0 //no partner and no children
replace partnerchildany_38=2 if anychildren_38==0 & partner_38==1 //partner but no children
replace partnerchildany_38=3 if anychildren_38==1 & partner_38==0 //no partner but children
replace partnerchildany_38=4 if anychildren_38==1 & partner_38==1 //partner and children
label define partnerchildany_38 1 "No partner or children" 2 "Partner and no children" 3 "Children and no partner" 4 "Partner and children" -100 "no participation in sweep" -99 "information not provided", replace
label values partnerchildany_38 partnerchildany_38
label var partnerchildany_38 "Whether has partner and/or any biological or non-biological children"
fre partnerchildany_38
fre partnerchildany_34
fre partnerchildany_30



//derived already add suffix
foreach X of varlist b8numch b8numadh b8anychd b8anyfst b8numadp b8chd006 b8ownchd bd8nchhh bd8ochhh {
rename  `X'  `X'_38	
}


save "$derived\BCS70_fertility_age38.dta", replace

use "$derived\BCS70_fertility_age38.dta", clear

  
  
  
  
**# Bookmark #5
*******************************************************************************
****************************** AGE 42 ***************************************** 
*******************************************************************************

//there is no new specific pregnancy data at age 42, instead children are logged in the person grid which has all previous and new children. See text below for person grid which is from the data guide. So we mainly use this person grid data to derive our fertility data for age 42, in combination with child variabes already drived based on this person grid. Person grid is in long format so we work within this before shaping it to wide and merging on with previous survey sweeps.  


***MAIN SURVEY DATA (flatfile)
use "$raw\bcs70_2012_flatfile", clear
codebook BCSID //N=9,841
keep BCSID B9INTM B9INTY B9OTHREA  //interview date //this is the only variable we need to derive ages as all other variables are in derived data or person grid



****DERIVED VARIABLES
//has summary variables for a number of child variables
merge 1:1 BCSID ///
using "$raw\bcs70_2012_derived", keepusing(BD9PARTP BD9MS BD9NUMCH BD9NPCHH BD9TOTAC BD9TOTOC BD9NOCAB BD9WCDIE BD9NCDIE BD9TOTCE) 
drop _merge



***PERSON GRID
merge 1:m BCSID ///
using "$raw\bcs70_2012_persongrid"

//N=9,687 for whom we have person grid data


//from document: bcs70_2012_follow_up_guide_to_the_datasets: "In past sweeps, cohort members have been asked about each person that they had been living with at the previous sweep, any new household members and absent children. These questions were asked independently of relationship and pregnancy histories and led to some inconsistencies in the data. At the BCS70 2012 follow-up, the cohort member is asked about: relationships since the last sweep; all children, whether in the household or not, and other household members. As individuals often leave the household and return at a later date, all persons reported as having lived with the cohort member, or been an absent child, were fed forward to the bcs70 2012 follow-up to enable cohort members to identify a previous household member returning to the household. Therefore the `bcs_2012_persongrid' hierarchical dataset, which has been constructed from the relationships, children and other household member sections of the questionnaire, contains data for all persons who were reported as living with the cohort member or being an absent child in previous sweeps (`bcs_2012_persongrid' dataset b9gridid=1 to 15), any new children (in household or absent) since the last sweep (b9gridid=16 to 26), any new partners since the last sweep (b9gridid=27 to 36) and any other household members new since the last sweep (b9gridid=37 to 46)."




*******************************************************************************

//partner (age 42)
fre BD9PARTP //whether lives with spouse or partner
cap drop partner
gen partner=.
replace partner=1 if inrange(BD9PARTP,1,3)
replace partner=0 if BD9PARTP==-1
label define partner 0 "No" 1 "Yes" -100 "no participation in sweep" -99 "information not provided", replace
label values partner partner
label var partner "Whether CM has current partner in hhld"
fre partner


//marital status (age 42)
fre BD9MS
cap drop marital
gen marital=.
replace marital=3 if BD9MS==1|BD9MS==3|BD9MS==4|BD9MS==6|BD9MS==8
replace marital=2 if (BD9MS==1|BD9MS==3|BD9MS==4|BD9MS==6|BD9MS==8) & partner==1
replace marital=1 if BD9MS==2|BD9MS==5
label define marital 3 "Single non-cohabiting" 2 "Single cohabiting with partner" 1 "Married or Civil Partnered" -100 "no participation in sweep" -99 "information not provided", replace
label values marital marital
label variable marital "Marital status (age 42)" 
fre marital



************************** BIOLOGICAL CHILDREN (age 42) *****************************


*** WHETHER HAD ANY BIOLOGICAL CHILDREN AND TOTAL NUMBER (age 42)
fre B9GRTOK //4=own child
cap drop biochild
gen biochild=.
replace biochild=1 if B9GRTOK==4
fre biochild

*any biological children (age 42)
cap drop anybiochildren
egen anybiochildren = total(biochild==1), by (BCSID)
replace anybiochildren=1 if inrange(anybiochildren,1,20)
replace anybiochildren=. if _merge==1
label variable anybiochildren "Whether CM has had any biological children"
label define yesno 0 "No" 1 "Yes" -100 "no participation in sweep" -99 "information not provided", replace
label values anybiochildren yesno
fre anybiochildren

*total number of biological children (age 42)
cap drop biochild_tot
egen biochild_tot = count(biochild), by (BCSID)
replace biochild_tot=. if _merge==1
label define biochild_tot 0 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values biochild_tot biochild_tot
label variable biochild_tot "Total number of biological children"
fre biochild_tot

fre BD9TOTOC //checking against the already derived variable in the dataset, we get the same result.  




*-------------------------------------------------------------------*
*** AGES OF BIOLOGICAL CHILDREN AND COHORT MEMBER AGE AT BIRTH (age 42)
*interview date (age 42)
fre B9INTM B9INTY
rename (B9INTM B9INTY) (intmonth intyear)

label define intyear -100 "no participation in sweep" -99 "information not provided", replace
label values intyear intyear

label define intmonth 1 "January" 2	"February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "	October" 11 "November" 12 "December" -100 "no participation in sweep" -99 "information not provided", replace
label values intmonth intmonth

cap drop intym
gen intym = ym(intyear,intmonth)
label var intym "Interview date - months since Jan 1960"
fre intym


*cohort member birthdate (age 42)
cap drop cmbirthy
gen cmbirthy=1970
label var cmbirthy "Birth year of CM"
fre cmbirthy

cap drop cmbirthm
gen cmbirthm=4
label var cmbirthm "Birth month of CM"
fre cmbirthm

cap drop cmbirthym
gen cmbirthym = ym(cmbirthy,cmbirthm)
label var cmbirthym "CM birth date - months since Jan 1960"
fre cmbirthym


*date of birth of biological child since Jan 1960 (age 42)
fre B9GDOBM //birth month //1=jan 12=dec
replace B9GDOBM=. if B9GDOBM==-8

fre B9GDOBY //birth year //1910 - 2013
replace B9GDOBY=. if B9GDOBY==-8

cap drop biochildym
gen biochildym = ym(B9GDOBY, B9GDOBM) if biochild==1
label var biochildym "Date of birth of biological child - months since Jan 1960"
fre biochildym


//child's age in whole years at interview (age 42)
cap drop biochildagey
gen biochildagey = (intym-biochildym)/12
fre biochildagey
replace biochildagey = floor(biochildagey)
label var biochildagey " Age in whole years of biological child"
fre biochildagey //range 0-30


//cm age in whole years at birth of child (age 42)
cap drop cmageybirth
gen cmageybirth = (biochildym-cmbirthym)/12
fre cmageybirth
replace cmageybirth = floor(cmageybirth)
label var cmageybirth "Age of CM in years at birth of biological child"
fre cmageybirth

//cm age in whole years at birth of child (age 42)
cap drop cmageybirth
gen cmageybirth = (biochildym-cmbirthym)/12
fre cmageybirth
replace cmageybirth = floor(cmageybirth)
label var cmageybirth "Age of CM in years at birth of biological child"
fre cmageybirth



***SUMMARY age of eldest and youngest biological child (in years) (age 42)
*eldest in years (age 42)
cap drop biochildy_eldest
egen biochildy_eldest = max(biochildagey), by (BCSID)
replace biochildy_eldest= -10 if anybiochildren==0
label define minusten -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildy_eldest minusten
label var biochildy_eldest "Age in years of eldest biological child"
fre  biochildy_eldest

*youngest in years (age 42)
cap drop biochildy_youngest
egen biochildy_youngest = min(biochildagey), by (BCSID)
replace biochildy_youngest= -10 if anybiochildren==0
label values biochildy_youngest minusten
label var biochildy_youngest "Age in years of youngest biological child"
fre  biochildy_youngest



***SUMMARY age of cohort member at birth of eldest and youngest child (in years and in months) (age 42)
cap drop cmageybirth_eldest //years
egen cmageybirth_eldest = min(cmageybirth), by (BCSID)
replace cmageybirth_eldest= -10 if anybiochildren==0
label values cmageybirth_eldest minusten
label var cmageybirth_eldest "CM age in years at birth of eldest biological child"
fre  cmageybirth_eldest

cap drop cmageybirth_youngest //years
egen cmageybirth_youngest = max(cmageybirth), by (BCSID)
replace cmageybirth_youngest= -10 if anybiochildren==0
label values cmageybirth_youngest minusten
label var cmageybirth_youngest "CM age in years at birth of youngest biological child"
fre  cmageybirth_youngest




*-------------------------------------------------------------------*
*** SEX OF BIOLOGICAL CHILDREN (age 42)

cap drop biochildsex
gen biochildsex=.
replace biochildsex=B9GSEX if biochild==1
label variable biochildsex "Sex of -biological child"
label define biochildsex 1 "male" 2 "female" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildsex biochildsex
fre biochildsex

//total boys (age 42)
cap drop biochildboy_total
egen biochildboy_total= total(biochildsex==1), by (BCSID)
replace biochildboy_total=-10 if anybiochildren==0
replace biochildboy_total=. if _merge==1
label define biochildboy_total 0 "Girls only" -10 "No non-biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values biochildboy_total biochildboy_total
label var biochildboy_total "Total number of biological children who are boys"
fre biochildboy_total

//total girls (age 42)
cap drop biochildgirl_total
egen biochildgirl_total= total(biochildsex==2), by (BCSID)
replace biochildgirl_total=-10 if anybiochildren==0
replace biochildgirl_total=. if _merge==1
label define biochildgirl_total 0 "Boys only" -10 "No non-biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values biochildgirl_total biochildgirl_total
label var biochildgirl_total "Total number of biological children who are girls"
fre biochildgirl_total


*-------------------------------------------------------------------*
*** WHERE BIOLOGICAL CHILDREN LIVE (age 42)
fre B9GSLIVE //whether person living with CM at interview //0=no, 1=yes

//in household (age 42)
cap drop biochildhh
gen biochildhh=.
replace biochildhh=1 if biochild==1 & B9GSLIVE==1
label variable biochildhh "Child lives in household"
fre biochildhh

cap drop biochildhh_total 
egen biochildhh_total = count(biochildhh), by (BCSID)
replace biochildhh_total=-10 if anybiochildren==0
replace biochildhh_total=. if _merge==1
label define biochildhh_total 0 "None of CM's biological children live in household" -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildhh_total biochildhh_total
label variable biochildhh_total "Total number of bio children in household (HH grid data)"
fre biochildhh_total


//not in household (age 42)
cap drop biochildnonhh
gen biochildnonhh=.
replace biochildnonhh=1 if biochild==1 & B9GSLIVE!=1 //& B9GSLIVE==0
label variable biochildnonhh "Child lives outside household"
fre biochildnonhh

cap drop biochildnonhh_total
egen biochildnonhh_total = count(biochildnonhh), by (BCSID)
replace biochildnonhh_total=-10 if anybiochildren==0
replace biochildnonhh_total=. if _merge==1
label define biochildnonhh_total 0 "All biological children live in household" -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildnonhh_total biochildnonhh_total
label variable biochildnonhh_total "Total number of bio children not in household"
fre biochildnonhh_total



*-------------------------------------------------------------------*
*** OTHER PARENT OF BIOLOGICAL CHILDREN (age 42)
fre B9GCRLP //Whether child is current partner's own child //1=yes, 2=no

fre B9OTHREA //whether any non-residential partner 2=no

//previous partner's child (age 42)
cap drop biochildprev
gen biochildprev=.
replace biochildprev=1 if biochild==1 & (B9GCRLP==2|(partner==0 & B9OTHREA==2))
label variable biochildprev "Bio child's other parent is previous partner"
fre biochildprev

cap drop biochildprev_total
egen biochildprev_total = count(biochildprev), by (BCSID)
replace biochildprev_total=-10 if anybiochildren==0
replace biochildprev_total=. if _merge==1
label define biochildprev_total 0 "Current partner(s) parent to all biological children" -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildprev_total biochildprev_total
label variable biochildprev_total "Total number of biological children had with a previous partner"
fre biochildprev_total

//whether a previous partner is parent to any children (age 42)
cap drop biochildprevany
gen biochildprevany=.
replace biochildprevany=1 if inrange(biochildprev_total,1,10)
replace biochildprevany=0 if biochildprev_total==0
replace biochildprevany=-10 if biochildprev_total==-10
label variable biochildprevany "Any children with a previous partner"
label define biochildprevany 1 "Previous partner(s) parent to all or some biological children" 0 "Current partner is parent to all biological children" -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildprevany biochildprevany
fre biochildprevany




************************** NON BIOLOGICAL CHILDREN (age 42) *****************************
fre B9GRTOK //5=adopted, 6=child of current partner, 7=Child of previous partner, 8=foster child

cap drop nonbiochild
gen nonbiochild=.
replace nonbiochild=1 if (B9GRTOK==5|B9GRTOK==6|B9GRTOK==7|B9GRTOK==8) & B9GSLIVE==1
label variable nonbiochild "Child is non-biological"
fre nonbiochild

cap drop adopt
gen adopt=.
replace adopt=1 if B9GRTOK==5 & B9GSLIVE==1
label variable adopt "Child is adopted"
fre adopt

cap drop foster
gen foster=.
replace foster=1 if B9GRTOK==8 & B9GSLIVE==1
label variable foster "Child is foster"
fre foster

cap drop step
gen step=.
replace step=1 if (B9GRTOK==6|B9GRTOK==7) & B9GSLIVE==1
label variable step "Child is step-child (current or previous partner)"
fre step


//any non-bio (age 42)
cap drop anynonbio
egen anynonbio = count(nonbiochild), by (BCSID)
replace anynonbio=1 if inrange(anynonbio,1,20)
replace anynonbio=. if _merge==1
label variable anynonbio "Whether CM has any non-biological children in household"
label define yesno 0 "No" 1 "Yes" -100 "no participation in sweep" -99 "information not provided", replace
label values anynonbio yesno
fre anynonbio

//total number of non-bio (age 42)
cap drop nonbiochild_tot
egen nonbiochild_tot = count(nonbiochild), by (BCSID)
label variable nonbiochild_tot "Total number of non-biological children in household"
label define nonbiochild_tot 0 "No non-biological children in HH" -100 "no participation in sweep" -99 "information not provided", replace 
label values nonbiochild_tot nonbiochild_tot
fre nonbiochild_tot

//total number of adopted (age 42)
cap drop adopt_tot
egen adopt_tot = count(adopt), by (BCSID)
replace adopt_tot=. if _merge==1
label variable adopt_tot "Total number of adopted children in household"
label define adopt_tot 0 "No adopted children in HH" -100 "no participation in sweep" -99 "information not provided", replace 
label values adopt_tot adopt_tot
fre adopt_tot

//total number of foster (age 42)
cap drop foster_tot
egen foster_tot = count(foster), by (BCSID)
replace foster_tot=. if _merge==1
label variable foster_tot "Total number of foster children in household"
label define foster_tot 0 "No foster children in HH" -100 "no participation in sweep" -99 "information not provided", replace 
label values foster_tot foster_tot
fre foster_tot

//total number of stepchildren (age 42)
cap drop step_tot
egen step_tot = count(step), by (BCSID)
replace step_tot=. if _merge==1
label variable step_tot "Total number of stepchildren in household"
label define step_tot 0 "No stepchildren in HH" -100 "no participation in sweep" -99 "information not provided", replace 
label values step_tot step_tot
fre step_tot




*-------------------------------------------------------------------*
***AGE OF NON BIOLOGICAL CHILD (age 42)

fre B9GAGE //person's age last birthday
cap drop nonbiochildagey
gen nonbiochildagey=.
replace nonbiochildagey=B9GAGE if inrange(B9GAGE,0,100) & nonbiochild==1
label variable nonbiochildagey "Age in years of non-biological child" 
fre nonbiochildagey

*eldest in years (age 42)
cap drop nonbiochildy_eldest
egen nonbiochildy_eldest = max(nonbiochildagey), by (BCSID)
replace nonbiochildy_eldest= -10 if anynonbio==0
label define nonbiochildy_eldest -10 "No non-biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values nonbiochildy_eldest nonbiochildy_eldest
label var nonbiochildy_eldest "Age in years of eldest non-biological child"
fre  nonbiochildy_eldest

*youngest in years (age 42)
cap drop nonbiochildy_youngest
egen nonbiochildy_youngest = min(nonbiochildagey), by (BCSID)
replace nonbiochildy_youngest= -10 if anynonbio==0
label define nonbiochildy_youngest -10 "No non-biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values nonbiochildy_youngest nonbiochildy_youngest
label var nonbiochildy_youngest "Age in years of youngest non-biological child"
fre  nonbiochildy_youngest



***SEX OF NON BIOLOGICAL CHILDREN (age 42)
fre B9GSEX
cap drop nonbiochildsex
gen nonbiochildsex=.
replace nonbiochildsex=B9GSEX if nonbiochild==1
label variable nonbiochildsex "Sex of non-biological child"
label define nonbiochildsex 1 "male" 2 "female" -100 "no participation in sweep" -99 "information not provided", replace
label values nonbiochildsex nonbiochildsex
fre nonbiochildsex

//total boys (age 42)
cap drop nonbiochildboy_total
egen nonbiochildboy_total= total(nonbiochildsex==1), by (BCSID)
replace nonbiochildboy_total=-10 if anynonbio==0
replace nonbiochildboy_total=. if _merge==1
label define nonbiochildboy_total 0 "Girls only" -10 "No non-biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values nonbiochildboy_total nonbiochildboy_total
label var nonbiochildboy_total "Total number of non-biological children who are boys"
fre nonbiochildboy_total

//total girls (age 42)
cap drop nonbiochildgirl_total
egen nonbiochildgirl_total= total(nonbiochildsex==2), by (BCSID)
replace nonbiochildgirl_total=-10 if anynonbio==0
replace nonbiochildgirl_total=. if _merge==1
label define nonbiochildgirl_total 0 "Boys only" -10 "No non-biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values nonbiochildgirl_total nonbiochildgirl_total
label var nonbiochildgirl_total "Total number of non-biological children who are girls"
fre nonbiochildgirl_total





********************** BIOLOGICAL AND NON BIOLOGICAL CHILDREN (age 42) ******************

*** ANY BIOLOGICAL OR NON BIOLOGICAL CHILD AND NUMBER (age 42)

*any biological or non-biological children (age 42)
cap drop anychildren
egen anychildren = total(biochild==1|nonbiochild==1), by (BCSID)
replace anychildren=1 if inrange(anychildren,1,20)
replace anychildren=. if _merge==1
label variable anychildren "Whether CM has any children (biological or non-biological)"
label define yesno 0 "No" 1 "Yes" -100 "no participation in sweep" -99 "information not provided", replace
label values anychildren yesno
fre anychildren

*total number of biological or non-biologial children (age 42)
cap drop children_tot
egen children_tot = total(biochild==1|nonbiochild==1), by (BCSID)
replace children_tot=. if _merge==1
label define children_tot 0 "No biological or non-biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values children_tot children_tot
label variable children_tot "Total number of biological or non-biological children"
fre children_tot



***AGE OF BIOLOGICAL OR NON BIOLOGICAL CHILD (age 42)

*ages of all children (age 42)
cap drop childyears
gen childyears=. 
replace childyears=biochildagey if biochildagey!=.
replace childyears=nonbiochildagey if nonbiochildagey!=.
fre childyears

*eldest in years (age 42)
cap drop childy_eldest
egen childy_eldest = max(childyears), by (BCSID)
replace childy_eldest= -10 if anychildren==0
label define childy_eldest -10 "No children (biological or non-biological)" -100 "no participation in sweep" -99 "information not provided", replace
label values childy_eldest childy_eldest
label var childy_eldest "Age in years of eldest child (biological or non-biological)"
fre childy_eldest

*youngest in years (age 42)
cap drop childy_youngest
egen childy_youngest = min(childyears), by (BCSID)
replace childy_youngest= -10 if anychildren==0
label define childy_youngest -10 "No children (biological or non-biological)" -100 "no participation in sweep" -99 "information not provided", replace
label values childy_youngest childy_youngest
label var childy_youngest "Age in years of youngest child (biological or non-biological)"
fre childy_youngest



***SEX OF BIOLOGICAL OR NON BIOLOGICAL CHILDREN (age 42)

*sex of all children (age 42)
cap drop childsex
gen childsex=.
replace childsex=B9GSEX if biochild==1|nonbiochild==1 
label variable childsex "Sex of child"
label define childsex 1 "male" 2 "female" -100 "no participation in sweep" -99 "information not provided", replace
label values childsex childsex
fre childsex

*number of boys (age 42)
cap drop childboy_total
egen childboy_total= total(childsex==1), by (BCSID)
replace childboy_total=-10 if anychildren==0
replace childboy_total=. if _merge==1
label define childboy_total 0 "Girls only" -10 "No non-biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values childboy_total childboy_total
label var childboy_total "Total number of children who are boys (biological or non-biological)"
fre childboy_total

*number of girls (age 42)
cap drop childgirl_total
egen childgirl_total= total(childsex==2), by (BCSID)
replace childgirl_total=-10 if anychildren==0
replace childgirl_total=. if _merge==1
label define childgirl_total 0 "Boys only" -10 "No non-biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values childgirl_total childgirl_total
label var childgirl_total "Total number of children who are girls (biological or non-biological)"
fre childgirl_total






***************** PARTNER AND CHILD COMBO (age 42) ******************

//partner and biological children (age 42)
cap drop partnerchildbio
gen partnerchildbio=.
replace partnerchildbio=1 if anybiochildren==0 & partner==0 //no partner and no children
replace partnerchildbio=2 if anybiochildren==0 & partner==1 //partner but no children
replace partnerchildbio=3 if anybiochildren==1 & partner==0 //no partner but children
replace partnerchildbio=4 if anybiochildren==1 & partner==1 //partner and children
label define partnerchildbio 1 "No partner or children" 2 "Partner and no children" 3 "Children and no partner" 4 "Partner and children" -100 "no participation in sweep" -99 "information not provided", replace
label values partnerchildbio partnerchildbio
label var partnerchildbio "Whether has partner and/or any biological children"
fre partnerchildbio

//partner and any bio or nonbio children (age 42)
cap drop partnerchildany
gen partnerchildany=.
replace partnerchildany=1 if anychildren==0 & partner==0 //no partner and no children
replace partnerchildany=2 if anychildren==0 & partner==1 //partner but no children
replace partnerchildany=3 if anychildren==1 & partner==0 //no partner but children
replace partnerchildany=4 if anychildren==1 & partner==1 //partner and children
label define partnerchildany 1 "No partner or children" 2 "Partner and no children" 3 "Children and no partner" 4 "Partner and children" -100 "no participation in sweep" -99 "information not provided", replace
label values partnerchildany partnerchildany
label var partnerchildany "Whether has partner and/or any biological or non-biological children"
fre partnerchildany




********RESHAPNG DATA (age 42)**********

//adding suffix _42 to denote varabels are from age 42 sweep
foreach var of varlist _all {	
rename `var' `var'_42		
if inlist("`var'", "skip_bcsid") {				
}
}
rename BCSID_42 bcsid


//reshaping to wide
replace B9GRIDID_42=0 if B9GRIDID_42==.
reshape wide /// just the variables for individuals and not family summary
B9GSEX_42 B9GDIED_42 B9GSLIVE_42 B9GRTOK_42 B9GDIEDY_42 B9GDIEDM_42 B9GSTY_42 B9GSTM_42 B9GLEFTY_42 B9GLEFTM_42 B9GDOBM_42 B9GDOBY_42 B9GAGE_42 B9GCRLP_42 B9GCRLP2_42 ///
biochild_42 biochildym_42 biochildagey_42 cmageybirth_42 biochildsex_42 biochildhh_42 biochildnonhh_42 biochildprev_42 nonbiochild_42 adopt_42 foster_42 step_42 nonbiochildagey_42 nonbiochildsex_42 childyears_42 childsex_42, ///
i(bcsid) j(B9GRIDID_42)

//N=9,841

gen BCSAGE42SURVEY=1 //age 42 survey participation
label var BCSAGE42SURVEY "Whether took part in age 42 survey"

drop _merge

save "$derived\BCS70_fertility_age42.dta", replace
use "$derived\BCS70_fertility_age42.dta", clear 





**# Bookmark #6
*******************************************************************************
****************************** AGE 46 ***************************************** 
*******************************************************************************
//The data is very similar in structure to age 42 with person grids for current and past hh members and children in household or absent (see description from data user guide below). So data is in long format, which is then tranformed to wide, before merging it with the previous sweeps. We also use some data from the main survey. 

//MAIN DATA
use "$raw\bcs_age46_main", clear
//N=8,581

//date of int (age 46)
fre B10INTM B10INTY

//partner (age 46)
fre BD10PARTP

//children who have died and number (age 46) (direct questions in this sweep but we also have HH grid derived)
fre B10DCHANY B10DCHMNY //(questions)
fre BD10WCDIE BD10NCDIE //(HH grid derived)

//already derived varables (many related to fertility)
describe BD10NUMCH BD10GRCHN BD10NOCHH BD10NPCHH BD10AYCHH BD10AOCHH BD10AYCOC BD10AOCOC BD10NC2H BD10NC4H BD10NC11H BD10NC15H BD10NC20H BD10NC30H BD10NC31H BD10NOC2A BD10NOC4A BD10NOC11A BD10NOC15A BD10NOC20A BD10NOC30A BD10NOC31A BD10NACAB BD10NOCAB BD10TOTAC BD10TOTOC BD10WCDIE BD10NCDIE BD10TOTCE BD10WOHHM BD10NOHHM


//keeping our using variables
keep BCSID B10INTM B10INTY B10DCHANY B10DCHMNY B10OTHREA BD10PARTP BD10MS BD10NUMCH BD10GRCHN BD10NOCHH BD10NPCHH BD10AYCHH BD10AOCHH BD10AYCOC BD10AOCOC BD10NC2H BD10NC4H BD10NC11H BD10NC15H BD10NC20H BD10NC30H BD10NC31H BD10NOC2A BD10NOC4A BD10NOC11A BD10NOC15A BD10NOC20A BD10NOC30A BD10NOC31A BD10NACAB BD10NOCAB BD10TOTAC BD10TOTOC BD10WCDIE BD10NCDIE BD10TOTCE BD10WOHHM BD10NOHHM 



//HOUSEHOLD GRID DATA (age 46)
merge 1:m BCSID ///
using "$raw\bcs_age46_persongrid"

//_merge=1 do not have person grid data
//N=8,155 for whom we have person grid data

/*
FROM USER GUIDE

4.4.2 Person grid

The person grid is comprised of five separate loops within the CAPI questionnaire;
partner grid, two child grids (children reported at last sweep and additional children
not previously mentioned), and two `other' household members grids (household
members that are not partners or children reported at last sweep and anyone not
reported in the four other grids). Together these cover all possible household
members at the time of interview as well as previous household members who have
since left. In order to obtain all the same key information these loops are structurally similar. The information is supplemented with feed-forward information from prior sweeps where questions were unasked.
*/



//partner (age 46)
fre BD10PARTP
cap drop partner
gen partner=.
replace partner=1 if inrange(BD10PARTP,1,3)
replace partner=0 if BD10PARTP==-1
label define partner 0 "No" 1 "Yes" -100 "no participation in sweep" -99 "information not provided", replace
label values partner partner
label var partner "Whether CM has current partner in hhld"
fre partner


//marital status (age 46)
fre BD10MS
cap drop marital
gen marital=.
replace marital=3 if BD10MS==1|BD10MS==3|BD10MS==4|BD10MS==6|BD10MS==8
replace marital=2 if (BD10MS==1|BD10MS==3|BD10MS==4|BD10MS==6|BD10MS==8) & partner==1
replace marital=1 if BD10MS==2|BD10MS==5
label define marital 3 "Single non-cohabiting" 2 "Single cohabiting with partner" 1 "Married or Civil Partnered" -100 "no participation in sweep" -99 "information not provided", replace
label values marital marital
label variable marital "Marital status (age 46)" 
fre marital



************************** BIOLOGICAL CHILDREN (age 46) *****************************

*-------------------------------------------------------------------*
*** WHETHER HAD ANY BIOLOGICAL CHILDREN AND TOTAL NUMBER (age 46)
fre B10GRTOK //4=own child
cap drop biochild
gen biochild=.
replace biochild=1 if B10GRTOK==4 //own child
fre biochild

*any biological children (age 46)
cap drop anybiochildren
egen anybiochildren = total(biochild==1), by (BCSID)
fre anybiochildren
replace anybiochildren=1 if inrange(anybiochildren,1,20)
replace anybiochildren=. if _merge==1
label variable anybiochildren "Whether CM has had any biological children"
label define yesno 0 "No" 1 "Yes" -100 "no participation in sweep" -99 "information not provided", replace
label values anybiochildren yesno
fre anybiochildren

*total number of biological children (age 46)
cap drop biochild_tot
egen biochild_tot = count(biochild), by (BCSID)
replace biochild_tot=. if _merge==1
label define biochild_tot 0 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values biochild_tot biochild_tot
label variable biochild_tot "Total number of biological children"
fre biochild_tot


fre BD10TOTOC //checking against the already derived variable for own children. We don't quite get the same result!? 


*-------------------------------------------------------------------*
*** AGES OF BIOLOGICAL CHILDREN AND COHORT MEMBER AGE AT BIRTH (age 46) 
*interview date
fre B10INTM B10INTY
rename (B10INTM B10INTY) (intmonth intyear)

label define intyear -100 "no participation in sweep" -99 "information not provided", replace
label values intyear intyear

label define intmonth 1 "January" 2	"February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "	October" 11 "November" 12 "December" -100 "no participation in sweep" -99 "information not provided", replace
label values intmonth intmonth


cap drop intym
gen intym = ym(intyear,intmonth)
label var intym "Interview date - months since Jan 1960"
fre intym

*cohort member birthdate (age 46)
cap drop cmbirthy
gen cmbirthy=1970
label var cmbirthy "Birth year of CM"
fre cmbirthy

cap drop cmbirthm
gen cmbirthm=4
label var cmbirthm "Birth month of CM"
fre cmbirthm

cap drop cmbirthym
gen cmbirthym = ym(cmbirthy,cmbirthm)
label var cmbirthym "CM birth date - months since Jan 1960"
fre cmbirthym

*date of birth of biological child since Jan 1960 (age 46)
fre B10GDOBM //birth month //1=jan 12=dec
replace B10GDOBM=. if B10GDOBM==-8

fre B10GDOBY //birth year //1912 - 2018
replace B10GDOBY=. if B10GDOBY==-8

cap drop biochildym
gen biochildym = ym(B10GDOBY, B10GDOBM) if biochild==1
label var biochildym "Date of birth of biological child - months since Jan 1960"
fre biochildym



//child's age in whole years at interview (age 46)
cap drop biochildagey
gen biochildagey = (intym-biochildym)/12
fre biochildagey
replace biochildagey = floor(biochildagey)
label var biochildagey " Age in whole years of biological child"
fre biochildagey //range 0-35

//cm age in whole years at birth of child (age 46)
cap drop cmageybirth
gen cmageybirth = (biochildym-cmbirthym)/12
fre cmageybirth
replace cmageybirth = floor(cmageybirth)
label var cmageybirth "Age of CM in years at birth of biological child"
fre cmageybirth

//cm age in whole years at birth of child (age 46)
cap drop cmageybirth
gen cmageybirth = (biochildym-cmbirthym)/12
fre cmageybirth
replace cmageybirth = floor(cmageybirth)
label var cmageybirth "Age of CM in years at birth of biological child"
fre cmageybirth




***SUMMARY age of eldest and youngest biological child (in years and months) (age 46)

*eldest in years (age 46)
cap drop biochildy_eldest
egen biochildy_eldest = max(biochildagey), by (BCSID)
replace biochildy_eldest= -10 if anybiochildren==0 
label define minusten -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildy_eldest minusten
label var biochildy_eldest "Age in years of eldest biological child"
fre  biochildy_eldest

*youngest in years (age 46)
cap drop biochildy_youngest
egen biochildy_youngest = min(biochildagey), by (BCSID)
replace biochildy_youngest= -10 if anybiochildren==0
label values biochildy_youngest minusten
label var biochildy_youngest "Age in years of youngest biological child"
fre  biochildy_youngest



***SUMMARY age of cohort member at birth of eldest and youngest child (age 46)
cap drop cmageybirth_eldest //years
egen cmageybirth_eldest = min(cmageybirth), by (BCSID)
replace cmageybirth_eldest= -10 if anybiochildren==0
label values cmageybirth_eldest minusten
label var cmageybirth_eldest "CM age in years at birth of eldest biological child"
fre  cmageybirth_eldest

cap drop cmageybirth_youngest //years
egen cmageybirth_youngest = max(cmageybirth), by (BCSID)
replace cmageybirth_youngest= -10 if anybiochildren==0
label values cmageybirth_youngest minusten
label var cmageybirth_youngest "CM age in years at birth of youngest biological child"
fre  cmageybirth_youngest



*-------------------------------------------------------------------*
*** SEX OF BIOLOGICAL CHILDREN (age 46)
fre B10GSEX
cap drop biochildsex
gen biochildsex=.
replace biochildsex=B10GSEX if biochild==1
label variable biochildsex "Sex of -biological child"
label define biochildsex 1 "male" 2 "female" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildsex biochildsex
fre biochildsex

//total boys (age 46)
cap drop biochildboy_total
egen biochildboy_total= total(biochildsex==1), by (BCSID)
replace biochildboy_total=-10 if anybiochildren==0
replace biochildboy_total=. if _merge==1
label define biochildboy_total 0 "Girls only" -10 "No non-biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values biochildboy_total biochildboy_total
label var biochildboy_total "Total number of biological children who are boys"
fre biochildboy_total

//total girls (age 46)
cap drop biochildgirl_total
egen biochildgirl_total= total(biochildsex==2), by (BCSID)
replace biochildgirl_total=-10 if anybiochildren==0
replace biochildgirl_total=. if _merge==1
label define biochildgirl_total 0 "Boys only" -10 "No non-biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values biochildgirl_total biochildgirl_total
label var biochildgirl_total "Total number of biological children who are girls"
fre biochildgirl_total




*-------------------------------------------------------------------*
*** WHERE BIOLOGICAL CHILDREN LIVE (age 46)
fre B10GSLIVE //whether person living with CM at interview //0=no, 1=yes

//in household
gen biochildhh=.
replace biochildhh=1 if biochild==1 & B10GSLIVE==1
label variable biochildhh "Child lives in household"
fre biochildhh
 
egen biochildhh_total = count(biochildhh), by (BCSID)
replace biochildhh_total=-10 if anybiochildren==0
replace biochildhh_total=. if _merge==1
label define biochildhh_total 0 "None of the biological children live in household" -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildhh_total biochildhh_total
label variable biochildhh_total "Total number of bio children in household (HH grid data)"
fre biochildhh_total

//not in household (age 46)
gen biochildnonhh=.
replace biochildnonhh=1 if biochild==1 & B10GSLIVE!=1
label variable biochildnonhh "Child lives outside household"
fre biochildnonhh

egen biochildnonhh_total = count(biochildnonhh), by (BCSID)
replace biochildnonhh_total=-10 if anybiochildren==0
replace biochildnonhh_total=. if _merge==1
label define biochildnonhh_total 0 "All biological children live in household" -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildnonhh_total biochildnonhh_total
label variable biochildnonhh_total "Total number of bio children not in household"
fre biochildnonhh_total

fre BD10NOCAB //checking against derived variable and we dont get the same result



*-------------------------------------------------------------------*
*** OTHER PARENT OF BIOLOGICAL CHILDREN (age 46)
fre B10GCRLP //Whether child is current partner's own child //1=yes, 0=no

fre B10OTHREA //whether any non-residential partner 2=no

//previous partner's child (age 46)
cap drop biochildprev
gen biochildprev=.
replace biochildprev=1 if biochild==1 & (B10GCRLP==0|(partner==0 & B10OTHREA==2))
label variable biochildprev "Bio child's other parent is previous partner"
fre biochildprev

cap drop biochildprev_total
egen biochildprev_total = count(biochildprev), by (BCSID)
replace biochildprev_total=-10 if anybiochildren==0
replace biochildprev_total=. if _merge==1
label define biochildprev_total 0 "Current partner(s) parent to all biological children" -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildprev_total biochildprev_total
label variable biochildprev_total "Total number of biological children had with a previous partner"
fre biochildprev_total

//whether a previous partner is parent to any children (age 46)
cap drop biochildprevany
gen biochildprevany=.
replace biochildprevany=1 if inrange(biochildprev_total,1,10)
replace biochildprevany=0 if biochildprev_total==0
replace biochildprevany=-10 if biochildprev_total==-10
label variable biochildprevany "Any children with a previous partner"
label define biochildprevany 1 "Previous partner(s) parent to all or some biological children" 0 "Current partner is parent to all biological children" -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildprevany biochildprevany
fre biochildprevany



************************** NON BIOLOGICAL CHILDREN (age 46)*****************************
*-------------------------------------------------------------------*
fre B10GRTOK //5=adopted, 6=child of current partner, 7=Child of previous partner, 8=foster child

cap drop nonbiochild
gen nonbiochild=.
replace nonbiochild=1 if (B10GRTOK==5|B10GRTOK==6|B10GRTOK==7|B10GRTOK==8) & B10GSLIVE==1
label variable nonbiochild "Child is non-biological"
fre nonbiochild

cap drop adopt
gen adopt=.
replace adopt=1 if B10GRTOK==5 & B10GSLIVE==1
label variable adopt "Child is adopted"
fre adopt

cap drop foster
gen foster=.
replace foster=1 if B10GRTOK==8 & B10GSLIVE==1
label variable foster "Child is foster"
fre foster

cap drop step
gen step=.
replace step=1 if (B10GRTOK==6|B10GRTOK==7) & B10GSLIVE==1 
label variable step "Child is step-child (current or previous partner)"
fre step


//any non-bio (age 46)
cap drop anynonbio
egen anynonbio = count(nonbiochild), by (BCSID)
replace anynonbio=1 if inrange(anynonbio,1,20)
replace anynonbio=. if _merge==1
label variable anynonbio "Whether CM has any non-biological children in household"
label define yesno 0 "No" 1 "Yes" -100 "no participation in sweep" -99 "information not provided", replace
label values anynonbio yesno
fre anynonbio

//total number of non-bio (age 46)
cap drop nonbiochild_tot
egen nonbiochild_tot = count(nonbiochild), by (BCSID)
label variable nonbiochild_tot "Total number of non-biological children in household"
label define nonbiochild_tot 0 "No non-biological children in HH" -100 "no participation in sweep" -99 "information not provided", replace 
label values nonbiochild_tot nonbiochild_tot
fre nonbiochild_tot

//total number of adopted (age 46)
cap drop adopt_tot
egen adopt_tot = count(adopt), by (BCSID)
replace adopt_tot=. if _merge==1
label variable adopt_tot "Total number of adopted children in household"
label define adopt_tot 0 "No adopted children in HH" -100 "no participation in sweep" -99 "information not provided", replace 
label values adopt_tot adopt_tot
fre adopt_tot

//total number of foster (age 46)
cap drop foster_tot
egen foster_tot = count(foster), by (BCSID)
replace foster_tot=. if _merge==1
label variable foster_tot "Total number of foster children in household"
label define foster_tot 0 "No foster children in HH" -100 "no participation in sweep" -99 "information not provided", replace 
label values foster_tot foster_tot
fre foster_tot

//total number of stepchildren (age 46)
cap drop step_tot
egen step_tot = count(step), by (BCSID)
replace step_tot=. if _merge==1
label variable step_tot "Total number of stepchildren in household"
label define step_tot 0 "No stepchildren in HH" -100 "no participation in sweep" -99 "information not provided", replace 
label values step_tot step_tot
fre step_tot




*-------------------------------------------------------------------*
***AGE OF NON BIOLOGICAL CHILD (age 46)

fre B10GAGE //person's age last birthday (age 46)
cap drop nonbiochildagey
gen nonbiochildagey=.
replace nonbiochildagey=B10GAGE if inrange(B10GAGE,0,100) & nonbiochild==1
label variable nonbiochildagey "Age in years of non-biological child" 
fre nonbiochildagey

*eldest in years (age 46)
cap drop nonbiochildy_eldest
egen nonbiochildy_eldest = max(nonbiochildagey), by (BCSID)
replace nonbiochildy_eldest= -10 if anynonbio==0
label define nonbiochildy_eldest -10 "No non-biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values nonbiochildy_eldest nonbiochildy_eldest
label var nonbiochildy_eldest "Age in years of eldest non-biological child"
fre  nonbiochildy_eldest

*youngest in years (age 46)
cap drop nonbiochildy_youngest
egen nonbiochildy_youngest = min(nonbiochildagey), by (BCSID)
replace nonbiochildy_youngest= -10 if anynonbio==0
label define nonbiochildy_youngest -10 "No non-biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values nonbiochildy_youngest nonbiochildy_youngest
label var nonbiochildy_youngest "Age in years of youngest non-biological child"
fre  nonbiochildy_youngest



***SEX OF NON BIOLOGICAL CHILDREN (age 46)
fre B10GSEX
cap drop nonbiochildsex
gen nonbiochildsex=.
replace nonbiochildsex=B10GSEX if nonbiochild==1
label variable nonbiochildsex "Sex of non-biological child"
label define nonbiochildsex 1 "male" 2 "female" -100 "no participation in sweep" -99 "information not provided", replace
label values nonbiochildsex nonbiochildsex
fre nonbiochildsex

//total boys (age 46)
cap drop nonbiochildboy_total
egen nonbiochildboy_total= total(nonbiochildsex==1), by (BCSID)
replace nonbiochildboy_total=-10 if anynonbio==0
replace nonbiochildboy_total=. if _merge==1
label define nonbiochildboy_total 0 "Girls only" -10 "No non-biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values nonbiochildboy_total nonbiochildboy_total
label var nonbiochildboy_total "Total number of non-biological children who are boys"
fre nonbiochildboy_total

//total girls (age 46)
cap drop nonbiochildgirl_total
egen nonbiochildgirl_total= total(nonbiochildsex==2), by (BCSID)
replace nonbiochildgirl_total=-10 if anynonbio==0
replace nonbiochildgirl_total=. if _merge==1
label define nonbiochildgirl_total 0 "Boys only" -10 "No non-biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values nonbiochildgirl_total nonbiochildgirl_total
label var nonbiochildgirl_total "Total number of non-biological children who are girls"
fre nonbiochildgirl_total





********************** BIOLOGICAL AND NON BIOLOGICAL CHILDREN (age 46) ******************

*** ANY BIOLOGICAL OR NON BIOLOGICAL CHILD AND NUMBER (age 46)

*any biological or non-biological children (age 46)
cap drop anychildren
egen anychildren = total(biochild==1|nonbiochild==1), by (BCSID)
replace anychildren=1 if inrange(anychildren,1,20)
replace anychildren=. if _merge==1
label variable anychildren "Whether CM has any children (biological or non-biological)"
label define yesno 0 "No" 1 "Yes" -100 "no participation in sweep" -99 "information not provided", replace
label values anychildren yesno
fre anychildren

*total number of biological or non-biologial children (age 46)
cap drop children_tot
egen children_tot = total(biochild==1|nonbiochild==1), by (BCSID)
replace children_tot=. if _merge==1
label define children_tot 0 "No biological or non-biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values children_tot children_tot
label variable children_tot "Total number of biological or non-children"
fre children_tot



***AGE OF BIOLOGICAL OR NON BIOLOGICAL CHILD (age 46)

*ages of all children (age 46)
cap drop childyears
gen childyears=. 
replace childyears=biochildagey if biochildagey!=.
replace childyears=nonbiochildagey if nonbiochildagey!=.
fre childyears

*eldest in years (age 46)
cap drop childy_eldest
egen childy_eldest = max(childyears), by (BCSID)
replace childy_eldest= -10 if anychildren==0
label define childy_eldest -10 "No children (biological or non-biological)" -100 "no participation in sweep" -99 "information not provided", replace
label values childy_eldest childy_eldest
label var childy_eldest "Age in years of eldest child (biological or non-biological)"
fre childy_eldest

*youngest in years (age 46)
cap drop childy_youngest
egen childy_youngest = min(childyears), by (BCSID)
replace childy_youngest= -10 if anychildren==0
label define childy_youngest -10 "No children (biological or non-biological)" -100 "no participation in sweep" -99 "information not provided", replace
label values childy_youngest childy_youngest
label var childy_youngest "Age in years of youngest child (biological or non-biological)"
fre childy_youngest



***SEX OF BIOLOGICAL OR NON BIOLOGICAL CHILDREN (age 46)

*sex of all children (age 46)
cap drop childsex
gen childsex=.
replace childsex=B10GSEX if biochild==1|nonbiochild==1 
label variable childsex "Sex of child"
label define childsex 1 "male" 2 "female" -100 "no participation in sweep" -99 "information not provided", replace
label values childsex childsex
fre childsex

*number of boys (age 46)
cap drop childboy_total
egen childboy_total= total(childsex==1), by (BCSID)
replace childboy_total=-10 if anychildren==0
replace childboy_total=. if _merge==1
label define childboy_total 0 "Girls only" -10 "No non-biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values childboy_total childboy_total
label var childboy_total "Total number of children who are boys (biological or non-biological)"
fre childboy_total

*number of girls (age 46)
cap drop childgirl_total
egen childgirl_total= total(childsex==2), by (BCSID)
replace childgirl_total=-10 if anychildren==0
replace childgirl_total=. if _merge==1
label define childgirl_total 0 "Boys only" -10 "No non-biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values childgirl_total childgirl_total
label var childgirl_total "Total number of children who are girls (biological or non-biological)"
fre childgirl_total





***************** PARTNER AND CHILD COMBO (age 46) ******************

//partner and biological children (age 46)
cap drop partnerchildbio
gen partnerchildbio=.
replace partnerchildbio=1 if anybiochildren==0 & partner==0 //no partner and no children
replace partnerchildbio=2 if anybiochildren==0 & partner==1 //partner but no children
replace partnerchildbio=3 if anybiochildren==1 & partner==0 //no partner but children
replace partnerchildbio=4 if anybiochildren==1 & partner==1 //partner and children
label define partnerchildbio 1 "No partner or children" 2 "Partner and no children" 3 "Children and no partner" 4 "Partner and children" -100 "no participation in sweep" -99 "information not provided", replace
label values partnerchildbio partnerchildbio
label var partnerchildbio "Whether has partner and/or any biological children"
fre partnerchildbio


//partner and any bio or nonbio children (age 46)
cap drop partnerchildany
gen partnerchildany=.
replace partnerchildany=1 if anychildren==0 & partner==0 //no partner and no children
replace partnerchildany=2 if anychildren==0 & partner==1 //partner but no children
replace partnerchildany=3 if anychildren==1 & partner==0 //no partner but children
replace partnerchildany=4 if anychildren==1 & partner==1 //partner and children
label define partnerchildany 1 "No partner or children" 2 "Partner and no children" 3 "Children and no partner" 4 "Partner and children" -100 "no participation in sweep" -99 "information not provided", replace
label values partnerchildany partnerchildany
label var partnerchildany "Whether has partner and/or any biological or non-biological children"
fre partnerchildany


**** end of data derivation (age 46)


//adding suffix _46 to denote varabels are from age 46 sweep
foreach var of varlist _all {	
rename `var' `var'_46		
if inlist("`var'", "skip_bcsid") {				
}
}
rename BCSID_46 bcsid

replace GRIDID_46=0 if GRIDID_46==.
reshape wide /// just the variables for individuals and not family summary
B10GSEX_46 B10GDIED_46 B10GSLIVE_46 B10GRTOK_46 B10GDIEDM_46 B10GDIEDY_46 B10GLEFTM_46 B10GLEFTY_46 B10GSTM_46 B10GSTY_46 B10GDOBM_46 B10GDOBY_46 B10GAGE_46 B10GCRLP_46 B10GCRLP2_46 ///
biochild_46 biochildym_46 biochildagey_46 cmageybirth_46 biochildsex_46 biochildhh_46 biochildnonhh_46 biochildprev_46 nonbiochild_46 adopt_46 foster_46 step_46 nonbiochildagey_46 nonbiochildsex_46 childyears_46 childsex_46, ///
i(bcsid) j(GRIDID_46)

//N=8,581

gen BCSAGE46SURVEY=1 //age 46 survey participation
label var BCSAGE46SURVEY "Whether took part in age 46 survey"
drop _merge

save "$derived\BCS70_fertility_age46.dta", replace
use "$derived\BCS70_fertility_age46.dta", clear 

 
 
 

 

**# Bookmark #3
*******************************************************************************
****************************** AGE 51 ***************************************** 
*******************************************************************************  
clear
set more off
 
***main interview
use "$raw\bcs11_age51_main.dta", clear
keep bcsid bd11ms b11othrela b11intm b11inty bd11weight_main
clonevar  BCSID = bcsid

codebook BCSID //N=8,016


***person grid
//codebook BCSID //N=7,776 note more CM's in person grid
merge 1:m bcsid ///
using "$raw\bcs11_age51_persongrid_longf"

//_merge==1 master only //those not with a person grid


*******************************************************************************

//partner (age 51)
//derive from HH grid
fre b11grtok //1=spouse, 2=civil partner, 3=cohabiting partner 

cap drop hhpartner
gen hhpartner=.
replace hhpartner=1 if inrange(b11grtok,1,3)

cap drop partner
egen partner = total(hhpartner==1), by (BCSID)
replace partner=1 if inrange(partner,1,20)
replace partner=. if _merge==1
label define partner 0 "No" 1 "Yes" -100 "no participation in sweep" -99 "information not provided", replace
label values partner partner
label var partner "Whether CM has current partner in hhld"
fre partner



//marital status (age 51)
fre bd11ms
cap drop marital
gen marital=.
replace marital=3 if bd11ms==1|bd11ms==3|bd11ms==4|bd11ms==6|bd11ms==7|bd11ms==8
replace marital=2 if (bd11ms==1|bd11ms==3|bd11ms==4|bd11ms==6|bd11ms==7|bd11ms==8) & partner==1
replace marital=1 if bd11ms==2|bd11ms==5
label define marital 3 "Single non-cohabiting" 2 "Single cohabiting with partner" 1 "Married or Civil Partnered" -100 "no participation in sweep" -99 "information not provided", replace
label values marital marital
label variable marital "Marital status (age 51)" 
fre marital




************************** BIOLOGICAL CHILDREN (age 51) *****************************

*-------------------------------------------------------------------*
*** WHETHER HAD ANY BIOLOGICAL CHILDREN AND TOTAL NUMBER (age 51)
fre b11grtok //4=own child
cap drop biochild
gen biochild=.
replace biochild=1 if b11grtok==4 //own child
fre biochild

*any biological children (age 51)
cap drop anybiochildren
egen anybiochildren = total(biochild==1), by (BCSID)
fre anybiochildren
replace anybiochildren=1 if inrange(anybiochildren,1,20)
replace anybiochildren=. if _merge==1
label variable anybiochildren "Whether CM has had any biological children"
label define yesno 0 "No" 1 "Yes" -100 "no participation in sweep" -99 "information not provided", replace
label values anybiochildren yesno
fre anybiochildren

*total number of biological children (age 51)
cap drop biochild_tot
egen biochild_tot = count(biochild), by (BCSID)
replace biochild_tot=. if _merge==1
label define biochild_tot 0 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values biochild_tot biochild_tot
label variable biochild_tot "Total number of biological children"
fre biochild_tot





*-------------------------------------------------------------------*
*** AGES OF BIOLOGICAL CHILDREN AND COHORT MEMBER AGE AT BIRTH (age 51) 
*interview date
fre b11intm b11inty
rename (b11intm b11inty) (intmonth intyear)
replace intmonth=. if intmonth<0
replace intyear=. if intyear<0

label define intyear -100 "no participation in sweep" -99 "information not provided", replace
label values intyear intyear

label define intmonth 1 "January" 2	"February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "	October" 11 "November" 12 "December" -100 "no participation in sweep" -99 "information not provided", replace
label values intmonth intmonth


cap drop intym
gen intym = ym(intyear,intmonth)
label var intym "Interview date - months since Jan 1960"
fre intym

*cohort member birthdate (age 51)
cap drop cmbirthy
gen cmbirthy=1970
label var cmbirthy "Birth year of CM"
fre cmbirthy

cap drop cmbirthm
gen cmbirthm=4
label var cmbirthm "Birth month of CM"
fre cmbirthm

cap drop cmbirthym
gen cmbirthym = ym(cmbirthy,cmbirthm)
label var cmbirthym "CM birth date - months since Jan 1960"
fre cmbirthym




*date of birth of biological child since Jan 1960 (age 51)
fre b11gdobm //birth month //1=jan 12=dec
replace b11gdobm=. if b11gdobm==-8

fre b11gdoby //birth year //1912 - 2018
replace b11gdoby=. if b11gdoby==-8

cap drop biochildym
gen biochildym = ym(b11gdoby, b11gdobm) if biochild==1
label var biochildym "Date of birth of biological child - months since Jan 1960"
fre biochildym



//child's age in whole years at interview (age 51)
cap drop biochildagey
gen biochildagey = (intym-biochildym)/12
fre biochildagey
replace biochildagey = floor(biochildagey)
label var biochildagey " Age in whole years of biological child"
fre biochildagey //range 0-39

//cm age in whole years at birth of child (age 51)
cap drop cmageybirth
gen cmageybirth = (biochildym-cmbirthym)/12
fre cmageybirth
replace cmageybirth = floor(cmageybirth)
label var cmageybirth "Age of CM in years at birth of biological child"
fre cmageybirth //range 12-52




***SUMMARY age of eldest and youngest biological child (in years and months) (age 51)

*eldest in years (age 51)
cap drop biochildy_eldest
egen biochildy_eldest = max(biochildagey), by (BCSID)
replace biochildy_eldest= -10 if anybiochildren==0 
label define minusten -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildy_eldest minusten
label var biochildy_eldest "Age in years of eldest biological child"
fre  biochildy_eldest

*youngest in years (age 51)
cap drop biochildy_youngest
egen biochildy_youngest = min(biochildagey), by (BCSID)
replace biochildy_youngest= -10 if anybiochildren==0
label values biochildy_youngest minusten
label var biochildy_youngest "Age in years of youngest biological child"
fre  biochildy_youngest



***SUMMARY age of cohort member at birth of eldest and youngest child (age 51)
cap drop cmageybirth_eldest //years
egen cmageybirth_eldest = min(cmageybirth), by (BCSID)
replace cmageybirth_eldest= -10 if anybiochildren==0
label values cmageybirth_eldest minusten
label var cmageybirth_eldest "CM age in years at birth of eldest biological child"
fre  cmageybirth_eldest

cap drop cmageybirth_youngest //years
egen cmageybirth_youngest = max(cmageybirth), by (BCSID)
replace cmageybirth_youngest= -10 if anybiochildren==0
label values cmageybirth_youngest minusten
label var cmageybirth_youngest "CM age in years at birth of youngest biological child"
fre  cmageybirth_youngest






*-------------------------------------------------------------------*
*** SEX OF BIOLOGICAL CHILDREN (age 51)
fre b11gsex
cap drop biochildsex
gen biochildsex=.
replace biochildsex=b11gsex if biochild==1
label variable biochildsex "Sex of -biological child"
label define biochildsex 1 "male" 2 "female" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildsex biochildsex
fre biochildsex

//total boys (age 51)
cap drop biochildboy_total
egen biochildboy_total= total(biochildsex==1), by (BCSID)
replace biochildboy_total=-10 if anybiochildren==0
replace biochildboy_total=. if _merge==1
label define biochildboy_total 0 "Girls only" -10 "No non-biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values biochildboy_total biochildboy_total
label var biochildboy_total "Total number of biological children who are boys"
fre biochildboy_total

//total girls (age 51)
cap drop biochildgirl_total
egen biochildgirl_total= total(biochildsex==2), by (BCSID)
replace biochildgirl_total=-10 if anybiochildren==0
replace biochildgirl_total=. if _merge==1
label define biochildgirl_total 0 "Boys only" -10 "No non-biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values biochildgirl_total biochildgirl_total
label var biochildgirl_total "Total number of biological children who are girls"
fre biochildgirl_total




*-------------------------------------------------------------------*
*** WHERE BIOLOGICAL CHILDREN LIVE (age 51)
fre b11gslive //whether person living with CM at interview //0=no, 1=yes

//in household
gen biochildhh=.
replace biochildhh=1 if biochild==1 & b11gslive==1
label variable biochildhh "Child lives in household"
fre biochildhh

cap drop biochildhh_total
egen biochildhh_total = count(biochildhh), by (BCSID)
replace biochildhh_total=-10 if anybiochildren==0
replace biochildhh_total=. if _merge==1
label define biochildhh_total 0 "None of the biological children live in household" -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildhh_total biochildhh_total
label variable biochildhh_total "Total number of bio children in household (HH grid data)"
fre biochildhh_total

//not in household (age 51)
gen biochildnonhh=.
replace biochildnonhh=1 if biochild==1 & b11gslive!=1
label variable biochildnonhh "Child lives outside household"
fre biochildnonhh

cap drop biochildnonhh_total
egen biochildnonhh_total = count(biochildnonhh), by (BCSID)
replace biochildnonhh_total=-10 if anybiochildren==0
replace biochildnonhh_total=. if _merge==1
label define biochildnonhh_total 0 "All biological children live in household" -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildnonhh_total biochildnonhh_total
label variable biochildnonhh_total "Total number of bio children not in household"
fre biochildnonhh_total







*-------------------------------------------------------------------*
*** OTHER PARENT OF BIOLOGICAL CHILDREN (age 51)
fre b11gcrlp //Whether child is current partner's own child //1=yes, 0=no

fre b11othrela //whether any non-residential partner 2=no

//previous partner's child (age 51)
cap drop biochildprev
gen biochildprev=.
replace biochildprev=1 if biochild==1 & (b11gcrlp==0|(partner==0 & b11othrela==2))
label variable biochildprev "Bio child's other parent is previous partner"
fre biochildprev

cap drop biochildprev_total
egen biochildprev_total = count(biochildprev), by (BCSID)
replace biochildprev_total=-10 if anybiochildren==0
replace biochildprev_total=. if _merge==1
label define biochildprev_total 0 "Current partner(s) parent to all biological children" -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildprev_total biochildprev_total
label variable biochildprev_total "Total number of biological children had with a previous partner"
fre biochildprev_total

//whether a previous partner is parent to any children (age 51)
cap drop biochildprevany
gen biochildprevany=.
replace biochildprevany=1 if inrange(biochildprev_total,1,10)
replace biochildprevany=0 if biochildprev_total==0
replace biochildprevany=-10 if biochildprev_total==-10
label variable biochildprevany "Any children with a previous partner"
label define biochildprevany 1 "Previous partner parent to all or some biological children" 0 "Current partner is parent to all biological children" -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildprevany biochildprevany
fre biochildprevany




************************** NON BIOLOGICAL CHILDREN (age 51)*****************************
*-------------------------------------------------------------------*
fre b11grtok //5=adopted, 6=child of current partner, 7=Child of previous partner, 8=fostered child

fre b11gslive //1=lives with CM at interview

cap drop nonbiochild
gen nonbiochild=.
replace nonbiochild=1 if (b11grtok==5|b11grtok==6|b11grtok==7|b11grtok==8) & b11gslive==1
label variable nonbiochild "Child is non-biological"
fre nonbiochild

cap drop adopt
gen adopt=.
replace adopt=1 if b11grtok==5 & b11gslive==1
label variable adopt "Child is adopted"
fre adopt

cap drop foster
gen foster=.
replace foster=1 if b11grtok==8 & b11gslive==1
label variable foster "Child is fostered"
fre foster

cap drop step
gen step=.
replace step=1 if (b11grtok==6|b11grtok==7) & b11gslive==1 
label variable step "Child is step-child (current or previous partner)"
fre step


//any non-bio (age 51)
cap drop anynonbio
egen anynonbio = count(nonbiochild), by (BCSID)
replace anynonbio=1 if inrange(anynonbio,1,20)
replace anynonbio=. if _merge==1
label variable anynonbio "Whether CM has any non-biological children in household"
label define yesno 0 "No" 1 "Yes" -100 "no participation in sweep" -99 "information not provided", replace
label values anynonbio yesno
fre anynonbio

//total number of non-bio (age 51)
cap drop nonbiochild_tot
egen nonbiochild_tot = count(nonbiochild), by (BCSID)
label variable nonbiochild_tot "Total number of non-biological children in household"
label define nonbiochild_tot 0 "No non-biological children in HH" -100 "no participation in sweep" -99 "information not provided", replace 
label values nonbiochild_tot nonbiochild_tot
fre nonbiochild_tot

//total number of adopted (age 51)
cap drop adopt_tot
egen adopt_tot = count(adopt), by (BCSID)
replace adopt_tot=. if _merge==1
label variable adopt_tot "Total number of adopted children in household"
label define adopt_tot 0 "No adopted children in HH" -100 "no participation in sweep" -99 "information not provided", replace 
label values adopt_tot adopt_tot
fre adopt_tot

//total number of fostered (age 51)
cap drop foster_tot
egen foster_tot = count(foster), by (BCSID)
replace foster_tot=. if _merge==1
label variable foster_tot "Total number of foster children in household"
label define foster_tot 0 "No foster children in HH" -100 "no participation in sweep" -99 "information not provided", replace 
label values foster_tot foster_tot
fre foster_tot

//total number of step-children (age 51)
cap drop step_tot
egen step_tot = count(step), by (BCSID)
replace step_tot=. if _merge==1
label variable step_tot "Total number of step-children in household"
label define step_tot 0 "No step children in HH" -100 "no participation in sweep" -99 "information not provided", replace 
label values step_tot step_tot
fre step_tot




*-------------------------------------------------------------------*
***AGE OF NON BIOLOGICAL CHILD (age 51)

fre b11gage //person's age last birthday (age 51)
cap drop nonbiochildagey
gen nonbiochildagey=.
replace nonbiochildagey=b11gage if inrange(b11gage,0,110) & nonbiochild==1
label variable nonbiochildagey "Age in years of non-biological child" 
fre nonbiochildagey

*eldest in years (age 51)
cap drop nonbiochildy_eldest
egen nonbiochildy_eldest = max(nonbiochildagey), by (BCSID)
replace nonbiochildy_eldest= -10 if anynonbio==0
label define nonbiochildy_eldest -10 "No non biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values nonbiochildy_eldest nonbiochildy_eldest
label var nonbiochildy_eldest "Age in years of eldest non biological child"
fre  nonbiochildy_eldest

*youngest in years (age 51)
cap drop nonbiochildy_youngest
egen nonbiochildy_youngest = min(nonbiochildagey), by (BCSID)
replace nonbiochildy_youngest= -10 if anynonbio==0
label define nonbiochildy_youngest -10 "No non biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values nonbiochildy_youngest nonbiochildy_youngest
label var nonbiochildy_youngest "Age in years of youngest non biological child"
fre  nonbiochildy_youngest



***SEX OF NON BIOLOGICAL CHILDREN (age 51)
fre b11gsex
cap drop nonbiochildsex
gen nonbiochildsex=.
replace nonbiochildsex=b11gsex if nonbiochild==1
label variable nonbiochildsex "Sex of non-biological child"
label define nonbiochildsex 1 "male" 2 "female" -100 "no participation in sweep" -99 "information not provided", replace
label values nonbiochildsex nonbiochildsex
fre nonbiochildsex

//total boys (age 51)
cap drop nonbiochildboy_total
egen nonbiochildboy_total= total(nonbiochildsex==1), by (BCSID)
replace nonbiochildboy_total=-10 if anynonbio==0
replace nonbiochildboy_total=. if _merge==1
label define nonbiochildboy_total 0 "Girls only" -10 "No non-biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values nonbiochildboy_total nonbiochildboy_total
label var nonbiochildboy_total "Total number of non-biological children who are boys"
fre nonbiochildboy_total

//total girls (age 51)
cap drop nonbiochildgirl_total
egen nonbiochildgirl_total= total(nonbiochildsex==2), by (BCSID)
replace nonbiochildgirl_total=-10 if anynonbio==0
replace nonbiochildgirl_total=. if _merge==1
label define nonbiochildgirl_total 0 "Boys only" -10 "No non-biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values nonbiochildgirl_total nonbiochildgirl_total
label var nonbiochildgirl_total "Total number of non-biological children who are girls"
fre nonbiochildgirl_total





********************** BIOLOGICAL AND NON BIOLOGICAL CHILDREN (age 51) ******************

*** ANY BIOLOGICAL OR NON BIOLOGICAL CHILD AND NUMBER (age 51)

*any biological or non-biological children (age 51)
cap drop anychildren
egen anychildren = total(biochild==1|nonbiochild==1), by (BCSID)
replace anychildren=1 if inrange(anychildren,1,20)
replace anychildren=. if _merge==1
label variable anychildren "Whether CM has any children (biological or non-biological)"
label define yesno 0 "No" 1 "Yes" -100 "no participation in sweep" -99 "information not provided", replace
label values anychildren yesno
fre anychildren

*total number of biological or non-biologial children (age 51)
cap drop children_tot
egen children_tot = total(biochild==1|nonbiochild==1), by (BCSID)
replace children_tot=. if _merge==1
label define children_tot 0 "No biological or non-biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values children_tot children_tot
label variable children_tot "Total number of biological or non-children"
fre children_tot





***AGE OF BIOLOGICAL OR NON BIOLOGICAL CHILD (age 51)

*ages of all children (age 51)
cap drop childyears
gen childyears=. 
replace childyears=biochildagey if biochildagey!=.
replace childyears=nonbiochildagey if nonbiochildagey!=.
fre childyears

*eldest in years (age 51)
cap drop childy_eldest
egen childy_eldest = max(childyears), by (BCSID)
replace childy_eldest= -10 if anychildren==0
label define childy_eldest -10 "No children (biological or non-biological)" -100 "no participation in sweep" -99 "information not provided", replace
label values childy_eldest childy_eldest
label var childy_eldest "Age in years of eldest child (biological or non biological)"
fre childy_eldest

*youngest in years (age 51)
cap drop childy_youngest
egen childy_youngest = min(childyears), by (BCSID)
replace childy_youngest= -10 if anychildren==0
label define childy_youngest -10 "No children (biological or non-biological)" -100 "no participation in sweep" -99 "information not provided", replace
label values childy_youngest childy_youngest
label var childy_youngest "Age in years of youngest child (biological or non biological)"
fre childy_youngest





***SEX OF BIOLOGICAL OR NON BIOLOGICAL CHILDREN (age 51)

*sex of all children (age 51)
cap drop childsex
gen childsex=.
replace childsex=b11gsex if biochild==1|nonbiochild==1 
replace childsex=. if childsex==-8
label variable childsex "Sex of child"
label define childsex 1 "male" 2 "female" -100 "no participation in sweep" -99 "information not provided", replace
label values childsex childsex
fre childsex

*number of boys (age 51)
cap drop childboy_total
egen childboy_total= total(childsex==1), by (BCSID)
replace childboy_total=-10 if anychildren==0
replace childboy_total=. if _merge==1
label define childboy_total 0 "Girls only" -10 "No non-biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values childboy_total childboy_total
label var childboy_total "Total number of children who are boys (biological or non-biological)"
fre childboy_total

*number of girls (age 51)
cap drop childgirl_total
egen childgirl_total= total(childsex==2), by (BCSID)
replace childgirl_total=-10 if anychildren==0
replace childgirl_total=. if _merge==1
label define childgirl_total 0 "Boys only" -10 "No non-biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values childgirl_total childgirl_total
label var childgirl_total "Total number of children who are girls (biological or non-biological)"
fre childgirl_total




***************** PARTNER AND CHILD COMBO (age 51) ******************

//partner and biological children (age 51)
cap drop partnerchildbio
gen partnerchildbio=.
replace partnerchildbio=1 if anybiochildren==0 & partner==0 //no partner and no children
replace partnerchildbio=2 if anybiochildren==0 & partner==1 //partner but no children
replace partnerchildbio=3 if anybiochildren==1 & partner==0 //no partner but children
replace partnerchildbio=4 if anybiochildren==1 & partner==1 //partner and children
label define partnerchildbio 1 "No partner or children" 2 "Partner and no children" 3 "Children and no partner" 4 "Partner and children" -100 "no participation in sweep" -99 "information not provided", replace
label values partnerchildbio partnerchildbio
label var partnerchildbio "Whether has partner and/or any biological children"
fre partnerchildbio


//partner and any bio or nonbio children (age 51)
cap drop partnerchildany
gen partnerchildany=.
replace partnerchildany=1 if anychildren==0 & partner==0 //no partner and no children
replace partnerchildany=2 if anychildren==0 & partner==1 //partner but no children
replace partnerchildany=3 if anychildren==1 & partner==0 //no partner but children
replace partnerchildany=4 if anychildren==1 & partner==1 //partner and children
label define partnerchildany 1 "No partner or children" 2 "Partner and no children" 3 "Children and no partner" 4 "Partner and children" -100 "no participation in sweep" -99 "information not provided", replace
label values partnerchildany partnerchildany
label var partnerchildany "Whether has partner and/or any biological or non biological children"
fre partnerchildany


**** end of data derivation (age 51)


fre hnum

replace hnum=0 if hnum==.

duplicates drop BCSID, force
//8,016

keep BCSID intmonth intyear partner marital anybiochildren biochild_tot biochildy_eldest biochildy_youngest cmageybirth_eldest cmageybirth_youngest biochildboy_total biochildgirl_total biochildhh_total biochildnonhh_total biochildprev_total biochildprevany anynonbio nonbiochild_tot adopt_tot foster_tot step_tot nonbiochildy_eldest nonbiochildy_youngest nonbiochildboy_total nonbiochildgirl_total anychildren children_tot childy_eldest childy_youngest childboy_total childgirl_total partnerchildbio partnerchildany bd11weight_main

rename BCSID bcsid

//adding suffix _51 to denote varabels are from age 51 sweep
foreach var of varlist intmonth intyear partner marital anybiochildren biochild_tot biochildy_eldest biochildy_youngest cmageybirth_eldest cmageybirth_youngest biochildboy_total biochildgirl_total biochildhh_total biochildnonhh_total biochildprev_total biochildprevany anynonbio nonbiochild_tot adopt_tot foster_tot step_tot nonbiochildy_eldest nonbiochildy_youngest nonbiochildboy_total nonbiochildgirl_total anychildren children_tot childy_eldest childy_youngest childboy_total childgirl_total partnerchildbio partnerchildany {	
rename `var' `var'_51		
}

gen bcssurvey_51=1 //age 51 survey participation
label var bcssurvey_51 "Whether took part in age 51 survey"

replace bcssurvey_51=0 if bcssurvey_51==.	
label define bcssurvey_51 1 "Yes" 0 "No participation in survey sweep", replace	
label values bcssurvey_51 bcssurvey_51
fre bcssurvey_51



order bcsid bcssurvey_51 intyear_51	intmonth_51	partner_51	marital_51	anybiochildren_51	biochild_tot_51 biochildhh_total_51	biochildnonhh_total_51	biochildprev_total_51	biochildprevany_51	biochildy_eldest_51	biochildy_youngest_51	cmageybirth_eldest_51	cmageybirth_youngest_51	biochildboy_total_51	biochildgirl_total_51	anynonbio_51	nonbiochild_tot_51	adopt_tot_51	foster_tot_51	step_tot_51	nonbiochildy_eldest_51	nonbiochildy_youngest_51	nonbiochildboy_total_51	nonbiochildgirl_total_51	anychildren_51	children_tot_51	childy_eldest_51	childy_youngest_51	childboy_total_51	childgirl_total_51	partnerchildbio_51	partnerchildany_51 bd11weight_main


save "$derived\BCS70_fertility_age51.dta", replace
use "$derived\BCS70_fertility_age51.dta", clear 

  
  
**# Bookmark #7
*******************************************************************************
*********** MERGING AND FURTHER WORK ON OVERALL DATA ********************************** 
*******************************************************************************  


//we need sex from response file
use "$raw\bcs_response", clear
keep BCSID SEX

rename BCSID bcsid
rename SEX sex
replace sex=-99 if sex==3
label define sex 1 "Male" 2 "Female" -99 "information not provided", replace
label values sex sex
fre sex


*merge with all derived fertility data
merge 1:1 bcsid using "$derived\BCS70_fertility_age38.dta" //earlier sweep are included here
drop _merge
merge 1:1 bcsid using "$derived\BCS70_fertility_age42.dta"
drop _merge
merge 1:1 bcsid using "$derived\BCS70_fertility_age46.dta"
drop _merge 
merge 1:1 bcsid using "$derived\BCS70_fertility_age51.dta"
drop _merge 


rename  (BCSAGE26SURVEY_26 BCSAGE30SURVEY_30 BCSAGE34SURVEY_34 BCSAGE38SURVEY_38 BCSAGE42SURVEY BCSAGE46SURVEY) (bcssurvey_26 bcssurvey_30 bcssurvey_34 bcssurvey_38 bcssurvey_42 bcssurvey_46)

*keeping if taking part in at least one fertility sweep
keep if bcssurvey_26==1| bcssurvey_30==1| bcssurvey_34==1| bcssurvey_38==1| bcssurvey_42==1| bcssurvey_46==1 | bcssurvey_51==1
//N=13,861


//cohort member birthdate
cap drop cmbyear
gen cmbyear=1970
label var cmbyear "Birth year of CM"
fre cmbyear

cap drop cmbmonth
gen cmbmonth=4
label var cmbmonth "Birth month of CM"
label define cmbmonth 4 "April"
label values cmbmonth cmbmonth
fre cmbmonth


*flag for insonsistencies number of children between sweeps (highe number of biological children in previous sweep)

cap drop biototal_flag_26_30
gen biototal_flag_26_30=biochild_tot_30-biochild_tot_26
replace biototal_flag_26_30=0 if inrange(biototal_flag_26_30,0,10)
replace biototal_flag_26_30=1 if inrange(biototal_flag_26_30,-10,-1)
label define biototal_flag_26_30 1 "Yes" 0 "No" -100 "no participation in one or both sweeps" -99 "information not provided", replace
label values biototal_flag_26_30 biototal_flag_26_30
label variable biototal_flag_26_30 "More biological children reported at age 26 than at age 30"
fre biototal_flag_26_30 //some inconsistencies N=44

cap drop biototal_flag_30_34
gen biototal_flag_30_34=biochild_tot_34-biochild_tot_30
replace biototal_flag_30_34=0 if inrange(biototal_flag_30_34,0,10)
replace biototal_flag_30_34=1 if inrange(biototal_flag_30_34,-10,-1)
label define biototal_flag_30_34 1 "Yes" 0 "No" -100 "no participation in one or both sweeps" -99 "information not provided", replace
label values biototal_flag_30_34 biototal_flag_30_34
label variable biototal_flag_30_34 "More biological children reported at age 30 than at age 34"
fre biototal_flag_30_34 //no inconsistencies


cap drop biototal_flag_34_38
gen biototal_flag_34_38=biochild_tot_38-biochild_tot_34
replace biototal_flag_34_38=0 if inrange(biototal_flag_34_38,0,10)
replace biototal_flag_34_38=1 if inrange(biototal_flag_34_38,-10,-1)
label define biototal_flag_34_38 1 "Yes" 0 "No" -100 "no participation in one or both sweeps" -99 "information not provided", replace
label values biototal_flag_34_38 biototal_flag_34_38
label variable biototal_flag_34_38 "More biological children reported at age 34 than at age 38"
fre biototal_flag_34_38 //no inconsistencies

cap drop biototal_flag_38_42
gen biototal_flag_38_42=biochild_tot_42-biochild_tot_38
replace biototal_flag_38_42=0 if inrange(biototal_flag_38_42,0,10)
replace biototal_flag_38_42=1 if inrange(biototal_flag_38_42,-10,-1)
label define biototal_flag_38_42 1 "Yes" 0 "No" -100 "no participation in sweep" -99 "information not provided", replace
label values biototal_flag_38_42 biototal_flag_38_42
label variable biototal_flag_38_42 "More biological children reported at age 38 than at age 42"
fre biototal_flag_38_42 //some inconsistencies N=149


cap drop biototal_flag_42_46
gen biototal_flag_42_46=biochild_tot_46-biochild_tot_42
replace biototal_flag_42_46=0 if inrange(biototal_flag_42_46,0,10)
replace biototal_flag_42_46=1 if inrange(biototal_flag_42_46,-10,-1)
label define biototal_flag_42_46 1 "Yes" 0 "No" -100 "no participation in sweep" -99 "information not provided", replace
label values biototal_flag_42_46 biototal_flag_42_46
label variable biototal_flag_42_46 "More biological children reported at age 42 than at age 46"
fre biototal_flag_42_46 //some inconsistencies N=47


cap drop biototal_flag_46_51
gen biototal_flag_46_51=biochild_tot_51-biochild_tot_46
replace biototal_flag_46_51=0 if inrange(biototal_flag_46_51,0,10)
replace biototal_flag_46_51=1 if inrange(biototal_flag_46_51,-10,-1)
label define biototal_flag_46_51 1 "Yes" 0 "No" -100 "no participation in sweep" -99 "information not provided", replace
label values biototal_flag_46_51 biototal_flag_46_51
label variable biototal_flag_46_51 "More biological children reported at age 46 than at age 51"
fre biototal_flag_46_51 //some inconsistencies N=68





*label and code survey participation
foreach Y of varlist bcssurvey_26 bcssurvey_30 bcssurvey_34 bcssurvey_38 bcssurvey_42 bcssurvey_46 bcssurvey_51 {
replace `Y'=0 if `Y'==.	
	
label define `Y' 1 "Yes" 0 "No participation in survey sweep", replace	
label values `Y' `Y'
fre `Y'
}



*MISSSING DATA CODING

*age 26
foreach Y of varlist partner_26 marital_26 anybiochildren_26 biochild_tot_26 biochildhh_total_26 biochildnonhh_total_26 biochildprevany_26 biochildy_eldest_26 biochildy_youngest_26 cmageybirth_eldest_26 cmageybirth_youngest_26 biochildboy_total_26 biochildgirl_total_26 anynonbio_26 nonbiochild_tot_26 adopt_tot_26 foster_tot_26 step_tot_26 nonbiochildy_eldest_26 nonbiochildy_youngest_26 nonbiochildboy_total_26 nonbiochildgirl_total_26 anychildren_26 children_tot_26 childboy_total_26 childgirl_total_26 childy_eldest_26 childy_youngest_26 partnerchildbio_26 partnerchildany_26  {

replace `Y'=-100 if `Y'==. & bcssurvey_26==0 
replace `Y'=-99 if `Y'==. 	
fre `Y'	
}


*age 30
foreach Y of varlist intyear_30	intmonth_30	partner_30	marital_30	anybiochildren_30	biochild_tot_30	biochildhh_total_30	biochild_extra_flag_30	biochildnonhh_total_30		biochildprev_total_30	biochildprevany_30	biochildy_eldest_30	biochildy_youngest_30	cmageybirth_eldest_30	cmageybirth_youngest_30	biochildboy_total_30	biochildgirl_total_30	anynonbio_30	nonbiochild_tot_30	adopt_tot_30	foster_tot_30	step_tot_30	nonbiochildy_eldest_30	nonbiochildy_youngest_30	nonbiochildboy_total_30	nonbiochildgirl_total_30	anychildren_30	children_tot_30	childy_eldest_30	childy_youngest_30	childboy_total_30	childgirl_total_30	partnerchildbio_30	partnerchildany_30 {

replace `Y'=-100 if `Y'==. & bcssurvey_30==0 
replace `Y'=-99 if `Y'==. 	
fre `Y'	
}


*age 34
foreach Y of varlist intyear_34	intmonth_34	partner_34	marital_34	anybiochildren_34	biochild_tot_34	biochildhh_total_34	biochild_extra_flag_34	biochildnonhh_total_34	biochildprev_total_34	biochildprevany_34	biochildy_eldest_34	biochildy_youngest_34	cmageybirth_eldest_34	cmageybirth_youngest_34	biochildboy_total_34	biochildgirl_total_34	anynonbio_34	nonbiochild_tot_34	adopt_tot_34	foster_tot_34	step_tot_34	nonbiochildy_eldest_34	nonbiochildy_youngest_34	nonbiochildboy_total_34	nonbiochildgirl_total_34	anychildren_34	children_tot_34	childy_eldest_34	childy_youngest_34	childboy_total_34	childgirl_total_34	partnerchildbio_34	partnerchildany_34 {

replace `Y'=-100 if `Y'==. & bcssurvey_34==0 
replace `Y'=-99 if `Y'==. 	
fre `Y'	
}


*age 38
foreach Y of varlist intyear_38	intmonth_38	partner_38	marital_38	anybiochildren_38	biochild_tot_38	biochildhh_total_38	biochild_extra_flag_38	biochildnonhh_total_38	biochildprev_total_38	biochildprevany_38	biochildy_eldest_38	biochildy_youngest_38	cmageybirth_eldest_38	cmageybirth_youngest_38	biochildboy_total_38	biochildgirl_total_38	anynonbio_38	nonbiochild_tot_38	adopt_tot_38	foster_tot_38	step_tot_38	nonbiochildy_eldest_38	nonbiochildy_youngest_38	nonbiochildboy_total_38	nonbiochildgirl_total_38	anychildren_38	children_tot_38	childy_eldest_38	childy_youngest_38	childboy_total_38	childgirl_total_38	partnerchildbio_38	partnerchildany_38 {

replace `Y'=-100 if `Y'==. & bcssurvey_38==0 
replace `Y'=-99 if `Y'==. 	
fre `Y'	
}


*age 42
foreach Y of varlist intyear_42	intmonth_42	partner_42	marital_42	anybiochildren_42	biochild_tot_42	biochildhh_total_42	biochildnonhh_total_42	biochildprev_total_42	biochildprevany_42	biochildy_eldest_42	biochildy_youngest_42	cmageybirth_eldest_42	cmageybirth_youngest_42	biochildboy_total_42	biochildgirl_total_42	anynonbio_42	nonbiochild_tot_42	adopt_tot_42	foster_tot_42	step_tot_42	nonbiochildy_eldest_42	nonbiochildy_youngest_42	nonbiochildboy_total_42	nonbiochildgirl_total_42	anychildren_42	children_tot_42	childy_eldest_42	childy_youngest_42	childboy_total_42	childgirl_total_42	partnerchildbio_42	partnerchildany_42  {

replace `Y'=-100 if `Y'==. & bcssurvey_42==0 
replace `Y'=-99 if `Y'==. 	
fre `Y'	
}



*age 46
foreach Y of varlist intyear_46	intmonth_46	partner_46	marital_46	anybiochildren_46	biochild_tot_46	biochildhh_total_46	biochildnonhh_total_46	biochildprev_total_46	biochildprevany_46	biochildy_eldest_46	biochildy_youngest_46	cmageybirth_eldest_46	cmageybirth_youngest_46	biochildboy_total_46	biochildgirl_total_46	anynonbio_46	nonbiochild_tot_46	adopt_tot_46	foster_tot_46	step_tot_46	nonbiochildy_eldest_46	nonbiochildy_youngest_46	nonbiochildboy_total_46	nonbiochildgirl_total_46	anychildren_46	children_tot_46	childy_eldest_46	childy_youngest_46	childboy_total_46	childgirl_total_46	partnerchildbio_46	partnerchildany_46  {

replace `Y'=-100 if `Y'==. & bcssurvey_46==0 
replace `Y'=-99 if `Y'==. 	
fre `Y'	
}

*age 51
foreach Y of varlist intyear_51 intmonth_51 partner_51 marital_51 anybiochildren_51 biochild_tot_51 biochildhh_total_51 biochildnonhh_total_51 biochildprev_total_51 biochildprevany_51 biochildy_eldest_51 biochildy_youngest_51 cmageybirth_eldest_51 cmageybirth_youngest_51 biochildboy_total_51 biochildgirl_total_51 anynonbio_51 nonbiochild_tot_51 adopt_tot_51 foster_tot_51 step_tot_51 nonbiochildy_eldest_51 nonbiochildy_youngest_51 nonbiochildboy_total_51 nonbiochildgirl_total_51 anychildren_51 children_tot_51 childy_eldest_51 childy_youngest_51 childboy_total_51 childgirl_total_51 partnerchildbio_51 partnerchildany_51  {

replace `Y'=-100 if `Y'==. & bcssurvey_51==0 
replace `Y'=-99 if `Y'==. 	
fre `Y'	
}



*cross sweep missingness
replace biototal_flag_26_30=-100 if biototal_flag_26_30==. & (bcssurvey_26==0 | bcssurvey_30==0)
replace biototal_flag_26_30=-99 if biototal_flag_26_30==. 	
fre biototal_flag_26_30	

replace biototal_flag_30_34=-100 if biototal_flag_30_34==. & (bcssurvey_30==0 | bcssurvey_34==0)
replace biototal_flag_30_34=-99 if biototal_flag_30_34==. 	
fre biototal_flag_30_34	

replace biototal_flag_34_38=-100 if biototal_flag_34_38==. & (bcssurvey_34==0 | bcssurvey_38==0)
replace biototal_flag_34_38=-99 if biototal_flag_34_38==. 	
fre biototal_flag_34_38	

replace biototal_flag_38_42=-100 if biototal_flag_38_42==. & (bcssurvey_38==0 | bcssurvey_42==0)
replace biototal_flag_38_42=-99 if biototal_flag_38_42==. 	
fre biototal_flag_38_42	

replace biototal_flag_42_46=-100 if biototal_flag_42_46==. & (bcssurvey_42==0 | bcssurvey_46==0)
replace biototal_flag_42_46=-99 if biototal_flag_42_46==. 	
fre biototal_flag_42_46	

replace biototal_flag_46_51=-100 if biototal_flag_46_51==. & (bcssurvey_46==0 | bcssurvey_51==0)
replace biototal_flag_46_51=-99 if biototal_flag_46_51==. 	
fre biototal_flag_46_51	




//RELABELLING VARIABLES
label var	adopt_tot_26	"Number of adopted children in HH (age 26)"
label var	adopt_tot_30	"Number of adopted children in HH (age 30)"
label var	adopt_tot_34	"Number of adopted children in HH (age 34)"
label var	adopt_tot_38	"Number of adopted children in HH (age 38)"
label var	adopt_tot_42	"Number of adopted children in HH (age 42)"
label var	adopt_tot_46	"Number of adopted children in HH (age 46)"
label var	anybiochildren_26	"Whether has had any bio children (age 26)"
label var	anybiochildren_30	"Whether has had any bio children (age 30)"
label var	anybiochildren_34	"Whether has had any bio children (age 34)"
label var	anybiochildren_38	"Whether has had any bio children (age 38)"
label var	anybiochildren_42	"Whether has had any bio children (age 42)"
label var	anybiochildren_46	"Whether has had any bio children (age 46)"
label var	anychildren_26	"Whether has any children (bio or non-bio) (age 26)"
label var	anychildren_30	"Whether has any children (bio or non-bio) (age 30)"
label var	anychildren_34	"Whether has any children (bio or non-bio) (age 34)"
label var	anychildren_38	"Whether has any children (bio or non-bio) (age 38)"
label var	anychildren_42	"Whether has any children (bio or non-bio) (age 42)"
label var	anychildren_46	"Whether has any children (bio or non-bio) (age 46)"
label var	anynonbio_26	"Whether has any non-bio children in HH (age 26)"
label var	anynonbio_30	"Whether has any non-bio children in HH (age 30)"
label var	anynonbio_34	"Whether has any non-bio children in HH (age 34)"
label var	anynonbio_38	"Whether has any non-bio children in HH (age 38)"
label var	anynonbio_42	"Whether has any non-bio children in HH (age 42)"
label var	anynonbio_46	"Whether has any non-bio children in HH (age 46)"
label var	bcssurvey_26	"Whether took part in age 26 survey"
label var	bcssurvey_30	"Whether took part in age 30 survey"
label var	bcssurvey_34	"Whether took part in age 34 survey"
label var	bcssurvey_38	"Whether took part in age 38 survey"
label var	bcssurvey_42	"Whether took part in age 42 survey"
label var	bcssurvey_46	"Whether took part in age 46 survey"
label var	bcsid	"research case identifier"
label var	biochild_extra_flag_30	"Flag: More bio children reported in HH grid than in pregnancy data (age 30)"
label var	biochild_extra_flag_34	"Flag: More bio children reported in HH grid than in pregnancy data (age 34)"
label var	biochild_extra_flag_38	"Flag: More bio children reported in HH grid than in pregnancy data (age 38)"
label var	biochild_tot_26	"Number of bio children (age 26)"
label var	biochild_tot_30	"Number of bio children (age 30)"
label var	biochild_tot_34	"Number of bio children (age 34)"
label var	biochild_tot_38	"Number of bio children (age 38)"
label var	biochild_tot_42	"Number of bio children (age 42)"
label var	biochild_tot_46	"Number of bio children (age 46)"
label var	biochildboy_total_26	"Number of bio children who are boys (age 26)"
label var	biochildboy_total_30	"Number of bio children who are boys (age 30)"
label var	biochildboy_total_34	"Number of bio children who are boys (age 34)"
label var	biochildboy_total_38	"Number of bio children who are boys (age 38)"
label var	biochildboy_total_42	"Number of bio children who are boys (age 42)"
label var	biochildboy_total_46	"Number of bio children who are boys (age 46)"
label var	biochildgirl_total_26	"Number of bio children who are girls (age 26)"
label var	biochildgirl_total_30	"Number of bio children who are girls (age 30)"
label var	biochildgirl_total_34	"Number of bio children who are girls (age 34)"
label var	biochildgirl_total_38	"Number of bio children who are girls (age 38)"
label var	biochildgirl_total_42	"Number of bio children who are girls (age 42)"
label var	biochildgirl_total_46	"Number of bio children who are girls (age 46)"
label var	biochildhh_total_26	"Number of bio children in HH (age 26)"
label var	biochildhh_total_30	"Number of bio children in HH (age 30)"
label var	biochildhh_total_34	"Number of bio children in HH (age 34)"
label var	biochildhh_total_38	"Number of bio children in HH (age 38)"
label var	biochildhh_total_42	"Number of bio children in HH (age 42)"
label var	biochildhh_total_46	"Number of bio children in HH (age 46)"
label var	biochildnonhh_total_26	"Number of bio children not in HH (age 26)"
label var	biochildnonhh_total_30	"Number of bio children not in HH (age 30)"
label var	biochildnonhh_total_34	"Number of bio children not in HH (age 34)"
label var	biochildnonhh_total_38	"Number of bio children not in HH (age 38)"
label var	biochildnonhh_total_42	"Number of bio children not in HH (age 42)"
label var	biochildnonhh_total_46	"Number of bio children not in HH (age 46)"
label var	biochildprev_total_30	"Number of bio children had with a previous partner (age 30)"
label var	biochildprev_total_34	"Number of bio children had with a previous partner (age 34)"
label var	biochildprev_total_38	"Number of bio children had with a previous partner (age 38)"
label var	biochildprev_total_42	"Number of bio children had with a previous partner (age 42)"
label var	biochildprev_total_46	"Number of bio children had with a previous partner (age 46)"
label var	biochildprevany_26	"Have had any bio children with a previous partner (age 26)"
label var	biochildprevany_30	"Have had any bio children with a previous partner (age 30)"
label var	biochildprevany_34	"Have had any bio children with a previous partner (age 34)"
label var	biochildprevany_38	"Have had any bio children with a previous partner (age 38)"
label var	biochildprevany_42	"Have had any bio children with a previous partner (age 42)"
label var	biochildprevany_46	"Have had any bio children with a previous partner (age 46)"
label var	biochildy_eldest_26	"Age in years of eldest bio child  (age 26)"
label var	biochildy_eldest_30	"Age in years of eldest bio child  (age 30)"
label var	biochildy_eldest_34	"Age in years of eldest bio child age 34)"
label var	biochildy_eldest_38	"Age in years of eldest bio child (age 38)"
label var	biochildy_eldest_42	"Age in years of eldest bio child (age 42)"
label var	biochildy_eldest_46	"Age in years of eldest bio child (age 46)"
label var	biochildy_youngest_26	"Age in years of youngest bio child  (age 26)"
label var	biochildy_youngest_30	"Age in years of youngest bio child  (age 30)"
label var	biochildy_youngest_34	"Age in years of youngest bio child (age 34)"
label var	biochildy_youngest_38	"Age in years of youngest bio child (age 38)"
label var	biochildy_youngest_42	"Age in years of youngest bio child (age 42)"
label var	biochildy_youngest_46	"Age in years of youngest bio child (age 46)"
label var	childboy_total_26	"Number of children who are boys (bio or non-bio) (age 26)"
label var	childboy_total_30	"Number of children who are boys (bio or non-bio) (age 30)"
label var	childboy_total_34	"Number of children who are boys (bio or non-bio) (age 34)"
label var	childboy_total_38	"Number of children who are boys (bio or non-bio) (age 38)"
label var	childboy_total_42	"Number of children who are boys (bio or non-bio) (age 42)"
label var	childboy_total_46	"Number of children who are boys (bio or non-bio) (age 46)"
label var	childgirl_total_26	"Number of children who are girls (bio or non-bio) (age 26)"
label var	childgirl_total_30	"Number of children who are girls (bio or non-bio) (age 30)"
label var	childgirl_total_34	"Number of children who are girls (bio or non-bio) (age 34)"
label var	childgirl_total_38	"Number of children who are girls (bio or non-bio) (age 38)"
label var	childgirl_total_42	"Number of children who are girls (bio or non-bio) (age 42)"
label var	childgirl_total_46	"Number of children who are girls (bio or non-bio) (age 46)"
label var	children_tot_26	"Number of children (bio or non-bio) (age 26)"
label var	children_tot_30	"Number of children (bio or non-bio) (age 30)"
label var	children_tot_34	"Number of children (bio or non-bio) (age 34)"
label var	children_tot_38	"Number of children (bio or non-bio) (age 38)"
label var	children_tot_42	"Number of children (bio or non-bio) (age 42)"
label var	children_tot_46	"Number of children (bio or non-bio) (age 46)"
label var	childy_eldest_26	"Age in years of eldest child (bio or non-bio) (age 26)"
label var	childy_eldest_30	"Age in years of eldest child (bio or non-bio) (age 30)"
label var	childy_eldest_34	"Age in years of eldest child (bio or non-bio) (age 34)"
label var	childy_eldest_38	"Age in years of eldest child (bio or non-bio) (age 38)"
label var	childy_eldest_42	"Age in years of eldest child (bio or non-bio) (age 42)"
label var	childy_eldest_46	"Age in years of eldest child (bio or non-bio) (age 46)"
label var	childy_youngest_26	"Age in years of youngest child (bio or non-bio) (age 26)"
label var	childy_youngest_30	"Age in years of youngest child (bio or non-bio) (age 30)"
label var	childy_youngest_34	"Age in years of youngest child (bio or non-bio) (age 34)"
label var	childy_youngest_38	"Age in years of youngest child (bio or non-bio) (age 38)"
label var	childy_youngest_42	"Age in years of youngest child (bio or non-bio) (age 42)"
label var	childy_youngest_46	"Age in years of youngest child (bio or non-bio) (age 46)"
label var	cmageybirth_eldest_26	"Age in years of CM at birth of eldest bio child (age 26)"
label var	cmageybirth_eldest_30	"Age in years of CM at birth of eldest bio child (age 30)"
label var	cmageybirth_eldest_34	"Age in years of CM at birth of eldest bio child (age 34)"
label var	cmageybirth_eldest_38	"Age in years of CM at birth of eldest bio child (age 38)"
label var	cmageybirth_eldest_42	"Age in years of CM at birth of eldest bio child (age 42)"
label var	cmageybirth_eldest_46	"Age in years of CM at birth of eldest bio child (age 46)"
label var	cmageybirth_youngest_26	"Age in years of CM at birth of youngest bio child (age 26)"
label var	cmageybirth_youngest_30	"Age in years of CM at birth of youngest bio child (age 30)"
label var	cmageybirth_youngest_34	"Age in years of CM at birth of youngest bio child (age 34)"
label var	cmageybirth_youngest_38	"Age in years of CM at birth of youngest bio child (age 38)"
label var	cmageybirth_youngest_42	"Age in years of CM at birth of youngest bio child (age 42)"
label var	cmageybirth_youngest_46	"Age in years of CM at birth of youngest bio child (age 46)"
label var	cmbmonth	"Birth month of CM"
label var	cmbyear	"Birth year of CM"
label var	foster_tot_26	"Number of foster children in HH (age 26)"
label var	foster_tot_30	"Number of foster children in HH (age 30)"
label var	foster_tot_34	"Number of foster children in HH (age 34)"
label var	foster_tot_38	"Number of foster children in HH (age 38)"
label var	foster_tot_42	"Number of foster children in HH (age 42)"
label var	foster_tot_46	"Number of foster children in HH (age 46)"
label var	intmonth_30	"Interview month (age 30)"
label var	intmonth_34	"Interview month (age 34)"
label var	intmonth_38	"Interview month (age 38)"
label var	intmonth_42	"Interview month (age 42)"
label var	intmonth_46	"Interview month (age 46)"
label var	intyear_30	"Interview year (age 30)"
label var	intyear_34	"Interview year (age 34)"
label var	intyear_38	"Interview year (age 38)"
label var	intyear_42	"Interview year (age 42)"
label var	intyear_46	"Interview year (age 46)"
label var	marital_26	"Marital status (age 26)"
label var	marital_30	"Marital status (age 30)"
label var	marital_34	"Marital status (age 34)"
label var	marital_38	"Marital status (age 38)"
label var	marital_42	"Marital status (age 42)"
label var	marital_46	"Marital status (age 46)"
label var	nonbiochild_tot_26	"Number of non-bio children in HH (age 26)"
label var	nonbiochild_tot_30	"Number of non-bio children in HH (age 30)"
label var	nonbiochild_tot_34	"Number of non-bio children in HH (age 34)"
label var	nonbiochild_tot_38	"Number of non-bio children in HH (age 38)"
label var	nonbiochild_tot_42	"Number of non-bio children in HH (age 42)"
label var	nonbiochild_tot_46	"Number of non-bio children in HH (age 46)"
label var	nonbiochildboy_total_26	"Number of non-bio children who are boys (age 26)"
label var	nonbiochildboy_total_30	"Number of non-bio children who are boys (age 30)"
label var	nonbiochildboy_total_34	"Number of non-bio children who are boys (age 34)"
label var	nonbiochildboy_total_38	"Number of non-bio children who are boys (age 38)"
label var	nonbiochildboy_total_42	"Number of non-bio children who are boys (age 42)"
label var	nonbiochildboy_total_46	"Number of non-bio children who are boys (age 46)"
label var	nonbiochildgirl_total_26	"Number of non-bio children who are girls (age 26)"
label var	nonbiochildgirl_total_30	"Number of non-bio children who are girls (age 30)"
label var	nonbiochildgirl_total_34	"Number of non-bio children who are girls (age 34)"
label var	nonbiochildgirl_total_38	"Number of non-bio children who are girls (age 38)"
label var	nonbiochildgirl_total_42	"Number of non-bio children who are girls (age 42)"
label var	nonbiochildgirl_total_46	"Number of non-bio children who are girls (age 46)"
label var	nonbiochildy_eldest_26	"Age in years of eldest non-bio child (age 26)"
label var	nonbiochildy_eldest_30	"Age in years of eldest non-bio child (age 30)"
label var	nonbiochildy_eldest_34	"Age in years of eldest non-bio child (age 34)"
label var	nonbiochildy_eldest_38	"Age in years of eldest non-bio child (age 38)"
label var	nonbiochildy_eldest_42	"Age in years of eldest non-bio child (age 42)"
label var	nonbiochildy_eldest_46	"Age in years of eldest non-bio child (age 46)"
label var	nonbiochildy_youngest_26	"Age in years of youngest non-bio child (age 26)"
label var	nonbiochildy_youngest_30	"Age in years of youngest non-bio child (age 30)"
label var	nonbiochildy_youngest_34	"Age in years of youngest non-bio child (age 34)"
label var	nonbiochildy_youngest_38	"Age in years of youngest non-bio child (age 38)"
label var	nonbiochildy_youngest_42	"Age in years of youngest non-bio child (age 42)"
label var	nonbiochildy_youngest_46	"Age in years of youngest non-bio child (age 46)"
label var	partner_26	"Whether has a partner in HH (age 26)"
label var	partner_30	"Whether has a partner in HH (age 30)"
label var	partner_34	"Whether has a partner in HH (age 34)"
label var	partner_38	"Whether has a partner in HH (age 38)"
label var	partner_42	"Whether has a partner in HH (age 42)"
label var	partner_46	"Whether has a partner in HH (age 46)"
label var	partnerchildany_26	"Whether has live-in partner/spouse and/or any bio or non-bio children (age 26)"
label var	partnerchildany_30	"Whether has live-in partner/spouse and/or any bio or non-bio children (age 30)"
label var	partnerchildany_34	"Whether has live-in partner/spouse and/or any bio or non-bio children (age 34)"
label var	partnerchildany_38	"Whether has live-in partner/spouse and/or any bio or non-bio children (age 38)"
label var	partnerchildany_42	"Whether has live-in partner/spouse and/or any bio or non-bio children (age 42)"
label var	partnerchildany_46	"Whether has live-in partner/spouse and/or any bio or non-bio children (age 46)"
label var	partnerchildbio_26	"Whether has live-in partner/spouse and/or any bio children (absent or in HH) (age 26)"
label var	partnerchildbio_30	"Whether has live-in partner/spouse and/or any bio children (absent or in HH) (age 30)"
label var	partnerchildbio_34	"Whether has live-in partner/spouse and/or any bio children (absent or in HH) (age 34)"
label var	partnerchildbio_38	"Whether has live-in partner/spouse and/or any bio children (absent or in HH) (age 38)"
label var	partnerchildbio_42	"Whether has live-in partner/spouse and/or any bio children (absent or in HH) (age 42)"
label var	partnerchildbio_46	"Whether has live-in partner/spouse and/or any bio children (absent or in HH) (age 46)"
label var	sex	"sex of cohort member"
label var	step_tot_26	"Number of stepchildren in HH (age 26)"
label var	step_tot_30	"Number of stepchildren in HH (age 30)"
label var	step_tot_34	"Number of stepchildren in HH (age 34)"
label var	step_tot_38	"Number of stepchildren in HH (age 38)"
label var	step_tot_42	"Number of stepchildren in HH (age 42)"
label var	step_tot_46	"Number of stepchildren in HH (age 46)"




label var	adopt_tot_51	"Number of adopted children in HH (age 51)"
label var	anybiochildren_51	"Whether has had any bio children (age 51)"
label var	anychildren_51	"Whether has any children (bio or non-bio) (age 51)"
label var	anynonbio_51	"Whether has any non-bio children in HH (age 51)"
label var	bcssurvey_51	"Whether took part in age 51 survey"
label var	bcsid	"research case identifier"
label var	biochild_tot_51	"Number of bio children (age 51)"
label var	biochildboy_total_51	"Number of bio children who are boys (age 51)"
label var	biochildgirl_total_51	"Number of bio children who are girls (age 51)"
label var	biochildhh_total_51	"Number of bio children in HH (age 51)"
label var	biochildnonhh_total_51	"Number of bio children not in HH (age 51)"
label var	biochildprev_total_51	"Number of bio children had with a previous partner (age 51)"
label var	biochildprevany_51	"Have had any bio children with a previous partner (age 51)"
label var	biochildy_eldest_51	"Age in years of eldest bio child (age 51)"
label var	biochildy_youngest_51	"Age in years of youngest bio child (age 51)"
label var	childboy_total_51	"Number of children who are boys (bio or non-bio) (age 51)"
label var	childgirl_total_51	"Number of children who are girls (bio or non-bio) (age 51)"
label var	children_tot_51	"Number of children (bio or non-bio) (age 51)"
label var	childy_eldest_51	"Age in years of eldest child (bio or non-bio) (age 51)"
label var	childy_youngest_51	"Age in years of youngest child (bio or non-bio) (age 51)"
label var	cmageybirth_eldest_51	"Age in years of CM at birth of eldest bio child (age 51)"
label var	cmageybirth_youngest_51	"Age in years of CM at birth of youngest bio child (age 51)"
label var	foster_tot_51	"Number of foster children in HH (age 51)"
label var	intmonth_51	"Interview month (age 51)"
label var	intyear_51	"Interview year (age 51)"
label var	marital_51	"Marital status (age 51)"
label var	nonbiochild_tot_51	"Number of non-bio children in HH (age 51)"
label var	nonbiochildboy_total_51	"Number of non-bio children who are boys (age 51)"
label var	nonbiochildgirl_total_51	"Number of non-bio children who are girls (age 51)"
label var	nonbiochildy_eldest_51	"Age in years of eldest non-bio child (age 51)"
label var	nonbiochildy_youngest_51	"Age in years of youngest non-bio child (age 51)"
label var	partner_51	"Whether has a partner in HH (age 51)"
label var	partnerchildany_51	"Whether has live-in partner/spouse and/or any bio or non-bio children (age 51)"
label var	partnerchildbio_51	"Whether has live-in partner/spouse and/or any bio children (age 51)"
label var	step_tot_51	"Number of step-children in HH (age 51)"




*-------------------------------------------------------------------------*

//keep variables
keep bcsid	sex	cmbyear	cmbmonth	bcssurvey_26	partner_26	marital_26	anybiochildren_26	biochild_tot_26	biochildhh_total_26	biochildnonhh_total_26	biochildprevany_26	biochildboy_total_26	biochildgirl_total_26	biochildy_eldest_26	biochildy_youngest_26	cmageybirth_eldest_26	cmageybirth_youngest_26	anynonbio_26	nonbiochild_tot_26	adopt_tot_26	foster_tot_26	step_tot_26	nonbiochildboy_total_26	nonbiochildgirl_total_26	nonbiochildy_eldest_26	nonbiochildy_youngest_26	anychildren_26	children_tot_26	childboy_total_26	childgirl_total_26	childy_eldest_26	childy_youngest_26	partnerchildbio_26	partnerchildany_26	bcssurvey_30	intyear_30	intmonth_30	partner_30	marital_30	anybiochildren_30	biochild_tot_30	biochildhh_total_30	biochild_extra_flag_30	biochildnonhh_total_30	biochildprev_total_30	biochildprevany_30	biochildy_eldest_30	biochildy_youngest_30	cmageybirth_eldest_30	cmageybirth_youngest_30	biochildboy_total_30	biochildgirl_total_30	anynonbio_30	nonbiochild_tot_30	adopt_tot_30	foster_tot_30	step_tot_30	nonbiochildy_eldest_30	nonbiochildy_youngest_30	nonbiochildboy_total_30	nonbiochildgirl_total_30	anychildren_30	children_tot_30	childy_eldest_30	childy_youngest_30	childboy_total_30	childgirl_total_30	partnerchildbio_30	partnerchildany_30	bcssurvey_34	intyear_34	intmonth_34	partner_34	marital_34	anybiochildren_34	biochild_tot_34	biochildhh_total_34	biochild_extra_flag_34	biochildnonhh_total_34	biochildprev_total_34	biochildprevany_34	biochildy_eldest_34	biochildy_youngest_34	cmageybirth_eldest_34	cmageybirth_youngest_34	biochildboy_total_34	biochildgirl_total_34	anynonbio_34	nonbiochild_tot_34	adopt_tot_34	foster_tot_34	step_tot_34	nonbiochildy_eldest_34	nonbiochildy_youngest_34	nonbiochildboy_total_34	nonbiochildgirl_total_34	anychildren_34	children_tot_34	childy_eldest_34	childy_youngest_34	childboy_total_34	childgirl_total_34	partnerchildbio_34	partnerchildany_34	bcssurvey_38	intyear_38	intmonth_38	partner_38	marital_38	anybiochildren_38	biochild_tot_38	biochildhh_total_38	biochild_extra_flag_38	biochildnonhh_total_38	biochildprev_total_38	biochildprevany_38	biochildy_eldest_38	biochildy_youngest_38	cmageybirth_eldest_38	cmageybirth_youngest_38	biochildboy_total_38	biochildgirl_total_38	anynonbio_38	nonbiochild_tot_38	adopt_tot_38	foster_tot_38	step_tot_38	nonbiochildy_eldest_38	nonbiochildy_youngest_38	nonbiochildboy_total_38	nonbiochildgirl_total_38	anychildren_38	children_tot_38	childy_eldest_38	childy_youngest_38	childboy_total_38	childgirl_total_38	partnerchildbio_38	partnerchildany_38	bcssurvey_42	intyear_42	intmonth_42	partner_42	marital_42	anybiochildren_42	biochild_tot_42	biochildhh_total_42	biochildnonhh_total_42	biochildprev_total_42	biochildprevany_42	biochildy_eldest_42	biochildy_youngest_42	cmageybirth_eldest_42	cmageybirth_youngest_42	biochildboy_total_42	biochildgirl_total_42	anynonbio_42	nonbiochild_tot_42	adopt_tot_42	foster_tot_42	step_tot_42	nonbiochildy_eldest_42	nonbiochildy_youngest_42	nonbiochildboy_total_42	nonbiochildgirl_total_42	anychildren_42	children_tot_42	childy_eldest_42	childy_youngest_42	childboy_total_42	childgirl_total_42	partnerchildbio_42	partnerchildany_42	bcssurvey_46	intyear_46	intmonth_46	partner_46	marital_46	anybiochildren_46	biochild_tot_46	biochildhh_total_46	biochildnonhh_total_46	biochildprev_total_46	biochildprevany_46	biochildy_eldest_46	biochildy_youngest_46	cmageybirth_eldest_46	cmageybirth_youngest_46	biochildboy_total_46	biochildgirl_total_46	anynonbio_46	nonbiochild_tot_46	adopt_tot_46	foster_tot_46	step_tot_46	nonbiochildy_eldest_46	nonbiochildy_youngest_46	nonbiochildboy_total_46	nonbiochildgirl_total_46	anychildren_46	children_tot_46	childy_eldest_46	childy_youngest_46	childboy_total_46	childgirl_total_46	partnerchildbio_46	partnerchildany_46 biototal_flag_26_30 biototal_flag_30_34 biototal_flag_34_38 biototal_flag_38_42 biototal_flag_42_46 ///
bcssurvey_51 bd11weight_main intyear_51 intmonth_51 partner_51 marital_51 anybiochildren_51 biochild_tot_51 biochildhh_total_51 biochildnonhh_total_51 biochildprev_total_51 biochildprevany_51 biochildy_eldest_51 biochildy_youngest_51 cmageybirth_eldest_51 cmageybirth_youngest_51 biochildboy_total_51 biochildgirl_total_51 anynonbio_51 nonbiochild_tot_51 adopt_tot_51 foster_tot_51 step_tot_51 nonbiochildy_eldest_51 nonbiochildy_youngest_51 nonbiochildboy_total_51 nonbiochildgirl_total_51 anychildren_51 children_tot_51 childy_eldest_51 childy_youngest_51 childboy_total_51 childgirl_total_51 partnerchildbio_51 partnerchildany_51 biototal_flag_46_51


order bcsid	sex	cmbyear	cmbmonth ///
bcssurvey_26	partner_26	marital_26	anybiochildren_26	biochild_tot_26	biochildhh_total_26	biochildnonhh_total_26	biochildprevany_26	biochildy_eldest_26	biochildy_youngest_26	cmageybirth_eldest_26	cmageybirth_youngest_26	biochildboy_total_26	biochildgirl_total_26	anynonbio_26	nonbiochild_tot_26	adopt_tot_26	foster_tot_26	step_tot_26	nonbiochildy_eldest_26	nonbiochildy_youngest_26	nonbiochildboy_total_26	nonbiochildgirl_total_26	anychildren_26	children_tot_26	childboy_total_26	childgirl_total_26	childy_eldest_26	childy_youngest_26	partnerchildbio_26	partnerchildany_26	///
bcssurvey_30	intyear_30	intmonth_30	partner_30	marital_30	anybiochildren_30	biochild_tot_30 biototal_flag_26_30	biochildhh_total_30	biochild_extra_flag_30	biochildnonhh_total_30	biochildprev_total_30	biochildprevany_30	biochildy_eldest_30	biochildy_youngest_30	cmageybirth_eldest_30	cmageybirth_youngest_30	biochildboy_total_30	biochildgirl_total_30	anynonbio_30	nonbiochild_tot_30	adopt_tot_30	foster_tot_30	step_tot_30	nonbiochildy_eldest_30	nonbiochildy_youngest_30	nonbiochildboy_total_30	nonbiochildgirl_total_30	anychildren_30	children_tot_30	childy_eldest_30	childy_youngest_30	childboy_total_30	childgirl_total_30	partnerchildbio_30	partnerchildany_30	///
bcssurvey_34	intyear_34	intmonth_34	partner_34	marital_34	anybiochildren_34	biochild_tot_34 biototal_flag_30_34	biochildhh_total_34	biochild_extra_flag_34	biochildnonhh_total_34	biochildprev_total_34	biochildprevany_34	biochildy_eldest_34	biochildy_youngest_34	cmageybirth_eldest_34	cmageybirth_youngest_34	biochildboy_total_34	biochildgirl_total_34	anynonbio_34	nonbiochild_tot_34	adopt_tot_34	foster_tot_34	step_tot_34	nonbiochildy_eldest_34	nonbiochildy_youngest_34	nonbiochildboy_total_34	nonbiochildgirl_total_34	anychildren_34	children_tot_34	childy_eldest_34	childy_youngest_34	childboy_total_34	childgirl_total_34	partnerchildbio_34	partnerchildany_34	///
bcssurvey_38	intyear_38	intmonth_38	partner_38	marital_38	anybiochildren_38	biochild_tot_38 biototal_flag_34_38	biochildhh_total_38	biochild_extra_flag_38	biochildnonhh_total_38	biochildprev_total_38	biochildprevany_38	biochildy_eldest_38	biochildy_youngest_38	cmageybirth_eldest_38	cmageybirth_youngest_38	biochildboy_total_38	biochildgirl_total_38	anynonbio_38	nonbiochild_tot_38	adopt_tot_38	foster_tot_38	step_tot_38	nonbiochildy_eldest_38	nonbiochildy_youngest_38	nonbiochildboy_total_38	nonbiochildgirl_total_38	anychildren_38	children_tot_38	childy_eldest_38	childy_youngest_38	childboy_total_38	childgirl_total_38	partnerchildbio_38	partnerchildany_38	///
bcssurvey_42	intyear_42	intmonth_42	partner_42	marital_42	anybiochildren_42	biochild_tot_42	biototal_flag_38_42 biochildhh_total_42	biochildnonhh_total_42	biochildprev_total_42	biochildprevany_42	biochildy_eldest_42	biochildy_youngest_42	cmageybirth_eldest_42	cmageybirth_youngest_42	biochildboy_total_42	biochildgirl_total_42	anynonbio_42	nonbiochild_tot_42	adopt_tot_42	foster_tot_42	step_tot_42	nonbiochildy_eldest_42	nonbiochildy_youngest_42	nonbiochildboy_total_42	nonbiochildgirl_total_42	anychildren_42	children_tot_42	childy_eldest_42	childy_youngest_42	childboy_total_42	childgirl_total_42	partnerchildbio_42	partnerchildany_42	///
bcssurvey_46	intyear_46	intmonth_46	partner_46	marital_46	anybiochildren_46	biochild_tot_46 biototal_flag_42_46	biochildhh_total_46	biochildnonhh_total_46	biochildprev_total_46	biochildprevany_46	biochildy_eldest_46	biochildy_youngest_46	cmageybirth_eldest_46	cmageybirth_youngest_46	biochildboy_total_46	biochildgirl_total_46	anynonbio_46	nonbiochild_tot_46	adopt_tot_46	foster_tot_46	step_tot_46	nonbiochildy_eldest_46	nonbiochildy_youngest_46	nonbiochildboy_total_46	nonbiochildgirl_total_46	anychildren_46	children_tot_46	childy_eldest_46	childy_youngest_46	childboy_total_46	childgirl_total_46	partnerchildbio_46	partnerchildany_46 ///
bcssurvey_51 bd11weight_main intyear_51 intmonth_51 partner_51 marital_51 anybiochildren_51 biochild_tot_51 biototal_flag_46_51 biochildhh_total_51 biochildnonhh_total_51 biochildprev_total_51 biochildprevany_51 biochildy_eldest_51 biochildy_youngest_51 cmageybirth_eldest_51 cmageybirth_youngest_51 biochildboy_total_51 biochildgirl_total_51 anynonbio_51 nonbiochild_tot_51 adopt_tot_51 foster_tot_51 step_tot_51 nonbiochildy_eldest_51 nonbiochildy_youngest_51 nonbiochildboy_total_51 nonbiochildgirl_total_51 anychildren_51 children_tot_51 childy_eldest_51 childy_youngest_51 childboy_total_51 childgirl_total_51 partnerchildbio_51 partnerchildany_51 
  
   
save "$derived\BCS_fertility_histories.dta", replace

