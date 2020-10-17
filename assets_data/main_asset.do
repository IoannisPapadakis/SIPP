cls

clear

set more off, permanently

global directory = "/Users/tommaso/Desktop/RAship_Javier/SIPP"

capture: log close main_asset
log using "main_asset", name("main_asset") text replace 


********************************************************************************
/*
This script manages the assets information. It just selects the needed
variables and moves it from the original folder (assets_data) to the panel
related folder.

The number of waves with wealth information changes depending on the panel.

96: 3,6,9,12
01: 3,6,9
04: 3,6
08: 4,7 
*/
********************************************************************************

cd "$directory/assets_data"


* Define the variable I extract:
local wealth "ssuid epppnum spanel wave thhtwlth thhtheq thhvehcl rhhuscbt"

** Panel 96
use "sipp96t3", clear

keep `wealth'

append using "sipp96t6"
keep `wealth'

append using "sipp96t9"
keep `wealth'

append using "sipp96t12"
keep `wealth'

rename spanel panel


cd "$directory/Selection_96"
save "sipp96_A", replace


** Panel 01
cd "$directory/assets_data"
use "sipp01t3", clear
keep `wealth'

append using "sipp01t6"
keep `wealth'

append using "sipp01t9"
keep `wealth'

rename spanel panel

cd "$directory/Selection_1"
save "sipp1_A", replace


** Panel 04
cd "$directory/assets_data"
use "sipp04t3", clear
keep `wealth'

append using "sipp04t6"
keep `wealth'


rename spanel panel

cd "$directory/Selection_4"
save "sipp4_A", replace


** Panel 08
cd "$directory/assets_data"
use "sipp08t4", clear
keep `wealth'

append using "sipp08t7"
keep `wealth'


rename spanel panel

cd "$directory/Selection_8"
save "sipp8_A", replace




log close main_asset

