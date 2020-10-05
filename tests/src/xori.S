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
    li x16, 0x123456
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
    xori x0, x1, 0x7ff
    xori x1, x2, 0x7ff
    xori x2, x3, 0x777
    xori x3, x4, 0x555
    xori x4, x5, 0x333
    xori x5, x6, 0x111
    xori x6, x7, 0x666
    xori x7, x8, 0x444
    xori x8, x9, 0x222
    xori x9, x10, 0x000
    xori x10, x11, 0x123
    xori x11, x12, 0x234
    xori x12, x13, 0x345
    xori x13, x14, 0x456
    xori x14, x15, 0x567
    xori x15, x16, 0x678
    xori x16, x17, 0x789
    xori x17, x18, 0x678
    xori x18, x19, 0x567
    xori x19, x20, 0x456
    xori x20, x21, 0x345
    xori x21, x22, 0x234
    xori x22, x23, 0x123
    xori x23, x24, 0x000
    xori x24, x25, 0x757
    xori x25, x26, 0x575
    xori x26, x27, 0xa
    xori x27, x28, 0xb
    xori x28, x29, 0xc
    xori x29, x30, 0xe
    xori x30, x1, 0xf
    xori x31, x2, 0x1
