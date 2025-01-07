

global orig "C:\Users\aase_\OneDrive - University College London\05 UCL\6.1-Next Steps\Original data"

global project "C:\Users\aase_\OneDrive - University College London\05 UCL\6.12-Harmonisation (relationships and fertility)\Next Steps"


clear all
set maxvar 30000
set more off




*------------------------------------------------------------------------------*
*------------------------------------------------------------------------------*
**# Bookmark #3

*********************************************************
***** AGE 25 *****

//LONGIDUDINAL FILE
use "$orig\ns9_2022_longitudinal_file", clear
//has weights
keep NSID SAMPPSU SAMPSTRATUM DESIGNWEIGHT MAINBOOST  W8OUTCOME W8FINWT
keep if W8OUTCOME==1
//N=7707
gen nssurvey=1
label var nssurvey "Whether took part in age 25 survey"


//WAVE ONE DATA
merge 1:1 NSID using "$orig\wave_one_lsype_young_person_2020", keepusing(W1sexYP DobyearYP DobmonthYP)
drop _merge
keep if W8OUTCOME==1


//MAIN INTERVIEW 
//N=7707
merge 1:1 NSID using "$orig\ns8_2015_main_interview.dta", keepusing(W8INTMTH W8INTYEAR W8BDATM W8BDATY W8HMS W8NRANY W8PART W8DOHMANY W8CMSEX)
drop _merge


//HOUSEHOLD MEMBERS
//long data: N=9378
merge 1:m NSID using "$orig\ns8_2015_household_members.dta"
drop _merge
codebook NSID // N=7707


//CHILD DATA
//long fata //N=2240
merge m:m NSID using "$orig\ns8_2015_children.dta"
drop _merge
codebook NSID //=7707


************************************************************


*in a relationship
fre W8PART

*Number of others who live here all or some of the time: 1-10, -9=refused, -1=not applicable (likely those who live alone as no 0 in the range)
fre W8DOHMANY


//partner (age 25)
*cohabiting: 1=yes, 2=no, -9=refused
fre W8NRANY
cap drop partner
gen partner=.
replace partner=1 if W8NRANY==1
replace partner=0 if W8NRANY==2
label define partner 0 "No" 1 "Yes" -100 "no participation in sweep" -99 "information not provided", replace
label values partner partner
label var partner "Whether CM has current partner in hhld"
fre partner


//marital status (age 25)
fre W8HMS
cap drop marital
gen marital=.
replace marital=3 if W8HMS==1|W8HMS==3|W8HMS==4|W8HMS==5|W8HMS==7|W8HMS==8|W8HMS==9 //single non cohab
replace marital=2 if (W8HMS==1|W8HMS==3|W8HMS==4|W8HMS==5|W8HMS==7|W8HMS==8|W8HMS==9) & partner==1 //single cohab
replace marital=1 if W8HMS==2|W8HMS==6 //married/civil partnered
replace marital=-99 if marital==.
label define marital 1 "Married or Civil Partnered" 2 "Single cohabiting with partner" 3 "Single non-cohabiting" -100 "no participation in sweep" -99 "information not provided", replace
label values marital marital
label variable marital "Marital status (age 25)" 
fre marital





************************** BIOLOGICAL CHILDREN (age 25) *****************************

*** WHETHER HAD ANY BIOLOGICAL CHILDREN AND TOTAL NUMBER (age 25)

*child relationship to respondent: 1=own child, 2=adopted, 3=current or previous partner's child, 5=other
fre W8NCHREL
cap drop biochild
gen biochild=.
replace biochild=1 if W8NCHREL==1
fre biochild

*any biological children (age 25)
cap drop anybiochildren
egen anybiochildren = total(biochild==1), by (NSID)
replace anybiochildren=1 if inrange(anybiochildren,1,20)
label variable anybiochildren "Whether CM has had any biological children"
label define yesno 0 "No" 1 "Yes" -100 "no participation in sweep" -99 "information not provided", replace
label values anybiochildren yesno
fre anybiochildren

*total number of biological children (age 25)
cap drop biochild_tot
egen biochild_tot = count(biochild), by (NSID)
label define biochild_tot 0 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values biochild_tot biochild_tot
label variable biochild_tot "Total number of biological children"
fre biochild_tot



*-------------------------------------------------------------------*
*** AGES OF BIOLOGICAL CHILDREN AND COHORT MEMBER AGE AT BIRTH (age 25)


//interview date (age 25)
fre W8INTMTH
fre W8INTYEAR
rename (W8INTMTH W8INTYEAR) (intmonth intyear)

label define intyear -100 "no participation in sweep" -99 "information not provided", replace
label values intyear intyear

label define intmonth 1 "January" 2	"February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "	October" 11 "November" 12 "December" -100 "no participation in sweep" -99 "information not provided", replace
label values intmonth intmonth

cap drop intym
gen intym = ym(intyear,intmonth)
label var intym "Interview date - months since Jan 1960"
fre intym




//cohort member birthdate (age 25)

*birth month of CM: 1-12, no missing
fre W8BDATM
*birth year of CM: 1988-1992, none missing, very few other years than 1989 and 1990
fre W8BDATY

rename (W8BDATM W8BDATY) (cmbirthm cmbirthy)

label var cmbirthy "Birth year of CM"
fre cmbirthy
label var cmbirthm "Birth month of CM"
fre cmbirthm

cap drop cmbirthym
gen cmbirthym = ym(cmbirthy,cmbirthm)
label var cmbirthym "CM birth date - months since Jan 1960"
fre cmbirthym





//date of birth of biological child since Jan 1960 (age 25)

*child month of birth: 1-12, -9=refused
fre W8NCHDOBM
replace W8NCHDOBM=. if W8NCHDOBM==-9

*child year of birth: 2000-2016, =9=refused
fre W8NCHDOBY
replace W8NCHDOBY=. if W8NCHDOBY==-9

cap drop biochildym
gen biochildym = ym(W8NCHDOBY, W8NCHDOBM) if biochild==1
label var biochildym "Date of birth of biological child - months since Jan 1960"
fre biochildym



//child's age in whole years at interview (age 25)
cap drop biochildagey
gen biochildagey = (intym-biochildym)/12
replace biochildagey=0 if biochildagey<0
fre biochildagey
replace biochildagey = floor(biochildagey)
label var biochildagey " Age in whole years of biological child"
fre biochildagey //range 0-11


//cm age in whole years at birth of child (age 25)
cap drop cmageybirth
gen cmageybirth = (biochildym-cmbirthym)/12
fre cmageybirth
replace cmageybirth = floor(cmageybirth)
label var cmageybirth "Age of CM in years at birth of biological child"
fre cmageybirth




***SUMMARY age of eldest and youngest biological child (in years and months) (age 25)

*eldest in years (age 25)
cap drop biochildy_eldest
egen biochildy_eldest = max(biochildagey), by (NSID)
replace biochildy_eldest= -10 if anybiochildren==0
label define minusten -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildy_eldest minusten
label var biochildy_eldest "Age in years of eldest biological child"
fre  biochildy_eldest

*youngest in years (age 25)
cap drop biochildy_youngest
egen biochildy_youngest = min(biochildagey), by (NSID)
replace biochildy_youngest= -10 if anybiochildren==0
label values biochildy_youngest minusten
label var biochildy_youngest "Age in years of youngest biological child"
fre  biochildy_youngest



***SUMMARY age of cohort member at birth of eldest and youngest child (in years and in months) (age 25)

cap drop cmageybirth_eldest //years
egen cmageybirth_eldest = min(cmageybirth), by (NSID)
replace cmageybirth_eldest= -10 if anybiochildren==0
label values cmageybirth_eldest minusten
label var cmageybirth_eldest "CM age in years at birth of eldest biological child"
fre  cmageybirth_eldest

cap drop cmageybirth_youngest //years
egen cmageybirth_youngest = max(cmageybirth), by (NSID)
replace cmageybirth_youngest= -10 if anybiochildren==0
label values cmageybirth_youngest minusten
label var cmageybirth_youngest "CM age in years at birth of youngest biological child"
fre  cmageybirth_youngest




*-------------------------------------------------------------------*
*** SEX OF BIOLOGICAL CHILDREN (age 25)
*child sex: 1=male, 2=female, -9=refused
fre W8NCHSEX
replace W8NCHSEX=. if W8NCHSEX<0

cap drop biochildsex
gen biochildsex=.
replace biochildsex=W8NCHSEX if biochild==1
label variable biochildsex "Sex of -biological child"
label define biochildsex 1 "male" 2 "female" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildsex biochildsex
fre biochildsex

//total boys (age 25)
cap drop biochildboy_total
egen biochildboy_total= total(biochildsex==1), by (NSID)
replace biochildboy_total=-10 if anybiochildren==0
label define biochildboy_total 0 "Girls only" -10 "No non-biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values biochildboy_total biochildboy_total
label var biochildboy_total "Total number of biological children who are boys"
fre biochildboy_total

