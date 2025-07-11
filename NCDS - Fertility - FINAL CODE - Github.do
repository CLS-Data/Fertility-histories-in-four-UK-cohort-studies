

global raw "[insert file path to folder with raw data]"
global derived "[insert file path to folder for derived data]"

clear all
set maxvar 30000
set more off



*****NCDS FERTILITY*****


**# Bookmark #1
**************************************************************************
**************************************************************************
******************* AGE 23 ***********************************************
**************************************************************************
**************************************************************************

//NCDS AGE 23 (1981, SWEEP 4)
use "$raw\ncds4", clear
//N=12,537
//NOTES: No data on who parent of children are, and no data on adopted children. Age of non-biological children is grouped into categories, so also age of any child is grouped. 

keep ncdsid dhhsize n5031 n4124 n4924 n4925 n4924 n4925 n4926 n4928 n4930 n4931 n4933 n4935 n4936 n4937 n4938 n4939 n4941 n4943 n4944 n4946 n4948 n4949 n4950 n4951 n4952 n4954 n4956 n4957 n4959 n4961 n4962 n4963 n4964 n4965 n4967 n4969 n4970 n4972 n4974 n4975 n4976 n4977 n5036 n5037 n5038 n5039 n5040 n5041 n5042 n5043 n5044 n5045 n5046 n5047 n5048 n5049 n5050 n5051 n5052 n5053 n5054 n5055 n5056 n5057 n5058 n5059 n5060 n5061 n5062 n5063 n5064 n5065 n5113 n5116
drop n4931 n4933 n4944 n4946 n4957 n4959 n4970 n4972

gen AGE23SURVEY=1
label var AGE23SURVEY "Whether took part in age 23 survey"



//INTERVIEW DATE (age 23)

//month (age 23)
fre n4124
clonevar intmonth = n4124
label var intmonth "Interview month (age 23)"
label define intmonth 1 "January" 2	"February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "	October" 11 "November" 12 "December" -100 "no participation in sweep" -99 "information not provided", replace
label values intmonth intmonth
fre intmonth


//year (age 23) (not available but we can work it out as all interviews took part from August 1981 to March 1982 according to documentation)
cap drop intyear
gen intyear=.
replace intyear=1981 if inrange(intmonth,7,12)
replace intyear=1982 if inrange(intmonth,1,2)
label var intyear "Interview year (age 23)"
label define intyear -100 "no participation in sweep" -99 "information not provided", replace
label values intyear intyear
fre intyear


//COHABITING PARTNER (age 23)
fre n5116 n5113
cap drop partner
gen partner=.
replace partner=1 if n5113==2|(n5113==1 & n5116==1)
replace partner=0 if (n5113==1 & n5116==2)|n5116==2|n5113==3|n5113==4|n5113==5 
label define partner 1 "Yes" 0 "No" -100 "no participation in sweep" -99 "information not provided", replace
label values partner partner
label var partner "Whether has a partner in HH (age 23)"
fre partner
//have checked this against household grid data and we get largely the same figure here (see towards end of code). So it looks like the question to single people on whether cohabiting was also asked to those divorced, separated and widwed. 


//MARITAL STATUS (age 23)
fre n5113
cap drop marital
gen marital=.
replace marital=3 if (n5113==1 & n5116==2)|n5113==3|n5113==4|n5113==5
replace marital=2 if (n5113==1 & n5116==1)
replace marital=1 if (n5113==2)
label define marital 3 "Single non-cohabiting" 2 "Single cohabiting with partner" 1 "Married" -100 "no participation in sweep" -99 "information not provided", replace
label values marital marital
label variable marital " Marital status (age 23)" 
fre marital



//HH GRID VARIABLES PREP (age 23)
//notes: room for 10 people. 1st person is not CM, so we need to adjust if matching up hh members longitudinally 

//relationship of CM to household member (2=natural child, 3=partner's child, 4=foster child). Note there is no category for adopted child in data.
fre n5036 n5039 n5042 n5045 n5048 n5051 n5054 n5057 n5060 n5063
rename (n5036 n5039 n5042 n5045 n5048 n5051 n5054 n5057 n5060 n5063) (hhrel1 hhrel2 hhrel3 hhrel4 hhrel5 hhrel6 hhrel7 hhrel8 hhrel9 hhrel10)

//sex of member
fre n5037 n5040 n5043 n5046 n5049 n5052 n5055 n5058 n5061 n5064
rename (n5037 n5040 n5043 n5046 n5049 n5052 n5055 n5058 n5061 n5064) (hhsex1 hhsex2 hhsex3 hhsex4 hhsex5 hhsex6 hhsex7 hhsex8 hhsex9 hhsex10)

//age of member (not in precise years but age categories so variable will be slightly different to other sweeps)
fre n5038 n5041 n5044 n5047 n5050 n5053 n5056 n5059 n5062 n5065
rename (n5038 n5041 n5044 n5047 n5050 n5053 n5056 n5059 n5062 n5065) (hhage1 hhage2 hhage3 hhage4 hhage5 hhage6 hhage7 hhage8 hhage9 hhage10)




*****************************************************************
*****BIOLOGICAL CHILDREN (age 23)********************************* 
*****************************************************************

//cohort members report on whether they have any children and how many, however we rely on additional data for each individual child to work out how many live birth they have had/fathered using information on whether child was stillborn. 

//note that there is space for first, second, third and fourth or last child, so if they have more children this will not be recorded. However, note that only four cms had had five children. 

//we use available data on sex of each child combined with whether stillborn to work out whether they have had any live children.
rename (n4930 n4943 n4956 n4969) (pregs1 pregs2 pregs3 pregs4) //sex: 1=boy 2=girl 8=don't know
rename (n4938 n4951 n4964 n4977) (biodieage1 biodieage2 biodieage3 biodieage4) //1=stillborn, 2-10=other 

foreach C in 1 2 3 4 {
cap drop biochild`C'
gen biochild`C'=.
replace biochild`C'=1 if inrange(pregs`C',1,8) & biodieage`C'!=1
}

***COMPUTE total number of biological children (age 23)
cap drop biochild_tot
egen biochild_tot =anycount(biochild1 biochild2 biochild3 biochild4), values(1)
replace biochild_tot=. if n4924==. //missing if not answered whether had any children
label define biochild_tot 0 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values biochild_tot biochild_tot
label variable biochild_tot "Number of bio children (age 23)"
replace biochild_tot=5 if n4925==5 //we replace with respondents answer if 5 children, although we don't know for certain thay they are not stillborn, the chance is low.
fre biochild_tot

cap drop biochild_tot_miss
gen biochild_tot_miss=1 if biochild_tot==. //this creates a missing values flag for this variable
fre biochild_tot_miss


***COMPUTE whether ever had any biological children (live births) (age 23)
cap drop anybiochildren
gen anybiochildren=.
replace anybiochildren=0 if biochild_tot==0
replace anybiochildren=1 if inrange(biochild_tot,1,5)
label variable anybiochildren "Whether has had any bio children (age 23)"
label define yesno 0 "No" 1 "Yes" -100 "no participation in sweep" -99 "information not provided", replace
label values anybiochildren yesno
fre anybiochildren



*----------------------------------------------------------------*

*** WHERE BIOLOGICAL CHILDREN LIVE (age 23)
//whether child lives with respondent (age 23)
fre n4936 n4949 n4962 n4975
rename (n4936 n4949 n4962 n4975) (biohh1 biohh2 biohh3 biohh4)
fre biohh1 biohh2 biohh3 biohh4
foreach C in 1 2 3 4 {
replace biohh`C'=. if biodieage`C'==1
}

***COMPUTE total number of biological children living in household (=1) (age 23)
cap drop biopreghh_total
egen biopreghh_total = anycount(biohh1 biohh2 biohh3 biohh4), values(1)
replace biopreghh_total=. if anybiochildren==.
replace biopreghh_total=-10 if anybiochildren==0
label variable biopreghh_total "Number of bio children in HH (child data) (age 23)"
fre biopreghh_total
label define biopreghh_total 0 "None of the biological children live in household" -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biopreghh_total biopreghh_total
fre biopreghh_total
rename biopreghh_total biochildhh_total


***COMPUTE total number of biological children not in household (=2) (age 23)
cap drop biochildnonhh_total
egen biochildnonhh_total = anycount(biohh1 biohh2 biohh3 biohh4), values(2)
replace biochildnonhh_total=. if anybiochildren==.
replace biochildnonhh_total=-10 if anybiochildren==0
label variable biochildnonhh_total "Number of bio children not in HH (age 23)"
fre biochildnonhh_total
label define biochildnonhh_total 0 "All biological children live in household" -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildnonhh_total biochildnonhh_total
fre biochildnonhh_total




*****************************************************************
*** SEX OF BIOLOGICAL CHILDREN (age 23)
*****************************************************************
//pregs: sex 1=boy 2=girl

***COMPUTE total number of biological boy and girl children (age 23)
cap drop biochildboy_total
egen biochildboy_total = anycount(pregs1 pregs2 pregs3 pregs4), values(1)
replace biochildboy_total=. if anybiochildren==.
replace biochildboy_total=-10 if anybiochildren==0 //no children
label define biochildboy_total 0 "Girls only" -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values biochildboy_total biochildboy_total
label var biochildboy_total "Number of bio children who are boys (age 23)"
fre biochildboy_total 

cap drop biochildgirl_total
egen biochildgirl_total = anycount(pregs1 pregs2 pregs3 pregs4), values(2)
replace biochildgirl_total=. if anybiochildren==.
replace biochildgirl_total=-10 if anybiochildren==0 //no children
label define biochildgirl_total 0 "Boys only" -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values biochildgirl_total biochildgirl_total
label var biochildgirl_total "Number of bio children who are girls (age 23)"
fre biochildgirl_total 




*************************************************************
*** AGES OF BIOLOGICAL CHILDREN AND COHORT MEMBER AGE AT BIRTH (age 23)
*************************************************************

***COMPUTE current age in whole years and whole months (respectively) of each biochild from birth year and month, and interview month and year. And age of cohort member at birth of child in whole years and in months as well.

//interview date (age 23)
fre intyear
fre intmonth
cap drop intym
gen intym = ym(intyear,intmonth)
label var intym "Interview date - months since Jan 1960"
fre intym

//cohort member birthdate (age 23)
cap drop cmbirthy
gen cmbirthy=1958
label var cmbirthy "Birth year of CM"
fre cmbirthy

cap drop cmbirthm
gen cmbirthm=3
label var cmbirthm "Birth month of CM"
fre cmbirthm

cap drop cmbirthym
gen cmbirthym = ym(cmbirthy,cmbirthm)
label var cmbirthym "CM birth date - months since Jan 1960"
fre cmbirthym

//CM age in years (age 23)
cap drop cmagey
gen cmagey=(intym-cmbirthym)/12
replace cmagey = floor(cmagey)
label var cmagey "CM age at interview"
fre cmagey



//month of birth of child (age 23)
fre n4926 n4939 n4952 n4965
rename (n4926 n4939 n4952 n4965) (biom1 biom2 biom3 biom4)
fre biom1 biom2 biom3 biom4

//year of birth of child (age 23)
fre n4928 n4941 n4954 n4967
rename (n4928 n4941 n4954 n4967) (bioy1 bioy2 bioy3 bioy4)
fre bioy1 bioy2 bioy3 bioy4 
 
foreach C in 1 2 3 4 {
fre biom`C'
fre bioy`C'
replace biom`C'=. if biom`C'==99|biom`C'==98
replace bioy`C'=. if bioy`C'==99|bioy`C'==98
replace bioy`C'=bioy`C'+ 1900
replace bioy`C'=. if biodieage`C'==1
replace biom`C'=. if biodieage`C'==1
}


foreach C in 1 2 3 4 {

cap drop biochildym`C'
gen biochildym`C' = ym(bioy`C',biom`C') 
label var biochildym`C' "`C' Date of birth of biological child - months since Jan 1960"
fre biochildym`C'

//child's age in whole years at interview (age 23)
cap drop biochildagey`C'
gen biochildagey`C' = (intym-biochildym`C')/12
fre biochildagey`C'
replace biochildagey`C' = floor(biochildagey`C')
label var biochildagey`C' "`C' Age in whole years of biological child"
fre biochildagey`C'

//cm age in whole years at birth of child (age 23)
cap drop cmageybirth`C'
gen cmageybirth`C' = (biochildym`C'-cmbirthym)/12
fre cmageybirth`C'
replace cmageybirth`C' = floor(cmageybirth`C')
label var cmageybirth`C' "`C' Age of CM in years at birth of biological child `C'"
fre cmageybirth`C'

}



*----------------------------------------------------------*

***COMPUTE age of eldest and youngest child in years (age 23)
cap drop biochildy_eldest //years
gen biochildy_eldest = max(biochildagey1, biochildagey2, biochildagey3, biochildagey4)
replace biochildy_eldest=-10 if anybiochildren==0
label define biochildy_eldest -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildy_eldest biochildy_eldest
label var biochildy_eldest "Age in years of eldest bio child (age 23)"
fre biochildy_eldest

cap drop biochildy_youngest //years
gen biochildy_youngest = min(biochildagey1, biochildagey2, biochildagey3, biochildagey4)
replace biochildy_youngest=-10 if anybiochildren==0
label define biochildy_eldest -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildy_youngest biochildy_eldest
label var biochildy_youngest "Age in years of youngest bio child (age 23)"
fre biochildy_youngest 




*----------------------------------------------------------*

***COMPUTE age of cohort member at birth of eldest and youngest child in years (age 23)
cap drop cmageybirth_eldest //years
gen cmageybirth_eldest = min(cmageybirth1, cmageybirth2, cmageybirth3, cmageybirth4)
replace cmageybirth_eldest=-10 if anybiochildren==0
label define cmageybirth_eldest -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values cmageybirth_eldest cmageybirth_eldest
label var cmageybirth_eldest "Age in years of CM at birth of eldest bio child (age 23)"
fre cmageybirth_eldest

cap drop cmageybirth_youngest //years
gen cmageybirth_youngest = max(cmageybirth1, cmageybirth2, cmageybirth3, cmageybirth4)
replace cmageybirth_youngest=-10 if anybiochildren==0
fre cmageybirth_youngest
label define cmageybirth_youngest -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values cmageybirth_youngest cmageybirth_youngest
label var cmageybirth_youngest "Age in years of CM at birth of youngest bio child (age 23)"
fre cmageybirth_youngest






*****************************************************************
*** NON BIOLOGICAL CHILDREN (age 23) *****************************
*****************************************************************
//derived from the household grid

//variable HH size provides information on those who have completed HH grid
fre dhhsize
replace dhhsize=. if dhhsize<1 //coding minus values to missing



*RECODE on non-biological children variables (age 23)
foreach C in 1 2 3 4 5 6 7 8 9 10 {

*non-biological and type (age 23)
cap drop nonbiochild`C'
gen nonbiochild`C'=.
replace nonbiochild`C'=1 if inrange(hhrel`C',3,4)
label define nonbiochild`C' 1 "Non-biological child", replace
label values nonbiochild`C' nonbiochild`C'
label var nonbiochild`C' "`C' is a non-biological"
fre nonbiochild`C'

cap drop step`C'
gen step`C'=.
replace step`C'=1 if hhrel`C'==3
label define step`C' 1 "Step child", replace
label values step`C' step`C'
label var step`C' "`C' is a stepchild"
fre step`C'

cap drop foster`C'
gen foster`C'=.
replace foster`C'=1 if hhrel`C'==4
label define foster`C' 1 "foster", replace
label values foster`C' foster`C'
label var foster`C' "`C' is foster"
fre foster`C'

*sex of nonbio children (age 23)
cap drop nonbiochildsex`C'
clonevar nonbiochildsex`C' = hhsex`C' if inrange(hhrel`C',3,4)
replace nonbiochildsex`C'=. if hhsex`C'==9
label var nonbiochildsex`C' "`C' Sex of non-biological child"
fre nonbiochildsex`C'

*age of nonbio children (age 23)
cap drop nonbiochildagey`C'
clonevar nonbiochildagey`C' = hhage`C' if inrange(hhrel`C',3,4) & hhage`C'<100 
replace nonbiochildagey`C'=. if hhage`C'==9
label var nonbiochildagey`C' "`C' Age in years of non-biological child"
fre nonbiochildagey`C'

}



***COMPUTE whether has any non-biologial children (age 23)
cap drop anynonbio
egen anynonbio= anycount(nonbiochild1 nonbiochild2 nonbiochild3 nonbiochild4 nonbiochild5 nonbiochild6 nonbiochild7 nonbiochild8 nonbiochild9 nonbiochild10), values(1)
replace anynonbio=1 if inrange(anynonbio,1,20)
replace anynonbio=. if dhhsize==. //code to missing if no data on whether lives alone or with others as indicates non-response on HH grid
label variable anynonbio "Whether has any non-bio children in HH (age 23)"
label define yesno 0 "No" 1 "Yes" -100 "no participation in sweep" -99 "information not provided", replace
label values anynonbio yesno
fre anynonbio


***COMPUTE total number of non-biologial children in household (age 23)
//number of all non-biological
cap drop nonbiochild_tot
egen nonbiochild_tot = anycount(nonbiochild1 nonbiochild2 nonbiochild3 nonbiochild4 nonbiochild5 nonbiochild6 nonbiochild7 nonbiochild8 nonbiochild9 nonbiochild10), values(1)
replace nonbiochild_tot=. if dhhsize==. //code to missing if no data on whether lives alone or with others as indicates non-response on HH grid
label define nonbiochild_tot 0 "No non-biological children in HH" -100 "no participation in sweep" -99 "information not provided", replace 
label values nonbiochild_tot nonbiochild_tot
label variable nonbiochild_tot "Number of non-bio children in HH (age 23)"
fre nonbiochild_tot

//number of foster (age 23)
cap drop foster_tot
egen foster_tot = anycount(foster1 foster2 foster3 foster4 foster5 foster6 foster7 foster8 foster9 foster10), values(1)
replace foster_tot=. if dhhsize==. //code to missing if no data on whether lives alone or with others as indicates non-response on HH grid
label define foster_tot 0 "No foster children in HH" -100 "no participation in sweep" -99 "information not provided", replace 
label values foster_tot foster_tot
label variable foster_tot "Number of foster children in HH (age 23)"
fre foster_tot

//number of stepchildren (age 23)
cap drop step_tot
egen step_tot = anycount(step2 step3 step4 step5 step6 step7 step8 step9 step10), values(1)
replace step_tot=. if dhhsize==. //code to missing if no data on whether lives alone or with others as indicates non-response on HH grid
label define step_tot 0 "No stepchildren in HH" -100 "no participation in sweep" -99 "information not provided", replace 
label values step_tot step_tot
label variable step_tot "Number of stepchildren in HH (age 23)"
fre step_tot




***COMPUTE age of youngest and oldest non-biological child (age 23)
//note that we only have age categories for non-biologial children
cap drop nonbiochildy_eldest //years
gen nonbiochildy_eldest = max(nonbiochildagey1, nonbiochildagey2, nonbiochildagey3, nonbiochildagey4, nonbiochildagey5, nonbiochildagey6, nonbiochildagey7, nonbiochildagey8, nonbiochildagey9, nonbiochildagey10)
replace nonbiochildy_eldest=-10 if anynonbio==0
replace nonbiochildy_eldest=. if anynonbio==.
label define nonbiochildy_eldest -10 "No non-biological children" 1 "0-4 years" 2 "5-10 years" 3 "11-16 years" 4 "17-21 years" -100 "no participation in sweep" -99 "information not provided", replace
label values nonbiochildy_eldest nonbiochildy_eldest
label var nonbiochildy_eldest "Age in years (categories) of eldest non-bio child (age 23)"
fre nonbiochildy_eldest


cap drop nonbiochildy_youngest //years
gen nonbiochildy_youngest = min(nonbiochildagey1, nonbiochildagey2, nonbiochildagey3, nonbiochildagey4, nonbiochildagey5, nonbiochildagey6, nonbiochildagey7, nonbiochildagey8, nonbiochildagey9, nonbiochildagey10)
replace nonbiochildy_youngest=-10 if anynonbio==0
replace nonbiochildy_youngest=. if anynonbio==.
label define nonbiochildy_eldest -10 "No non-biological children" 1 "0-4 years" 2 "5-10 years" 3 "11-16 years" 4 "17-21 years" -100 "no participation in sweep" -99 "information not provided", replace
label values nonbiochildy_youngest nonbiochildy_eldest
label var nonbiochildy_youngest "Age in years (categories) of youngest non-bio child (age 23)"
fre nonbiochildy_youngest 



***COMPUTE total number of non-biological boys and girls (age 23)
//nonbiochildsex: 1=boy 2=girl
cap drop nonbiochildboy_total
egen nonbiochildboy_total = anycount(nonbiochildsex1  nonbiochildsex2 nonbiochildsex3 nonbiochildsex4 nonbiochildsex5 nonbiochildsex6 nonbiochildsex7 nonbiochildsex8 nonbiochildsex9 nonbiochildsex10), values(1)
replace nonbiochildboy_total=-10 if anynonbio==0 //no non-biologial children
replace nonbiochildboy_total=. if anynonbio==.
label define nonbiochildboy_total 0 "Girls only" -10 "No non-biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values nonbiochildboy_total nonbiochildboy_total
label var nonbiochildboy_total "Number of non-bio children who are boys (age 23)"
fre nonbiochildboy_total 


cap drop nonbiochildgirl_total
egen nonbiochildgirl_total = anycount(nonbiochildsex1 nonbiochildsex2 nonbiochildsex3 nonbiochildsex4 nonbiochildsex5 nonbiochildsex6 nonbiochildsex7 nonbiochildsex8 nonbiochildsex9 nonbiochildsex10), values(2)
replace nonbiochildgirl_total=-10 if anynonbio==0 //no non-biologial children
replace nonbiochildgirl_total=. if anynonbio==.
label define nonbiochildgirl_total 0 "Boys only" -10 "No non-biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values nonbiochildgirl_total nonbiochildgirl_total
label var nonbiochildgirl_total "Number of non-bio children who are girls (age 23)"
fre nonbiochildgirl_total 




*************** BIOLOGICAL AND NON BIOLOGICAL CHILDREN  (age 23) *******************************

***COMPUTE whether has any biological or non-biological (age 23)
cap drop anychildren
gen anychildren=.
replace anychildren=1 if anynonbio==1|anybiochildren==1
replace anychildren=0 if anynonbio==0 & anybiochildren==0
label define anychildren 0 "No" 1 "Yes" -100 "no participation in sweep" -99 "information not provided", replace
label values anychildren anychildren
label var anychildren "Whether has any children (bio or non-bio) (age 23)"
fre anychildren 

***COMPUTE total number of biological and non-biological children (age 23)
cap drop children_tot
gen children_tot=biochild_tot + nonbiochild_tot
fre children_tot
label define children_tot 0 "No children (biological or non-biological)" -100 "no participation in sweep" -99 "information not provided", replace
label values children_tot children_tot
label var children_tot "Number of children (bio or non-bio) (age 23)"
fre children_tot



***Age of biological or non biologial children (age 23)
//because we only have age groupings for non-biological children we first age group biological children variable.

*RECODE of biological children variables
foreach C in 1 2 3 4 {
recode biochildagey`C' (0/4=1 "0-4 years") (5/10=2 "5-10 years") (11/16=3 "11-16 years") (17/21=4 "17-21 years"), gen(biochildageyg`C')
label define biochildageyg`C' 1 "0-4 years" 2 "5-10 years" 3 "11-16 years" 4 "17-21 years", replace
label values biochildageyg`C' biochildageyg`C'
}



***COMPUTE youngest and oldest biological or non-biological children (age 23)
cap drop childy_eldest //years
gen childy_eldest = max(biochildageyg1, biochildageyg2, biochildageyg3, biochildageyg4,nonbiochildagey1, nonbiochildagey2, nonbiochildagey3, nonbiochildagey4, nonbiochildagey5, nonbiochildagey6, nonbiochildagey7, nonbiochildagey8, nonbiochildagey9, nonbiochildagey10  )
replace childy_eldest=-10 if anybiochildren==0 & anynonbio==0
replace childy_eldest=. if anybiochildren==.|anynonbio==.
label define childy_eldest -10 "No children (biological or non-biological)" 1 "0-4 years" 2 "5-10 years" 3 "11-16 years" 4 "17-21 years" -100 "no participation in sweep" -99 "information not provided", replace
label values childy_eldest childy_eldest
label var childy_eldest "Age in years (categories) of eldest child (bio or non-bio) (age 23)"
fre childy_eldest

cap drop childy_youngest //years
gen childy_youngest = min(biochildageyg1, biochildageyg2, biochildageyg3, biochildageyg4,nonbiochildagey1, nonbiochildagey2, nonbiochildagey3, nonbiochildagey4, nonbiochildagey5, nonbiochildagey6, nonbiochildagey7, nonbiochildagey8, nonbiochildagey9, nonbiochildagey10  )
replace childy_youngest=-10 if anybiochildren==0 & anynonbio==0
replace childy_youngest=. if anybiochildren==.|anynonbio==.
label define childy_youngest -10 "No children (biological or non-biological)" 1 "0-4 years" 2 "5-10 years" 3 "11-16 years" 4 "17-21 years" -100 "no participation in sweep" -99 "information not provided", replace
label values childy_youngest childy_youngest
label var childy_youngest "Age in years (categories) of youngest child (bio or non-bio) (age 23)"
fre childy_youngest



***COMPUTE total number of male biological or non-biological children (age 23)
cap drop biochildboy_total_R
clonevar biochildboy_total_R = biochildboy_total 
replace biochildboy_total_R=0 if biochildboy_total==-10
fre biochildboy_total_R

cap drop nonbiochildboy_total_R
clonevar nonbiochildboy_total_R = nonbiochildboy_total 
replace nonbiochildboy_total_R=0 if nonbiochildboy_total ==-10
fre nonbiochildboy_total_R

cap drop childboy_total
gen childboy_total = biochildboy_total_R + nonbiochildboy_total_R
drop biochildboy_total_R nonbiochildboy_total_R
replace childboy_total=-10 if anybiochildren==0 & anynonbio==0  //no bio or non-bio children
label define childboy_total 0 "Girls only" -10 "No children (biological or non-biological)" -100 "no participation in sweep" -99 "information not provided", replace
label values childboy_total childboy_total
label var childboy_total "Number of children who are boys (bio or non-bio) (age 23)"
fre childboy_total 



***COMPUTE total number of female biological or non-biological children (age 23)
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
label var childgirl_total "Number of children who are girls (bio or non-bio) (age 23)"
fre childgirl_total





***********************************************************
***************** PARTNER AND CHILD COMBO (age 23) ******************
***********************************************************

//partner and biological children (age 23)
cap drop partnerchildbio
gen partnerchildbio=.
replace partnerchildbio=1 if anybiochildren==0 & partner==0 //no partner and no children
replace partnerchildbio=2 if anybiochildren==0 & partner==1 //partner but no children
replace partnerchildbio=3 if anybiochildren==1 & partner==0 //no partner but children
replace partnerchildbio=4 if anybiochildren==1 & partner==1 //partner and children
label define partnerchildbio 1 "No partner or children" 2 "Partner and no children" 3 "Children and no partner" 4 "Partner and children" -100 "no participation in sweep" -99 "information not provided", replace
label values partnerchildbio partnerchildbio
label var partnerchildbio "Whether has live-in partner/spouse and/or any bio children (age 23)"
fre partnerchildbio


//partner and any bio or nonbio children (age 23)
cap drop partnerchildany
gen partnerchildany=.
replace partnerchildany=1 if anychildren==0 & partner ==0 //no partner and no children
replace partnerchildany=2 if anychildren==0 & partner ==1 //partner but no children
replace partnerchildany=3 if anychildren==1 & partner ==0 //no partner but children
replace partnerchildany=4 if anychildren==1 & partner ==1 //partner and children
label define partnerchildany 1 "No partner or children" 2 "Partner and no children" 3 "Children and no partner" 4 "Partner and children" -100 "no participation in sweep" -99 "information not provided", replace
label values partnerchildany partnerchildany
label var partnerchildany "Whether has live-in partner/spouse and/or any bio or non-bio children (age 23)"
fre partnerchildany



*----------------------------------------------------*

//adding suffic 23
foreach var of varlist _all {	
rename `var' `var'_23		
if inlist("`var'", "skip_ncdsid") {				
}
}
rename ncdsid_23 ncdsid



save "$derived\NCDS_fertility_age23.dta", replace
use "$derived\NCDS_fertility_age23.dta", clear




**# Bookmark #1

**************************************************************************
**************************************************************************
******************* AGE 33 ***********************************************
**************************************************************************
**************************************************************************


****************************************************************************
//NCDS AGE 33 (1991, SWEEP 5)
use "$raw\ncds5cmi", clear
//N=11,469

//respondents are asked to report all their children ever

//data on individual children (we use this mainly as we have details of each child, incl twins and triplets), but link back to data for each pregnancy to work out who the other parent is. Household grid for non-biological children, and a few other variables are also used.

keep ncdsid n622_5 resp5cmi resp5cl n504738 n504740 n506515 n502013 n507113 n507114 n507116 n507118 n507120 n507121 n507123 n507125 n507126 n507128 n507130 n507132 n507134 n507136 n507137 n507139 n507141 n507142 n507144 n507146 n507148 n507150 n507152 n507153 n507155 n507157 n507158 n507160 n507162 n507164 n507166 n507168 n507169 n507171 n507173 n507174 n507176 n507214 n507216 n507218 n507220 n507221 n507223 n507225 n507226 n507228 n507230 n507232 n507234 n507236 n507237 n507239 n507241 n507242 n507244 n507246 n507248 n507250 n507252 n507253 n507255 n507257 n507258 n507260 n507262 n507264 n507266 n507268 n507269 n507271 n507273 n507274 n507276 n507314 n507316 n507318 n507320 n507321 n507323 n507325 n507326 n507328 n507330 n507332 n507334 n507336 n507337 n507339 n507341 n507342 n507344 n507346 n507348 n507350 n507352 n507353 n507355 n507357 n507358 n507360 n507362 n507364 n507366 n507368 n507369 n507371 n507373 n507374 n507376 ageych totchld alone child marchild n502015 n502026 n502037 n502048 n505115 n505126 n505137 n505148 n502215 n502223 n502231 n502239 n505315 n505323 n505331 n505339 n502617 n502623 n502629 n502635 n502641 n502647 n502653 n502659 n502665 n502618 n502624 n502630 n502636 n502642 n502648 n502654 n502660 n502666 n502620 n502626 n502632 n502638 n502644 n502650 n502656 n502662 n502668 


//child number: n502015 n502026 n502037 n502048 n505115 n505126 n505137 n505148
//other parent: n502215 n502223 n502231 n502239 n505315 n505323 n505331 n505339


//SURVEY PARTICIPATION (age 33)
gen NCDSAGE33SURVEY=1
label var NCDSAGE33SURVEY "Whether took part in age 33 survey"
fre NCDSAGE33SURVEY //N=11,469


//RESPONSE TO QUESTIONNAIRES (age 33)

//HH grid 
fre resp5cmi //1=yes, 0=no

//children data
fre resp5cl //1=yes, 0=no


//INTERVIEW DATE (age 33)
//survey year was 1991
cap drop intyear
gen intyear = 1991
label var intyear "Interview year (age 33)"
label define intyear -100 "no participation in sweep" -99 "information not provided", replace
label values intyear intyear
fre intyear

//month
//nearly 300 values are outside 1-12 range. To avoid too much missing data for calculation of age when had child, we use June as the months for all missing values. This is the most frequent interview date for those with valid values. 
fre n504740
cap drop intmonth
gen intmonth = n504740
replace intmonth=6 if n504740==0|n504740>12 //replacing with June for missing or invalid values.
label var intmonth "Interview month (age 30)"
label define intmonth 1 "January" 2	"February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "	October" 11 "November" 12 "December" -100 "no participation in sweep" -99 "information not provided", replace
label values intmonth intmonth
fre intmonth
drop n504740


//PARTHER IN HH (age 33)
fre alone
cap drop partner
recode alone (2=0 "No") (1=1 "Yes"), gen(partner)
label var partner "Whether has a partner in HH (age 33)"
fre partner
//note that this has been derived from the HH grid, as we have checked as we get the exact same figure (see end of code)


//MARITAL STATUS (age 33)
fre n506515
cap drop marital
gen marital=.
replace marital=1 if n506515==2|n506515==3 //married
replace marital=2 if (n506515==1|n506515==4|n506515==5|n506515==6) & partner==1 //single cohabiting
replace marital=3 if (n506515==1|n506515==4|n506515==5|n506515==6) & partner==0 //single non-cohabiting
label define marital 3 "Single non-cohabiting" 2 "Single cohabiting with partner" 1 "Married" -100 "no participation in sweep" -99 "information not provided", replace
label values marital marital
label variable marital "Marital status (age 33)" 
fre marital



//PREGNANCIES AND CHILDREN (age 33)
//notes: respondends are asked to report all children ever had/fathered. We use data just on live births, so stillborn etc are omitted.

//ever had/fathered any children (age 33)
fre n507113 //live children
fre n502013 //pregnancy
cap drop everpreg
gen everpreg=.
replace everpreg=0 if n502013==2
replace everpreg=1 if n502013==1
fre everpreg

//date of birth month
fre n507116 n507132 n507148 n507164 n507216 n507232 n507248 n507264 n507316
rename (n507116 n507132 n507148 n507164 n507216 n507232 n507248 n507264 n507316) (pregm1 pregm2 pregm3 pregm4 pregm5 pregm6 pregm7 pregm8 pregm9)
//code values 0 as missing

//year of birth
fre n507118 n507134 n507150 n507166 n507218 n507234 n507250 n507266 n507318
rename (n507118 n507134 n507150 n507166 n507218 n507234 n507250 n507266 n507318) (pregy1 pregy2 pregy3 pregy4 pregy5 pregy6 pregy7 pregy8 pregy9)
//code values 0 as missing, then add 1900 to each value as currently format is 1975=75 

//child sex (1=boy 2=girl 3=not sure)
fre n507120 n507136 n507152 n507168 n507220 n507236 n507252 n507268 n507320
rename (n507120 n507136 n507152 n507168 n507220 n507236 n507252 n507268 n507320) (pregs1 pregs2 pregs3 pregs4 pregs5 pregs6 pregs7 pregs8 pregs9)

//where child is now lives //1=with CM 2=elsewhere 3=stillborn, 4=died
fre n507125 n507141 n507157 n507173 n507225 n507241 n507257 n507273 n507325
rename (n507125 n507141 n507157 n507173 n507225 n507241 n507257 n507273 n507325) (preghh1 preghh2 preghh3 preghh4 preghh5 preghh6 preghh7 preghh8 preghh9)

//month child died (not sure we need this)
drop n507126 n507142 n507158 n507174 n507226 n507242 n507258 n507274 n507326

//year child died (not sure we need this)
drop n507128 n507144 n507160 n507176 n507228 n507244 n507260 n507276 n507328

//child number (we need these to link with who the other parent is)
fre n502015 n502026 n502037 n502048 n505115 n505126 n505137 n505148
rename (n502015 n502026 n502037 n502048 n505115 n505126 n505137 n505148) (pregnumA pregnumB pregnumC pregnumD pregnumE pregnumF pregnumG pregnumH)

//other parent present/last partner //1=yes 2=no
fre n502215 n502223 n502231 n502239 n505315 n505323 n505331 n505339
rename (n502215 n502223 n502231 n502239 n505315 n505323 n505331 n505339) (pregparA pregparB pregparC pregparD pregparE pregparF pregparG pregparH)



*-------------------------------------------------------------------*

*RECODE variables to missing if stillborn child and other adjustments (age 33)

foreach C in 1 2 3 4 5 6 7 8 9 {
cap drop biochild`C'
recode preghh`C' (1/4=1 "bio-child"), gen(biochild`C') 

cap drop prego`C'
gen prego`C'=.
replace prego`C'=1 if preghh`C'==1|preghh`C'==2|preghh`C'==4
}

foreach C in 1 2 3 4 5 6 7 8 9 {
foreach X of varlist pregm`C' pregy`C' pregs`C' preghh`C' {
replace	`X'=. if prego`C'==.
replace pregm`C'=. if pregm`C'==0
replace pregy`C'=. if pregy`C'==0
replace pregs`C'=. if pregs`C'==3

}
}

foreach C in 1 2 3 4 5 6 7 8 9 {
replace pregy`C'= pregy`C' + 1900
}


*----------------------------------------------------------*
//renaming hh grid variables (age 33)
//CM is member 1, so other folk start with 2

//sex (1=male, 2=female)
fre n502617 n502623 n502629 n502635 n502641 n502647 n502653 n502659 n502665
rename (n502617 n502623 n502629 n502635 n502641 n502647 n502653 n502659 n502665) (hhsex2 hhsex3 hhsex4 hhsex5 hhsex6 hhsex7 hhsex8 hhsex9 hhsex10)

//age (in whole years so none of that categorical nonsense as in last sweep)
fre n502618 n502624 n502630 n502636 n502642 n502648 n502654 n502660 n502666
rename (n502618 n502624 n502630 n502636 n502642 n502648 n502654 n502660 n502666) (hhage2 hhage3 hhage4 hhage5 hhage6 hhage7 hhage8 hhage9 hhage10)

//relationship to CM (3=own child, 4=adopted child, 5=foster chld, 6=step child)
fre n502620 n502626 n502632 n502638 n502644 n502650 n502656 n502662 n502668
rename (n502620 n502626 n502632 n502638 n502644 n502650 n502656 n502662 n502668) (hhrel2 hhrel3 hhrel4 hhrel5 hhrel6 hhrel7 hhrel8 hhrel9 hhrel10)





*************************************************************
*** WHETHER HAS HAD ANY BIOLOGICAL CHILDREN AND TOTAL NUMBER (age 33)
*************************************************************

***COMPUTE whether ever had any biological children (live births) (age 33)
cap drop anybiochildren
egen anybiochildren=anycount(prego1 prego2 prego3 prego4 prego5 prego6 prego7 prego8 prego9), values(1)
replace anybiochildren=1 if inrange(anybiochildren,1,20)
replace anybiochildren=. if everpreg==.
label variable anybiochildren "Whether has had any bio children (age 33)"
label define yesno 0 "No" 1 "Yes" -100 "no participation in sweep" -99 "information not provided", replace
label values anybiochildren yesno
fre anybiochildren

