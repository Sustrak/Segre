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
    mulhu x0, x1, x2
    mulhu x1, x2, x3
    mulhu x2, x3, x4
    mulhu x3, x4, x5
    mulhu x4, x5, x6
    mulhu x5, x6, x7
    mulhu x6, x7, x8
    mulhu x7, x8, x9
    mulhu x8, x9, x10
    mulhu x9, x10, x11
    mulhu x10, x11, x12
    mulhu x11, x12, x13
    mulhu x12, x13, x14
    mulhu x13, x14, x15
    mulhu x14, x15, x16
    mulhu x15, x16, x17
    mulhu x16, x17, x18
    mulhu x17, x18, x19
    mulhu x18, x19, x20
    mulhu x19, x20, x21
    mulhu x20, x21, x22
    mulhu x21, x22, x23
    mulhu x22, x23, x24
    mulhu x23, x24, x25
    mulhu x24, x25, x26
    mulhu x25, x26, x27
    mulhu x26, x27, x28
    mulhu x27, x28, x29
    mulhu x28, x29, x30
    mulhu x29, x30, x31
    mulhu x30, x1, x2
    mulhu x31, x2, x3
