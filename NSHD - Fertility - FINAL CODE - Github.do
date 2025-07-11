
******************************************************************************
*********HARMONISATION OF FERTILITY MEASURES FROM AGE 19 - AGE 53*************
******************************************************************************


*****************************************************************************
*******Variables to request from NSHD ***************************************

*Age 19 (1965): int19rec nochil65 marag65
*Age 20 (1966): int20 chil66 nochil66 maragy66
*Age 22 (1968): nochil68 nchild68 maragy68_v2
*Age 26 (1972): int26 date72 chil72 dobfchyr dobfchmr dobschyr dobschmr dobthdyr dobthdmr dobfthyr dobfthmr sexfch sexsch sexthd sexfth marst26
*Age 31 (1977): int31 age77 nochil77 mchil77 chilaiy77 chilaim77 chilaiiy77 chilaiim77 schil77 schilii77 cmarj77 marj77rec marj77rec2
*Age 36 (1982): int36 age82 chil82m totkid82 chay182 cham182 chay282_v2 cham282 chay382 cham382 chay482 cham482 chay582 cham582 chisnew1 chisnew2 chisnew3 chisnew4 chisnew5 marj82 rel182 rel282 rel382 rel482 rel582 rel682 rel782 rel882 rel982
*Age 43 (1989): int43 age89 chil89 chs89 chiln89 chss189 chss289 chss389 chss489 chss589 chay189 chay289 chay389 chay489 chay589  cham189 cham289 cham389 cham489 cham589 chys189 chys289 chys389 chys489 chys589 chms189 chms289 chms389 chms489 chms589 chis189 chis289 chis389 chis489 chis589  chss189 chss289 chss389 chss489 chss589 rel289 rel389 rel489 rel589 rel689 rel789 rel889 marj89 rel189a
*Age 53: (1999): int53 age99 newkid99 akid991 akid992 akid993 akid994 akid995 akid996 akid997 akid998 akid999 rel1 marstats

global derived "[insert file path to folder for derived data]" 

use "[insert file path to raw data]", clear 


*basic info for study members

gen cmbyear = 1946
label variable cmbyear "Birth year of study member"

gen cmbmonth = 3
label define month 3 "March"
label values cmbmonth month
label variable cmbmonth  "Birth month of study member"
tab1 cmbyear cmbmonth

*Century month when study member born: March 1946
gen cm_age = (46*12) + 3
label var cm_age "Century month study member born" 
tab cm_age

**************
*1965 [age 19]
**************

*interviewed or not
tab int19rec // int19 not available - but this variable was. 
recode int19rec (-9 0 = 0 "no participation in survey sweep") (1 = 1 "yes"), gen(NSHDSURVEY_19)
label variable NSHDSURVEY_19 "Whether took part in age 19 survey"
tab NSHDSURVEY_19

*number of biological children 

tab nochil65 
recode nochil65  (-9999 = -100 "no participation in sweep") (-9799/-9 = -99 "information not provided") (0=0 "no children") (1=1) (2=2), gen(biochild_tot_19)
label variable biochild_tot_19 "Number of biological children [age 19]"
tab biochild_tot_19


*any biological children

recode biochild_tot_19 (-100 = -100 "no participation in sweep") (-99 = -99 "information not provided") (0 = 0 "no") (1 2 = 1 "yes"), gen(anybiochildren_19) // collapsed to make a no/yes variable
label variable anybiochildren_19 "Whether has any biological children [age 19]"
tab anybiochildren_19


*marital status
label define mar -100 "no participation in sweep" -99 "information not provided" 1 "married" 2 "single", replace // marital status

tab marag65 // year / month got married
gen marital_19 = .
replace marital_19 = -100 if marag65 == -9999
replace marital_19 = 2 if marag65 == -9599
replace marital_19 = 1 if marag65 >= -9 & marag65 !=.
labe variable marital_19 "Marital status [age 19]"
label values marital_19 mar
tab marital_19

*marriage and parent status
label define marchild -100 "no participation in sweep" -99 "information not provided" 0"not married no children" 1"married no children" 2"children not married" 3"married and children" , replace
drop partnerchildbio_19
gen partnerchildbio_19 = -100
replace partnerchildbio_19 = -99 if marital_19 == -99 | anybiochildren_19 == -99	
replace partnerchildbio_19 = 0 if marital_19 == 2 & anybiochildren_19 == 0	 
replace partnerchildbio_19 = 1 if marital_19 == 1 & anybiochildren_19 == 0
replace partnerchildbio_19 = 2 if marital_19 == 2 & anybiochildren_19 == 1	
replace partnerchildbio_19 = 3 if marital_19 == 1 & anybiochildren_19 == 1	 


label values partnerchildbio_19 marchild
label variable partnerchildbio_19 "Whether has live in spouse and/or any bio children [age 19]"
tab partnerchildbio_19	 


**************
*1966 [age 20]
**************
*Interviewed or not
recode int20 (-9 0 2 3 4 25 = 0 "no participation in survey sweep") (1 = 1 "yes"), gen(NSHDSURVEY_20)
label variable NSHDSURVEY_20 "Whether took part in age 20 sweep"
tab NSHDSURVEY_20

*not got year / month of interviewed

*any biological children
drop anybiochildren_20
tab chil66 
recode chil66  (-9999 = -100 "no participation in sweep") (-9899/-9 = -99 "information not provided") (0=0 "no") (1=1 "yes") , gen(anybiochildren_20)
label variable anybiochildren_20 "Whether has any biological children [age 20]"
tab anybiochildren_20 // n=3891, 318 have a child
tab NSHDSURVEY_20  //n=3897 interviewed
replace anybiochildren_20 = -99 if anybiochildren_20 == -100 & NSHDSURVEY_20 == 1
replace anybiochildren_20 = -100 if anybiochildren_20 == -99 & NSHDSURVEY_20 == 0
tab anybiochildren_20 NSHDSURVEY_20 
tab anybiochildren_20

*number of biological children 

tab nochil66 
recode nochil66 (-9999 = -100 "no participation in sweep") (-9899/-9 = -99 "information not provided") (0=0 "no children") (1=1 ) (2=2) (3=3 ), gen(biochild_tot_20)
label variable biochild_tot_20 "Number of biological children [age 20]"
tab biochild_tot_20 // n=3891, 309 have 1+ children. 
tab biochild_tot_20 NSHDSURVEY_20
replace biochild_tot_20 = -99 if biochild_tot_20 == -100 & NSHDSURVEY_20 == 1
replace biochild_tot_20 = -100 if biochild_tot_20 == -99 & NSHDSURVEY_20 == 0
tab biochild_tot_20 anybiochildren_20

*flag to note mismatch information in biochild_tot_20 and anybiochildren_20 variables 

drop cflag_20

gen cflag_20 = 1 if biochild_tot_20 == 0 & anybiochildren_20 == -99 | biochild_tot_20 == 0 & anybiochildren_20 == 1 | biochild_tot_20 == -99 & anybiochildren_20 == 1 | biochild_tot_20 == 1 & anybiochildren_20 == 0
label variable cflag_20 "Mismatched information in anybiochildren_20 and biochild_tot_20 variables"
tab cflag_20

*Flag to denote reporting a child at earlier sweep, no child at current sweep 

gen cflag_1920 = 1 if (anybiochildren_19 == 1 & anybiochildren_20 == 0)
label variable cflag_1920 "Biological children reported at age 19, not age 20"
tab cflag_1920 // n=8

*marital status
tab1 maragm66 maragy66
drop marital_20
recode maragy66 (-9999 -9 = -100 "no participation in sweep") (-9899 = -99 "information not provided") (-9799 = 2 "single") (2/9 = 1 "married"), gen(marital_20)
label variable marital_20 "Marital status [age 20]"
replace marital_20 = -99 if NSHDSURVEY_20 == 1 & (maragy66 == -9999 | maragy66 == -9899)
tab marital_20

*marriage and parent status

drop partnerchildbio_20
gen partnerchildbio_20 = -100
replace partnerchildbio_20 = -99 if (marital_20 == -99 | anybiochildren_20 == -99)
replace partnerchildbio_20 = 0 if marital_20 == 2 & anybiochildren_20 == 0	 
replace partnerchildbio_20 = 1 if marital_20 == 1 & anybiochildren_20 == 0
replace partnerchildbio_20 = 2 if marital_20 == 2 & anybiochildren_20 == 1	
replace partnerchildbio_20 = 3 if marital_20 == 1 & anybiochildren_20 == 1	 


label values partnerchildbio_20 marchild
label variable partnerchildbio_20 "Whether has live in spouse and/or any bio children [age 20]"
tab partnerchildbio_20	 


**************
*1968 [age 22]
**************

*postal questionnaire - asks CM to bring information on children up to date: name / sex / dob

*Interviewed or not
recode int22 (-9 0 2 3 4 25 = 0 "no participation in survey sweep") (1 = 1 "yes"), gen(NSHDSURVEY_22)
label variable NSHDSURVEY_22 "Whether took part in age 22 sweep"
tab NSHDSURVEY_22

*not got year / month of interviewed
drop biochild_tot_22
tab nochil68
recode nochil68 (-9999 = -100 "no participation in sweep") (-9899/-9 = -99 "information not provided") (0=0 "no children") (1=1) (2=2) (3=3) (4=4) (5 = 5), gen(biochild_tot_22)
label variable biochild_tot_22 "Number of biological children [age 22]"
tab biochild_tot_22 

tab biochild_tot_22 NSHDSURVEY_22 // n=63 have a value but in NSHDSURVEY_22 coded as 0 [int22 = 'not contacted' or 'temporarily abroad']
replace biochild_tot_22 = -100 if biochild_tot_22 >= 0 & NSHDSURVEY_22 == 0 //set these to "not interviewed"
replace biochild_tot_22 = -99 if biochild_tot_22 == -100 & NSHDSURVEY_22 ==1 //set these to "no info"
replace biochild_tot_22 = -100 if biochild_tot_22 == -99 & NSHDSURVEY_22 ==0 //set these to "not interviewed info"
tab biochild_tot_22 NSHDSURVEY_22 


recode nchild68 (-1 = -100 "no participation in sweep") (-2 = -99 "information not provided") (0 = 0 "no") (1/ 5 = 1 "yes"), gen(anybiochildren_22)
label variable anybiochildren_22 "Whether has any biological children [age 22]"
tab anybiochildren_22

tab NSHDSURVEY_22 anybiochildren_22

replace anybiochildren_22 = -100 if anybiochildren_22 >= 0 & NSHDSURVEY_22 == 0 //set these to "not interviewed"
replace anybiochildren_22 = -99 if anybiochildren_22 == -100 & NSHDSURVEY_22 ==1 //set these to "no info"
replace anybiochildren_22 = -100 if anybiochildren_22 == -99 & NSHDSURVEY_22 ==0 //set these to "no info"
tab anybiochildren_22 NSHDSURVEY_22 


*flag to note mismatch information in biochild_tot_22 and anybiochildren_22 variables - not derived as no mismatch

*Flag to denote reporting a child at earlier sweep, no/fewer child at current sweep
tab anybiochildren_19 anybiochildren_22 
tab anybiochildren_20 anybiochildren_22 

gen cflag_1922 = 1 if (anybiochildren_19 == 1 & anybiochildren_22 == 0) | (anybiochildren_20 == 1 & anybiochildren_22 == 0)
label variable cflag_1922 "Biological children reported age 19 or 20, not at age 22"
tab cflag_1922 


*marital status
tab maragy68_v2 
tab maragy68_v2, nol

recode maragy68_v2 (-9999 -9 = -100 "no participation in sweep") (-9899 = -99 "information not provided") (-9799 = 2 "single") (2/9 = 1 "married"), gen(marital_22)
labe variable marital_22 "Marital status [age 22]"
tab marital_22
tab marital_22 NSHDSURVEY_22
replace marital_22 = -99 if marital_22 == -100 & NSHDSURVEY_22 == 1
replace marital_22 = -100 if marital_22 == -99 & NSHDSURVEY_22 == 0
replace marital_22 = -100 if marital_22 >= 0 & NSHDSURVEY_22 == 0
tab marital_22 NSHDSURVEY_22

*marriage and parent status

drop partnerchildbio_22
gen partnerchildbio_22 = -100
replace partnerchildbio_22 = -99 if marital_22 == -99 | anybiochildren_22 == -99	
replace partnerchildbio_22 = 0 if marital_22 == 2 & anybiochildren_22 == 0	 
replace partnerchildbio_22 = 1 if marital_22 == 1 & anybiochildren_22 == 0
replace partnerchildbio_22 = 2 if marital_22 == 2 & anybiochildren_22 == 1	
replace partnerchildbio_22 = 3 if marital_22 == 1 & anybiochildren_22 == 1	 


label values partnerchildbio_22 marchild
label variable partnerchildbio_22 "Whether has live in spouse and/or any bio children [age 22]"
tab partnerchildbio_22	 
tab partnerchildbio_22 NSHDSURVEY_22


**************
*1972 [age 26]
**************

*Interviewed or not
recode int26 (-9 0 2 3 4 25 = 0 "no participation in survey sweep") (1 = 1 "yes"), gen(NSHDSURVEY_26)
label variable NSHDSURVEY_26 "Whether took part in age 26 sweep"
tab NSHDSURVEY_26

*year and month of interview

recode date72 (1/12 = 1972) (13/24 = 1973) (25/36 = 1974) (37/47 = 1975) (-9999/-9 = -100 "no participation in sweep") (88/99 = -99 "information not provided"), gen(intyear_26) 
label variable intyear_26 "Interview year (age 26)"
tab intyear_26

drop intmonth_26
recode date72 (1 13 25 37 = 1 "Jan") (2 14 26 38 = 2 "Feb") (3 15 27 39 = 3 "March") (4 16 28 40 = 4 "April") (5 17 29 41 = 5 "May") (6 18 30 42 = 6 "June") (7 19 31 43 = 7 "July") (8 20 32 44 = 8 "Aug") (9 21 33 45 = 9 "Sept") (10 22 34 46 = 10 "Oct") (11 23 35 47 = 11 "Nov") (12 24 36 = 12 "Dec") (-9999/-9 = -100 "no participation in sweep") (88/99 = -99 "information not provided"), gen(intmonth_26)
label variable intmonth_26 "Interview month (age 26)"

tab intmonth_26 intyear_26


drop biochild_tot_26
tab chil72 // questionnaire variable 'how many children have you had' // 8 and 9 = don't know refused n=10 
recode chil72 (-9999 -9 = -100 "no participation in sweep") (0=0 "no children") (1=1) (2=2) (3=3) (4=4) (5=5) (6=6) (8 9 = -99  "information not provided"), gen(biochild_tot_26)
label variable biochild_tot_26 "Number of biological children [age 26]"
tab biochild_tot_26 

drop anybiochildren_26
recode chil72 (-9999 -9 = -100 "no participation in sweep") (8 9 = -99 "information not provided") (0=0 "no") (1/6 = 1 "yes"), gen(anybiochildren_26) // collapsed to make a no/yes variable
label variable anybiochildren_26 "Whether has any biological children [age 26]"
tab anybiochildren_26 


*Flag to denote reporting a child at earlier sweep, no child at current sweep 	  

drop flagsamp
gen flagsamp = 1 if (anybiochildren_19 >=0 & anybiochildren_26 >= 0) | (anybiochildren_20 >=0 & anybiochildren_26 >=0) | (anybiochildren_22 >=0 & anybiochildren_26 >=0)
tab flagsamp

