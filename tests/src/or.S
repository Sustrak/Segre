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
    li x16, 0x12345a
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
    or x0, x1, x2
    or x1, x2, x3
    or x2, x3, x4
    or x3, x4, x5
    or x4, x5, x6
    or x5, x6, x7
    or x6, x7, x8
    or x7, x8, x9
    or x8, x9, x10
    or x9, x10, x11
    or x10, x11, x12
    or x11, x12, x13
    or x12, x13, x14
    or x13, x14, x15
    or x14, x15, x16
    or x15, x16, x17
    or x16, x17, x18
    or x17, x18, x19
    or x18, x19, x20
    or x19, x20, x21
    or x20, x21, x22
    or x21, x22, x23
    or x22, x23, x24
    or x23, x24, x25
    or x24, x25, x26
    or x25, x26, x27
    or x26, x27, x28
    or x27, x28, x29
    or x28, x29, x30
    or x29, x30, x31
    or x30, x1, x2
    or x31, x2, x3