***COMPUTE total number of biological children (age 33)
cap drop biochild_tot
egen biochild_tot =anycount(prego1 prego2 prego3 prego4 prego5 prego6 prego7 prego8 prego9), values(1)
replace biochild_tot=. if everpreg==.
label define biochild_tot 0 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values biochild_tot biochild_tot
label variable biochild_tot "Number of bio children (age 33)"
fre biochild_tot

*-----------------------------------------------------------*
*** WHERE BIOLOGICAL CHILDREN LIVE (age 33)
//preghh: 1=living with CM 2=living elsewhere 4=died

***COMPUTE total number of biological children not in household (=2) (age 33)
cap drop biochildnonhh_total
egen biochildnonhh_total = anycount(preghh1 preghh2 preghh3 preghh4 preghh5 preghh6 preghh7 preghh8 preghh9), values(2)
replace biochildnonhh_total=. if everpreg==.
replace biochildnonhh_total=-10 if anybiochildren==0
label variable biochildnonhh_total "Number of bio children not in HH (age 33)"
fre biochildnonhh_total
label define biochildnonhh_total 0 "All biological children live in household" -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildnonhh_total biochildnonhh_total
fre biochildnonhh_total

clonevar biocpregnonhh_total = biochildnonhh_total //creating a variable for the original variable



***COMPUTE total number of biological children living in household (=1) (age 33)
cap drop biopreghh_total
egen biopreghh_total = anycount(preghh1 preghh2 preghh3 preghh4 preghh5 preghh6 preghh7 preghh8 preghh9), values(1)
replace biopreghh_total=. if everpreg==.
//replace biopreghh_total=-10 if anybiochildren==0
label variable biopreghh_total "Number of bio children in HH (child data) (age 33)"
//label define biopreghh_total 0 "None of the biological children live in household" -10 "No biological children", replace
label values biopreghh_total biopreghh_total
fre biopreghh_total





*-------------------------------------------------------*
*** CHECKING EXTRA BIOLOGICAL CHILDREN IN HOUSEHOLD NOT REPORTED AS PREGNANCY (age 33)
fre resp5cmi

*RECODE biological children variables from HH grid (age 33)
foreach C in 1 2 3 4 5 6 7 8 9 10 {

*Biological child in HH (HH grid)
cap drop biochildhh`C'
gen biochildhh`C'=.
replace biochildhh`C'=1 if hhrel`C'==3 & (hhage`C'<20|hhage`C'==.) //include children under 20 as likely to be a mistake if older
label define biochildhh`C' 1 "Biological child in HH (HH grid)", replace
label values biochildhh`C' biochildhh`C'
label var biochildhh`C' "`C' is biological in HH (HH grid)"
fre biochildhh`C'
}


***COMPUTE total number of biological children reported in hh grid (age 33)
cap drop biochildhh_total
egen biochildhh_total = anycount(biochildhh1 biochildhh2 biochildhh3 biochildhh4 biochildhh5 biochildhh6 biochildhh7 biochildhh8 biochildhh9 biochildhh10), values(1)
label variable biochildhh_total "Number of bio children in HH (HH grid data) (age 33)"
fre biochildhh_total
replace biochildhh_total=. if resp5cmi==0
label variable biochildhh_total "Total number of bio children in household (HH grid data)"
fre biochildhh_total


clonevar biohhgrid_total = biochildhh_total //creating a variable for the original hhgrid total number of bio children



//computing difference in pregnancy data and household data (age 33)

cap drop biochild_tot_miss
gen biochild_tot_miss=1 if biochild_tot==. //this creates a missing values flag for this variable

replace biochild_tot=0 if biochild_tot==. // this bit is important as crucial for the inclusion of all HH grid data in adjustments for extra children 

fre biochild_tot biochildhh_total
tab biochild_tot biochildhh_total, mi
cap drop difference
gen difference=biochild_tot - biochildhh_total
fre difference


//creating a variable that flags CMs with differences (age 33)
cap drop biochild_extra_flag
gen biochild_extra_flag=.
label var biochild_extra_flag "Flag: More bio children reported in HH grid than in pregnancy data"
replace biochild_extra_flag=1 if inrange(difference, -10,-1)
replace biochild_extra_flag=0 if inrange(difference, 0,20)
label define biochild_extra_flag 1 "Yes" 0 "No" -100 "no participation in sweep" -99 "information not provided", replace
label values biochild_extra_flag biochild_extra_flag
fre biochild_extra_flag  

//creating variable to use for adjustment of total children (age 33)
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


******ADJUSTING (age 33)
cap drop bioextra_miss
gen bioextra_miss=1 if bioextra==. //missing values flag 
fre bioextra_miss
replace bioextra=0 if bioextra==.

fre biochild_tot_miss //already created a missing flag for this

//TOTAL NUMBER OF CHILDREN (age 33)
fre biochild_tot bioextra
replace biochild_tot=biochild_tot + bioextra
replace biochild_tot=. if biochild_tot_miss== 1 
fre biochild_tot

//ANY BIO CHILDREN (age 33)
cap drop anybiochildren
gen anybiochildren=.
replace anybiochildren=1 if inrange(biochild_tot,1,20)
replace anybiochildren=0 if biochild_tot==0
label define yesno 0 "No" 1 "Yes" -100 "no participation in sweep" -99 "information not provided", replace
label values anybiochildren yesno
fre anybiochildren

//WHERE LIVE (age 33)
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
fre biochildhh_total

fre biopreghh_total //preg variable

cap drop biochildnonhh_total
gen biochildnonhh_total= biochild_tot-biochildhh_total 
replace biochildnonhh_total=-10 if anybiochildren==0
label variable biochildnonhh_total "Total number of bio children not in household"
fre biochildnonhh_total
label define biochildnonhh_total 0 "All biological children live in household" -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildnonhh_total biochildnonhh_total
fre biochildnonhh_total

fre biocpregnonhh_total  //preg variable

*coding values for previous variable (age 33)
replace biochildhh_total=-10 if anybiochildren==0
label define biochildhh_total -10 "No biological children" 0 "None of the biological children live in household" -100 "no participation in sweep" -99 "information not provided", replace
replace biochildhh_total=. if anybiochildren==.
label values biochildhh_total biochildhh_total



*************************************************************
*** OTHER PARENT OF BIOLOGICAL CHILDREN (age 33)
*************************************************************

foreach C in 1 2 3 4 5 6 7 8 9 {

cap drop parent`C'
gen parent`C'=.
replace parent`C'=1 if biochild`C'==1 & pregnumA==`C' & pregparA==1
replace parent`C'=2 if biochild`C'==1 & pregnumA==`C' & pregparA==2
replace parent`C'=1 if biochild`C'==1 & pregnumB==`C' & pregparB==1
replace parent`C'=2 if biochild`C'==1 & pregnumB==`C' & pregparB==2
replace parent`C'=1 if biochild`C'==1 & pregnumC==`C' & pregparC==1
replace parent`C'=2 if biochild`C'==1 & pregnumC==`C' & pregparC==2
replace parent`C'=1 if biochild`C'==1 & pregnumD==`C' & pregparD==1
replace parent`C'=2 if biochild`C'==1 & pregnumD==`C' & pregparD==2
replace parent`C'=1 if biochild`C'==1 & pregnumE==`C' & pregparE==1
replace parent`C'=2 if biochild`C'==1 & pregnumE==`C' & pregparE==2
replace parent`C'=1 if biochild`C'==1 & pregnumF==`C' & pregparF==1
replace parent`C'=2 if biochild`C'==1 & pregnumF==`C' & pregparF==2
replace parent`C'=1 if biochild`C'==1 & pregnumG==`C' & pregparG==1
replace parent`C'=2 if biochild`C'==1 & pregnumG==`C' & pregparG==2
replace parent`C'=1 if biochild`C'==1 & pregnumH==`C' & pregparH==1
replace parent`C'=2 if biochild`C'==1 & pregnumH==`C' & pregparH==2		
}


***COMPUTE number of biological children whose parent is previous partner (age 33)
cap drop biochildprev_total
egen biochildprev_total = anycount(parent1 parent2 parent3 parent4 parent5 parent6 parent7 parent8 parent9), values(2)
replace biochildprev_total=. if everpreg==.
replace biochildprev_total=-10 if anybiochildren==0 //no children
label define biochildprev_total 0 "Current partner is parent to all biological children" -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildprev_total biochildprev_total
label variable biochildprev_total "Number of bio children had with a previous partner (age 33)"
fre biochildprev_total

//whether a previous partner is parent to any children (age 33)
cap drop biochildprevany
gen biochildprevany=.
replace biochildprevany=1 if inrange(biochildprev_total,1,10)
replace biochildprevany=0 if biochildprev_total==0
replace biochildprevany=-10 if biochildprev_total==-10
label variable biochildprevany "Any children with a previous partner"
label define biochildprevany 1 "Previous partner(s) parent to all or some biologial children" 0 "Current partner is parent to all biological children" -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildprevany biochildprevany
fre biochildprevany




*************************************************************
*** SEX OF BIOLOGICAL CHILDREN (age 33)
*************************************************************

//PREGNANCY DATA

//sex 1=boy 2=girl

***COMPUTE total number of biological boy and girl children (age 33)
cap drop biochildboy_total
egen biochildboy_total = anycount(pregs1 pregs2 pregs3 pregs4 pregs5 pregs6 pregs7 pregs8 pregs9), values(1)
replace biochildboy_total=. if everpreg==.
replace biochildboy_total=-10 if anybiochildren==0 //no children
label define biochildboy_total 0 "Girls only" -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values biochildboy_total biochildboy_total
label var biochildboy_total "Number of bio children who are boys (age 33)"
fre biochildboy_total 

cap drop biochildgirl_total
egen biochildgirl_total = anycount(pregs1 pregs2 pregs3 pregs4 pregs5 pregs6 pregs7 pregs8 pregs9), values(2)
replace biochildgirl_total=. if everpreg==.
replace biochildgirl_total=-10 if anybiochildren==0 //no children
label define biochildgirl_total 0 "Boys only" -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values biochildgirl_total biochildgirl_total
label var biochildgirl_total "Number of bio children who are girls (age 33)"
fre biochildgirl_total 



*----------------------------------------------------------*
******ADJUSTING PREVIOUS VARIABLES ADDING THE EXTRA GIRLS AND BOYS IDENTIFIED IN HH GRID BUT NOT INCLUDED IN PREGNANCY DATA

foreach C in 2 3 4 5 6 7 8 9 10 {

*sex of biological hh children (age 33)
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


***COMPUTE total number of biological girls and boys reported in hh grid (age 33)
cap drop biochildhhboy_total
gen biochildhhboy_total=biochildhhboy2 +biochildhhboy3 +biochildhhboy4 +biochildhhboy5 +biochildhhboy6 +biochildhhboy7 +biochildhhboy8 +biochildhhboy9 +biochildhhboy10
replace biochildhhboy_total=.  if resp5cmi==0
label variable biochildhhboy_total "Total number of bio boys in household (HH grid data)"
fre biochildhhboy_total

cap drop biochildhhgirl_total
gen biochildhhgirl_total=biochildhhgirl2 +biochildhhgirl3 +biochildhhgirl4 +biochildhhgirl5 +biochildhhgirl6 +biochildhhgirl7 +biochildhhgirl8 +biochildhhgirl9 +biochildhhgirl10
replace biochildhhgirl_total=.  if resp5cmi==0
label variable biochildhhgirl_total "Total number of bio girls in household (HH grid data)"
fre biochildhhgirl_total



//computing difference in pregnancy data and household data

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

//creating a variable that flags CMs with differences
cap drop bioboy_extra_flag
gen bioboy_extra_flag=.
label var bioboy_extra_flag "Flag: More bio boys reported in HH grid than in pregnancy data"
replace bioboy_extra_flag=1 if inrange(diff_boy, -10,-1)
fre bioboy_extra_flag //applies to 65 

cap drop biogirl_extra_flag
gen biogirl_extra_flag=.
label var biogirl_extra_flag "Flag: More bio girls reported in HH grid than in pregnancy data"
replace biogirl_extra_flag=1 if inrange(diff_girl, -10,-1)
fre biogirl_extra_flag //applies to 71 
 

//creating variable to use for adjustment of total boys and girls
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


******ADJUSTING (age 33)

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


//TOTAL NUMBER OF BOYS AND GIRLS (age 33)
fre biochildboy_total bioextraboy
replace biochildboy_total=biochildboy_total + bioextraboy
replace biochildboy_total=. if biochildboy_tot_miss== 1 
replace biochildboy_total=-10 if biochild_tot==0
fre biochildboy_total

fre biochildgirl_total bioextragirl
replace biochildgirl_total=biochildgirl_total + bioextragirl
replace biochildgirl_total=. if biochildgirl_tot_miss== 1 
replace biochildgirl_total=-10 if biochild_tot==0
fre biochildgirl_total






***********************************************************
*** AGES OF BIOLOGICAL CHILDREN AND COHORT MEMBER AGE AT THEIR BIRTH (age 33)
*************************************************************
***COMPUTE current age in whole years and whole months (respectively) of each biochild from birth year and month, and interview month and year. And age of cohort member at birth of child in whole years and in months as well. (age 33)

//interview date (age 33)
fre intyear
fre intmonth
cap drop intym
gen intym = ym(intyear,intmonth)
label var intym "Interview date - months since Jan 1960"
fre intym

//cohort member birthdate (age 33)
cap drop cmbirthy
gen cmbirthy=1958
label var cmbirthy "Birth year of CM"
fre cmbirthy

cap drop cmbirthm
gen cmbirthm=3
label var cmbirthm "Birth month of CM"
fre cmbirthm

cap drop cmbirthym
gen cmbirthym = ym(cmbirthy,cmbirthm)
label var cmbirthym "CM birth date - months since Jan 1960"
fre cmbirthym

//CM age in years (age 33)
cap drop cmagey
gen cmagey=(intym-cmbirthym)/12
replace cmagey = floor(cmagey)
label var cmagey "CM age at interview"
fre cmagey



foreach C in 1 2 3 4 5 6 7 8 9 {

cap drop biochildym`C'
gen biochildym`C' = ym(pregy`C',pregm`C') 
label var biochildym`C' "`C' Date of birth of biological child - months since Jan 1960"
fre biochildym`C'

//child's age in whole years at interview (age 33)
cap drop biochildagey`C'
gen biochildagey`C' = (intym-biochildym`C')/12
fre biochildagey`C'
replace biochildagey`C' = floor(biochildagey`C')
label var biochildagey`C' "`C' Age in whole years of biological child"
fre biochildagey`C'

//cm age in whole years at birth of child (age 33)
cap drop cmageybirth`C'
gen cmageybirth`C' = (biochildym`C'-cmbirthym)/12
fre cmageybirth`C'
replace cmageybirth`C' = floor(cmageybirth`C')
label var cmageybirth`C' "`C' Age of CM in years at birth of biological child `C'"
fre cmageybirth`C'

}


*----------------------------------------------------------*
******VARIABLES FOR AGES OF EXTRA CHILDREN IDENTIFIED IN HH GRID BUT NOT INCLUDED IN PREGNANCY DATA

*ages of extra children in hh (age 33)
foreach C in 2 3 4 5 6 7 8 9 10 {
cap drop biohhage`C' //coded 0 or 1
gen biohhage`C'=.
replace biohhage`C'=hhage`C' if hhrel`C'==3 & biochild_extra_flag==1
label var biohhage`C' "`C' hh biological child age"
fre biohhage`C'
}


***COMPUTE age of eldest and youngest child in years (age 33)
cap drop biochildy_eldest //years
gen biochildy_eldest = max(biochildagey1, biochildagey2, biochildagey3, biochildagey4, biochildagey5, biochildagey6, biochildagey7, biochildagey8, biochildagey9, biohhage2,biohhage3,biohhage4,biohhage5,biohhage6,biohhage7,biohhage8,biohhage9,biohhage10)
replace biochildy_eldest=0 if biochildy_eldest<0 
replace biochildy_eldest=-10 if anybiochildren==0
replace biochildy_eldest=. if biochildy_eldest>30
replace biochildy_eldest=. if biochild_tot_miss==1
label define biochildy_eldest -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildy_eldest biochildy_eldest
label var biochildy_eldest "Age in years of eldest biological child (age 33)"
fre biochildy_eldest 

cap drop biochildy_youngest //years
gen biochildy_youngest = min(biochildagey1, biochildagey2, biochildagey3, biochildagey4, biochildagey5, biochildagey6, biochildagey7, biochildagey8, biochildagey9,biohhage2,biohhage3,biohhage4,biohhage5,biohhage6,biohhage7,biohhage8,biohhage9,biohhage10)
replace biochildy_youngest=0 if biochildy_youngest<0 
replace biochildy_youngest=-10 if anybiochildren==0
replace biochildy_youngest=. if biochildy_youngest>30 
replace biochildy_youngest=. if biochild_tot_miss==1
label define biochildy_eldest -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildy_youngest biochildy_eldest
label var biochildy_youngest "Age in years of youngest biological child (age 33)"
fre biochildy_youngest 



*----------------------------------------------------------*
******VARIABLES FOR AGES OF CM AT BIRTH OF EXTRA CHILDREN IDENTIFIED IN HH GRID BUT NOT INCLUDED IN PREGNANCY DATA (age 33)

*age of CM at birth of extra children in hh grid
foreach C in 2 3 4 5 6 7 8 9 10 {
cap drop cmagebirth_hhextra`C'
gen cmagebirth_hhextra`C'=cmagey-biohhage`C' if biochild_extra_flag==1 
fre cmagebirth_hhextra`C'
}


***COMPUTE age of cohort member at birth of eldest and youngest child in years (age 33)

cap drop cmageybirth_eldest //years
gen cmageybirth_eldest = min(cmageybirth1, cmageybirth2, cmageybirth3, cmageybirth4, cmageybirth5, cmageybirth6, cmageybirth7, cmageybirth8, cmageybirth9, cmagebirth_hhextra2,cmagebirth_hhextra3,cmagebirth_hhextra4,cmagebirth_hhextra5,cmagebirth_hhextra6,cmagebirth_hhextra7,cmagebirth_hhextra8,cmagebirth_hhextra9,cmagebirth_hhextra10)
replace cmageybirth_eldest=. if cmageybirth_eldest<0
replace cmageybirth_eldest=-10 if anybiochildren==0
replace cmageybirth_eldest=. if biochild_tot_miss==1
label define cmageybirth_eldest -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values cmageybirth_eldest cmageybirth_eldest
label var cmageybirth_eldest "CM age in years at birth of eldest biological child (age 33)"
fre cmageybirth_eldest

cap drop cmageybirth_youngest //years
gen cmageybirth_youngest = max(cmageybirth1, cmageybirth2, cmageybirth3, cmageybirth4, cmageybirth5, cmageybirth6, cmageybirth7, cmageybirth8, cmageybirth9, cmagebirth_hhextra2,cmagebirth_hhextra3,cmagebirth_hhextra4,cmagebirth_hhextra5,cmagebirth_hhextra6,cmagebirth_hhextra7,cmagebirth_hhextra8,cmagebirth_hhextra9,cmagebirth_hhextra10)
replace cmageybirth_youngest=. if cmageybirth_youngest<0
replace cmageybirth_youngest=-10 if anybiochildren==0
replace cmageybirth_youngest=. if biochild_tot_miss==1
fre cmageybirth_youngest
label define cmageybirth_youngest -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values cmageybirth_youngest cmageybirth_youngest
label var cmageybirth_youngest "CM age in years at birth of youngest biological child (age 33)"
fre cmageybirth_youngest



************************** NON BIOLOGICAL CHILDREN (age 33) *****************************
//derived from the household grid

*RECODE of non-biological children variables (age 33)
foreach C in 2 3 4 5 6 7 8 9 10 {

*non-biological and type (age 33)
cap drop nonbiochild`C'
gen nonbiochild`C'=.
replace nonbiochild`C'=1 if inrange(hhrel`C',4,6)
label define nonbiochild`C' 1 "Non-biological child", replace
label values nonbiochild`C' nonbiochild`C'
label var nonbiochild`C' "`C' is a non-biological"
fre nonbiochild`C'

cap drop step`C'
gen step`C'=.
replace step`C'=1 if hhrel`C'==6 & hhage`C'<40 
label define step`C' 1 "Step child", replace
label values step`C' step`C'
label var step`C' "`C' is a stepchild"
fre step`C'

cap drop adopt`C'
gen adopt`C'=.
replace adopt`C'=1 if hhrel`C'==4 & hhage`C'<40 
label define adopt`C' 1 "Adopted", replace
label values adopt`C' adopt`C'
label var adopt`C' "`C' is adopted"
fre adopt`C'

cap drop foster`C'
gen foster`C'=.
replace foster`C'=1 if hhrel`C'==5 & hhage`C'<40 
label define foster`C' 1 "foster", replace
label values foster`C' foster`C'
label var foster`C' "`C' is foster"
fre foster`C'

*age of nonbio children (age 33)
cap drop nonbiochildagey`C'
clonevar nonbiochildagey`C' = hhage`C' if inrange(hhrel`C',4,6) & hhage`C'<40 
label var nonbiochildagey`C' "`C' Age in years of non-biological child"
fre nonbiochildagey`C'

*sex of nonbio children (age 33)
cap drop nonbiochildsex`C'
clonevar nonbiochildsex`C' = hhsex`C' if inrange(hhrel`C',4,6) & hhage`C'<40 
label var nonbiochildsex`C' "`C' Sex of non-biological child"
fre nonbiochildsex`C'

}

***COMPUTE whether has any non-biologial children (age 33)
cap drop anynonbio
egen anynonbio= anycount(nonbiochild2 nonbiochild3 nonbiochild4 nonbiochild5 nonbiochild6 nonbiochild7 nonbiochild8 nonbiochild9 nonbiochild10), values(1)
replace anynonbio=1 if inrange(anynonbio,1,20)
replace anynonbio=. if resp5cmi==0 //code to . if missing HH grid
label variable anynonbio "Whether has any non-bio children in HH (age 33)"
label define yesno 0 "No" 1 "Yes" -100 "no participation in sweep" -99 "information not provided", replace
label values anynonbio yesno
fre anynonbio 

***COMPUTE total number of non-biologial children in household (age 33)
//number of all non-biological (age 33)
cap drop nonbiochild_tot
egen nonbiochild_tot = anycount(nonbiochild2 nonbiochild3 nonbiochild4 nonbiochild5 nonbiochild6 nonbiochild7 nonbiochild8 nonbiochild9 nonbiochild10), values(1)
replace nonbiochild_tot=. if resp5cmi==0 //code to . if missing HH grid
label define nonbiochild_tot 0 "No non-biological children in HH" -100 "no participation in sweep" -99 "information not provided", replace 
label values nonbiochild_tot nonbiochild_tot
label variable nonbiochild_tot "Number of non-bio children in HH (age 23)"
fre nonbiochild_tot

//number of adopted (age 33)
cap drop adopt_tot
egen adopt_tot = anycount(adopt2 adopt3 adopt4 adopt5 adopt6 adopt7 adopt8 adopt9 adopt10), values(1)
replace adopt_tot=. if resp5cmi==0 //code to . if missing HH grid
label define adopt_tot 0 "No adopted children in HH" -100 "no participation in sweep" -99 "information not provided", replace 
label values adopt_tot adopt_tot
label variable adopt_tot "Number of adopted children in HH (age 33)"
fre adopt_tot

//number of foster (age 33)
cap drop foster_tot
egen foster_tot = anycount(foster2 foster3 foster4 foster5 foster6 foster7 foster8 foster9 foster10), values(1)
replace foster_tot=. if resp5cmi==0 //code to . if missing HH grid
label define foster_tot 0 "No foster children in HH" -100 "no participation in sweep" -99 "information not provided", replace 
label values foster_tot foster_tot
label variable foster_tot "Number of foster children in HH (age 33)"
fre foster_tot

//number of stepchildren (age 33)
cap drop step_tot
egen step_tot = anycount(step2 step3 step4 step5 step6 step7 step8 step9 step10), values(1)
replace step_tot=. if resp5cmi==0 //code to . if missing HH grid
label define step_tot 0 "No stepchildren in HH" -100 "no participation in sweep" -99 "information not provided", replace 
label values step_tot step_tot
label variable step_tot "Number of stepchildren in HH (age 33)"
fre step_tot


***COMPUTE age of youngest and oldest non-biological child (age 33)
cap drop nonbiochildy_eldest //years
gen nonbiochildy_eldest = max(nonbiochildagey2, nonbiochildagey3, nonbiochildagey4, nonbiochildagey5, nonbiochildagey6, nonbiochildagey7, nonbiochildagey8, nonbiochildagey9, nonbiochildagey10)
replace nonbiochildy_eldest=-10 if anynonbio==0
replace nonbiochildy_eldest=. if resp5cmi==0 //code to . if missing HH grid
label define nonbiochildy_eldest_33 -10 "No non-biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values nonbiochildy_eldest nonbiochildy_eldest_33
label var nonbiochildy_eldest "Age in years of eldest non-bio child (age 33)"
fre nonbiochildy_eldest

cap drop nonbiochildy_youngest //years (age 33)
gen nonbiochildy_youngest = min(nonbiochildagey2, nonbiochildagey3, nonbiochildagey4, nonbiochildagey5, nonbiochildagey6, nonbiochildagey7, nonbiochildagey8, nonbiochildagey9, nonbiochildagey10)
replace nonbiochildy_youngest=-10 if anynonbio==0
replace nonbiochildy_youngest=. if resp5cmi==0 //code to . if missing HH grid
label define nonbiochildy_youngest -10 "No non-biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values nonbiochildy_youngest nonbiochildy_eldest_33
label var nonbiochildy_youngest "Age in years of youngest non-bio child (age 33)"
fre nonbiochildy_youngest 



***COMPUTE total number of non-biological boys and girls (age 33)
//nonbiochildsex: 1=boy 2=girl

cap drop nonbiochildboy_total
egen nonbiochildboy_total = anycount(nonbiochildsex2 nonbiochildsex3 nonbiochildsex4 nonbiochildsex5 nonbiochildsex6 nonbiochildsex7 nonbiochildsex8 nonbiochildsex9 nonbiochildsex10), values(1)
replace nonbiochildboy_total=-10 if anynonbio==0 //no non-biologial children
replace nonbiochildboy_total=. if resp5cmi==0 //code to . if missing HH grid
label define nonbiochildboy_total 0 "Girls only" -10 "No non-biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values nonbiochildboy_total nonbiochildboy_total
label var nonbiochildboy_total "Number of non-bio children who are boys (age 33)"
fre nonbiochildboy_total 

cap drop nonbiochildgirl_total
egen nonbiochildgirl_total = anycount(nonbiochildsex2 nonbiochildsex3 nonbiochildsex4 nonbiochildsex5 nonbiochildsex6 nonbiochildsex7 nonbiochildsex8 nonbiochildsex9 nonbiochildsex10), values(2)
replace nonbiochildgirl_total=-10 if anynonbio==0 //no non-biologial children
replace nonbiochildgirl_total=. if resp5cmi==0 //code to . if missing HH grid
label define nonbiochildgirl_total 0 "Boys only" -10 "No non-biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values nonbiochildgirl_total nonbiochildgirl_total
label var nonbiochildgirl_total "Number of non-bio children who are girls (age 33)"
fre nonbiochildgirl_total 







*************** BIOLOGICAL AND NON BIOLOGICAL CHILDREN (age 33) **************

***COMPUTE whether has any biological or non-biological (age 33)
cap drop anychildren
gen anychildren=.
replace anychildren=1 if anynonbio==1|anybiochildren==1
replace anychildren=0 if anynonbio==0 & anybiochildren==0
replace anychildren=. if anybiochildren==.|anynonbio==.
label define anychildren 0 "No" 1 "Yes" -100 "no participation in sweep" -99 "information not provided", replace
label values anychildren anychildren
label var anychildren "Whether has any children (bio or non-bio) (age 33)"
fre anychildren 

***COMPUTE total number of biological and non-biological children (age 33)
cap drop children_tot
gen children_tot=biochild_tot + nonbiochild_tot
fre children_tot
label define children_tot 0 "No children (biological or non-biological)" -100 "no participation in sweep" -99 "information not provided", replace
label values children_tot children_tot
label var children_tot "Number of children (bio or non-bio) (age 33)"
fre children_tot



***COMPUTE youngest and oldest biological or non-biological children (age 33)
cap drop childy_eldest //years
gen childy_eldest = max(biochildy_eldest, nonbiochildy_eldest)
replace childy_eldest=-10 if anybiochildren==0 & anynonbio==0
replace childy_eldest=. if anybiochildren==.|anynonbio==.
label define childy_eldest_33 -10 "No children (biological or non-biological)" -100 "no participation in sweep" -99 "information not provided", replace
label values childy_eldest childy_eldest_33
label var childy_eldest "Age in years of eldest child (bio or non-bio) (age 33)"
fre childy_eldest

cap drop childy_youngest //years
gen childy_youngest = min(biochildy_youngest, nonbiochildy_youngest)
replace childy_youngest=-10 if anybiochildren==0 & anynonbio==0
replace childy_youngest=. if anybiochildren==.|anynonbio==.
replace childy_youngest=. if childy_youngest==-1 //code -1 to missing as can't be a real age
label define childy_youngest_33 -10 "No children (biological or non-biological)" -100 "no participation in sweep" -99 "information not provided", replace
label values childy_youngest childy_youngest_33
label var childy_youngest "Age in years of youngest child (bio or non-bio) (age 33)"
fre childy_youngest



***COMPUTE total number of male biological or non-biological children (age 33)
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
label var childboy_total "Number of children who are boys (bio or non-bio) (age 33)"
fre childboy_total 


***COMPUTE total number of female biological or non-biological children (age 33)
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
label var childgirl_total "Number of children who are girls (bio or non-bio) (age 33)"
fre childgirl_total 





***************** PARTNER AND CHILD COMBO (age 33) ******************

//partner and biological children (age 33)
cap drop partnerchildbio
gen partnerchildbio=.
replace partnerchildbio=1 if anybiochildren==0 & partner==0 //no partner and no children
replace partnerchildbio=2 if anybiochildren==0 & partner==1 //partner but no children
replace partnerchildbio=3 if anybiochildren==1 & partner==0 //no partner but children
replace partnerchildbio=4 if anybiochildren==1 & partner==1 //partner and children
label define partnerchildbio 1 "No partner or children" 2 "Partner and no children" 3 "Children and no partner" 4 "Partner and children" -100 "no participation in sweep" -99 "information not provided", replace
label values partnerchildbio partnerchildbio
label var partnerchildbio "Whether has live-in partner/spouse and/or any bio children (age 33)"
fre partnerchildbio

//partner and any bio or nonbio children (age 33)
cap drop partnerchildany
gen partnerchildany=.
replace partnerchildany=1 if anychildren==0 & partner==0 //no partner and no children
replace partnerchildany=2 if anychildren==0 & partner==1 //partner but no children
replace partnerchildany=3 if anychildren==1 & partner==0 //no partner but children
replace partnerchildany=4 if anychildren==1 & partner==1 //partner and children
label define partnerchildany 1 "No partner or children" 2 "Partner and no children" 3 "Children and no partner" 4 "Partner and children" -100 "no participation in sweep" -99 "information not provided", replace
label values partnerchildany partnerchildany
label var partnerchildany "Whether has live-in partner/spouse and/or any bio or non-bio children (age 33)"
fre partnerchildany



*---------------------------------------------------*

*** CHECKING FROM HH GRID WHO HAS A PARTNER (age 33)
//1=spouse, 2=live-in partner

foreach C in 2 3 4 5 6 7 8 9 10 {

cap drop partnerhh`C'
gen partnerhh`C'=0
replace partnerhh`C'=1 if hhrel`C'==1|hhrel`C'==2
label define partnerhh`C' 1 "live-in partner", replace
label values partnerhh`C' partnerhh`C'
label var partnerhh`C' "`C' is a live-in partner"
fre partnerhh`C'
}

cap drop partnerhhcheck
gen partnerhhcheck=partnerhh2+partnerhh3+partnerhh4+partnerhh5+partnerhh6+partnerhh7+partnerhh8+partnerhh9+partnerhh10
replace partnerhhcheck=. if resp5cmi==0 //code to . if missing HH grid
replace partnerhhcheck=1 if partnerhhcheck>1 & partnerhhcheck!=.
fre partnerhhcheck
fre partner
//variable is perfectly consistent with already derived variable
drop partnerhhcheck

//OTHER RELEVANT VARIABLES DERIVED
fre ageych totchld alone child marchild


*----------------------------------------------------*


//adding suffic 33 to all variables
foreach var of varlist _all {	
rename `var' `var'_33		
if inlist("`var'", "skip_ncdsid") {				
}
}
rename ncdsid_33 ncdsid


save "$derived\NCDS_fertility_age33.dta", replace
use "$derived\NCDS_fertility_age33.dta", clear







**# Bookmark #3
**************************************************************************
**************************************************************************
******************* AGE 42 ***********************************************
**************************************************************************
**************************************************************************


//NCDS AGE 42 (2000, SWEEP 6)
use "$raw\ncds6", clear
//N=11,419

//NOTE: DATA IS SAME AS FOR BCS70 AGE 30, EVEN VARIABLE NAMES ARE THE SAME! Records all pregnancies since last interview. So children need to be added to when the last interview was to derive variables at age 42. We cannot derive who the other parent of the children is as we only have this info for the new children in relation to the current partner.

//keeping the variables used for derivation
keep ncdsid intdate dmsex marstat2 dmsppart othrela everpreg ///
///
prega prega2 prega3 prega4 prega5 prega6 prega7 prega8 prega11 prega12 prega16 prega17 prega21 prega22 prega26 prega31 prega36 ///
///
pregc pregc2 pregc3 pregc4 pregc5 pregc6 pregc7 pregc8 pregc11 pregc12 pregc16 pregc17 pregc21 pregc22 pregc26 pregc31 pregc36 ///
///
pregem pregem2 pregem3 pregem4 pregem5 pregem6 pregem7 pregem8 pregem11 pregem12 pregem16 pregem17 pregem21 pregem22 pregem26 pregem31 pregem36 ///
///
 pregey pregey2 pregey3 pregey4 pregey5 pregey6 pregey7 pregey8 pregey11 pregey12 pregey16 pregey17 pregey21 pregey22 pregey26 pregey31 pregey36 ///
 ///
prege prege2 prege3 prege4 prege5 prege6 prege7 prege8 prege11 prege12 prege16 prege17 prege21 prege22 prege26 prege31 prege36 ///
/// 
whopara whopara2 whopara3 whopara4 whopara5 whopara6 whopara7 whopara8 whopar12 whopar13 whopar14 whopar15 whopar22 whopar23 whopar24 whopar25 whopar32 whopar33 whopar34 whopar35 whopar42 whopar43 whopar52 whopar53 whopar62 whopar63 ///
/// 
 wherkid wherkid2 wherkid3 wherkid4 wherkid5 wherkid6 wherkid7 wherkid8 wherki11 wherki12 wherki16 wherki17 wherki21 wherki22 wherki26 wherki31 wherki36 ///
/// 
reltoke2 reltoke3 reltoke4 reltoke5 reltoke6 reltoke7 reltoke8 reltoke9 reltok10 ///
/// 
age2 age3 age4 age5 age6 age7 age8 age9 age10 ///
///
sex2 sex3 sex4 sex5 sex6 sex7 sex8 sex9 sex10 ///
///
numadch anychd chd16f chd13f chdage3 chdage4 chd5_16 chd16 chd0_6 ownchild hhsize

*--------------------------------------------------------*





*************************************************************
*** RECODING, RENAMING AND GENERATING VARIABLES FOR USE ***
*************************************************************
gen NCDSAGE42SURVEY=1
label var NCDSAGE42SURVEY "Whether took part in age 42 survey"


*interview date (age 42)
fre intdate

cap drop intyear
gen intyear = real(substr(intdate, -4, 4))
label var intyear "Interview year (age 42)"
label define intyear -100 "no participation in sweep" -99 "information not provided", replace
label values intyear intyear
fre intyear

cap drop intmonth
gen intmonth = real(substr(intdate, -6, 2))
label var intmonth "Interview month (age 42)"
label define intmonth 1 "January" 2	"February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "	October" 11 "November" 12 "December" -100 "no participation in sweep" -99 "information not provided", replace
label values intmonth intmonth
fre intmonth

//whether has a partner or spouse living in household (age 42)
fre dmsppart
recode dmsppart (2=0 "No") (1=1 "Yes"), gen(partner)
label var partner "Whether CM has current partner in hhld (age 42)"
fre partner
drop dmsppart

fre othrela

//marital status (age 42)
fre marstat2
cap drop marital
gen marital=.
replace marital=3 if marstat2==1|marstat2==4|marstat2==5|marstat2==6
replace marital=2 if (marstat2==1|marstat2==4|marstat2==5|marstat2==6) & partner==1
replace marital=1 if marstat2==2|marstat2==3
label define marital 3 "Single non-cohabiting" 2 "Single cohabiting with partner" 1 "Married" -100 "no participation in sweep" -99 "information not provided", replace
label values marital marital
label variable marital "Marital status (age 42)" 
fre marital




*--------------------------------------------------------*
//RENAMING PREGNANCY DATA VARIABLES (age 42)
describe prega prega2 prega3 prega4 prega5 prega6 prega7 prega8 prega11 prega12 prega16 prega17 prega21 prega22 prega26 prega31 prega36

describe pregc pregc2 pregc3 pregc4 pregc5 pregc6 pregc7 pregc8 pregc11 pregc12 pregc16 pregc17 pregc21 pregc22 pregc26 pregc31 pregc36

describe pregem pregem2 pregem3 pregem4 pregem5 pregem6 pregem7 pregem8 pregem11 pregem12 pregem16 pregem17 pregem21 pregem22 pregem26 pregem31 pregem36

describe pregey pregey2 pregey3 pregey4 pregey5 pregey6 pregey7 pregey8 pregey11 pregey12 pregey16 pregey17 pregey21 pregey22 pregey26 pregey31 pregey36

describe whopara whopara2 whopara3 whopara4 whopara5 whopara6 whopara7 whopara8 whopar12 whopar13 whopar14 whopar15 whopar22 whopar23 whopar24 whopar25 whopar32 whopar33 whopar34 whopar35 whopar42 whopar43 whopar52 whopar53 whopar62 whopar63