drop cflag_1926
gen cflag_1926 = 1 if (anybiochildren_19 > anybiochildren_26) & flagsamp ==1 | (anybiochildren_20 > anybiochildren_26) & flagsamp ==1 | (anybiochildren_22 > anybiochildren_26) & flagsamp ==1
label variable cflag_1926 "Biological children reported age 19, 20 or 22, not at age 26"
tab cflag_1926 // n=6


drop cnflag_1926
gen cnflag_1926 = 1 if (biochild_tot_19 > biochild_tot_26) & flagsamp ==1 | (biochild_tot_20 > biochild_tot_26) & flagsamp ==1 | (biochild_tot_22 > biochild_tot_26) & flagsamp ==1
label variable cnflag_1926 "Fewer biological children reported age 26 than age 19, 20 or 22"
tab cnflag_1926 // n=8

tab cnflag_1926 cflag_1926, m


*calculating century month had eldest and youngest child: century month = month since 1900 
*HOWEVER some study members who were interviewed at age 26 have 5-9 children and but there is only information for DOB [and sex] of 1st-4th children
drop dobfchyr dobfchmr dobfthyr dobfthmr
local varlist dobfchy dobfchm dobfthy dobfthm // 1st and fourth child
foreach var in `varlist' {
	recode `var' (-9999/-9 = .) (88 99 = .), gen(`var'r)
}

*1st child
drop cmonthc1_26
gen cmonthc1_26 = (dobfchyr*12) + dobfchmr
summ cmonthc1_26
label var cmonthc1_26 "Century month [since 1900] had eldest [1st] child [Age 26]"
fre cmonthc1_26 // n=1989
tab cmonthc1_26 if NSHDSURVEY_26 == 1 //n=1821
tab cmonthc1_26 if NSHDSURVEY_26 != 1 // information for n=168 study members who are coded as dead/have emigrated/permanent refusal/not contacted/temp abroad
tab cmonthc1_26 anybiochildren_26 // information for n=1814 of those who report to have a child in anybiochildren_26 and n=7 who do not report to have a child in anybiochildren_26
tab anybiochildren_26 NSHDSURVEY_26


*set the n=168 and n=7 to missing 
replace cmonthc1_26 = . if NSHDSURVEY_26 !=1
replace cmonthc1_26 = . if anybiochildren_26 == 0 & NSHDSURVEY_26 ==1
tab cmonthc1_26 

*2nd child
drop cmonthc2_26
gen cmonthc2_26 = (dobschyr*12) + dobschmr
summ cmonthc2_26
label var cmonthc2_26 "Century month [since 1900] had 2nd child [Age 26]"
fre cmonthc2_26  // n=1023

fre cmonthc2_26 if NSHDSURVEY_26 == 1 // n=963
tab cmonthc2_26 if NSHDSURVEY_26 != 1 // n=60
tab cmonthc2_26 anybiochildren_26

replace cmonthc2_26 = . if NSHDSURVEY_26 !=1
replace cmonthc2_26 = . if anybiochildren_26 == 0 & NSHDSURVEY_26 ==1
tab cmonthc2_26 

*3rd child
drop cmonthc3_26
gen cmonthc3_26 = (dobthdyr*12) + dobthdmr
summ cmonthc3_26
label var cmonthc3_26 "Century month [since 1900] had 3rd child [Age 26]"
fre cmonthc3_26 // n=240
fre cmonthc3_26 if NSHDSURVEY_26 == 1 // n=227
fre cmonthc3_26 if NSHDSURVEY_26 != 1 // n=13

replace cmonthc3_26 = . if NSHDSURVEY_26 !=1
replace cmonthc3_26 = . if anybiochildren_26 == 0 & NSHDSURVEY_26 ==1
tab cmonthc3_26

*4th child
drop cmonthc4_26
gen cmonthc4_26 = (dobfthyr*12) + dobfthmr
summ cmonthc4_26
label var cmonthc4_26 "Century month [since 1900] had youngest [4th] child [Age 26]"
fre cmonthc4_26 // n=47
fre cmonthc4_26 if NSHDSURVEY_26 == 1 // n=47
fre cmonthc4_26 if NSHDSURVEY_26 != 1 // n=0

replace cmonthc4_26 = . if NSHDSURVEY_26 !=1
replace cmonthc4_26 = . if anybiochildren_26 == 0 & NSHDSURVEY_26 ==1
tab cmonthc4_26

*Age in years CM had children

drop agec1_26
gen agec1_26 = (cmonthc1_26 - cm_age) / 12
replace agec1_26 = floor(agec1_26) 
label var agec1_26 "Age [in years] had eldest [1st] child [Age 26]"
tab agec1_26 // n=1989 range: 15 - 26

drop agec2_26
gen agec2_26 = (cmonthc2_26 - cm_age) / 12
replace agec2_26 = floor(agec2_26) 
label var agec2_26 "Age [in years] had 2nd child [Age 26]"
tab agec2_26 // n= 1023 range: 17 - 26
tab agec2_26 if NSHDSURVEY_26 == 1 // n=963

drop agec3_26
gen agec3_26 = (cmonthc3_26 - cm_age) / 12
replace agec3_26 = floor(agec3_26) 
label var agec3_26 "Age [in years] had 3rd child [Age 26]"
tab agec3_26 // n= 240 range: 19 - 26
tab agec3_26 if NSHDSURVEY_26 == 1 // n=227

drop agec4_26
gen agec4_26 = (cmonthc4_26 - cm_age) / 12
replace agec4_26 = floor(agec4_26) 
label var agec4_26 "Age [in years] had 4th child [Age 26]"
tab agec4_26 // n= 47 range: 20 - 26
tab agec4_26 if NSHDSURVEY_26 == 1 // n=47

*Age had youngest and oldest child
drop cmageybirth_youngest_26 cmageybirth_eldest_26
egen cmageybirth_youngest_26 = rowmax(agec1_26 agec2_26 agec3_26 agec4_26)
egen cmageybirth_eldest_26 = rowmin(agec1_26 agec2_26 agec3_26 agec4_26)
label variable cmageybirth_youngest_26 "Age in years of study member at birth of youngest child [age 26]"
label variable cmageybirth_eldest_26 "Age in years of study member at birth of oldest child [age 26]"
summ cmageybirth_youngest_26 cmageybirth_eldest_26

*assigning missing values
label define missage -100 "no participation in sweep" -99 "information not provided" -10 "no children"
tab cmageybirth_eldest_26, nol
replace cmageybirth_eldest_26 = -10 if NSHDSURVEY_26 == 1 & anybiochildren_26 == 0 // if no children at age 26
replace cmageybirth_eldest_26 = -100 if NSHDSURVEY_26 == 0 // if not interviewed at age 43
replace cmageybirth_eldest_26 = -99 if NSHDSURVEY_26 == 1 & anybiochildren_26 == -99 // if interviewed at age 43 but no info on children
replace cmageybirth_eldest_26 = -99 if NSHDSURVEY_26 == 1 & cmageybirth_eldest_26 == . 
label values cmageybirth_eldest_26 missage
tab cmageybirth_eldest_26
tab cmageybirth_eldest_26 if NSHDSURVEY_26 == 1


tab cmageybirth_youngest_26
replace cmageybirth_youngest_26 = -10 if NSHDSURVEY_26 == 1 & anybiochildren_26 == 0 // if no children at age 43
replace cmageybirth_youngest_26 = -100 if NSHDSURVEY_26 == 0 // if not interviewed at age 43
replace cmageybirth_youngest_26 = -99 if NSHDSURVEY_26 == 1 & anybiochildren_26 == -99 // if interviewed at age 43 but no info on children
replace cmageybirth_youngest_26 = -99 if NSHDSURVEY_26 == 1 & cmageybirth_youngest_26 == . 
label values cmageybirth_youngest_26 missage
tab cmageybirth_youngest_26
tab cmageybirth_youngest_26 if NSHDSURVEY_26 == 1


*********************************************
*Age of children: 1972 (study member age 26)
*********************************************

tab NSHDSURVEY_26 // n3749 interviewed
tab age72 

*century month of interview: CM century month born in 555 + age in months when interviewed 
drop age72r
gen age72r = age72
recode age72r (-9 777 888 = .) 
summ age72r // of the n=3749 interviewed, n=3657 have age at interview information: range 312 - 356 

drop ageint_26
gen  ageint_26 = cm_age + age72r
label var ageint_26 "Century month interviewed [age 26]"
*replace ageint_26 = 869 if NSHDSURVEY_26 == 1 & age72r == . // replace the n=94 missing [value 888] with median - 869 or mean 871??
summ ageint_26 
tab ageint_26 NSHDSURVEY_26 // n=5 not interviewed 
replace ageint_26 = . if NSHDSURVEY_26 !=1
tab ageint_26 NSHDSURVEY_26
replace ageint_26 = . if  NSHDSURVEY_26 == 0

*generating age of children in years [1972]
summ ageint_26 cmonthc1_26
*1st child
drop agec1_26y
gen agec1_26y = (ageint_26 - cmonthc1_26) / 12 // month of interview - month had 1st child
replace agec1_26y = floor(agec1_26y)
label var agec1_26y "Age [in years] of 1st child [age 26]"
fre agec1_26y // n=1773
tab agec1_26y NSHDSURVEY_26

drop agec2_26y
gen agec2_26y = (ageint_26 - cmonthc2_26) / 12 // month of interview - month had 2nd child
replace agec2_26y = floor(agec2_26y)
label var agec2_26y "Age [in years] of 2nd child [age 26]"
fre agec2_26y // n=947
tab agec2_26y NSHDSURVEY_26

drop agec3_26y
gen agec3_26y = (ageint_26 - cmonthc3_26) / 12 // month of interview - month had 3rd child
replace agec3_26y = floor(agec3_26y)
label var agec3_26y "Age [in years] of 3rd child [age 26]"
fre agec3_26y // n=225
tab agec3_26y NSHDSURVEY_26

drop agec4_26y
gen agec4_26y = (ageint_26 - cmonthc4_26) / 12 // month of interview - month had 4th child
replace agec4_26y = floor(agec4_26y)
label var agec4_26y "Age [in years] of 4th child [age 26]"
fre agec4_26y // n=46
tab agec4_26y NSHDSURVEY_26


*age of eldest and youngest child

drop biochildy_youngest_26 biochildy_eldest_26
egen biochildy_eldest_26 = rowmax(agec1_26y agec2_26y agec3_26y agec4_26y)
egen biochildy_youngest_26 = rowmin(agec1_26y agec2_26y agec3_26y agec4_26y)
label variable biochildy_eldest_26 "Age in years of eldest biological child [Age 26]"
label variable biochildy_youngest_26 "Age in years of youngest biological child [Age 26]"
summ biochildy_youngest_26 biochildy_eldest_26


tab biochildy_eldest_26, nol
replace biochildy_eldest_26 = -10 if NSHDSURVEY_26 == 1 & anybiochildren_26 == 0 // if no children at age 26
replace biochildy_eldest_26 = -100 if NSHDSURVEY_26 == 0 // if not interviewed at age 26
replace biochildy_eldest_26 = -99 if NSHDSURVEY_26 == 1 & anybiochildren_26 == -99 // if interviewed at age 26 but no info on children
replace biochildy_eldest_26 = -99 if NSHDSURVEY_26 == 1 & biochildy_eldest_26 == . 
label values biochildy_eldest_26 missage
tab biochildy_eldest_26
tab biochildy_eldest_26 NSHDSURVEY_26


tab biochildy_youngest_26
replace biochildy_youngest_26 = -10 if NSHDSURVEY_26 == 1 & anybiochildren_26 == 0 // if no children at age 43
replace biochildy_youngest_26 = -100 if NSHDSURVEY_26 == 0 // if not interviewed at age 26
replace biochildy_youngest_26 = -99 if NSHDSURVEY_26 == 1 & anybiochildren_26 == -99 // if interviewed at age 26 but no info on children
replace biochildy_youngest_26 = -99 if NSHDSURVEY_26 == 1 & biochildy_youngest_26 == . 
label values biochildy_youngest_26 missage
tab biochildy_youngest_26
tab biochildy_youngest_26 NSHDSURVEY_26


*sex of children [age 26]
label define sexc -100 "no participation in sweep" -99 "information not provided" -10 "no (further) children" 1"male" 2"female", replace
label define biosexb  -100 "no participation in sweep" -99 "information not provided" -10 "no children" 0 "girls only", replace
label define biosexg  -100 "no participation in sweep" -99 "information not provided" -10 "no children" 0 "boys only", replace
tab1 sexfch sexsch sexthd sexfth 

recode sexfch (-9999 -9 = -100) (9 = -99) (8 = -10 ) (1 = 1 ) (2=2 ), gen(sexc1_26)
recode sexsch (-9999 -9 = -100) (9 = -99) (8 = -10 ) (1 = 1 ) (2=2 ), gen(sexc2_26)
recode sexthd (-9999 -9 = -100) (9 = -99) (8 = -10 ) (1 = 1 ) (2=2 ), gen(sexc3_26)
recode sexfth (-9999 -9 = -100) (9 = -99) (8 = -10 ) (1 = 1 ) (2=2 ), gen(sexc4_26)

label values sexc1_26 sexc
label values sexc2_26 sexc
label values sexc3_26 sexc
label values sexc4_26 sexc

label var sexc1_26 "Sex of 1st child: [age 26]"
label var sexc2_26 "Sex of 2nd child: [age 26]"
label var sexc3_26 "Sex of 3rd child: [age 26]"
label var sexc4_26 "Sex of 4th child: [age 26]"

tab1 sexc1_26 sexc2_26 sexc3_26 sexc4_26

tab sexc1_26 NSHDSURVEY_26 // a lot of information for study members who did not participate in age 26 survey....

drop biochildboy_total_26
egen biochildboy_total_26 = anycount(sexc1_26 sexc2_26 sexc3_26 sexc4_26), values(1)
replace biochildboy_total_26 = -100 if sexc1_26 == -100
replace biochildboy_total_26 = -99 if sexc1_26 == -99
replace biochildboy_total_26 = -10 if sexc1_26 == -10
replace biochildboy_total_26 = -100 if NSHDSURVEY_26 == 0 
replace biochildboy_total_26 = -99 if NSHDSURVEY_26 == 1 & biochildboy_total_26 == -100
label variable biochildboy_total_26 "Number of bio children who are boys [Age 26]"
label values biochildboy_total_26 biosexb
tab biochildboy_total_26

tab biochildboy_total_26 NSHDSURVEY_26

drop biochildgirl_total_26
egen biochildgirl_total_26 = anycount(sexc1_26 sexc2_26 sexc3_26 sexc4_26), values(2)
replace biochildgirl_total_26 = -100 if sexc1_26 == -100
replace biochildgirl_total_26 = -99 if sexc1_26 == -99
replace biochildgirl_total_26 = -10 if sexc1_26 == -10
replace biochildgirl_total_26 = -100 if NSHDSURVEY_26 == 0 
replace biochildgirl_total_26 = -99 if NSHDSURVEY_26 == 1 & biochildgirl_total_26 == -100
*replace biochildgirl_total_26 = sexc1_26 if biochildgirl_total_26 == 0 & sexc1_26 !=1
label variable biochildgirl_total_26 "Number of bio children who are girls [Age 26]"
label values biochildgirl_total_26 biosexg
tab biochildgirl_total_26

tab biochildgirl_total_26 NSHDSURVEY_26


*flag to denote mismatched info in anybiochildren_26 biochildgirl_total_26 or biochildboy_total_26
tab biochildgirl_total_26 anybiochildren_26
drop cgflag_26
gen cgflag_26 = 1 if (anybiochildren_26 == -99 & biochildgirl_total_26 == -10) | (anybiochildren_26 == 1 & biochildgirl_total_26 == -10) | (anybiochildren_26 == 0 & biochildgirl_total_26 == 0) | (anybiochildren_26 == 0 & biochildgirl_total_26 == 1)
label variable cgflag_26 "mismatched info in anybiochildren_26 & biochildgirl_total_26"
tab cgflag_26

