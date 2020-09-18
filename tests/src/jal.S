.text
li a0, 0x8000
la t1, LABEL
jalr t2, t1, 0
li t2, -1
LABEL:
    sw t2, 0(a0)
