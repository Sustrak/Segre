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
    xor x0, x1, x2
    xor x1, x2, x3
    xor x2, x3, x4
    xor x3, x4, x5
    xor x4, x5, x6
    xor x5, x6, x7
    xor x6, x7, x8
    xor x7, x8, x9
    xor x8, x9, x10
    xor x9, x10, x11
    xor x10, x11, x12
    xor x11, x12, x13
    xor x12, x13, x14
    xor x13, x14, x15
    xor x14, x15, x16
    xor x15, x16, x17
    xor x16, x17, x18
    xor x17, x18, x19
    xor x18, x19, x20
    xor x19, x20, x21
    xor x20, x21, x22
    xor x21, x22, x23
    xor x22, x23, x24
    xor x23, x24, x25
    xor x24, x25, x26
    xor x25, x26, x27
    xor x26, x27, x28
    xor x27, x28, x29
    xor x28, x29, x30
    xor x29, x30, x31
    xor x30, x1, x2
    xor x31, x2, x3
