##########################################################
### Will launch the tests for the operations:          ###
###   ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND ###
##########################################################

tests=("addi" "slti" "sltiu" "xori" "ori" "andi" "slli" "srli" "srai")
segre_dir=$(git rev-parse --show-toplevel)
$segre_dir/CI/scripts/run_list.sh $tests
