.globl _start
.section .text

segre_test:
    la x30, user_stack_start
    lw x1, 4(x30)
    lw x2, 8(x30)
    add x3, x1, x2
    lw x4, 12(x30)
    li x5,  0xffffffff
    li x6,  0xffffffff
    li x7,  0xffffffff
    li x8,  0xffffffff
    li x9,  0xffffffff
    li x10, 0xffffffff
    li x11, 0xffffffff
    li x12, 0xffffffff
    li x13, 0xffffffff
    li x14, 0xffffffff
    li x15, 0xffffffff
    li x16, 0xffffffff
    li x17, 0xffffffff
    li x18, 0xffffffff
    li x19, 0xffffffff
    li x20, 0xffffffff
    li x21, 0xffffffff
    li x22, 0xffffffff
    li x23, 0xffffffff
    li x24, 0xffffffff
    li x25, 0xffffffff
    li x26, 0xffffffff
    li x27, 0xffffffff
    li x28, 0xffffffff
    li x29, 0xffffffff
    li x30, 0xffffffff
    li x31, 0xffffffff