//total girls (age 25)
cap drop biochildgirl_total
egen biochildgirl_total= total(biochildsex==2), by (NSID)
replace biochildgirl_total=-10 if anybiochildren==0
label define biochildgirl_total 0 "Boys only" -10 "No non-biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values biochildgirl_total biochildgirl_total
label var biochildgirl_total "Total number of biological children who are girls"
fre biochildgirl_total





*-------------------------------------------------------------------*
*** WHERE BIOLOGICAL CHILDREN LIVE (age 25)
*whether child lives with CM: 1=yes all of the time, 2=yes some of the time, 3=no, -9=refused
fre W8NCHPRES

//in household (age 25)
cap drop biochildhh
gen biochildhh=.
replace biochildhh=1 if biochild==1 & (W8NCHPRES==1|W8NCHPRES==2)
label variable biochildhh "Child lives in household"
fre biochildhh

cap drop biochildhh_total 
egen biochildhh_total = count(biochildhh), by (NSID)
replace biochildhh_total=-10 if anybiochildren==0
label define biochildhh_total 0 "None of CM's biological children live in household" -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildhh_total biochildhh_total
label variable biochildhh_total "Total number of bio children in household (HH grid data)"
fre biochildhh_total



//not in household (age 25)
cap drop biochildnonhh
gen biochildnonhh=.
replace biochildnonhh=1 if biochild==1 & W8NCHPRES==3 
label variable biochildnonhh "Child lives outside household"
fre biochildnonhh

cap drop biochildnonhh_total
egen biochildnonhh_total = count(biochildnonhh), by (NSID)
replace biochildnonhh_total=-10 if anybiochildren==0
label define biochildnonhh_total 0 "All biological children live in household" -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildnonhh_total biochildnonhh_total
label variable biochildnonhh_total "Total number of bio children not in household"
fre biochildnonhh_total




*-------------------------------------------------------------------*
*** OTHER PARENT OF BIOLOGICAL CHILDREN (age 25)

*Whether cohabiting partner's child: 1=yes, 2=no, -1=not applicable, -9=refused
fre W8NCHRELP

*in a relationships: 1=yes, 2=no, -1=not applicable, -9=refused
fre W8PART


//previous partner's child (age 25)
cap drop biochildprev
gen biochildprev=.
replace biochildprev=1 if biochild==1 & (W8NCHRELP==2|(partner==0 & W8PART==2))
label variable biochildprev "Bio child's other parent is previous partner"
fre biochildprev

cap drop biochildprev_total
egen biochildprev_total = count(biochildprev), by (NSID)
replace biochildprev_total=-10 if anybiochildren==0
label define biochildprev_total 0 "Current partner(s) parent to all biological children" -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildprev_total biochildprev_total
label variable biochildprev_total "Total number of biological children had with a previous partner"
fre biochildprev_total

//whether a previous partner is parent to any children (age 25)
cap drop biochildprevany
gen biochildprevany=.
replace biochildprevany=1 if inrange(biochildprev_total,1,10)
replace biochildprevany=0 if biochildprev_total==0
replace biochildprevany=-10 if biochildprev_total==-10
label variable biochildprevany "Any children with a previous partner"
label define biochildprevany 1 "Previous partner parent to all or some biological children" 0 "Current partner is parent to all biological children" -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildprevany biochildprevany
fre biochildprevany




*-------------------------------------------------------------------*
***BIOLOGICAL CHILDREN WHO HAVE DIED (age 25)

*children who have died
cap drop deadchild
gen deadchild=.
replace deadchild=1 if biochild==1 & W8CHDLIVE==9

cap drop biodied_total
egen biodied_total = count(deadchild), by (NSID)
fre biodied_total
replace biodied_total=-10 if anybiochildren==0
label define biodied_total 0 "All biological children alive" -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biodied_total biodied_total
label var biodied_total "Total number of biological children that had died"
fre biodied_total 

cap drop anybiodied
gen anybiodied=.
replace anybiodied=1 if inrange(biodied_total,1,5)
replace anybiodied=0 if biodied_total==0
replace anybiodied=-10 if anybiochildren==0
label define anybiodied 0 "No" 1 "Yes" -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values anybiodied anybiodied
label variable anybiodied "Whether any bio children have died"
fre anybiodied




************************** NON BIOLOGICAL CHILDREN (age 25)
**************************

*---------------------------------------------------------------------*
//note: looks like we need to use non bio from both child and household grid children. The child grid is all children who CM considers themselves a parent to, and HH grid are all other children in HH (note that own children are not included here). Limit child grid non-bio to those that live in the HH for variables to be cosistent with other cohorts.

//HH grid
*relationship of HH member to CM: 6=child of current/previous partner,7=fostered child
fre W8RELTOKEY

//CHILD GRID
*child relationship to respondent: 1=own child, 2=adopted, 3=current or previous partner's child, 5=other
fre W8NCHREL

cap drop nonbiochild
gen nonbiochild=.
replace nonbiochild=1 if (W8RELTOKEY==6|W8RELTOKEY==7) //HH grid
replace nonbiochild=1 if (W8NCHREL==2|W8NCHREL==3) & (W8NCHPRES==1|W8NCHPRES==2) //child grid
label variable nonbiochild "Child is non-biological"
fre nonbiochild


cap drop adopt
gen adopt=.
replace adopt=1 if (W8NCHREL==2) & (W8NCHPRES==1|W8NCHPRES==2) //child grid
label variable adopt "Child is adopted"
fre adopt

cap drop foster
gen foster=.
replace foster=1 if W8RELTOKEY==7 //HH grid
label variable foster "Child is fostered"
fre foster

cap drop step
gen step=.
replace step=1 if (W8RELTOKEY==6|W8RELTOKEY==7) //HH grid
replace step=1 if W8NCHREL==3 & (W8NCHPRES==1|W8NCHPRES==2) //child grid
label variable step "Child is step-child (current or previous partner)"
fre step


//any non-bio (age 25)
cap drop anynonbio
egen anynonbio = count(nonbiochild), by (NSID)
replace anynonbio=1 if inrange(anynonbio,1,20)
label variable anynonbio "Whether CM has any non-biological children in household"
label define yesno 0 "No" 1 "Yes" -100 "no participation in sweep" -99 "information not provided", replace
label values anynonbio yesno
fre anynonbio


//total number of non-bio (age 25)
cap drop nonbiochild_tot
egen nonbiochild_tot = count(nonbiochild), by (NSID)
label variable nonbiochild_tot "Total number of non-biological children in household"
label define nonbiochild_tot 0 "No non-biological children in HH" -100 "no participation in sweep" -99 "information not provided", replace 
label values nonbiochild_tot nonbiochild_tot
fre nonbiochild_tot

//total number of adopted (age 25)
cap drop adopt_tot
egen adopt_tot = count(adopt), by (NSID)
label variable adopt_tot "Total number of adopted children in household"
label define adopt_tot 0 "No adopted children in HH" -100 "no participation in sweep" -99 "information not provided", replace 
label values adopt_tot adopt_tot
fre adopt_tot

//total number of fostered (age 25)
cap drop foster_tot
egen foster_tot = count(foster), by (NSID)
label variable foster_tot "Total number of fostered children in household"
label define foster_tot 0 "No fostered children in HH" -100 "no participation in sweep" -99 "information not provided", replace 
label values foster_tot foster_tot
fre foster_tot

//total number of step-children (age 25)
cap drop step_tot
egen step_tot = count(step), by (NSID)
label variable step_tot "Total number of step-children in household"
label define step_tot 0 "No step children in HH" -100 "no participation in sweep" -99 "information not provided", replace 
label values step_tot step_tot
fre step_tot



*-------------------------------------------------------------------*
***AGE OF NON BIOLOGICAL CHILD (age 25)

//child gird
fre W8NCHDOBY W8NCHDOBM
cap drop CGnonbiochildym
gen CGnonbiochildym = ym(W8NCHDOBY, W8NCHDOBM) if (W8NCHREL==2|W8NCHREL==3) & (W8NCHPRES==1|W8NCHPRES==2) //child grid
label var CGnonbiochildym "Date of birth of non-biological child - months since Jan 1960"
fre CGnonbiochildym

	*child's age in whole years at interview (age 25)
cap drop CGnonbiochildagey
gen CGnonbiochildagey = (intym-CGnonbiochildym)/12
fre CGnonbiochildagey
replace CGnonbiochildagey = floor(CGnonbiochildagey)
label var CGnonbiochildagey " Age in whole years of non-biological child"
fre CGnonbiochildagey //range 0-15



