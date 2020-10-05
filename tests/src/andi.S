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
    andi x0, x1, 0x7ff
    andi x1, x2, 0x7ff
    andi x2, x3, 0x777
    andi x3, x4, 0x555
    andi x4, x5, 0x333
    andi x5, x6, 0x111
    andi x6, x7, 0x666
    andi x7, x8, 0x444
    andi x8, x9, 0x222
    andi x9, x10, 0x000
    andi x10, x11, 0x123
    andi x11, x12, 0x234
    andi x12, x13, 0x345
    andi x13, x14, 0x456
    andi x14, x15, 0x567
    andi x15, x16, 0x678
    andi x16, x17, 0x789
    andi x17, x18, 0x678
    andi x18, x19, 0x567
    andi x19, x20, 0x456
    andi x20, x21, 0x345
    andi x21, x22, 0x234
    andi x22, x23, 0x123
    andi x23, x24, 0x000
    andi x24, x25, 0x757
    andi x25, x26, 0x575
    andi x26, x27, 0xa
    andi x27, x28, 0xb
    andi x28, x29, 0xc
    andi x29, x30, 0xe
    andi x30, x1, 0xf
    andi x31, x2, 0x1