tab biochildboy_total_26 anybiochildren_26
drop cbflag_26
gen cbflag_26 = 1 if (anybiochildren_26 == -99 & biochildboy_total_26 == -10) | (anybiochildren_26 == 1 & biochildboy_total_26 == -10) | (anybiochildren_26 == 0 & biochildboy_total_26 == 0) | (anybiochildren_26 == 0 & biochildboy_total_26 == 1)
label variable cbflag_26 "mismatched info in anybiochildren_26 & biochildboy_total_26"
tab cbflag_26


*marital status age 26

*unclear whether the variables are accumulated sample??
tab marst26 NSHDSURVEY_26
drop marital_26
recode marst26(-9999 -9 = -100 "no participation in sweep") (1 2 6 = 1 "married") (0 3 4 = 3 "single not cohabiting") (5 7 = 2 "single cohabiting with partner"), gen(marital_26)
replace marital_26 = -100 if NSHDSURVEY_26 == 0
replace marital_26 = -99 if NSHDSURVEY_26 == 1 & marital_26 == -100
label variable marital_26 "Marital status [age 26]" 
tab marital_26
tab marital_26 NSHDSURVEY_26

label define harmmar -100 "no participation in sweep" -99 "information not provided" 1 "Married" 2 "Single cohabiting" 3 "Single not cohabiting", replace
label values marital_26 harmmar
tab marital_26 NSHDSURVEY_26


**If assume married and cohab = partner in household, could make 'partner in household' variable
drop partner_26
recode marital_26 (-100 = -100 "no participation in sweep") (-99 = -99 "information not provided") (3 = 0 "no") (1 2 = 1 "yes"), gen(partner_26)
label variable partner_26 "Partner in HH (age 26)"
tab partner_26 marital_26


*Marital Status and Parent status
label define marchild2 -100 "no participation in sweep" -99 "information not provided" 0"no partner no children" 1"partner no children" 2"children no partner" 3"partner and children" , replace

drop partnerchildbio_26
gen partnerchildbio_26 = -100 if NSHDSURVEY_26  == 0
replace partnerchildbio_26 = 0 if marital_26 == 3 & anybiochildren_26 == 0	 
replace partnerchildbio_26 = 1 if (marital_26 == 1 | marital_26 == 2) & anybiochildren_26 == 0
replace partnerchildbio_26 = 2 if marital_26 == 3 & anybiochildren_26 == 1	
replace partnerchildbio_26 = 3 if (marital_26 == 1 | marital_26 == 2) & anybiochildren_26 == 1	 
replace partnerchildbio_26 = -99 if marital_26 == -99 | anybiochildren_26 == -99	 
label values partnerchildbio_26 marchild2
label variable partnerchildbio_26 "Whether has live in spouse and/or any bio children [age 26]"
tab partnerchildbio_26 // n=3706 with info in both	 
tab partnerchildbio_26 NSHDSURVEY_26 


**************
*1977 [age 31]
**************

*interviewed
recode int31 (-9 0 2 3 4 25 = 0 "no participation in survey sweep ") (1 = 1 "yes"), gen(NSHDSURVEY_31)
label variable NSHDSURVEY_31 "Whether took part in age 31 sweep"
tab NSHDSURVEY_31

*year and month of interview
gen age77r = age77
replace age77r = . if age77r == -9999 | age77r == -9
replace age77r = . if age77r == 9999 
tab age77r // range from 370 [Jan 1977] - 403 [Oct 1979]


label define miss -100 "no participation in sweep" -99 "information not provided", replace


recode age77r (370 / 381 = 1977) (382 / 393 = 1978) (394 / 403 = 1979), gen(intyear_31)
replace intyear_31 = -100 if NSHDSURVEY_31 == 0
replace intyear_31 = -99 if NSHDSURVEY_31 == 1 & intyear_31 == .
label variable intyear_31 "Interview year (age 31)"
label values intyear_31 miss
tab intyear_31 NSHDSURVEY_31

drop intmonth_31
recode age77r (370 382 394 = 1 "Jan") (371 383 395 = 2 "Feb") (372 384 396 = 3 "March") (373 385 397 = 4 "April") (374 386 398 = 5 "May") (375 387 399 = 6 "June") (376 388 400 = 7 "July") (377 389 401 = 8 "Aug") (378 390 402 = 9 "Sept") (379 391 403 = 10 "Oct") (380 392 = 11 "Nov") (381 393 = 12 "Dec"), gen(intmonth_31)

replace intmonth_31 = -100 if NSHDSURVEY_31 == 0
replace intmonth_31 = -99 if NSHDSURVEY_31 == 1 & intmonth_31 == .

label define month -100 "no participation in sweep" -99 "information not provided" 1 "Jan" 2 "Feb" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "Aug" 9 "Sept" 10 "Oct" 11 "Nov" 12 "Dec", replace

label variable intmonth_31 "Interview month (age 31)"
label values intmonth_31 month

tab intmonth_31
tab intmonth_31 NSHDSURVEY_31
tab intmonth_31 intyear_31

*Questionnaire asks about children since last contact. 

*variable identifying when 'last contact' was 

*last contact prior to 1977
drop lastint_p31
gen lastint_p31 = .
replace lastint_p31 = 19 if NSHDSURVEY_19 == 1 //last interview age 19 - 1965
replace lastint_p31 = 20 if NSHDSURVEY_20 == 1 //last interview age 20 - 1966
replace lastint_p31 = 22 if NSHDSURVEY_22 == 1 //last interview age 22 - 1968
replace lastint_p31 = 26 if NSHDSURVEY_26 == 1 //last interview age 26 - 1972
replace lastint_p31 = 99 if lastint_p31 == . & NSHDSURVEY_31 == 1 // n=63 no date of last interview
label variable lastint_p31 "Age/Year of last interview prior to age 31"
tab lastint_p31

tab lastint_p31 NSHDSURVEY_31 // n=63 interviewed in 1977, but not know when last interviewed [age19 to age26 - not interviewed].
list NSHDSURVEY_19 NSHDSURVEY_20 NSHDSURVEY_22 NSHDSURVEY_26 if NSHDSURVEY_31 == 1 & lastint_p31 == 99

*these variables are for use in later derivation using information from 'last contact' sweep [above]
drop child77a
tab nochil77  // number of children since last contact // 8 = zero children [1694] 9 = ? [197] nochil77 = questionnaire variable
recode nochil77 (-9999 -9 = -1 "not interviewed") (9 = -2 "no info") (8=0) (1=1) (2 = 2) (3 = 3) (4 = 4) (5 =5), gen(child77a)
label variable child77a "number of children since last contact [age 31]"
tab child77a // n=3142, 1448 had a child [1 - 5]

drop child77b
tab mchil77
tab nochil77 mchil77
recode mchil77 (-9999 -9 = -1 "not interviewed") (9 = -2 "no info") (0 8=0 "no") (1=1 "yes"), gen(child77b) // any children since last contact 

label variable child77b "had a child since last contact [age 31]"
tab child77b // n=3143, 1450 had a child [following recode below]

tab child77a child77b 

*flag to note mismatch information in child77a and child77b variables 
drop cflag77
gen cflag77 = 1 if child77a  == 0 & child77b ==1 | child77a == -2 & child77b ==1
label variable cflag77 " Mismatched information in child77a and child77b variables"
tab cflag77

	  
*generating 'number of biological children' variable including info from last contact: 1977 info and info from when last contacted prior to 1977

label define child  -100 "no participation in sweep" -99 "information not provided" 0 "no children"
drop biochild_tot_31
gen biochild_tot_31 = .
replace biochild_tot_31 = child77a + biochild_tot_19 if lastint_p31 == 19 & child77a >=0 & biochild_tot_19 >= 0
replace biochild_tot_31 = child77a + biochild_tot_20 if lastint_p31 == 20 & child77a >=0 & biochild_tot_20 >= 0
replace biochild_tot_31 = child77a + biochild_tot_22 if lastint_p31 == 22 & child77a >=0 & biochild_tot_22 >= 0
replace biochild_tot_31 = child77a + biochild_tot_26 if lastint_p31 == 26 & child77a >=0 & biochild_tot_26 >= 0
replace biochild_tot_31 = child77a if lastint_p31 == 99 & child77a >=0 
replace biochild_tot_31 = -100 if lastint_p31 == 26 & biochild_tot_26 == -99 & NSHDSURVEY_31 == 0
replace biochild_tot_31 = -99 if child77a == -2 
replace biochild_tot_31 = -100 if child77a == -1 & biochild_tot_31 == .
tab biochild_tot_31 
label variable biochild_tot_31 "number of biological children [age 31]"
label values biochild_tot_31 child
tab biochild_tot_31 
tab biochild_tot_31 NSHDSURVEY_31

drop anybiochildren_31
recode biochild_tot_31 (-100 = -100 "no participation in sweep") (-99 = -99 "information not provided")(0=0 "no") (1/9 = 1 "yes"), gen(anybiochildren_31)
label variable anybiochildren_31 "Has a biological child [age 31]"
tab anybiochildren_31 NSHDSURVEY_31


*Flag to denote reporting a child at earlier sweep, no child at current sweep 
drop cflag_1931
gen cflag_1931 = 1 if (anybiochildren_19 == 1 & anybiochildren_31 == 0) | (anybiochildren_20 == 1 & anybiochildren_31 == 0) | (anybiochildren_22 == 1 & anybiochildren_31 == 0) | (anybiochildren_26 == 1 & anybiochildren_31 == 0)
label variable cflag_1931 "Biological children reported age 19, 20, 22 or 26, not at age 31"
tab cflag_1931 // n=2

drop flagsamp
gen flagsamp = 1 if (biochild_tot_19 >=0 & biochild_tot_31 >=0) | (biochild_tot_20 >=0 & biochild_tot_31 >=0) | (biochild_tot_22 >=0 & biochild_tot_31 >=0) | (biochild_tot_26 >=0 & biochild_tot_31 >=0)
tab flagsamp

*Flag to denote number of children at current sweep is less than the number reported at earlier sweep 
drop cnflag_1931
gen cnflag_1931 = 1 if (biochild_tot_19 > biochild_tot_31) & flagsamp ==1 | (biochild_tot_20 > biochild_tot_31) & flagsamp ==1 | (biochild_tot_22 > biochild_tot_31) & flagsamp ==1 | (biochild_tot_26 > biochild_tot_31) & flagsamp ==1
label variable cnflag_1931 "Fewer biological children reported age 31 than age 19, 20, 22 or 26"
tab cnflag_1931 // n=4

*In nochil77 and [my] child77a variable study members had between 0-5 children since last contact. However, there is only age and sex information for TWO children: chilaim77 chilaiy77 chilaiim77 chilaiiy77 schil77 schilii77. How to best update age of / age had youngest/oldest child and also total number of girl/boy children variables?

*calculating century month had 1st child: century month = month since 1900

tab1 chilaiy77 chilaim77 // year and month had child

gen child1y_31 = chilaiy77
gen child1m_31 = chilaim77
recode child1y_31 (-9999/-9 = .) (88 99 = .)
recode child1m_31 (-9999/-9 = .) (88 99 = .)
tab1 child1y_31 child1m_31

cap drop cmonthc1_31
gen cmonthc1_31 = (child1y_31*12) + child1m_31
summ cmonthc1_31
label var cmonthc1_31 "Century month [since 1900] had 1st child [Age 31]"
fre cmonthc1_31 // n=1439

*Age in years CM had 1st child
drop agec1_31
gen agec1_31 = (cmonthc1_31 - cm_age) / 12
replace agec1_31 = round(agec1_31, .01) // round to 2 decimal places 
replace agec1_31 = floor(agec1_31) 
label var agec1_31 "Age [in years] had 1st child [Age 31]"
tab agec1_31 // n=1439


*calculating century month had 2nd child: century month = month since 1900
tab1 chilaiiy77 chilaiim77

gen child2y_31 = chilaiiy77
gen child2m_31 = chilaiim77
recode child2y_31 (-9999/-9 = .) (88 99 = .)
recode child2m_31 (-9999/-9 = .) (88 99 = .)
tab1 child2y_31 child2m_31

cap drop cmonthc277
gen cmonthc2_31 = (child2y_31*12) + child2m_31
summ cmonthc2_31
label var cmonthc2_31 "Century month [since 1900] had 2nd child [Age 31]"
fre cmonthc2_31 // n=262


*Age in years CM had 2nd child
drop agec2_31
gen agec2_31 = (cmonthc2_31 - cm_age) / 12
replace agec2_31 = round(agec2_31, .01) // round to 2 decimal places 
replace agec2_31 = floor(agec2_31) 
label var agec2_31 "Age [in years] had 2nd child [Age 31]"
tab agec2_31 // n=262

drop cmageybirth_eldest_31 cmageybirth_youngest_31
*Age in years had eldest / youngest child 
egen cmageybirth_eldest_31 = rowmin(agec1_26 agec2_26 agec3_26 agec4_26 agec1_31 agec2_31)
egen cmageybirth_youngest_31 = rowmax(agec1_26 agec2_26 agec3_26 agec4_26 agec1_31 agec2_31)
label variable cmageybirth_youngest_31 "Age in years of study member at birth of youngest child [age 31]"
label variable cmageybirth_eldest_31 "Age in years of study member at birth of oldest child [age 31]"
summ cmageybirth_youngest_31 cmageybirth_eldest_31 

summ cmageybirth_eldest_31 //n=2703
summ cmageybirth_eldest_31 if NSHDSURVEY_31 == 1 //n=2305

summ cmageybirth_youngest_31 //n=2703
summ cmageybirth_youngest_31 if NSHDSURVEY_31 == 1 //n=2305


tab cmageybirth_eldest_31 NSHDSURVEY_31
replace cmageybirth_eldest_31 = -10 if NSHDSURVEY_31 == 1 & anybiochildren_31 == 0 // if no children at age 1
replace cmageybirth_eldest_31 = -100 if NSHDSURVEY_31 == 0 // if not interviewed at age 43
replace cmageybirth_eldest_31 = -99 if NSHDSURVEY_31 == 1 & anybiochildren_31 == -99 // if interviewed at age 31 but no info on children
replace cmageybirth_eldest_31 = -99 if NSHDSURVEY_31 == 1 & cmageybirth_eldest_31 == . 
label values cmageybirth_eldest_31 missage
tab cmageybirth_eldest_31
tab cmageybirth_eldest_31 NSHDSURVEY_31


tab cmageybirth_youngest_31 NSHDSURVEY_31
replace cmageybirth_youngest_31 = -10 if NSHDSURVEY_31 == 1 & anybiochildren_31 == 0 // if no children at age 31
replace cmageybirth_youngest_31 = -100 if NSHDSURVEY_31 == 0 // if not interviewed at age 31
replace cmageybirth_youngest_31 = -99 if NSHDSURVEY_31 == 1 & anybiochildren_31 == -99 // if interviewed at age 31 but no info on children
replace cmageybirth_youngest_31 = -99 if NSHDSURVEY_31 == 1 & cmageybirth_youngest_31 == . 
label values cmageybirth_youngest_31 missage
tab cmageybirth_youngest_31
tab cmageybirth_youngest_31 NSHDSURVEY_31 


*century month of interview date

gen age31 = age77
recode age31 (-9 9999 = .)
gen cmonth_31 = (cm_age + age31) // century month born + age at interview in 1977 in months
summ cmonth_31


