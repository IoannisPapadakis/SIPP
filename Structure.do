cls

clear all

set more off

********************************************************************************

* Tommaso Santini

********************************************************************************


global directory = ""


****************************************************************************************************************************** 
*** This script, illustrates the procedure to get the final datasets from the raw starting one. It runs all the separate scripts and records the time.
****************************************************************************************************************************** 


timer on 100

* merge the CEPR datasets to have the raw data for each panel
 foreach Y in  96 1 4 8  {

cd "$directory/sippsets`Y'"
do main_app_`Y'.do
}
*


cd "$directory/assets_data"
do main_asset.do

cd "/Users/tommaso/Desktop/RAship_Javier/SIPP/Main"
do main1.do

cd "/Users/tommaso/Desktop/RAship_Javier/SIPP/Main"
do main2.do

cd "/Users/tommaso/Desktop/RAship_Javier/SIPP/Main"
do main3.do


timer off 100

timer list 100