describe wherkid wherkid2 wherkid3 wherkid4 wherkid5 wherkid6 wherkid7 wherkid8 wherki11 wherki12 wherki16 wherki17 wherki21 wherki22 wherki26 wherki31 wherki36

foreach v of varlist pregey pregey2 pregey3 pregey4 pregey5 pregey6 pregey7 pregey8 pregey11 pregey12 pregey16 pregey17 pregey21 pregey22 pregey26 pregey31 pregey36  {
    display `"`v':"', `"`:var label `v''"'
}

foreach v of varlist whopara whopara2 whopara3 whopara4 whopara5 whopara6 whopara7 whopara8 whopar12 whopar13 whopar14 whopar15 whopar22 whopar23 whopar24 whopar25 whopar32 whopar33 whopar34 whopar35 whopar42 whopar43 whopar52 whopar53 whopar62 whopar63  {
    display `"`v':"', `"`:var label `v''"'
}

//whether partner is other parent is not coded using the child numbers as for the other variables, so we rename to match the suffix for the other variables for the right child. (age 42)
rename whopara	pregpar1
rename whopara2	pregpar2
rename whopara3	pregpar3
rename whopara4	pregpar4
rename whopara5	pregpar5
rename whopara6	pregpar6
rename whopara7	pregpar7
rename whopara8	pregpar8
rename whopar12	pregpar11
rename whopar14	pregpar12
rename whopar22	pregpar16
rename whopar24	pregpar17
rename whopar32	pregpar21
rename whopar34	pregpar22
rename whopar42	pregpar26
rename whopar52	pregpar31
rename whopar62	pregpar36


//RENAMING VARIABLES (age 42)
rename (prega prega2 prega3 prega4 prega5 prega6 prega7 prega8 prega11 prega12 prega16 prega17 prega21 prega22 prega26 prega31 prega36) (prego1 prego2 prego3 prego4 prego5 prego6 prego7 prego8 prego11 prego12 prego16 prego17 prego21 prego22 prego26 prego31 prego36)

rename (pregc pregc2 pregc3 pregc4 pregc5 pregc6 pregc7 pregc8 pregc11 pregc12 pregc16 pregc17 pregc21 pregc22 pregc26 pregc31 pregc36) (pregs1 pregs2 pregs3 pregs4 pregs5 pregs6 pregs7 pregs8 pregs11 pregs12 pregs16 pregs17 pregs21 pregs22 pregs26 pregs31 pregs36)

rename (pregem pregem2 pregem3 pregem4 pregem5 pregem6 pregem7 pregem8 pregem11 pregem12 pregem16 pregem17 pregem21 pregem22 pregem26 pregem31 pregem36) (pregm1 pregm2 pregm3 pregm4 pregm5 pregm6 pregm7 pregm8 pregm11 pregm12 pregm16 pregm17 pregm21 pregm22 pregm26 pregm31 pregm36)

rename (pregey pregey2 pregey3 pregey4 pregey5 pregey6 pregey7 pregey8 pregey11 pregey12 pregey16 pregey17 pregey21 pregey22 pregey26 pregey31 pregey36) (pregy1 pregy2 pregy3 pregy4 pregy5 pregy6 pregy7 pregy8 pregy11 pregy12 pregy16 pregy17 pregy21 pregy22 pregy26 pregy31 pregy36)

rename (prege prege2 prege3 prege4 prege5 prege6 prege7 prege8 prege11 prege12 prege16 prege17 prege21 prege22 prege26 prege31 prege36) (pregdmy1 pregdmy2 pregdmy3 pregdmy4 pregdmy5 pregdmy6 pregdmy7 pregdmy8 pregdmy11 pregdmy12 pregdmy16 pregdmy17 pregdmy21 pregdmy22 pregdmy26 pregdmy31 pregdmy36) 

//already renamed further above
//pregpar1 pregpar2 pregpar3 pregpar4 pregpar5 pregpar6 pregpar7 pregpar8 pregpar11 pregpar12 pregpar16 pregpar17 pregpar21 pregpar22 pregpar26 pregpar31 pregpar36 ///

rename (wherkid wherkid2 wherkid3 wherkid4 wherkid5 wherkid6 wherkid7 wherkid8 wherki11 wherki12 wherki16 wherki17 wherki21 wherki22 wherki26 wherki31 wherki36) (preghh1 preghh2 preghh3 preghh4 preghh5 preghh6 preghh7 preghh8 preghh11 preghh12 preghh16 preghh17 preghh21 preghh22 preghh26 preghh31 preghh36)



*--------------------------------------------------------*
**** HH GRID ****
//renaming variables (age 42)
rename (reltoke2 reltoke3 reltoke4 reltoke5 reltoke6 reltoke7 reltoke8 reltoke9 reltok10) (hhrel2 hhrel3 hhrel4 hhrel5 hhrel6 hhrel7 hhrel8 hhrel9 hhrel10)

rename (age2 age3 age4 age5 age6 age7 age8 age9 age10) (hhage2 hhage3 hhage4 hhage5 hhage6 hhage7 hhage8 hhage9 hhage10) ///

rename (sex2 sex3 sex4 sex5 sex6 sex7 sex8 sex9 sex10) (hhsex2 hhsex3 hhsex4 hhsex5 hhsex6 hhsex7 hhsex8 hhsex9 hhsex10)




*------------------------------------------------------------*

//pregnant since last interview (age 42)
fre everpreg
cap drop pregsincelast
gen pregsincelast=.
replace pregsincelast=1 if everpreg==1
replace pregsincelast=0 if everpreg==2
fre pregsincelast


*RECODE variables to missing if not a live birth (age 42)
foreach C in 1 2 3 4 5 6 7 8 11 12 16 17 21 22 26 31 36 {
foreach X of varlist pregs`C' pregm`C' pregy`C' pregpar`C' preghh`C' {

replace	`X'=. if prego`C'!=1

replace prego`C'=. if prego`C'!=1|pregsincelast==.
label define prego`C' 1 "Live birth", replace
label values prego`C' prego`C'
fre pregs`C' pregm`C' pregy`C' pregpar`C' preghh`C'

//recode to missing and other adjustments

replace	pregs`C'=. if pregs`C'==9|pregs`C'==.|pregsincelast==. //sex 1=boy 2=girl 9=not answered (so code to missing)

replace	pregm`C'=. if pregm`C'>12 //we keep missing as (.) data for month of birth

replace	pregy`C'=. if pregy`C'==9999 //we keep missing data as (.) for year of birth

replace	pregpar`C'=. if pregpar`C'==8|pregpar`C'==9|pregsincelast==. //other parent 1=current partner 2=not current partner 8=dont know, 9=not answered

replace	pregpar`C'=2 if partner==0 & othrela==2 & prego`C'==1 //recoding other parent to not current partner if there is no current partner in HH and no other non-resident partner

replace	preghh`C'=. if preghh`C'==8|preghh`C'==9|preghh`C'==.|pregsincelast==. //whether in household

fre prego`C' pregs`C' pregm`C' pregy`C' pregpar`C' preghh`C'

}
}


*---------------------------------------------------*
//ADDING SUFFIX 42 BEFORE MERGING WITH PREVIOUS SWEEP (age 42)
foreach var of varlist _all {	
rename `var' `var'_42		
if inlist("`var'", "skip_ncdsid") {				
}
}
rename ncdsid_42 ncdsid


*---------------------------------------------------*
//MERGING ON PREVIOUS SWEEP AS WE NEED TO ADD NEW CHILDREN TO PREVIOUS ONES

merge 1:1 ncdsid using "$derived\NCDS_fertility_age23.dta"
drop _merge

merge 1:1 ncdsid using "$derived\NCDS_fertility_age33.dta"
drop _merge



*-------------------------------------------------------------------*
***COMPUTE current age in whole years of each biochild from birth year and month, and interview month and year. And age of cohort member at birth of child in whole years.


//interview date (age 42)
fre intyear_42
fre intmonth_42
cap drop intym_42
gen intym_42 = ym(intyear_42,intmonth_42)
label var intym_42 "Interview date - months since Jan 1960"
fre intym_42

//cohort member birthdate (age 42)
cap drop cmbirthy_42
gen cmbirthy_42=1958
label var cmbirthy_42 "Birth year of CM"
fre cmbirthy_42

cap drop cmbirthm_42
gen cmbirthm_42=3
label var cmbirthm_42 "Birth month of CM"
fre cmbirthm_42

cap drop cmbirthym_42
gen cmbirthym_42 = ym(cmbirthy_42,cmbirthm_42)
label var cmbirthym_42 "CM birth date - months since Jan 1960"
fre cmbirthym_42

//CM age in years
cap drop cmagey_42
gen cmagey_42=(intym_42-cmbirthym_42)/12
replace cmagey_42 = floor(cmagey_42)
label var cmagey_42 "CM age at interview"
fre cmagey_42 




//new children at age 42 since last interview
foreach C in 1 2 3 4 5 6 7 8 11 12 16 17 21 22 26 31 36 {

cap drop biochildym`C'_42
gen biochildym`C'_42 = ym(pregy`C'_42,pregm`C'_42) 
label var biochildym`C'_42 "`C' Date of birth of biological child - months since Jan 1960"
fre biochildym`C'_42

//child's age in whole years at interview
cap drop biochildagey`C'_42
gen biochildagey`C'_42 = (intym_42-biochildym`C'_42)/12
fre biochildagey`C'_42
replace biochildagey`C'_42 = floor(biochildagey`C'_42)
label var biochildagey`C'_42 "`C' Age in whole years of biological child"
fre biochildagey`C'_42

//cm age in whole years at birth of child
cap drop cmageybirth`C'_42
gen cmageybirth`C'_42 = (biochildym`C'_42-cmbirthym_42)/12
fre cmageybirth`C'_42
replace cmageybirth`C'_42 = floor(cmageybirth`C'_42)
label var cmageybirth`C'_42 "`C' Age of CM in years at birth of biological child `C'"
fre cmageybirth`C'_42

}




*** ADJUSTING AGE OF PREVIOUSLY REPORTED CHILDREN TO DATE OF INTERVIEW (age 42)

*** AGE 23 CHILDREN: children reported previously at age 23 updated with their age at 42
foreach C in 1_23 2_23 3_23 4_23 {

//child's age in whole years at interview
cap drop biochildagey`C'
gen biochildagey`C' = (intym_42-biochildym`C')/12
fre biochildagey`C'
replace biochildagey`C' = floor(biochildagey`C')
label var biochildagey`C' "`C' Age in whole years of biological child"
fre biochildagey`C'
}

//***AGE 33 CHILDREN: children reported previously at age 33 updated with their age at 42
foreach C in 1 2 3 4 5 6 7 8 9 {

//child's age in whole years at age 42 interview
cap drop biochildagey`C'_33
gen biochildagey`C'_33 = (intym_42-biochildym`C'_33)/12
fre biochildagey`C'_33
replace biochildagey`C'_33 = floor(biochildagey`C'_33)
label var biochildagey`C'_33 "`C' Age in whole years of biological child"
fre biochildagey`C'_33
}




*************************************************************
*** WHETHER HAS HAD ANY BIOLOGICAL CHILDREN AND TOTAL NUMBER (age 42)
*************************************************************

//this is just temporary as these will be added to last interview (age 42)
cap drop anybiochildren_42
egen anybiochildren_42=anycount(prego1_42 prego2_42 prego3_42 prego4_42 prego5_42 prego6_42 prego7_42 prego8_42 prego11_42 prego12_42 prego16_42 prego17_42 prego21_42 prego22_42 prego26_42 prego31_42 prego36_42), values(1)
replace anybiochildren_42=1 if inrange(anybiochildren_42,1,20)
replace anybiochildren_42=. if pregsincelast_42==.
fre anybiochildren_42 


//Figuring out which data to add the new children to (age 42)
rename AGE23SURVEY_23 NCDSAGE23SURVEY_23

*since sweep 33
cap drop preg_33_42
gen preg_33_42=.
replace preg_33_42=1 if anybiochildren_33!=. & anybiochildren_42!=.
fre preg_33_42 //N=9669

cap drop sweep33_42
gen sweep33_42=.
replace sweep33_42=1 if NCDSAGE33SURVEY_33!=. & NCDSAGE42SURVEY_42!=.
fre sweep33_42 //N=9890


*since sweep 23
cap drop preg_23_42
gen preg_23_42=.
replace preg_23_42=1 if anybiochildren_23!=. & anybiochildren_33==. & anybiochildren_42!=.
fre preg_23_42 //N=1199

cap drop sweep23_42
gen sweep23_42=.
replace sweep23_42=1 if NCDSAGE23SURVEY_23!=. & NCDSAGE33SURVEY_33==. & NCDSAGE42SURVEY_42!=.
fre sweep23_42 //N=1042


*since sweep 16
cap drop preg_16_42
gen preg_16_42=.
replace preg_16_42=1 if anybiochildren_23==. &  anybiochildren_33==. & anybiochildren_42!=.
fre preg_16_42 //N=514

cap drop sweep16_42
gen sweep16_42=.
replace sweep16_42=1 if NCDSAGE23SURVEY_23==. & NCDSAGE33SURVEY_33==. & NCDSAGE42SURVEY_42!=.
fre sweep16_42 //N=487



***COMPUTE total number of biological children (age 42)
//since age 33
cap drop biochild_total_B
egen biochild_total_B =anycount(prego1_42 prego2_42 prego3_42 prego4_42 prego5_42 prego6_42 prego7_42 prego8_42 prego11_42 prego12_42 prego16_42 prego17_42 prego21_42 prego22_42 prego26_42 prego31_42 prego36_42), values(1)
replace biochild_total_B=. if sweep33_42==.|preg_33_42==. 
replace biochild_total_B= biochild_total_B + biochild_tot_33
fre biochild_total_B //N=9669

//since age 23
cap drop biochild_total_C
egen biochild_total_C =anycount(prego1_42 prego2_42 prego3_42 prego4_42 prego5_42 prego6_42 prego7_42 prego8_42 prego11_42 prego12_42 prego16_42 prego17_42 prego21_42 prego22_42 prego26_42 prego31_42 prego36_42), values(1)
replace biochild_total_C=. if sweep23_42==.|preg_23_42==. 
replace biochild_total_C= biochild_total_C + biochild_tot_23
fre biochild_total_C //N=1032

//since age 16
cap drop biochild_total_D
egen biochild_total_D =anycount(prego1_42 prego2_42 prego3_42 prego4_42 prego5_42 prego6_42 prego7_42 prego8_42 prego11_42 prego12_42 prego16_42 prego17_42 prego21_42 prego22_42 prego26_42 prego31_42 prego36_42), values(1)
replace biochild_total_D=. if sweep16_42==.|preg_16_42==. 
replace biochild_total_D= biochild_total_D
fre biochild_total_D //N=482


// COMPUTE age 42 total children 
fre biochild_total_B biochild_total_C biochild_total_D

cap drop included
gen included=.
replace included=1 if biochild_total_B!=.
replace included=1 if biochild_total_C!=.
replace included=1 if biochild_total_D!=.
fre included


cap drop biochild_tot_42
egen biochild_tot_42=rowtotal(biochild_total_D biochild_total_B biochild_total_C)
replace biochild_tot_42=. if included==.
fre biochild_tot_42
label define biochild_tot_42 0 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values biochild_tot_42 biochild_tot_42
label variable biochild_tot_42 "Total number of biological children"
fre biochild_tot_42




*-----------------------------------------------------*
*** CHECKING EXTRA BIOLOGICAL CHILDREN IN HOUSEHOLD NOT REPORTED AS PREGNANCY (age 42)

***COMPUTE total number of biological children reported in hh grid (age 42)

//we have to use HH grid data for this as pregnancy data will only include current location of the new children, whereas children reported in pregnancy data at age 33 will not have up to date information of where they live.

cap drop biochildhh_total_42
egen biochildhh_total_42 = anycount(hhrel2_42 hhrel3_42 hhrel4_42 hhrel5_42 hhrel6_42 hhrel7_42 hhrel8_42 hhrel9_42 hhrel10_42), values(3) //3=own child
replace biochildhh_total_42=. if (NCDSAGE42SURVEY_42==.| hhsize_42==.)
 //code to missing if not in age 42 sweep or didn't complete HH grid. We use HHsize derived variable to tell us this.
label variable biochildhh_total_42 "Total number of biological children in HH grid age 42"   
fre biochildhh_total_42

clonevar biohhgrid_total_42 = biochildhh_total_42 //creating a variable for the original hhgrid total number of bio children




//computing difference in pregnancy data and household data (age 42)

cap drop biochild_tot_miss_42
gen biochild_tot_miss_42=1 if biochild_tot_42==. //this creates a missing values flag for this variable

replace biochild_tot_42=0 if biochild_tot_42==. // this bit is important as crucial for the inclusion of all HH grid data in adjustments for extra children 

fre biochild_tot_42 biochildhh_total_42
tab biochild_tot_42 biochildhh_total_42, mi
cap drop difference_42
gen difference_42=biochild_tot_42 - biochildhh_total_42
fre difference_42


//creating a variable that flags CMs with differences (age 42)
cap drop biochild_extra_flag_42
gen biochild_extra_flag_42=.
label var biochild_extra_flag_42 "Flag: More bio children reported in HH grid than in pregnancy data"
replace biochild_extra_flag_42=1 if inrange(difference_42, -10,-1)
replace biochild_extra_flag_42=0 if inrange(difference_42, 0,20)
label define biochild_extra_flag_42 1 "Yes" 0 "No" -100 "no participation in sweep" -99 "information not provided", replace
label values biochild_extra_flag_42 biochild_extra_flag_42

fre biochild_extra_flag_42 //applies to 1177 CMs 

//creating variable to use for adjustment of total children (age 42)
cap drop bioextra_42
gen bioextra_42=difference_42
replace bioextra_42=0 if inrange(difference_42,0,10)
replace bioextra_42=1 if difference_42==-1
replace bioextra_42=2 if difference_42==-2
replace bioextra_42=3 if difference_42==-3
replace bioextra_42=4 if difference_42==-4
replace bioextra_42=5 if difference_42==-5
replace bioextra_42=6 if difference_42==-6
replace bioextra_42=7 if difference_42==-7
fre bioextra_42


******ADJUSTING  (age 42)
cap drop bioextra_miss_42
gen bioextra_miss_42=1 if bioextra_42==. //missing values flag 
fre bioextra_miss_42
replace bioextra_42=0 if bioextra_42==.

fre biochild_tot_miss_42 //already created a missing flag for this

//TOTAL NUMBER OF CHILDREN (age 42)
fre biochild_tot_42 bioextra_42
replace biochild_tot_42=biochild_tot_42 + bioextra_42
replace biochild_tot_42=. if biochild_tot_miss_42== 1 //& bioextra_miss_42==1
fre biochild_tot_42 

//ANY BIO CHILDREN (age 42)
cap drop anybiochildren_42
gen anybiochildren_42=.
replace anybiochildren_42=1 if inrange(biochild_tot_42,1,20)
replace anybiochildren_42=0 if biochild_tot_42==0
label define yesno 0 "No" 1 "Yes" -100 "no participation in sweep" -99 "information not provided", replace
label values anybiochildren_42 yesno
fre anybiochildren_42

//WHERE LIVE (age 42)

*in household (age 42)
fre biochildhh_total_42
label variable biochildhh_total_42 "Total number of bio children in household age 42"
fre biochildhh_total_42

*not in household (age 42)
fre biochild_tot_42 biochildhh_total_42 
cap drop biochildnonhh_total_42
gen biochildnonhh_total_42= biochild_tot_42-biochildhh_total_42 
replace biochildnonhh_total_42=-10 if anybiochildren_42==0
label variable biochildnonhh_total_42 "Total number of bio children not in household age 42"
fre biochildnonhh_total_42
label define biochildnonhh_total_42 0 "All biological children live in household" -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildnonhh_total_42 biochildnonhh_total_42
fre biochildnonhh_total_42 if NCDSAGE42SURVEY==1

*recoding and labelling biochildhh_total_42
replace biochildhh_total_42=-10 if anybiochildren_42==0
label define biochildhh_total_42 -10 "No biological children" 0 "None of the biological children live in household" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildhh_total_42 biochildhh_total_42
fre biochildhh_total_42 if NCDSAGE42SURVEY==1
replace biochildhh_total_42=. if anybiochildren_42==. & NCDSAGE42SURVEY==1



*******************************************************
*** OTHER PARENT OF CHILDREN IS CURRENT PARTNER (age 42)
*******************************************************
//we have this information on the new children. For the older children, reported at age 33, we don't have information on whether the other parent is the current partner. Therefore this variable cannot be derived. HOWEVER, WE MAY BE ABLE TO WORK THIS OUT FROM HH GRID (AGE 33 AND AGE 42 GRIDS) OF WHETHER OR NOT THERE HAS BEEN A CHANGE IN PARTNER. AND OF COURSE IF CM DOES NOT HAVE PARTNER IN HH THIS INFO SHOULD ALSO BE USED.  




****************************************************
*** SEX OF BIOLOGICAL CHILDREN (age 42)
****************************************************

//PREGNANCY DATA
//sex 1=boy 2=girl


cap drop Rbiochildboy_total_33
clonevar Rbiochildboy_total_33 = biochildboy_total_33
replace Rbiochildboy_total_33=0 if Rbiochildboy_total_33==-10

cap drop Rbiochildboy_total_23
clonevar Rbiochildboy_total_23 = biochildboy_total_23
replace Rbiochildboy_total_23=0 if Rbiochildboy_total_23==-10

*ADDING AGE 42 BOYS TO THE APPROPRIATE SWEEP

//since age 33
cap drop biochildboy_total_B
egen biochildboy_total_B =anycount(pregs1_42 pregs2_42 pregs3_42 pregs4_42 pregs5_42 pregs6_42 pregs7_42 pregs8_42 pregs11_42 pregs12_42 pregs16_42 pregs17_42 pregs21_42 pregs22_42 pregs26_42 pregs31_42 pregs36_42), values(1)
replace biochildboy_total_B=. if sweep33_42==.|preg_33_42==. 
replace biochildboy_total_B= biochildboy_total_B + Rbiochildboy_total_33
fre biochildboy_total_B //N=9669
//since age 23
cap drop biochildboy_total_C
egen biochildboy_total_C =anycount(pregs1_42 pregs2_42 pregs3_42 pregs4_42 pregs5_42 pregs6_42 pregs7_42 pregs8_42 pregs11_42 pregs12_42 pregs16_42 pregs17_42 pregs21_42 pregs22_42 pregs26_42 pregs31_42 pregs36_42), values(1)
replace biochildboy_total_C=. if sweep23_42==.|preg_23_42==. 
replace biochildboy_total_C= biochildboy_total_C + Rbiochildboy_total_23
fre biochildboy_total_C //N=1032
//since age 16
cap drop biochildboy_total_D
egen biochildboy_total_D =anycount(pregs1_42 pregs2_42 pregs3_42 pregs4_42 pregs5_42 pregs6_42 pregs7_42 pregs8_42 pregs11_42 pregs12_42 pregs16_42 pregs17_42 pregs21_42 pregs22_42 pregs26_42 pregs31_42 pregs36_42), values(1)
replace biochildboy_total_D=. if sweep16_42==.|preg_16_42==. 
replace biochildboy_total_D=biochildboy_total_D
fre biochildboy_total_D //N=482


// COMPUTE age 42 total boys
fre biochildboy_total_D biochildboy_total_B biochildboy_total_C

cap drop biochildboy_total_42
egen biochildboy_total_42=rowtotal(biochildboy_total_D biochildboy_total_B biochildboy_total_C)
replace biochildboy_total_42=. if included==.
//replace biochildboy_total_42=-10 if anybiochildren_42==0
label define biochildboy_total_42 0 "Girls only" -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values biochildboy_total_42 biochildboy_total_42
label variable biochildboy_total_42 "Total number of biological boys"
fre biochildboy_total_42 //N=11,183





*----------------------------------------------------------------*
***COMPUTE total number of biological GIRLS (age 42)

cap drop Rbiochildgirl_total_33
clonevar Rbiochildgirl_total_33 = biochildgirl_total_33
replace Rbiochildgirl_total_33=0 if Rbiochildgirl_total_33==-10

cap drop Rbiochildgirl_total_23
clonevar Rbiochildgirl_total_23 = biochildgirl_total_23
replace Rbiochildgirl_total_23=0 if Rbiochildgirl_total_23==-10

*ADDING AGE 42 girlS TO THE APPROPRIATE SWEEP

//since age 33
cap drop biochildgirl_total_B
egen biochildgirl_total_B =anycount(pregs1_42 pregs2_42 pregs3_42 pregs4_42 pregs5_42 pregs6_42 pregs7_42 pregs8_42 pregs11_42 pregs12_42 pregs16_42 pregs17_42 pregs21_42 pregs22_42 pregs26_42 pregs31_42 pregs36_42), values(2)
replace biochildgirl_total_B=. if sweep33_42==.|preg_33_42==. 
replace biochildgirl_total_B= biochildgirl_total_B + Rbiochildgirl_total_33
fre biochildgirl_total_B //N=9669
//since age 23
cap drop biochildgirl_total_C
egen biochildgirl_total_C =anycount(pregs1_42 pregs2_42 pregs3_42 pregs4_42 pregs5_42 pregs6_42 pregs7_42 pregs8_42 pregs11_42 pregs12_42 pregs16_42 pregs17_42 pregs21_42 pregs22_42 pregs26_42 pregs31_42 pregs36_42), values(2)
replace biochildgirl_total_C=. if sweep23_42==.|preg_23_42==. 
replace biochildgirl_total_C= biochildgirl_total_C + Rbiochildgirl_total_23
fre biochildgirl_total_C //N=1032
//since age 16
cap drop biochildgirl_total_D
egen biochildgirl_total_D =anycount(pregs1_42 pregs2_42 pregs3_42 pregs4_42 pregs5_42 pregs6_42 pregs7_42 pregs8_42 pregs11_42 pregs12_42 pregs16_42 pregs17_42 pregs21_42 pregs22_42 pregs26_42 pregs31_42 pregs36_42), values(2)
replace biochildgirl_total_D=. if sweep16_42==.|preg_16_42==. 
replace biochildgirl_total_D=biochildgirl_total_D
fre biochildgirl_total_D //N=482


// COMPUTE age 42 total girls
fre biochildgirl_total_D biochildgirl_total_B biochildgirl_total_C

cap drop biochildgirl_total_42
egen biochildgirl_total_42=rowtotal(biochildgirl_total_D biochildgirl_total_B biochildgirl_total_C)
replace biochildgirl_total_42=. if included==.
//replace biochildgirl_total_42=-10 if anybiochildren_42==0
label define biochildgirl_total_42 0 "Boys only" -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values biochildgirl_total_42 biochildgirl_total_42
label variable biochildgirl_total_42 "Total number of biological girls"
fre biochildgirl_total_42 //N=11,183



*** CHECKING EXTRA BOYS AND GIRLS IN HOUSEHOLD NOT REPORTED AS PREGNANCY (age 42)

foreach C in 2_42 3_42 4_42 5_42 6_42 7_42 8_42 9_42 10_42 {
*biological boys in hh grid
cap drop bioboyhh`C'
gen bioboyhh`C'=0
replace bioboyhh`C'=1 if hhrel`C'==3 & hhsex`C'==1
label define bioboyhh`C' 1 "biological boy", replace
label values bioboyhh`C' bioboyhh`C'
label var bioboyhh`C' "`C' is a hh biological boy"
fre bioboyhh`C'
}

foreach C in 2_42 3_42 4_42 5_42 6_42 7_42 8_42 9_42 10_42 {
*biological girls in hh grid
cap drop biogirlhh`C'
gen biogirlhh`C'=0
replace biogirlhh`C'=1 if hhrel`C'==3 & hhsex`C'==2
label define biogirlhh`C' 1 "biological girl", replace
label values biogirlhh`C' biogirlhh`C'
label var biogirlhh`C' "`C' is a hh biological girl"
fre biogirlhh`C'
}


***COMPUTE total number of biological boys and girls reported in hh grid (age 42)

//boys (age 42)
cap drop bioboyhh_total_42
gen bioboyhh_total_42=bioboyhh2_42+bioboyhh3_42+bioboyhh4_42+bioboyhh5_42+bioboyhh6_42+bioboyhh7_42+bioboyhh8_42+bioboyhh9_42+bioboyhh10_42
label variable bioboyhh_total_42 "Total number of bio boys in household (HH grid data)"
replace bioboyhh_total_42=. if hhsize_42==. //code to . if missing HH grid
fre bioboyhh_total_42

//girls (age 42)
cap drop biogirlhh_total_42
gen biogirlhh_total_42=biogirlhh2_42+biogirlhh3_42+biogirlhh4_42+biogirlhh5_42+biogirlhh6_42+biogirlhh7_42+biogirlhh8_42+biogirlhh9_42+biogirlhh10_42
label variable biogirlhh_total_42 "Total number of bio girls in household (HH grid data)"
replace biogirlhh_total_42=. if hhsize_42==. //code to . if missing HH grid
fre biogirlhh_total_42



//computing difference in pregnancy data and household data (age 42)

fre biochildboy_total_42 biochildgirl_total_42
fre bioboyhh_total_42 biogirlhh_total_42 

cap drop biochildboy_tot_miss_42
gen biochildboy_tot_miss_42=1 if biochildboy_total_42==. //this creates a missing values flag for this variable
cap drop biochildgirl_tot_miss_42
gen biochildgirl_tot_miss_42=1 if biochildgirl_total_42==. //this creates a missing values flag for this variable

replace biochildboy_total_42=0 if biochildboy_total_42==.|biochildboy_total_42==-10 // this bit is important as crucial for the inclusion of all HH grid data in adjustments for extra children 
replace biochildgirl_total_42=0 if biochildgirl_total_42==.|biochildgirl_total_42==-10 // this bit is important as crucial for the inclusion of all HH grid data in adjustments for extra children 


fre biochildboy_total_42
fre bioboyhh_total_42

fre biochildgirl_total_42
fre biogirlhh_total_42

cap drop diffboy_42
gen diffboy_42=biochildboy_total_42-bioboyhh_total_42
fre diffboy_42

cap drop diffgirl_42
gen diffgirl_42=biochildgirl_total_42-biogirlhh_total_42
fre diffgirl_42



//extra boys identified and to be added (age 42)
cap drop bioextraboy_42
gen bioextraboy_42=diffboy_42
replace bioextraboy_42=0 if inrange(diffboy_42,0,10)
replace bioextraboy_42=1 if diffboy_42==-1
replace bioextraboy_42=2 if diffboy_42==-2
replace bioextraboy_42=3 if diffboy_42==-3
replace bioextraboy_42=4 if diffboy_42==-4
replace bioextraboy_42=5 if diffboy_42==-5
replace bioextraboy_42=6 if diffboy_42==-6
fre bioextraboy_42

//extra girls identified and to be added (age 42)
cap drop bioextragirl_42
gen bioextragirl_42=diffgirl_42
replace bioextragirl_42=0 if inrange(diffgirl_42,0,10)
replace bioextragirl_42=1 if diffgirl_42==-1
replace bioextragirl_42=2 if diffgirl_42==-2
replace bioextragirl_42=3 if diffgirl_42==-3
replace bioextragirl_42=4 if diffgirl_42==-4
replace bioextragirl_42=5 if diffgirl_42==-5
replace bioextragirl_42=6 if diffgirl_42==-6
fre bioextragirl_42



******ADJUSTING (age 42)

//first doing some missing value flags
cap drop bioextraboy_miss_42
gen bioextraboy_miss_42=1 if bioextraboy_42==. //missing values flag 
fre bioextraboy_miss_42
replace bioextraboy_42=0 if bioextraboy_42==.

cap drop bioextragirl_miss_42
gen bioextragirl_miss_42=1 if bioextragirl_42==. //missing values flag 
fre bioextragirl_miss_42
replace bioextragirl_42=0 if bioextragirl_42==.


//TOTAL NUMBER OF BOYS AND GIRLS (age 42)

//boys (age 42)
fre biochildboy_total_42 bioextraboy_42
replace biochildboy_total_42=biochildboy_total_42+bioextraboy_42
replace biochildboy_total_42=. if biochildboy_tot_miss_42==1 
fre biochildboy_total_42

//girls (age 42)
fre biochildgirl_total_42
replace biochildgirl_total_42=biochildgirl_total_42+bioextragirl_42
replace biochildgirl_total_42=. if biochildgirl_tot_miss_42==1 
fre biochildgirl_total_42


//check that new total is similar to the variable => yes good match
cap drop total_new_42
gen total_new_42=biochildboy_total_42+biochildgirl_total_42
fre total_new_42
fre biochild_tot_42

//coding no children as -10
replace biochildboy_total_42=-10 if biochildboy_total_42==0 & biochildgirl_total_42==0
fre biochildboy_total_42

replace biochildgirl_total_42=-10 if biochildgirl_total_42==0 & biochildboy_total_42==0 | biochildboy_total_42==-10
fre biochildgirl_total_42





*********************************************************
*** AGES OF BIOLOGICAL CHILDREN (age 42)
*********************************************************

//1. we have already updated ages of pregnancy childrens ages previously.
fre biochildagey1_23 biochildagey2_23 biochildagey3_23 biochildagey4_23 

fre biochildagey1_33 biochildagey2_33 biochildagey3_33 biochildagey4_33 biochildagey5_33 biochildagey6_33 biochildagey7_33 biochildagey8_33 biochildagey9_33 

fre biochildagey1_42 biochildagey2_42 biochildagey3_42 biochildagey4_42 biochildagey5_42 biochildagey6_42 biochildagey7_42 biochildagey8_42 biochildagey11_42 biochildagey12_42 biochildagey16_42 biochildagey17_42 biochildagey21_42 biochildagey22_42 biochildagey26_42 biochildagey31_42 biochildagey36_42

 
//2. now update ages of extra HH grid children identified at 33 
 
// time in years since last interview at age 33 to be added to HH grid bio children's ages 
cap drop addtime
gen addtime=(intym_42-intym_33)/12
replace addtime=round(addtime, 1)
fre addtime 

foreach C in 2_33 3_33 4_33 5_33 6_33 7_33 8_33 9_33 10_33 {
cap drop Rbiohhage`C'
gen Rbiohhage`C'=.
replace Rbiohhage`C'=hhage`C' if hhrel`C'==3 & biochild_extra_flag_33==1
replace Rbiohhage`C'=(Rbiohhage`C' + addtime)
fre Rbiohhage`C'
} 
 

//3. identify additional children in HH grid at age 42
***COMPUTE age of eldest and youngest child in years from HH grid data at age 46 for CM's with a flag for having more children in HH grid than in preg data.
foreach C in 2_42 3_42 4_42 5_42 6_42 7_42 8_42 9_42 10_42 {
cap drop biohhage`C'
gen biohhage`C'=.
replace biohhage`C'=hhage`C' if hhrel`C'==3 & biochild_extra_flag_42==1
replace biohhage`C'=. if hhage`C'==999|hhage`C'==998
fre biohhage`C'
}



//THEN DO FINAL AGE OF CHILDREN MEASURE (age 42)
*--------------------------------------------------------------------*
*** COMPUTE age of eldest and youngest biological child (age 42)
cap drop biochildy_eldest_42 //years
gen biochildy_eldest_42 = max(biochildagey1_42, biochildagey2_42, biochildagey3_42, biochildagey4_42, biochildagey5_42, biochildagey6_42, biochildagey7_42, biochildagey8_42, biochildagey11_42, biochildagey12_42, biochildagey16_42, biochildagey17_42, biochildagey21_42, biochildagey22_42, biochildagey26_42, biochildagey31_42, biochildagey36_42, biochildagey1_33, biochildagey2_33, biochildagey3_33, biochildagey4_33, biochildagey5_33, biochildagey6_33, biochildagey7_33, biochildagey8_33, biochildagey9_33,biochildagey1_23, biochildagey2_23, biochildagey3_23, biochildagey4_23,biohhage2_42,biohhage3_42,biohhage4_42,biohhage5_42,biohhage6_42,biohhage7_42,biohhage8_42,biohhage9_42,biohhage10_42,Rbiohhage2_33,Rbiohhage3_33,Rbiohhage4_33,Rbiohhage5_33,Rbiohhage6_33,Rbiohhage7_33,Rbiohhage8_33,Rbiohhage9_33,Rbiohhage10_33)
replace biochildy_eldest_42=-10 if anybiochildren_42==0
replace biochildy_eldest_42=. if biochild_tot_miss_42==1
label define biochildy_eldest_42 -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildy_eldest_42 biochildy_eldest_42
label var biochildy_eldest_42 "Age in years of eldest biological child"
fre biochildy_eldest_42

cap drop biochildy_youngest_42 //years
gen biochildy_youngest_42 = min(biochildagey1_42, biochildagey2_42, biochildagey3_42, biochildagey4_42, biochildagey5_42, biochildagey6_42, biochildagey7_42, biochildagey8_42, biochildagey11_42, biochildagey12_42, biochildagey16_42, biochildagey17_42, biochildagey21_42, biochildagey22_42, biochildagey26_42, biochildagey31_42, biochildagey36_42, biochildagey1_33, biochildagey2_33, biochildagey3_33, biochildagey4_33, biochildagey5_33, biochildagey6_33, biochildagey7_33, biochildagey8_33, biochildagey9_33,biochildagey1_23, biochildagey2_23, biochildagey3_23, biochildagey4_23,biohhage2_42,biohhage3_42,biohhage4_42,biohhage5_42,biohhage6_42,biohhage7_42,biohhage8_42,biohhage9_42,biohhage10_42,Rbiohhage2_33,Rbiohhage3_33,Rbiohhage4_33,Rbiohhage5_33,Rbiohhage6_33,Rbiohhage7_33,Rbiohhage8_33,Rbiohhage9_33,Rbiohhage10_33)
replace biochildy_youngest_42=-10 if anybiochildren_42==0
replace biochildy_youngest_42=. if biochild_tot_miss_42==1
label define biochildy_youngest_42 -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildy_youngest_42 biochildy_youngest_42
label var biochildy_youngest_42 "Age in years of youngest biological child"
fre biochildy_youngest_42





*************************************************************
******** AGE OF COHORT MEMBER AGE AT BIRTH (age 42) *******
*************************************************************