*generating age of children in years [1977]

*1st child
drop agec1_31y
gen agec1_31y = (cmonth_31 - cmonthc1_31) / 12 // month of interview - month had 1st child
replace agec1_31y = floor(agec1_31y)
recode agec1_31y -1 = 0
label var agec1_31y "Age [in years] of 1st child [age 31]"
fre agec1_31y // n=1436
tab agec1_31y NSHDSURVEY_31 //

*2nd child
drop agec2_31y
gen agec2_31y = (cmonth_31 - cmonthc2_31) / 12 // month of interview - month had 2nd child
replace agec2_31y = floor(agec2_31y)
label var agec2_31y "Age [in years] of 2nd child [age 31]"
fre agec2_31y // n=262
tab agec2_31y NSHDSURVEY_31 //n=1 not interviewed


drop biochildy_eldest_31 biochildy_youngest_31
egen biochildy_eldest_31 = rowmax(agec1_26y agec2_26y agec3_26y agec4_26y agec1_31y agec2_31y)
egen biochildy_youngest_31 = rowmin(agec1_26y agec2_26y agec3_26y agec4_26y agec1_31y agec2_31y)
label variable biochildy_eldest_31 "Age in years of eldest biological child [Age 31]"
label variable biochildy_youngest_31 "Age in years of youngest biological child [Age 31]"
summ biochildy_youngest_31 biochildy_eldest_31	  

replace biochildy_eldest_31 = -10 if NSHDSURVEY_31 == 1 & anybiochildren_31 == 0 // if no children at age 31
replace biochildy_eldest_31 = -100 if NSHDSURVEY_31 == 0 // if not interviewed at age 31
replace biochildy_eldest_31 = -99 if NSHDSURVEY_31 == 1 & anybiochildren_31 == -99 // if interviewed at age 31 but no info on children
replace biochildy_eldest_31 = -99 if NSHDSURVEY_31 == 1 & biochildy_eldest_31 == . 
label values biochildy_eldest_31 missage
tab biochildy_eldest_31
tab biochildy_eldest_31 NSHDSURVEY_31 

replace biochildy_youngest_31 = -10 if NSHDSURVEY_31 == 1 & anybiochildren_31 == 0 // if no children at age 31
replace biochildy_youngest_31 = -100 if NSHDSURVEY_31 == 0 // if not interviewed at age 31
replace biochildy_youngest_31 = -99 if NSHDSURVEY_31 == 1 & anybiochildren_31 == -99 // if interviewed at age 31 but no info on children
replace biochildy_youngest_31 = -99 if NSHDSURVEY_31 == 1 & biochildy_youngest_31 == . 
label values biochildy_youngest_31 missage
tab biochildy_youngest_31
tab biochildy_youngest_31 NSHDSURVEY_31 


*sex of children [age 31]

tab1 schil77 schilii77

recode schil77 (-9999 -9 = -100 "no participation in sweep") (3 4 5 9 = -99 "information not provided") (8 = 0 "no child") (1 = 1 "male") (2=2 "female"), gen(sexc1_31)
recode schilii77 (-9999 -9 = -100 "no participation in sweep") (4 9 = -99 "information not provided") (8 = 0 "no child") (1 = 1 "male") (2=2 "female"), gen(sexc2_31)


label var sexc1_31 "Sex of 1st child [since last interview]: [age 31]"
label var sexc2_31 "Sex of 2nd child [since last interview]: [age 31]"

tab1 sexc1_31 sexc2_31 

drop biochildboy_total_31
egen biochildboy_total_31 = anycount(sexc1_26 sexc2_26 sexc3_26 sexc4_26 sexc1_31 sexc2_31), values(1)
replace biochildboy_total_31 = -100 if sexc1_31 == -100
replace biochildboy_total_31 = -99 if sexc1_31 == -99
replace biochildboy_total_31 = -10 if anybiochildren_31 == 0
label variable biochildboy_total_31 "Number of bio children who are boys [Age 31]"
label values biochildboy_total_31 biosexb
tab biochildboy_total_31
tab biochildboy_total_31 NSHDSURVEY_31

drop biochildgirl_total_31
egen biochildgirl_total_31 = anycount(sexc1_26 sexc2_26 sexc3_26 sexc4_26 sexc1_31 sexc2_31), values(2)
replace biochildgirl_total_31 = -100 if sexc1_31 == -100
replace biochildgirl_total_31 = -99 if sexc1_31 == -99
replace biochildgirl_total_31 = -10 if anybiochildren_31 == 0
label variable biochildgirl_total_31 "Number of bio children who are girls [Age 31]"
label values biochildgirl_total_31 biosexg
tab biochildgirl_total_31
tab biochildgirl_total_31 NSHDSURVEY_31 

*flag to denote mismtched info in anybiochildren_31 biochildgirl_total_31
tab biochildgirl_total_31 anybiochildren_31
drop cgflag_31
gen cgflag_31 = 1 if (anybiochildren_31 == 0 & biochildgirl_total_31 == 1) | (anybiochildren_31 == 1 & biochildgirl_total_31 == -99)
label variable cgflag_31 "mismatched info in anybiochildren_31 & biochildgirl_total_31"
tab cgflag_31

tab biochildboy_total_31 anybiochildren_31
drop cbflag_31
gen cbflag_31 = 1 if (anybiochildren_31 == 0 & biochildboy_total_31 == 1) | (anybiochildren_31 == 1 & biochildboy_total_31 == -99)
label variable cbflag_31 "mismatched info in anybiochildren_31 & biochildboy_total_31"
tab cbflag_31


*marital status age 31

tab NSHDSURVEY_31 // n=3339 interviewed 

tab lastint_p31
tab cmarj77 // any change to marital status since last interviewed n=418 = yes
tab marj77rec marj77rec2 // present marital status - if a change - info for n=402/418

tab1 marital_19 marital_20 marital_22 marital_26
*getting last marital status for those whose marital status not changed at age 31 from when last interviewed
*marital_19 - marital_22 only single or married; marital_26 includes if single cohabiting
drop mmarital_31 
gen mmarital_31 = marital_19 if marital_19 >= 0 & lastint_p31 == 19 & cmarj77 == 0 // no last interview date 
replace mmarital_31 = marital_20 if marital_20 >= 0 & lastint_p31 == 20 & cmarj77 == 0
replace mmarital_31 = marital_22 if marital_22 >= 0 & lastint_p31 == 22 & cmarj77 == 0
replace mmarital_31 = marital_26 if marital_26 >= 0 & lastint_p31 == 26 & cmarj77 == 0
// some cm were interviewed earlier but gave no marital status info when interviewed at an earlier time
replace mmarital_31 = marital_26 if  marital_26 >= 0 & mmarital_31 == . & lastint_p31 !=. & cmarj77 == 0  // taking most recent earlier date first
replace mmarital_31 = marital_22 if  marital_22 >= 0 & mmarital_31 == . & lastint_p31 !=. & cmarj77 == 0
replace mmarital_31 = marital_20 if  marital_20 >= 0 & mmarital_31 == . & lastint_p31 !=. & cmarj77 == 0
replace mmarital_31 = marital_19 if  marital_19 >= 0 & mmarital_31 == . & lastint_p31 !=. & cmarj77 == 0
tab mmarital_31 // n=2859 of n=2907

tab cmarj77

drop tempmar31 
tab marj77rec
recode marj77rec (1 = 1) (3 4 = 2) (6 = 3) (-9999 -9 8 9 = .), gen(tempmar31) 
tab tempmar31

drop marital_31
gen marital_31 = .
replace marital_31 = tempmar31 if cmarj77 == 1 & tempmar31 !=. // info for 400/418 who had change in status
replace marital_31 = mmarital_31 if marital_31 == . // info for 2859 of 2907 who had no change from previous interview
replace marital_31 = 9 if marital_31 == . & cmarj77 == 0 & marital_19 < 0 & marital_20 < 0 & marital_22 < 0 & marital_26 < 0 // reported no change since last interview but no info in previous marital status variables [n=48]
list marital_19  marital_20  marital_22  marital_26 int31 if marital_31 == 9 // [n=48]

replace marital_31 = -99 if marital_31 == . & marj77rec2 == -2
replace marital_31 = -100 if marital_31 == . & marj77rec2 == -1
replace marital_31 = -99 if marital_31 == 9
tab marital_31 // n=6 missing
tab marital_31 marj77rec2, m

*who are the missing n=6?
list marital_19  marital_20  marital_22  marital_26b marry77b  if marital_31 == . & int31 == 1
list int20 int22 int26 int20to31 cmarj77 marj77rec if marital_31 == . & int31 == 1 // marital change but n/a in marj77rec
list marital_19  marital_20  marital_22  marital_26b cmarj77 marj77rec2 int31 if marital_31 == .

replace marital_31 = -99 if marital_31 == .
tab marital_31
label values marital_31 harmmar
label variable marital_31 "Marital status [age 31]"
tab marital_31


*partner in household

recode marital_31 (-100 = -100 "no participation in sweep") (-99 = -99 "information not provided") (3 = 0 "no") (1 2 = 1 "yes"), gen(partner_31)
label variable partner_31 "Partner in HH (age 31)"
tab partner_31


*Marital Status and Parent status

*using marital_31 marital_31b anybiochildren_31 - my derived variables
tab1 marital_31 anybiochildren_31
drop partnerchildbio_31
gen partnerchildbio_31 = -100
replace partnerchildbio_31 = 0 if partner_31 == 0 & anybiochildren_31 == 0	 
replace partnerchildbio_31 = 1 if partner_31 == 1 & anybiochildren_31 == 0
replace partnerchildbio_31 = 2 if partner_31 == 0 & anybiochildren_31 == 1	
replace partnerchildbio_31 = 3 if partner_31 == 1 & anybiochildren_31 == 1	 
replace partnerchildbio_31 = -99 if marital_31 == -99 | anybiochildren_31 == -99	 
label values partnerchildbio_31 marchild2
label variable partnerchildbio_31 "Whether has live in spouse and/or any bio children [age 31]"
tab partnerchildbio_31 // n=3068 with info in both	 ; n=271 missing in marital or chidlren vars || need to look further into this
tab partnerchildbio_31 NSHDSURVEY_31


**************
*1982 [age 36]
**************

*interviewed
drop NSHDSURVEY_36
recode int36 (-9 0 2 3 4 25 = 0 "no participation in survey sweep") (1 = 1 "yes"), gen(NSHDSURVEY_36)
label variable NSHDSURVEY_36 "Whether took part in age 36 survey sweep"
tab NSHDSURVEY_36

*year and month of interview
*these variable match existing derived variables in dataset: inty82 intm82

gen age36 = age82
replace age36 = . if age82 == -9
tab age36 // range from 432 [March 1982] - 450 [June 1983]

recode age36 (432 / 441 = 1982) (442 / 450 = 1983) , gen(intyear_36)
replace intyear_36 = -100 if NSHDSURVEY_36 == 0
replace intyear_36 = -99 if NSHDSURVEY_36 == 1 & intyear_36 == .
label variable intyear_36 "Interview year (age 36)"
label values intyear_36 missage
tab intyear_36


drop intmonth_36
recode age36 (442 = 1 "Jan") (443 = 2 "Feb") (432 444 = 3 "March") (433 445 = 4 "April") (434 446 = 5 "May") (435 = 6 "June") (436 = 7 "July") (437 = 8 "Aug") (438 450 = 9 "Sept") (439 = 10 "Oct") (440 = 11 "Nov") (441 = 12 "Dec"), gen(intmonth_36)
replace intmonth_36 = -100 if NSHDSURVEY_36 == 0
replace intmonth_36 = -99 if NSHDSURVEY_36 == 1 & intmonth_36 == .
label variable intmonth_36 "Interview year (age 36)"
label values intmonth_36 month
tab intmonth_36
label variable intmonth_36 "Interview month (age 36)"

tab intmonth_36


*Children 

tab int36 age82 chil82m  // ever had a child [questionnaire variable]
tab totkid82 // total number of children in 1982 [derived]
*other variables in questionnaire - not dataset: chil82 [ever had children]; how many children [chiln82]; any children died [child82]

drop anybiochildren_36 
recode chil82m (98 -9 = -100 "no participation in sweep") (9 = -99 "information not provided") (0=0 "no") (1 = 1 "yes"), gen(anybiochildren_36)
label variable anybiochildren_36 "Has a biological child [age 36]"
tab anybiochildren_36 
tab anybiochildren_36 NSHDSURVEY_36 

drop biochild_tot_36
recode totkid82 (99 -9 =-100 "no participation in sweep") (0=0 "no children") (1 = 1) (2 = 2) (3 = 3) (4 = 4) (5 =5), gen(biochild_tot_36)
label variable biochild_tot_36 "Number of biological children [age 36]"
tab biochild_tot_36 NSHDSURVEY_36 // n=3321
tab biochild_tot_36 anybiochildren_36

* Recoding - missing in anybiochildren_36 but identified as no children in biochild_tot_36
list nshdid_ntag1 if anybiochildren_36 == -2 & biochild_tot_36 == 0 // ID:  15270613
replace anybiochildren_36 = 0 if nshdid_ntag1 == 15270613


*flag to note discrepancy between child82 and nchild82 (totkid82)
gen cflag_36 = 1 if anybiochildren_36 == 0 & biochild_tot_36 > 0 | anybiochildren_36 == 1 & biochild_tot_36 ==0
label variable cflag_36 "Mismatched information in anybiochildren_36 and biochild_tot_36 variables"

tab cflag_36 // n=11

*Flag to denote reporting a/some children at earlier sweep, no/fewer children at current sweep 	  

drop flagsamp
gen flagsamp = 1 if (biochild_tot_19 > -1 & biochild_tot_36 > -1) | (biochild_tot_20 > -1 & biochild_tot_36 > -1) | (biochild_tot_22 > -1 & biochild_tot_36 > -1) | (biochild_tot_26 > -1 & biochild_tot_36 > -1) | (biochild_tot_31 > -1 & biochild_tot_36 > -1) 
tab flagsamp

drop cnflag_1936
gen cnflag_1936 = 1 if ((biochild_tot_19 > biochild_tot_36) & flagsamp ==1) | ((biochild_tot_20 > biochild_tot_36) & flagsamp ==1) | ((biochild_tot_22 > biochild_tot_36) & flagsamp ==1) | ((biochild_tot_26 > biochild_tot_36) & flagsamp ==1) | ((biochild_tot_31 > biochild_tot_36) & flagsamp ==1)
label variable cnflag_1936 "Fewer children reported at age 36 than at age 19, 20, 22, 26 or 31"
tab cnflag_1936 // n=36


*when had children

tab1 chay182 cham182 chay282_v2 cham282 chay382 cham382 chay482 cham482 chay582 cham582 
local varlist chay182 cham182 chay282_v2 cham282 chay382 cham382 chay482 cham482 chay582 cham582
foreach var in `varlist' {
	recode `var' (-9999/-9 = .) (88 99 = .), into(`var'r)
	tab1 `var' `var'r
}

*generating century month had 1st child in 1982
drop cmonthc1_36
gen cmonthc1_36 = (chay182r*12) + cham182r
summ cmonthc1_36
label var cmonthc1_36 "Century month [since 1900] had 1st child [age 36]"
fre cmonthc1_36 // n=2734

*generating century month had 2nd child in 1982 
drop cmonthc2_36
gen cmonthc2_36 = (chay282_v2r*12) + cham282r
summ cmonthc2_36
label var cmonthc2_36 "Century month [since 1900] had 2nd child [age 36]"
fre cmonthc2_36 // n=2267

