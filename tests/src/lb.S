segre_test:
    li x1,  0x00000000
    li x2,  0x00000000
    li x3,  0x00000000
    li x4,  0x00000000
    li x5,  0x00000000
    li x6,  0x00000000
    li x7,  0x00000000
    li x8,  0x00000000
    li x9,  0x00000000
    li x10, 0x00000000
    li x11, 0x00000000
    li x12, 0x00000000
    li x13, 0x00000000
    li x14, 0x00000000
    li x15, 0x00000000
    li x17, 0x00000000
    li x18, 0x00000000
    li x19, 0x00000000
    li x20, 0x00000000
    li x21, 0x00000000
    li x22, 0x00000000
    li x23, 0x00000000
    li x24, 0x00000000
    li x25, 0x00000000
    li x26, 0x00000000
    li x27, 0x00000000
    li x28, 0x00000000
    li x29, 0x00000000
    li x30, 0x00000000
    li x31, 0x00000000
    la x30, test_data
    lb x0, 0(x30)
    lb x1, 0(x30)

.data
    .align 2 # Byte
test_data:
    .half 0x00
    .half 0x20
    .half 0x40
    .half 0x60
    .word 0xcaca
    .word 0xbeef

