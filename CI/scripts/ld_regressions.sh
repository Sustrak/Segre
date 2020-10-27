##########################################################
### Will launch the tests for the operations:          ###
###   LB LBU LH LHU LW                                 ###
##########################################################

tests=(lb lbu lh lhu lw)
./CI/scripts/run_list.sh $(echo ${tests[@]})