//HH grid
*month of birth of HH member: 1-12, -9=refused (N=3500!!!), -1=not applicable (N=13)
fre W8HHMDOBM 
*year of birth of HH member: 1915-2016, -9=refused (N=3501!!!), -1=not applicable (N=13)
fre W8HHMDOBY 

*age of HH member: 0-100, -1=not applicable (N=3514)
fre W8DHHMAGE 
replace W8DHHMAGE=. if W8DHHMAGE<0

*age of HH member last birthday: 1-99, -9=refused (N=873), -8=don't know (N=576), -1=not applicable (N=5874)
fre W8RAGE  
replace W8RAGE=. if W8RAGE<0


replace W8HHMDOBM=. if W8HHMDOBM==-9|W8HHMDOBM==-1
replace W8HHMDOBY=. if W8HHMDOBY==-9|W8HHMDOBY==-1

cap drop HHnonbiochildym
gen HHnonbiochildym = ym(W8HHMDOBY, W8HHMDOBM) if (W8RELTOKEY==6|W8RELTOKEY==7) //HH grid
label var HHnonbiochildym "Date of birth of non-biological child - months since Jan 1960"
fre HHnonbiochildym

	*child's age in whole years at interview (age 25)
cap drop HHnonbiochildagey
gen HHnonbiochildagey = (intym-HHnonbiochildym)/12
fre HHnonbiochildagey
replace HHnonbiochildagey = floor(HHnonbiochildagey)

replace HHnonbiochildagey= W8DHHMAGE if (HHnonbiochildagey==. & (W8RELTOKEY==6|W8RELTOKEY==7)) //HH grid

replace HHnonbiochildagey= W8RAGE if (HHnonbiochildagey==. & (W8RELTOKEY==6|W8RELTOKEY==7))

replace HHnonbiochildagey=. if HHnonbiochildagey>40 //set to missing 4 cases where nonbio are over 40 which is unlikely
label var HHnonbiochildagey "Age in whole years of non-biological child"
fre HHnonbiochildagey //range 0-32



//CG and HH combined: nonbio-child age (age 25)
cap drop nonbiochildagey
gen nonbiochildagey=.
replace nonbiochildagey=CGnonbiochildagey if inrange(CGnonbiochildagey,0,100)
replace nonbiochildagey=HHnonbiochildagey if inrange(HHnonbiochildagey,0,100)
label variable nonbiochildagey "Age in years of non-biological child" 
fre nonbiochildagey //range 0-32



*eldest in years (age 25)
cap drop nonbiochildy_eldest
egen nonbiochildy_eldest = max(nonbiochildagey), by (NSID)
replace nonbiochildy_eldest= -10 if anynonbio==0
label define nonbiochildy_eldest -10 "No non biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values nonbiochildy_eldest nonbiochildy_eldest
label var nonbiochildy_eldest "Age in years of eldest non biological child"
fre  nonbiochildy_eldest

*youngest in years (age 25)
cap drop nonbiochildy_youngest
egen nonbiochildy_youngest = min(nonbiochildagey), by (NSID)
replace nonbiochildy_youngest= -10 if anynonbio==0
label define nonbiochildy_youngest -10 "No non biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values nonbiochildy_youngest nonbiochildy_youngest
label var nonbiochildy_youngest "Age in years of youngest non biological child"
fre  nonbiochildy_youngest



*-------------------------------------------------------------------*
***SEX OF NON BIOLOGICAL CHILDREN (age 42)

//CHILD GRID
*child sex: 1=male, 2=female, -9=refused
fre W8NCHSEX
replace W8NCHSEX=. if W8NCHSEX<0


//HH GRID
*sex of HH member: 1=male, 2=female, -9=refused, -8=don't know, -1=not applicable
fre W8DCHSEX
replace W8DCHSEX=. if W8DCHSEX<0


cap drop nonbiochildsex
gen nonbiochildsex=.
replace nonbiochildsex=W8NCHSEX if (W8NCHREL==2|W8NCHREL==3) & (W8NCHPRES==1|W8NCHPRES==2) //child grid
replace nonbiochildsex=W8DCHSEX if (W8RELTOKEY==6|W8RELTOKEY==7) //hh grid
label variable nonbiochildsex "Sex of non-biological child"
label define nonbiochildsex 1 "male" 2 "female" -100 "no participation in sweep" -99 "information not provided", replace
label values nonbiochildsex nonbiochildsex
fre nonbiochildsex


//total boys (age 25)
cap drop nonbiochildboy_total
egen nonbiochildboy_total= total(nonbiochildsex==1), by (NSID)
replace nonbiochildboy_total=-10 if anynonbio==0
label define nonbiochildboy_total 0 "Girls only" -10 "No non-biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values nonbiochildboy_total nonbiochildboy_total
label var nonbiochildboy_total "Total number of non-biological children who are boys"
fre nonbiochildboy_total

//total girls (age 25)
cap drop nonbiochildgirl_total
egen nonbiochildgirl_total= total(nonbiochildsex==2), by (NSID)
replace nonbiochildgirl_total=-10 if anynonbio==0
label define nonbiochildgirl_total 0 "Boys only" -10 "No non-biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values nonbiochildgirl_total nonbiochildgirl_total
label var nonbiochildgirl_total "Total number of non-biological children who are girls"
fre nonbiochildgirl_total






********************** BIOLOGICAL AND NON BIOLOGICAL CHILDREN (age 25) ******************

*** ANY BIOLOGICAL OR NON BIOLOGICAL CHILD AND NUMBER (age 25)

*any biological or non-biological children (age 42)
cap drop anychildren
egen anychildren = total(biochild==1|nonbiochild==1), by (NSID)
replace anychildren=1 if inrange(anychildren,1,20)
label variable anychildren "Whether CM has any children (biological or non-biological)"
label define yesno 0 "No" 1 "Yes" -100 "no participation in sweep" -99 "information not provided", replace
label values anychildren yesno
fre anychildren

*total number of biological or non-biologial children (age 25)
cap drop children_tot
egen children_tot = total(biochild==1|nonbiochild==1), by (NSID)
label define children_tot 0 "No biological or non-biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values children_tot children_tot
label variable children_tot "Total number of biological or non-biological children"
fre children_tot




***AGE OF BIOLOGICAL OR NON BIOLOGICAL CHILD (age 25)

*ages of all children (age 25)
cap drop childyears
gen childyears=. 
replace childyears=biochildagey if biochildagey!=.
replace childyears=nonbiochildagey if nonbiochildagey!=.
fre childyears

*eldest in years (age 25)
cap drop childy_eldest
egen childy_eldest = max(childyears), by (NSID)
replace childy_eldest= -10 if anychildren==0
label define childy_eldest -10 "No children (biological or non-biological)" -100 "no participation in sweep" -99 "information not provided", replace
label values childy_eldest childy_eldest
label var childy_eldest "Age in years of eldest child (biological or non biological)"
fre childy_eldest

*youngest in years (age 25)
cap drop childy_youngest
egen childy_youngest = min(childyears), by (NSID)
replace childy_youngest= -10 if anychildren==0
label define childy_youngest -10 "No children (biological or non-biological)" -100 "no participation in sweep" -99 "information not provided", replace
label values childy_youngest childy_youngest
label var childy_youngest "Age in years of youngest child (biological or non biological)"
fre childy_youngest




***SEX OF BIOLOGICAL OR NON BIOLOGICAL CHILDREN (age 25)

*sex of all children (age 25)
cap drop childsex
gen childsex=.
replace childsex=nonbiochildsex if nonbiochild==1 
replace childsex=biochildsex if biochild==1
label variable childsex "Sex of child"
label define childsex 1 "male" 2 "female" -100 "no participation in sweep" -99 "information not provided", replace
label values childsex childsex
fre childsex

*number of boys (age 25)
cap drop childboy_total
egen childboy_total= total(childsex==1), by (NSID)
replace childboy_total=-10 if anychildren==0
label define childboy_total 0 "Girls only" -10 "No non-biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values childboy_total childboy_total
label var childboy_total "Total number of children who are boys (biological or non-biological)"
fre childboy_total

*number of girls (age 25)
cap drop childgirl_total
egen childgirl_total= total(childsex==2), by (NSID)
replace childgirl_total=-10 if anychildren==0
label define childgirl_total 0 "Boys only" -10 "No non-biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values childgirl_total childgirl_total
label var childgirl_total "Total number of children who are girls (biological or non-biological)"
fre childgirl_total





***************** PARTNER AND CHILD COMBO (age 25) ******************

//partner and biological children (age 25)
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

//partner and any bio or nonbio children (age 25)
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


save "$project\temp.dta", replace


********RESHAPNG DATA (age 25)**********
use "$project\temp.dta", clear

duplicates drop NSID, force


