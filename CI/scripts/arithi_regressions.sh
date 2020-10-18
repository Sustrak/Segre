##########################################################
### Will launch the tests for the operations:          ###
###   ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI   ###
##########################################################

tests=("addi" "slti" "sltiu" "xori" "ori" "andi" "slli" "srli" "srai")
segre_dir=$(git rev-parse --show-toplevel)
$segre_dir/CI/scripts/run_list.sh $tests
