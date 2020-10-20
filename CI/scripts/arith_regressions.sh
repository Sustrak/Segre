##########################################################
### Will launch the tests for the operations:          ###
###   ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND ###
##########################################################

tests=("add" "sub" "sll" "slt" "sltu" "xor" "srl" "sra" "or" "and")
#segre_dir=$(git rev-parse --show-toplevel)
./CI/scripts/run_list.sh $tests
