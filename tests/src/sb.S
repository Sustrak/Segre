.globl _start
.section .text

segre_test:
    li x1,  0xcacacaca
    li x2,  0xdeadbeef
    li x3,  0x5a5a5a5a
    li x4,  0xcacacaca
    li x5,  0xdeadbeef
    li x6,  0x5a5a5a5a
    li x7,  0xcacacaca
    li x8,  0xdeadbeef
    li x9,  0x5a5a5a5a
    li x10, 0xcacacaca
    li x11, 0xdeadbeef
    li x12, 0x5a5a5a5a
    li x13, 0xcacacaca
    li x14, 0xdeadbeef
    li x15, 0x5a5a5a5a
    li x16, 0xcacacaca
    li x17, 0xdeadbeef
    li x18, 0x5a5a5a5a
    li x19, 0xcacacaca
    li x20, 0xdeadbeef
    li x21, 0x5a5a5a5a
    li x22, 0xcacacaca
    li x23, 0xdeadbeef
    li x24, 0x5a5a5a5a
    li x25, 0xcacacaca
    li x26, 0xdeadbeef
    li x27, 0x5a5a5a5a
    li x28, 0xcacacaca
    li x29, 0xdeadbeef
    la x30, user_stack_start
    sb x0, 0(x30)
    sb x1, 1(x30)
    sb x2, 2(x30)
    sb x3, 3(x30)
    sb x4, 4(x30)
    sb x5, 5(x30)
    sb x6, 6(x30)
    sb x7, 7(x30)
    sb x8, 8(x30)
    sb x9, 9(x30)
    sb x10, 10(x30)
    sb x11, 11(x30)
    sb x12, 12(x30)
    sb x13, 13(x30)
    sb x14, 14(x30)
    sb x15, 15(x30)
    sb x16, 16(x30)
    sb x17, 17(x30)
    sb x18, 18(x30)
    sb x19, 19(x30)
    sb x20, 20(x30)
    sb x21, 21(x30)
    sb x22, 22(x30)
    sb x23, 23(x30)
    sb x24, 24(x30)
    sb x25, 25(x30)
    sb x26, 26(x30)
    sb x27, 27(x30)
    sb x28, 28(x30)
    sb x29, 29(x30)
    lb x0, 0(x30)
    lb x1, 1(x30)
    lb x2, 2(x30)
    lb x3, 3(x30)
    lb x4, 4(x30)
    lb x5, 5(x30)
    lb x6, 6(x30)
    lb x7, 7(x30)
    lb x8, 8(x30)
    lb x9, 9(x30)
    lb x10, 10(x30)
    lb x11, 11(x30)
    lb x12, 12(x30)
    lb x13, 13(x30)
    lb x14, 14(x30)
    lb x15, 15(x30)
    lb x16, 16(x30)
    lb x17, 17(x30)
    lb x18, 18(x30)
    lb x19, 19(x30)
    lb x20, 20(x30)
    lb x21, 21(x30)
    lb x22, 22(x30)
    lb x23, 23(x30)
    lb x24, 24(x30)
    lb x25, 25(x30)
    lb x26, 26(x30)
    lb x27, 27(x30)
    lb x28, 28(x30)
    lb x29, 29(x30)
    li x30, 0xffffffff
    li x31, 0xffffffff
