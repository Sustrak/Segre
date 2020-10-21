segre_test:
    li x0,  0x0
    li x1,  0x1
    li x2,  0x2
    li x3,  0x3
    li x4,  0x4
    li x5,  0x5
    li x6,  0x6
    li x7,  0x7
    li x8,  0x8
    li x9,  0x9
    li x10, -1
    li x11, 0
    li x12, -2
    li x13, -1
    li x14, -3
    li x15, -2
    li x16, -4
    li x17, -3
    li x18, -5
    li x19, -4
    li x20, 0xf0000000
    li x21, 0xf0000000
    li x22, 0xd0000000
    li x23, 0xd0000000
    li x24, 0xc0000000
    li x25, 0xc0000000
    li x26, 0xb0000000
    li x27, 0xb0000000
    li x28, 0xa0000000
    li x29, 0xa0000000
    li x30, 0x0
    li x31, 0x0

    bne zero, x1, b1
    li x1, 0xffffffff
    csrw 0xfff, x0
b1: li x1, 0xbe
    bne x2, x3, b2
    li x2, 0xffffffff
    li x3, 0xffffffff
    csrw 0xfff, x0
b2: li x2, 0xbe
    li x3, 0xbe
    bne x4, x5, b3
    li x4, 0xffffffff
    li x5, 0xffffffff
    csrw 0xfff, x0
b3: li x4, 0xbe
    li x5, 0xbe
    bne x6, x7, b4
    li x6, 0xffffffff
    li x7, 0xffffffff
    csrw 0xfff, x0
b4: li x6, 0xbe
    li x7, 0xbe
    bne x8, x9, b5
    li x8, 0xffffffff
    li x9, 0xffffffff
    csrw 0xfff, x0
b5: li x8, 0xbe
    li x9, 0xbe
    bne x10, x11, b6
    li x10, 0xffffffff
    li x11, 0xffffffff
    csrw 0xfff, x0
b6: li x10, 0xbe
    li x11, 0xbe
    bne x12, x13, b7
    li x12, 0xffffffff
    li x13, 0xffffffff
    csrw 0xfff, x0
b7: li x12, 0xbe
    li x13, 0xbe
    bne x14, x15, b8
    li x14, 0xffffffff
    li x15, 0xffffffff
    csrw 0xfff, x0
b8: li x14, 0xbe
    li x15, 0xbe
    bne x16, x17, b9
    li x16, 0xffffffff
    li x17, 0xffffffff
    csrw 0xfff, x0
b9: li x16, 0xbe
    li x17, 0xbe
    bne x18, x19, b10
    li x18, 0xffffffff
    li x19, 0xffffffff
    csrw 0xfff, x0
b10: li x18, 0xbe
    li x19, 0xbe
    bne x20, x21, test_done
    li x20, 0xbe
    li x21, 0xbe
    bne x22, x23, test_done
    li x22, 0xbe
    li x23, 0xbe
    bne x24, x25, test_done
    li x24, 0xbe
    li x25, 0xbe
    bne x26, x27, test_done
    li x26, 0xbe
    li x27, 0xbe
    bne x28, x29, test_done
    li x28, 0xbe
    li x29, 0xbe
    bne x30, x31, test_done
    li x30, 0xbe
    li x31, 0xbe
