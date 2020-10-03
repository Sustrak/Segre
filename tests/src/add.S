segre_test:
    li x0,  0x123456
    li x1,  0x234567
    li x2,  0x345678
    li x3,  0x456790
    li x4,  0x56789a
    li x5,  0x6789ab
    li x6,  0x789abc
    li x7,  0x89abcd
    li x8,  0x9abcde
    li x9,  0xabcdef
    li x10, 0x1abcde
    li x11, 0x12abcd
    li x12, 0x123abc
    li x13, 0x1234ab
    li x14, 0x12345a
    li x15, 0x123456
    li x17, 0x123456
    li x18, 0x234567
    li x19, 0x345678
    li x20, 0x456790
    li x21, 0x56789a
    li x22, 0x6789ab
    li x23, 0x789abc
    li x24, 0x89abcd
    li x25, 0x9abcde
    li x26, 0xabcdef
    li x27, 0x1abcde
    li x28, 0x12abcd
    li x29, 0x123abc
    li x30, 0x8234ab
    li x31, 0x82345a
    add x0, x1, x2
    add x1, x2, x3
    add x2, x3, x4
    add x3, x4, x5
    add x4, x5, x6
    add x5, x6, x7
    add x6, x7, x8
    add x7, x8, x9
    add x8, x9, x10
    add x9, x10, x11
    add x10, x11, x12
    add x11, x12, x13
    add x12, x13, x14
    add x13, x14, x15
    add x14, x15, x16
    add x15, x16, x17
    add x16, x17, x18
    add x17, x18, x19
    add x18, x19, x20
    add x19, x20, x21
    add x20, x21, x22
    add x21, x22, x23
    add x22, x23, x24
    add x23, x24, x25
    add x24, x25, x26
    add x25, x26, x27
    add x26, x27, x28
    add x27, x28, x29
    add x28, x29, x30
    add x29, x30, x31
    add x30, x1, x2
    add x31, x2, x3