//generating variables for the extra HH grid children at age 33 and 42 to include in final code below.  We subtract childs age from age 42 as childrens age at 33 has been adjusted to be their age at age 42 interview.
foreach C in 2_42 3_42 4_42 5_42 6_42 7_42 8_42 9_42 10_42 {
cap drop cmagebirth_hhextra`C'
gen cmagebirth_hhextra`C'=cmagey_42-biohhage`C' if biochild_extra_flag_42==1
fre cmagebirth_hhextra`C'
}

foreach C in 2_33 3_33 4_33 5_33 6_33 7_33 8_33 9_33 10_33 {
cap drop cmagebirth_hhextra`C'
gen cmagebirth_hhextra`C'=cmagey_42-Rbiohhage`C' if biochild_extra_flag_33==1
fre cmagebirth_hhextra`C'
}


***COMPUTE age of cohort member at birth of eldest and youngest child in years (age 42)
cap drop cmageybirth_eldest_42 //years
gen cmageybirth_eldest_42 = min(cmageybirth1_23, cmageybirth2_23, cmageybirth3_23, cmageybirth4_23,cmageybirth1_33,cmageybirth2_33,cmageybirth3_33,cmageybirth4_33,cmageybirth5_33,cmageybirth6_33,cmageybirth7_33,cmageybirth8_33,cmageybirth9_33,cmageybirth1_42,cmageybirth2_42,cmageybirth3_42,cmageybirth4_42,cmageybirth5_42,cmageybirth6_42,cmageybirth7_42,cmageybirth8_42,cmageybirth11_42,cmageybirth12_42,cmageybirth16_42,cmageybirth17_42,cmageybirth21_42,cmageybirth22_42,cmageybirth26_42,cmageybirth31_42,cmageybirth36_42,cmagebirth_hhextra2_42,cmagebirth_hhextra3_42,cmagebirth_hhextra4_42,cmagebirth_hhextra5_42,cmagebirth_hhextra6_42,cmagebirth_hhextra7_42,cmagebirth_hhextra8_42,cmagebirth_hhextra9_42,cmagebirth_hhextra10_42,cmagebirth_hhextra2_33,cmagebirth_hhextra3_33,cmagebirth_hhextra4_33,cmagebirth_hhextra5_33,cmagebirth_hhextra6_33,cmagebirth_hhextra7_33,cmagebirth_hhextra8_33,cmagebirth_hhextra9_33,cmagebirth_hhextra10_33)
replace cmageybirth_eldest_42=-10 if anybiochildren_42==0
replace cmageybirth_eldest_42=. if biochild_tot_miss_42==1
label define cmageybirth_eldest_42 -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values cmageybirth_eldest_42 cmageybirth_eldest_42
label var cmageybirth_eldest_42 "CM age in years at birth of eldest biological child"
fre cmageybirth_eldest_42

cap drop cmageybirth_youngest_42 //years
gen cmageybirth_youngest_42 = max(cmageybirth1_23, cmageybirth2_23, cmageybirth3_23, cmageybirth4_23,cmageybirth1_33,cmageybirth2_33,cmageybirth3_33,cmageybirth4_33,cmageybirth5_33,cmageybirth6_33,cmageybirth7_33,cmageybirth8_33,cmageybirth9_33,cmageybirth1_42,cmageybirth2_42,cmageybirth3_42,cmageybirth4_42,cmageybirth5_42,cmageybirth6_42,cmageybirth7_42,cmageybirth8_42,cmageybirth11_42,cmageybirth12_42,cmageybirth16_42,cmageybirth17_42,cmageybirth21_42,cmageybirth22_42,cmageybirth26_42,cmageybirth31_42,cmageybirth36_42,cmagebirth_hhextra2_42,cmagebirth_hhextra3_42,cmagebirth_hhextra4_42,cmagebirth_hhextra5_42,cmagebirth_hhextra6_42,cmagebirth_hhextra7_42,cmagebirth_hhextra8_42,cmagebirth_hhextra9_42,cmagebirth_hhextra10_42,cmagebirth_hhextra2_33,cmagebirth_hhextra3_33,cmagebirth_hhextra4_33,cmagebirth_hhextra5_33,cmagebirth_hhextra6_33,cmagebirth_hhextra7_33,cmagebirth_hhextra8_33,cmagebirth_hhextra9_33,cmagebirth_hhextra10_33)
replace cmageybirth_youngest_42=-10 if anybiochildren_42==0
replace cmageybirth_youngest_42=. if biochild_tot_miss_42==1
label define cmageybirth_youngest_42 -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values cmageybirth_youngest_42 cmageybirth_youngest_42
label var cmageybirth_youngest_42 "CM age in years at birth of youngest biological child"
fre cmageybirth_youngest_42





*************************************************************
*** NON BIOLOGICAL CHILDREN (age 42) ***
*************************************************************
fre hhrel2_42 hhrel3_42 hhrel4_42 hhrel5_42 hhrel6_42 hhrel7_42 hhrel8_42 hhrel9_42 hhrel10_42

*RECODE on non-biological children variables (age 42)
foreach C in 2_42 3_42 4_42 5_42 6_42 7_42 8_42 9_42 10_42 {

*non-biological and type (age 42)
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


*age of nonbio children (age 42)
cap drop nonbiochildagey`C'
clonevar nonbiochildagey`C' = hhage`C' if inrange(hhrel`C',4,7) & hhage`C'<100 
label var nonbiochildagey`C' "`C' Age in years of non-biological child"
fre nonbiochildagey`C'

*sex of nonbio children (age 42)
cap drop nonbiochildsex`C'
clonevar nonbiochildsex`C' = hhsex`C' if inrange(hhrel`C',4,7)
label var nonbiochildsex`C' "`C' Sex of non-biological child"
fre nonbiochildsex`C'

}



***COMPUTE whether has any non-biologial children in household (age 42)
cap drop anynonbio_42
egen anynonbio_42=anycount(nonbiochild2_42 nonbiochild3_42 nonbiochild4_42 nonbiochild5_42 nonbiochild6_42 nonbiochild7_42 nonbiochild8_42 nonbiochild9_42 nonbiochild10_42), values(1)
replace anynonbio_42=1 if inrange(anynonbio_42,1,20)
replace anynonbio_42=. if (hhsize_42==.)
label variable anynonbio_42 "Whether CM has any non-biological children in household"
label define yesno 0 "No" 1 "Yes" -100 "no participation in sweep" -99 "information not provided", replace
label values anynonbio_42 yesno
fre anynonbio_42 


***COMPUTE total number of non-biologial children in household (age 42)

//number of all non-biological (age 42)
cap drop nonbiochild_tot_42
egen nonbiochild_tot_42 = anycount(nonbiochild2_42 nonbiochild3_42 nonbiochild4_42 nonbiochild5_42 nonbiochild6_42 nonbiochild7_42 nonbiochild8_42 nonbiochild9_42 nonbiochild10_42), values(1)
replace nonbiochild_tot_42=. if (hhsize_42==.)
label define nonbiochild_tot_42 0 "No non-biological children in HH" -100 "no participation in sweep" -99 "information not provided", replace 
label values nonbiochild_tot_42 nonbiochild_tot_42
label variable nonbiochild_tot_42 "Total number of non-biological children in household"
fre nonbiochild_tot_42


//number of adopted (age 42)
cap drop adopt_tot_42
egen adopt_tot_42 = anycount(adopt2_42 adopt3_42 adopt4_42 adopt5_42 adopt6_42 adopt7_42 adopt8_42 adopt9_42 adopt10_42), values(1)
replace adopt_tot_42=. if (hhsize_42==.)
label define adopt_tot_42 0 "No adopted children in HH" -100 "no participation in sweep" -99 "information not provided", replace 
label values adopt_tot_42 adopt_tot_42
label variable adopt_tot_42 "Total number of adopted children in household"
fre adopt_tot_42

//number of foster (age 42)
cap drop foster_tot_42
egen foster_tot_42 = anycount(foster2_42 foster3_42 foster4_42 foster5_42 foster6_42 foster7_42 foster8_42 foster9_42 foster10_42), values(1)
replace foster_tot_42=. if (hhsize_42==.)
label define foster_tot_42 0 "No foster children in HH" -100 "no participation in sweep" -99 "information not provided", replace 
label values foster_tot_42 foster_tot_42
label variable foster_tot_42 "Total number of foster children in household"
fre foster_tot_42

//number of stepchildren (age 42)
cap drop step_tot_42
egen step_tot_42 = anycount(step2_42 step3_42 step4_42 step5_42 step6_42 step7_42 step8_42 step9_42 step10_42), values(1)
replace step_tot_42=. if (hhsize_42==.)
label define step_tot_42 0 "No stepchildren in HH" -100 "no participation in sweep" -99 "information not provided", replace 
label values step_tot_42 step_tot_42
label variable step_tot_42 "Total number of stepchildren in household"
fre step_tot_42



***COMPUTE age of youngest and oldest non-biological child (age 42)
cap drop nonbiochildy_eldest_42 //years
gen nonbiochildy_eldest_42 = max(nonbiochildagey2_42, nonbiochildagey3_42, nonbiochildagey4_42, nonbiochildagey5_42, nonbiochildagey6_42, nonbiochildagey7_42, nonbiochildagey8_42, nonbiochildagey9_42, nonbiochildagey10_42)
replace nonbiochildy_eldest_42=-10 if anynonbio_42==0
replace nonbiochildy_eldest_42=. if (hhsize_42==.)
label define nonbiochildy_eldest_42 -10 "No non-biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values nonbiochildy_eldest_42 nonbiochildy_eldest_42
label var nonbiochildy_eldest_42 "Age in years of youngest non-biological child"
fre nonbiochildy_eldest_42

cap drop nonbiochildy_youngest_42 //years
gen nonbiochildy_youngest_42 = min(nonbiochildagey2_42, nonbiochildagey3_42, nonbiochildagey4_42, nonbiochildagey5_42, nonbiochildagey6_42, nonbiochildagey7_42, nonbiochildagey8_42, nonbiochildagey9_42, nonbiochildagey10_42)
replace nonbiochildy_youngest_42=-10 if anynonbio_42==0
replace nonbiochildy_youngest_42=. if (hhsize_42==.)
label define nonbiochildy_youngest_42 -10 "No non-biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values nonbiochildy_youngest_42 nonbiochildy_youngest_42
label var nonbiochildy_youngest_42 "Age in years of youngest non-biological child"
fre nonbiochildy_youngest_42




***COMPUTE total number of non-biological boys and girls (age 42)
//nonbiochildsex: 1=boy 2=girl

cap drop nonbiochildboy_total_42
egen nonbiochildboy_total_42 = anycount(nonbiochildsex2_42 nonbiochildsex3_42 nonbiochildsex4_42 nonbiochildsex5_42 nonbiochildsex6_42 nonbiochildsex7_42 nonbiochildsex8_42 nonbiochildsex9_42 nonbiochildsex10_42), values(1)
replace nonbiochildboy_total_42=-10 if anynonbio_42==0 //no non-biologial children
replace nonbiochildboy_total_42=. if (hhsize_42==.)
label define nonbiochildboy_total_42 0 "Girls only" -10 "No non-biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values nonbiochildboy_total_42 nonbiochildboy_total_42
label var nonbiochildboy_total_42 "Total number of non-biological children who are boys"
fre nonbiochildboy_total_42 

cap drop nonbiochildgirl_total_42
egen nonbiochildgirl_total_42 = anycount(nonbiochildsex2_42 nonbiochildsex3_42 nonbiochildsex4_42 nonbiochildsex5_42 nonbiochildsex6_42 nonbiochildsex7_42 nonbiochildsex8_42 nonbiochildsex9_42 nonbiochildsex10_42), values(2)
replace nonbiochildgirl_total_42=-10 if anynonbio_42==0 //no non-biologial children
replace nonbiochildgirl_total_42=. if (hhsize_42==.)
label define nonbiochildgirl_total_42 0 "Boys only" -10 "No non-biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values nonbiochildgirl_total_42 nonbiochildgirl_total_42
label var nonbiochildgirl_total_42 "Total number of non-biological children who are girls"
fre nonbiochildgirl_total_42 






*************************************************************
**** BIOLOGICAL AND NON BIOLOGICAL CHILDREN (age 42) ****
*************************************************************

***COMPUTE whether has any biological or non-biological (age 42)
cap drop anychildren_42
gen anychildren_42=.
replace anychildren_42=1 if anynonbio_42==1|anybiochildren_42==1
replace anychildren_42=0 if anynonbio_42==0 & anybiochildren_42==0
replace anychildren_42=. if anybiochildren_42==.|anynonbio_42==.
label define anychildren_42 0 "No" 1 "Yes" -100 "no participation in sweep" -99 "information not provided", replace
label values anychildren_42 anychildren_42
label var anychildren_42 "Whether CM has any children (biological or non-biological)"
fre anychildren_42 
fre anychildren_33

***COMPUTE total number of biological and non-biological children (age 42)
cap drop children_tot_42
gen children_tot_42=biochild_tot_42 + nonbiochild_tot_42
replace children_tot_42=. if anybiochildren_42==.|anynonbio_42==.
fre children_tot_42
label define children_tot_42 0 "No children (biological or non-biological)" -100 "no participation in sweep" -99 "information not provided", replace
label values children_tot_42 children_tot_42
label var children_tot_42 "Total number of children (biological or non-biological)"
fre children_tot_42
fre children_tot_33



***COMPUTE youngest and oldest biological or non-biological children (age 42)
//create temporary recoded variables 
foreach X of varlist biochildy_eldest_42 nonbiochildy_eldest_42 biochildy_youngest_42 nonbiochildy_youngest_42 {
cap drop `X'_R
clonevar `X'_R = `X'
replace `X'_R=. if `X'_R==-10	
fre `X'_R
}

cap drop childy_eldest_42 //years
gen childy_eldest_42 = max(biochildy_eldest_42_R, nonbiochildy_eldest_42_R)
replace childy_eldest_42=-10 if anybiochildren_42==0 & anynonbio_42==0
replace childy_eldest_42=. if anybiochildren_42==.|anynonbio_42==.
label define childy_eldest_42 -10 "No children (biological or non-biological)" -100 "no participation in sweep" -99 "information not provided", replace
label values childy_eldest_42 childy_eldest_42
label var childy_eldest_42 "Age in years of eldest child (biological or non biological)"
fre childy_eldest_42

cap drop childy_youngest_42 //years
gen childy_youngest_42 = min(biochildy_youngest_42_R, nonbiochildy_youngest_42_R)
replace childy_youngest_42=-10 if anybiochildren_42==0 & anynonbio_42==0
replace childy_youngest_42=. if anybiochildren_42==.|anynonbio_42==.
label define childy_youngest_42 -10 "No children (biological or non-biological)" -100 "no participation in sweep" -99 "information not provided", replace
label values childy_youngest_42 childy_youngest_42
label var childy_youngest_42 "Age in years of youngest child (biological or non biological)"
fre childy_youngest_42

drop biochildy_eldest_42_R nonbiochildy_eldest_42_R biochildy_youngest_42_R nonbiochildy_youngest_42_R



***COMPUTE total number of male biological or non-biological children (age 42)
foreach X of varlist biochildboy_total_42 biochildgirl_total_42 nonbiochildboy_total_42 nonbiochildgirl_total_42 {
cap drop `X'_R
clonevar `X'_R = `X'
replace `X'_R=0 if `X'_R==-10	
}

fre biochildboy_total_42_R biochildgirl_total_42_R nonbiochildboy_total_42_R nonbiochildgirl_total_42_R

cap drop childboy_total_42
gen childboy_total_42 = biochildboy_total_42_R + nonbiochildboy_total_42_R
replace childboy_total_42=-10 if anybiochildren_42==0 & anynonbio_42==0  //no bio or non-bio children
replace childboy_total_42=. if anybiochildren_42==.|anynonbio_42==.  //no bio or non-bio children
label define childboy_total_42 0 "Girls only" -10 "No children (biological or non-biological)" -100 "no participation in sweep" -99 "information not provided", replace
drop biochildboy_total_42_R  nonbiochildboy_total_42_R
label values childboy_total_42 childboy_total_42
label var childboy_total_42 "Total number of children who are boys (biological or non-biological)"
fre childboy_total_42 


cap drop childgirl_total_42
gen childgirl_total_42 = biochildgirl_total_42_R + nonbiochildgirl_total_42_R
replace childgirl_total_42=-10 if anybiochildren_42==0 & anynonbio_42==0  //no bio or non-bio children
replace childgirl_total_42=. if anybiochildren_42==.|anynonbio_42==.  //no bio or non-bio children
label define childgirl_total_42 0 "Boys only" -10 "No children (biological or non-biological)" -100 "no participation in sweep" -99 "information not provided", replace
drop biochildgirl_total_42_R  nonbiochildgirl_total_42_R
label values childgirl_total_42 childgirl_total_42
label var childgirl_total_42 "Total number of children who are girls (biological or non-biological)"
fre childgirl_total_42 




*************************************************************
****COMPUTE partner child combo (age 42) ****
*************************************************************

//partner and biological children (age 42)
cap drop partnerchildbio_42
gen partnerchildbio_42=.
replace partnerchildbio_42=1 if anybiochildren_42==0 & partner_42==0 //no partner and no children
replace partnerchildbio_42=2 if anybiochildren_42==0 & partner_42==1 //partner but no children
replace partnerchildbio_42=3 if anybiochildren_42==1 & partner_42==0 //no partner but children
replace partnerchildbio_42=4 if anybiochildren_42==1 & partner_42==1 //partner and children
label define partnerchildbio_42 1 "No partner or children" 2 "Partner and no children" 3 "Children and no partner" 4 "Partner and children" -100 "no participation in sweep" -99 "information not provided", replace
label values partnerchildbio_42 partnerchildbio_42
label var partnerchildbio_42 "Whether has partner and/or any biological children"
fre partnerchildbio_42


//partner and any bio or nonbio children (age 42)
cap drop partnerchildany_42
gen partnerchildany_42=.
replace partnerchildany_42=1 if anychildren_42==0 & partner_42==0 //no partner and no children
replace partnerchildany_42=2 if anychildren_42==0 & partner_42==1 //partner but no children
replace partnerchildany_42=3 if anychildren_42==1 & partner_42==0 //no partner but children
replace partnerchildany_42=4 if anychildren_42==1 & partner_42==1 //partner and children
label define partnerchildany_42 1 "No partner or children" 2 "Partner and no children" 3 "Children and no partner" 4 "Partner and children" -100 "no participation in sweep" -99 "information not provided", replace
label values partnerchildany_42 partnerchildany_42
label var partnerchildany_42 "Whether has partner and/or any biological or non biological children"
fre partnerchildany_42

*************************************************************


save "$derived\NCDS_fertility_age23_42.dta", replace 
use "$derived\NCDS_fertility_age23_42.dta", clear







**# Bookmark #4
**************************************************************************
**************************************************************************
******************* AGE 46 ***********************************************
**************************************************************************
**************************************************************************


****************************************************************************
//NCDS AGE 46 (2004, SWEEP 7)
use "$raw\ncds7", clear
//N=9,534
//asks about pregnancies since last interview, so need to add them to what we already know from previous sweeps. We cannot derive who the other parent of the children is as we only have this info for the new children in relation to the current partner.

keep ncdsid n7dlasnt n7intmon n7intyr nd7hgdn nd7sex nd7ms n7othrea nd7spphh n7everpg n7pregn1 n7pregn2 n7pregn3 n7pregn4 n7pregn5 n7pregn6 n71pga11 n71pga12 n71pga13 n71pga21 n71pga22 n71pga31 n71pga32 n71pga41 n71pga51 n71pga61 n7livh11 n7livh12 n7livh13 n7livh21 n7livh22 n7livh31 n7livh41 n7livh51 n7livh61 n7lhhn11 n7lhhn12 n7lhhn13 n7lhhn21 n7lhhn22 n7lhhn31 n7lhhn41 n7lhhn51 n7lhhn61 n7prgc11 n7prgc12 n7prgc13 n7prgc21 n7prgc22 n7prgc31 n7prgc41 n7prgc51 n7prgc61 n7prgm11 n7prgm12 n7prgm13 n7prgm21 n7prgm22 n7prgm31 n7prgm41 n7prgm51 n7prgm61 n7prgy11 n7prgy12 n7prgy13 n7prgy21 n7prgy22 n7prgy31 n7prgy41 n7prgy51 n7prgy61 n7wprb11 n7wprb12 n7wprb13 n7wprb21 n7wprb22 n7wprb31 n7wprb41 n7wprb51 n7wprb61 n7abka11 n7abka12 n7abka13 n7abka21 n7abka22 n7abka31 n7abka41 n7abka51 n7abka61 n7sex12 n7sex13 n7sex14 n7sex15 n7sex16 n7sex17 n7sex18 n7sex19 n7sex20 n7rage11 n7rage12 n7rage13 n7rage14 n7rage15 n7rage16 n7rage17 n7rage18 n7rage19 n7rage20 n7pmth2 n7pmth3 n7pmth4 n7pmth5 n7pmth6 n7pmth7 n7pmth8 n7pmth9 n7pmth10 n7chdid2 n7chdid3 n7chdid4 n7chdid5 n7chdid6 n7chdid7 n7chdid8 n7chdid9 n7rtok12 n7rtok13 n7rtok14 n7rtok15 n7rtok16 n7rtok17 n7rtok18 n7rtok19 n7rtok20 nd7nchhh nd7nch16 nd7ochhh nd7och16 n7numadh n7anychd nd7lf03 nd7lf04 nd7lf05 nd7lf06 nd7lf07


*--------------------------------------------------------*

gen NCDSAGE46SURVEY=1
label var NCDSAGE46SURVEY "Whether took part in age 46 survey"

//whether did hh grid (age 46)
fre nd7hgdn //yes=1

//whether took part in last survey (1=yes, 2=no) (age 46)
fre n7dlasnt 

//interview year and month (age 46)
fre n7intyr //2002 2004 2005
cap drop intyear
gen intyear = n7intyr
label var intyear "Interview year (age 46)"
label define intyear -100 "no participation in sweep" -99 "information not provided", replace
label values intyear intyear
fre intyear

fre n7intmon //1-12
cap drop intmonth
gen intmonth = n7intmon
label var intmonth "Interview month (age 46)"
label define intmonth 1 "January" 2	"February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "	October" 11 "November" 12 "December" -100 "no participation in sweep" -99 "information not provided", replace
label values intmonth intmonth
fre intmonth


//whether has a partner or spouse living in household (age 46)
fre  nd7spphh //0=no 1=yes -6=didn't complete HH grid
cap drop partner
gen partner=nd7spphh
replace partner=. if nd7spphh== -6
label var partner "Whether CM has current partner in hhld (age 46)"
label define partner 0 "No" 1 "Yes" -100 "no participation in sweep" -99 "information not provided", replace
label values partner partner
fre partner


//marital status (age 46)
fre nd7ms

cap drop marital
gen marital=.
replace marital=3 if nd7ms==3|nd7ms==4|nd7ms==5|nd7ms==6 &partner==0
replace marital=2 if (nd7ms==2|nd7ms==3|nd7ms==4|nd7ms==5|nd7ms==6) & partner==1
replace marital=1 if nd7ms==1
label define marital 3 "Single non-cohabiting" 2 "Single cohabiting with partner" 1 "Married" -100 "no participation in sweep" -99 "information not provided", replace
label values marital marital
label variable marital "Marital status (age 46)" 
fre marital




*--------------------------------------------------------*
//RENAMING VARIABLES (age 46)

//number of babies during pregnancy //don't think we need this
fre n7pregn1 n7pregn2 n7pregn3 n7pregn4 n7pregn5 n7pregn6

//outcome of pregnancy (age 46)
rename (n71pga11 n71pga12 n71pga13 n71pga21 n71pga22 n71pga31 n71pga41 n71pga51 n71pga61) (prego11 prego12 prego13 prego21 prego22 prego31 prego41 prego51 prego61)

//child sex  (age 46)
rename (n7prgc11 n7prgc12 n7prgc13 n7prgc21 n7prgc22 n7prgc31 n7prgc41 n7prgc51 n7prgc61) (pregs11 pregs12 pregs13 pregs21 pregs22 pregs31 pregs41 pregs51 pregs61)

//child date of birth month (age 46)
rename (n7prgm11 n7prgm12 n7prgm13 n7prgm21 n7prgm22 n7prgm31 n7prgm41 n7prgm51 n7prgm61) (pregm11 pregm12 pregm13 pregm21 pregm22 pregm31 pregm41 pregm51 pregm61)

//child date of birth year (age 46)
rename (n7prgy11 n7prgy12 n7prgy13 n7prgy21 n7prgy22 n7prgy31 n7prgy41 n7prgy51 n7prgy61) (pregy11 pregy12 pregy13 pregy21 pregy22 pregy31 pregy41 pregy51 pregy61)

//whether child lives in household (age 46)
rename (n7livh11 n7livh12 n7livh13 n7livh21 n7livh22 n7livh31 n7livh41 n7livh51 n7livh61) (preghh11 preghh12 preghh13 preghh21 preghh22 preghh31 preghh41 preghh51 preghh61)

//where absent child currently lives //we dont use this (age 46)
fre n7abka11 n7abka12 n7abka13 n7abka21 n7abka22 n7abka31 n7abka41 n7abka51 n7abka61

//child's person number from hh grid (age 46)
rename (n7lhhn11 n7lhhn12 n7lhhn13 n7lhhn21 n7lhhn22 n7lhhn31 n7lhhn41 n7lhhn51 n7lhhn61) (pnum11 pnum12 pnum13 pnum21 pnum22 pnum31 pnum41 pnum51 pnum61)

//child's other natural parent (age 46)
rename (n7wprb11 n7wprb12 n7wprb13 n7wprb21 n7wprb22 n7wprb31 n7wprb41 n7wprb51 n7wprb61) (pregpar11 pregpar12 pregpar13 pregpar21 pregpar22 pregpar31 pregpar41 pregpar51 pregpar61)




//HOUSEHOLD GRID (age 46)
//we would need household grid information not only to work out non-biological resident children but also how many biological children still lives in the household at this sweep.
  
//relationship to CM
rename (n7rtok12 n7rtok13 n7rtok14 n7rtok15 n7rtok16 n7rtok17 n7rtok18 n7rtok19 n7rtok20) (hhrel2 hhrel3 hhrel4 hhrel5 hhrel6 hhrel7 hhrel8 hhrel9 hhrel10)

//sex
rename (n7sex12 n7sex13 n7sex14 n7sex15 n7sex16 n7sex17 n7sex18 n7sex19 n7sex20) (hhsex2 hhsex3 hhsex4 hhsex5 hhsex6 hhsex7 hhsex8 hhsex9 hhsex10)

//age in years (not year born)
rename (n7rage12 n7rage13 n7rage14 n7rage15 n7rage16 n7rage17 n7rage18 n7rage19 n7rage20) (hhage2 hhage3 hhage4 hhage5 hhage6 hhage7 hhage8 hhage9 hhage10)

//age month born //don't think we need this
fre n7pmth2 n7pmth3 n7pmth4 n7pmth5 n7pmth6 n7pmth7 n7pmth8 n7pmth9 n7pmth10

//hh person number for children only // don't think we need this
fre n7chdid2 n7chdid3 n7chdid4 n7chdid5 n7chdid6 n7chdid7 n7chdid8 n7chdid9






*************************BIOLOGICAL CHILDREN (age 46)*********************************

//whether own or fathered pregnancy since last interview (age 46)
fre n7everpg
cap drop pregsincelast
clonevar pregsincelast = n7everpg
replace pregsincelast=. if pregsincelast<0
replace pregsincelast=0 if pregsincelast==2
fre pregsincelast //N=369 or 3.9% said yes to this


