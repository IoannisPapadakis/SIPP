clear

set more off, permanently
set varabbrev off, permanently

********************************************************************************

* Tommaso Santini

********************************************************************************

global directory = ""

capture: log close main_1
log using "main_1", name("main_1") text replace 

********************************************************************************
/*

Reshapes the dataset from the CEPR structure with the two jobs to a standard shape.
In particular, it generates the variables relative to the spouse in the same line 
as the reference individual.

It drops some observation according to some criteria.

Merges the main dataset with the one containing the asset information.
*/
********************************************************************************


* local Y = 96
* local Y = 1
* local Y = 4
* local Y = 8


timer on 1 // 6 minutes


 foreach Y in  96 1 4 8  {


cd "$directory/Selection_`Y'"

use "sipp`Y'.dta"


* Select and order the variables
keep ssuid epppnum id srefmon wave panel year month wksper age race sipp_st esr job estlemp earn tpearn hours rmwkwjb occ ind educ ms spouseid rfoklt18 wpfinwgt whfnwgt
order ssuid epppnum id srefmon wave panel year month wksper age race sipp_st esr job estlemp earn tpearn hours rmwkwjb occ ind educ ms spouseid rfoklt18 wpfinwgt whfnwgt


********************************************************************************
** Preliminary drops
sort id year month

* Drop age
drop if age <25 | age>55


** check with age (one year tolerance)
sort id year month

gen check_age_tol = id[_n]==id[_n-1]   &  age[_n] != age[_n-1]   &   age[_n] != age[_n-1]+1   &   age[_n] != age[_n-1]+2
by id: egen check_1_age_tol = total(check_age_tol)
gen  check_2_age_tol = check_1_age_tol != 0  
drop check_age_tol check_1_age_tol


** check with age (zero tolerance)

gen check_age = id[_n]==id[_n-1]   &  age[_n] != age[_n-1]   &   age[_n] != age[_n-1]+1
by id: egen check_1_age = total(check_age)
gen check_2_age = check_1_age != 0  
drop check_age check_1_age

order check_2_age_tol check_2_age, after(age)


drop if check_2_age_tol == 1
drop check_2_age_tol
drop if check_2_age == 1
drop check_2_age

********************************************************************************




* Generate total hours per week, sum of two jobs.
sort id year month 

egen thours = sum(hours), by(id wave srefmon) 
label var thours "Hours worked in a week"
order thours, after(hours)


** Keep only one job
sort id year month 


* drop the one in which the individual did not earn at all
drop if  earn == .   &    id == id[_n-1] & year == year[_n-1] & month == month[_n-1] & srefmon == srefmon[_n-1] 
drop if  earn == .   &    id == id[_n+1] & year == year[_n+1] & month == month[_n+1] & srefmon == srefmon[_n+1] 

* drop the one in which the individual earns less
drop if  earn < earn[_n-1]   &   id == id[_n-1] & year == year[_n-1] & month == month[_n-1] & srefmon == srefmon[_n-1] 
drop if  earn < earn[_n+1]   &    id == id[_n+1] & year == year[_n+1] & month == month[_n+1] & srefmon == srefmon[_n+1] 

* drop according to appearance if the earnings are the same
drop if  job > job[_n-1]   &   id == id[_n-1] & year == year[_n-1] & month == month[_n-1] & srefmon == srefmon[_n-1] 
drop if  job > job[_n+1]   &    id == id[_n+1] & year == year[_n+1] & month == month[_n+1] & srefmon == srefmon[_n+1] 

* drop if tpearn is lower than earn (tpearn is the sum of two jobs)
drop if tpearn < earn & earn != .

* drop if tpearn is negative (total earned inxcome)
drop if tpearn < 0 



duplicates tag, gen(dup)
duplicates tag id year month , gen(dup1)
tab dup
drop if dup > 0
tab dup
tab dup1
drop if dup1 > 0
tab dup1
drop dup dup1




**** Broad categories of industry and occupation

/*

For panels 96 and 01 the detalied industry and occupations categories are 
different with respect to the detailed ind and occ of panels 04 and 08. The codes 
to define broad categories are, therefore, different.  
The 2004-2008 SIPP panels use the 2000 Census Occupation codes (based on the 2000 SOC)
and Census Industry codes (based on the 2002 NAICS):

	https://www.bls.gov/soc/2000/soc-structure-2000.pdf
	https://www.census.gov/cgi-bin/sssd/naics/naicsrch?chart=2002
	
*/

      
*** Panels 96 and 01

* Occupations

		gen occ61 = 0 ,after(occ) // set to zero in order to run one regression of the whole sample and control for both industry and occ
		label var occ61 "Broad categories occ. Panel 96 and 01"
		
		replace occ61 = 1  if (occ>=3&occ<=37)        & (panel==1996 | panel==2001)         /*Executive, Administrative, and Managerial Occupations*/
        replace occ61 = 2  if (occ>=43 & occ<=199)    & (panel==1996 | panel==2001)         /*Professional Specialty Occupations*/
        replace occ61 = 3  if (occ>=203 & occ<=235)   & (panel==1996 | panel==2001)         /*Technicians and Related Support Occupations*/
        replace occ61 = 4  if (occ>=243 & occ<=285)   & (panel==1996 | panel==2001)         /*Sales Occupations*/
        replace occ61 = 5  if (occ>=303 & occ<=389)   & (panel==1996 | panel==2001)         /*Administrative Support Occupations, Including Clerical*/
        replace occ61 = 6  if (occ>=403 & occ<=407)   & (panel==1996 | panel==2001)         /*Private Household Occupations - Services*/
        replace occ61 = 7  if (occ>=413 & occ<=427)   & (panel==1996 | panel==2001)         /*Protective Service Occupations - Services*/
        replace occ61 = 8  if (occ>=433 & occ<=469)   & (panel==1996 | panel==2001)         /*Service Occupations, Except Protective and Household*/
        replace occ61 = 9  if (occ>=503 & occ<=699)   & (panel==1996 | panel==2001)         /*PRECISION PRODUCTION, CRAFT, AND REPAIR OCCUPATIONS, including construction*/
        replace occ61 = 10 if (occ>=703 & occ<=799)   & (panel==1996 | panel==2001)         /*Machine Operators, Assemblers, and Inspectors*/
        replace occ61 = 11 if (occ>=803 & occ<=856)   & (panel==1996 | panel==2001)         /*Transportation and Material Moving Occupations*/
        replace occ61 = 12 if (occ>=864 & occ<=889)   & (panel==1996 | panel==2001)         /*Handlers, Equipment Cleaners, Helpers, and Laborers*/
		replace occ61 = 13 if (occ >= 473 & occ<=499) & (panel==1996 | panel==2001)         /*farming, forestry, fishing occupations*/
		replace occ61 = 14 if  occ >= 903 & occ<=905  & (panel==1996 | panel==2001)         /*MILITARY OCCUPATIONS*/
		
		
        drop if occ61 == 13 & (panel==1996 | panel==2001)                        /*farming, forestry, fishing occupations*/
        drop if occ61 == 14 & (panel==1996 | panel==2001)                        /*MILITARY OCCUPATIONS*/
        
		
* Industries

		gen ind61 = 0 ,after(ind) // set to zero, same as before
		label var ind61 "Broad categories ind. Panel 96 and 01"
		
		replace ind61 = 1   if (ind>=40   & ind<=50)  & (panel==1996 | panel==2001)                        /*MINING*/
        replace ind61 = 2   if (ind==60 )             & (panel==1996 | panel==2001)                        /*CONSTRUCTION*/ 
        replace ind61 = 3   if (ind>=100  & ind<=392) & (panel==1996 | panel==2001)                        /*MANUFACTURING*/ 
        replace ind61 = 4   if (ind>=400  & ind<=472) & (panel==1996 | panel==2001)                        /*TRANSPORTATION, COMMUNICATIONS, AND OTHER PUBLIC UTILITIES*/ 
        replace ind61 = 5   if (ind>=500  & ind<=571) & (panel==1996 | panel==2001)                        /*WHOLESALE TRADE*/ 
        replace ind61 = 6   if (ind>=580  & ind<=691) & (panel==1996 | panel==2001)                        /*RETAIL TRADE*/ 
        replace ind61 = 7   if (ind>=700  & ind<=712) & (panel==1996 | panel==2001)                        /*FINANCE, INSURANCE, AND REAL ESTATE*/
        replace ind61 = 8   if (ind>=721  & ind<=760) & (panel==1996 | panel==2001)                        /*BUSINESS AND REPAIR SERVICES*/
        replace ind61 = 9   if (ind>=761  & ind<=791) & (panel==1996 | panel==2001)                        /*PERSONAL SERVICES*/
        replace ind61 = 10  if (ind>=800  & ind<=810) & (panel==1996 | panel==2001)                        /*ENTERTAINMENT AND RECREATION SERVICES*/
        replace ind61 = 11  if (ind>=812  & ind<=893) & (panel==1996 | panel==2001)                        /*PROFESSIONAL AND RELATED SERVICES*/
		replace ind61 = 12  if  ind>=10   & ind<=32   & (panel==1996 | panel==2001)                        /*AGRICULTURE, FORESTRY, AND FISHERIES*/
		replace ind61 = 13  if  ind>=900  & ind<=932  & (panel==1996 | panel==2001)                        /*PUBLIC ADMINISTRATION*/
		replace ind61 = 14  if  ind>=940  & ind<=960  & (panel==1996 | panel==2001)                        /*ACTIVE DUTY MILITARY*/

        drop if ind61 == 12 & (panel==1996 | panel==2001)                        /*AGRICULTURE, FORESTRY, AND FISHERIES*/
        drop if ind61 == 13 & (panel==1996 | panel==2001)                        /*PUBLIC ADMINISTRATION*/
        drop if ind61 == 14 & (panel==1996 | panel==2001)                        /*ACTIVE DUTY MILITARY*/

		


*** Panels 04 and 08: 


* Occupations
		
		gen occ48 = 0 ,after(occ) // set to zero, same as before
		label var occ48 "Broad categories occ. Panel 04 and 08"
		
        replace occ48 = 15 if (occ>=10   & occ<=430)   & panel>=2004        	/*Executive, Administrative, and Managerial Occupations*/
        replace occ48 = 16 if (occ>=500  & occ<=950)   & panel>=2004        	/*Business and Financial Operations*/
        replace occ48 = 17 if (occ>=1000 & occ<=1240)  & panel>=2004        	/*Computer and Mathematical Occupations*/       
        replace occ48 = 18 if (occ>=1300 & occ<=1560)  & panel>=2004        	/*Architecture and Engineering Occupations*/    
        replace occ48 = 19 if (occ>=1600 & occ<=1960)  & panel>=2004        	/*Life, Physical, and Social Science Occupations*/      
        replace occ48 = 20 if (occ>=2000 & occ<=2100)  & panel>=2004        	/*Community and Social Services Occupations*/   
        replace occ48 = 21 if (occ>=2100 & occ<=2150)  & panel>=2004        	/*Legal Occupations*/   
        replace occ48 = 22 if (occ>=2200 & occ<=2550)  & panel>=2004        	/*Education, Training, and Library Occupations*/        
        replace occ48 = 23 if (occ>=2600 & occ<=2960)  & panel>=2004        	/*Arts, Design, Entertainment, Sports, and Media*/      
        replace occ48 = 24 if (occ>=3000 & occ<=3540)  & panel>=2004        	/*Healthcare Practitioners and Technical*/      
        replace occ48 = 25 if (occ>=3600 & occ<=3650)  & panel>=2004        	/*Healthcare Support Occupations*/      
        replace occ48 = 26 if (occ>=3700 & occ<=3950)  & panel>=2004        	/*Protective Service Occupations*/      
        replace occ48 = 27 if (occ>=4000 & occ<=4160)  & panel>=2004        	/*Food Preparation and Serving Related*/        
        replace occ48 = 28 if (occ>=4200 & occ<=4250)  & panel>=2004        	/*Building and Grounds Cleaning and*/   
        replace occ48 = 29 if (occ>=4300 & occ<=4650)  & panel>=2004        	/*Personal Care and Service Occupations*/       
        replace occ48 = 30 if (occ>=4700 & occ<=4960)  & panel>=2004        	/*Sales and Related Occupations*/       
        replace occ48 = 31 if (occ>=5000 & occ<=5930)  & panel>=2004            /*Office and Administrative Support Occupations*/       
        replace occ48 = 32 if (occ>=6000 & occ<=6130)  & panel>=2004        	/*Farming, Fishing, and Forestry Occupations DROP*/        
        replace occ48 = 33 if (occ>=6200 & occ<=6940)  & panel>=2004        	/*Construction and Extraction Occupations*/     
        replace occ48 = 34 if (occ>=7000 & occ<=7620)  & panel>=2004        	/*Installation, Maintenance, and Repair*/       
        replace occ48 = 35 if (occ>=7700 & occ<=8960)  & panel>=2004        	/*Production Occupations*/      
        replace occ48 = 36 if (occ>=9000 & occ<=9750)  & panel>=2004        	/*Transportation and Material Moving*/  
		replace occ48 = 37 if  occ == 9840 & panel>=2004			            /* Persons unemployed and last job Armed Forces */

		drop if occ48 == 32 & panel>=2004  /*Farming, Fishing, and Forestry Occupations DROP*/        
		drop if occ48 == 36 & panel>=2004  /* Persons whose current labor force status is unemployed and last job was Armed Forces DROP*/      				


* Industries
		
		gen ind48 = 0 , after(ind)  // set to zero, same as before
		label var ind48 "Broad categories ind. Panel 04 and 08"
		
        replace ind48 = 24 if (ind>=0370 & ind<=0490)  & panel>=2004            /*MINING*/
        replace ind48 = 25 if (ind>=0570 & ind<=0690)  & panel>=2004            /*Utilities*/
        replace ind48 = 26 if (ind==0770 )             & panel>=2004			/*CONSTRUCTION*/
        replace ind48 = 27 if (ind>=1070 & ind<=3990)  & panel>=2004            /*MANUFACTURING*/
        replace ind48 = 28 if (ind>=6070 & ind<=6390)  & panel>=2004            /*TRANSPORTATION, and warehousing*/
        replace ind48 = 29 if (ind>=4070 & ind<=4590)  & panel>=2004            /*WHOLESALE TRADE*/
        replace ind48 = 30 if (ind>=4670 & ind<=5790)  & panel>=2004            /*RETAIL TRADE*/
        replace ind48 = 31 if (ind>=6470 & ind<=6780)  & panel>=2004            /*Information*/
        replace ind48 = 32 if (ind>=6870 & ind<=6990)  & panel>=2004            /*FINANCE, INSURANCE,*/
        replace ind48 = 33 if (ind>=7070 & ind<=7190)  & panel>=2004            /* REAL ESTATE and Rental and Leasing*/
        replace ind48 = 34 if (ind>=7270 & ind<=7490)  & panel>=2004            /* Professional, Scientific, and Technical Services*/
        replace ind48 = 35 if (ind>=7570 & ind<=7490)  & panel>=2004            /* Management of Companies and Enterprises*/
        replace ind48 = 36 if (ind>=7580 & ind<=7790)  & panel>=2004            /* Administrative and Support and Waste Management and Remediation Services*/
        replace ind48 = 37 if (ind>=7860 & ind<=7890)  & panel>=2004            /*Educational Services*/
        replace ind48 = 38 if (ind>=7970 & ind<=8470)  & panel>=2004            /*Health Care and Social Assistance*/
        replace ind48 = 39 if (ind>=8560 & ind<=8590)  & panel>=2004            /*Arts, Entertainment, and Recreation*/
        replace ind48 = 40 if (ind>=8660 & ind<=8690)  & panel>=2004            /*Accommodation and Food Services*/
        replace ind48 = 41 if (ind>=8770 & ind<=9290)  & panel>=2004            /*Other Services (except Public Administration)*/
        replace ind48 = 42 if (ind>=9370 & ind<=9590)  & panel>=2004            /*Public Administration; DROP*/
		replace ind48 = 43 if (ind>=0170 & ind<=0290)  & panel>=2004            /*AGRICULTURE, FORESTRY, AND FISHERIES; DROP*/


		drop if ind48 == 43 & panel>=2004  /*AGRICULTURE, FORESTRY, AND FISHERIES; DROP*/
		drop if ind48 == 42 & panel>=2004  /*Public Administration; DROP*/
		
		


*** Employment 

* Drop if no info about work status
drop if esr == .

* Drop if individ. reports employment but no income
drop if (esr == 1 | esr == 2 ) & tpearn == 0

* Drop if individ. reports employment but no industry nor/or occupation
drop if (esr == 1 | esr == 2 ) & ind == .
drop if (esr == 1 | esr == 2 ) & occ == . 


** Define employment
gen emp=., after(esr)

  * Unemployed
  replace emp = 0 if esr >= 3 

  * Employed
  replace emp = 1 if (esr == 1 | esr ==2)

  * Define the value labels
  label define flows 0 "nE" 1 "E"
  label values emp flows

  
tab emp,m
  


* Compute Income 3-month average (tpearn)
sort id year month
by id: gen tpearn_avg = (tpearn[_n-1] + tpearn + tpearn[_n+1]) / 3 if tpearn[_n-1] != 0 & tpearn != 0 & tpearn[_n+1] != 0
replace tpearn_avg = tpearn if tpearn_avg == .
label var tpearn_avg "3 months income average"
order tpearn_avg, after(tpearn)
drop tpearn earn

* Compute income 3-months average for weekly wage (wwage)
gen wwage_avg = tpearn_avg/rmwkwjb, after(tpearn_avg)
replace wwage_avg = 0 if wwage_avg == .
label var wwage_avg "3 months weekly wage average"




** Define job separation 
gen jobsep=0, after(emp)
replace jobsep = 1 if id == id[_n-1] & emp[_n-1] == 1 & emp == 0

* Assign occupation of previous job to obs with job separation (for the occ switching cox regression). { jobsep == 1 implies that id == id[_n-1] }

* broad
replace occ61 = occ61[_n-1] if jobsep == 1 & occ61 == 0 & (panel==1996 | panel==2001)

replace occ48 = occ48[_n-1] if jobsep == 1 & occ48 == 0 &  panel >= 2004

* detailed
replace occ = occ[_n-1] if jobsep == 1 & occ == . 



* Define rehiring
gen hire=0, after(jobsep)
replace hire = 1 if id == id[_n-1] & emp[_n-1] == 0 & emp == 1

* Generate dummy for seam effect
gen seamth1=0, after(srefmon)
replace seamth1=1 if srefmon==1

gen seamth4=0, after(seamth1)
replace seamth4=1 if srefmon==4


** generate the time variable
gen time=ym(year ,month), after(month)





*** Wages and Wealth

* Merge with the wealth info (topical module)
merge m:1 ssuid epppnum panel wave using "sipp`Y'_A"
tab wave _merge // remember: asset information not in any wave.
drop if _merge == 2
drop _merge

* Create net liquid wealth
gen hh_netliq= thhtwlth-thhtheq-thhvehcl-rhhuscbt
drop thhtwlth thhtheq thhvehcl rhhuscbt

** Adjust for infaltion thhtnw and tpearn
merge m:1 year month using CPI_U.dta
drop if _merge == 2
drop _merge

* Wealth 
replace hh_netliq = (hh_netliq/cpi) * 100

* Wage
replace tpearn_avg = (tpearn_avg/cpi) * 100
drop cpi






********************************************************************************

****** Attach wealth to waves in which there isn't.

* Generate variable that will count month in sample to identify any second interview
sort id wave srefmon
gen count=1,after(wave)
replace count=count[_n-1]+1 if id==id[_n-1] & ( ( month ==( month[_n-1]+1 ) & year==year[_n-1]) | (year==(year[_n-1]+1)&month==1) ) in 2/l
gen index=0, after(count)
replace index=1 if count==1 
replace index=2 if count==1 & id==id[_n-1]
qui by id: replace index=index[_n-1] if index==0 
label var index "Interview id"
drop count


** Attach
sort id year month

* compute the mean wealth in each wave
bysort id index wave:  egen hh_netliq_avg = mean(hh_netliq) 

* wave 3
gen w96_3_ind = hh_netliq_avg if wave == 3 

bysort id index:  egen w96_3 = mean(w96_3_ind)

* wave 4
gen w96_4_ind = hh_netliq_avg if wave == 4

bysort id index:  egen w96_4 = mean(w96_4_ind)

* wave 6
gen w96_6_ind = hh_netliq_avg if wave == 6

bysort id index:  egen w96_6 = mean(w96_6_ind)

* wave 7
gen w96_7_ind = hh_netliq_avg if wave == 7

bysort id index:  egen w96_7 = mean(w96_7_ind)


* wave 9
gen w96_9_ind = hh_netliq_avg if wave == 9

bysort id index:  egen w96_9 = mean(w96_9_ind)

* wave 12

gen w96_12_ind = hh_netliq_avg if wave == 12

bysort id index:  egen w96_12 = mean(w96_12_ind)

* drop the indexes
drop w96_3_ind w96_4_ind w96_6_ind w96_7_ind w96_9_ind w96_12_ind


* Panel specific (see first lines of main_0 for clarifications)
replace hh_netliq = w96_3 if ( wave == 1 | wave == 2 | wave == 4 ) & ( panel == 1996 | panel == 2001 | panel == 2004 )

replace hh_netliq = w96_4 if ( wave == 1 | wave == 2 | wave == 3 | wave == 5 ) & panel == 2008

replace hh_netliq = w96_6 if ( wave == 5 | wave == 7 ) & ( panel == 1996 | panel == 2001 )
replace hh_netliq = w96_6 if ( wave == 5 | wave == 7 | wave == 8 | wave == 9 | wave == 10 | wave == 11 | wave == 12 ) & panel == 2004

replace hh_netliq = w96_7 if ( wave == 6 | wave == 8 | wave == 9 | wave == 19 | wave == 11 | wave == 12 ) & panel == 2008

replace hh_netliq = w96_9 if ( wave == 8 | wave == 10 ) & panel == 1996
replace hh_netliq = w96_9 if ( wave == 8 | wave == 10 | wave == 11 | wave == 12 ) & panel == 2001

replace hh_netliq = w96_12 if wave == 11 & panel == 1996

drop hh_netliq_avg w96_3 w96_4 w96_6 w96_7 w96_9 w96_12
********************************************************************************





********************************************************************************
* Generate spouse working dummy, spouse total earned income and spouse working hours in each month
 
sort spouseid year month
save "dataset1_`Y'.dta", replace

gen emp_sp = emp
label var emp_sp "Spouse employment status"

gen tpearn_avg_sp = tpearn_avg
label var tpearn_avg_sp "Spouse 3 months monthly wage average"

gen wwage_avg_sp = wwage_avg
label var wwage_avg_sp "Spouse 3 months weekly wage average"

gen thours_sp = thours
label var thours_sp "Hours worked in a week by the spouse"

keep id year month emp_sp tpearn_avg_sp wwage_avg_sp thours_sp
rename id spouseid
sort spouseid year month
save temp, replace
use "dataset1_`Y'.dta", clear
merge m:m spouseid year month using temp
tab _merge
drop if _merge == 2
drop _merge
erase "temp.dta"

order emp_sp tpearn_avg_sp wwage_avg_sp thours_sp, after(spouseid)

********************************************************************************



** Prepare to transform in spell dataset

sort id year month

** Keep only those who experienced a job separation
by id: egen mark=sum(jobsep)
keep if mark>0
drop mark

** Keep only those who have been hired
by id: egen mark=sum(hire)
keep if mark>0
drop mark


* Create the variable "unemployment duration at the hiring point":
gen dur = 1 if emp == 0, after(hire)
replace dur = dur[_n-1] + 1 if id == id[_n-1] & emp == 0 & emp[_n-1] == 0 
replace dur = dur[_n-1] if hire == 1
replace dur = . if hire == 0
label var dur "Unemployment duration at the hiring point"


* Merge with aggregate unemployment rate ( to use it as a control in the regression)
merge m:1 year month using "unempRate.dta"
drop if _merge<3
drop _merge
order UnEmp_rate, after(month)


* Keep only spouse related wage variables
drop tpearn_avg wwage_avg hours thours rmwkwjb 

sort id year month



save "dataset1_`Y'.dta", replace


tabmiss id
tabmiss panel

tabmiss ind if emp == 1
tabmiss occ if emp == 1

tabmiss ind61 if emp == 1   
tabmiss occ61 if emp == 1   

tabmiss ind48 if emp == 1   
tabmiss occ48 if emp == 1   

tabmiss educ

tabmiss ms

tabmiss spouseid if ms == 1

tabmiss emp_sp if ms == 1    // !!! 


tabmiss tpearn_avg_sp if ms == 1 & emp_sp == 1

tabmiss wwage_avg_sp if ms == 1 & emp_sp == 1

tabmiss thours_sp if emp_sp == 1

tabmiss rfoklt18

duplicates r
duplicates r id year month


}
*


timer off 1
timer list 1
timer clear 1



log close main_1





