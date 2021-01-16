segre_test:
    li x3, 0xaaaabbbb
    csrrw x2, 0x0, x3
    csrrwi x0, 0x1, 0x1A