*RECODE variables  (age 46)
foreach C in 11 12 13 21 22 31 41 51 61 {
foreach X of varlist pregs`C' pregm`C' pregy`C' pregpar`C' preghh`C' pnum`C' {

replace	`X'=. if prego`C'!=1 //recode all to missing if not a live birth

replace prego`C'=. if prego`C'!=1|pregsincelast==.
label define prego`C' 1 "Live birth", replace
label values prego`C' prego`C'
fre pregs`C' pregm`C' pregy`C' pregpar`C' preghh`C'

//recode to missing and other adjustments

replace	pregs`C'=. if pregs`C'<0|pregsincelast==.

replace	pregm`C'=. if pregm`C'<0

replace	pregy`C'=. if pregy`C'<0

replace	pregpar`C'=. if pregpar`C'<0 

replace	pregpar`C'=2 if partner==0 & n7othrea==2 & prego`C'==1 //recoding other parent to not current partner if there is no current partner in HH and no other non-resident partner

replace	preghh`C'=. if preghh`C'<0|pregsincelast==. 

fre prego`C' pregs`C' pregm`C' pregy`C' pregpar`C' preghh`C' pnum`C'

}
}
 

*---------------------------------------------------*

//ADDING SUFFIX 46 BEFORE MERGING WITH PREVIOUS SWEEP
foreach var of varlist _all {	
rename `var' `var'_46		
if inlist("`var'", "skip_ncdsid") {				
}
}

rename ncdsid_46 ncdsid


*------------------------------------------------------------------------*
//MERGING ON PREVIOUS SWEEPS AS WE NEED TO ADD NEW CHILDREN TO PREVIOUS ONES, ALL DEPENDING ON WHEN THEY LAST TOOK PART.

merge 1:1 ncdsid using "$derived\NCDS_fertility_age23_42.dta"
drop _merge




*-------------------------------------------------------------------*
***COMPUTE current age in whole years and of each biochild from birth year and month, and interview month and year. And age of cohort member at birth of child in whole years. (age 46)

//interview date (age 46)
cap drop intym_46
gen intym_46 = ym(intyear_46,intmonth_46)
label var intym_46 "Interview date - months since Jan 1960"
fre intym_46

//cohort member birthdate (age 46)
cap drop cmbirthy_46
gen cmbirthy_46=1958
label var cmbirthy_46 "Birth year of CM"
fre cmbirthy_46

cap drop cmbirthm_46
gen cmbirthm_46=3
label var cmbirthm_46 "Birth month of CM"
fre cmbirthm_46

cap drop cmbirthym_46
gen cmbirthym_46 = ym(cmbirthy_46,cmbirthm_46)
label var cmbirthym_46 "CM birth date - months since Jan 1960"
fre cmbirthym_46

//CM age in years (age 46)
cap drop cmagey_46
gen cmagey_46=(intym_46-cmbirthym_46)/12
replace cmagey_46 = floor(cmagey_46)
label var cmagey_46 "CM age at interview"
fre cmagey_46 




//***AGE 46 CHILDREN: children since last interview (reported at age 46)
foreach C in 11 12 13 21 22 31 41 51 61 {

cap drop biochildym`C'_46
gen biochildym`C'_46 = ym(pregy`C'_46,pregm`C'_46) 
label var biochildym`C'_46 "`C' Date of birth of biological child - months since Jan 1960"
fre biochildym`C'_46

//child's age in whole years at interview (age 46)
cap drop biochildagey`C'_46
gen biochildagey`C'_46 = (intym_46-biochildym`C'_46)/12
fre biochildagey`C'_46
replace biochildagey`C'_46 = floor(biochildagey`C'_46)
label var biochildagey`C'_46 "`C' Age in whole years of biological child"
fre biochildagey`C'_46

//cm age in whole years at birth of child (age 46)
cap drop cmageybirth`C'_46
gen cmageybirth`C'_46 = (biochildym`C'_46-cmbirthym_46)/12
fre cmageybirth`C'_46
replace cmageybirth`C'_46 = floor(cmageybirth`C'_46)
label var cmageybirth`C'_46 "`C' Age of CM in years at birth of biological child `C'"
fre cmageybirth`C'_46
}




*** ADJUSTING AGE OF PREVIOUSLY REPORTED CHILDREN TO DATE OF INTERVIEW (age 46)

*** AGE 23 CHILDREN: children reported previously at age 23
foreach C in 1_23 2_23 3_23 4_23 {

//child's age in whole years at interview
cap drop biochildagey`C'
gen biochildagey`C' = (intym_46-biochildym`C')/12
fre biochildagey`C'
replace biochildagey`C' = floor(biochildagey`C')
label var biochildagey`C' "`C' Age in whole years of biological child"
fre biochildagey`C'
}


//***AGE 33 CHILDREN: children reported previously at age 33
foreach C in 1 2 3 4 5 6 7 8 9 {

//child's age in whole years at interview
cap drop biochildagey`C'_33
gen biochildagey`C'_33 = (intym_46-biochildym`C'_33)/12
fre biochildagey`C'_33
replace biochildagey`C'_33 = floor(biochildagey`C'_33)
label var biochildagey`C'_33 "`C' Age in whole years of biological child"
fre biochildagey`C'_33
}


//***AGE 42 CHILDREN: children since 1991 (reported at age 42)
foreach C in 1 2 3 4 5 6 7 8 11 12 16 17 21 22 26 31 36 {

//child's age in whole years at interview
cap drop biochildagey`C'_42
gen biochildagey`C'_42 = (intym_46-biochildym`C'_42)/12
fre biochildagey`C'_42
replace biochildagey`C'_42 = floor(biochildagey`C'_42)
label var biochildagey`C'_42 "`C' Age in whole years of biological child"
fre biochildagey`C'_42
}




*-------------------------------------------------------------------*
*** WHETHER HAS HAD ANY BIOLOGICAL CHILDREN AND TOTAL NUMBER (age 46)

***COMPUTE whether ever had any biological children (live births) since last interview (age 46)

//this is just temporary as these will be added to last interview
cap drop anybiochildren_46
egen anybiochildren_46=anycount(prego11_46 prego12_46 prego13_46 prego21_46 prego22_46 prego31_46 prego41_46 prego51_46 prego61_46), values(1)
replace anybiochildren_46=1 if inrange(anybiochildren_46,1,20)
replace anybiochildren_46=. if pregsincelast_46==.
fre anybiochildren_46 


//Figuring out which data to add the new children to
fre anybiochildren_46 //N=9,525 //only 3% of CMs have new children

*since sweep 42
cap drop preg_42_46
gen preg_42_46=.
replace preg_42_46=1 if anybiochildren_42!=. & anybiochildren_46!=.
fre preg_42_46 //N=8082 //8903

cap drop sweep42_46
gen sweep42_46=.
replace sweep42_46=1 if NCDSAGE42SURVEY_42!=. & NCDSAGE46SURVEY_46!=.
fre sweep42_46 //N=8127 //9072

*since sweep 33
cap drop preg_33_46
gen preg_33_46=.
replace preg_33_46=1 if anybiochildren_33!=. & anybiochildren_42==. & anybiochildren_46!=.
fre preg_33_46 //N=356

cap drop sweep33_46
gen sweep33_46=.
replace sweep33_46=1 if NCDSAGE33SURVEY_33!=. & NCDSAGE42SURVEY_42==. & NCDSAGE46SURVEY_46!=.
fre sweep33_46 //N=362


*since sweep 23
cap drop preg_23_46
gen preg_23_46=.
replace preg_23_46=1 if anybiochildren_23!=. & anybiochildren_33==. & anybiochildren_42==. & anybiochildren_46!=.
fre preg_23_46 //N=249

cap drop sweep23_46
gen sweep23_46=.
replace sweep23_46=1 if NCDSAGE23SURVEY_23!=. & NCDSAGE33SURVEY_33==. & NCDSAGE42SURVEY_42==. & NCDSAGE46SURVEY_46!=.
fre sweep23_46 //N=100


*since sweep 16
cap drop preg_16_46
gen preg_16_46=.
replace preg_16_46=1 if anybiochildren_23==. & anybiochildren_33==. & anybiochildren_42==. & anybiochildren_46!=.
fre preg_16_46 //N=23

cap drop sweep16_46
gen sweep16_46=.
replace sweep16_46=1 if NCDSAGE23SURVEY_23==. & NCDSAGE33SURVEY_33==. & NCDSAGE42SURVEY_42==. & NCDSAGE46SURVEY_46!=.
fre sweep16_46 //N=0

//note above we have variables that specify which data we should be adding the children reported at age 46 to. Note that 9,525 reporting at age 46 have been split into 4 groups. So we need to do 4 parts in code below.



***COMPUTE total number of biological children (age 46)
//since age 42
cap drop biochild_total_A
egen biochild_total_A =anycount(prego11_46 prego12_46 prego13_46 prego21_46 prego22_46 prego31_46 prego41_46 prego51_46 prego61_46), values(1)
replace biochild_total_A=. if sweep42_46==.|preg_42_46==. 
replace biochild_total_A=biochild_total_A + biochild_tot_42
fre biochild_total_A //N=8903
//since age 33
cap drop biochild_total_B
egen biochild_total_B =anycount(prego11_46 prego12_46 prego13_46 prego21_46 prego22_46 prego31_46 prego41_46 prego51_46 prego61_46), values(1)
replace biochild_total_B=. if sweep33_46==.|preg_33_46==. 
replace biochild_total_B= biochild_total_B + biochild_tot_33
fre biochild_total_B //N=349
//since age 23
cap drop biochild_total_C
egen biochild_total_C =anycount(prego11_46 prego12_46 prego13_46 prego21_46 prego22_46 prego31_46 prego41_46 prego51_46 prego61_46), values(1)
replace biochild_total_C=. if sweep23_46==.|preg_23_46==. 
replace biochild_total_C= biochild_total_C + biochild_tot_23
fre biochild_total_C //N=99

//note 4th block we dont't do as no observations



// COMPUTE age 46 total children
fre biochild_total_A biochild_total_B biochild_total_C

cap drop included
gen included=.
replace included=1 if biochild_total_A!=.
replace included=1 if biochild_total_B!=.
replace included=1 if biochild_total_C!=.
fre included

cap drop biochild_tot_46
egen biochild_tot_46=rowtotal(biochild_total_A biochild_total_B biochild_total_C)
replace biochild_tot_46=. if included==.
fre biochild_tot_46
label define biochild_tot_46 0 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values biochild_tot_46 biochild_tot_46
label variable biochild_tot_46 "Total number of biological children"
fre biochild_tot_46


*-----------------------------------------------------*
*** CHECKING EXTRA BIOLOGICAL CHILDREN IN HOUSEHOLD NOT REPORTED AS PREGNANCY (age 46)

***COMPUTE total number of biological children reported in hh grid

//we have to use HH grid data for this as pregnancy data will only include current location of the new children, whereas children reported in pregnancy data previously will not have up to date information of where they live.

cap drop biochildhh_total_46
egen biochildhh_total_46 = anycount(hhrel2_46 hhrel3_46 hhrel4_46 hhrel5_46 hhrel6_46 hhrel7_46 hhrel8_46 hhrel9_46 hhrel10_46), values(3) //3=own child
replace biochildhh_total_46=. if (NCDSAGE46SURVEY_46==.| nd7hgdn==0|nd7hgdn==.)
 //code to missing if not in age 46 sweep or didn't complete HH grid.
label variable biochildhh_total_46 "Total number of biological children in HH grid age 46"   
fre biochildhh_total_46

clonevar biohhgrid_total_46 = biochildhh_total_46 //creating a variable for the original hhgrid total number of bio children




//computing difference in pregnancy data and household data (age 46)

cap drop biochild_tot_miss_46
gen biochild_tot_miss_46=1 if biochild_tot_46==. //this creates a missing values flag for this variable

replace biochild_tot_46=0 if biochild_tot_46==. // this bit is important as crucial for the inclusion of all HH grid data in adjustments for extra children 

fre biochild_tot_46 biochildhh_total_46
tab biochild_tot_46 biochildhh_total_46, mi
cap drop difference_46
gen difference_46=biochild_tot_46 - biochildhh_total_46
fre difference_46


//creating a variable that flags CMs with differences (age 46)
cap drop biochild_extra_flag_46
gen biochild_extra_flag_46=.
label var biochild_extra_flag_46 "Flag: More bio children reported in HH grid than in pregnancy data"
replace biochild_extra_flag_46=1 if inrange(difference_46, -10,-1)
replace biochild_extra_flag_46=0 if inrange(difference_46,0,20)
label define biochild_extra_flag_46 1 "Yes" 0 "No" -100 "no participation in sweep" -99 "information not provided", replace
label values biochild_extra_flag_46 biochild_extra_flag_46
fre biochild_extra_flag_46 //applies to 709 CMs 

//creating variable to use for adjustment of total children (age 46)
cap drop bioextra_46
gen bioextra_46=difference_46
replace bioextra_46=0 if inrange(difference_46,0,10)
replace bioextra_46=1 if difference_46==-1
replace bioextra_46=2 if difference_46==-2
replace bioextra_46=3 if difference_46==-3
replace bioextra_46=4 if difference_46==-4
replace bioextra_46=5 if difference_46==-5
replace bioextra_46=6 if difference_46==-6
replace bioextra_46=7 if difference_46==-7
fre bioextra_46



******ADJUSTING (age 46)
cap drop bioextra_miss_46
gen bioextra_miss_46=1 if bioextra_46==. //missing values flag 
fre bioextra_miss_46
replace bioextra_46=0 if bioextra_46==.

fre biochild_tot_miss_46 //already created a missing flag for this

//TOTAL NUMBER OF CHILDREN (age 46)
fre biochild_tot_46 bioextra_46
replace biochild_tot_46=biochild_tot_46 + bioextra_46
replace biochild_tot_46=. if biochild_tot_miss_46== 1 //& bioextra_miss_46==1
fre biochild_tot_46


//ANY BIO CHILDREN (age 46)
cap drop anybiochildren_46
gen anybiochildren_46=.
replace anybiochildren_46=1 if inrange(biochild_tot_46,1,20)
replace anybiochildren_46=0 if biochild_tot_46==0
fre anybiochildren_46
label variable anybiochildren_46 "Whether CM has had any biological children age 46"
label define yesno 0 "No" 1 "Yes" -100 "no participation in sweep" -99 "information not provided", replace
label values anybiochildren_46 yesno
fre anybiochildren_46 


//WHERE LIVE (age 46)

*in household (age 46)
fre biochildhh_total_46
label variable biochildhh_total_46 "Total number of bio children in household age 46"
fre biochildhh_total_46

*not in household (age 46)
fre biochild_tot_46 biochildhh_total_46 
cap drop biochildnonhh_total_46
gen biochildnonhh_total_46= biochild_tot_46-biochildhh_total_46 
replace biochildnonhh_total_46=-10 if anybiochildren_46==0
label variable biochildnonhh_total_46 "Total number of bio children not in household age 46"
fre biochildnonhh_total_46
label define biochildnonhh_total_46 0 "All biological children live in household" -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildnonhh_total_46 biochildnonhh_total_46
fre biochildnonhh_total_46

*coding values for previous variable (age 46)
replace biochildhh_total_46=-10 if anybiochildren_46==0
replace biochildhh_total_46=. if anybiochildren_46==.
label define biochildhh_total_46 -10 "No biological children" 0 "None of the biological children live in household" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildhh_total_46 biochildhh_total_46
fre biochildhh_total_46



*******************************************************
*** OTHER PARENT OF CHILDREN IS CURRENT PARTNER (age 46)
*******************************************************
//we have this information on the new children. For the older children, reported previously, we don't have information on whether the other parent is the current partner. 





****************************************************
*** SEX OF BIOLOGICAL CHILDREN (age 46)
****************************************************
//sex 1=boy 2=girl

*----------------------------------------------------------------*
***COMPUTE total number of biological BOYS (age 46)

//recoding -10 to 0
cap drop Rbiochildboy_total_42
clonevar Rbiochildboy_total_42 = biochildboy_total_42
replace Rbiochildboy_total_42=0 if Rbiochildboy_total_42==-10

cap drop Rbiochildboy_total_33
clonevar Rbiochildboy_total_33 = biochildboy_total_33
replace Rbiochildboy_total_33=0 if Rbiochildboy_total_33==-10

cap drop Rbiochildboy_total_23
clonevar Rbiochildboy_total_23 = biochildboy_total_23
replace Rbiochildboy_total_23=0 if Rbiochildboy_total_23==-10



*ADDING AGE 46 BOYS TO THE APPROPRIATE SWEEP

//since age 42
cap drop biochildboy_total_A
egen biochildboy_total_A =anycount(pregs11_46 pregs12_46 pregs13_46 pregs21_46 pregs22_46 pregs31_46 pregs41_46 pregs51_46 pregs61_46), values(1)
replace biochildboy_total_A=. if sweep42_46==.|preg_42_46==. 
replace biochildboy_total_A=biochildboy_total_A + Rbiochildboy_total_42
fre biochildboy_total_A //N=8082
//since age 33
cap drop biochildboy_total_B
egen biochildboy_total_B =anycount(pregs11_46 pregs12_46 pregs13_46 pregs21_46 pregs22_46 pregs31_46 pregs41_46 pregs51_46 pregs61_46), values(1)
replace biochildboy_total_B=. if sweep33_46==.|preg_33_46==. 
replace biochildboy_total_B= biochildboy_total_B + Rbiochildboy_total_33
fre biochildboy_total_B //N=356
//since age 23
cap drop biochildboy_total_C
egen biochildboy_total_C =anycount(pregs11_46 pregs12_46 pregs13_46 pregs21_46 pregs22_46 pregs31_46 pregs41_46 pregs51_46 pregs61_46 biochild1_23 biochild2_23 biochild3_23 biochild4_23), values(1)
replace biochildboy_total_C=. if sweep23_46==.|preg_23_46==. 
replace biochildboy_total_C= biochildboy_total_C + Rbiochildboy_total_23
fre biochildboy_total_C //N=99


// COMPUTE age 46 total boys
fre biochildboy_total_A biochildboy_total_B biochildboy_total_C

cap drop biochildboy_total_46
egen biochildboy_total_46=rowtotal(biochildboy_total_A biochildboy_total_B biochildboy_total_C)
replace biochildboy_total_46=. if included==.
replace biochildboy_total_46=-10 if anybiochildren_46==0
label define biochildboy_total_46 0 "Girls only" -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values biochildboy_total_46 biochildboy_total_46
label variable biochildboy_total_46 "Total number of biological boys"
fre biochildboy_total_46




*----------------------------------------------------------------*
***COMPUTE total number of biological girlS (age 46)

//recoding -10 to 0
cap drop Rbiochildgirl_total_42
clonevar Rbiochildgirl_total_42 = biochildgirl_total_42
replace Rbiochildgirl_total_42=0 if Rbiochildgirl_total_42==-10

cap drop Rbiochildgirl_total_33
clonevar Rbiochildgirl_total_33 = biochildgirl_total_33
replace Rbiochildgirl_total_33=0 if Rbiochildgirl_total_33==-10

cap drop Rbiochildgirl_total_23
clonevar Rbiochildgirl_total_23 = biochildgirl_total_23
replace Rbiochildgirl_total_23=0 if Rbiochildgirl_total_23==-10


*ADDING AGE 46 girls TO THE APPROPRIATE SWEEP

//since age 42
cap drop biochildgirl_total_A
egen biochildgirl_total_A =anycount(pregs11_46 pregs12_46 pregs13_46 pregs21_46 pregs22_46 pregs31_46 pregs41_46 pregs51_46 pregs61_46), values(2)
replace biochildgirl_total_A=. if sweep42_46==.|preg_42_46==. 
replace biochildgirl_total_A=biochildgirl_total_A + Rbiochildgirl_total_42
fre biochildgirl_total_A //N=8082
//since age 33
cap drop biochildgirl_total_B
egen biochildgirl_total_B =anycount(pregs11_46 pregs12_46 pregs13_46 pregs21_46 pregs22_46 pregs31_46 pregs41_46 pregs51_46 pregs61_46), values(2)
replace biochildgirl_total_B=. if sweep33_46==.|preg_33_46==. 
replace biochildgirl_total_B= biochildgirl_total_B + Rbiochildgirl_total_33
fre biochildgirl_total_B //N=356
//since age 23
cap drop biochildgirl_total_C
egen biochildgirl_total_C =anycount(pregs11_46 pregs12_46 pregs13_46 pregs21_46 pregs22_46 pregs31_46 pregs41_46 pregs51_46 pregs61_46 biochild1_23 biochild2_23 biochild3_23 biochild4_23), values(2)
replace biochildgirl_total_C=. if sweep23_46==.|preg_23_46==. 
replace biochildgirl_total_C= biochildgirl_total_C + Rbiochildgirl_total_23
fre biochildgirl_total_C //N=99


// COMPUTE age 46 total girls
fre biochildgirl_total_A biochildgirl_total_B biochildgirl_total_C

cap drop biochildgirl_total_46
egen biochildgirl_total_46=rowtotal(biochildgirl_total_A biochildgirl_total_B biochildgirl_total_C)
replace biochildgirl_total_46=. if included==.
replace biochildgirl_total_46=-10 if anybiochildren_46==0
label define biochildgirl_total_46 0 "Boys only" -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values biochildgirl_total_46 biochildgirl_total_46
label variable biochildgirl_total_46 "Total number of biological girls"
fre biochildgirl_total_46


*----------------------------------------------------------------*



*----------------------------------------------------------*
******ADJUSTING PREVIOUS VARIABLES ADDING THE EXTRA GIRLS AND BOYS IDENTIFIED IN HH GRID BUT NOT INCLUDED IN PREGNANCY DATA (age 46)

foreach C in 2_46 3_46 4_46 5_46 6_46 7_46 8_46 9_46 10_46 {

*sex of biological hh children
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


***COMPUTE total number of biological girls and boys reported in hh grid (age 46)
cap drop biochildhhboy_total_46
gen biochildhhboy_total_46=biochildhhboy2_46+biochildhhboy3_46+biochildhhboy4_46+biochildhhboy5_46+biochildhhboy6_46+biochildhhboy7_46+biochildhhboy8_46+biochildhhboy9_46+biochildhhboy10_46
replace biochildhhboy_total_46=.  if nd7hgdn==0|nd7hgdn==.
label variable biochildhhboy_total_46 "Total number of bio boys in household (HH grid data)"
fre biochildhhboy_total_46

cap drop biochildhhgirl_total_46
gen biochildhhgirl_total_46=biochildhhgirl2_46+biochildhhgirl3_46+biochildhhgirl4_46+biochildhhgirl5_46+biochildhhgirl6_46+biochildhhgirl7_46+biochildhhgirl8_46+biochildhhgirl9_46+biochildhhgirl10_46
replace biochildhhgirl_total_46=.  if nd7hgdn==0|nd7hgdn==.
label variable biochildhhgirl_total_46 "Total number of bio girls in household (HH grid data)"
fre biochildhhgirl_total_46


//computing difference in pregnancy data and household data

fre biochildboy_total_46 biochildgirl_total_46 //pregnancies
fre biochildhhboy_total_46 biochildhhgirl_total_46 //hh grid

cap drop biochildboy_tot_miss_46
gen biochildboy_tot_miss_46=1 if biochildboy_total_46==. //this creates a missing values flag for this variable
cap drop biochildgirl_tot_miss_46
gen biochildgirl_tot_miss_46=1 if biochildgirl_total_46==. //this creates a missing values flag for this variable

replace biochildboy_total_46=0 if biochildboy_total_46==.|biochildboy_total_46==-10 // this bit is important as crucial for the inclusion of all HH grid data in adjustments for extra children 
replace biochildgirl_total_46=0 if biochildgirl_total_46==.|biochildgirl_total_46==-10 // this bit is important as crucial for the inclusion of all HH grid data in adjustments for extra children 

fre biochildboy_total_46 biochildhhboy_total_46
tab biochildboy_total_46 biochildhhboy_total_46, mi
cap drop diff_boy_46
gen diff_boy_46=biochildboy_total_46 - biochildhhboy_total_46
fre diff_boy_46

fre biochildgirl_total_46 biochildhhgirl_total_46
tab biochildgirl_total_46 biochildhhgirl_total_46, mi
cap drop diff_girl_46
gen diff_girl_46=biochildgirl_total_46 - biochildhhgirl_total_46
fre diff_girl_46

//creating a variable that flags CMs with differences
cap drop bioboy_extra_flag_46
gen bioboy_extra_flag_46=.
label var bioboy_extra_flag_46 "Flag: More bio boys reported in HH grid than in pregnancy data"
replace bioboy_extra_flag_46=1 if inrange(diff_boy_46, -10,-1)
fre bioboy_extra_flag_46 //applies to 501

//creating a variable that flags CMs with differences
cap drop biogirl_extra_flag_46
gen biogirl_extra_flag_46=.
label var biogirl_extra_flag_46 "Flag: More bio girls reported in HH grid than in pregnancy data"
replace biogirl_extra_flag_46=1 if inrange(diff_girl_46, -10,-1)
fre biogirl_extra_flag_46 //applies to 477
 

//creating variable to use for adjustment of total boys and girls
cap drop bioextraboy_46
gen bioextraboy_46=difference_46
replace bioextraboy_46=0 if inrange(diff_boy_46,0,10)
replace bioextraboy_46=1 if diff_boy_46==-1
replace bioextraboy_46=2 if diff_boy_46==-2
replace bioextraboy_46=3 if diff_boy_46==-3
replace bioextraboy_46=4 if diff_boy_46==-4
replace bioextraboy_46=5 if diff_boy_46==-5
replace bioextraboy_46=6 if diff_boy_46==-6
replace bioextraboy_46=7 if diff_boy_46==-7
fre bioextraboy_46

cap drop bioextragirl_46
gen bioextragirl_46=difference_46
replace bioextragirl_46=0 if inrange(diff_girl_46,0,10)
replace bioextragirl_46=1 if diff_girl_46==-1
replace bioextragirl_46=2 if diff_girl_46==-2
replace bioextragirl_46=3 if diff_girl_46==-3
replace bioextragirl_46=4 if diff_girl_46==-4
replace bioextragirl_46=5 if diff_girl_46==-5
replace bioextragirl_46=6 if diff_girl_46==-6
replace bioextragirl_46=7 if diff_girl_46==-7
fre bioextragirl_46


******ADJUSTING (age 46)

//first doing some missing value flags
cap drop bioextraboy_miss_46
gen bioextraboy_miss_46=1 if bioextraboy_46==. //missing values flag 
fre bioextraboy_miss_46
replace bioextraboy_46=0 if bioextraboy_46==.

cap drop bioextragirl_miss_46
gen bioextragirl_miss_46=1 if bioextragirl_46==. //missing values flag 
fre bioextragirl_miss_46
replace bioextragirl_46=0 if bioextragirl_46==.

fre biochildboy_tot_miss_46 //already created a missing flag for this
fre biochildgirl_tot_miss_46 //already created a missing flag for this



//TOTAL NUMBER OF BOYS AND GIRLS (age 46)

fre biochildboy_tot_miss_46 bioextraboy_miss_46

//boys (age 46)
fre biochildboy_total_46 bioextraboy_46
replace biochildboy_total_46=biochildboy_total_46+bioextraboy_46
replace biochildboy_total_46=. if biochildboy_tot_miss_46==1 //& bioextraboy_miss_46==1
replace biochildboy_total_46=-10 if anybiochildren_46==0
fre biochildboy_total_46

//girls (age 46)
fre biochildgirl_total_46
replace biochildgirl_total_46=biochildgirl_total_46+bioextragirl_46
replace biochildgirl_total_46=. if biochildgirl_tot_miss_46==1 //& bioextragirl_miss_46==1
replace biochildgirl_total_46=-10 if anybiochildren_46==0
fre biochildgirl_total_46






*********************************************************
*** AGES OF BIOLOGICAL CHILDREN (age 46)
*********************************************************


//1. we have already updated ages of pregnancy childrens ages previously.
fre biochildagey1_23 biochildagey2_23 biochildagey3_23 biochildagey4_23 

fre biochildagey1_33 biochildagey2_33 biochildagey3_33 biochildagey4_33 biochildagey5_33 biochildagey6_33 biochildagey7_33 biochildagey8_33 biochildagey9_33 

fre biochildagey1_42 biochildagey2_42 biochildagey3_42 biochildagey4_42 biochildagey5_42 biochildagey6_42 biochildagey7_42 biochildagey8_42 biochildagey11_42 biochildagey12_42 biochildagey16_42 biochildagey17_42 biochildagey21_42 biochildagey22_42 biochildagey26_42 biochildagey31_42 biochildagey36_42

fre biochildagey11_46 biochildagey12_46 biochildagey13_46 biochildagey21_46 biochildagey22_46 biochildagey31_46 biochildagey41_46 biochildagey51_46 biochildagey61_46
 

 
//2. now update ages of extra HH grid children identified at 33 and 42 
 
// time in years since last interview at age 33 to be added to HH grid bio children's ages 
cap drop addtime
gen addtime=(intym_46-intym_33)/12
replace addtime=round(addtime, 1)
fre addtime 

foreach C in 2_33 3_33 4_33 5_33 6_33 7_33 8_33 9_33 10_33 {
cap drop Rbiohhage`C'
gen Rbiohhage`C'=.
replace Rbiohhage`C'=hhage`C' if hhrel`C'==3 & biochild_extra_flag_33==1
replace Rbiohhage`C'=(Rbiohhage`C' + addtime)
fre Rbiohhage`C'
} 
 
 
// time in years since last interview at age 42 to be added to HH grid bio children's ages 
cap drop addtime
gen addtime=(intym_46-intym_42)/12
replace addtime=round(addtime, 1)
fre addtime 

foreach C in 2_42 3_42 4_42 5_42 6_42 7_42 8_42 9_42 10_42 {
cap drop Rbiohhage`C'
gen Rbiohhage`C'=.
replace Rbiohhage`C'=hhage`C' if hhrel`C'==3 & biochild_extra_flag_42==1
replace Rbiohhage`C'=(Rbiohhage`C' + addtime)
fre Rbiohhage`C'
} 


//3. identify additional children in HH grid at age 46
***COMPUTE age of eldest and youngest child in years from HH grid data at age 46 for CM's with a flag for having more children in HH grid than in preg data.
foreach C in 2_46 3_46 4_46 5_46 6_46 7_46 8_46 9_46 10_46 {
cap drop biohhage`C'
gen biohhage`C'=.
replace biohhage`C'=hhage`C' if hhrel`C'==3 & biochild_extra_flag_46==1
fre biohhage`C'
}



//THEN DO FINAL AGE OF CHILDREN MEASURE (age 46)
*--------------------------------------------------------------------*
*** COMPUTE age of eldest and youngest biological child (age 46)
cap drop biochildy_eldest_46 //years
gen biochildy_eldest_46 = max(biochildagey11_46,biochildagey12_46,biochildagey13_46,biochildagey21_46,biochildagey22_46,biochildagey31_46,biochildagey41_46,biochildagey51_46,biochildagey61_46, biochildagey1_42, biochildagey2_42, biochildagey3_42, biochildagey4_42, biochildagey5_42, biochildagey6_42, biochildagey7_42, biochildagey8_42, biochildagey11_42, biochildagey12_42, biochildagey16_42, biochildagey17_42, biochildagey21_42, biochildagey22_42, biochildagey26_42, biochildagey31_42, biochildagey36_42, biochildagey1_33, biochildagey2_33, biochildagey3_33, biochildagey4_33, biochildagey5_33, biochildagey6_33, biochildagey7_33, biochildagey8_33, biochildagey9_33,biochildagey1_23, biochildagey2_23, biochildagey3_23, biochildagey4_23, biohhage2_46, biohhage3_46, biohhage4_46, biohhage5_46, biohhage6_46, biohhage7_46, biohhage8_46, biohhage9_46, biohhage10_46, Rbiohhage2_42,Rbiohhage3_42,Rbiohhage4_42,Rbiohhage5_42,Rbiohhage6_42,Rbiohhage7_42,Rbiohhage8_42,Rbiohhage9_42,Rbiohhage10_42,Rbiohhage2_33,Rbiohhage3_33,Rbiohhage4_33,Rbiohhage5_33,Rbiohhage6_33,Rbiohhage7_33,Rbiohhage8_33,Rbiohhage9_33,Rbiohhage10_33)
replace biochildy_eldest_46=-10 if anybiochildren_46==0
replace biochildy_eldest_46=. if biochild_tot_miss_46==1
label define biochildy_eldest_46 -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildy_eldest_46 biochildy_eldest_46
label var biochildy_eldest_46 "Age in years of eldest biological child"
fre biochildy_eldest_46

cap drop biochildy_youngest_46 //years
gen biochildy_youngest_46 = min(biochildagey11_46,biochildagey12_46,biochildagey13_46,biochildagey21_46,biochildagey22_46,biochildagey31_46,biochildagey41_46,biochildagey51_46,biochildagey61_46, biochildagey1_42, biochildagey2_42, biochildagey3_42, biochildagey4_42, biochildagey5_42, biochildagey6_42, biochildagey7_42, biochildagey8_42, biochildagey11_42, biochildagey12_42, biochildagey16_42, biochildagey17_42, biochildagey21_42, biochildagey22_42, biochildagey26_42, biochildagey31_42, biochildagey36_42, biochildagey1_33, biochildagey2_33, biochildagey3_33, biochildagey4_33, biochildagey5_33, biochildagey6_33, biochildagey7_33, biochildagey8_33, biochildagey9_33,biochildagey1_23, biochildagey2_23, biochildagey3_23, biochildagey4_23, biohhage2_46, biohhage3_46, biohhage4_46, biohhage5_46, biohhage6_46, biohhage7_46, biohhage8_46, biohhage9_46, biohhage10_46, Rbiohhage2_42,Rbiohhage3_42,Rbiohhage4_42,Rbiohhage5_42,Rbiohhage6_42,Rbiohhage7_42,Rbiohhage8_42,Rbiohhage9_42,Rbiohhage10_42,Rbiohhage2_33,Rbiohhage3_33,Rbiohhage4_33,Rbiohhage5_33,Rbiohhage6_33,Rbiohhage7_33,Rbiohhage8_33,Rbiohhage9_33,Rbiohhage10_33)
replace biochildy_youngest_46=-10 if anybiochildren_46==0
replace biochildy_youngest_46=. if biochild_tot_miss_46==1
label define biochildy_youngest_46 -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildy_youngest_46 biochildy_youngest_46
label var biochildy_youngest_46 "Age in years of youngest biological child"
fre biochildy_youngest_46







*************************************************************
******** AGE OF COHORT MEMBER AGE AT BIRTH (age 46) *******
*************************************************************

//generating variables for the extra HH grid children at age 33 and 42 and 46 to include in final code below. We subtract childs age from age 46 as childrens age has already been adjusted to be their age at age 46 interview if reported in a previous sweep, using the Rbioage variable.

foreach C in 2_46 3_46 4_46 5_46 6_46 7_46 8_46 9_46 10_46 {
cap drop cmagebirth_hhextra`C'
gen cmagebirth_hhextra`C'=cmagey_46-biohhage`C' if biochild_extra_flag_46==1
fre cmagebirth_hhextra`C'
}

foreach C in 2_42 3_42 4_42 5_42 6_42 7_42 8_42 9_42 10_42 {
cap drop cmagebirth_hhextra`C'
gen cmagebirth_hhextra`C'=cmagey_46-Rbiohhage`C' if biochild_extra_flag_42==1
fre cmagebirth_hhextra`C'
}

foreach C in 2_33 3_33 4_33 5_33 6_33 7_33 8_33 9_33 10_33 {
cap drop cmagebirth_hhextra`C'
gen cmagebirth_hhextra`C'=cmagey_46-Rbiohhage`C' if biochild_extra_flag_33==1
fre cmagebirth_hhextra`C'
}


***COMPUTE age of cohort member at birth of eldest and youngest child in years (age 46)
cap drop cmageybirth_eldest_46 //years
gen cmageybirth_eldest_46 = min(cmageybirth11_46,cmageybirth12_46,cmageybirth13_46,cmageybirth21_46,cmageybirth22_46,cmageybirth31_46,cmageybirth41_46,cmageybirth51_46,cmageybirth61_46,cmagebirth_hhextra2_46,cmagebirth_hhextra3_46,cmagebirth_hhextra4_46,cmagebirth_hhextra5_46,cmagebirth_hhextra6_46,cmagebirth_hhextra7_46,cmagebirth_hhextra8_46,cmagebirth_hhextra9_46,cmagebirth_hhextra10_46,cmageybirth1_42,cmageybirth2_42,cmageybirth3_42,cmageybirth4_42,cmageybirth5_42,cmageybirth6_42,cmageybirth7_42,cmageybirth8_42,cmageybirth11_42,cmageybirth12_42,cmageybirth16_42,cmageybirth17_42,cmageybirth21_42,cmageybirth22_42,cmageybirth26_42,cmageybirth31_42,cmageybirth36_42,cmagebirth_hhextra2_42,cmagebirth_hhextra3_42,cmagebirth_hhextra4_42,cmagebirth_hhextra5_42,cmagebirth_hhextra6_42,cmagebirth_hhextra7_42,cmagebirth_hhextra8_42,cmagebirth_hhextra9_42,cmagebirth_hhextra10_42, cmageybirth1_33,cmageybirth2_33,cmageybirth3_33,cmageybirth4_33,cmageybirth5_33,cmageybirth6_33,cmageybirth7_33,cmageybirth8_33,cmageybirth9_33, cmagebirth_hhextra2_33,cmagebirth_hhextra3_33,cmagebirth_hhextra4_33,cmagebirth_hhextra5_33,cmagebirth_hhextra6_33,cmagebirth_hhextra7_33,cmagebirth_hhextra8_33,cmagebirth_hhextra9_33,cmagebirth_hhextra10_33, cmageybirth1_23, cmageybirth2_23, cmageybirth3_23, cmageybirth4_23)
replace cmageybirth_eldest_46=-10 if anybiochildren_46==0
replace cmageybirth_eldest_46=. if biochild_tot_miss_46==1
label define cmageybirth_eldest_46 -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values cmageybirth_eldest_46 cmageybirth_eldest_46
label var cmageybirth_eldest_46 "CM age in years at birth of eldest biological child"
fre cmageybirth_eldest_46

cap drop cmageybirth_youngest_46 //years
gen cmageybirth_youngest_46 = max(cmageybirth11_46,cmageybirth12_46,cmageybirth13_46,cmageybirth21_46,cmageybirth22_46,cmageybirth31_46,cmageybirth41_46,cmageybirth51_46,cmageybirth61_46,cmagebirth_hhextra2_46,cmagebirth_hhextra3_46,cmagebirth_hhextra4_46,cmagebirth_hhextra5_46,cmagebirth_hhextra6_46,cmagebirth_hhextra7_46,cmagebirth_hhextra8_46,cmagebirth_hhextra9_46,cmagebirth_hhextra10_46,cmageybirth1_42,cmageybirth2_42,cmageybirth3_42,cmageybirth4_42,cmageybirth5_42,cmageybirth6_42,cmageybirth7_42,cmageybirth8_42,cmageybirth11_42,cmageybirth12_42,cmageybirth16_42,cmageybirth17_42,cmageybirth21_42,cmageybirth22_42,cmageybirth26_42,cmageybirth31_42,cmageybirth36_42,cmagebirth_hhextra2_42,cmagebirth_hhextra3_42,cmagebirth_hhextra4_42,cmagebirth_hhextra5_42,cmagebirth_hhextra6_42,cmagebirth_hhextra7_42,cmagebirth_hhextra8_42,cmagebirth_hhextra9_42,cmagebirth_hhextra10_42, cmageybirth1_33,cmageybirth2_33,cmageybirth3_33,cmageybirth4_33,cmageybirth5_33,cmageybirth6_33,cmageybirth7_33,cmageybirth8_33,cmageybirth9_33, cmagebirth_hhextra2_33,cmagebirth_hhextra3_33,cmagebirth_hhextra4_33,cmagebirth_hhextra5_33,cmagebirth_hhextra6_33,cmagebirth_hhextra7_33,cmagebirth_hhextra8_33,cmagebirth_hhextra9_33,cmagebirth_hhextra10_33, cmageybirth1_23, cmageybirth2_23, cmageybirth3_23, cmageybirth4_23)
replace cmageybirth_youngest_46=-10 if anybiochildren_46==0
replace cmageybirth_youngest_46=. if biochild_tot_miss_46==1
label define cmageybirth_youngest_46 -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values cmageybirth_youngest_46 cmageybirth_youngest_46
label var cmageybirth_youngest_46 "CM age in years at birth of youngest biological child"
fre cmageybirth_youngest_46






*************************************************************
*** NON BIOLOGICAL CHILDREN (age 46) ***
*************************************************************
fre hhrel2_46 hhrel3_46 hhrel4_46 hhrel5_46 hhrel6_46 hhrel7_46 hhrel8_46 hhrel9_46 hhrel10_46

*RECODE on non-biological children variables (age 46)
foreach C in 2_46 3_46 4_46 5_46 6_46 7_46 8_46 9_46 10_46 {

*non-biological and type (age 46)
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


*age of nonbio children (age 46)
cap drop nonbiochildagey`C'
clonevar nonbiochildagey`C' = hhage`C' if inrange(hhrel`C',4,7) & hhage`C'<100 
label var nonbiochildagey`C' "`C' Age in years of non-biological child"
fre nonbiochildagey`C'

*sex of nonbio children (age 46)
cap drop nonbiochildsex`C'
clonevar nonbiochildsex`C' = hhsex`C' if inrange(hhrel`C',4,7)
label var nonbiochildsex`C' "`C' Sex of non-biological child"
fre nonbiochildsex`C'

}



***COMPUTE whether has any non-biologial children in household (age 46)
cap drop anynonbio_46
egen anynonbio_46=anycount(nonbiochild2_46 nonbiochild3_46 nonbiochild4_46 nonbiochild5_46 nonbiochild6_46 nonbiochild7_46 nonbiochild8_46 nonbiochild9_46 nonbiochild10_46), values(1)
replace anynonbio_46=1 if inrange(anynonbio_46,1,20)
replace anynonbio_46=. if (nd7hgdn==0|nd7hgdn==.)
label variable anynonbio_46 "Whether CM has any non-biological children in household"
label define yesno 0 "No" 1 "Yes" -100 "no participation in sweep" -99 "information not provided", replace
label values anynonbio_46 yesno
fre anynonbio_46 


***COMPUTE total number of non-biologial children in household (age 46)

//number of all non-biological (age 46)
cap drop nonbiochild_tot_46
egen nonbiochild_tot_46 = anycount(nonbiochild2_46 nonbiochild3_46 nonbiochild4_46 nonbiochild5_46 nonbiochild6_46 nonbiochild7_46 nonbiochild8_46 nonbiochild9_46 nonbiochild10_46), values(1)
replace nonbiochild_tot_46=. if (nd7hgdn==0|nd7hgdn==.)
label define nonbiochild_tot_46 0 "No non-biological children in HH" -100 "no participation in sweep" -99 "information not provided", replace 
label values nonbiochild_tot_46 nonbiochild_tot_46
label variable nonbiochild_tot_46 "Total number of non-biological children in household"
fre nonbiochild_tot_46


//number of adopted (age 46)
cap drop adopt_tot_46
egen adopt_tot_46 = anycount(adopt2_46 adopt3_46 adopt4_46 adopt5_46 adopt6_46 adopt7_46 adopt8_46 adopt9_46 adopt10_46), values(1)
replace adopt_tot_46=. if (nd7hgdn==0|nd7hgdn==.)
label define adopt_tot_46 0 "No adopted children in HH" -100 "no participation in sweep" -99 "information not provided", replace 
label values adopt_tot_46 adopt_tot_46
label variable adopt_tot_46 "Total number of adopted children in household"
fre adopt_tot_46

//number of foster (age 46)
cap drop foster_tot_46
egen foster_tot_46 = anycount(foster2_46 foster3_46 foster4_46 foster5_46 foster6_46 foster7_46 foster8_46 foster9_46 foster10_46), values(1)
replace foster_tot_46=. if (nd7hgdn==0|nd7hgdn==.)
label define foster_tot_46 0 "No foster children in HH" -100 "no participation in sweep" -99 "information not provided", replace 
label values foster_tot_46 foster_tot_46
label variable foster_tot_46 "Total number of foster children in household"
fre foster_tot_46

//number of stepchildren (age 46)
cap drop step_tot_46
egen step_tot_46 = anycount(step2_46 step3_46 step4_46 step5_46 step6_46 step7_46 step8_46 step9_46 step10_46), values(1)
replace step_tot_46=. if (nd7hgdn==0|nd7hgdn==.)
label define step_tot_46 0 "No stepchildren in HH" -100 "no participation in sweep" -99 "information not provided", replace 
label values step_tot_46 step_tot_46
label variable step_tot_46 "Total number of stepchildren in household"
fre step_tot_46



***COMPUTE age of youngest and oldest non-biological child (age 46)
cap drop nonbiochildy_eldest_46 //years
gen nonbiochildy_eldest_46 = max(nonbiochildagey2_46, nonbiochildagey3_46, nonbiochildagey4_46, nonbiochildagey5_46, nonbiochildagey6_46, nonbiochildagey7_46, nonbiochildagey8_46, nonbiochildagey9_46, nonbiochildagey10_46)
replace nonbiochildy_eldest_46=-10 if anynonbio_46==0
replace nonbiochildy_eldest_46=. if (nd7hgdn==0|nd7hgdn==.)
label define nonbiochildy_eldest_46 -10 "No non-biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values nonbiochildy_eldest_46 nonbiochildy_eldest_46
label var nonbiochildy_eldest_46 "Age in years of youngest non-biological child"
fre nonbiochildy_eldest_46

cap drop nonbiochildy_youngest_46 //years
gen nonbiochildy_youngest_46 = min(nonbiochildagey2_46, nonbiochildagey3_46, nonbiochildagey4_46, nonbiochildagey5_46, nonbiochildagey6_46, nonbiochildagey7_46, nonbiochildagey8_46, nonbiochildagey9_46, nonbiochildagey10_46)
replace nonbiochildy_youngest_46=-10 if anynonbio_46==0
replace nonbiochildy_youngest_46=. if (nd7hgdn==0|nd7hgdn==.)
label define nonbiochildy_youngest_46 -10 "No non-biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values nonbiochildy_youngest_46 nonbiochildy_youngest_46
label var nonbiochildy_youngest_46 "Age in years of youngest non-biological child"
fre nonbiochildy_youngest_46




***COMPUTE total number of non-biological boys and girls (age 46)
//nonbiochildsex: 1=boy 2=girl

cap drop nonbiochildboy_total_46
egen nonbiochildboy_total_46 = anycount(nonbiochildsex2_46 nonbiochildsex3_46 nonbiochildsex4_46 nonbiochildsex5_46 nonbiochildsex6_46 nonbiochildsex7_46 nonbiochildsex8_46 nonbiochildsex9_46 nonbiochildsex10_46), values(1)
replace nonbiochildboy_total_46=-10 if anynonbio_46==0 //no non-biologial children
replace nonbiochildboy_total_46=. if (nd7hgdn==0|nd7hgdn==.)
label define nonbiochildboy_total_46 0 "Girls only" -10 "No non-biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values nonbiochildboy_total_46 nonbiochildboy_total_46
label var nonbiochildboy_total_46 "Total number of non-biological children who are boys"
fre nonbiochildboy_total_46 

cap drop nonbiochildgirl_total_46
egen nonbiochildgirl_total_46 = anycount(nonbiochildsex2_46 nonbiochildsex3_46 nonbiochildsex4_46 nonbiochildsex5_46 nonbiochildsex6_46 nonbiochildsex7_46 nonbiochildsex8_46 nonbiochildsex9_46 nonbiochildsex10_46), values(2)
replace nonbiochildgirl_total_46=-10 if anynonbio_46==0 //no non-biologial children
replace nonbiochildgirl_total_46=. if (nd7hgdn==0|nd7hgdn==.)
label define nonbiochildgirl_total_46 0 "Boys only" -10 "No non-biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values nonbiochildgirl_total_46 nonbiochildgirl_total_46
label var nonbiochildgirl_total_46 "Total number of non-biological children who are girls"
fre nonbiochildgirl_total_46 






*************************************************************
**** BIOLOGICAL AND NON BIOLOGICAL CHILDREN (age 46) ****
*************************************************************

***COMPUTE whether has any biological or non-biological (age 46)
cap drop anychildren_46
gen anychildren_46=.
replace anychildren_46=1 if anynonbio_46==1|anybiochildren_46==1
replace anychildren_46=0 if anynonbio_46==0 & anybiochildren_46==0
replace anychildren_46=. if anybiochildren_46==.|anynonbio_46==.
label define anychildren_46 0 "No" 1 "Yes" -100 "no participation in sweep" -99 "information not provided", replace
label values anychildren_46 anychildren_46
label var anychildren_46 "Whether CM has any children (biological or non-biological)"
fre anychildren_46 

***COMPUTE total number of biological and non-biological children (age 46)
cap drop children_tot_46
gen children_tot_46=biochild_tot_46 + nonbiochild_tot_46
fre children_tot_46
label define children_tot_46 0 "No children (biological or non-biological)" -100 "no participation in sweep" -99 "information not provided", replace
label values children_tot_46 children_tot_46
label var children_tot_46 "Total number of children (biological or non-biological)"
fre children_tot_46



***COMPUTE youngest and oldest biological or non-biological children
//create temporary recoded variables (age 46)
foreach X of varlist biochildy_eldest_46 nonbiochildy_eldest_46 biochildy_youngest_46 nonbiochildy_youngest_46 {
cap drop `X'_R
clonevar `X'_R = `X'
replace `X'_R=. if `X'_R==-10	
fre `X'_R
}

cap drop childy_eldest_46 //years
gen childy_eldest_46 = max(biochildy_eldest_46_R, nonbiochildy_eldest_46_R)
replace childy_eldest_46=-10 if anybiochildren_46==0 & anynonbio_46==0
replace childy_eldest_46=. if anybiochildren_46==.|anynonbio_46==.
label define childy_eldest_46 -10 "No children (biological or non-biological)" -100 "no participation in sweep" -99 "information not provided", replace
label values childy_eldest_46 childy_eldest_46
label var childy_eldest_46 "Age in years of eldest child (biological or non biological)"
fre childy_eldest_46

cap drop childy_youngest_46 //years
gen childy_youngest_46 = min(biochildy_youngest_46_R, nonbiochildy_youngest_46_R)
replace childy_youngest_46=-10 if anybiochildren_46==0 & anynonbio_46==0
replace childy_youngest_46=. if anybiochildren_46==.|anynonbio_46==.
label define childy_youngest_46 -10 "No children (biological or non-biological)" -100 "no participation in sweep" -99 "information not provided", replace
label values childy_youngest_46 childy_youngest_46
label var childy_youngest_46 "Age in years of youngest child (biological or non biological)"
fre childy_youngest_46

drop biochildy_eldest_46_R nonbiochildy_eldest_46_R biochildy_youngest_46_R nonbiochildy_youngest_46_R



***COMPUTE total number of male biological or non-biological children (age 46)
foreach X of varlist biochildboy_total_46 biochildgirl_total_46 nonbiochildboy_total_46 nonbiochildgirl_total_46 {
cap drop `X'_R
clonevar `X'_R = `X'
replace `X'_R=0 if `X'_R==-10	
}