*generating century month had 3rd child in 1982
drop cmonthc3_36
gen cmonthc3_36 = (chay382r*12) + cham382r
summ cmonthc3_36
label var cmonthc3_36 "Century month [since 1900] had 3rd child [age 36]"
fre cmonthc3_36 // n=785

*generating century month had 4th child in 1982
drop cmonthc4_36
gen cmonthc4_36 = (chay482r*12) + cham482r
summ cmonthc4_36
label var cmonthc4_36 "Century month [since 1900] had 4th child [age 36]"
fre cmonthc4_36 // n=180

*generating century month had 5th child in 1982
drop cmonthc5_36
gen cmonthc5_36 = (chay582r*12) + cham582r
summ cmonthc5_36
label var cmonthc5_36 "Century month [since 1900] had 5th child [age 36]"
fre cmonthc5_36 // n=39


**************************************
*Age in years study member had children [1982]
**************************************

*Age in years CM had 1st child in 1982
drop agec1_36
gen agec1_36 = (cmonthc1_36 - cm_age) / 12
replace agec1_36 = floor(agec1_36) // round to complete year 
label var agec1_36 "Age [in years] had 1st child [age 36]"
tab agec1_36 // n=2734 range: 15 - 36
tab agec1_36 if NSHDSURVEY_36 == 1 

*Age in years CM had 2nd child in 1982 
drop agec2_36
gen agec2_36 = (cmonthc2_36 - cm_age) / 12
replace agec2_36 = floor(agec2_36) // round to complete year 
label var agec2_36 "Age [in years] had 2nd child : [age 36]"
tab agec2_36 // n=2267 range: 18-36
tab agec2_36 if NSHDSURVEY_36 == 1 

*Age in years CM had 3rd child in 1982
drop agec3_36
gen agec3_36 = (cmonthc3_36 - cm_age) / 12
replace agec3_36 = floor(agec3_36) // round to complete year 
label var agec3_36 "Age [in years] had 3rd child: [age 36]"
tab agec3_36 // n=785 range: 19 - 36
tab agec3_36 if NSHDSURVEY_36 == 1 

*Age in years CM had 4th child in 1982
drop agec4_36
gen agec4_36 = (cmonthc4_36 - cm_age) / 12
replace agec4_36 = floor(agec4_36) // round to complete year 
label var agec4_36 "Age [in years] had 4th child: [age 36]"
tab agec4_36 // n=180 range: 21 - 36
tab agec4_36 if NSHDSURVEY_36 == 1 

*Age in years CM had 5th child in 1982
drop agec5_36
gen agec5_36 = (cmonthc5_36 - cm_age) / 12
replace agec5_36 = floor(agec5_36) // round to complete year 
label var agec5_36 "Age [in years] had 5th child: [age 36]"
tab agec5_36 // n=39 range: 23 - 36
tab agec5_36 if NSHDSURVEY_36 == 1 

summ agec1_26 agec2_26 agec3_26 agec4_26 agec1_31 agec2_31 agec1_36 agec3_36 agec4_36 agec5_36

egen cmageybirth_youngest_36 = rowmax(agec1_26 agec2_26 agec3_26 agec4_26 agec1_31 agec2_31 agec1_36 agec2_36 agec3_36 agec4_36 agec5_36)
egen cmageybirth_eldest_36 = rowmin(agec1_26 agec2_26 agec3_26 agec4_26 agec1_31 agec2_31 agec1_36 agec2_36 agec3_36 agec4_36 agec5_36)
label variable cmageybirth_youngest_36 "Age in years of study member at birth of youngest child [age 36]"
label variable cmageybirth_eldest_36 "Age in years of study member at birth of oldest child [age 36]"
summ cmageybirth_youngest_26 cmageybirth_eldest_26 cmageybirth_youngest_31 cmageybirth_eldest_31 cmageybirth_youngest_36 cmageybirth_eldest_36 

replace cmageybirth_eldest_36 = -10 if NSHDSURVEY_36 == 1 & anybiochildren_36 == 0 // if no children at age 1
replace cmageybirth_eldest_36 = -100 if NSHDSURVEY_36 == 0 // if not interviewed at age 36
replace cmageybirth_eldest_36 = -99 if NSHDSURVEY_36 == 1 & anybiochildren_36 == -99 // if interviewed at age 36 but no info on children
replace cmageybirth_eldest_36 = -99 if NSHDSURVEY_36 == 1 & cmageybirth_eldest_36 == . 
label values cmageybirth_eldest_36 missage
tab cmageybirth_eldest_36
tab cmageybirth_eldest_36 NSHDSURVEY_36

replace cmageybirth_youngest_36 = -10 if NSHDSURVEY_36 == 1 & anybiochildren_36 == 0 // if no children at age 1
replace cmageybirth_youngest_36 = -100 if NSHDSURVEY_36 == 0 // if not interviewed at age 36
replace cmageybirth_youngest_36 = -99 if NSHDSURVEY_36 == 1 & anybiochildren_36 == -99 // if interviewed at age 36 but no info on children
replace cmageybirth_youngest_36 = -99 if NSHDSURVEY_36 == 1 & cmageybirth_youngest_36 == . 
label values cmageybirth_youngest_36 missage
tab cmageybirth_youngest_36
tab cmageybirth_youngest_36 NSHDSURVEY_36


*age of children in months [1982]

*generating century month of interview in 1982
recode inty82 (-9999/-9 = .), into(inty82r)
recode intm82 (-9999/-9 = .), into(intm82r)
drop cmonth_36
gen cmonth_36 = (inty82r*12) + intm82r
label var cmonth_36 "Century month [since 1900] of interview"
summ cmonth_36

*generating age of child in years [1982]
*1st child
drop agec1_36y
gen agec1_36y = (cmonth_36 - cmonthc1_36) / 12 // month of interview - month had 1st child 
replace agec1_36y = floor(agec1_36y) // round to complete year 
label var agec1_36y "Age [in years] of 1st child [age 36]"
tab agec1_36y // n=2734 range: 0 - 21
tab agec1_36y if NSHDSURVEY_36 == 1 

*2nd child
drop agec2_36y
gen agec2_36y = (cmonth_36 - cmonthc2_36) / 12 // month of interview - month had 2nd child 
replace agec2_36y = floor(agec2_36y)
label var agec2_36y "Age [in years] of 2nd child [age 36]"
tab agec2_36y // n=2734 range: 0 - 21
tab agec2_36y if NSHDSURVEY_36 == 1 

*3rd child
drop agec3_36y
gen agec3_36y = (cmonth_36 - cmonthc3_36) / 12
replace agec3_36y = floor(agec3_36y) // round to complete year 
label var agec3_36y "Age [in years] of 3rd child [age 36]"
tab agec3_36y // n=785 range: -1 (n=3) - 16
tab agec3_36y if NSHDSURVEY_36 == 1 
*3 cm's had child in month after their interview date - recoded to zero
recode agec3_36y (-1 = 0)

*4th child
drop agec4_36y
gen agec4_36y = (cmonth_36 - cmonthc4_36) / 12  // month of interview - month had 4th child
replace agec4_36y = floor(agec4_36y) // round to complete year 
label var agec4_36y "Age [in years] of 4th child [age 36]"
tab agec4_36y // n=180 range: 0 - 14
tab agec4_36y if NSHDSURVEY_36 == 1 

*5th child
drop agec5_36y
gen agec5_36y = (cmonth_36 - cmonthc5_36) / 12 // month of interview - month had 5th child
replace agec5_36y = floor(agec5_36y) // round to complete year 
label var agec5_36y " Age [in years] of 5th child [age 36]"
tab agec5_36y // n=39 range: 0 - 12
tab agec5_36y if NSHDSURVEY_36 == 1 

summ agec1_26y agec2_26y agec3_26y agec4_26y agec1_31y agec2_31y agec1_36y agec2_36y agec3_36y agec4_36y agec5_36y

drop biochildy_eldest_36 biochildy_youngest_36
egen biochildy_eldest_36 = rowmax(agec1_26y agec2_26y agec3_26y agec4_26y agec1_31y agec2_31y agec1_36y agec2_36y agec3_36y agec4_36y agec5_36y)
egen biochildy_youngest_36 = rowmin(agec1_26y agec2_26y agec3_26y agec4_26y agec1_31y agec2_31y agec1_36y agec2_36y agec3_36y agec4_36y agec5_36y)
label variable biochildy_eldest_36 "Age in years of eldest biological child [Age 36]"
label variable biochildy_youngest_36 "Age in years of youngest biological child [Age 36]"
summ biochildy_youngest_31 biochildy_eldest_31 biochildy_youngest_36 biochildy_eldest_36	  

tab biochildy_eldest_36
tab biochildy_eldest_36 if NSHDSURVEY_36 == 1

replace biochildy_youngest_36 = -10 if NSHDSURVEY_36 == 1 & anybiochildren_36 == 0 // if no children at age 1
replace biochildy_youngest_36 = -100 if NSHDSURVEY_36 == 0 // if not interviewed at age 36
replace biochildy_youngest_36 = -99 if NSHDSURVEY_36 == 1 & anybiochildren_36 == -99 // if interviewed at age 36 but no info on children
replace biochildy_youngest_36 = -99 if NSHDSURVEY_36 == 1 & biochildy_youngest_36 == . 
label values biochildy_youngest_36 missage
tab biochildy_youngest_36
tab biochildy_youngest_36 NSHDSURVEY_36

replace biochildy_eldest_36 = -10 if NSHDSURVEY_36 == 1 & anybiochildren_36 == 0 // if no children at age 1
replace biochildy_eldest_36 = -100 if NSHDSURVEY_36 == 0 // if not interviewed at age 36
replace biochildy_eldest_36 = -99 if NSHDSURVEY_36 == 1 & anybiochildren_36 == -99 // if interviewed at age 36 but no info on children
replace biochildy_eldest_36 = -99 if NSHDSURVEY_36 == 1 & biochildy_eldest_36 == . 
label values biochildy_eldest_36 missage
tab biochildy_eldest_36
tab biochildy_eldest_36 NSHDSURVEY_36

*sex of child in 1982  
tab1 chisnew1 chisnew2 chisnew3 chisnew4 chisnew5 

drop sexc1_36 sexc2_36 sexc3_36 sexc4_36 sexc5_36

recode chisnew1 (0 -9 = -100 "no participation in sweep") (9 = -99 "information not provided") (8 = 0 "no child") (1 = 1 "male") (2=2 "female"), gen(sexc1_36) 
recode chisnew2 (0 -9 = -100 "no participation in sweep") (9 = -99 "information not provided") (8 = 0 "no (further) child") (1 = 1 "male") (2=2 "female"), gen(sexc2_36) 
recode chisnew3 (0 -9 = -100 "no participation in sweep") (9 = -99 "information not provided") (8 = 0 "no (further) child") (1 = 1 "male") (2=2 "female"), gen(sexc3_36) 
recode chisnew4 (0 -9 = -100 "no participation in sweep") (9 = -99 "information not provided") (8 = 0 "no (further) child") (1 = 1 "male") (2=2 "female"), gen(sexc4_36) 
recode chisnew5 (0 -9 = -100 "no participation in sweep") (9 = -99 "information not provided") (8 = 0 "no (further) child") (1 = 1 "male") (2=2 "female"), gen(sexc5_36) 


label var sexc1_36 "Sex of 1st child [age 36]"
label var sexc2_36 "Sex of 2nd child [age 36]"
label var sexc3_36 "Sex of 3rd child [age 36]"
label var sexc4_36 "Sex of 4th child [age 36]"
label var sexc5_36 "Sex of 5th child [age 36]"

tab1 sexc1_36 sexc2_36 sexc3_36 sexc4_36 sexc5_36

*Number of children who are boys 
drop biochildboy_total_36
egen biochildboy_total_36 = anycount(sexc1_36 sexc2_36 sexc3_36 sexc4_36 sexc5_36), values(1)
replace biochildboy_total_36 = -100 if sexc1_36 == -100
replace biochildboy_total_36 = -99 if sexc1_36 == -99
replace biochildboy_total_36 = -10 if sexc1_36 == 0

label variable biochildboy_total_36 "Number of bio children who are boys [Age 36]"
label values biochildboy_total_36 biosexb
tab biochildboy_total_36
tab biochildboy_total_36 NSHDSURVEY_36 

*Number of children who are girls 
drop biochildgirl_total_36
egen biochildgirl_total_36 = anycount(sexc1_36 sexc2_36 sexc3_36 sexc4_36 sexc5_36), values(2)
replace biochildgirl_total_36 = -100 if sexc1_36 == -100
replace biochildgirl_total_36 = -99 if sexc1_36 == -99
label variable biochildgirl_total_36 "Number of bio children who are girls [Age 36]"
label values biochildgirl_total_36 biosexg
tab biochildgirl_total_36
tab biochildgirl_total_36 NSHDSURVEY_36 

*flag to denote mismatched info in anybiochildren_36 biochildgirl_total_36
tab biochildgirl_total_36 anybiochildren_36
drop cgflag_36
gen cgflag_36 = 1 if (anybiochildren_36 == 0 & (biochildgirl_total_36 == -99 | biochildgirl_total_36 == 1)) | (anybiochildren_36 == -99 & biochildgirl_total_36 == 0)
label variable cgflag_36 "mismatched info in anybiochildren_36 & biochildgirl_total_36"
tab cgflag_36

tab biochildboy_total_36 anybiochildren_36
drop cbflag_36
gen cbflag_36 = 1 if (anybiochildren_36 == 0 & (biochildboy_total_36 == -99 | biochildboy_total_36 == 1)) | (anybiochildren_36 == -99 & biochildboy_total_36 == 0)
label variable cbflag_36 "mismatched info in anybiochildren_36 & biochildboy_total_36"
tab cbflag_36


*number of biological and non-biological children in the household - using household grid information 
label define chh -100 "no participation in sweep" -99 "information not provided" 0 "none" 
drop childrenhh_tot_36
egen childrenhh_tot_36 = anycount(rel182 rel282 rel382 rel482 rel582 rel682 rel782 rel882 rel982), values(4)
replace childrenhh_tot_36 = -100 if rel182 == -9999 | rel182 == -9
label variable childrenhh_tot_36 "Children in HH - household grid - bio + non-bio [age 36]"
label values childrenhh_tot_36 chh
tab childrenhh_tot_36
tab biochild_tot_36
tab childrenhh_tot_36 biochild_tot_36

*current marital status
tab marj82
tab marj82 NSHDSURVEY_36, nol

drop marital_36
recode marj82 (-9999 -9  = -100 "no participation in sweep") (2 = 1 "married") ( 1 6 7  = 2 "single cohabiting") ( 0 3 4 5 = 3 "single not cohabiting"), gen(marital_36)
label variable marital_36 "Marital Status [age 36]"
tab marital_36
tab marital_36 NSHDSURVEY_36


recode marj82 (-9999 -9 = -100 "no participation in sweep") (0 3 4 5 = 0 "no") (1 2 6 7 = 1 "yes"), gen(partner_36)
label variable partner_36 "Whether has a partner in HH"
tab marj82 partner_36 

label define phh -100 "no participation in sweep" 0 "no" 1 "yes"
drop partner_36b
egen partner_36b = anycount(rel182 rel282 rel382 rel482 rel582 rel682 rel782 rel882 rel982), values(1, 2)
replace partner_36b = -100 if rel182 == -9999 | rel182 == -9
label variable partner_36b "Partner in HH - household grid - [age 36]"
label values partner_36b phh
tab partner_36b
tab partner_36 partner_36b // exact same distribution so deop this one?

*Marital Status and Parent status
tab1 marstat82a child82