keep NSID cmbirthm cmbirthy W8CMSEX ///
nssurvey intmonth intyear partner marital anybiochildren biochild_tot biochildhh_total biochildnonhh_total biodied_total anybiodied biochildprev_total biochildprevany biochildy_eldest biochildy_youngest cmageybirth_eldest cmageybirth_youngest biochildboy_total biochildgirl_total anynonbio nonbiochild_tot adopt_tot foster_tot step_tot nonbiochildy_eldest nonbiochildy_youngest nonbiochildboy_total nonbiochildgirl_total anychildren children_tot childy_eldest childy_youngest childboy_total childgirl_total partnerchildbio partnerchildany


order NSID cmbirthm cmbirthy W8CMSEX ///
nssurvey intmonth intyear partner marital anybiochildren biochild_tot biochildhh_total biochildnonhh_total biodied_total anybiodied biochildprev_total biochildprevany biochildy_eldest biochildy_youngest cmageybirth_eldest cmageybirth_youngest biochildboy_total biochildgirl_total anynonbio nonbiochild_tot adopt_tot foster_tot step_tot nonbiochildy_eldest nonbiochildy_youngest nonbiochildboy_total nonbiochildgirl_total anychildren children_tot childy_eldest childy_youngest childboy_total childgirl_total partnerchildbio partnerchildany


*suffix
foreach var of varlist nssurvey intmonth intyear partner marital anybiochildren biochild_tot biochildhh_total biochildnonhh_total biodied_total anybiodied biochildprev_total biochildprevany biochildy_eldest biochildy_youngest cmageybirth_eldest cmageybirth_youngest biochildboy_total biochildgirl_total anynonbio nonbiochild_tot adopt_tot foster_tot step_tot nonbiochildy_eldest nonbiochildy_youngest nonbiochildboy_total nonbiochildgirl_total anychildren children_tot childy_eldest childy_youngest childboy_total childgirl_total partnerchildbio partnerchildany {	
rename `var' `var'_25		

}

foreach v of varlist NSID cmbirthm cmbirthy nssurvey_25 intmonth_25 intyear_25 partner_25 marital_25 anybiochildren_25 biochild_tot_25 biochildhh_total_25 biochildnonhh_total_25 biodied_total_25 anybiodied_25 biochildprev_total_25 biochildprevany_25 biochildy_eldest_25 biochildy_youngest_25 cmageybirth_eldest_25 cmageybirth_youngest_25 biochildboy_total_25 biochildgirl_total_25 anynonbio_25 nonbiochild_tot_25 adopt_tot_25 foster_tot_25 step_tot_25 nonbiochildy_eldest_25 nonbiochildy_youngest_25 nonbiochildboy_total_25 nonbiochildgirl_total_25 anychildren_25 children_tot_25 childy_eldest_25 childy_youngest_25 childboy_total_25 childgirl_total_25 partnerchildbio_25 partnerchildany_25   {
    display `"`v':"', `"`:var label `v''"'
}


label var	nssurvey_25	"Whether took part in age 25 survey"
label var	intmonth_25	"Interview month (age 25)"
label var	intyear_25	"Interview year (age 25)"
label var	partner_25	"Whether has a partner in HH (age 25)"
label var	marital_25	"Marital status (age 25)"
label var	anybiochildren_25	"Whether has had any bio children (age 25)"
label var	biochild_tot_25	"Number of bio children (age 25)"
label var	biochildhh_total_25	"Number of bio children in HH (age 25)"
label var	biochildnonhh_total_25	"Number of bio children not in HH (age 25)"
label var	biodied_total_25	"Number of bio children that have died (age 25)"
label var	anybiodied_25	"Whether any bio children have died (age 25)"
label var	biochildprev_total_25	"Number of bio children had with a previous partner (age 25)"
label var	biochildprevany_25	"Have had any bio children with a previous partner (age 25)"
label var	biochildy_eldest_25	"Age in years of eldest bio child  (age 25)"
label var	biochildy_youngest_25	"Age in years of youngest bio child  (age 25)"
label var	cmageybirth_eldest_25	"Age in years of CM at birth of eldest bio child (age 25)"
label var	cmageybirth_youngest_25	"Age in years of CM at birth of youngest bio child (age 25)"
label var	biochildboy_total_25	"Number of bio children who are boys (age 25)"
label var	biochildgirl_total_25	"Number of bio children who are girls (age 25)"
label var	anynonbio_25	"Whether has any non-bio children in HH (age 25)"
label var	nonbiochild_tot_25	"Number of non-bio children in HH (age 25)"
label var	adopt_tot_25	"Number of adopted children in HH (age 25)"
label var	foster_tot_25	"Number of fostered children in HH (age 25)"
label var	step_tot_25	"Number of step children in HH (age 25)"
label var	nonbiochildy_eldest_25	"Age in years of eldest non-bio child (age 25)"
label var	nonbiochildy_youngest_25	"Age in years of youngest non-bio child (age 25)"
label var	nonbiochildboy_total_25	"Number of non-bio children who are boys (age 25)"
label var	nonbiochildgirl_total_25	"Number of non-bio children who are girls (age 25)"
label var	anychildren_25	"Whether has any children (bio or non-bio) (age 25)"
label var	children_tot_25	"Number of children (bio or non-bio) (age 25)"
label var	childy_eldest_25	"Age in years of eldest child (bio or non-bio) (age 25)"
label var	childy_youngest_25	"Age in years of youngest child (bio or non-bio) (age 25)"
label var	childboy_total_25	"Number of children who are boys (bio or non-bio) (age 25)"
label var	childgirl_total_25	"Number of children who are girls (bio or non-bio) (age 25)"
label var	partnerchildbio_25	"Whether has live-in partner/spouse and/or any bio children (age 25)"
label var	partnerchildany_25	"Whether has live-in partner/spouse and/or any bio or non-bio children (age 25)"



foreach var of varlist nssurvey_25 intmonth_25 intyear_25 partner_25 marital_25 anybiochildren_25 biochild_tot_25 biochildhh_total_25 biochildnonhh_total_25 biodied_total_25 anybiodied_25 biochildprev_total_25 biochildprevany_25 biochildy_eldest_25 biochildy_youngest_25 cmageybirth_eldest_25 cmageybirth_youngest_25 biochildboy_total_25 biochildgirl_total_25 anynonbio_25 nonbiochild_tot_25 adopt_tot_25 foster_tot_25 step_tot_25 nonbiochildy_eldest_25 nonbiochildy_youngest_25 nonbiochildboy_total_25 nonbiochildgirl_total_25 anychildren_25 children_tot_25 childy_eldest_25 childy_youngest_25 childboy_total_25 childgirl_total_25 partnerchildbio_25 partnerchildany_25 {	
replace `var'=-99 if `var'==.		
}



save "$project\NS_fertility_age25_wide.dta", replace
use "$project\NS_fertility_age25_wide.dta", clear 





*------------------------------------------------------------------------------*
*------------------------------------------------------------------------------*
**# Bookmark #2

*********************************************************
*********************************************************
***** AGE 32 *****

*longitudinal file
use "$orig\ns9_2022_longitudinal_file", clear

*merging on sweep 1 for date of birth of CM
merge 1:1 NSID using "$orig\wave_one_lsype_young_person_2020", keepusing (DobyearYP DobmonthYP W1sexYP)
//has month and year of birth for original sample
fre DobyearYP DobmonthYP

fre W9OUTCOME
keep if W9OUTCOME==1
//N=7,279 productive in sweep
drop _merge
gen nssurvey=1
label var nssurvey "Whether took part in age 32 survey"

*merging on main 
merge 1:1 NSID using "$orig\ns9_2022_main_interview", keepusing (W9HMS W9OTHCRELA W9INTMTH W9INTYEAR W9BDATY W9BDATM W9DSEX)
drop _merge

*merging on derived 
merge 1:1 NSID using "$orig\ns9_2022_derived_variables", keepusing (W9DCOHAB W9DPARTP)
drop _merge

*merging on person grid 
merge 1:m NSID using "$orig\ns9_2022_person_grid"
//N=20,184
codebook NSID //N=7,279
drop _merge

*merging on data for children with non resident parents
merge m:m NSID GRIDID using "$orig\ns9_2022_children_with_non_resident_parent.dta", keepusing(W9SEOF)
drop if _merge==2
drop _merge


// we don't merge on pregnancy data below as everything we need is in person grid file and the non-resident parent file.


save "$project\NS_fertility_age32.dta", replace
use "$project\NS_fertility_age32.dta", clear 

tab HHCAT W9RELTOKEY
tab HHCAT GRIDID


//partner age 32
 fre W9DCOHAB 
cap drop partner
gen partner=.
replace partner=1 if W9DCOHAB==1
replace partner=0 if W9DCOHAB==0
label define partner 0 "No spouse or partner living with CM" 1 "Lives with spouse or partner", replace
label values partner partner
label var partner "Whether CM has current partner in hhld"
fre partner 


