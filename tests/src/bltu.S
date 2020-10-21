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
    li x10, -2
    li x11, -1
    li x12, -4
    li x13, -3
    li x14, -6
    li x15, -5
    li x16, -8
    li x17, -7
    li x18, -10
    li x19, -9
    li x20, -4
    li x21, -5
    li x22, -6
    li x23, -7
    li x24, -8
    li x25, -9
    li x26, -10
    li x27, -11
    li x28, -12
    li x29, -13
    li x30, -14
    li x31, -15

    bltu zero, x1, b1
    li x1, 0xffffffff
    csrw 0xfff, x0
b1: li x1, 0xbe
    bltu x2, x3, b2
    li x2, 0xffffffff
    li x3, 0xffffffff
    csrw 0xfff, x0
b2: li x2, 0xbe
    li x3, 0xbe
    bltu x4, x5, b3
    li x4, 0xffffffff
    li x5, 0xffffffff
    csrw 0xfff, x0
b3: li x4, 0xbe
    li x5, 0xbe
    bltu x6, x7, b4
    li x6, 0xffffffff
    li x7, 0xffffffff
    csrw 0xfff, x0
b4: li x6, 0xbe
    li x7, 0xbe
    bltu x8, x9, b5
    li x8, 0xffffffff
    li x9, 0xffffffff
    csrw 0xfff, x0
b5: li x8, 0xbe
    li x9, 0xbe
    bltu x10, x11, b6
    li x10, 0xffffffff
    li x11, 0xffffffff
    csrw 0xfff, x0
b6: li x10, 0xbe
    li x11, 0xbe
    bltu x12, x13, b7
    li x12, 0xffffffff
    li x13, 0xffffffff
    csrw 0xfff, x0
b7: li x12, 0xbe
    li x13, 0xbe
    bltu x14, x15, b8
    li x14, 0xffffffff
    li x15, 0xffffffff
    csrw 0xfff, x0
b8: li x14, 0xbe
    li x15, 0xbe
    bltu x16, x17, b9
    li x16, 0xffffffff
    li x17, 0xffffffff
    csrw 0xfff, x0
b9: li x16, 0xbe
    li x17, 0xbe
    bltu x18, x19, b10
    li x18, 0xffffffff
    li x19, 0xffffffff
    csrw 0xfff, x0
b10: li x18, 0xbe
    li x19, 0xbe
    bltu x20, x21, test_done
    li x20, 0xbe
    li x21, 0xbe
    bltu x22, x23, test_done
    li x22, 0xbe
    li x23, 0xbe
    bltu x24, x25, test_done
    li x24, 0xbe
    li x25, 0xbe
    bltu x26, x27, test_done
    li x26, 0xbe
    li x27, 0xbe
    bltu x28, x29, test_done
    li x28, 0xbe
    li x29, 0xbe
    bltu x30, x31, test_done
    li x30, 0xbe
    li x31, 0xbe
