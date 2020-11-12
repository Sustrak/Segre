# USAGE #

# ARGS #
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
vlog -sv -work $work_dir -F $rtl_dir/cache_subsystem/filelist.f

# Compile tb
vlog -sv -work $work_dir $tb_dir/cache_subsystem_tb.sv

# Start simulation
vsim -dpicpppath /usr/bin/gcc -l build/sim_transcript -voptargs=+acc $work_dir.cache_subsystem_tb