//marital status age 32
fre W9DPARTP
fre partner
tab W9DPARTP partner, mi

cap drop marital
gen marital=.
replace marital=3 if W9DPARTP==-1 & partner==0
replace marital=2 if W9DPARTP==3
replace marital=1 if W9DPARTP==1|W9DPARTP==2
label define marital 3 "Single non-cohabiting" 2 "Single cohabiting with partner" 1 "Married or Civil Partnered" -100 "no participation in sweep" -99 "information not provided", replace
label values marital marital
label variable marital "Marital status (age 42)" 
fre marital




************************** BIOLOGICAL CHILDREN (age 32) *****************************


*** WHETHER HAD ANY BIOLOGICAL CHILDREN AND TOTAL NUMBER (age 32)
fre GRIDID HHCAT W9RELTOKEY

fre W9RELTOKEY //4=biological child

cap drop biochild
gen biochild=.
replace biochild=1 if W9RELTOKEY==4
fre biochild

*any biological children (age 32)
cap drop anybiochildren
egen anybiochildren = total(biochild==1), by (NSID)
replace anybiochildren=1 if inrange(anybiochildren,1,20)
label variable anybiochildren "Whether CM has had any biological children"
label define yesno 0 "No" 1 "Yes" -100 "no participation in sweep" -99 "information not provided", replace
label values anybiochildren yesno
fre anybiochildren


*total number of biological children (age 32)
cap drop biochild_tot
egen biochild_tot = count(biochild), by (NSID)
label define biochild_tot 0 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values biochild_tot biochild_tot
label variable biochild_tot "Total number of biological children"
fre biochild_tot




*** AGES OF BIOLOGICAL CHILDREN AND COHORT MEMBER AGE AT BIRTH (age 32)

*interview date (age 32)
fre W9INTMTH W9INTYEAR
rename (W9INTMTH W9INTYEAR) (intmonth intyear)

label define intyear -100 "no participation in sweep" -99 "information not provided", replace
label values intyear intyear

label define intmonth 1 "January" 2	"February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "	October" 11 "November" 12 "December" -100 "no participation in sweep" -99 "information not provided", replace
label values intmonth intmonth

fre intmonth intyear

cap drop intym
gen intym = ym(intyear,intmonth)
label var intym "Interview date - months since Jan 1960"
fre intym



*cohort member birthdate (age 32)
fre W9BDATY W9BDATM

cap drop cmbirthy
gen cmbirthy=W9BDATY
label var cmbirthy "Birth year of CM"
fre cmbirthy

cap drop cmbirthm
gen cmbirthm=W9BDATM
label var cmbirthm "Birth month of CM"
fre cmbirthm

cap drop cmbirthym
gen cmbirthym = ym(cmbirthy,cmbirthm)
label var cmbirthym "CM birth date - months since Jan 1960"
fre cmbirthym



*date of birth of biological child since Jan 1960 (age 32)
fre W9DOBM //birth month //1=jan 12=dec
replace W9DOBM=. if W9DOBM<0

fre W9DOBY //birth year //1915 - 2023
replace W9DOBY=. if W9DOBY<0

cap drop biochildym
gen biochildym = ym(W9DOBY, W9DOBM) if biochild==1
label var biochildym "Date of birth of biological child - months since Jan 1960"
fre biochildym


//child's age in whole years at interview (age 32)
cap drop biochildagey
gen biochildagey = (intym-biochildym)/12
fre biochildagey
replace biochildagey = floor(biochildagey)
replace biochildagey=0 if biochildagey<0
label var biochildagey " Age in whole years of biological child"
fre biochildagey //range 0-17


//cm age in whole years at birth of child (age 32)
cap drop cmageybirth
gen cmageybirth = (biochildym-cmbirthym)/12
fre cmageybirth
replace cmageybirth = floor(cmageybirth)
label var cmageybirth "Age of CM in years at birth of biological child"
fre cmageybirth //range 17 to 33, which is reasonable 




***SUMMARY age of eldest and youngest biological child (in years) (age 32)

*eldest in years (age 32)
cap drop biochildy_eldest
egen biochildy_eldest = max(biochildagey), by (NSID)
replace biochildy_eldest= -10 if anybiochildren==0
label define minusten -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildy_eldest minusten
label var biochildy_eldest "Age in years of eldest biological child"
fre  biochildy_eldest

*youngest in years (age 32)
cap drop biochildy_youngest
egen biochildy_youngest = min(biochildagey), by (NSID)
replace biochildy_youngest= -10 if anybiochildren==0
label values biochildy_youngest minusten
label var biochildy_youngest "Age in years of youngest biological child"
fre  biochildy_youngest


***SUMMARY age of cohort member at birth of eldest and youngest child (in years and in months) (age 32)
cap drop cmageybirth_eldest //years
egen cmageybirth_eldest = min(cmageybirth), by (NSID)
replace cmageybirth_eldest= -10 if anybiochildren==0
label values cmageybirth_eldest minusten
label var cmageybirth_eldest "CM age in years at birth of eldest biological child"
fre  cmageybirth_eldest

cap drop cmageybirth_youngest //years
egen cmageybirth_youngest = max(cmageybirth), by (NSID)
replace cmageybirth_youngest= -10 if anybiochildren==0
label values cmageybirth_youngest minusten
label var cmageybirth_youngest "CM age in years at birth of youngest biological child"
fre  cmageybirth_youngest




*-------------------------------------------------------------------*
*** SEX OF BIOLOGICAL CHILDREN (age 32)
fre W9SEX //1=male, 2=female

cap drop biochildsex
gen biochildsex=.
replace biochildsex=W9SEX if biochild==1
replace biochildsex=. if biochildsex<0
label variable biochildsex "Sex of -biological child"
label define biochildsex 1 "male" 2 "female" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildsex biochildsex
fre biochildsex



//total boys (age 32)
cap drop biochildboy_total
egen biochildboy_total= total(biochildsex==1), by (NSID)
replace biochildboy_total=-10 if anybiochildren==0
label define biochildboy_total 0 "Girls only" -10 "No non-biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values biochildboy_total biochildboy_total
label var biochildboy_total "Total number of biological children who are boys"
fre biochildboy_total

//total girls (age 32)
cap drop biochildgirl_total
egen biochildgirl_total= total(biochildsex==2), by (NSID)
replace biochildgirl_total=-10 if anybiochildren==0
label define biochildgirl_total 0 "Boys only" -10 "No non-biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values biochildgirl_total biochildgirl_total
label var biochildgirl_total "Total number of biological children who are girls"
fre biochildgirl_total





*-------------------------------------------------------------------*
*** WHERE BIOLOGICAL CHILDREN LIVE (age 32)
*lives with CM
fre W9PRES //1=yes 2=no


//in household (age 32)
cap drop biochildhh
gen biochildhh=.
replace biochildhh=1 if biochild==1 & W9PRES==1
label variable biochildhh "Child lives in household"
fre biochildhh

cap drop biochildhh_total 
egen biochildhh_total = count(biochildhh), by (NSID)
replace biochildhh_total=-10 if anybiochildren==0
label define biochildhh_total 0 "None of CM's biological children live in household" -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildhh_total biochildhh_total
label variable biochildhh_total "Total number of bio children in household (HH grid data)"
fre biochildhh_total


//not in household (age 32)
cap drop biochildnonhh
gen biochildnonhh=.
replace biochildnonhh=1 if biochild==1 & W9PRES==2
label variable biochildnonhh "Child lives outside household"
fre biochildnonhh

cap drop biochildnonhh_total
egen biochildnonhh_total = count(biochildnonhh), by (NSID)
replace biochildnonhh_total=-10 if anybiochildren==0
label define biochildnonhh_total 0 "All biological children live in household" -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildnonhh_total biochildnonhh_total
label variable biochildnonhh_total "Total number of bio children not in household"
fre biochildnonhh_total


*************************************************


*** OTHER PARENT OF BIOLOGICAL CHILDREN (age 32)
fre W9SEOF
fre W9OTHCRELA //no=2

//previous partner's child (age 32)
cap drop biochildprev
gen biochildprev=.
replace biochildprev=1 if biochild==1 & (inrange(W9SEOF,-9,10))
replace biochildprev=1 if biochildprev==. & biochild==1 & partner==0
label variable biochildprev "Bio child's other parent is previous partner"
fre biochildprev

cap drop biochildprev_total
egen biochildprev_total = count(biochildprev), by (NSID)
replace biochildprev_total=-10 if anybiochildren==0
label define biochildprev_total 0 "Current partner(s) parent to all biological children" -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildprev_total biochildprev_total
label variable biochildprev_total "Total number of biological children had with a previous partner"
fre biochildprev_total


