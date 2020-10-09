CC = rustc 
CFLAGS = --crate-type cdylib

.PHONY: clean

all: build
build: decoder.rs
	$(CC) $(CFLAGS) $^
	mv libdecoder.so ../lib
clean:

