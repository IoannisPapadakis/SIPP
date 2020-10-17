clear

set more off, permanently

********************************************************************************

* Tommaso Santini

********************************************************************************

global directory = ""


capture: log close main_3
log using "main_3", name("main_3") text replace 

********************************************************************************
* This script appends the spell datasets into the final spell dataset (all panels)
********************************************************************************


cd "$directory/Selection_96"

use "spells96.dta", clear


cd "$directory/Selection_1"

append using "spells1.dta"


cd "$directory/Selection_4"

append using "spells4.dta"


cd "$directory/Selection_8"

append using "spells8.dta"



label drop spanel


tab panel,m
tab race,m

tab idSpell
tab Spells

tab ms,m
tab rfoklt18,m

tabmiss panel


drop if panel == .
drop if year_h == .
drop if index != index_h // if the spell is composed of two different interviews
 
cd "$directory/Main"

save "allPanels_spells", replace


log close main_3
