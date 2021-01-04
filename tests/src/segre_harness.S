.globl _start
.section .text
_start:
main:
    .include "segre_test.S"
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

test_done:
    csrw 0xfff, x0

.section .data

user_stack_start:
.word 0xfafafafa
.word 0xfafafafa
.word 0xfafafafa
.word 0xfafafafa
.word 0xfafafafa
.word 0x5a5a5a5a
.word 0x5a5a5a5a
.word 0x5a5a5a5a
.word 0x5a5a5a5a
.word 0x5a5a5a5a
.word 0xfafafafa
.word 0xfafafafa
.word 0xfafafafa
.word 0xfafafafa
.word 0xfafafafa
.word 0x5a5a5a5a
.word 0x5a5a5a5a
.word 0x5a5a5a5a
.word 0x5a5a5a5a
.word 0x5a5a5a5a
.rept 4979
.4byte 0x0
.endr
user_stack_end:
.4byte 0x0
.align 2

