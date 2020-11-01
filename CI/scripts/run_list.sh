##########################################################
### Will launch the tests passed as list               ###
##########################################################

#segre_dir=$(git rev-parse --show-toplevel)
segre_dir=.
failed=0
for t in $@; do
    echo "Executing test $t"
    vsim -c -nolog -do "do $segre_dir/scripts/tcl/compile.tcl $t 1; quit" > /dev/null
    rm -rf vsim.wlf
    if grep -q -w "Error\|Fatal\|UVM_ERROR\|UVM_FATAL" $segre_dir/build/sim_transcript; then
        echo "$t test has failed"
        failed=1
    fi
done

exit $failed