drop partnerchildbio_36
gen partnerchildbio_36 = -100
replace partnerchildbio_36 = 0 if partner_36 == 0 & anybiochildren_36 == 0	 
replace partnerchildbio_36 = 1 if partner_36 == 1 & anybiochildren_36 == 0
replace partnerchildbio_36 = 2 if partner_36 == 0 & anybiochildren_36 == 1	
replace partnerchildbio_36 = 3 if partner_36 == 1 & anybiochildren_36 == 1	 
replace partnerchildbio_36 = -99 if partner_36 == -99 | anybiochildren_36 == -99	 
label values partnerchildbio_36 marchild2
label variable partnerchildbio_36 "Whether has live with spouse/partner and/or any bio children [age 36]"
tab partnerchildbio_36 // n=3068 with info in both	 ; n=271 missing in marital or children vars || need to look further into this
tab partnerchildbio_36 NSHDSURVEY_36

	  
***********
*1989 [43]
***********
drop NSHDSURVEY_43
recode int43 (-9 0 2 3 4 25 = 0 "no participation in survey sweep") (1 = 1 "yes"), gen(NSHDSURVEY_43)
label variable NSHDSURVEY_43 "Whether took part in survey sweep (age 43)"
tab NSHDSURVEY_43

*year and month of interview
*these variable match existing derived variables in dataset: inty82 intm82

gen age43 = age89
replace age43 = . if age89 == -9
tab age43 // range from 514 [January 1989] - 533 [August 1990]

drop intyear_43
recode age43 (514 / 526 = 1989) (527 / 533 = 1990) , gen(intyear_43)
replace intyear_43 = -100 if NSHDSURVEY_43 == 0
replace intyear_43 = -99 if NSHDSURVEY_43 == 1 & intyear_43 == .
label variable intyear_43 "Interview year (age 43)"
label values intyear_43 missage
tab intyear_43

drop intmonth_43
recode age43 (514 526  = 1 "Jan") (515 527 = 2 "Feb") (516 528 = 3 "March") (517 529 = 4 "April") (518 530 = 5 "May") (519 531 = 6 "June") (520 532 = 7 "July") (521 533 = 8 "Aug") (522 = 9 "Sept") (523 = 10 "Oct") (524 = 11 "Nov") (525 = 12 "Dec")  , gen(intmonth_43)

replace intmonth_43 = -100 if NSHDSURVEY_43 == 0
replace intmonth_43 = -99 if NSHDSURVEY_43 == 1 & intmonth_43 == .
label variable intmonth_43 "Interview month (age 43)"
label values intmonth_43 month
tab intmonth_43



**Children 
tab chil89 
tab NSHDSURVEY_43 chil89 // ever had a child - if not asked in 1982
drop child43a
recode chil89 (-9 = -100 "no participation in sweep") (9 = -99 "information not provided") (8 = -98 "asked at age 36") (0=0 "no child") (1 = 1 "has a child"), gen(child43a)
label variable child43a "Ever had a child [if not asked in age 36 survey] [age 43]"

tab child43a // n=285 of which n=237 ever had a child

*had children SINCE 1982 - if provided info in 1982

tab chs89 // from questionnaire
drop child43b
recode chs89 (-9 = -100 "no participation in sweep") (8 = -99 "information not provided") (2 = 0 "no child") (1 = 1 "has a child"), gen(child43b)
label variable child43b "Had a child since age 36 [if asked in age 36 survey] [age 43]"
tab child43b NSHDSURVEY_43

drop anybiochildren_3643
gen anybiochildren_3643 = 0 if anybiochildren_36 == 0 | child43b == 0 // if anybiochildren_36 >= 0
replace anybiochildren_3643 = 1 if anybiochildren_36 == 1 | child43b == 1
replace anybiochildren_3643 = 0 if child43b == 0 & anybiochildren_3643 == .
tab anybiochildren_3643 child43b, m

*generating if has a child in 1989 using 1982 and 1989 information - for 1989 sample
drop anybiochildren_43
gen anybiochildren_43 = .
replace anybiochildren_43 = anybiochildren_3643 if anybiochildren_43 ==. & NSHDSURVEY_43 == 1 & anybiochildren_36 >= 0
replace anybiochildren_43 = child43a if anybiochildren_43 == . & child43a >= 0 // has a child or not if not asked in 1982  
*replace anybiochildren_43 = child43b if anybiochildren_43 ==. & child43b >= 0 // has a child since 1982 if asked in 1982 & 1989  
replace anybiochildren_43 = -100 if NSHDSURVEY_43 == 0
replace anybiochildren_43 = -99 if NSHDSURVEY_43 == 1 & anybiochildren_43 == .

label variable anybiochildren_43 "Has a biological child [age 43]"
label define anybiochildren_43lab  -100 "no participation in sweep" -99 "information not provided" 0 "no" 1 "yes", replace
label values anybiochildren_43 anybiochildren_43lab
tab anybiochildren_43 NSHDSURVEY_43


*number of children 

tab chiln89 // number of children if not asked in 1982
clonevar kid8289 = chiln89
recode kid8289 (-9 88 = .)
replace kid8289 = 0 if child43a == 0
tab kid8289 child43a // info for n=235 of n=237 with child in child43a

tab child43b //n323 had a child since 1982 [if asked in 1982]
egen newkid43 = anycount(chss189 chss289 chss389 chss489 chss589), values(1 2) // generating number of children since 1982 if asked in 1982 using child sex variables
tab newkid43 // info for all n=323 who had a child since 1982

tab biochild_tot_36 // number of children in 1982 

*number of children for those in 1982 and 1989
drop kid43
egen kid43 = rowtotal(biochild_tot_36 newkid43) if biochild_tot_36 >= 0 & newkid43 >= 0
tab1 biochild_tot_36 newkid43 kid43 // total number of children for those interviewed in 1982 and 1989

*combining information 
drop biochild_tot_43
gen biochild_tot_43 = kid43
replace biochild_tot_43 = kid8289 if biochild_tot_43 == .
replace biochild_tot_43 = -100 if NSHDSURVEY_43 == 0
replace biochild_tot_43 = -99 if NSHDSURVEY_43 == 1 & biochild_tot_43 == .

label define biochild_tot_43lab -100 "no participation in sweep" -99 "information not provided" 0 "no child"
label variable biochild_tot_43 "Number of biological children [age 43]"
label values biochild_tot_43 biochild_tot_43lab
tab biochild_tot_43 NSHDSURVEY_43


tab biochild_tot_43 anybiochildren_43 // discrepancies

list child43a child43b anybiochildren_36 kid8289 newkid43 kid43 if biochild_tot_43 == -2 & anybiochildren_43 == 1 // n=5 has a child but number not coded as down as having been asked in 1982 (value 88 in chiln89)
tab child43a chiln89 , m

list child43a child43b anybiochildren_36 kid8289 newkid43 kid43 biochild_tot_43 if biochild_tot_43 >= 1 & anybiochildren_43 == 0


*flag to note discrepancy between anybiochildren_43 and biochild_tot_43
tab biochild_tot_43 anybiochildren_43
drop cflag_43
gen cflag_43 = 1 if anybiochildren_43 == 0 & biochild_tot_43 >= 1
replace cflag_43 = 1 if anybiochildren_43 == 1 & biochild_tot_43 == 0
replace cflag_43 = 1 if anybiochildren_43 == 1 & biochild_tot_43 == -99


label variable cflag_43 "Mismatched information in anybiochildren_43 and biochild_tot_43 variables"
tab cflag_43 // n=16


*Flag to denote reporting a/some children at earlier sweep, no/fewer children at current sweep 	  

drop flagsamp
gen flagsamp = 1 if (biochild_tot_19 > -1 & biochild_tot_43 > -1) | (biochild_tot_20 > -1 & biochild_tot_43 > -1) | (biochild_tot_22 > -1 & biochild_tot_43 > -1) | (biochild_tot_26 > -1 & biochild_tot_43 > -1) | (biochild_tot_31 > -1 & biochild_tot_43 > -1) | (biochild_tot_36 > -1 & biochild_tot_43 > -1) 
tab flagsamp

drop cnflag_1943
gen cnflag_1943 = 1 if ((biochild_tot_19 > biochild_tot_43) & flagsamp ==1) | ((biochild_tot_20 > biochild_tot_43) & flagsamp ==1) | ((biochild_tot_22 > biochild_tot_43) & flagsamp ==1) | ((biochild_tot_26 > biochild_tot_43) & flagsamp ==1) | ((biochild_tot_31 > biochild_tot_43) & flagsamp ==1) |  ((biochild_tot_36 > biochild_tot_43) & flagsamp ==1)
label variable cnflag_1943 "Fewer children reported at age 43 than at age 19, 20, 22, 26, 31 or 36"
tab cnflag_1943 // n=34

list biochild_tot_19 biochild_tot_20 biochild_tot_22 biochild_tot_26 biochild_tot_31 biochild_tot_36 biochild_tot_43 if cnflag_1943 == 1 // output omitted 

*of the n=33, most discrepancies to do with age 31 - higher than at age 36 or 43


*child's year of birth
tab1 chay189 chay289 chay389 chay489 chay589 // if not already given info [at 1982 or before] // if info in 1982, n=7 have valid info [eg] in chay189]

local varlist chay189 chay289 chay389 chay489 chay589
foreach var in `varlist' {
	recode `var' (-9 98 99 = .), gen(`var'r)
	tab1 `var' `var'r
}

*child's month of birth
tab1 cham189 cham289 cham389 cham489 cham589   

local varlist cham189 cham289 cham389 cham489 cham589 
foreach var in `varlist' {
	recode `var' (-9 88 99 = .), gen(`var'r)
	tab1 `var' `var'r
}


*century month had 1st to 5th child: 1989 [if not reported earlier]

gen cmonthc1_43 = (chay189r*12) + cham189r
label var cmonthc1_43 "Century month [since 1900] had 1st child [not reported earlier] [Age 43]"
gen cmonthc2_43 = (chay289r*12) + cham289r
label var cmonthc2_43 "Century month [since 1900] had 2nd child [not reported earlier] [Age 43]"
gen cmonthc3_43 = (chay389r*12) + cham389r
label var cmonthc3_43 "Century month [since 1900] had 3rd child [not reported earlier] [Age 43]"
gen cmonthc4_43 = (chay489r*12) + cham489r
label var cmonthc4_43 "Century month [since 1900] had 4th child [not reported earlier] [Age 43]"
gen cmonthc5_43 = (chay589r*12) + cham589r
label var cmonthc5_43 "Century month [since 1900] had 5th child [not reported earlier] [Age 43]"
tab cmonthc5_43

*child's year of birth - children had after interview in 82  [in chys189 n=255 had a child since 1982, but n=2 in 1972 or 1981...]

tab1 chys189 chys289 chys389 chys489 chys589 

local varlist chys189 chys289 chys389 chys489 chys589 
foreach var in `varlist' {
	recode `var' (-9 98 99 = .), gen(`var'r)
	tab1 `var' `var'r
}

*child's month of birth - children had after interview in 82

tab1 chms189 chms289 chms389 chms489 chms589

local varlist chms189 chms289 chms389 chms489 chms589
foreach var in `varlist' {
	recode `var' (-9 88 99 = .), gen(`var'r)
	tab1 `var' `var'r
}

*century month had 1st to 5th child since 1982: 1989 [if reported earlier]
gen cmc1_43 = (chys189r*12) + chms189r
label var cmc1_43 "Century month [since 1900] had 1st child since 1982 [if reported earlier] [Age 43]"
gen cmc2_43 = (chys289r*12) + chms289r
label var cmc2_43 "Century month [since 1900] had 2nd child since 1982 [if reported earlier] [Age 43]"
gen cmc3_43 = (chys389r*12) + chms389r
label var cmc3_43 "Century month [since 1900] had 3rd child since 1982 [if reported earlier] [Age 43]"
gen cmc4_43 = (chys489r*12) + chms489r
label var cmc4_43 "Century month [since 1900] had 4th child since 1982 [if reported earlier] [Age 43]"
gen cmc5_43 = (chys589r*12) + chms589r
label var cmc5_43 "Century month [since 1900] had 5th child since 1982 [if reported earlier] [Age 43]"
tab cmc1_43


*Age in years CM had 1st child: 1989 [not reported earlier]
drop agec1_43
gen agec1_43 = (cmonthc1_43 - cm_age) / 12
replace agec1_43 = floor(agec1_43) // round to complete year 
label var agec1_43 "Age [in years] had 1st child [not reported earlier] [Age 43]"
tab agec1_43 // n=222 range: 16-42 
tab agec1_43 NSHDSURVEY_43 

*Age in years CM had 2nd child: 1989 [not reported earlier]
drop agec2_43
gen agec2_43 = (cmonthc2_43 - cm_age) / 12
replace agec2_43 = floor(agec2_43) // round to complete year 
label var agec2_43 "Age [in years] had 2nd child [not reported earlier] [Age 43]"
tab agec2_43 // n=190 range: 19-43
tab agec2_43 NSHDSURVEY_43 

*Age in years CM had 3rd child: 1989 [not reported earlier]
drop agec3_43
gen agec3_43 = (cmonthc3_43 - cm_age) / 12
replace agec3_43 = floor(agec3_43) // round to complete year 
label var agec3_43 "Age [in years] had 3rd child [not reported earlier] [Age 43]"
tab agec3_43 // n=82 range: 20-43
tab agec3_43 NSHDSURVEY_43 

*Age in years CM had 4th child: 1989 [not reported earlier]
drop agec4_43
gen agec4_43 = (cmonthc4_43 - cm_age) / 12
replace agec4_43 = floor(agec4_43) // round to complete year 
label var agec4_43 "Age [in years] had 4th child [not reported earlier] [Age 43]"
tab agec4_43 // n=20 range: 21-42
tab agec4_43 NSHDSURVEY_43 

*Age in years CM had 5th child: 1989 [not reported earlier]
drop agec5_43
gen agec5_43 = (cmonthc5_43 - cm_age) / 12
replace agec5_43 = floor(agec5_43) // round to complete year 
label var agec5_43 "Age [in years] had 5th child [not reported earlier] [Age 43]"
tab agec5_43 // n=6 range: 25-42
tab agec5_43 NSHDSURVEY_43 


***********************************************************************
*Age in years CM had 1st child since 1982: 1989 [if reported earlier]
***********************************************************************
drop agec1_43b
gen agec1_43b = (cmc1_43 - cm_age) / 12
replace agec1_43b = floor(agec1_43b) // round to complete year 
label var agec1_43b "Age [in years] had 1st child since 1982 [if reported earlier] [Age 43]"
tab agec1_43b // n=320 range 26-43
tab agec1_43b NSHDSURVEY_43 

*Age in years CM had 2nd child: 1989
drop agec2_43b
gen agec2_43b = (cmc2_43 - cm_age) / 12
replace agec2_43b = floor(agec2_43b) // round to complete year 
label var agec2_43b "Age [in years] had 2nd child since 1982 [if reported earlier] [Age 43]"
tab agec2_43b // n=72 range: 28-43
tab agec2_43b NSHDSURVEY_43 

*Age in years CM had 3rd child: 1989
drop agec3_43b
gen agec3_43b = (cmc3_43 - cm_age) / 12
replace agec3_43b = floor(agec3_43b) // round to complete year 
label var agec3_43b "Age [in years] had 3rd child since 1982 [if reported earlier] [Age 43]"
tab agec3_43b // n=11 range: 40-42
tab agec3_43b NSHDSURVEY_43 

