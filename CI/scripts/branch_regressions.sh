#################################################
### Will launch the tests for the operations: ###
###   BEQ BNE BLT BGE BLTU BGEU               ###
#################################################

tests=(beq bne blt bge bltu bgeu)
./CI/scripts/run_list.sh $(echo ${tests[@]})
