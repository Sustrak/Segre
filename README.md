### Welcom to Segre's repository

A RISC-V 32 bit processor

#### Dependences
 - [Spike](https://github.com/riscv/riscv-isa-sim) Isa simulator to get the golden results for tests. Has to be located at same level as segre's folder.
   - Compile spike with `--enable-commitlog` and `--with-isa=rv32im`
 - Modelsim/Questasim

#### Tests
All tests are located in `tests/` folder and they are the main interface between RTL and the testbench. Test sources are located in `tests/src` and listed in `tests/src/testlist` this is where test's Makefile gets the name of its sources.

Once the Makefile it's executed it will produce the following outputs:
 - **hex_segre**: Hexdump of the instructions for testbench to load them into tb's memory
 - **build_segre**: Binaries for segre execution
 - **build_spike**: Binaries for spike execution
 - **result_segre**: Golden results for each test, extracted from spike
 
 Creating new test is as easy as, writting the main of the program in `tests/src/` and do a `make` in `tests/` folder.
 
 ##### Running tests
 In order to run a test we must run the following command:
 
 `vsim -do "do scripts/tcl/compile.tcl <name_of_the_test> <use_modelsim>"`
 
 Use `-c` to run vsim in CLI mode.
 
 The testbench will run all the test and check the results automatically.
