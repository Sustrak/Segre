CC = rustc 
CFLAGS = --crate-type dylib

.PHONY: clean

all: build
build: decoder.rs
	$(CC) $(CFLAGS) $^
	mv libdecoder.so ../lib
clean:

