##########################################################
### Will launch the tests for the operations:          ###
###   SB SH SW                                         ###
##########################################################

tests=(sb sh sw sb_stress st_ld_stress st_ld_w)
./CI/scripts/run_list.sh $(echo ${tests[@]})
