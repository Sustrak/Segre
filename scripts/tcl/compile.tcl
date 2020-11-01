# USAGE #
# compile.tcl <testname> <use_modelsim>

# ARGS #
set test_name $1
set use_modelsim $2
set GITHUB_CI [pwd]
set rtl_dir src/rtl
set tb_dir src/tb
set work_dir build/work
set pkg_dir src/pkg
set test_dir tests/hex

# Create build dir
file mkdir build

# Create work library
vlib $work_dir

# Compile packages
vlog -sv -work $work_dir $pkg_dir/segre_pkg.sv

# Compile rtl
vlog -sv -work $work_dir $rtl_dir/segre_controller.sv
vlog -sv -work $work_dir $rtl_dir/segre_if_stage.sv
vlog -sv -work $work_dir $rtl_dir/segre_decode.sv
vlog -sv -work $work_dir $rtl_dir/segre_id_stage.sv
vlog -sv -work $work_dir $rtl_dir/segre_alu.sv
vlog -sv -work $work_dir $rtl_dir/segre_tkbr.sv
vlog -sv -work $work_dir $rtl_dir/segre_ex_stage.sv
vlog -sv -work $work_dir $rtl_dir/segre_mem_stage.sv
vlog -sv -work $work_dir $rtl_dir/segre_register_file.sv
vlog -sv -work $work_dir $rtl_dir/segre_core.sv

# Compile tb
vlog -sv -work $work_dir $tb_dir/interface.sv
if { $use_modelsim } {
    vlog -sv -work $work_dir +define+USE_MODELSIM=1 $tb_dir/memory.sv
    vlog -sv -work $work_dir +define+USE_MODELSIM=1 $tb_dir/top_tb.sv
} else {
    vlog -sv -work $work_dir $tb_dir/memory.sv
    vlog -sv -work $work_dir $tb_dir/top_tb.sv
}

# Start simulation
vsim -dpicpppath /usr/bin/gcc -l build/sim_transcript +TEST_NAME=$test_name -voptargs=+acc -sv_lib lib/libdecoder $work_dir.top_tb

# Add the wave to the simulation
do scripts/wave.do

# Run all
run -all
