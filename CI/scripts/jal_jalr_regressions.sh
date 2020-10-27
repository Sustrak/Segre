##########################################################
### Will launch the tests for the operations:          ###
###   JAL, JALR                                        ###
##########################################################

tests=(jaljalr)
./CI/scripts/run_list.sh $(echo ${tests[@]})
