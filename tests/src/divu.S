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
    divu x0, x1, x2
    divu x1, x2, x3
    divu x2, x3, x4
    divu x3, x4, x5
    divu x4, x5, x6
    divu x5, x6, x7
    divu x6, x7, x8
    divu x7, x8, x9
    divu x8, x9, x10
    divu x9, x10, x11
    divu x10, x11, x12
    divu x11, x12, x13
    divu x12, x13, x14
    divu x13, x14, x15
    divu x14, x15, x16
    divu x15, x16, x17
    divu x16, x17, x18
    divu x17, x18, x19
    divu x18, x19, x20
    divu x19, x20, x21
    divu x20, x21, x22
    divu x21, x22, x23
    divu x22, x23, x24
    divu x23, x24, x25
    divu x24, x25, x26
    divu x25, x26, x27
    divu x26, x27, x28
    divu x27, x28, x29
    divu x28, x29, x30
    divu x29, x30, x31
    divu x30, x1, x2
    divu x31, x2, x3
