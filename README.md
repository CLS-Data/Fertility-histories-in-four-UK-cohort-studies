# Fertility histories in four British cohort studies

[Centre for Longitudinal Studies](https://cls.ucl.ac.uk/)

---

## Overview
This repository provides Stata code that derives harmonised fertility variables in four British cohort studies:

•	1946 MRC National Survey of Health and Development (NSHD)

•	1958 National Child Development Study (NCDS)

•	1970 British Cohort Study (BCS70)

•	1989/1990 Next Steps

The derived fertility data have been deposited with the [**UK Data Service**](https://beta.ukdataservice.ac.uk/datacatalogue/studies/study?id=9418). The code provided here enables researchers to track how the data have been derived as well as to adapt the code for their own use such as deriving additional variables. There is a code file for each cohort.   

---

## Included variable domains

| Domain         | Example of variables                               |
| -------------- | -------------------------------------- |
| Fertility      | biologial children (whether has any, number, number of girls and boys, age of eldest and youngest, number of children with a previous partner, number living in household, number living outside household )   |
|                |  non-biological children (whether has any, number, number of girls and boys, age of eldest and youngest)   |
|Partnership           |  whether partner in houshold, marital status   |

Further details about the full set of variables available can be found in the [**user guide**](https://cls.ucl.ac.uk/wp-content/uploads/2025/07/cohorts_harmonised_fertility_user_guide.pdf) for the deposited data.

---

## Syntax and data availability
- *Source data:* Download raw data for NCDS, BCS70, and Next Steps from the  [**UK Data Service**](https://ukdataservice.ac.uk/). For the NSHD, raw data should be requested from [**MRC Unit for Lifelong Health and Ageing at UCL (LHA)**](https://nshd.mrc.ac.uk/data-sharing/). See the the Stata code for NSHD for the variables to be requested. Place all raw data files in a folder on your computer.
  
- *Syntax:* Each of the code files (one for each cohorts) reads those data files and produces the datasets.    
- *Derived datasets:* Available to download from the [**UK Data Service**](https://beta.ukdataservice.ac.uk/datacatalogue/studies/study?id=9418).

---

## User feedback and future plans

We welcome user feedback. Please open an issue on GitHub or email **clsdata@ucl.ac.uk**.

## Authors
Aase Villadsen, Samantha Parsons, Alice Goisis
 
## Licence  
Code: MIT Licence (see `LICENSE`).

---

© 2025 UCL Centre for Longitudinal Studies
