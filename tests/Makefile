mkfile_path = $(abspath $(lastword $(MAKEFILE_LIST)))

TARGET = riscv64-unknown-elf

AS = $(TARGET)-as
GCC = $(TARGET)-gcc
SPIKE = ../../riscv-isa-sim/build/spike --log-commits --isa rv32im
CFLAGS_SPIKE = -O0 -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles -march=rv32im -mabi=ilp32 -Tlink.ld -Isrc/
CFLAGS_SEGRE = -O3 -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles -march=rv32im -mabi=ilp32 -Tsegre_link.ld -Isrc/
ASFLAGS = -march=rv32i -mabi=ilp32
OBJD = $(TARGET)-objdump

TEST_SRC = $(shell cat src/testlist)
TEST_OBJ_SEGRE = $(patsubst %.S, build_segre/%.o, $(TEST_SRC))
TEST_OBJ_SPIKE = $(patsubst %.S, build_spike/%.o, $(TEST_SRC))
TEST_HEX_SEGRE = $(patsubst build_segre/%.o, hex_segre/%.hex, $(TEST_OBJ_SEGRE))
TEST_RES_SPIKE = $(patsubst build_spike/%.o, result_segre/%.result, $(TEST_OBJ_SPIKE))

.PHONY: clean
all: build_dirs build gen_hex gen_results 

build_dirs:
	mkdir -p build_segre
	mkdir -p build_spike
	mkdir -p hex_segre
	mkdir -p result_segre

build: build_dirs $(TEST_OBJ_SEGRE) $(TEST_OBJ_SPIKE)
gen_hex: build_dirs $(TEST_HEX_SEGRE)
gen_results: build_dirs $(TEST_RES_SPIKE)

build_segre/%.o: src/%.S
	cp $^ segre_test.S
	$(GCC) $(CFLAGS_SEGRE) src/segre_harness.S -o $@
	rm segre_test.S

build_spike/%.o: src/%.S
	cp $^ segre_test.S
	$(GCC) $(CFLAGS_SPIKE) src/spike_harness.S -o $@
	rm segre_test.S

hex_segre/%.hex: build_segre/%.o
	$(OBJD) -d $^ | grep -E "[a-f0-9]+:" | awk '{print $$2}' > $@;

