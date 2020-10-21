##########################################################
### Will launch the tests for the operations:          ###
###   ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND ###
##########################################################

tests=(beq bne blt bge bltu bgeu)
./CI/scripts/run_list.sh $(echo ${tests[@]})
