##########################################################
### Will launch the tests for the operations:          ###
###   ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI   ###
##########################################################

tests=(addi slti sltiu xori ori andi slli srli srai)
./CI/scripts/run_list.sh $(echo ${tests[@]})