fre biochildboy_total_46_R biochildgirl_total_46_R nonbiochildboy_total_46_R nonbiochildgirl_total_46_R

cap drop childboy_total_46
gen childboy_total_46 = biochildboy_total_46_R + nonbiochildboy_total_46_R
replace childboy_total_46=-10 if anybiochildren_46==0 & anynonbio_46==0  //no bio or non-bio children
replace childboy_total_46=. if anybiochildren_46==.|anynonbio_46==.  //no bio or non-bio children

label define childboy_total_46 0 "Girls only" -10 "No children (biological or non-biological)" -100 "no participation in sweep" -99 "information not provided", replace
drop biochildboy_total_46_R  nonbiochildboy_total_46_R
label values childboy_total_46 childboy_total_46
label var childboy_total_46 "Total number of children who are boys (biological or non-biological)"
fre childboy_total_46 


cap drop childgirl_total_46
gen childgirl_total_46 = biochildgirl_total_46_R + nonbiochildgirl_total_46_R
replace childgirl_total_46=-10 if anybiochildren_46==0 & anynonbio_46==0  //no bio or non-bio children
replace childgirl_total_46=. if anybiochildren_46==.|anynonbio_46==.  //no bio or non-bio children
label define childgirl_total_46 0 "Boys only" -10 "No children (biological or non-biological)" -100 "no participation in sweep" -99 "information not provided", replace
drop biochildgirl_total_46_R  nonbiochildgirl_total_46_R
label values childgirl_total_46 childgirl_total_46
label var childgirl_total_46 "Total number of children who are girls (biological or non-biological)"
fre childgirl_total_46 




*************************************************************
****COMPUTE partner child combo (age 46) ****
*************************************************************

//partner and biological children (age 46)
cap drop partnerchildbio_46
gen partnerchildbio_46=.
replace partnerchildbio_46=1 if anybiochildren_46==0 & partner_46==0 //no partner and no children
replace partnerchildbio_46=2 if anybiochildren_46==0 & partner_46==1 //partner but no children
replace partnerchildbio_46=3 if anybiochildren_46==1 & partner_46==0 //no partner but children
replace partnerchildbio_46=4 if anybiochildren_46==1 & partner_46==1 //partner and children
label define partnerchildbio_46 1 "No partner or children" 2 "Partner and no children" 3 "Children and no partner" 4 "Partner and children" -100 "no participation in sweep" -99 "information not provided", replace
label values partnerchildbio_46 partnerchildbio_46
label var partnerchildbio_46 "Whether has partner and/or any biological children"
fre partnerchildbio_46


//partner and any bio or nonbio children (age 46)
cap drop partnerchildany_46
gen partnerchildany_46=.
replace partnerchildany_46=1 if anychildren_46==0 & partner_46==0 //no partner and no children
replace partnerchildany_46=2 if anychildren_46==0 & partner_46==1 //partner but no children
replace partnerchildany_46=3 if anychildren_46==1 & partner_46==0 //no partner but children
replace partnerchildany_46=4 if anychildren_46==1 & partner_46==1 //partner and children
label define partnerchildany_46 1 "No partner or children" 2 "Partner and no children" 3 "Children and no partner" 4 "Partner and children" -100 "no participation in sweep" -99 "information not provided", replace
label values partnerchildany_46 partnerchildany_46
label var partnerchildany_46 "Whether has partner and/or any biological or non biological children"
fre partnerchildany_46

*************************************************************


save "$derived\NCDS_fertility_age23_46.dta", replace 
use "$derived\NCDS_fertility_age23_46.dta", clear





**# Bookmark #5
**************************************************************************
**************************************************************************
******************* AGE 50 ***********************************************
**************************************************************************
**************************************************************************

*****NCDS FERTILITY*****

****************************************************************************
//NCDS AGE 50 (2008, SWEEP 8)
use "$raw\ncds_2008_followup", clear
//N=9,790


keep NCDSID ND8SPPHH ND8MS N8HMS N8MS N8INTMON N8INTYR ND8ALHH N8EVERPG N8PREG11 N8PREG12 N8PREG13 N8PREG21 N8PREG22 N8PREG23 N8PREG31 N8PREG32 N8PREG41 N8PREG51 N8PREG61 N8PREG71 N8PREG81 N8LHHN11 N8LHHN12 N8LHHN13 N8LHHN21 N8LHHN22 N8LHHN23 N8LHHN31 N8LHHN32 N8LHHN33 N8LHHN41 N8LHHN42 N8LHHN43 N8LHHN51 N8LHHN52 N8LHHN53 N8LHHN61 N8LHHN62 N8LHHN63 N8LHHN71 N8LHHN72 N8LHHN73 N8LHHN81 N8LHHN82 N8LHHN83 N8PRGC11 N8PRGC12 N8PRGC13 N8PRGC21 N8PRGC22 N8PRGC23 N8PRGC31 N8PRGC32 N8PRGC33 N8PRGC41 N8PRGC42 N8PRGC43 N8PRGC51 N8PRGC52 N8PRGC53 N8PRGC61 N8PRGC62 N8PRGC63 N8PRGC71 N8PRGC72 N8PRGC73 N8PRGC81 N8PRGC82 N8PRGC83 N8PRGM11 N8PRGM12 N8PRGM13 N8PRGM21 N8PRGM22 N8PRGM23 N8PRGM31 N8PRGM32 N8PRGM33 N8PRGM41 N8PRGM42 N8PRGM43 N8PRGM51 N8PRGM52 N8PRGM53 N8PRGM61 N8PRGM62 N8PRGM63 N8PRGM71 N8PRGM72 N8PRGM73 N8PRGM81 N8PRGM82 N8PRGM83 N8PRGY11 N8PRGY12 N8PRGY13 N8PRGY21 N8PRGY22 N8PRGY23 N8PRGY31 N8PRGY32 N8PRGY33 N8PRGY41 N8PRGY42 N8PRGY43 N8PRGY51 N8PRGY52 N8PRGY53 N8PRGY61 N8PRGY62 N8PRGY63 N8PRGY71 N8PRGY72 N8PRGY73 N8PRGY81 N8PRGY82 N8PRGY83 N8LINE12 N8LINE13 N8LINE14 N8LINE15 N8LINE16 N8LINE17 N8LINE18 N8LINE19 N8LINE20 N8LINE21 N8LINE22 N8CHHM12 N8CHHM13 N8CHHM14 N8CHHM15 N8CHHM16 N8CHHM17 N8CHHM18 N8CHHM19 N8CHHM20 N8CHHM21 N8CHHM22 N8NAMH12 N8NAMH13 N8NAMH14 N8NAMH15 N8NAMH16 N8NAMH17 N8NAMH18 N8NAMH19 N8NAMH20 N8NAMH21 N8NAMH22 N8SEX12 N8SEX13 N8SEX14 N8SEX15 N8SEX16 N8SEX17 N8SEX18 N8SEX19 N8SEX20 N8SEX21 N8SEX22 N8RAGE12 N8RAGE13 N8RAGE14 N8RAGE15 N8RAGE16 N8RAGE17 N8RAGE18 N8RAGE19 N8RAGE20 N8RAGE21 N8RAGE22 N8RTOK12 N8RTOK13 N8RTOK14 N8RTOK15 N8RTOK16 N8RTOK17 N8RTOK18 N8RTOK19 N8RTOK20 N8RTOK21 N8RTOK22 N8WHYL12 N8WHYL13 N8WHYL14 N8WHYL15 N8WHYL16 N8WHYL17 N8WHYL18 N8WHYL19 N8WHYL20 N8WHYL21 N8WHYL22 ND8NCHHH ND8OCHHH ND8NCHAB ND8OCHAB ND8NCHTT N8ABMO15 N8ABMO16 N8ABMO17 N8ABMO18 N8ABMO19 N8ABMO20 N8ABMO21 N8ABMO22 N8ABMO23


*--------------------------------------------------------*

gen NCDSAGE50SURVEY=1
label var NCDSAGE50SURVEY "Whether took part in age 50 survey"

//OTHER

//HH grid available (age 50)
fre ND8ALHH
cap drop HHgrid
gen HHgrid=.
replace HHgrid=1 if ND8ALHH==1|ND8ALHH==2
fre HHgrid


//interview date (age 50)
fre N8INTYR
cap drop intyear
gen intyear = N8INTYR
label var intyear "Interview year (age 50)"
label define intyear -100 "no participation in sweep" -99 "information not provided", replace
label values intyear intyear
fre intyear

fre N8INTMON 
cap drop intmonth
gen intmonth = N8INTMON
label var intmonth "Interview month (age 50)"
label define intmonth 1 "January" 2	"February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "	October" 11 "November" 12 "December" -100 "no participation in sweep" -99 "information not provided", replace
label values intmonth intmonth
fre intmonth


//whether has a partner or spouse living in household (age 50)
fre  ND8SPPHH //0=no 1=yes -6=didn't complete HH grid
cap drop partner
gen partner=ND8SPPHH
replace partner=. if ND8SPPHH== -6
label var partner "Whether CM has current partner in hhld (age 50)"
label define partner 0 "No" 1 "Yes" -100 "no participation in sweep" -99 "information not provided", replace
label values partner partner
fre partner


//marital status (age 50)
fre ND8MS
cap drop marital
gen marital=.
replace marital=3 if (ND8MS==1|ND8MS==4|ND8MS==5|ND8MS==6|ND8MS==7|ND8MS==8|ND8MS==9) & partner==0
replace marital=2 if (ND8MS==1|ND8MS==4|ND8MS==5|ND8MS==6|ND8MS==7|ND8MS==8|ND8MS==9) & partner==1
replace marital=1 if ND8MS==2|ND8MS==3
label define marital 3 "Single non-cohabiting" 2 "Single cohabiting with partner" 1 "Married" -100 "no participation in sweep" -99 "information not provided", replace
label values marital marital
label variable marital "Marital status (age 50)" 
fre marital //32 missing as this is missing iformation on whether living with partner



*--------------------------------------------------------*
//RENAMING VARIABLES

***PREGNANCIES

//outcome of pregnancy (age 50)
rename (N8PREG11 N8PREG12 N8PREG13 N8PREG21 N8PREG22 N8PREG23 N8PREG31 N8PREG32 N8PREG41 N8PREG51 N8PREG61 N8PREG71 N8PREG81) (prego11 prego12 prego13 prego21 prego22 prego23 prego31 prego32 prego41 prego51 prego61 prego71 prego81)

//person number hh grid (age 50)
rename (N8LHHN11 N8LHHN12 N8LHHN13 N8LHHN21 N8LHHN22 N8LHHN23 N8LHHN31 N8LHHN32 N8LHHN41 N8LHHN51 N8LHHN61 N8LHHN71  N8LHHN81) (pnum11 pnum12 pnum13 pnum21 pnum22 pnum23 pnum31 pnum32 pnum41 pnum51 pnum61 pnum71  pnum81)

//sex (age 50)
rename (N8PRGC11 N8PRGC12 N8PRGC13 N8PRGC21 N8PRGC22 N8PRGC23 N8PRGC31 N8PRGC32 N8PRGC41 N8PRGC51 N8PRGC61 N8PRGC71 N8PRGC81) (pregs11 pregs12 pregs13 pregs21 pregs22 pregs23 pregs31 pregs32 pregs41 pregs51 pregs61 pregs71 pregs81)

//month of birth (age 50)
rename (N8PRGM11 N8PRGM12 N8PRGM13 N8PRGM21 N8PRGM22 N8PRGM23 N8PRGM31 N8PRGM32 N8PRGM41 N8PRGM51 N8PRGM61 N8PRGM71 N8PRGM81) (pregm11 pregm12 pregm13 pregm21 pregm22 pregm23 pregm31 pregm32 pregm41 pregm51 pregm61 pregm71 pregm81)

//year of birth (age 50)
rename (N8PRGY11 N8PRGY12 N8PRGY13 N8PRGY21 N8PRGY22 N8PRGY23 N8PRGY31 N8PRGY32 N8PRGY41 N8PRGY51 N8PRGY61 N8PRGY71 N8PRGY81) (pregy11 pregy12 pregy13 pregy21 pregy22 pregy23 pregy31 pregy32 pregy41 pregy51 pregy61 pregy71 pregy81)




***HH GRID

//relationsip to HH member (age 50)
rename (N8RTOK12 N8RTOK13 N8RTOK14 N8RTOK15 N8RTOK16 N8RTOK17 N8RTOK18 N8RTOK19 N8RTOK20 N8RTOK21 N8RTOK22)(hhrel02 hhrel03 hhrel04 hhrel05 hhrel06 hhrel07 hhrel08 hhrel09 hhrel10 hhrel11 hhrel12)

//sex (age 50)
rename (N8SEX12 N8SEX13 N8SEX14 N8SEX15 N8SEX16 N8SEX17 N8SEX18 N8SEX19 N8SEX20 N8SEX21 N8SEX22) (hhsex02 hhsex03 hhsex04 hhsex05 hhsex06 hhsex07 hhsex08 hhsex09 hhsex10 hhsex11 hhsex12)

//age (age 50)
rename (N8RAGE12 N8RAGE13 N8RAGE14 N8RAGE15 N8RAGE16 N8RAGE17 N8RAGE18 N8RAGE19 N8RAGE20 N8RAGE21 N8RAGE22) (hhage02 hhage03 hhage04 hhage05 hhage06 hhage07 hhage08 hhage09 hhage10 hhage11 hhage12)

//HH member number (age 50)
rename (N8LINE12 N8LINE13 N8LINE14 N8LINE15 N8LINE16 N8LINE17 N8LINE18 N8LINE19 N8LINE20 N8LINE21 N8LINE22) (hhnum02 hhnum03 hhnum04 hhnum05 hhnum06 hhnum07 hhnum08 hhnum09 hhnum10 hhnum11 hhnum12)

//HH member status (whether still in HH, new in HH, nolonger in HH ) (age 50)
rename (N8CHHM12 N8CHHM13 N8CHHM14 N8CHHM15 N8CHHM16 N8CHHM17 N8CHHM18 N8CHHM19 N8CHHM20 N8CHHM21 N8CHHM22) (hhstatus02 hhstatus03 hhstatus04 hhstatus05 hhstatus06 hhstatus07 hhstatus08 hhstatus09 hhstatus10 hhstatus11 hhstatus12)

//whether still lives in HH (age 50)
rename (N8NAMH12 N8NAMH13 N8NAMH14 N8NAMH15 N8NAMH16 N8NAMH17 N8NAMH18 N8NAMH19 N8NAMH20 N8NAMH21 N8NAMH22) (hhwhere02 hhwhere03 hhwhere04 hhwhere05 hhwhere06 hhwhere07 hhwhere08 hhwhere09 hhwhere10 hhwhere11 hhwhere12)

//what happend to HH member (dead, living elsewhere, not applicable) (age 50)
rename (N8WHYL12 N8WHYL13 N8WHYL14 N8WHYL15 N8WHYL16 N8WHYL17 N8WHYL18 N8WHYL19 N8WHYL20 N8WHYL21 N8WHYL22) (hhwhat02 hhwhat03 hhwhat04 hhwhat05 hhwhat06 hhwhat07 hhwhat08 hhwhat09 hhwhat10 hhwhat11 hhwhat12)



*************************BIOLOGICAL CHILDREN (age 50)*********************************

//pregnancies since last interviewed (which could be any time since age 16)
fre N8EVERPG
cap drop pregsincelast
clonevar pregsincelast = N8EVERPG
replace pregsincelast=. if pregsincelast<0
replace pregsincelast=0 if pregsincelast==2
fre pregsincelast 


*RECODE variables  
foreach C in 11 12 13 21 22 23 31 32 41 51 61 71 81 {
foreach X of varlist pregs`C' pregm`C' pregy`C' pnum`C' {

replace	`X'=. if prego`C'!=1 //recode all to missing if not a live birth

replace prego`C'=. if prego`C'!=1|pregsincelast==.
label define prego`C' 1 "Live birth", replace
label values prego`C' prego`C'
fre pregs`C' pregm`C' pregy`C' 

//recode to missing and other adjustments

replace	pregs`C'=. if pregs`C'<0

replace	pregm`C'=. if pregm`C'<0

replace	pregy`C'=. if pregy`C'<0

fre prego`C' pregs`C' pregm`C' pregy`C' pnum`C'

}
}
 

*---------------------------------------------------*

//ADDING SUFFIX 50 BEFORE MERGING WITH PREVIOUS SWEEP
foreach var of varlist _all {	
rename `var' `var'_50		
if inlist("`var'", "skip_ncdsid") {				
}
}

rename NCDSID_50 ncdsid
 

*------------------------------------------------------------------------*
//MERGING ON PREVIOUS SWEEPS AS WE NEED TO ADD NEW CHILDREN TO PREVIOUS ONES, ALL DEPENDING ON WHEN THEY LAST TOOK PART.

merge 1:1 ncdsid using "$derived\NCDS_fertility_age23_46.dta"
drop _merge

save "$derived\NCDS_fertility_age23_50.dta", replace 
use "$derived\NCDS_fertility_age23_50.dta", clear





*-------------------------------------------------------------------*
***COMPUTE current age in whole years of each biochild from birth year and month, and interview month and year. And age of cohort member at birth of child in whole years and in months as well.
//we do this bit first to identify children who may have been reported both at age 33, age 42, and age 46.


//interview date (age 50)
cap drop intym_50
gen intym_50 = ym(intyear_50,intmonth_50)
label var intym_50 "Interview date - months since Jan 1960"
fre intym_50

//cohort member birthdate (age 50)
cap drop cmbirthy_50
gen cmbirthy_50=1958
label var cmbirthy_50 "Birth year of CM"
fre cmbirthy_50

cap drop cmbirthm_50
gen cmbirthm_50=3
label var cmbirthm_50 "Birth month of CM"
fre cmbirthm_50

cap drop cmbirthym_50
gen cmbirthym_50 = ym(cmbirthy_50,cmbirthm_50)
label var cmbirthym_50 "CM birth date - months since Jan 1960"
fre cmbirthym_50

//CM age in years (age 50)
cap drop cmagey_50
gen cmagey_50=(intym_50-cmbirthym_50)/12
replace cmagey_50 = floor(cmagey_50)
label var cmagey_50 "CM age at interview"
fre cmagey_50 





//***AGE 50 CHILDREN: children since last interview (reported at age 50)
foreach C in 11 12 13 21 22 23 31 32 41 51 61 71 81 {

cap drop biochildym`C'_50
gen biochildym`C'_50 = ym(pregy`C'_50,pregm`C'_50) 
label var biochildym`C'_50 "`C' Date of birth of biological child - months since Jan 1960"
fre biochildym`C'_50

//child's age in whole years at interview
cap drop biochildagey`C'_50
gen biochildagey`C'_50 = (intym_50-biochildym`C'_50)/12
fre biochildagey`C'_50
replace biochildagey`C'_50 = floor(biochildagey`C'_50)
label var biochildagey`C'_50 "`C' Age in whole years of biological child"
fre biochildagey`C'_50

//cm age in whole years at birth of child
cap drop cmageybirth`C'_50
gen cmageybirth`C'_50 = (biochildym`C'_50-cmbirthym_50)/12
fre cmageybirth`C'_50
replace cmageybirth`C'_50 = floor(cmageybirth`C'_50)
label var cmageybirth`C'_50 "`C' Age of CM in years at birth of biological child `C'"
fre cmageybirth`C'_50

}





*** ADJUSTING AGE OF PREVIOUSLY REPORTED CHILDREN TO DATE OF INTERVIEW (age 50)

*** AGE 23 CHILDREN: children reported previously at age 23
foreach C in 1_23 2_23 3_23 4_23 {

//child's age in whole years at interview
cap drop biochildagey`C'
gen biochildagey`C' = (intym_50-biochildym`C')/12
fre biochildagey`C'
replace biochildagey`C' = floor(biochildagey`C')
label var biochildagey`C' "`C' Age in whole years of biological child"
fre biochildagey`C'
}

//***AGE 33 CHILDREN: children reported previously at age 33
foreach C in 1 2 3 4 5 6 7 8 9 {

//child's age in whole years at interview
cap drop biochildagey`C'_33
gen biochildagey`C'_33 = (intym_50-biochildym`C'_33)/12
fre biochildagey`C'_33
replace biochildagey`C'_33 = floor(biochildagey`C'_33)
label var biochildagey`C'_33 "`C' Age in whole years of biological child"
fre biochildagey`C'_33

}

//***AGE 42 CHILDREN: children since 1991 (reported at age 42)
foreach C in 1 2 3 4 5 6 7 8 11 12 16 17 21 22 26 31 36 {

//child's age in whole years at interview
cap drop biochildagey`C'_42
gen biochildagey`C'_42 = (intym_50-biochildym`C'_42)/12
fre biochildagey`C'_42
replace biochildagey`C'_42 = floor(biochildagey`C'_42)
label var biochildagey`C'_42 "`C' Age in whole years of biological child"
fre biochildagey`C'_42

}


//***AGE 46 CHILDREN: children since last interview (reported at age 46)
foreach C in 11 12 13 21 22 31 41 51 61 {

//child's age in whole years at interview
cap drop biochildagey`C'_46
gen biochildagey`C'_46 = (intym_50-biochildym`C'_46)/12
fre biochildagey`C'_46
replace biochildagey`C'_46 = floor(biochildagey`C'_46)
label var biochildagey`C'_46 "`C' Age in whole years of biological child"
fre biochildagey`C'_46
}





*------------------------------------------------------------------------*

*-------------------------------------------------------------------*
*** WHETHER HAS HAD ANY BIOLOGICAL CHILDREN AND TOTAL NUMBER (age 50)

***COMPUTE whether ever had any biological children (live births) since last interview (age 50)

//this is just temporary as these will be added to last interview
cap drop anybiochildren_50
egen anybiochildren_50=anycount(prego11_50 prego12_50 prego13_50 prego21_50 prego22_50 prego23_50 prego31_50 prego32_50 prego41_50 prego51_50 prego61_50 prego71_50 prego81_50), values(1)
replace anybiochildren_50=1 if inrange(anybiochildren_50,1,20)
replace anybiochildren_50=. if pregsincelast_50==.
fre anybiochildren_50 //N=9,761, 4% have new children 



//Figuring out which data to add the new children to (age 50)

*A.since sweep 46
cap drop preg_46_50
gen preg_46_50=.
replace preg_46_50=1 if anybiochildren_46!=. & anybiochildren_50!=.
fre preg_46_50 //N 8237

cap drop sweep46_50
gen sweep46_50=.
replace sweep46_50=1 if NCDSAGE46SURVEY_46!=. & NCDSAGE50SURVEY_50!=.
fre sweep46_50 //N=8399


*B.since sweep 42
cap drop preg_42_50
gen preg_42_50=.
replace preg_42_50=1 if anybiochildren_42!=. & anybiochildren_46==. & anybiochildren_50!=.
fre preg_42_50 //N=986

cap drop sweep42_50
gen sweep42_50=.
replace sweep42_50=1 if NCDSAGE42SURVEY_42!=. & NCDSAGE46SURVEY_46==. & NCDSAGE50SURVEY_50!=.
fre sweep42_50 //N=1019


*C.since sweep 33
cap drop preg_33_50
gen preg_33_50=.
replace preg_33_46=1 if anybiochildren_33!=. & anybiochildren_42==. & anybiochildren_46==. & anybiochildren_50!=.
fre preg_33_50 //N=0

cap drop sweep33_50
gen sweep33_50=.
replace sweep33_50=1 if NCDSAGE33SURVEY_33!=. & NCDSAGE42SURVEY_42==. & NCDSAGE46SURVEY_46==. & NCDSAGE50SURVEY_50!=.
fre sweep33_50 //N=143


*D.since sweep 23
cap drop preg_23_50
gen preg_23_50=.
replace preg_23_50=1 if anybiochildren_23!=. & anybiochildren_33==. & anybiochildren_42==. & anybiochildren_46==. & anybiochildren_50!=.
fre preg_23_50 //N=238

cap drop sweep23_50
gen sweep23_50=.
replace sweep23_50=1 if NCDSAGE23SURVEY_23!=. & NCDSAGE33SURVEY_33==. & NCDSAGE42SURVEY_42==. & NCDSAGE46SURVEY_46==.  & NCDSAGE50SURVEY_50!=.
fre sweep23_50 //N=92


*E.since sweep 16
cap drop preg_16_50
gen preg_16_50=.
replace preg_16_50=1 if anybiochildren_23==. & anybiochildren_33==. & anybiochildren_42==. & anybiochildren_46==. & anybiochildren_50!=.
fre preg_16_50 //N=162

cap drop sweep16_50
gen sweep16_50=.
replace sweep16_50=1 if NCDSAGE23SURVEY_23==. & NCDSAGE33SURVEY_33==. & NCDSAGE42SURVEY_42==. & NCDSAGE46SURVEY_46==. & NCDSAGE50SURVEY_50!=.
fre sweep16_50 //N=137


//note above we have variables that specify which data we should be adding the children reported at age 50 to. Note we have split these into 5 groups. So we need to do 5 parts in code below.



***COMPUTE total number of biological children (age 50)

//since age 46
cap drop biochild_total_A
egen biochild_total_A =anycount(prego11_50 prego12_50 prego13_50 prego21_50 prego22_50 prego23_50 prego31_50 prego32_50 prego41_50 prego51_50 prego61_50 prego71_50 prego81_50), values(1)
replace biochild_total_A=. if sweep46_50==.|preg_46_50==. 
replace biochild_total_A=biochild_total_A + biochild_tot_46
fre biochild_total_A //N=7237

//since age 42
cap drop biochild_total_B
egen biochild_total_B =anycount(prego11_50 prego12_50 prego13_50 prego21_50 prego22_50 prego23_50 prego31_50 prego32_50 prego41_50 prego51_50 prego61_50 prego71_50 prego81_50), values(1)
replace biochild_total_B=. if sweep42_50==.|preg_42_50==. 
replace biochild_total_B=biochild_total_B + biochild_tot_42
fre biochild_total_B //N=982

//since age 33
cap drop biochild_total_C
egen biochild_total_C =anycount(prego11_50 prego12_50 prego13_50 prego21_50 prego22_50 prego23_50 prego31_50 prego32_50 prego41_50 prego51_50 prego61_50 prego71_50 prego81_50), values(1)
replace biochild_total_C=. if sweep33_50==.|preg_33_50==. 
replace biochild_total_C= biochild_total_C + biochild_tot_33
fre biochild_total_C //N=0

//since age 23
cap drop biochild_total_D
egen biochild_total_D =anycount(prego11_50 prego12_50 prego13_50 prego21_50 prego22_50 prego23_50 prego31_50 prego32_50 prego41_50 prego51_50 prego61_50 prego71_50 prego81_50), values(1)
replace biochild_total_D=. if sweep23_50==.|preg_23_50==. 
replace biochild_total_D= biochild_total_D + biochild_tot_23
fre biochild_total_D //N=90

//since age 16
cap drop biochild_total_E
egen biochild_total_E =anycount(prego11_50 prego12_50 prego13_50 prego21_50 prego22_50 prego23_50 prego31_50 prego32_50 prego41_50 prego51_50 prego61_50 prego71_50 prego81_50), values(1)
replace biochild_total_E=. if sweep16_50==.|preg_16_50==. 
replace biochild_total_E= biochild_total_E
fre biochild_total_E //N=135




// COMPUTE age 50 total children
fre biochild_total_A biochild_total_B biochild_total_C biochild_total_D biochild_total_E

cap drop included
gen included=.
replace included=1 if biochild_total_A!=.
replace included=1 if biochild_total_B!=.
replace included=1 if biochild_total_C!=.
replace included=1 if biochild_total_D!=.
replace included=1 if biochild_total_E!=.
fre included //N=9,444

cap drop biochild_tot_50
egen biochild_tot_50=rowtotal(biochild_total_A biochild_total_B biochild_total_C biochild_total_D biochild_total_E)
replace biochild_tot_50=. if include==.
fre biochild_tot_50
label define biochild_tot_50 0 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values biochild_tot_50 biochild_tot_50
label variable biochild_tot_50 "Total number of biological children"
fre biochild_tot_50 



*-----------------------------------------------------*
*** CHECKING EXTRA BIOLOGICAL CHILDREN IN HOUSEHOLD NOT REPORTED AS PREGNANCY (age 50)

***COMPUTE total number of biological children reported in hh grid (age 50)

//we have to use HH grid data for this as pregnancy data will only include current location of the new children, whereas children reported in pregnancy data previously will not have up to date information of where they live.

cap drop biochildhh_total_50
egen biochildhh_total_50 = anycount(hhrel02_50 hhrel03_50 hhrel04_50 hhrel05_50 hhrel06_50 hhrel07_50 hhrel08_50 hhrel09_50 hhrel10_50 hhrel11_50 hhrel12_50), values(4) //4=own child
replace biochildhh_total_50=. if (NCDSAGE50SURVEY_50==.|HHgrid_50==.)
 //code to missing if not in age 50 sweep or didn't complete HH grid.
label variable biochildhh_total_50 "Total number of biological children in HH grid age 46"   
fre biochildhh_total_50

clonevar biohhgrid_total_50 = biochildhh_total_50 //creating a variable for the original hhgrid total number of bio children




//computing difference in pregnancy data and household data

cap drop biochild_tot_miss_50
gen biochild_tot_miss_50=1 if biochild_tot_50==. //this creates a missing values flag for this variable

replace biochild_tot_50=0 if biochild_tot_50==. //@@@ this bit is important as crucial for the inclusion of all HH grid data in adjustments for extra children 

fre biochild_tot_50 biochildhh_total_50
tab biochild_tot_50 biochildhh_total_50, mi
cap drop difference_50
gen difference_50=biochild_tot_50 - biochildhh_total_50
fre difference_50


//creating a variable that flags CMs with differences
cap drop biochild_extra_flag_50
gen biochild_extra_flag_50=.
label var biochild_extra_flag_50 "Flag: More bio children reported in HH grid than in pregnancy data"
replace biochild_extra_flag_50=1 if inrange(difference_50, -10,-1)
replace biochild_extra_flag_50=0 if inrange(difference_50, 0,20)
label define biochild_extra_flag_50 1 "Yes" 0 "No" -100 "no participation in sweep" -99 "information not provided", replace
label values biochild_extra_flag_50 biochild_extra_flag_50
fre biochild_extra_flag_50 //applies to 850 CMs 

//creating variable to use for adjustment of total children
cap drop bioextra_50
gen bioextra_50=difference_50
replace bioextra_50=0 if inrange(difference_50,0,10)
replace bioextra_50=1 if difference_50==-1
replace bioextra_50=2 if difference_50==-2
replace bioextra_50=3 if difference_50==-3
replace bioextra_50=4 if difference_50==-4
replace bioextra_50=5 if difference_50==-5
replace bioextra_50=6 if difference_50==-6
replace bioextra_50=7 if difference_50==-7
fre bioextra_50



******ADJUSTING (age 50)
cap drop bioextra_miss_50
gen bioextra_miss_50=1 if bioextra_50==. //missing values flag 
fre bioextra_miss_50
replace bioextra_50=0 if bioextra_50==.

fre biochild_tot_miss_50 //already created a missing flag for this

//TOTAL NUMBER OF CHILDREN (age 50)
fre biochild_tot_50 bioextra_50
replace biochild_tot_50=biochild_tot_50 + bioextra_50
replace biochild_tot_50=. if biochild_tot_miss_50== 1 //& bioextra_miss_50==1
fre biochild_tot_50

//ANY BIO CHILDREN (age 50)
cap drop anybiochildren_50
gen anybiochildren_50=.
replace anybiochildren_50=1 if inrange(biochild_tot_50,1,20)
replace anybiochildren_50=0 if biochild_tot_50==0
fre anybiochildren_50
label variable anybiochildren_50 "Whether CM has had any biological children age 50"
label define yesno 0 "No" 1 "Yes" -100 "no participation in sweep" -99 "information not provided", replace
label values anybiochildren_50 yesno
fre anybiochildren_50 
fre anybiochildren_46


//WHERE LIVE (age 50)

*in household (age 50)
fre biochildhh_total_50
label variable biochildhh_total_50 "Total number of bio children in household age 50"
fre biochildhh_total_50

*not in household (age 50)
fre biochild_tot_50 biochildhh_total_50 
cap drop biochildnonhh_total_50
gen biochildnonhh_total_50= biochild_tot_50-biochildhh_total_50 
replace biochildnonhh_total_50=-10 if anybiochildren_50==0
label variable biochildnonhh_total_50 "Total number of bio children not in household age 50"
fre biochildnonhh_total_50
label define biochildnonhh_total_50 0 "All biological children live in household" -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildnonhh_total_50 biochildnonhh_total_50
fre biochildnonhh_total_50

*coding values for previous variable (age 50)
replace biochildhh_total_50=-10 if anybiochildren_50==0
replace biochildhh_total_50=. if anybiochildren_50==.
label define biochildhh_total_50 -10 "No biological children" 0 "None of the biological children live in household" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildhh_total_50 biochildhh_total_50




*******************************************************
*** OTHER PARENT OF CHILDREN IS CURRENT PARTNER (age 50)
*******************************************************
*** we cannot derive




****************************************************
*** SEX OF BIOLOGICAL CHILDREN (age 50)
****************************************************
//sex 1=boy 2=girl


*-------------------*
***COMPUTE total number of biological BOYS (age 50)

//recoding -10 to 0 so we can add them

cap drop Rbiochildboy_total_46
clonevar Rbiochildboy_total_46 = biochildboy_total_46
replace Rbiochildboy_total_46=0 if Rbiochildboy_total_46==-10

cap drop Rbiochildboy_total_42
clonevar Rbiochildboy_total_42 = biochildboy_total_42
replace Rbiochildboy_total_42=0 if Rbiochildboy_total_42==-10

cap drop Rbiochildboy_total_33
clonevar Rbiochildboy_total_33 = biochildboy_total_33
replace Rbiochildboy_total_33=0 if Rbiochildboy_total_33==-10

cap drop Rbiochildboy_total_23
clonevar Rbiochildboy_total_23 = biochildboy_total_23
replace Rbiochildboy_total_23=0 if Rbiochildboy_total_23==-10


*ADDING AGE 50 BOYS TO THE APPROPRIATE SWEEP

//since age 46
cap drop biochildboy_total_A
egen biochildboy_total_A =anycount(pregs11_50 pregs12_50 pregs13_50 pregs21_50 pregs22_50 pregs23_50 pregs31_50 pregs32_50 pregs41_50 pregs51_50 pregs61_50 pregs71_50 pregs81_50), values(1)
replace biochildboy_total_A=. if sweep46_50==.|preg_46_50==. 
replace biochildboy_total_A=biochildboy_total_A + Rbiochildboy_total_46
fre biochildboy_total_A //N=7134

//since age 42
cap drop biochildboy_total_B
egen biochildboy_total_B =anycount(pregs11_50 pregs12_50 pregs13_50 pregs21_50 pregs22_50 pregs23_50 pregs31_50 pregs32_50 pregs41_50 pregs51_50 pregs61_50 pregs71_50 pregs81_50), values(1)
replace biochildboy_total_B=. if sweep42_50==.|preg_42_50==. 
replace biochildboy_total_B=biochildboy_total_B + Rbiochildboy_total_42
fre biochildboy_total_B //N=791

//since age 33
cap drop biochildboy_total_C
egen biochildboy_total_C =anycount(pregs11_50 pregs12_50 pregs13_50 pregs21_50 pregs22_50 pregs23_50 pregs31_50 pregs32_50 pregs41_50 pregs51_50 pregs61_50 pregs71_50 pregs81_50), values(1)
replace biochildboy_total_C=. if sweep33_50==.|preg_33_50==. 
replace biochildboy_total_C= biochildboy_total_C + Rbiochildboy_total_33
fre biochildboy_total_C //N=0

//since age 23
cap drop biochildboy_total_D
egen biochildboy_total_D =anycount(pregs11_50 pregs12_50 pregs13_50 pregs21_50 pregs22_50 pregs23_50 pregs31_50 pregs32_50 pregs41_50 pregs51_50 pregs61_50 pregs71_50 pregs81_50), values(1)
replace biochildboy_total_D=. if sweep23_50==.|preg_23_50==. 
replace biochildboy_total_D= biochildboy_total_D + Rbiochildboy_total_23
fre biochildboy_total_D //N=90

//since age 16
cap drop biochildboy_total_E
egen biochildboy_total_E =anycount(pregs11_50 pregs12_50 pregs13_50 pregs21_50 pregs22_50 pregs23_50 pregs31_50 pregs32_50 pregs41_50 pregs51_50 pregs61_50 pregs71_50 pregs81_50), values(1)
replace biochildboy_total_E=. if sweep16_50==.|preg_16_50==. 
replace biochildboy_total_E= biochildboy_total_E
fre biochildboy_total_E //N=135


// COMPUTE age 50 total boys
fre biochildboy_total_A biochildboy_total_B biochildboy_total_C biochildboy_total_D biochildboy_total_E

cap drop biochildboy_total_50
egen biochildboy_total_50=rowtotal(biochildboy_total_A biochildboy_total_B biochildboy_total_C biochildboy_total_D biochildboy_total_E)
replace biochildboy_total_50=. if included==.
replace biochildboy_total_50=-10 if anybiochildren_50==0
label define biochildboy_total_50 0 "Girls only" -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values biochildboy_total_50 biochildboy_total_50
label variable biochildboy_total_50 "Total number of biological boys"
fre biochildboy_total_50






*-------------------*
***COMPUTE total number of biological girlS (age 50)

//recoding -10 to 0 so we can add them

cap drop Rbiochildgirl_total_46
clonevar Rbiochildgirl_total_46 = biochildgirl_total_46
replace Rbiochildgirl_total_46=0 if Rbiochildgirl_total_46==-10

cap drop Rbiochildgirl_total_42
clonevar Rbiochildgirl_total_42 = biochildgirl_total_42
replace Rbiochildgirl_total_42=0 if Rbiochildgirl_total_42==-10

cap drop Rbiochildgirl_total_33
clonevar Rbiochildgirl_total_33 = biochildgirl_total_33
replace Rbiochildgirl_total_33=0 if Rbiochildgirl_total_33==-10

cap drop Rbiochildgirl_total_23
clonevar Rbiochildgirl_total_23 = biochildgirl_total_23
replace Rbiochildgirl_total_23=0 if Rbiochildgirl_total_23==-10


*ADDING AGE 50 GIRLS TO THE APPROPRIATE SWEEP

//since age 46
cap drop biochildgirl_total_A
egen biochildgirl_total_A =anycount(pregs11_50 pregs12_50 pregs13_50 pregs21_50 pregs22_50 pregs23_50 pregs31_50 pregs32_50 pregs41_50 pregs51_50 pregs61_50 pregs71_50 pregs81_50), values(2)
replace biochildgirl_total_A=. if sweep46_50==.|preg_46_50==. 
replace biochildgirl_total_A=biochildgirl_total_A + Rbiochildgirl_total_46
fre biochildgirl_total_A //N=7134

//since age 42
cap drop biochildgirl_total_B
egen biochildgirl_total_B =anycount(pregs11_50 pregs12_50 pregs13_50 pregs21_50 pregs22_50 pregs23_50 pregs31_50 pregs32_50 pregs41_50 pregs51_50 pregs61_50 pregs71_50 pregs81_50), values(2)
replace biochildgirl_total_B=. if sweep42_50==.|preg_42_50==. 
replace biochildgirl_total_B=biochildgirl_total_B + Rbiochildgirl_total_42
fre biochildgirl_total_B //N=791

//since age 33
cap drop biochildgirl_total_C
egen biochildgirl_total_C =anycount(pregs11_50 pregs12_50 pregs13_50 pregs21_50 pregs22_50 pregs23_50 pregs31_50 pregs32_50 pregs41_50 pregs51_50 pregs61_50 pregs71_50 pregs81_50), values(2)
replace biochildgirl_total_C=. if sweep33_50==.|preg_33_50==. 
replace biochildgirl_total_C= biochildgirl_total_C + Rbiochildgirl_total_33
fre biochildgirl_total_C //N=0

//since age 23
cap drop biochildgirl_total_D
egen biochildgirl_total_D =anycount(pregs11_50 pregs12_50 pregs13_50 pregs21_50 pregs22_50 pregs23_50 pregs31_50 pregs32_50 pregs41_50 pregs51_50 pregs61_50 pregs71_50 pregs81_50), values(2)
replace biochildgirl_total_D=. if sweep23_50==.|preg_23_50==. 
replace biochildgirl_total_D= biochildgirl_total_D + Rbiochildgirl_total_23
fre biochildgirl_total_D //N=90

//since age 16
cap drop biochildgirl_total_E
egen biochildgirl_total_E =anycount(pregs11_50 pregs12_50 pregs13_50 pregs21_50 pregs22_50 pregs23_50 pregs31_50 pregs32_50 pregs41_50 pregs51_50 pregs61_50 pregs71_50 pregs81_50), values(2)
replace biochildgirl_total_E=. if sweep16_50==.|preg_16_50==. 
replace biochildgirl_total_E= biochildgirl_total_E
fre biochildgirl_total_E //N=135


// COMPUTE age 50 total girls (age 50)
fre biochildgirl_total_A biochildgirl_total_B biochildgirl_total_C biochildgirl_total_D biochildgirl_total_E

cap drop biochildgirl_total_50
egen biochildgirl_total_50=rowtotal(biochildgirl_total_A biochildgirl_total_B biochildgirl_total_C biochildgirl_total_D biochildgirl_total_E)
replace biochildgirl_total_50=. if included==.
replace biochildgirl_total_50=-10 if anybiochildren_50==0
label define biochildgirl_total_50 0 "Boys only" -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildgirl_total_50 biochildgirl_total_50
label variable biochildgirl_total_50 "Total number of biological girls"
fre biochildgirl_total_50


 

*----------------------------------------------------------*
******ADJUSTING PREVIOUS VARIABLES ADDING THE EXTRA GIRLS AND BOYS IDENTIFIED IN HH GRID BUT NOT INCLUDED IN PREGNANCY DATA (age 50)

foreach C in 02_50 03_50 04_50 05_50 06_50 07_50 08_50 09_50 10_50 11_50 12_50 {

*sex of biological hh children (age 50)
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


***COMPUTE total number of biological girls and boys reported in hh grid (age 50)
cap drop biochildhhboy_total_50
gen biochildhhboy_total_50=biochildhhboy02_50+biochildhhboy03_50+biochildhhboy04_50+biochildhhboy05_50+biochildhhboy06_50+biochildhhboy07_50+biochildhhboy08_50+biochildhhboy09_50+biochildhhboy10_50+biochildhhboy11_50+biochildhhboy12_50
replace biochildhhboy_total_50=.  if HHgrid==.
label variable biochildhhboy_total_50 "Total number of bio boys in household (HH grid data)"
fre biochildhhboy_total_50

cap drop biochildhhgirl_total_50
gen biochildhhgirl_total_50=biochildhhgirl02_50+biochildhhgirl03_50+biochildhhgirl04_50+biochildhhgirl05_50+biochildhhgirl06_50+biochildhhgirl07_50+biochildhhgirl08_50+biochildhhgirl09_50+biochildhhgirl10_50+biochildhhgirl11_50+biochildhhgirl12_50
replace biochildhhgirl_total_50=.  if HHgrid==.
label variable biochildhhgirl_total_50 "Total number of bio girls in household (HH grid data)"
fre biochildhhgirl_total_50


//computing difference in pregnancy data and household data (age 50)

fre biochildboy_total_50 biochildgirl_total_50 //pregnancies
fre biochildhhboy_total_50 biochildhhgirl_total_50 //hh grid

cap drop biochildboy_tot_miss_50
gen biochildboy_tot_miss_50=1 if biochildboy_total_50==. //this creates a missing values flag for this variable
cap drop biochildgirl_tot_miss_50
gen biochildgirl_tot_miss_50=1 if biochildgirl_total_50==. //this creates a missing values flag for this variable

replace biochildboy_total_50=0 if biochildboy_total_50==.|biochildboy_total_50==-10 // this bit is important as crucial for the inclusion of all HH grid data in adjustments for extra children 
replace biochildgirl_total_50=0 if biochildgirl_total_50==.|biochildgirl_total_50==-10 // this bit is important as crucial for the inclusion of all HH grid data in adjustments for extra children 

fre biochildboy_total_50 biochildhhboy_total_50
tab biochildboy_total_50 biochildhhboy_total_50, mi
cap drop diff_boy_50
gen diff_boy_50=biochildboy_total_50 - biochildhhboy_total_50
fre diff_boy_50

fre biochildgirl_total_50 biochildhhgirl_total_50
tab biochildgirl_total_50 biochildhhgirl_total_50, mi
cap drop diff_girl_50
gen diff_girl_50=biochildgirl_total_50 - biochildhhgirl_total_50
fre diff_girl_50

//creating a variable that flags CMs with differences
cap drop bioboy_extra_flag_50
gen bioboy_extra_flag_50=.
label var bioboy_extra_flag_50 "Flag: More bio boys reported in HH grid than in pregnancy data"
replace bioboy_extra_flag_50=1 if inrange(diff_boy_50, -10,-1)
fre bioboy_extra_flag_50 //applies to 501

//creating a variable that flags CMs with differences
cap drop biogirl_extra_flag_50
gen biogirl_extra_flag_50=.
label var biogirl_extra_flag_50 "Flag: More bio girls reported in HH grid than in pregnancy data"
replace biogirl_extra_flag_50=1 if inrange(diff_girl_50, -10,-1)
fre biogirl_extra_flag_50 //applies to 477
 

//creating variable to use for adjustment of total boys and girls
cap drop bioextraboy_50
gen bioextraboy_50=difference_50
replace bioextraboy_50=0 if inrange(diff_boy_50,0,10)
replace bioextraboy_50=1 if diff_boy_50==-1
replace bioextraboy_50=2 if diff_boy_50==-2
replace bioextraboy_50=3 if diff_boy_50==-3
replace bioextraboy_50=4 if diff_boy_50==-4
replace bioextraboy_50=5 if diff_boy_50==-5
replace bioextraboy_50=6 if diff_boy_50==-6
replace bioextraboy_50=7 if diff_boy_50==-7
fre bioextraboy_50

cap drop bioextragirl_50
gen bioextragirl_50=difference_50
replace bioextragirl_50=0 if inrange(diff_girl_50,0,10)
replace bioextragirl_50=1 if diff_girl_50==-1
replace bioextragirl_50=2 if diff_girl_50==-2
replace bioextragirl_50=3 if diff_girl_50==-3
replace bioextragirl_50=4 if diff_girl_50==-4
replace bioextragirl_50=5 if diff_girl_50==-5
replace bioextragirl_50=6 if diff_girl_50==-6
replace bioextragirl_50=7 if diff_girl_50==-7
fre bioextragirl_50


******ADJUSTING (age 50)

//first doing some missing value flags
cap drop bioextraboy_miss_50
gen bioextraboy_miss_50=1 if bioextraboy_50==. //missing values flag 
fre bioextraboy_miss_50
replace bioextraboy_50=0 if bioextraboy_50==.

cap drop bioextragirl_miss_50
gen bioextragirl_miss_50=1 if bioextragirl_50==. //missing values flag 
fre bioextragirl_miss_50
replace bioextragirl_50=0 if bioextragirl_50==.

fre biochildboy_tot_miss_50 //already created a missing flag for this
fre biochildgirl_tot_miss_50 //already created a missing flag for this



//TOTAL NUMBER OF BOYS AND GIRLS (age 50)

fre biochildboy_tot_miss_50 bioextraboy_miss_50

//boys (age 50)
fre biochildboy_total_50 bioextraboy_50
replace biochildboy_total_50=biochildboy_total_50+bioextraboy_50
replace biochildboy_total_50=. if biochildboy_tot_miss_50==1 //& bioextraboy_miss_50==1
replace biochildboy_total_50=-10 if biochild_tot_50==0
fre biochildboy_total_50

//girls (age 50)
fre biochildgirl_total_50
replace biochildgirl_total_50=biochildgirl_total_50+bioextragirl_50
replace biochildgirl_total_50=. if biochildgirl_tot_miss_50==1 //& bioextragirl_miss_50==1
replace biochildgirl_total_50=-10 if biochild_tot_50==0
fre biochildgirl_total_50






*********************************************************
*** AGES OF BIOLOGICAL CHILDREN (age 50)
*********************************************************

//1. we have already updated ages of pregnancy childrens ages previously. 
fre biochildagey1_23 biochildagey2_23 biochildagey3_23 biochildagey4_23 

fre biochildagey1_33 biochildagey2_33 biochildagey3_33 biochildagey4_33 biochildagey5_33 biochildagey6_33 biochildagey7_33 biochildagey8_33 biochildagey9_33 

fre biochildagey1_42 biochildagey2_42 biochildagey3_42 biochildagey4_42 biochildagey5_42 biochildagey6_42 biochildagey7_42 biochildagey8_42 biochildagey11_42 biochildagey12_42 biochildagey16_42 biochildagey17_42 biochildagey21_42 biochildagey22_42 biochildagey26_42 biochildagey31_42 biochildagey36_42

fre biochildagey11_46 biochildagey12_46 biochildagey13_46 biochildagey21_46 biochildagey22_46 biochildagey31_46 biochildagey41_46 biochildagey51_46 biochildagey61_46

fre biochildagey11_50 biochildagey12_50 biochildagey13_50 biochildagey21_50 biochildagey22_50 biochildagey23_50 biochildagey31_50 biochildagey32_50 biochildagey41_50 biochildagey51_50 biochildagey61_50 biochildagey71_50 biochildagey81_50


//2. now update ages of extra HH grid children identified at 33 and 42 
 
// time in years since last interview at age 33 to be added to HH grid bio children's ages 
cap drop addtime
gen addtime=(intym_50-intym_33)/12
replace addtime=round(addtime, 1)
fre addtime 

foreach C in 2_33 3_33 4_33 5_33 6_33 7_33 8_33 9_33 10_33 {
cap drop Rbiohhage`C'
gen Rbiohhage`C'=.
replace Rbiohhage`C'=hhage`C' if hhrel`C'==3 & biochild_extra_flag_33==1
replace Rbiohhage`C'=(Rbiohhage`C' + addtime)
fre Rbiohhage`C'
} 
 
 
// time in years since last interview at age 42 to be added to HH grid bio children's ages 
cap drop addtime
gen addtime=(intym_50-intym_42)/12
replace addtime=round(addtime, 1)
fre addtime 

foreach C in 2_42 3_42 4_42 5_42 6_42 7_42 8_42 9_42 10_42 {
cap drop Rbiohhage`C'
gen Rbiohhage`C'=.
replace Rbiohhage`C'=hhage`C' if hhrel`C'==3 & biochild_extra_flag_42==1
replace Rbiohhage`C'=(Rbiohhage`C' + addtime)
fre Rbiohhage`C'
} 


// time in years since last interview at age 46 to be added to HH grid bio children's ages 
cap drop addtime
gen addtime=(intym_50-intym_46)/12
replace addtime=round(addtime, 1)
fre addtime 

foreach C in 2_46 3_46 4_46 5_46 6_46 7_46 8_46 9_46 10_46 {
cap drop Rbiohhage`C'
gen Rbiohhage`C'=.
replace Rbiohhage`C'=hhage`C' if hhrel`C'==3 & biochild_extra_flag_46==1
replace Rbiohhage`C'=(Rbiohhage`C' + addtime)
fre Rbiohhage`C'
} 


//3. identify additional children in HH grid at age 50
***COMPUTE age of eldest and youngest child in years from HH grid data at age 50 for CM's with a flag for having more children in HH grid than in preg data.
foreach C in 02_50 03_50 04_50 05_50 06_50 07_50 08_50 09_50 10_50 11_50 12_50 {
cap drop biohhage`C'
gen biohhage`C'=.
replace biohhage`C'=hhage`C' if hhrel`C'==4 & biochild_extra_flag_50==1
fre biohhage`C'
}



