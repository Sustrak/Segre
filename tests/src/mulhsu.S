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
    mulhsu x0, x1, x2
    mulhsu x1, x2, x3
    mulhsu x2, x3, x4
    mulhsu x3, x4, x5
    mulhsu x4, x5, x6
    mulhsu x5, x6, x7
    mulhsu x6, x7, x8
    mulhsu x7, x8, x9
    mulhsu x8, x9, x10
    mulhsu x9, x10, x11
    mulhsu x10, x11, x12
    mulhsu x11, x12, x13
    mulhsu x12, x13, x14
    mulhsu x13, x14, x15
    mulhsu x14, x15, x16
    mulhsu x15, x16, x17
    mulhsu x16, x17, x18
    mulhsu x17, x18, x19
    mulhsu x18, x19, x20
    mulhsu x19, x20, x21
    mulhsu x20, x21, x22
    mulhsu x21, x22, x23
    mulhsu x22, x23, x24
    mulhsu x23, x24, x25
    mulhsu x24, x25, x26
    mulhsu x25, x26, x27
    mulhsu x26, x27, x28
    mulhsu x27, x28, x29
    mulhsu x28, x29, x30
    mulhsu x29, x30, x31
    mulhsu x30, x1, x2
    mulhsu x31, x2, x3
