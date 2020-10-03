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
    li x30, 0x1234ab
    li x31, 0x12345a
    and x0, x1, x2
    and x1, x2, x3
    and x2, x3, x4
    and x3, x4, x5
    and x4, x5, x6
    and x5, x6, x7
    and x6, x7, x8
    and x7, x8, x9
    and x8, x9, x10
    and x9, x10, x11
    and x10, x11, x12
    and x11, x12, x13
    and x12, x13, x14
    and x13, x14, x15
    and x14, x15, x16
    and x15, x16, x17
    and x16, x17, x18
    and x17, x18, x19
    and x18, x19, x20
    and x19, x20, x21
    and x20, x21, x22
    and x21, x22, x23
    and x22, x23, x24
    and x23, x24, x25
    and x24, x25, x26
    and x25, x26, x27
    and x26, x27, x28
    and x27, x28, x29
    and x28, x29, x30
    and x29, x30, x31
    and x30, x1, x2
    and x31, x2, x3