//THEN DO FINAL AGE OF CHILDREN MEASURE (age 50)
*--------------------------------------------------------------------*
*** COMPUTE age of eldest and youngest biological child (age 50)
cap drop biochildy_eldest_50 //years
gen biochildy_eldest_50 = max(biochildagey11_50,biochildagey12_50,biochildagey13_50,biochildagey21_50,biochildagey22_50,biochildagey23_50,biochildagey31_50,biochildagey32_50,biochildagey41_50,biochildagey51_50,biochildagey61_50,biochildagey71_50,biochildagey81_50,biohhage02_50,biohhage03_50,biohhage04_50,biohhage05_50,biohhage06_50,biohhage07_50,biohhage08_50,biohhage09_50,biohhage10_50,biohhage11_50,biohhage12_50, biochildagey11_46,biochildagey12_46,biochildagey13_46,biochildagey21_46,biochildagey22_46,biochildagey31_46,biochildagey41_46,biochildagey51_46,biochildagey61_46, Rbiohhage2_46, Rbiohhage3_46, Rbiohhage4_46, Rbiohhage5_46, Rbiohhage6_46, Rbiohhage7_46, Rbiohhage8_46, Rbiohhage9_46, Rbiohhage10_46, biochildagey1_42, biochildagey2_42, biochildagey3_42, biochildagey4_42, biochildagey5_42, biochildagey6_42, biochildagey7_42, biochildagey8_42, biochildagey11_42, biochildagey12_42, biochildagey16_42, biochildagey17_42, biochildagey21_42, biochildagey22_42, biochildagey26_42, biochildagey31_42, biochildagey36_42, Rbiohhage2_42,Rbiohhage3_42,Rbiohhage4_42,Rbiohhage5_42,Rbiohhage6_42,Rbiohhage7_42,Rbiohhage8_42,Rbiohhage9_42,Rbiohhage10_42, biochildagey1_33, biochildagey2_33, biochildagey3_33, biochildagey4_33, biochildagey5_33, biochildagey6_33, biochildagey7_33, biochildagey8_33, biochildagey9_33, Rbiohhage2_33,Rbiohhage3_33,Rbiohhage4_33,Rbiohhage5_33,Rbiohhage6_33,Rbiohhage7_33,Rbiohhage8_33,Rbiohhage9_33,Rbiohhage10_33, biochildagey1_23, biochildagey2_23, biochildagey3_23, biochildagey4_23)
replace biochildy_eldest_50=-10 if anybiochildren_50==0
replace biochildy_eldest_50=. if anybiochildren_50==.
label define biochildy_eldest_50 -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildy_eldest_50 biochildy_eldest_50
label var biochildy_eldest_50 "Age in years of eldest biological child"
fre biochildy_eldest_50

cap drop biochildy_youngest_50 //years
gen biochildy_youngest_50 = min(biochildagey11_50,biochildagey12_50,biochildagey13_50,biochildagey21_50,biochildagey22_50,biochildagey23_50,biochildagey31_50,biochildagey32_50,biochildagey41_50,biochildagey51_50,biochildagey61_50,biochildagey71_50,biochildagey81_50,biohhage02_50,biohhage03_50,biohhage04_50,biohhage05_50,biohhage06_50,biohhage07_50,biohhage08_50,biohhage09_50,biohhage10_50,biohhage11_50,biohhage12_50, biochildagey11_46,biochildagey12_46,biochildagey13_46,biochildagey21_46,biochildagey22_46,biochildagey31_46,biochildagey41_46,biochildagey51_46,biochildagey61_46, Rbiohhage2_46, Rbiohhage3_46, Rbiohhage4_46, Rbiohhage5_46, Rbiohhage6_46, Rbiohhage7_46, Rbiohhage8_46, Rbiohhage9_46, Rbiohhage10_46, biochildagey1_42, biochildagey2_42, biochildagey3_42, biochildagey4_42, biochildagey5_42, biochildagey6_42, biochildagey7_42, biochildagey8_42, biochildagey11_42, biochildagey12_42, biochildagey16_42, biochildagey17_42, biochildagey21_42, biochildagey22_42, biochildagey26_42, biochildagey31_42, biochildagey36_42, Rbiohhage2_42,Rbiohhage3_42,Rbiohhage4_42,Rbiohhage5_42,Rbiohhage6_42,Rbiohhage7_42,Rbiohhage8_42,Rbiohhage9_42,Rbiohhage10_42, biochildagey1_33, biochildagey2_33, biochildagey3_33, biochildagey4_33, biochildagey5_33, biochildagey6_33, biochildagey7_33, biochildagey8_33, biochildagey9_33, Rbiohhage2_33,Rbiohhage3_33,Rbiohhage4_33,Rbiohhage5_33,Rbiohhage6_33,Rbiohhage7_33,Rbiohhage8_33,Rbiohhage9_33,Rbiohhage10_33, biochildagey1_23, biochildagey2_23, biochildagey3_23, biochildagey4_23)
replace biochildy_youngest_50=-10 if anybiochildren_50==0
replace biochildy_youngest_50=. if anybiochildren_50==. 
label define biochildy_youngest_50 -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildy_youngest_50 biochildy_youngest_50
label var biochildy_youngest_50 "Age in years of youngest biological child"
fre biochildy_youngest_50




*************************************************************
******** AGE OF COHORT MEMBER AGE AT BIRTH (age 50) *******
*************************************************************

//generating variables for the extra HH grid children at age 33 and 42 and 46 and age 50 to include in final code below.  We subtract childs age from age 50 as childrens age has already been adjusted to be their age at age 50 interview if reported in a previous sweep, using the Rbioage variable.

foreach C in 02_50 03_50 04_50 05_50 06_50 07_50 08_50 09_50 10_50 11_50 12_50 {
cap drop cmagebirth_hhextra`C'
gen cmagebirth_hhextra`C'=cmagey_50-biohhage`C' if biochild_extra_flag_50==1
fre cmagebirth_hhextra`C'
}

foreach C in 2_46 3_46 4_46 5_46 6_46 7_46 8_46 9_46 10_46 {
cap drop cmagebirth_hhextra`C'
gen cmagebirth_hhextra`C'=cmagey_50-Rbiohhage`C' if biochild_extra_flag_46==1
fre cmagebirth_hhextra`C'
}

foreach C in 2_42 3_42 4_42 5_42 6_42 7_42 8_42 9_42 10_42 {
cap drop cmagebirth_hhextra`C'
gen cmagebirth_hhextra`C'=cmagey_50-Rbiohhage`C' if biochild_extra_flag_42==1
fre cmagebirth_hhextra`C'
}

foreach C in 2_33 3_33 4_33 5_33 6_33 7_33 8_33 9_33 10_33 {
cap drop cmagebirth_hhextra`C'
gen cmagebirth_hhextra`C'=cmagey_50-Rbiohhage`C' if biochild_extra_flag_33==1
fre cmagebirth_hhextra`C'
}



***COMPUTE age of cohort member at birth of eldest and youngest child in years (age 50)
cap drop cmageybirth_eldest_50 //years
gen cmageybirth_eldest_50 = min(cmageybirth11_50,cmageybirth12_50,cmageybirth13_50,cmageybirth21_50,cmageybirth22_50,cmageybirth23_50,cmageybirth31_50,cmageybirth32_50,cmageybirth41_50,cmageybirth51_50,cmageybirth61_50,cmageybirth71_50,cmageybirth81_50,cmagebirth_hhextra02_50,cmagebirth_hhextra03_50,cmagebirth_hhextra04_50,cmagebirth_hhextra05_50,cmagebirth_hhextra06_50,cmagebirth_hhextra07_50,cmagebirth_hhextra08_50,cmagebirth_hhextra09_50,cmagebirth_hhextra10_50,cmagebirth_hhextra11_50,cmagebirth_hhextra12_50,cmageybirth11_46,cmageybirth12_46,cmageybirth13_46,cmageybirth21_46,cmageybirth22_46,cmageybirth31_46,cmageybirth41_46,cmageybirth51_46,cmageybirth61_46,cmagebirth_hhextra2_46,cmagebirth_hhextra3_46,cmagebirth_hhextra4_46,cmagebirth_hhextra5_46,cmagebirth_hhextra6_46,cmagebirth_hhextra7_46,cmagebirth_hhextra8_46,cmagebirth_hhextra9_46,cmagebirth_hhextra10_46,cmageybirth1_42,cmageybirth2_42,cmageybirth3_42,cmageybirth4_42,cmageybirth5_42,cmageybirth6_42,cmageybirth7_42,cmageybirth8_42,cmageybirth11_42,cmageybirth12_42,cmageybirth16_42,cmageybirth17_42,cmageybirth21_42,cmageybirth22_42,cmageybirth26_42,cmageybirth31_42,cmageybirth36_42,cmagebirth_hhextra2_42,cmagebirth_hhextra3_42,cmagebirth_hhextra4_42,cmagebirth_hhextra5_42,cmagebirth_hhextra6_42,cmagebirth_hhextra7_42,cmagebirth_hhextra8_42,cmagebirth_hhextra9_42,cmagebirth_hhextra10_42, cmageybirth1_33,cmageybirth2_33,cmageybirth3_33,cmageybirth4_33,cmageybirth5_33,cmageybirth6_33,cmageybirth7_33,cmageybirth8_33,cmageybirth9_33, cmagebirth_hhextra2_33,cmagebirth_hhextra3_33,cmagebirth_hhextra4_33,cmagebirth_hhextra5_33,cmagebirth_hhextra6_33,cmagebirth_hhextra7_33,cmagebirth_hhextra8_33,cmagebirth_hhextra9_33,cmagebirth_hhextra10_33,cmageybirth1_23, cmageybirth2_23, cmageybirth3_23, cmageybirth4_23)
replace cmageybirth_eldest_50=-10 if anybiochildren_50==0
replace cmageybirth_eldest_50=. if anybiochildren_50==.
label define cmageybirth_eldest_50 -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values cmageybirth_eldest_50 cmageybirth_eldest_50
label var cmageybirth_eldest_50 "CM age in years at birth of eldest biological child"
fre cmageybirth_eldest_50

cap drop cmageybirth_youngest_50 //years
gen cmageybirth_youngest_50 = max(cmageybirth11_50,cmageybirth12_50,cmageybirth13_50,cmageybirth21_50,cmageybirth22_50,cmageybirth23_50,cmageybirth31_50,cmageybirth32_50,cmageybirth41_50,cmageybirth51_50,cmageybirth61_50,cmageybirth71_50,cmageybirth81_50,cmagebirth_hhextra02_50,cmagebirth_hhextra03_50,cmagebirth_hhextra04_50,cmagebirth_hhextra05_50,cmagebirth_hhextra06_50,cmagebirth_hhextra07_50,cmagebirth_hhextra08_50,cmagebirth_hhextra09_50,cmagebirth_hhextra10_50,cmagebirth_hhextra11_50,cmagebirth_hhextra12_50,cmageybirth11_46,cmageybirth12_46,cmageybirth13_46,cmageybirth21_46,cmageybirth22_46,cmageybirth31_46,cmageybirth41_46,cmageybirth51_46,cmageybirth61_46,cmagebirth_hhextra2_46,cmagebirth_hhextra3_46,cmagebirth_hhextra4_46,cmagebirth_hhextra5_46,cmagebirth_hhextra6_46,cmagebirth_hhextra7_46,cmagebirth_hhextra8_46,cmagebirth_hhextra9_46,cmagebirth_hhextra10_46,cmageybirth1_42,cmageybirth2_42,cmageybirth3_42,cmageybirth4_42,cmageybirth5_42,cmageybirth6_42,cmageybirth7_42,cmageybirth8_42,cmageybirth11_42,cmageybirth12_42,cmageybirth16_42,cmageybirth17_42,cmageybirth21_42,cmageybirth22_42,cmageybirth26_42,cmageybirth31_42,cmageybirth36_42,cmagebirth_hhextra2_42,cmagebirth_hhextra3_42,cmagebirth_hhextra4_42,cmagebirth_hhextra5_42,cmagebirth_hhextra6_42,cmagebirth_hhextra7_42,cmagebirth_hhextra8_42,cmagebirth_hhextra9_42,cmagebirth_hhextra10_42, cmageybirth1_33,cmageybirth2_33,cmageybirth3_33,cmageybirth4_33,cmageybirth5_33,cmageybirth6_33,cmageybirth7_33,cmageybirth8_33,cmageybirth9_33, cmagebirth_hhextra2_33,cmagebirth_hhextra3_33,cmagebirth_hhextra4_33,cmagebirth_hhextra5_33,cmagebirth_hhextra6_33,cmagebirth_hhextra7_33,cmagebirth_hhextra8_33,cmagebirth_hhextra9_33,cmagebirth_hhextra10_33,cmageybirth1_23, cmageybirth2_23, cmageybirth3_23, cmageybirth4_23)
replace cmageybirth_youngest_50=-10 if anybiochildren_50==0
replace cmageybirth_youngest_50=. if anybiochildren_50==.
label define cmageybirth_youngest_50 -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values cmageybirth_youngest_50 cmageybirth_youngest_50
label var cmageybirth_youngest_50 "CM age in years at birth of youngest biological child"
fre cmageybirth_youngest_50




*************************************************************
*** NON BIOLOGICAL CHILDREN (age 50) ***
*************************************************************
//5=adopted, 6=step, 7=foster

*RECODE on non-biological children variables (age 50)
foreach C in 02_50 03_50 04_50 05_50 06_50 07_50 08_50 09_50 10_50 11_50 12_50 {

*non-biological and type (age 50)
cap drop nonbiochild`C'
gen nonbiochild`C'=.
replace nonbiochild`C'=1 if inrange(hhrel`C',5,7)
label define nonbiochild`C' 1 "Non-biological child" 0 "No non-biological child", replace
label values nonbiochild`C' nonbiochild`C'
label var nonbiochild`C' "`C' is a non-biological"
fre nonbiochild`C'

cap drop step`C'
gen step`C'=.
replace step`C'=1 if hhrel`C'==6
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
replace foster`C'=1 if hhrel`C'==7
label define foster`C' 1 "foster", replace
label values foster`C' foster`C'
label var foster`C' "`C' is foster"
fre foster`C'


*age of nonbio children (age 50)
cap drop nonbiochildagey`C'
clonevar nonbiochildagey`C' = hhage`C' if inrange(hhrel`C',5,7) & hhage`C'<100 
label var nonbiochildagey`C' "`C' Age in years of non-biological child"
fre nonbiochildagey`C'

*sex of nonbio children (age 50)
cap drop nonbiochildsex`C'
clonevar nonbiochildsex`C' = hhsex`C' if inrange(hhrel`C',5,7)
label var nonbiochildsex`C' "`C' Sex of non-biological child"
fre nonbiochildsex`C'

}



***COMPUTE whether has any non-biologial children in household (age 50)
cap drop anynonbio_50
egen anynonbio_50=anycount(nonbiochild02_50 nonbiochild03_50 nonbiochild04_50 nonbiochild05_50 nonbiochild06_50 nonbiochild07_50 nonbiochild08_50 nonbiochild09_50 nonbiochild10_50 nonbiochild11_50 nonbiochild12_50), values(1)
replace anynonbio_50=1 if inrange(anynonbio_50,1,20)
replace anynonbio_50=. if (HHgrid_50==.)
label variable anynonbio_50 "Whether CM has any non-biological children in household"
label define yesno 0 "No" 1 "Yes" -100 "no participation in sweep" -99 "information not provided", replace
label values anynonbio_50 yesno
fre anynonbio_50 


***COMPUTE total number of non-biologial children in household (age 50)

//number of all non-biological (age 50)
cap drop nonbiochild_tot_50
egen nonbiochild_tot_50 = anycount(nonbiochild02_50 nonbiochild03_50 nonbiochild04_50 nonbiochild05_50 nonbiochild06_50 nonbiochild07_50 nonbiochild08_50 nonbiochild09_50 nonbiochild10_50 nonbiochild11_50 nonbiochild12_50), values(1)
replace nonbiochild_tot_50=. if (HHgrid_50==.)
label define nonbiochild_tot_50 0 "No non-biological children in HH" -100 "no participation in sweep" -99 "information not provided", replace 
label values nonbiochild_tot_50 nonbiochild_tot_50
label variable nonbiochild_tot_50 "Total number of non-biological children in household"
fre nonbiochild_tot_50


//number of adopted (age 50)
cap drop adopt_tot_50
egen adopt_tot_50 = anycount(adopt02_50 adopt03_50 adopt04_50 adopt05_50 adopt06_50 adopt07_50 adopt08_50 adopt09_50 adopt10_50 adopt11_50 adopt12_50), values(1)
replace adopt_tot_50=. if (HHgrid_50==.)
label define adopt_tot_50 0 "No adopted children in HH" -100 "no participation in sweep" -99 "information not provided", replace 
label values adopt_tot_50 adopt_tot_50
label variable adopt_tot_50 "Total number of adopted children in household"
fre adopt_tot_50

//number of foster (age 50)
cap drop foster_tot_50
egen foster_tot_50 = anycount(foster02_50 foster03_50 foster04_50 foster05_50 foster06_50 foster07_50 foster08_50 foster09_50 foster10_50 foster11_50 foster12_50), values(1)
replace foster_tot_50=. if (HHgrid_50==.)
label define foster_tot_50 0 "No foster children in HH" -100 "no participation in sweep" -99 "information not provided", replace 
label values foster_tot_50 foster_tot_50
label variable foster_tot_50 "Total number of foster children in household"
fre foster_tot_50

//number of stepchildren (age 50)
cap drop step_tot_50
egen step_tot_50 = anycount(step02_50 step03_50 step04_50 step05_50 step06_50 step07_50 step08_50 step09_50 step10_50 step11_50 step12_50), values(1)
replace step_tot_50=. if (HHgrid_50==.)
label define step_tot_50 0 "No stepchildren in HH" -100 "no participation in sweep" -99 "information not provided", replace 
label values step_tot_50 step_tot_50
label variable step_tot_50 "Total number of stepchildren in household"
fre step_tot_50




***COMPUTE age of youngest and oldest non-biological child (age 50)
cap drop nonbiochildy_eldest_50 //years
gen nonbiochildy_eldest_50 = max(nonbiochildagey02_50,nonbiochildagey03_50,nonbiochildagey04_50,nonbiochildagey05_50,nonbiochildagey06_50,nonbiochildagey07_50,nonbiochildagey08_50,nonbiochildagey09_50,nonbiochildagey10_50,nonbiochildagey11_50,nonbiochildagey12_50)
replace nonbiochildy_eldest_50=-10 if anynonbio_50==0
replace nonbiochildy_eldest_50=. if (HHgrid_50==.)
label define nonbiochildy_eldest_50 -10 "No non-biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values nonbiochildy_eldest_50 nonbiochildy_eldest_50
label var nonbiochildy_eldest_50 "Age in years of youngest non-biological child"
fre nonbiochildy_eldest_50

cap drop nonbiochildy_youngest_50 //years
gen nonbiochildy_youngest_50 = min(nonbiochildagey02_50,nonbiochildagey03_50,nonbiochildagey04_50,nonbiochildagey05_50,nonbiochildagey06_50,nonbiochildagey07_50,nonbiochildagey08_50,nonbiochildagey09_50,nonbiochildagey10_50,nonbiochildagey11_50,nonbiochildagey12_50)
replace nonbiochildy_youngest_50=-10 if anynonbio_50==0
replace nonbiochildy_youngest_50=. if (HHgrid_50==.)
label define nonbiochildy_youngest_50 -10 "No non-biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values nonbiochildy_youngest_50 nonbiochildy_youngest_50
label var nonbiochildy_youngest_50 "Age in years of youngest non-biological child"
fre nonbiochildy_youngest_50




***COMPUTE total number of non-biological boys and girls (age 50)
//nonbiochildsex: 1=boy 2=girl

cap drop nonbiochildboy_total_50
egen nonbiochildboy_total_50 = anycount(nonbiochildsex2_46 nonbiochildsex3_46 nonbiochildsex4_46 nonbiochildsex5_46 nonbiochildsex6_46 nonbiochildsex7_46 nonbiochildsex8_46 nonbiochildsex9_46 nonbiochildsex10_46 nonbiochildsex02_50 nonbiochildsex03_50 nonbiochildsex04_50 nonbiochildsex05_50 nonbiochildsex06_50 nonbiochildsex07_50 nonbiochildsex08_50 nonbiochildsex09_50 nonbiochildsex10_50 nonbiochildsex11_50 nonbiochildsex12_50), values(1)
replace nonbiochildboy_total_50=-10 if anynonbio_50==0 //no non-biologial children
replace nonbiochildboy_total_50=. if (HHgrid_50==.)
label define nonbiochildboy_total_50 0 "Girls only" -10 "No non-biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values nonbiochildboy_total_50 nonbiochildboy_total_50
label var nonbiochildboy_total_50 "Total number of non-biological children who are boys"
fre nonbiochildboy_total_50 

cap drop nonbiochildgirl_total_50
egen nonbiochildgirl_total_50 = anycount(nonbiochildsex2_46 nonbiochildsex3_46 nonbiochildsex4_46 nonbiochildsex5_46 nonbiochildsex6_46 nonbiochildsex7_46 nonbiochildsex8_46 nonbiochildsex9_46 nonbiochildsex10_46 nonbiochildsex02_50 nonbiochildsex03_50 nonbiochildsex04_50 nonbiochildsex05_50 nonbiochildsex06_50 nonbiochildsex07_50 nonbiochildsex08_50 nonbiochildsex09_50 nonbiochildsex10_50 nonbiochildsex11_50 nonbiochildsex12_50), values(2)
replace nonbiochildgirl_total_50=-10 if anynonbio_50==0 //no non-biologial children
replace nonbiochildgirl_total_50=. if (HHgrid_50==.)
label define nonbiochildgirl_total_50 0 "Boys only" -10 "No non-biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values nonbiochildgirl_total_50 nonbiochildgirl_total_50
label var nonbiochildgirl_total_50 "Total number of non-biological children who are girls"
fre nonbiochildgirl_total_50 






*************************************************************
**** BIOLOGICAL AND NON BIOLOGICAL CHILDREN (age 50) ****
*************************************************************

***COMPUTE whether has any biological or non-biological (age 50)
cap drop anychildren_50
gen anychildren_50=.
replace anychildren_50=1 if anynonbio_50==1|anybiochildren_50==1
replace anychildren_50=0 if anynonbio_50==0 & anybiochildren_50==0
replace anychildren_50=. if anybiochildren_50==.|anynonbio_50==.
label define anychildren_50 0 "No" 1 "Yes" -100 "no participation in sweep" -99 "information not provided", replace
label values anychildren_50 anychildren_50
label var anychildren_50 "Whether CM has any children (biological or non-biological)"
fre anychildren_50 


***COMPUTE total number of biological and non-biological children (age 50)
cap drop children_tot_50
gen children_tot_50=biochild_tot_50 + nonbiochild_tot_50
fre children_tot_50
label define children_tot_50 0 "No children (biological or non-biological)" -100 "no participation in sweep" -99 "information not provided", replace
label values children_tot_50 children_tot_50
label var children_tot_50 "Total number of children (biological or non-biological)"
fre children_tot_50




***COMPUTE youngest and oldest biological or non-biological children (age 50)
//create temporary recoded variables 
foreach X of varlist biochildy_eldest_50 nonbiochildy_eldest_50 biochildy_youngest_50 nonbiochildy_youngest_50 {
cap drop `X'_R
clonevar `X'_R = `X'
replace `X'_R=. if `X'_R==-10	
fre `X'_R
}

cap drop childy_eldest_50 //years
gen childy_eldest_50 = max(biochildy_eldest_50_R, nonbiochildy_eldest_50_R)
replace childy_eldest_50=-10 if anybiochildren_50==0 & anynonbio_50==0
replace childy_eldest_50=. if anybiochildren_50==.|anynonbio_50==.
label define childy_eldest_50 -10 "No children (biological or non-biological)" -100 "no participation in sweep" -99 "information not provided", replace
label values childy_eldest_50 childy_eldest_50
label var childy_eldest_50 "Age in years of eldest child (biological or non-biological)"
fre childy_eldest_50

cap drop childy_youngest_50 //years
gen childy_youngest_50 = min(biochildy_youngest_50_R, nonbiochildy_youngest_50_R)
replace childy_youngest_50=-10 if anybiochildren_50==0 & anynonbio_50==0
replace childy_youngest_50=. if anybiochildren_50==.|anynonbio_50==.
label define childy_youngest_50 -10 "No children (biological or non-biological)" -100 "no participation in sweep" -99 "information not provided", replace
label values childy_youngest_50 childy_youngest_50
label var childy_youngest_50 "Age in years of youngest child (biological or non-biological)"
fre childy_youngest_50

drop biochildy_eldest_50_R nonbiochildy_eldest_50_R biochildy_youngest_50_R nonbiochildy_youngest_50_R



***COMPUTE total number of male biological or non-biological children (age 50)
foreach X of varlist biochildboy_total_50 biochildgirl_total_50 nonbiochildboy_total_50 nonbiochildgirl_total_50 {
cap drop `X'_R
clonevar `X'_R = `X'
replace `X'_R=0 if `X'_R==-10	
}