//whether a previous partner is parent to any children (age 32)
cap drop biochildprevany
gen biochildprevany=.
replace biochildprevany=1 if inrange(biochildprev_total,1,10)
replace biochildprevany=0 if biochildprev_total==0
replace biochildprevany=-10 if biochildprev_total==-10
label variable biochildprevany "Any children with a previous partner"
label define biochildprevany 1 "Previous partner parent to all or some biological children" 0 "Current partner is parent to all biological children" -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biochildprevany biochildprevany
fre biochildprevany



***BIOLOGICAL CHILDREN WHO HAVE DIED (age 32)

*children who died
cap drop deadchild
gen deadchild=.
replace deadchild=1 if biochild==1 & W9ALIVE==2

cap drop biodied_total
egen biodied_total = total(deadchild==1), by (NSID)
replace biodied_total=-10 if anybiochildren==0
label define biodied_total 0 "All biological children alive" -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values biodied_total biodied_total
label var biodied_total "Total number of biological children that had died"
fre biodied_total //this is a very small number, so maybe don't report or check for a derived variable

cap drop anybiodied
egen anybiodied = total(deadchild==1), by (NSID)
replace anybiodied=1 if inrange(anybiodied,1,5)
replace anybiodied=-10 if anybiochildren==0
label define anybiodied 0 "No" 1 "Yes" -10 "No biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values anybiodied anybiodied
label var anybiodied "Whether any biological children had died"
fre anybiodied







************************** NON BIOLOGICAL CHILDREN (age 32) *****************************
fre W9RELTOKEY //5=adopted, 6=child of current partner, 7=Child of previous partner, 8=fostered child

fre W9PRES //1=yes 2=no //lives in HH

cap drop nonbiochild
gen nonbiochild=.
replace nonbiochild=1 if (W9RELTOKEY==5|W9RELTOKEY==6|W9RELTOKEY==7|W9RELTOKEY==8) & W9PRES==1
label variable nonbiochild "Child is non-biological"
fre nonbiochild

cap drop adopt
gen adopt=.
replace adopt=1 if W9RELTOKEY==5 & W9PRES==1
label variable adopt "Child is adopted"
fre adopt

cap drop foster
gen foster=.
replace foster=1 if W9RELTOKEY==8 & W9PRES==1
label variable foster "Child is fostered"
fre foster

cap drop step
gen step=.
replace step=1 if (W9RELTOKEY==6|W9RELTOKEY==7) & W9PRES==1
label variable step "Child is step-child (current or previous partner)"
fre step



//any non-bio (age 32)
cap drop anynonbio
egen anynonbio = count(nonbiochild), by (NSID)
replace anynonbio=1 if inrange(anynonbio,1,20)
label variable anynonbio "Whether CM has any non-biological children in household"
label define yesno 0 "No" 1 "Yes" -100 "no participation in sweep" -99 "information not provided", replace
label values anynonbio yesno
fre anynonbio

//total number of non-bio (age 32)
cap drop nonbiochild_tot
egen nonbiochild_tot = count(nonbiochild), by (NSID)
label variable nonbiochild_tot "Total number of non-biological children in household"
label define nonbiochild_tot 0 "No non-biological children in HH" -100 "no participation in sweep" -99 "information not provided", replace 
label values nonbiochild_tot nonbiochild_tot
fre nonbiochild_tot

//total number of adopted (age 32)
cap drop adopt_tot
egen adopt_tot = count(adopt), by (NSID)
label variable adopt_tot "Total number of adopted children in household"
label define adopt_tot 0 "No adopted children in HH" -100 "no participation in sweep" -99 "information not provided", replace 
label values adopt_tot adopt_tot
fre adopt_tot

//total number of fostered (age 32)
cap drop foster_tot
egen foster_tot = count(foster), by (NSID)
label variable foster_tot "Total number of fostered children in household"
label define foster_tot 0 "No fostered children in HH" -100 "no participation in sweep" -99 "information not provided", replace 
label values foster_tot foster_tot
fre foster_tot

//total number of step-children (age 32)
cap drop step_tot
egen step_tot = count(step), by (NSID)
label variable step_tot "Total number of step-children in household"
label define step_tot 0 "No step children in HH" -100 "no participation in sweep" -99 "information not provided", replace 
label values step_tot step_tot
fre step_tot



*-------------------------------------------------------------------*
***AGE OF NON BIOLOGICAL CHILD (age 32)

fre W9RAGE //person's age last birthday
cap drop nonbiochildagey
gen nonbiochildagey=.
replace nonbiochildagey=W9RAGE if inrange(W9RAGE,0,100) & nonbiochild==1
label variable nonbiochildagey "Age in years of non-biological child" 
fre nonbiochildagey


*eldest in years (age 32)
cap drop nonbiochildy_eldest
egen nonbiochildy_eldest = max(nonbiochildagey), by (NSID)
replace nonbiochildy_eldest= -10 if anynonbio==0
label define nonbiochildy_eldest -10 "No non biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values nonbiochildy_eldest nonbiochildy_eldest
label var nonbiochildy_eldest "Age in years of eldest non biological child"
fre  nonbiochildy_eldest

*youngest in years (age 32)
cap drop nonbiochildy_youngest
egen nonbiochildy_youngest = min(nonbiochildagey), by (NSID)
replace nonbiochildy_youngest= -10 if anynonbio==0
label define nonbiochildy_youngest -10 "No non biological children" -100 "no participation in sweep" -99 "information not provided", replace
label values nonbiochildy_youngest nonbiochildy_youngest
label var nonbiochildy_youngest "Age in years of youngest non biological child"
fre  nonbiochildy_youngest





***SEX OF NON BIOLOGICAL CHILDREN (age 32)
fre W9SEX //1=male, 2=female
replace W9SEX=. if W9SEX==-9

cap drop nonbiochildsex
gen nonbiochildsex=.
replace nonbiochildsex=W9SEX if nonbiochild==1
label variable nonbiochildsex "Sex of non-biological child"
label define nonbiochildsex 1 "male" 2 "female" -100 "no participation in sweep" -99 "information not provided", replace
label values nonbiochildsex nonbiochildsex
fre nonbiochildsex

//total boys (age 32)
cap drop nonbiochildboy_total
egen nonbiochildboy_total= total(nonbiochildsex==1), by (NSID)
replace nonbiochildboy_total=-10 if anynonbio==0
label define nonbiochildboy_total 0 "Girls only" -10 "No non-biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values nonbiochildboy_total nonbiochildboy_total
label var nonbiochildboy_total "Total number of non-biological children who are boys"
fre nonbiochildboy_total

//total girls (age 32)
cap drop nonbiochildgirl_total
egen nonbiochildgirl_total= total(nonbiochildsex==2), by (NSID)
replace nonbiochildgirl_total=-10 if anynonbio==0
label define nonbiochildgirl_total 0 "Boys only" -10 "No non-biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values nonbiochildgirl_total nonbiochildgirl_total
label var nonbiochildgirl_total "Total number of non-biological children who are girls"
fre nonbiochildgirl_total




********************** BIOLOGICAL AND NON BIOLOGICAL CHILDREN (age 32) ******************

*** ANY BIOLOGICAL OR NON BIOLOGICAL CHILD AND NUMBER (age 32)

*any biological or non-biological children (age 32)
cap drop anychildren
egen anychildren = total(biochild==1|nonbiochild==1), by (NSID)
replace anychildren=1 if inrange(anychildren,1,20)
label variable anychildren "Whether CM has any children (biological or non-biological)"
label define yesno 0 "No" 1 "Yes" -100 "no participation in sweep" -99 "information not provided", replace
label values anychildren yesno
fre anychildren

*total number of biological or non-biologial children (age 32)
cap drop children_tot
egen children_tot = total(biochild==1|nonbiochild==1), by (NSID)
label define children_tot 0 "No biological or non-biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values children_tot children_tot
label variable children_tot "Total number of biological or non-biological children"
fre children_tot




***AGE OF BIOLOGICAL OR NON BIOLOGICAL CHILD (age 32)

*ages of all children (age 32)
cap drop childyears
gen childyears=. 
replace childyears=biochildagey if biochildagey!=.
replace childyears=nonbiochildagey if nonbiochildagey!=.
fre childyears

*eldest in years (age 32)
cap drop childy_eldest
egen childy_eldest = max(childyears), by (NSID)
replace childy_eldest= -10 if anychildren==0
label define childy_eldest -10 "No children (biological or non-biological)" -100 "no participation in sweep" -99 "information not provided", replace
label values childy_eldest childy_eldest
label var childy_eldest "Age in years of eldest child (biological or non biological)"
fre childy_eldest

