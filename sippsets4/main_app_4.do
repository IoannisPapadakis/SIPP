cls 

clear

set more off

********************************************************************************

* Tommaso Santini

********************************************************************************

global directory = ""

cd "$directory/sippsets4"

use "set_a.dta"
drop if age == .


merge 1:1 id srefmon wave age using "set_b.dta"
drop _merge

merge 1:1 id srefmon wave age using "set_c.dta"
drop _merge

merge 1:m id srefmon wave age using "set_d.dta"
drop _merge


merge m:1 id wave srefmon using "set_f.dta"
drop _merge


/*
merge 1:1 id wave srefmon using "set_g.dta"
drop _merge
*/

/*
merge 1:1 id wave srefmon using "set_h.dta"
drop _merge

merge 1:1 id wave srefmon using "set_h2.dta"
drop _merge
*/
	
merge m:1 id wave age using "set_i.dta"
drop _merge

/*
merge 1:1 id srefmon wave age using "set_j.dta"
drop _merge
*/



order id wave srefmon month 
sort id wave srefmon

cd "$directory/Selection_4"
save "sipp4.dta", replace


