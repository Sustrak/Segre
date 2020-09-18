set rtl_dir src/rtl
set tb_dir src/tb
set work_dir build/work
set pkg_dir src/pkg
set test_dir tests/hex

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
vlog -sv -work $work_dir -define HEX_FILE="$test_dir/jal.hex" -define DEBUG $tb_dir/memory.sv
vlog -sv -work $work_dir $tb_dir/top_tb.sv

# Start simulation
vsim -l build/sim_transcript -voptargs=+acc $work_dir.top_tb

# Add the wave to the simulation
do scripts/wave.do

# Run all
run -all