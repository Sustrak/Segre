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
    mulh x0, x1, x2
    mulh x1, x2, x3
    mulh x2, x3, x4
    mulh x3, x4, x5
    mulh x4, x5, x6
    mulh x5, x6, x7
    mulh x6, x7, x8
    mulh x7, x8, x9
    mulh x8, x9, x10
    mulh x9, x10, x11
    mulh x10, x11, x12
    mulh x11, x12, x13
    mulh x12, x13, x14
    mulh x13, x14, x15
    mulh x14, x15, x16
    mulh x15, x16, x17
    mulh x16, x17, x18
    mulh x17, x18, x19
    mulh x18, x19, x20
    mulh x19, x20, x21
    mulh x20, x21, x22
    mulh x21, x22, x23
    mulh x22, x23, x24
    mulh x23, x24, x25
    mulh x24, x25, x26
    mulh x25, x26, x27
    mulh x26, x27, x28
    mulh x27, x28, x29
    mulh x28, x29, x30
    mulh x29, x30, x31
    mulh x30, x1, x2
    mulh x31, x2, x3
