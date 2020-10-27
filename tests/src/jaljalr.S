segre_test:
    jal x1, jmp_1
    li x1, 0xcacacaca
    jalr x30, x30
jmp_1:
    jal x2, jmp_2
    li x2, 0xcacacaca
    jalr x29, x29
jmp_2:
    jal x3, jmp_3
    li x3, 0xcacacaca
    jalr x28, x28
jmp_3:
    jal x4, jmp_4
    li x4, 0xcacacaca
    jalr x27, x27
jmp_4:
    jal x5, jmp_5
    li x5, 0xcacacaca
    jalr x26, x26
jmp_5:
    jal x6, jmp_6
    li x6, 0xcacacaca
    jalr x25, x25
jmp_6:
    jal x7, jmp_7
    li x7, 0xcacacaca
    jalr x24, x24
jmp_7:
    jal x8, jmp_8
    li x8, 0xcacacaca
    jalr x23, x23
jmp_8:
    jal x9, jmp_9
    li x9, 0xcacacaca
    jalr x22, x22
jmp_9:
    jal x10, jmp_10
    li x10, 0xcacacaca
    jalr x21, x21
jmp_10:
    jal x11, jmp_11
    li x11, 0xcacacaca
    jalr x20, x20
jmp_11:
    jal x12, jmp_12
    li x12, 0xcacacaca
    jalr x19, x19
jmp_12:
    jal x13, jmp_13
    li x13, 0xcacacaca
    jalr x18, x18
jmp_13:
    jal x14, jmp_14
    li x14, 0xcacacaca
    jalr x17, x17
jmp_14:
    jal x15, jmp_15
    li x15, 0xcacacaca
    jalr x16, x16
jmp_15:
    jal x16, jmp_16
    li x16, 0xcacacaca
    jal x31, jmp_31
jmp_16:
    jal x17, jmp_17
    li x17, 0xcacacaca
    jalr x15, x15
jmp_17:
    jal x18, jmp_18
    li x18, 0xcacacaca
    jalr x14, x14
jmp_18:
    jal x19, jmp_19
    li x19, 0xcacacaca
    jalr x13, x13
jmp_19:
    jal x20, jmp_20
    li x20, 0xcacacaca
    jalr x12, x12
jmp_20:
    jal x21, jmp_21
    li x21, 0xcacacaca
    jalr x11, x11
jmp_21:
    jal x22, jmp_22
    li x22, 0xcacacaca
    jalr x10, x10
jmp_22:
    jal x23, jmp_23
    li x23, 0xcacacaca
    jalr x9, x9
jmp_23:
    jal x24, jmp_24
    li x24, 0xcacacaca
    jalr x8, x8
jmp_24:
    jal x25, jmp_25
    li x25, 0xcacacaca
    jalr x7, x7
jmp_25:
    jal x26, jmp_26
    li x26, 0xcacacaca
    jalr x6, x6
jmp_26:
    jal x27, jmp_27
    li x27, 0xcacacaca
    jalr x5, x5
jmp_27:
    jal x28, jmp_28
    li x28, 0xcacacaca
    jalr x4, x4
jmp_28:
    jal x29, jmp_29
    li x29, 0xcacacaca
    jalr x3, x3
jmp_29:
    jal x30, jmp_30
    li x30, 0xcacacaca
    jalr x2, x2
jmp_30:
#    jal x31, jmp_31
    jalr x1, x1
jmp_31:
    li x31, 0xcacacaca
