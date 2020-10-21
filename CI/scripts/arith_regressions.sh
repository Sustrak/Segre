##########################################################
### Will launch the tests for the operations:          ###
###   ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND ###
##########################################################

tests=(add sub sll slt sltu xor srl sra or and)
./CI/scripts/run_list.sh $(echo ${tests[@]})
