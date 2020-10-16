##########################################################
### Will launch the tests passed as list               ###
##########################################################

segre_dir=$(git rev-parse --show-toplevel)
echo "Executing tests..."
for t in $@; do
    vsim -c -nolog -do "do $segre_dir/scripts/tcl/compile.tcl $t; quit" > /dev/null
    rm -rf vsim.wlf
    if grep -q "UVM_ERROR\|UVM_FATAL" $segre_dir/build/sim_transcript; then
        echo "$t test has failed"
    fi
    exit 0
done