*Age in years CM had 4th child: 1989
drop agec4_43b
gen agec4_43b = (cmc4_43 - cm_age) / 12
replace agec4_43b = floor(agec4_43b) // round to complete year 
label var agec4_43b "Age [in years] had 4th child since 1982 [if reported earlier] [Age 43]"
tab agec4_43b // n=1 range: 41
tab agec4_43b NSHDSURVEY_43 

*NO FIFTH CHILD


drop cmageybirth_youngest_43 cmageybirth_eldest_43
egen cmageybirth_youngest_43 = rowmax(agec1_26 agec2_26 agec3_26 agec4_26 agec1_31 agec2_31 agec1_36 agec2_36 agec3_36 agec4_36 agec5_36 agec1_43 agec2_43 agec3_43 agec4_43 agec5_43 agec1_43b agec2_43b agec3_43b agec4_43b)
egen cmageybirth_eldest_43 = rowmin(agec1_26 agec2_26 agec3_26 agec4_26 agec1_31 agec2_31 agec1_36 agec2_36 agec3_36 agec4_36 agec5_36 agec1_43 agec2_43 agec3_43 agec4_43 agec5_43 agec1_43b agec2_43b agec3_43b agec4_43b)
label variable cmageybirth_youngest_43 "Age in years of study member at birth of youngest child [age 43]"
label variable cmageybirth_eldest_43 "Age in years of study member at birth of oldest child [age 43]"
summ cmageybirth_youngest_26 cmageybirth_youngest_31 cmageybirth_youngest_36 cmageybirth_youngest_43
summ cmageybirth_eldest_26 cmageybirth_eldest_31 cmageybirth_eldest_36 cmageybirth_eldest_43

tab cmageybirth_eldest_43
tab cmageybirth_eldest_43 NSHDSURVEY_43


tab cmageybirth_eldest_43
replace cmageybirth_eldest_43 = -10 if NSHDSURVEY_43 == 1 & anybiochildren_43 == 0 // if no children at age 43
replace cmageybirth_eldest_43 = -100 if NSHDSURVEY_43 == 0 // if not interviewed at age 43
replace cmageybirth_eldest_43 = -99 if NSHDSURVEY_43 == 1 & anybiochildren_43 == -99 // if interviewed at age 43 but no info on children
replace cmageybirth_eldest_43 = -99 if NSHDSURVEY_43 == 1 & cmageybirth_eldest_43 == . 
label values cmageybirth_eldest_43 missage
tab cmageybirth_eldest_43
tab cmageybirth_eldest_43 NSHDSURVEY_43


tab cmageybirth_youngest_43
replace cmageybirth_youngest_43 = -10 if NSHDSURVEY_43 == 1 & anybiochildren_43 == 0 // if no children at age 43
replace cmageybirth_youngest_43 = -100 if NSHDSURVEY_43 == 0 // if not interviewed at age 43
replace cmageybirth_youngest_43 = -99 if NSHDSURVEY_43 == 1 & anybiochildren_43 == -2 // if interviewed at age 43 but no info on children
replace cmageybirth_youngest_43 = -99 if NSHDSURVEY_43 == 1 & cmageybirth_youngest_43 == . 
label values cmageybirth_youngest_43 missage
tab cmageybirth_youngest_43
tab cmageybirth_youngest_43 NSHDSURVEY_43


***********************
*Age of children: 1989
***********************

*century month of interview: CM century month born in 555 + age in months when interviewed 
gen age89r = age89
recode age89r -9 = .
gen  ageint_43 = cm_age + age89r
label var ageint_43 "Century month interviewed [age 43]"
summ ageint_43

*generating age of children in months and years [1989]

*1st child
drop agec1_43y
gen agec1_43y =(ageint_43 - cmonthc1_43) / 12 // month of interview - month had 1st child
replace agec1_43y = floor(agec1_43y) // round to complete year 
label var agec1_43y "Age [in years] of 1st child [not reported earlier] [age 43]"
fre agec1_43y // n=222 range: 27 - 326 

*2nd child
drop agec2_43y
gen agec2_43y = (ageint_43 - cmonthc2_43) / 12 // month of interview - month had 2nd child
replace agec2_43y = floor(agec2_43y) // round to complete year 
label var agec2_43y "Age [in years] of 2nd child [not reported earlier] [age 43]"
fre agec2_43y // n=190 range: 13 - 296

*3rd child
drop agec3_43y
gen agec3_43y = (ageint_43 - cmonthc3_43) / 12 // month of interview - month had 3rd child
replace agec3_43y = floor(agec3_43y) // round to complete year 
label var agec3_43y "Age [in years] of 3rd child [not reported earlier] [age 43]"
fre agec3_43y // n=82 range: 5 - 279

*4th child
drop agec4_43y
gen agec4_43y = (ageint_43 - cmonthc4_43) / 12 // month of interview - month had 4th child
replace agec4_43y = floor(agec4_43y) // round to complete year 
label var agec4_43y "Age [in months] of 4th child [not reported earlier] [age 43]"
fre agec4_43y // n=20 range: 7 - 265

*5th child
drop agec5_43y
gen agec5_43y = (ageint_43 - cmonthc5_43) / 12 // month of interview - month had 5th child
replace agec5_43y = floor(agec5_43y) // round to complete year 
label var agec5_43y "Age [in years] of 5th child [not reported earlier] [age 43]"
fre agec5_43y // n=6 range: 1 - 17

*as above but for children had after last interview [1982]
*1st child
drop agec1_43yb
gen agec1_43yb = (ageint_43 - cmc1_43) / 12 // month of interview - month had 1st child
replace agec1_43yb = floor(agec1_43yb) // round to complete year 
label var agec1_43yb "Age [in years] of 1st child since 1982 [if reported earlier] [age 43]"
fre agec1_43yb // n=320 range: 0-16


*2nd child
drop agec2_43yb
gen agec2_43yb = (ageint_43 - cmc2_43) / 12 // month of interview - month had 2nd child
replace agec2_43yb = floor(agec2_43yb) // round to complete year 
label var agec2_43yb "Age [in years] of 2nd child since 1982 [if reported earlier] [age 43]"
fre agec2_43yb // n=72 range: 0 - 15

*3rd child
drop agec3_43yb
gen agec3_43yb = (ageint_43 - cmc3_43) / 12 // month of interview - month had 3rd child
replace agec3_43yb = floor(agec3_43yb) // round to complete year 
label var agec3_43yb "Age [in years] of 3rd child since 1982 [if reported earlier] [age 43]"
fre agec3_43yb // n=11 range: 0 - 2

*4th child
drop agec4_43yb
gen agec4_43yb = (ageint_43 - cmc4_43) / 12 // month of interview - month had 4th child
replace agec4_43yb = floor(agec4_43yb) // round to complete year 
label var agec4_43yb "Age [in years] of 4th child since 1982 [if reported earlier] [age 43]"
fre agec4_43yb // n=1 range: 1

* NO FIFTH CHILD

*Age of Eldest / Youngest child
drop biochildy_eldest_43 biochildy_youngest_43
egen biochildy_eldest_43 = rowmax(agec1_26y agec2_26y agec3_26y agec4_26y agec1_31y agec2_31y agec1_36y agec2_36y agec3_36y agec4_36y agec5_36y agec1_43y agec2_43y agec3_43y agec4_43y agec5_43y agec1_43yb agec2_43yb agec3_43yb agec4_43yb)
egen biochildy_youngest_43 = rowmin(agec1_26y agec2_26y agec3_26y agec4_26y agec1_31y agec2_31y agec1_36y agec2_36y agec3_36y agec4_36y agec5_36y agec1_43y agec2_43y agec3_43y agec4_43y agec5_43y agec1_43yb agec2_43yb agec3_43yb agec4_43yb)
label variable biochildy_eldest_43 "Age in years of eldest biological child [Age 43]"
label variable biochildy_youngest_43 "Age in years of youngest biological child [Age 43]"
summ biochildy_youngest_31 biochildy_youngest_36 biochildy_youngest_43 
summ biochildy_eldest_31 biochildy_eldest_36 biochildy_eldest_43 


replace biochildy_eldest_43 = -10 if NSHDSURVEY_43 == 1 & anybiochildren_43 == 0 // if no children at age 43
replace biochildy_eldest_43 = -100 if NSHDSURVEY_43 == 0 // if not interviewed at age 43
replace biochildy_eldest_43 = -99 if NSHDSURVEY_43 == 1 & anybiochildren_43 == -99 // if interviewed at age 436 but no info on children
replace biochildy_eldest_43 = -99 if NSHDSURVEY_43 == 1 & biochildy_eldest_43 == . 
label values biochildy_eldest_43 missage
tab biochildy_eldest_43
tab biochildy_eldest_43 NSHDSURVEY_43


replace biochildy_youngest_43 = -10 if NSHDSURVEY_43 == 1 & anybiochildren_43 == 0 // if no children at age 43
replace biochildy_youngest_43 = -100 if NSHDSURVEY_43 == 0 // if not interviewed at age 43
replace biochildy_youngest_43 = -99 if NSHDSURVEY_43 == 1 & anybiochildren_43 == -99 // if interviewed at age 436 but no info on children
replace biochildy_youngest_43 = -99 if NSHDSURVEY_43 == 1 & biochildy_youngest_43 == . 
label values biochildy_youngest_43 missage
tab biochildy_youngest_43
tab biochildy_youngest_43 NSHDSURVEY_43


*sex of child

tab1 chis189 chis289 chis389 chis489 chis589 

tab1 chss189 chss289 chss389 chss489 chss589 


recode chis189 (-9 8 = -100 "no participation in sweep") (9 = -99 "information not provided") (1 = 1 "male") (2=2 "female"), gen(sexc1_43) 
recode chis289 (-9 8 = -100 "not asked/interviewed") (9 = -99 "no info") (1 = 1 "male") (2=2 "female"), gen(sexc2_43) 
recode chis389 (-9 8 = -100 "not asked/interviewed") (9 = -99 "no info") (1 = 1 "male") (2=2 "female"), gen(sexc3_43) 
recode chis489 (-9 8 = -100 "not asked/interviewed") (9 = -99 "no info") (1 = 1 "male") (2=2 "female"), gen(sexc4_43) 
recode chis589 (-9 8 = -100 "not asked/interviewed") (9 = -99 "no info") (1 = 1 "male") (2=2 "female"), gen(sexc5_43) 


label var sexc1_43 "Sex of 1st child [not reported earlier] (Age 43)"
label var sexc2_43 "Sex of 2nd child [not reported earlier] (Age 43)"
label var sexc3_43 "Sex of 3rd child [not reported earlier] (Age 43)"
label var sexc4_43 "Sex of 4th child [not reported earlier] (Age 43)"
label var sexc5_43 "Sex of 5th child [not reported earlier] (Age 43)"

recode chss189 (-9 8 = -100 "no participation in sweep") (9 = -99 "information not provided")  (1 = 1 "male") (2=2 "female"), gen(sexc1_43b) 
recode chss289 (-9 8 = -100 "no participation in sweep") (9 = -99 "information not provided") (1 = 1 "male") (2=2 "female"), gen(sexc2_43b) 
recode chss389 (-9 8 = -100 "no participation in sweep") (9 = -99 "information not provided") (1 = 1 "male") (2=2 "female"), gen(sexc3_43b) 
recode chss489 (-9 8 = -100 "no participation in sweep") (9 = -99 "information not provided") (1 = 1 "male") (2=2 "female"), gen(sexc4_43b) 

label var sexc1_43b "Sex of 1st child since 1982 [if reported earlier] (Age 43)"
label var sexc2_43b "Sex of 2nd child since 1982 [if reported earlier] (Age 43)"
label var sexc3_43b "Sex of 3rd child since 1982 [if reported earlier] (Age 43)"
label var sexc4_43b "Sex of 4th child since 1982 [if reported earlier] (Age 43)"


*total number of biological children who are boys: not mentioned in survey before
drop biochildboy_total_43a
egen biochildboy_total_43a = anycount(sexc1_43 sexc2_43 sexc3_43 sexc4_43 sexc5_43), values(1)
label variable biochildboy_total_43a "Number of bio children who are boys [Age 43]" // children not mentioned before 
tab biochildboy_total_43a
tab biochildboy_total_43a if NSHDSURVEY_43 == 1

drop biochildboy_total_43b
egen biochildboy_total_43b = anycount(sexc1_36 sexc2_36 sexc3_36 sexc4_36 sexc5_36 sexc1_43b sexc2_43b sexc3_43b sexc4_43b), values(1)  //  children before and had since 1982
label variable biochildboy_total_43b "Number of bio children who are boys [Age 36 and 43]" 
tab biochildboy_total_43b
tab biochildboy_total_43b if NSHDSURVEY_43 == 1

tab biochildboy_total_43a biochildboy_total_43b, m

*discrepancy: mentioned / not mentioned before
gen bflag_43 = 1 if biochildboy_total_43a >= 1 & biochildboy_total_43b >= 1
label variable bflag_43 "boy children reported in both biochildboy_total_43a and biochildboy_total_43b" 
tab bflag_43

*total number of biological children who are boys
drop biochildboy_total_43
egen biochildboy_total_43 = rowtotal(biochildboy_total_43a biochildboy_total_43b) // not mentioned before
replace biochildboy_total_43 = -100 if NSHDSURVEY_43 == 0
replace biochildboy_total_43 = -99 if NSHDSURVEY_43 == 1 & (sexc1_43 == -99 | sexc1_43b == -99)
replace biochildboy_total_43 = -10 if anybiochildren_43 == 0
label variable biochildboy_total_43 "Number of bio children who are boys [Age 36 and 43]" // children before and had since 1982
label values biochildboy_total_43 biosexb
tab biochildboy_total_43
tab biochildboy_total_43 NSHDSURVEY_43


*total number of biological children who are girls: not mentioned in survey before
drop biochildgirl_total_43a
egen biochildgirl_total_43a = anycount(sexc1_43 sexc2_43 sexc3_43 sexc4_43 sexc5_43), values(2)
label variable biochildgirl_total_43a "Number of bio children who are girls [Age 43]" // children not mentioned before 
tab biochildgirl_total_43a
tab biochildgirl_total_43a NSHDSURVEY_43


drop biochildgirl_total_43b
egen biochildgirl_total_43b = anycount(sexc1_36 sexc2_36 sexc3_36 sexc4_36 sexc5_36 sexc1_43b sexc2_43b sexc3_43b sexc4_43b), values(2)  //  children before and had since 1982
label variable biochildgirl_total_43b "Number of bio children who are girls [Age 36 and 43]" 
tab biochildgirl_total_43b
tab biochildgirl_total_43b NSHDSURVEY_43

tab biochildgirl_total_43a biochildgirl_total_43b, m

*discrepancy: mentioned / not mentioned before
gen gflag_43 = 1 if biochildgirl_total_43a >= 1 & biochildgirl_total_43b >= 1
label variable gflag_43 "girl children reported in both biochildgirl_total_43a and biochildgirl_total_43b" 
tab gflag_43

*total number of biological children who are boys
drop biochildgirl_total_43
egen biochildgirl_total_43 = rowtotal(biochildgirl_total_43a biochildgirl_total_43b)
replace biochildgirl_total_43 = -100 if NSHDSURVEY_43 == 0
replace biochildgirl_total_43 = -99 if NSHDSURVEY_43 == 1 & (sexc1_43 == -99 | sexc1_43b == -99)
replace biochildgirl_total_43 = -10 if anybiochildren_43 == 0
label variable biochildgirl_total_43 "Number of bio children who are girls [Age 36 and 43]" // children before and had since 1982
label values biochildgirl_total_43 biosexg
tab biochildgirl_total_43
tab biochildgirl_total_43 NSHDSURVEY_43 

