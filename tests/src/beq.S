segre_test:
    li x0,  0x0
    li x1,  0x0
    li x2,  0x1
    li x3,  0x1
    li x4,  0x2
    li x5,  0x2
    li x6,  0x3
    li x7,  0x3
    li x8,  0x4
    li x9,  0x4
    li x10, -1
    li x11, -1
    li x12, -2
    li x13, -2
    li x14, -3
    li x15, -3
    li x16, -4
    li x17, -4
    li x18, -5
    li x19, -5
    li x20, 0xf0000000
    li x21, 0xe0000000
    li x22, 0xd0000000
    li x23, 0xc0000000
    li x24, 0xb0000000
    li x25, 0xa0000000
    li x26, 0x90000000
    li x27, 0x80000000
    li x28, 0x70000000
    li x29, 0x60000000
    li x30, 0x50000000
    li x31, 0x0

    beq zero, x1, b1
    li x1, 0xffffffff
    csrw 0xfff, x0
b1: li x1, 0xbe
    beq x2, x3, b2
    li x2, 0xffffffff
    li x3, 0xffffffff
    csrw 0xfff, x0
b2: li x2, 0xbe
    li x3, 0xbe
    beq x4, x5, b3
    li x4, 0xffffffff
    li x5, 0xffffffff
    csrw 0xfff, x0
b3: li x4, 0xbe
    li x5, 0xbe
    beq x6, x7, b4
    li x6, 0xffffffff
    li x7, 0xffffffff
    csrw 0xfff, x0
b4: li x6, 0xbe
    li x7, 0xbe
    beq x8, x9, b5
    li x8, 0xffffffff
    li x9, 0xffffffff
    csrw 0xfff, x0
b5: li x8, 0xbe
    li x9, 0xbe
    beq x10, x11, b6
    li x10, 0xffffffff
    li x11, 0xffffffff
    csrw 0xfff, x0
b6: li x10, 0xbe
    li x11, 0xbe
    beq x12, x13, b7
    li x12, 0xffffffff
    li x13, 0xffffffff
    csrw 0xfff, x0
b7: li x12, 0xbe
    li x13, 0xbe
    beq x14, x15, b8
    li x14, 0xffffffff
    li x15, 0xffffffff
    csrw 0xfff, x0
b8: li x14, 0xbe
    li x15, 0xbe
    beq x16, x17, b9
    li x16, 0xffffffff
    li x17, 0xffffffff
    csrw 0xfff, x0
b9: li x16, 0xbe
    li x17, 0xbe
    beq x18, x19, b10
    li x18, 0xffffffff
    li x19, 0xffffffff
    csrw 0xfff, x0
b10: li x18, 0xbe
    li x19, 0xbe
    beq x20, x21, test_done
    li x20, 0xbe
    li x21, 0xbe
    beq x22, x23, test_done
    li x22, 0xbe
    li x23, 0xbe
    beq x24, x25, test_done
    li x24, 0xbe
    li x25, 0xbe
    beq x26, x27, test_done
    li x26, 0xbe
    li x27, 0xbe
    beq x28, x29, test_done
    li x28, 0xbe
    li x29, 0xbe
    beq x30, x31, test_done
    li x30, 0xbe
    li x31, 0xbe
