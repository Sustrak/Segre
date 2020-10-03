.globl _start
.section .text
_start:
main:
    .include "segre_test.S"

test_done:
    csrw 0xfff, x0
