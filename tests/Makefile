mkfile_path = $(abspath $(lastword $(MAKEFILE_LIST)))

TARGET = riscv64-unknown-elf

AS = $(TARGET)-as
OBJD = $(TARGET)-objdump

TEST_SRC = $(wildcard src/*.S)
TEST_OBJ = $(patsubst src/%.S, build/%.o, $(TEST_SRC))
TEST_HEX = $(patsubst build/%.o, hex/%.hex, $(TEST_OBJ))

.PHONY: clean
all: build_dirs build gen_hex

build_dirs:
	mkdir -p build
	mkdir -p hex

build: $(TEST_OBJ)
gen_hex: $(TEST_HEX)

build/%.o: src/%.S
	$(AS) $^ -o $@

hex/%.hex: build/%.o
	$(OBJD) -d $^ | grep -E "[a-f0-9]+:" | awk '{print $$2}' > $@;

clean:
	rm -rf build hex
