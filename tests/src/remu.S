segre_test:
    li x0,  0x123456
    li x1,  0x234567
    li x2,  -42
    li x3,  0x456790
    li x4,  -64
    li x5,  0x6789ab
    li x6,  -120
    li x7,  0x89abcd
    li x8,  -248
    li x9,  0xabcdef
    li x10, -340
    li x11, 0x12abcd
    li x12, -4312
    li x13, 0x1234ab
    li x14, -3123
    li x15, 0x123456
    li x16, -22331
    li x17, 0x123456
    li x18, -99
    li x19, 0x345678
    li x20, -123
    li x21, 0x56789a
    li x22, -33221
    li x23, 0x789abc
    li x24, -4455
    li x25, 0x9abcde
    li x26, -2231
    li x27, 0x1abcde
    li x28, -1234
    li x29, 0x123abc
    li x30, -77915
    li x31, 0x82345a
    remu x0, x1, x2
    remu x1, x2, x3
    remu x2, x3, x4
    remu x3, x4, x5
    remu x4, x5, x6
    remu x5, x6, x7
    remu x6, x7, x8
    remu x7, x8, x9
    remu x8, x9, x10
    remu x9, x10, x11
    remu x10, x11, x12
    remu x11, x12, x13
    remu x12, x13, x14
    remu x13, x14, x15
    remu x14, x15, x16
    remu x15, x16, x17
    remu x16, x17, x18
    remu x17, x18, x19
    remu x18, x19, x20
    remu x19, x20, x21
    remu x20, x21, x22
    remu x21, x22, x23
    remu x22, x23, x24
    remu x23, x24, x25
    remu x24, x25, x26
    remu x25, x26, x27
    remu x26, x27, x28
    remu x27, x28, x29
    remu x28, x29, x30
    remu x29, x30, x31
    remu x30, x1, x2
    remu x31, x2, x3
