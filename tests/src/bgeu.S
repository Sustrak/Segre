segre_test:
    li x0,  0x0
    li x1,  0x0
    li x2,  0x3
    li x3,  0x2
    li x4,  0x2
    li x5,  0x2
    li x6,  0x4
    li x7,  0x3
    li x8,  0x4
    li x9,  0x4
    li x10, -1
    li x11, -1
    li x12, -1
    li x13, -2
    li x14, -3
    li x15, -3
    li x16, -3
    li x17, -4
    li x18, -5
    li x19, -5
    li x20, -15
    li x21, -14
    li x22, -13
    li x23, -12
    li x24, -11
    li x25, -10
    li x26, -9
    li x27, -8
    li x28, -7
    li x29, -6
    li x30, -5
    li x31, -4

    bgeu zero, x1, b1
    li x1, 0xffffffff
    csrw 0xfff, x0
b1: li x1, 0xbe
    bgeu x2, x3, b2
    li x2, 0xffffffff
    li x3, 0xffffffff
    csrw 0xfff, x0
b2: li x2, 0xbe
    li x3, 0xbe
    bgeu x4, x5, b3
    li x4, 0xffffffff
    li x5, 0xffffffff
    csrw 0xfff, x0
b3: li x4, 0xbe
    li x5, 0xbe
    bgeu x6, x7, b4
    li x6, 0xffffffff
    li x7, 0xffffffff
    csrw 0xfff, x0
b4: li x6, 0xbe
    li x7, 0xbe
    bgeu x8, x9, b5
    li x8, 0xffffffff
    li x9, 0xffffffff
    csrw 0xfff, x0
b5: li x8, 0xbe
    li x9, 0xbe
    bgeu x10, x11, b6
    li x10, 0xffffffff
    li x11, 0xffffffff
    csrw 0xfff, x0
b6: li x10, 0xbe
    li x11, 0xbe
    bgeu x12, x13, b7
    li x12, 0xffffffff
    li x13, 0xffffffff
    csrw 0xfff, x0
b7: li x12, 0xbe
    li x13, 0xbe
    bgeu x14, x15, b8
    li x14, 0xffffffff
    li x15, 0xffffffff
    csrw 0xfff, x0
b8: li x14, 0xbe
    li x15, 0xbe
    bgeu x16, x17, b9
    li x16, 0xffffffff
    li x17, 0xffffffff
    csrw 0xfff, x0
b9: li x16, 0xbe
    li x17, 0xbe
    bgeu x18, x19, b10
    li x18, 0xffffffff
    li x19, 0xffffffff
    csrw 0xfff, x0
b10: li x18, 0xbe
    li x19, 0xbe
    bgeu x20, x21, test_done
    li x20, 0xbe
    li x21, 0xbe
    bgeu x22, x23, test_done
    li x22, 0xbe
    li x23, 0xbe
    bgeu x24, x25, test_done
    li x24, 0xbe
    li x25, 0xbe
    bgeu x26, x27, test_done
    li x26, 0xbe
    li x27, 0xbe
    bgeu x28, x29, test_done
    li x28, 0xbe
    li x29, 0xbe
    bgeu x30, x31, test_done
    li x30, 0xbe
    li x31, 0xbe