fre biochildboy_total_50_R biochildgirl_total_50_R nonbiochildboy_total_50_R nonbiochildgirl_total_50_R

cap drop childboy_total_50
gen childboy_total_50 = biochildboy_total_50_R + nonbiochildboy_total_50_R
replace childboy_total_50=-10 if anybiochildren_50==0 & anynonbio_50==0  //no bio or non-bio children
replace childboy_total_50=. if anybiochildren_50==.|anynonbio_50==.  //no bio or non-bio children

label define childboy_total_50 0 "Girls only" -10 "No children (biological or non-biological)" -100 "no participation in sweep" -99 "information not provided", replace
drop biochildboy_total_50_R  nonbiochildboy_total_50_R
label values childboy_total_50 childboy_total_50
label var childboy_total_50 "Total number of children who are boys (biological or non-biological)"
fre childboy_total_50 


cap drop childgirl_total_50
gen childgirl_total_50 = biochildgirl_total_50_R + nonbiochildgirl_total_50_R
replace childgirl_total_50=-10 if anybiochildren_50==0 & anynonbio_50==0  //no bio or non-bio children
replace childgirl_total_50=. if anybiochildren_50==.|anynonbio_50==.  //no bio or non-bio children
label define childgirl_total_50 0 "Boys only" -10 "No children (biological or non-biological)" -100 "no participation in sweep" -99 "information not provided", replace
drop biochildgirl_total_50_R  nonbiochildgirl_total_50_R
label values childgirl_total_50 childgirl_total_50
label var childgirl_total_50 "Total number of children who are girls (biological or non-biological)"
fre childgirl_total_50 





*************************************************************
****COMPUTE partner child combo (age 50) ****
*************************************************************

//partner and biological children (age 50)
cap drop partnerchildbio_50
gen partnerchildbio_50=.
replace partnerchildbio_50=1 if anybiochildren_50==0 & partner_50==0 //no partner and no children
replace partnerchildbio_50=2 if anybiochildren_50==0 & partner_50==1 //partner but no children
replace partnerchildbio_50=3 if anybiochildren_50==1 & partner_50==0 //no partner but children
replace partnerchildbio_50=4 if anybiochildren_50==1 & partner_50==1 //partner and children
label define partnerchildbio_50 1 "No partner or children" 2 "Partner and no children" 3 "Children and no partner" 4 "Partner and children" -100 "no participation in sweep" -99 "information not provided", replace
label values partnerchildbio_50 partnerchildbio_50
label var partnerchildbio_50 "Whether has partner and/or any biological children"
fre partnerchildbio_50


//partner and any bio or nonbio children (age 50)
cap drop partnerchildany_50
gen partnerchildany_50=.
replace partnerchildany_50=1 if anychildren_50==0 & partner_50==0 //no partner and no children
replace partnerchildany_50=2 if anychildren_50==0 & partner_50==1 //partner but no children
replace partnerchildany_50=3 if anychildren_50==1 & partner_50==0 //no partner but children
replace partnerchildany_50=4 if anychildren_50==1 & partner_50==1 //partner and children
label define partnerchildany_50 1 "No partner or children" 2 "Partner and no children" 3 "Children and no partner" 4 "Partner and children" -100 "no participation in sweep" -99 "information not provided", replace
label values partnerchildany_50 partnerchildany_50
label var partnerchildany_50 "Whether has partner and/or any biological or non-biological children"
fre partnerchildany_50

*************************************************************


save "$derived\NCDS_fertility_age23_50.dta", replace 
use "$derived\NCDS_fertility_age23_50.dta", clear






**# Bookmark #6
**************************************************************************
**************************************************************************
************* MERGING AND FURTHER WORK ON OVERALL DATA *******************
**************************************************************************
**************************************************************************



use "$derived\NCDS_fertility_age23_50.dta", clear //N=14,815


clonevar NCDSID = ncdsid //for merging with response file
merge 1:1 NCDSID using "$raw\ncds_response.dta", keepusing(N622) 
keep if _merge==3
drop _merge

cap drop sex
clonevar sex=N622
label var sex "Sex of cohort member"
fre sex

cap drop cmbyear
gen cmbyear=1958
label var cmbyear "Birth year of CM"
fre cmbyear

cap drop cmbmonth
gen cmbmonth=3
label var cmbmonth "Birth month of CM" 
fre cmbmonth

rename (NCDSAGE23SURVEY_23 NCDSAGE33SURVEY_33 NCDSAGE42SURVEY_42 NCDSAGE46SURVEY_46 NCDSAGE50SURVEY_50) (ncdssurvey_23 ncdssurvey_33 ncdssurvey_42 ncdssurvey_46 ncdssurvey_50 )




*flag for insonsistencies number of children between sweeps (highe number of biological children in previous sweep)

cap drop biototal_flag_23_33
gen biototal_flag_23_33=biochild_tot_33-biochild_tot_23
replace biototal_flag_23_33=0 if inrange(biototal_flag_23_33,0,10)
replace biototal_flag_23_33=1 if inrange(biototal_flag_23_33,-10,-1)
label define biototal_flag_23_33 1 "Yes" 0 "No" -100 "no participation in sweep" -99 "information not provided", replace
label values biototal_flag_23_33 biototal_flag_23_33
label variable biototal_flag_23_33 "More biological children reported at age 23 than at age 33"
fre biototal_flag_23_33 // inconsistencies N=22

cap drop biototal_flag_33_42
gen biototal_flag_33_42=biochild_tot_42-biochild_tot_33
replace biototal_flag_33_42=0 if inrange(biototal_flag_33_42,0,10)
replace biototal_flag_33_42=1 if inrange(biototal_flag_33_42,-10,-1)
label define biototal_flag_33_42 1 "Yes" 0 "No" -100 "no participation in sweep" -99 "information not provided", replace
label values biototal_flag_33_42 biototal_flag_33_42
label variable biototal_flag_33_42 "More biological children reported at age 33 than at age 42"
fre biototal_flag_33_42 //no inconsistencies

cap drop biototal_flag_42_46
gen biototal_flag_42_46=biochild_tot_46-biochild_tot_42
replace biototal_flag_42_46=0 if inrange(biototal_flag_42_46,0,10)
replace biototal_flag_42_46=1 if inrange(biototal_flag_42_46,-10,-1)
label define biototal_flag_42_46 1 "Yes" 0 "No" -100 "no participation in sweep" -99 "information not provided", replace
label values biototal_flag_42_46 biototal_flag_42_46
label variable biototal_flag_42_46 "More biological children reported at age 42 than at age 46"
fre biototal_flag_42_46 //no inconsistencies

cap drop biototal_flag_46_50
gen biototal_flag_46_50=biochild_tot_50-biochild_tot_46
replace biototal_flag_46_50=0 if inrange(biototal_flag_46_50,0,10)
replace biototal_flag_46_50=1 if inrange(biototal_flag_46_50,-10,-1)
label define biototal_flag_46_50 1 "Yes" 0 "No" -100 "no participation in sweep" -99 "information not provided", replace
label values biototal_flag_46_50 biototal_flag_46_50
label variable biototal_flag_46_50 "More biological children reported at age 46 than at age 50"
fre biototal_flag_46_50 //no inconsistencies






*label and code survey participation
foreach Y of varlist ncdssurvey_23 ncdssurvey_33 ncdssurvey_42 ncdssurvey_46 ncdssurvey_50 {
replace `Y'=0 if `Y'==.	
	
label define `Y' 1 "Yes" 0 "No participation in survey sweep", replace	
label values `Y' `Y'
fre `Y'
}



*MISSSING DATA CODING

*age 23
foreach Y of varlist intyear_23 intmonth_23 partner_23 marital_23 anybiochildren_23 biochild_tot_23 biochildhh_total_23 biochildnonhh_total_23 biochildy_eldest_23 biochildy_youngest_23 cmageybirth_eldest_23 cmageybirth_youngest_23 biochildboy_total_23 biochildgirl_total_23 anynonbio_23 nonbiochild_tot_23 foster_tot_23 step_tot_23 nonbiochildy_eldest_23 nonbiochildy_youngest_23 nonbiochildboy_total_23 nonbiochildgirl_total_23 anychildren_23 children_tot_23 childy_eldest_23 childy_youngest_23 childboy_total_23 childgirl_total_23 partnerchildbio_23 partnerchildany_23 {

replace `Y'=-100 if `Y'==. & ncdssurvey_23==0 
replace `Y'=-99 if `Y'==. 	
fre `Y'	
}


*age 33
foreach Y of varlist intyear_33 intmonth_33 partner_33 marital_33 anybiochildren_33 biochild_tot_33 biochildhh_total_33 biochild_extra_flag_33 biochildnonhh_total_33  biochildprev_total_33 biochildprevany_33 biochildy_eldest_33 biochildy_youngest_33 cmageybirth_eldest_33 cmageybirth_youngest_33 biochildboy_total_33 biochildgirl_total_33 anynonbio_33 nonbiochild_tot_33 adopt_tot_33 foster_tot_33 step_tot_33 nonbiochildy_eldest_33 nonbiochildy_youngest_33 nonbiochildboy_total_33 nonbiochildgirl_total_33 anychildren_33 children_tot_33 childy_eldest_33 childy_youngest_33 childboy_total_33 childgirl_total_33 partnerchildbio_33 partnerchildany_33  {

replace `Y'=-100 if `Y'==. & ncdssurvey_33==0 
replace `Y'=-99 if `Y'==. 	
fre `Y'	
}


*age 42
foreach Y of varlist intyear_42 intmonth_42 partner_42 marital_42 anybiochildren_42 biochild_tot_42 biochildhh_total_42 biochild_extra_flag_42 biochildnonhh_total_42 biochildy_eldest_42 biochildy_youngest_42 cmageybirth_eldest_42 cmageybirth_youngest_42 biochildboy_total_42 biochildgirl_total_42 anynonbio_42 nonbiochild_tot_42 adopt_tot_42 foster_tot_42 step_tot_42 nonbiochildy_eldest_42 nonbiochildy_youngest_42 nonbiochildboy_total_42 nonbiochildgirl_total_42 anychildren_42 children_tot_42 childy_eldest_42 childy_youngest_42 childboy_total_42 childgirl_total_42 partnerchildbio_42 partnerchildany_42   {

replace `Y'=-100 if `Y'==. & ncdssurvey_42==0 
replace `Y'=-99 if `Y'==. 	
fre `Y'	
}


*age 46
foreach Y of varlist intyear_46 intmonth_46 partner_46 marital_46 anybiochildren_46 biochild_tot_46 biochildhh_total_46 biochild_extra_flag_46 biochildnonhh_total_46 biochildy_eldest_46 biochildy_youngest_46 cmageybirth_eldest_46 cmageybirth_youngest_46 biochildboy_total_46 biochildgirl_total_46 anynonbio_46 nonbiochild_tot_46 adopt_tot_46 foster_tot_46 step_tot_46 nonbiochildy_eldest_46 nonbiochildy_youngest_46 nonbiochildboy_total_46 nonbiochildgirl_total_46 anychildren_46 children_tot_46 childy_eldest_46 childy_youngest_46 childboy_total_46 childgirl_total_46 partnerchildbio_46 partnerchildany_46   {

replace `Y'=-100 if `Y'==. & ncdssurvey_46==0 
replace `Y'=-99 if `Y'==. 	
fre `Y'	
}


*age 50
foreach Y of varlist intyear_50 intmonth_50 partner_50 marital_50 anybiochildren_50 biochild_tot_50 biochildhh_total_50 biochild_extra_flag_50 biochildnonhh_total_50 biochildy_eldest_50 biochildy_youngest_50 cmageybirth_eldest_50 cmageybirth_youngest_50 biochildboy_total_50 biochildgirl_total_50 anynonbio_50 nonbiochild_tot_50 adopt_tot_50 foster_tot_50 step_tot_50 nonbiochildy_eldest_50 nonbiochildy_youngest_50 nonbiochildboy_total_50 nonbiochildgirl_total_50 anychildren_50 children_tot_50 childy_eldest_50 childy_youngest_50 childboy_total_50 childgirl_total_50 partnerchildbio_50 partnerchildany_50  {

replace `Y'=-100 if `Y'==. & ncdssurvey_50==0 
replace `Y'=-99 if `Y'==. 	
fre `Y'	
}





*cross sweep missingness
replace biototal_flag_23_33=-100 if biototal_flag_23_33==. & (ncdssurvey_23==0 | ncdssurvey_33==0)
replace biototal_flag_23_33=-99 if biototal_flag_23_33==. 	
fre biototal_flag_23_33	

replace biototal_flag_33_42=-100 if biototal_flag_33_42==. & (ncdssurvey_33==0 | ncdssurvey_42==0)
replace biototal_flag_33_42=-99 if biototal_flag_33_42==. 	
fre biototal_flag_33_42	

replace biototal_flag_42_46=-100 if biototal_flag_42_46==. & (ncdssurvey_42==0 | ncdssurvey_46==0)
replace biototal_flag_42_46=-99 if biototal_flag_42_46==. 	
fre biototal_flag_42_46	

replace biototal_flag_46_50=-100 if biototal_flag_46_50==. & (ncdssurvey_46==0 | ncdssurvey_50==0)
replace biototal_flag_46_50=-99 if biototal_flag_46_50==. 	
fre biototal_flag_46_50	






/*
//generates output for excel sheet for summary variable names and labels
foreach v of varlist _all   {
    display `"`v':"', `"`:var label `v''"'
}
*/

label var	adopt_tot_33	"Number of adopted children in HH (age 33)"
label var	adopt_tot_42	"Number of adopted children in HH (age 42)"
label var	adopt_tot_46	"Number of adopted children in HH (age 46)"
label var	adopt_tot_50	"Number of adopted children in HH (age 50)"
label var	anybiochildren_23	"Whether has had any bio children (age 23)"
label var	anybiochildren_33	"Whether has had any bio children (age 33)"
label var	anybiochildren_42	"Whether has had any bio children (age 42)"
label var	anybiochildren_46	"Whether has had any bio children (age 46)"
label var	anybiochildren_50	"Whether has had any bio children (age 50)"
label var	anychildren_23	"Whether has any children (bio or non-bio) (age 23)"
label var	anychildren_33	"Whether has any children (bio or non-bio) (age 33)"
label var	anychildren_42	"Whether has any children (bio or non-bio) (age 42)"
label var	anychildren_46	"Whether has any children (bio or non-bio) (age 46)"
label var	anychildren_50	"Whether has any children (bio or non-bio) (age 50)"
label var	anynonbio_23	"Whether has any non-bio children in HH (age 23)"
label var	anynonbio_33	"Whether has any non-bio children in HH (age 33)"
label var	anynonbio_42	"Whether has any non-bio children in HH (age 42)"
label var	anynonbio_46	"Whether has any non-bio children in HH (age 46)"
label var	anynonbio_50	"Whether has any non-bio children in HH (age 50)"
label var	biochild_extra_flag_33	"Flag: More bio children reported in HH grid than in pregnancy data (age 33)"
label var	biochild_extra_flag_42	"Flag: More bio children reported in HH grid than in pregnancy data (age 42)"
label var	biochild_extra_flag_46	"Flag: More bio children reported in HH grid than in pregnancy data (age 46)"
label var	biochild_extra_flag_50	"Flag: More bio children reported in HH grid than in pregnancy data (age 50)"
label var	biochild_tot_23	"Number of bio children (age 23)"
label var	biochild_tot_33	"Number of bio children (age 33)"
label var	biochild_tot_42	"Number of bio children (age 42)"
label var	biochild_tot_46	"Number of bio children (age 46)"
label var	biochild_tot_50	"Number of bio children (age 50)"
label var	biochildboy_total_23	"Number of bio children who are boys (age 23)"
label var	biochildboy_total_33	"Number of bio children who are boys (age 33)"
label var	biochildboy_total_42	"Number of bio children who are boys (age 42)"
label var	biochildboy_total_46	"Number of bio children who are boys (age 46)"
label var	biochildboy_total_50	"Number of bio children who are boys (age 50)"
label var	biochildgirl_total_23	"Number of bio children who are girls (age 23)"
label var	biochildgirl_total_33	"Number of bio children who are girls (age 33)"
label var	biochildgirl_total_42	"Number of bio children who are girls (age 42)"
label var	biochildgirl_total_46	"Number of bio children who are girls (age 46)"
label var	biochildgirl_total_50	"Number of bio children who are girls (age 50)"
label var	biochildhh_total_23	"Number of bio children in HH (age 23)"
label var	biochildhh_total_33	"Number of bio children in HH (age 33)"
label var	biochildhh_total_42	"Number of bio children in HH (age 42)"
label var	biochildhh_total_46	"Number of bio children in HH (age 46)"
label var	biochildhh_total_50	"Number of bio children in HH (age 50)"
label var	biochildnonhh_total_23	"Number of bio children not in HH (age 23)"
label var	biochildnonhh_total_33	"Number of bio children not in HH (age 33)"
label var	biochildnonhh_total_42	"Number of bio children not in HH (age 42)"
label var	biochildnonhh_total_46	"Number of bio children not in HH (age 46)"
label var	biochildnonhh_total_50	"Number of bio children not in HH (age 50)"
label var	biochildprev_total_33	"Number of bio children had with a previous partner (age 33)"
label var	biochildprevany_33	"Have had any bio children with a previous partner (33)"
label var	biochildy_eldest_23	"Age in years of eldest bio child (age 23)"
label var	biochildy_eldest_33	"Age in years of eldest bio child (age 33)"
label var	biochildy_eldest_42	"Age in years of eldest bio child (age 42)"
label var	biochildy_eldest_46	"Age in years of eldest bio child (age 46)"
label var	biochildy_eldest_50	"Age in years of eldest bio child (age 50)"
label var	biochildy_youngest_23	"Age in years of youngest bio child (age 23)"
label var	biochildy_youngest_33	"Age in years of youngest bio child (age 33)"
label var	biochildy_youngest_42	"Age in years of youngest bio child (age 42)"
label var	biochildy_youngest_46	"Age in years of youngest bio child (age 46)"
label var	biochildy_youngest_50	"Age in years of youngest bio child (age 50)"
label var	childboy_total_23	"Number of children who are boys (bio or non-bio) (age 23)"
label var	childboy_total_33	"Number of children who are boys (bio or non-bio) (age 33)"
label var	childboy_total_42	"Number of children who are boys (bio or non-bio) (age 42)"
label var	childboy_total_46	"Number of children who are boys (bio or non-bio) (age 46)"
label var	childboy_total_50	"Number of children who are boys (bio or non-bio) (age 50)"
label var	childgirl_total_23	"Number of children who are girls (bio or non-bio) (age 23)"
label var	childgirl_total_33	"Number of children who are girls (bio or non-bio) (age 33)"
label var	childgirl_total_42	"Number of children who are girls (bio or non-bio) (age 42)"
label var	childgirl_total_46	"Number of children who are girls (bio or non-bio) (age 46)"
label var	childgirl_total_50	"Number of children who are girls (bio or non-bio) (age 50)"
label var	children_tot_23	"Number of children (bio or non-bio) (age 23)"
label var	children_tot_33	"Number of children (bio or non-bio) (age 33)"
label var	children_tot_42	"Number of children (bio or non-bio) (age 42)"
label var	children_tot_46	"Number of children (bio or non-bio) (age 46)"
label var	children_tot_50	"Number of children (bio or non-bio) (age 50)"
label var	childy_eldest_23	"Age in years (categories) of eldest child (bio or non-bio) (age 23)"
label var	childy_eldest_33	"Age in years of eldest child (bio or non-bio) (age 33)"
label var	childy_eldest_42	"Age in years of eldest child (bio or non-bio) (age 42)"
label var	childy_eldest_46	"Age in years of eldest child (bio or non-bio) (age 46)"
label var	childy_eldest_50	"Age in years of eldest child (bio or non-bio) (age 50)"
label var	childy_youngest_23	"Age in years (categories) of youngest child (bio or non-bio) (age 23)"
label var	childy_youngest_33	"Age in years of youngest child (bio or non-bio) (age 33)"
label var	childy_youngest_42	"Age in years of youngest child (bio or non-bio) (age 42)"
label var	childy_youngest_46	"Age in years of youngest child (bio or non-bio) (age 46)"
label var	childy_youngest_50	"Age in years of youngest child (bio or non-bio) (age 50)"
label var	cmageybirth_eldest_23	"Age in years of CM at birth of eldest bio child (age 23)"
label var	cmageybirth_eldest_33	"Age in years of CM at birth of eldest bio child (age 33)"
label var	cmageybirth_eldest_42	"Age in years of CM at birth of eldest bio child (age 42)"
label var	cmageybirth_eldest_46	"Age in years of CM at birth of eldest bio child (age 46)"
label var	cmageybirth_eldest_50	"Age in years of CM at birth of eldest bio child (age 50)"
label var	cmageybirth_youngest_23	"Age in years of CM at birth of youngest bio child (age 23)"
label var	cmageybirth_youngest_33	"Age in years of CM at birth of youngest bio child (age 33)"
label var	cmageybirth_youngest_42	"Age in years of CM at birth of youngest bio child (age 42)"
label var	cmageybirth_youngest_46	"Age in years of CM at birth of youngest bio child (age 46)"
label var	cmageybirth_youngest_50	"Age in years of CM at birth of youngest bio child (age 50)"
label var	cmbmonth	"Birth month of CM"
label var	cmbyear	"Birth year of CM"
label var	foster_tot_23	"Number of foster children in HH (age 23)"
label var	foster_tot_33	"Number of foster children in HH (age 33)"
label var	foster_tot_42	"Number of foster children in HH (age 42)"
label var	foster_tot_46	"Number of foster children in HH (age 46)"
label var	foster_tot_50	"Number of foster children in HH (age 50)"
label var	intmonth_23	"Interview month (age 23)"
label var	intmonth_33	"Interview month (age 33)"
label var	intmonth_42	"Interview month (age 42)"
label var	intmonth_46	"Interview month (age 46)"
label var	intmonth_50	"Interview month (age 50)"
label var	intyear_23	"Interview year (age 23)"
label var	intyear_33	"Interview year (age 33)"
label var	intyear_42	"Interview year (age 42)"
label var	intyear_46	"Interview year (age 46)"
label var	intyear_50	"Interview year (age 50)"
label var	marital_23	"Marital status (age 23)"
label var	marital_33	"Marital status (age 33)"
label var	marital_42	"Marital status (age 42)"
label var	marital_46	"Marital status (age 46)"
label var	marital_50	"Marital status (age 50)"
label var	ncdssurvey_23	"Whether took part in age 23 survey"
label var	ncdssurvey_33	"Whether took part in age 33 survey"
label var	ncdssurvey_42	"Whether took part in age 42 survey"
label var	ncdssurvey_46	"Whether took part in age 46 survey"
label var	ncdssurvey_50	"Whether took part in age 50 survey"
label var	ncdsid	"ncdsid serial number"
label var	nonbiochild_tot_23	"Number of non-bio children in HH (age 23)"
label var	nonbiochild_tot_33	"Number of non-bio children in HH (age 33)"
label var	nonbiochild_tot_42	"Number of non-bio children in HH (age 42)"
label var	nonbiochild_tot_46	"Number of non-bio children in HH (age 46)"
label var	nonbiochild_tot_50	"Number of non-bio children in HH (age 50)"
label var	nonbiochildboy_total_23	"Number of non-bio children who are boys (age 23)"
label var	nonbiochildboy_total_33	"Number of non-bio children who are boys (age 33)"
label var	nonbiochildboy_total_42	"Number of non-bio children who are boys (age 42)"
label var	nonbiochildboy_total_46	"Number of non-bio children who are boys (age 46)"
label var	nonbiochildboy_total_50	"Number of non-bio children who are boys (age 50)"
label var	nonbiochildgirl_total_23	"Number of non-bio children who are girls (age 23)"
label var	nonbiochildgirl_total_33	"Number of non-bio children who are girls (age 33)"
label var	nonbiochildgirl_total_42	"Number of non-bio children who are girls (age 42)"
label var	nonbiochildgirl_total_46	"Number of non-bio children who are girls (age 46)"
label var	nonbiochildgirl_total_50	"Number of non-bio children who are girls (age 50)"
label var	nonbiochildy_eldest_23	"Age in years (categories) of eldest non-bio child (age 23)"
label var	nonbiochildy_eldest_33	"Age in years of eldest non-bio child (age 33)"
label var	nonbiochildy_eldest_42	"Age in years of eldest non-bio child (age 42)"
label var	nonbiochildy_eldest_46	"Age in years of eldest non-bio child (age 46)"
label var	nonbiochildy_eldest_50	"Age in years of eldest non-bio child (age 50)"
label var	nonbiochildy_youngest_23	"Age in years (categories) of youngest non-bio child (age 23)"
label var	nonbiochildy_youngest_33	"Age in years of youngest non-bio child (age 33)"
label var	nonbiochildy_youngest_42	"Age in years of youngest non-bio child (age 42)"
label var	nonbiochildy_youngest_46	"Age in years of youngest non-bio child (age 46)"
label var	nonbiochildy_youngest_50	"Age in years of youngest non-bio child (age 50)"
label var	partner_23	"Whether has a partner in HH (age 23)"
label var	partner_33	"Whether has a partner in HH (age 33)"
label var	partner_42	"Whether has a partner in HH (age 42)"
label var	partner_46	"Whether has a partner in HH (age 46)"
label var	partner_50	"Whether has a partner in HH (age 50)"
label var	partnerchildany_23	"Whether has live-in partner/spouse and/or any bio or non-bio children (Age 23)"
label var	partnerchildany_33	"Whether has live-in partner/spouse and/or any bio or non-bio children (age 33)"
label var	partnerchildany_42	"Whether has live-in partner/spouse and/or any bio or non-bio children (age 42)"
label var	partnerchildany_46	"Whether has live-in partner/spouse and/or any bio or non-bio children (age 46)"
label var	partnerchildany_50	"Whether has live-in partner/spouse and/or any bio or non-bio children (age 50)"
label var	partnerchildbio_23	"Whether has live-in partner/spouse and/or any bio children (asbsent or in HH) (age 23)"
label var	partnerchildbio_33	"Whether has live-in partner/spouse and/or any bio children (asbsent or in HH) (age 33)"
label var	partnerchildbio_42	"Whether has live-in partner/spouse and/or any bio children (asbsent or in HH) (age 42)"
label var	partnerchildbio_46	"Whether has live-in partner/spouse and/or any bio children (asbsent or in HH) (age 46)"
label var	partnerchildbio_50	"Whether has live-in partner/spouse and/or any bio children (asbsent or in HH) (age 50)"
label var	sex	"sex of cohort member"
label var	step_tot_23	"Number of stepchildren in HH (age 23)"
label var	step_tot_33	"Number of stepchildren in HH (age 33)"
label var	step_tot_42	"Number of stepchildren in HH (age 42)"
label var	step_tot_46	"Number of stepchildren in HH (age 46)"
label var	step_tot_50	"Number of stepchildren in HH (age 50)"



*** keep variables
keep ncdsid	sex	cmbyear	cmbmonth	ncdssurvey_23	intmonth_23	intyear_23	partner_23	marital_23	anybiochildren_23	biochild_tot_23	biochildhh_total_23	biochildnonhh_total_23		biochildboy_total_23	biochildgirl_total_23	biochildy_eldest_23	biochildy_youngest_23	cmageybirth_eldest_23	cmageybirth_youngest_23	anynonbio_23	nonbiochild_tot_23	foster_tot_23	step_tot_23	nonbiochildy_eldest_23	nonbiochildy_youngest_23	nonbiochildboy_total_23	nonbiochildgirl_total_23	anychildren_23	children_tot_23	childy_eldest_23	childy_youngest_23	childboy_total_23	childgirl_total_23	partnerchildbio_23	partnerchildany_23	n4924_23	n4925_23	ncdssurvey_33	intyear_33	intmonth_33	partner_33	marital_33	biochild_tot_33	biochild_extra_flag_33	anybiochildren_33	biochildhh_total_33	biochildnonhh_total_33	biochildprev_total_33	biochildprevany_33	biochildboy_total_33	biochildgirl_total_33	biochildy_eldest_33	biochildy_youngest_33	cmageybirth_eldest_33	cmageybirth_youngest_33	anynonbio_33	nonbiochild_tot_33	adopt_tot_33	foster_tot_33	step_tot_33	nonbiochildy_eldest_33	nonbiochildy_youngest_33	nonbiochildboy_total_33	nonbiochildgirl_total_33	anychildren_33	children_tot_33	childy_eldest_33	childy_youngest_33	childboy_total_33	childgirl_total_33	partnerchildbio_33	partnerchildany_33	ncdssurvey_42	intyear_42	intmonth_42	partner_42	marital_42	biochild_tot_42	biochildhh_total_42	biochild_extra_flag_42	anybiochildren_42	biochildnonhh_total_42	biochildboy_total_42	biochildgirl_total_42	biochildy_eldest_42	biochildy_youngest_42	cmageybirth_eldest_42	cmageybirth_youngest_42	anynonbio_42	nonbiochild_tot_42	adopt_tot_42	foster_tot_42	step_tot_42	nonbiochildy_eldest_42	nonbiochildy_youngest_42	nonbiochildboy_total_42	nonbiochildgirl_total_42	anychildren_42	children_tot_42	childy_eldest_42	childy_youngest_42	childboy_total_42	childgirl_total_42	partnerchildbio_42	partnerchildany_42	numadch_42	ownchild_42	ncdssurvey_46	intyear_46	intmonth_46	partner_46	marital_46	biochild_tot_46	biochildhh_total_46	biochild_extra_flag_46	anybiochildren_46	biochildnonhh_total_46	biochildboy_total_46	biochildgirl_total_46	biochildy_eldest_46	biochildy_youngest_46	cmageybirth_eldest_46	cmageybirth_youngest_46	anynonbio_46	nonbiochild_tot_46	adopt_tot_46	foster_tot_46	step_tot_46	nonbiochildy_eldest_46	nonbiochildy_youngest_46	nonbiochildboy_total_46	nonbiochildgirl_total_46	anychildren_46	children_tot_46	childy_eldest_46	childy_youngest_46	childboy_total_46	childgirl_total_46	partnerchildbio_46	partnerchildany_46	nd7spphh_46	nd7nchhh_46	nd7ochhh_46	n7numadh_46	ncdssurvey_50	intyear_50	intmonth_50	partner_50	marital_50	biochild_tot_50	biochildhh_total_50	biochild_extra_flag_50	anybiochildren_50	biochildnonhh_total_50	biochildboy_total_50	biochildgirl_total_50	biochildy_eldest_50	biochildy_youngest_50	cmageybirth_eldest_50	cmageybirth_youngest_50	anynonbio_50	nonbiochild_tot_50	adopt_tot_50	foster_tot_50	step_tot_50	nonbiochildy_eldest_50	nonbiochildy_youngest_50	nonbiochildboy_total_50	nonbiochildgirl_total_50	anychildren_50	children_tot_50	childy_eldest_50	childy_youngest_50	childboy_total_50	childgirl_total_50	partnerchildbio_50	partnerchildany_50	ND8SPPHH_50	ND8NCHHH_50	ND8OCHHH_50	ND8NCHAB_50	ND8OCHAB_50	ND8NCHTT_50 biototal_flag_23_33 biototal_flag_33_42 biototal_flag_42_46 biototal_flag_46_50

drop n4924_23	n4925_23	numadch_42	ownchild_42	nd7spphh_46	nd7nchhh_46	nd7ochhh_46	n7numadh_46	ND8SPPHH_50	ND8NCHHH_50	ND8OCHHH_50	ND8NCHAB_50	ND8OCHAB_50	ND8NCHTT_50

order ncdsid	sex	cmbyear	cmbmonth ncdssurvey_23	intyear_23 intmonth_23			partner_23	marital_23	anybiochildren_23	biochild_tot_23	biochildhh_total_23		biochildnonhh_total_23		biochildy_eldest_23	biochildy_youngest_23	cmageybirth_eldest_23	cmageybirth_youngest_23	biochildboy_total_23	biochildgirl_total_23	anynonbio_23	nonbiochild_tot_23		foster_tot_23	step_tot_23	nonbiochildy_eldest_23	nonbiochildy_youngest_23	nonbiochildboy_total_23	nonbiochildgirl_total_23	anychildren_23	children_tot_23	childy_eldest_23	childy_youngest_23	childboy_total_23	childgirl_total_23	partnerchildbio_23	partnerchildany_23	ncdssurvey_33	intyear_33	intmonth_33		partner_33	marital_33	anybiochildren_33	biochild_tot_33 biototal_flag_23_33	biochildhh_total_33	biochild_extra_flag_33	biochildnonhh_total_33		biochildprev_total_33	biochildprevany_33	biochildy_eldest_33	biochildy_youngest_33	cmageybirth_eldest_33	cmageybirth_youngest_33	biochildboy_total_33	biochildgirl_total_33	anynonbio_33	nonbiochild_tot_33	adopt_tot_33	foster_tot_33	step_tot_33	nonbiochildy_eldest_33	nonbiochildy_youngest_33	nonbiochildboy_total_33	nonbiochildgirl_total_33	anychildren_33	children_tot_33	childy_eldest_33	childy_youngest_33	childboy_total_33	childgirl_total_33	partnerchildbio_33	partnerchildany_33	ncdssurvey_42	intyear_42	intmonth_42		partner_42	marital_42	anybiochildren_42	biochild_tot_42 biototal_flag_33_42	biochildhh_total_42	biochild_extra_flag_42	biochildnonhh_total_42					biochildy_eldest_42	biochildy_youngest_42	cmageybirth_eldest_42	cmageybirth_youngest_42	biochildboy_total_42	biochildgirl_total_42	anynonbio_42	nonbiochild_tot_42	adopt_tot_42	foster_tot_42	step_tot_42	nonbiochildy_eldest_42	nonbiochildy_youngest_42	nonbiochildboy_total_42	nonbiochildgirl_total_42	anychildren_42	children_tot_42	childy_eldest_42	childy_youngest_42	childboy_total_42	childgirl_total_42	partnerchildbio_42	partnerchildany_42	ncdssurvey_46	intyear_46	intmonth_46		partner_46	marital_46	anybiochildren_46	biochild_tot_46 biototal_flag_42_46	biochildhh_total_46	biochild_extra_flag_46	biochildnonhh_total_46					biochildy_eldest_46	biochildy_youngest_46	cmageybirth_eldest_46	cmageybirth_youngest_46	biochildboy_total_46	biochildgirl_total_46	anynonbio_46	nonbiochild_tot_46	adopt_tot_46	foster_tot_46	step_tot_46	nonbiochildy_eldest_46	nonbiochildy_youngest_46	nonbiochildboy_total_46	nonbiochildgirl_total_46	anychildren_46	children_tot_46	childy_eldest_46	childy_youngest_46	childboy_total_46	childgirl_total_46	partnerchildbio_46	partnerchildany_46	ncdssurvey_50	intyear_50	intmonth_50		partner_50	marital_50	anybiochildren_50	biochild_tot_50 biototal_flag_46_50	biochildhh_total_50	biochild_extra_flag_50	biochildnonhh_total_50					biochildy_eldest_50	biochildy_youngest_50	cmageybirth_eldest_50	cmageybirth_youngest_50	biochildboy_total_50	biochildgirl_total_50	anynonbio_50	nonbiochild_tot_50	adopt_tot_50	foster_tot_50	step_tot_50	nonbiochildy_eldest_50	nonbiochildy_youngest_50	nonbiochildboy_total_50	nonbiochildgirl_total_50	anychildren_50	children_tot_50	childy_eldest_50	childy_youngest_50	childboy_total_50	childgirl_total_50	partnerchildbio_50	partnerchildany_50


save "$derived\NCDS _fertility _histories.dta", replace