*youngest in years (age 32)
cap drop childy_youngest
egen childy_youngest = min(childyears), by (NSID)
replace childy_youngest= -10 if anychildren==0
label define childy_youngest -10 "No children (biological or non-biological)" -100 "no participation in sweep" -99 "information not provided", replace
label values childy_youngest childy_youngest
label var childy_youngest "Age in years of youngest child (biological or non biological)"
fre childy_youngest




***SEX OF BIOLOGICAL OR NON BIOLOGICAL CHILDREN (age 32)

*sex of all children (age 32)
cap drop childsex
gen childsex=.
replace childsex=W9SEX if biochild==1|nonbiochild==1 
label variable childsex "Sex of child"
label define childsex 1 "male" 2 "female" -100 "no participation in sweep" -99 "information not provided", replace
label values childsex childsex
fre childsex

*number of boys (age 32)
cap drop childboy_total
egen childboy_total= total(childsex==1), by (NSID)
replace childboy_total=-10 if anychildren==0
label define childboy_total 0 "Girls only" -10 "No non-biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values childboy_total childboy_total
label var childboy_total "Total number of children who are boys (biological or non-biological)"
fre childboy_total

*number of girls (age 32)
cap drop childgirl_total
egen childgirl_total= total(childsex==2), by (NSID)
replace childgirl_total=-10 if anychildren==0
label define childgirl_total 0 "Boys only" -10 "No non-biological children" -100 "no participation in sweep" -99 "information not provided", replace 
label values childgirl_total childgirl_total
label var childgirl_total "Total number of children who are girls (biological or non-biological)"
fre childgirl_total





***************** PARTNER AND CHILD COMBO (age 32) ******************

//partner and biological children (age 32)
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

//partner and any bio or nonbio children (age 32)
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



save "$project\NS_fertility_age32_long.dta", replace
use "$project\NS_fertility_age32_long.dta", clear 
//N=20,185
//codebook NSID = 7,279


********RESHAPNG DATA (age 32)**********

tab GRIDID HHCAT 
fre HHCAT
fre GRIDID
replace GRIDID=0 if GRIDID==.

reshape wide /// just the variables for individuals and not family summary
HHCAT W9SEX W9ALIVE W9PRES W9RELTOKEY W9LVDYM W9LVDYY W9WHNMOM W9WHNMOY W9SLVYM W9SLVYY W9DOBM W9DOBY W9RAGE W9GRIDFLAG W9SEOF biochild biochildym biochildagey cmageybirth biochildsex biochildhh biochildnonhh biochildprev deadchild nonbiochild adopt foster step nonbiochildagey nonbiochildsex childyears childsex, i(NSID) j(GRIDID)


keep NSID cmbirthy cmbirthm W9DSEX nssurvey intmonth intyear partner marital anybiochildren biochild_tot biochildy_eldest biochildy_youngest cmageybirth_eldest cmageybirth_youngest biochildboy_total biochildgirl_total biochildhh_total biochildnonhh_total biochildprev_total biochildprevany biodied_total anybiodied anynonbio nonbiochild_tot adopt_tot foster_tot step_tot nonbiochildy_eldest nonbiochildy_youngest nonbiochildboy_total nonbiochildgirl_total anychildren children_tot childy_eldest childy_youngest childboy_total childgirl_total partnerchildbio partnerchildany


//adding suffix _32 to denote varabels are from age 32 sweep
foreach var of varlist cmbirthy cmbirthm nssurvey intmonth intyear partner marital anybiochildren biochild_tot biochildy_eldest biochildy_youngest cmageybirth_eldest cmageybirth_youngest biochildboy_total biochildgirl_total biochildhh_total biochildnonhh_total biochildprev_total biochildprevany biodied_total anybiodied anynonbio nonbiochild_tot adopt_tot foster_tot step_tot nonbiochildy_eldest nonbiochildy_youngest nonbiochildboy_total nonbiochildgirl_total anychildren children_tot childy_eldest childy_youngest childboy_total childgirl_total partnerchildbio partnerchildany {	
rename `var' `var'_32		
}


//generates output for excel sheet for summary variable names and labels
foreach v of varlist nssurvey_32 intmonth_32 intyear_32 partner_32 marital_32 anybiochildren_32 biochild_tot_32 biochildy_eldest_32 biochildy_youngest_32 cmageybirth_eldest_32 cmageybirth_youngest_32 biochildboy_total_32 biochildgirl_total_32 biochildhh_total_32 biochildnonhh_total_32 biochildprev_total_32 biochildprevany_32 biodied_total_32 anybiodied_32 anynonbio_32 nonbiochild_tot_32 adopt_tot_32 foster_tot_32 step_tot_32 nonbiochildy_eldest_32 nonbiochildy_youngest_32 nonbiochildboy_total_32 nonbiochildgirl_total_32 anychildren_32 children_tot_32 childy_eldest_32 childy_youngest_32 childboy_total_32 childgirl_total_32 partnerchildbio_32 partnerchildany_32   {
    display `"`v':"', `"`:var label `v''"'
}


label var	adopt_tot_32	"Number of adopted children in HH (age 32)"
label var	anybiochildren_32	"Whether has had any bio children (age 32)"
label var	anybiodied_32	"Whether any bio children have died (age 32)"
label var	anychildren_32	"Whether has any children (bio or non-bio) (age 32)"
label var	anynonbio_32	"Whether has any non-bio children in HH (age 32)"
label var	biochild_tot_32	"Number of bio children (age 32)"
label var	biochildboy_total_32	"Number of bio children who are boys (age 32)"
label var	biochildgirl_total_32	"Number of bio children who are girls (age 32)"
label var	biochildhh_total_32	"Number of bio children in HH (age 32)"
label var	biochildnonhh_total_32	"Number of bio children not in HH (age 32)"
label var	biochildprev_total_32	"Number of bio children had with a previous partner (age 32)"
label var	biochildprevany_32	"Have had any bio children with a previous partner (age 32)"
label var	biochildy_eldest_32	"Age in years of eldest bio child  (age 32)"
label var	biochildy_youngest_32	"Age in years of youngest bio child  (age 32)"
label var	biodied_total_32	"Number of bio children that have died (age 32)"
label var	childboy_total_32	"Number of children who are boys (bio or non-bio) (age 32)"
label var	childgirl_total_32	"Number of children who are girls (bio or non-bio) (age 32)"
label var	children_tot_32	"Number of children (bio or non-bio) (age 32)"
label var	childy_eldest_32	"Age in years of eldest child (bio or non-bio) (age 32)"
label var	childy_youngest_32	"Age in years of youngest child (bio or non-bio) (age 32)"
label var	cmageybirth_eldest_32	"Age in years of CM at birth of eldest bio child (age 32)"
label var	cmageybirth_youngest_32	"Age in years of CM at birth of youngest bio child (age 32)"
label var	foster_tot_32	"Number of fostered children in HH (age 32)"
label var	intmonth_32	"Interview month (age 32)"
label var	intyear_32	"Interview year (age 32)"
label var	marital_32	"Marital status (age 32)"
label var	nonbiochild_tot_32	"Number of non-bio children in HH (age 32)"
label var	nonbiochildboy_total_32	"Number of non-bio children who are boys (age 32)"
label var	nonbiochildgirl_total_32	"Number of non-bio children who are girls (age 32)"
label var	nonbiochildy_eldest_32	"Age in years of eldest non-bio child (age 32)"
label var	nonbiochildy_youngest_32	"Age in years of youngest non-bio child (age 32)"
label var	nssurvey_32	"Whether took part in age 32 survey"
label var	partner_32	"Whether has a partner in HH (age 32)"
label var	partnerchildany_32	"Whether has live-in partner/spouse and/or any bio or non-bio children (age 32)"
label var	partnerchildbio_32	"Whether has live-in partner/spouse and/or any bio children (age 32)"
label var	step_tot_32	"Number of step children in HH (age 32)"




order NSID cmbirthy cmbirthm W9DSEX nssurvey_32 intmonth_32 intyear_32 partner_32 marital_32 anybiochildren_32 biochild_tot_32 biochildhh_total_32 biochildnonhh_total_32 biodied_total_32 anybiodied_32 biochildprev_total_32 biochildprevany_32 biochildy_eldest_32 biochildy_youngest_32 cmageybirth_eldest_32 cmageybirth_youngest_32 biochildboy_total_32 biochildgirl_total_32    anynonbio_32 nonbiochild_tot_32 adopt_tot_32 foster_tot_32 step_tot_32 nonbiochildy_eldest_32 nonbiochildy_youngest_32 nonbiochildboy_total_32 nonbiochildgirl_total_32 anychildren_32 children_tot_32 childy_eldest_32 childy_youngest_32 childboy_total_32 childgirl_total_32 partnerchildbio_32 partnerchildany_32

foreach var of varlist nssurvey_32 intmonth_32 intyear_32 partner_32 marital_32 anybiochildren_32 biochild_tot_32 biochildhh_total_32 biochildnonhh_total_32 biodied_total_32 anybiodied_32 biochildprev_total_32 biochildprevany_32 biochildy_eldest_32 biochildy_youngest_32 cmageybirth_eldest_32 cmageybirth_youngest_32 biochildboy_total_32 biochildgirl_total_32    anynonbio_32 nonbiochild_tot_32 adopt_tot_32 foster_tot_32 step_tot_32 nonbiochildy_eldest_32 nonbiochildy_youngest_32 nonbiochildboy_total_32 nonbiochildgirl_total_32 anychildren_32 children_tot_32 childy_eldest_32 childy_youngest_32 childboy_total_32 childgirl_total_32 partnerchildbio_32 partnerchildany_32 {	
replace `var'=-99 if `var'==.		
}



