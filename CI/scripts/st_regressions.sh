##########################################################
### Will launch the tests for the operations:          ###
###   SB SH SW                                         ###
##########################################################

tests=(sb sh sw)
./CI/scripts/run_list.sh $(echo ${tests[@]})