*flag for mismatch information in anybiochildren_43 and child sex variables - biochildgirl_total_43 biochildboy_total_43

drop cgflag_43
gen cgflag_43 = 1 if (anybiochildren_43 == 0 & biochildgirl_total_43 == 1) | (anybiochildren_43 == -99 & (biochildgirl_total_43 == 0 | biochildgirl_total_43 == 1))
label variable cgflag_43 "mismatched info in anybiochildren_43 & biochildgirl_total_43"
tab cgflag_43

drop cbflag_43
gen cbflag_43 = 1 if (anybiochildren_43 == 0 & biochildboy_total_43 == 1) | (anybiochildren_43 == -99 & (biochildboy_total_43 == 0 | biochildboy_total_43 == 2))
label variable cbflag_43 "mismatched info in anybiochildren_43 & biochildboy_total_43"
tab cbflag_43


*one cm in both 1st sex of child variables 
tab sexc1_43 sexc1_43b, nol
list nshdid_ntag  if sexc1_43 == 2 & sexc1_43b ==1 // one cm in both 1st sex of child variables 


*children in household

label define chh43 -100 "no participation in sweep" -99 "information not provided"  0 "none" , replace
drop childrenhh_tot_43
egen childrenhh_tot_43 = anycount(rel289 rel389 rel489 rel589 rel689 rel789 rel889), values(4) // this code assumes code 8 = alone -
replace childrenhh_tot_43 = -100 if rel289 == -9 | NSHDSURVEY_43 == 0
replace childrenhh_tot_43 = -99 if rel289 == 9
label variable childrenhh_tot_43 "Children in HH - household grid - bio + non-bio [age 43]"
label values childrenhh_tot_43 chh43
tab childrenhh_tot_43
tab biochild_tot_43
tab childrenhh_tot_43 biochild_tot_43


*Marital status age 43

clonevar marj89a = marj89
replace marj89a = -100 if NSHDSURVEY_43 == 0  // replacing those not interviewed with -100
tab marj89a rel189a // bit of mismatch - used household grid information 

drop marital_43
gen marital_43 = -100
replace marital_43 = 1 if rel189a == 1
replace marital_43 = 2 if rel189a == 2
replace marital_43 = 3 if rel189a == 8
replace marital_43 = -99 if rel189a == . & NSHDSURVEY_43 == 1
label define marital_43lab -100 "no participation in sweep" -99 "information not provided" 1 "married" 2 "single cohabiting" 3 "single not cohabiting", replace
label variable marital_43 "Marital Status [age 43]"
label values marital_43 marital_43lab
tab marital_43
*partner in household

drop partner_43
recode marital_43 (-100 = -100 "no participation in sweep") (-99 = -99 "information not provided") (3 = 0 "no") (1 2 = 1 "yes"), gen(partner_43)
label variable partner_43 "Partner in HH (age 43)"
tab partner_43

*Partner and child status
drop partnerchildbio_43
gen partnerchildbio_43 = -100 if NSHDSURVEY_43 == 0
replace partnerchildbio_43 = 0 if partner_43 ==  0 & anybiochildren_43 == 0
replace partnerchildbio_43 = 1 if partner_43 ==  1 & anybiochildren_43 == 0
replace partnerchildbio_43 = 2 if partner_43 ==  0 & anybiochildren_43 == 1
replace partnerchildbio_43 = 3 if partner_43 ==  1 & anybiochildren_43 == 1	 
replace partnerchildbio_43 = -99 if partner_43 == -99 | anybiochildren_43 == -99	

label values partnerchildbio_43 marchild2
label variable partnerchildbio_43 "Whether has live in spouse/partner and/or any bio children [age 43]"
tab partnerchildbio_43 // n=3253 with info in both
tab partnerchildbio_43 NSHDSURVEY_43


**************
*1999 [age 53]
**************

drop NSHDSURVEY_53
recode int53 (-9 0 2 3 4 25 35 = 0 "no participation in survey sweep") (1 = 1 "yes"), gen(NSHDSURVEY_53)
label variable NSHDSURVEY_53 "Whether took part in survey sweep (age 53)"
tab NSHDSURVEY_53

*year and month of interview

tab age99 // range from 636 [March 1999] - 650 [May 2000]


drop intyear_53
recode age99 (636 / 645 = 1999) (646 / 650 = 2000) (-9 = .), gen(intyear_53)
replace intyear_53 = -100 if NSHDSURVEY_53 == 0
replace intyear_53 = -99 if NSHDSURVEY_53 == 1 & intyear_53 == .
label variable intyear_53 "Interview year (age 53)"
label values intyear_53 missage
tab age99 intyear_53
tab intyear_53

drop intmonth_53
recode age99 (646  = 1 ) (647 = 2 ) (636 648 = 3 ) (637 649 = 4 ) (638 650 = 5 ) (639 = 6 ) (640 = 7 ) (641 = 8) (642 = 9 ) (643 = 10 ) (644 = 11 ) (645 = 12 ) (-1 = -100 ) (-2 = -99 ) , gen(intmonth_53)
replace intmonth_53 = -100 if NSHDSURVEY_53 == 0
replace intmonth_53 = -99 if NSHDSURVEY_53 == 1 & intmonth_53 == .
label variable intmonth_53 "Interview month (age 53)"
label values intmonth_53 month
tab intmonth_53

**Number of Children 

*questionnaire variables CHIL CHILN_v2
tab chil NSHDSURVEY_53, m  // n=519 valid info - ever had a child or not - with n=88 had a child 
tab chiln_v2 NSHDSURVEY_53, m // this derived variable for 'ever children' has no information for n=486 interviewed at age 53
tab newkid99 NSHDSURVEY_53, m // this derived variable for 'new children' has no information for n=481 interviewed at age 53 [39 = 1 ; 18 = 2 ; 5 = 3 new children reported at age 53]

*making new total number of children variable based on age 43 variable and 'newkid99' - sublementing with age 36 information 
tab biochild_tot_43r NSHDSURVEY_53, m // however, n=203 not interviewed at age 43

clonevar newkid99r = newkid99
replace newkid99r = . if newkid99r == -2 | newkid99r == 99 | newkid99r == -9
tab newkid99r

clonevar biochild_tot_43r = biochild_tot_43
replace biochild_tot_43r = . if biochild_tot_43 < 0
tab biochild_tot_43r

tab biochild_tot_43r chiln_v2 if NSHDSURVEY_53 == 1, m
tab biochild_tot_43r newkid99r if NSHDSURVEY_53 == 1, m

clonevar biochild_tot_36r = biochild_tot_36
replace biochild_tot_36r = . if biochild_tot_36 < 0
tab biochild_tot_36r

egen temp3653 = rowtotal(biochild_tot_36 newkid99r) if biochild_tot_36 >=0 & NSHDSURVEY_53 == 1
tab  temp3653

drop biochild_tot_53
egen biochild_tot_53 = rowtotal(biochild_tot_43r newkid99r) //children at age 43 + new children at age 53
replace biochild_tot_53 = temp3653 if biochild_tot_43r == . & biochild_tot_53 == 0 & NSHDSURVEY_53 == 1 // replace with children at age 36 + new children at age 53 if  missing at age 43 and coded as 0 and in age 53 survey
replace biochild_tot_53 = -100 if NSHDSURVEY_53 == 0
replace biochild_tot_53 = -99 if NSHDSURVEY_53 == 1 & (biochild_tot_43r == . & biochild_tot_36r == . & newkid99r == .)

*Of the 3,034 interviewed at age 53, we have information for 2,973 so missing for n=61. These were not interviewed/gave no information at age 36 or 43  but are coded as 0 in newkid99.  
replace biochild_tot_53 = 0 if biochild_tot_53 == . & NSHDSURVEY_53 == 1 & newkid99r == 0

label variable biochild_tot_53 "Number of biological children [age 53]"
label values biochild_tot_53 biochild_tot_43lab
tab biochild_tot_53 // no info for n=31 who were interviewed
label define anybiochildren_43lab  -100 "no participation in sweep" -99 "information not provided" 0 "no" 1 "yes" label values biochild_tot_43 biochild_tot_43lab
*any children 
recode biochild_tot_53 (-100 = -100 "no participation in sweep") (-99 = -99 "information not provided") (0 = 0 "no") (1/9 = 1 "yes"), gen(anybiochildren_53)
label variable anybiochildren_53 "Has a biological child [age 53]"
tab anybiochildren_53

/*
*Sex or Year had child information for n=203 or n=205
*Very unsure how we get to these numbers..... only n=62 new children reported [newkid99]
*Sex of child
tab1 chss chss2 chss3 chss4 chss5

*year had child - but no month. cannot calculate age of child or age had child without month information.
tab1 chds chds2 chds3 chds4 chds5

tab chds chss
*/

*Existing derived variables for age had 1st to 9th child - use these to update age had eldest / youngest child
tab1 akid991 akid992 akid993 akid994 akid995 akid996 akid997 akid998 akid999

drop akid991r akid992r akid993r akid994r akid995r akid996r akid997r akid998r akid999r
*making new version of derived variables so i can recode missing and restrict to age 53 sample 
local varlist akid991 akid992 akid993 akid994 akid995 akid996 akid997 akid998 akid999
foreach var in `varlist' akid991 akid992 akid993 akid994 akid995 akid996 akid997 akid998 akid999 {
	clonevar `var'r = `var'
	tab `var' `var'r
}

*Age had eldest / youngest child
drop cmageybirth_youngest_53 cmageybirth_eldest_53
egen cmageybirth_youngest_53 = rowmax(agec1_26 agec2_26 agec3_26 agec4_26 agec1_31 agec2_31 agec1_36 agec2_36 agec3_36 agec4_36 agec5_36 agec1_43 agec2_43 agec3_43 agec4_43 agec5_43 agec1_43b agec2_43b agec3_43b agec4_43b akid991r akid992r akid993r akid994r akid995r akid996r akid997r akid998r akid999r)
egen cmageybirth_eldest_53 = rowmin(agec1_26 agec2_26 agec3_26 agec4_26 agec1_31 agec2_31 agec1_36 agec2_36 agec3_36 agec4_36 agec5_36 agec1_43 agec2_43 agec3_43 agec4_43 agec5_43 agec1_43b agec2_43b agec3_43b agec4_43b akid991r akid992r akid993r akid994r akid995r akid996r akid997r akid998r akid999r)
label variable cmageybirth_youngest_53 "Age in years of study member at birth of youngest child [age 53]"
label variable cmageybirth_eldest_53 "Age in years of study member at birth of oldest child [age 53]"
summ cmageybirth_youngest_26 cmageybirth_youngest_31 cmageybirth_youngest_36 cmageybirth_youngest_43 cmageybirth_youngest_53
summ cmageybirth_eldest_26 cmageybirth_eldest_31 cmageybirth_eldest_36 cmageybirth_eldest_43 cmageybirth_eldest_53

tab cmageybirth_eldest_53
replace cmageybirth_eldest_53 = -10 if NSHDSURVEY_53 == 1 & anybiochildren_53 == 0 // if no children at age 53
replace cmageybirth_eldest_53 = -100 if NSHDSURVEY_53 == 0 // if not interviewed at age 53
replace cmageybirth_eldest_53 = -99 if NSHDSURVEY_53 == 1 & anybiochildren_53 == -99 // if interviewed at age 53 but no info on children
replace cmageybirth_eldest_53 = -99 if NSHDSURVEY_53 == 1 & cmageybirth_eldest_53 == . 
label values cmageybirth_eldest_53 missage
tab cmageybirth_eldest_53
tab cmageybirth_eldest_53 if NSHDSURVEY_53 == 1


tab cmageybirth_youngest_53
replace cmageybirth_youngest_53 = -10 if NSHDSURVEY_53 == 1 & anybiochildren_53 == 0 // if no children at age 53
replace cmageybirth_youngest_53 = -100 if NSHDSURVEY_53 == 0 // if not interviewed at age 53
replace cmageybirth_youngest_53 = -99 if NSHDSURVEY_53 == 1 & anybiochildren_53 == -99 // if interviewed at age 53 but no info on children
replace cmageybirth_youngest_53 = -99 if NSHDSURVEY_53 == 1 & cmageybirth_youngest_53 == . 
label values cmageybirth_youngest_53 missage
tab cmageybirth_youngest_53
tab cmageybirth_youngest_53 if NSHDSURVEY_53 == 1

*Marital Status

tab rel1 marstats // of those with info in marstats, n=322 no info in rel1 [whether partner in household]
tab rel1 marstats , m nol

tab marstats partner_53, m

      Current marital |           Partner in HH (age 53)
          status 1999 | no partic  informati         no        yes |     Total
----------------------+--------------------------------------------+----------
                   -9 |         2          0          0          0 |         2 
Single, that is never |         0        110         55         18 |       183 
Married and living wi |         0          8          0      2,319 |     2,327 
Married and separated |         0         31         22         13 |        66 
             Divorced |         0        136         80        110 |       326 
         Or, widowed? |         0         37         34         14 |        85 
                    . |     2,326         47          0          0 |     2,373 
----------------------+--------------------------------------------+----------
                Total |     2,328        369        191      2,474 |     5,362 



*partner in household - of those with info in marstats, n=322 no info in rel1 [whether partner in household]
*of the n=322 these are single = n110; married n=8; sep/div/wid = n204

*partner in household

tab rel1, nol // household grid information

drop partner_53
gen partner_53 = -100
replace partner_53 = -99 if NSHDSURVEY_53 == 1 & (rel1 == . | rel1 == -9)
replace partner_53 = 1 if rel1 == 1 | rel1 == 2
replace partner_53 = 0 if rel1 == 3
label variable partner_53 "Partner in HH (age 53)"
label define p53 -100 "no participation in sweep" -99 "information not provided" 0 "no" 1 "yes"
label values partner_53 p53
tab partner_53

*marital status

label define ms53a -100 "no participation in sweep" -99 "information not provided" 1 "married" 2 "single cohabiting" 3 "single not cohabiting"

drop marital_53
gen marital_53 = -100
replace marital_53 = -99 if NSHDSURVEY_53 == 1 & partner_53 == -99
replace marital_53 = 1 if marstats == 2 & rel1 == 1
replace marital_53 = 2 if (marstats == 1 & rel1 == 2) | (marstats == 3 & rel1 == 2) | (marstats == 4 & rel1 == 2) | (marstats == 5 & rel1 == 2)
replace marital_53 = 3 if (marstats == 1 & rel1 == 3) | (marstats == 3 & rel1 == 3) | (marstats == 4 & rel1 == 3) | (marstats == 5 & rel1 == 3)
label variable marital_53 "Marital Status [age 53]"
label values marital_53 ms53a
tab marital_53

*Partner and child status
tab marital_53 anybiochildren_53, m

drop partnerchildbio_53
gen partnerchildbio_53 = -100
replace partnerchildbio_53 = 0 if partner_53 ==  0 & anybiochildren_53 == 0
replace partnerchildbio_53 = 1 if partner_53 ==  1 & anybiochildren_53 == 0
replace partnerchildbio_53 = 2 if partner_53 ==  0 & anybiochildren_53 == 1
replace partnerchildbio_53 = 3 if partner_53 ==  1 & anybiochildren_53 == 1	 
replace partnerchildbio_53 = -99 if partner_53 == -99 | anybiochildren_53 == -99	

label values partnerchildbio_53 marchild2
label variable partnerchildbio_53 "Whether has live in spouse/partner and/or any bio children [age 53]"
tab partnerchildbio_53 // n=3253 with info in both
tab partnerchildbio_53 NSHDSURVEY_53


save "$derived\NSHD_fertility_histories.dta", replace