result_segre/%.result: build_spike/%.o
	rm -rf $@
	$(SPIKE) $^ 2> tmp.result
	echo 0 >> $@
	cat tmp.result | grep -w "x 1" | tail -n 1 | sed -e 's/x 1/x1/g' | awk '{print $$7}' | cut -c 3-11 | xargs -I {} echo {} >> $@
	cat tmp.result | grep -w "x 2" | tail -n 1 | sed -e 's/x 2/x1/g' | awk '{print $$7}' | cut -c 3-11 | xargs -I {} echo {} >> $@
	cat tmp.result | grep -w "x 3" | tail -n 2 | head -n 1 | sed -e 's/x 3/x1/g' | awk '{print $$7}' | cut -c 3-11 | xargs -I {} echo {} >> $@
	cat tmp.result | grep -w "x 4" | tail -n 1 | sed -e 's/x 4/x1/g' | awk '{print $$7}' | cut -c 3-11 | xargs -I {} echo {} >> $@
	cat tmp.result | grep -w "x 5" | tail -n 1 | sed -e 's/x 5/x1/g' | awk '{print $$7}' | cut -c 3-11 | xargs -I {} echo {} >> $@
	cat tmp.result | grep -w "x 6" | tail -n 1 | sed -e 's/x 6/x1/g' | awk '{print $$7}' | cut -c 3-11 | xargs -I {} echo {} >> $@
	cat tmp.result | grep -w "x 7" | tail -n 1 | sed -e 's/x 7/x1/g' | awk '{print $$7}' | cut -c 3-11 | xargs -I {} echo {} >> $@
	cat tmp.result | grep -w "x 8" | tail -n 1 | sed -e 's/x 8/x1/g' | awk '{print $$7}' | cut -c 3-11 | xargs -I {} echo {} >> $@
	cat tmp.result | grep -w "x 9" | tail -n 1 | sed -e 's/x 9/x1/g' | awk '{print $$7}' | cut -c 3-11 | xargs -I {} echo {} >> $@
	cat tmp.result | grep -w "x10" | tail -n 1 | awk '{print $$7}' | cut -c 3-11 | xargs -I {} echo {} >> $@
	cat tmp.result | grep -w "x11" | tail -n 1 | awk '{print $$7}' | cut -c 3-11 | xargs -I {} echo {} >> $@
	cat tmp.result | grep -w "x12" | tail -n 1 | awk '{print $$7}' | cut -c 3-11 | xargs -I {} echo {} >> $@
	cat tmp.result | grep -w "x13" | tail -n 1 | awk '{print $$7}' | cut -c 3-11 | xargs -I {} echo {} >> $@
	cat tmp.result | grep -w "x14" | tail -n 1 | awk '{print $$7}' | cut -c 3-11 | xargs -I {} echo {} >> $@
	cat tmp.result | grep -w "x15" | tail -n 1 | awk '{print $$7}' | cut -c 3-11 | xargs -I {} echo {} >> $@
	cat tmp.result | grep -w "x16" | tail -n 1 | awk '{print $$7}' | cut -c 3-11 | xargs -I {} echo {} >> $@
	cat tmp.result | grep -w "x17" | tail -n 1 | awk '{print $$7}' | cut -c 3-11 | xargs -I {} echo {} >> $@
	cat tmp.result | grep -w "x18" | tail -n 1 | awk '{print $$7}' | cut -c 3-11 | xargs -I {} echo {} >> $@
	cat tmp.result | grep -w "x19" | tail -n 1 | awk '{print $$7}' | cut -c 3-11 | xargs -I {} echo {} >> $@
	cat tmp.result | grep -w "x20" | tail -n 1 | awk '{print $$7}' | cut -c 3-11 | xargs -I {} echo {} >> $@
	cat tmp.result | grep -w "x21" | tail -n 1 | awk '{print $$7}' | cut -c 3-11 | xargs -I {} echo {} >> $@
	cat tmp.result | grep -w "x22" | tail -n 1 | awk '{print $$7}' | cut -c 3-11 | xargs -I {} echo {} >> $@
	cat tmp.result | grep -w "x23" | tail -n 1 | awk '{print $$7}' | cut -c 3-11 | xargs -I {} echo {} >> $@
	cat tmp.result | grep -w "x24" | tail -n 1 | awk '{print $$7}' | cut -c 3-11 | xargs -I {} echo {} >> $@
	cat tmp.result | grep -w "x25" | tail -n 1 | awk '{print $$7}' | cut -c 3-11 | xargs -I {} echo {} >> $@
	cat tmp.result | grep -w "x26" | tail -n 1 | awk '{print $$7}' | cut -c 3-11 | xargs -I {} echo {} >> $@
	cat tmp.result | grep -w "x27" | tail -n 1 | awk '{print $$7}' | cut -c 3-11 | xargs -I {} echo {} >> $@
	cat tmp.result | grep -w "x28" | tail -n 1 | awk '{print $$7}' | cut -c 3-11 | xargs -I {} echo {} >> $@
	cat tmp.result | grep -w "x29" | tail -n 1 | awk '{print $$7}' | cut -c 3-11 | xargs -I {} echo {} >> $@
	cat tmp.result | grep -w "x30" | tail -n 2 | head -n 1 | awk '{print $$7}' | cut -c 3-11 | xargs -I {} echo {} >> $@
	cat tmp.result | grep -w "x31" | tail -n 1 | awk '{print $$7}' | cut -c 3-11 | xargs -I {} echo {} >> $@
	rm tmp.result

buffer_sum: src/buffer_sum/buffer_sum.c
	$(GCC) $(CFLAGS_SEGRE) $^ -o build_segre/buffer_sum.o
	$(OBJD) -d build_segre/buffer_sum.o | grep -E "[a-f0-9]+:" | awk '{print $$2}' > hex_segre/buffer_sum.hex;

mem_copy: src/mem_copy/mem_copy.c
	$(GCC) $(CFLAGS_SEGRE) $^ -o build_segre/mem_copy.o
	$(OBJD) -d build_segre/mem_copy.o | grep -E "[a-f0-9]+:" | awk '{print $$2}' > hex_segre/mem_copy.hex
	
matrix_multiply: src/matrix_multiply/matrix_multiply.c
	$(GCC) $(CFLAGS_SEGRE) $^ -o build_segre/matrix_multiply.o
	$(OBJD) -d build_segre/matrix_multiply.o | grep -E "[a-f0-9]+:" | awk '{print $$2}' > hex_segre/matrix_multiply.hex

clean:
	rm -rf hex_segre build_spike build_segre result_segre
