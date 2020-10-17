clear

set more off, permanently

********************************************************************************

* Tommaso Santini

********************************************************************************

global directory = ""


capture: log close main_2
log using "main_2", name("main_2") text replace 

********************************************************************************
/*
This script creates the Spells dataset. 
*/
********************************************************************************


* local Y = 96
* local Y = 1
* local Y = 4
* local Y = 8



timer on 2 // 1 sec


foreach Y in  96 1 4 8  {


cd "$directory/Selection_`Y'"

use "dataset1_`Y'.dta", clear

* Keep only the transition points
keep if jobsep == 1 | hire == 1


** Keep only the completed spells (not generalizable algorithm; I just did it manually enough times so that it works for each panel)
sort id year month

* Drop the obs with a hire as the first status of individ. history [2]   {e.g. E,E,nE,nE,nE,E,E,nE} --> {E,nE,nE,nE,E,E,nE}
gen mark = 0, after(hire)
by id: replace mark = 1 if jobsep[1] == 0 & _n == 1
drop if mark == 1
drop mark

* AGAIN: Drop the obs with a hire as the first status of individ. history [2b] {E,nE,nE,nE,E,E,nE}-->{nE,nE,nE,E,E,nE}
gen mark = 0, after(hire)
by id: replace mark = 1 if jobsep[1] == 0 & _n == 1
drop if mark == 1
drop mark


* Drop individ, who show up just once [1]
gen mark = 0, after(hire)
by id: replace mark = 1 if _N == 1
drop if mark == 1
drop mark


* Drop the obs with job separation as the last status in individ. history [3] {nE,nE,nE,E,E,nE} --> {nE,nE,nE,E,E}
gen mark = 0, after(hire)
by id: replace mark = 1 if jobsep[_N] == 1 & _n == _N
drop if mark == 1
drop mark

* AGAIN: Drop the obs with job separation as the last status in individ. history [3b]
gen mark = 0, after(hire)
by id: replace mark = 1 if jobsep[_N] == 1 & _n == _N
drop if mark == 1
drop mark


* Drop individ, who show up just once [1a]
gen mark = 0, after(hire)
by id: replace mark = 1 if _N == 1
drop if mark == 1
drop mark


* Get rid of sequent hires or sep.  
drop if emp == 1 & emp[_n-1] == 1 & id==id[_n-1]   // {nE,nE,nE,E,E} --> {nE,nE,nE,E}
drop if emp == 0 & emp[_n+1] == 0 & id==id[_n+1]   // {nE,nE,nE,E,E} --> {nE,nE,E} --> {nE,E} good


* Total number of spells per individ.
gen Spells=0, after(hire)
by id: replace Spells = _N/2
tab Spells 

* Check whether is the same of hires and drops for any individ.
by id: egen jp = total(jobsep)
by id: egen hr = total(hire)
order jp hr,after(hire)
gen equal = jp == hr, after(hr)
tab equal
drop jp hr equal




* Assign a number to each individual spell
sort hire id year month

gen idSpell = 1, after(hire)
replace idSpell = idSpell[_n-1] + 1 if id == id[_n-1] 

sort id year month





*** Create spell dataset

save "temp_main.dta", replace

su idSpell, meanonly
local X = r(max) // get the maximum number of spells for individual in the panel

** Spell i

forvalues i = 1/ `X' { 

use "temp_main.dta", clear

* Save "hire dataset" for the merge
keep if idSpell == `i'
keep if emp == 1

foreach x of var * {   // rename all of the variables as the "hire variable"
	rename `x' `x'_h 
}
*

rename id_h id 
rename race_h race // take it back after the loop
label var dur_h "unemployment duration at the hiring point"


save "spell_`i'_hire.dta", replace


* "Displacement" dataset
use "temp_main.dta",clear
keep if idSpell == `i'
keep if emp == 0

merge 1:1 id race using "spell_`i'_hire.dta"
drop _merge


order id idSpell Spells

erase "spell_`i'_hire.dta"

save "spell_`i'", replace


}
*


* append the datasets

use "spell_1.dta", clear

forvalues i = 2/ `X' {   

append using "spell_`i'.dta"

}
*

forvalues i = 1/ `X' {

erase "spell_`i'.dta"

}
*
erase "temp_main.dta"

sort id year month // which is identical to sort id idSpell


** 
#delimit ; 

keep id idSpell Spells panel race   // permanent 
year month time seamth1 seamth4 index UnEmp_rate sipp_st age occ occ61 occ48 ind ind61 ind48 educ ms emp_sp tpearn_avg_sp wwage_avg_sp thours_sp rfoklt18 hh_netliq wpfinwgt  // displacement
year_h month_h time_h seamth1_h seamth4_h index_h UnEmp_rate_h sipp_st_h age_h occ_h occ61_h occ48_h ind_h ind61_h ind48_h educ_h dur_h ms_h emp_sp_h tpearn_avg_sp_h wwage_avg_sp_h thours_sp_h rfoklt18_h wpfinwgt_h ;  // rehiring



order id idSpell Spells panel race   // permanent
year month time seamth1 seamth4 index UnEmp_rate sipp_st age occ occ61 occ48 ind ind61 ind48 educ ms emp_sp tpearn_avg_sp wwage_avg_sp thours_sp rfoklt18 hh_netliq wpfinwgt    // displacement
year_h month_h time_h seamth1_h seamth4_h index_h UnEmp_rate_h sipp_st_h age_h occ_h occ61_h occ48_h ind_h ind61_h ind48_h educ_h dur_h ms_h emp_sp_h tpearn_avg_sp_h wwage_avg_sp_h thours_sp_h rfoklt18_h wpfinwgt_h ;  // rehiring

#delimit cr



save "spells`Y'.dta", replace


}
*


timer off 2
timer list 2
timer clear 2


log close main_2