save "$project\NS_fertility_age32_wide.dta", replace
use "$project\NS_fertility_age32_wide.dta", clear 





**# Bookmark #1
*------------------------------------------------------------------------------*
*------------------------------------------------------------------------------*
**** MERGING OF FILES AND FURTHER ADJUSTMENTS****

use "$orig\ns9_2022_longitudinal_file", clear
//has weights
//N=16,122
keep NSID SAMPPSU SAMPSTRATUM DESIGNWEIGHT MAINBOOST W8OUTCOME W8FINWT W9OUTCOME W9FINWTALLA W9FINWTLONGA W9FINWTALLB W9FINWTLONGB
keep if W8OUTCOME==1 |W9OUTCOME==1
//N=9,410

//sex and birthday
merge 1:1 NSID using "$orig\wave_one_lsype_young_person_2020", keepusing(W1sexYP DobyearYP DobmonthYP) 
drop _merge
keep if W8OUTCOME==1 |W9OUTCOME==1
//N=9,410


merge 1:1 NSID using "$project\NS_fertility_age25_wide.dta" //N=7,707
drop _merge

merge 1:1 NSID using "$project\NS_fertility_age32_wide.dta" //N=7,279
drop _merge

//N=9,410


*sex of CM
fre W1sexYP
fre W8CMSEX
fre W9DSEX

cap drop sex
clonevar sex=W1sexYP
replace sex=W8CMSEX if sex==-99|sex==.
replace sex=W9DSEX if sex==-99|sex==.
label define sex 1 "Male" 2 "Female" -100 "no participation in sweep" -99 "information not provided", replace
label values sex sex
label var sex "sex of cohort member"
fre sex

drop W8CMSEX W9DSEX 

*year of birth
fre DobyearYP
fre cmbirthy
fre cmbirthy_32 

replace cmbirthy=DobyearYP if cmbirthy==.
replace cmbirthy=cmbirthy_32 if cmbirthy==.|cmbirthy==-94
fre cmbirthy


*month of birth
fre DobmonthYP
fre cmbirthm  
fre cmbirthm_32

replace cmbirthm=DobmonthYP if cmbirthm==.
replace cmbirthm=cmbirthm_32 if cmbirthm==.|cmbirthm==-94
fre cmbirthm

drop DobyearYP DobmonthYP cmbirthy_32 cmbirthm_32 W1sexYP 




*flag for insonsistencies number of children between sweeps (highe number of biological children in previous sweep)
cap drop biototal_flag_25_32
gen biototal_flag_25_32=biochild_tot_32-biochild_tot_25
replace biototal_flag_25_32=0 if inrange(biototal_flag_25_32,0,10)
replace biototal_flag_25_32=1 if inrange(biototal_flag_25_32,-10,-1)
label define biototal_flag_25_32 1 "Yes" 0 "No" -100 "no participation in one or both sweeps" -99 "information not provided", replace
label values biototal_flag_25_32 biototal_flag_25_32
label variable biototal_flag_25_32 "More biological children reported at age 25 than at age 32"
fre biototal_flag_25_32 //some inconsistencies N=75



*label and code survey participation
foreach Y of varlist nssurvey_25 nssurvey_32 {
replace `Y'=0 if `Y'==.	
	
label define `Y' 1 "Yes" 0 "No participation in survey sweep", replace	
label values `Y' `Y'
fre `Y'
}


*MISSSING DATA CODING

*age 25
foreach Y of varlist intmonth_25 intyear_25 partner_25 marital_25 anybiochildren_25 biochild_tot_25 biochildhh_total_25 biochildnonhh_total_25 biodied_total_25 anybiodied_25 biochildprev_total_25 biochildprevany_25 biochildy_eldest_25 biochildy_youngest_25 cmageybirth_eldest_25 cmageybirth_youngest_25 biochildboy_total_25 biochildgirl_total_25 anynonbio_25 nonbiochild_tot_25 adopt_tot_25 foster_tot_25 step_tot_25 nonbiochildy_eldest_25 nonbiochildy_youngest_25 nonbiochildboy_total_25 nonbiochildgirl_total_25 anychildren_25 children_tot_25 childy_eldest_25 childy_youngest_25 childboy_total_25 childgirl_total_25 partnerchildbio_25 partnerchildany_25  {

replace `Y'=-100 if `Y'==. & nssurvey_25==0 
replace `Y'=-99 if `Y'==. 	
fre `Y'	
}


*age 32
foreach Y of varlist intmonth_32 intyear_32 partner_32 marital_32 anybiochildren_32 biochild_tot_32 biochildhh_total_32 biochildnonhh_total_32 biodied_total_32 anybiodied_32 biochildprev_total_32 biochildprevany_32 biochildy_eldest_32 biochildy_youngest_32 cmageybirth_eldest_32 cmageybirth_youngest_32 biochildboy_total_32 biochildgirl_total_32 anynonbio_32 nonbiochild_tot_32 adopt_tot_32 foster_tot_32 step_tot_32 nonbiochildy_eldest_32 nonbiochildy_youngest_32 nonbiochildboy_total_32 nonbiochildgirl_total_32 anychildren_32 children_tot_32 childy_eldest_32 childy_youngest_32 childboy_total_32 childgirl_total_32 partnerchildbio_32 partnerchildany_32  {

replace `Y'=-100 if `Y'==. & nssurvey_32==0 
replace `Y'=-99 if `Y'==. 	
fre `Y'	
}

*cross sweep missingness
replace biototal_flag_25_32=-100 if biototal_flag_25_32==. & (nssurvey_25==0 | nssurvey_32==0)
replace biototal_flag_25_32=-99 if biototal_flag_25_32==. 	
fre biototal_flag_25_32	


foreach Y of varlist cmbirthm cmbirthy sex  {
replace `Y'=-99 if `Y'==. 	
fre `Y'	
}

label values cmbirthm intmonth
label values cmbirthy intyear

drop W8OUTCOME W9OUTCOME

order NSID SAMPPSU SAMPSTRATUM DESIGNWEIGHT MAINBOOST W8FINWT W9FINWTALLA W9FINWTLONGA W9FINWTALLB W9FINWTLONGB ///
sex cmbirthm cmbirthy ///
nssurvey_25 intyear_25 intmonth_25 partner_25 marital_25 anybiochildren_25 biochild_tot_25 biochildhh_total_25 biochildnonhh_total_25 biodied_total_25 anybiodied_25 biochildprev_total_25 biochildprevany_25 biochildy_eldest_25 biochildy_youngest_25 cmageybirth_eldest_25 cmageybirth_youngest_25 biochildboy_total_25 biochildgirl_total_25 anynonbio_25 nonbiochild_tot_25 adopt_tot_25 foster_tot_25 step_tot_25 nonbiochildy_eldest_25 nonbiochildy_youngest_25 nonbiochildboy_total_25 nonbiochildgirl_total_25 anychildren_25 children_tot_25 childy_eldest_25 childy_youngest_25 childboy_total_25 childgirl_total_25 partnerchildbio_25 partnerchildany_25 ///
nssurvey_32 intmonth_32 intyear_32 partner_32 marital_32 anybiochildren_32 biochild_tot_32 biototal_flag_25_32 biochildhh_total_32 biochildnonhh_total_32 biodied_total_32 anybiodied_32 biochildprev_total_32 biochildprevany_32 biochildy_eldest_32 biochildy_youngest_32 cmageybirth_eldest_32 cmageybirth_youngest_32 biochildboy_total_32 biochildgirl_total_32 anynonbio_32 nonbiochild_tot_32 adopt_tot_32 foster_tot_32 step_tot_32 nonbiochildy_eldest_32 nonbiochildy_youngest_32 nonbiochildboy_total_32 nonbiochildgirl_total_32 anychildren_32 children_tot_32 childy_eldest_32 childy_youngest_32 childboy_total_32 childgirl_total_32 partnerchildbio_32 partnerchildany_32 

drop W9FINWTALLA W9FINWTLONGA W9FINWTLONGB


save "$project\Next_Steps_fertility_histories.dta", replace




