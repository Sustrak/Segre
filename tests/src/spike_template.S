.include "user_define.h"
.globl _start
.section .text
.option norvc;
_start:           
                  csrr x5, 0xf14
                  li x6, 0
                  beq x5, x6, 0f

0: j h0_start
h0_start:
                  li x26, 0x40000100
                  csrw 0x301, x26
kernel_sp:        
                  la x28, kernel_stack_end

trap_vec_init:    
                  la x26, mtvec_handler
                  ori x26, x26, 0
                  csrw 0x305, x26 # MTVEC

mepc_setup:       
                  la x26, init
                  csrw 0x341, x26
                  j init_machine_mode

custom_csr_setup: 
                  nop

init:             
                  li x0, 0xf55bfdaf
                  li x1, 0x80000000
                  li x2, 0xd0e67836
                  li x3, 0xd2317493
                  li x4, 0x80000000
                  li x5, 0x0
                  li x6, 0x80000000
                  li x7, 0x5
                  li x8, 0xfba05788
                  li x9, 0xf4556b6d
                  li x10, 0x0
                  li x11, 0x7
                  li x13, 0xe5cd995
                  li x14, 0x369b19fb
                  li x15, 0x3
                  li x16, 0x80000000
                  li x17, 0x0
                  li x18, 0xdb5ebd6e
                  li x19, 0xf19ee742
                  li x20, 0x1
                  li x21, 0x8e638793
                  li x22, 0x0
                  li x23, 0x7a772e59
                  li x24, 0xe
                  li x25, 0x820cf2bf
                  li x26, 0x80000000
                  li x27, 0xd
                  li x29, 0x0
                  li x30, 0x0
                  li x31, 0x0
                  la x12, user_stack_end
main:
                  .include "segre_test.S"
                  j test_done
test_done:        
                  li gp, 1
write_tohost:     
                  sw gp, tohost, t5

_exit:            
                  csrrw t0, 0xc00, t0
                  j write_tohost

init_machine_mode:
                  li x26, 0x1800
                  csrw 0x300, x26 # MSTATUS
                  li x26, 0x0
                  csrw 0x304, x26 # MIE
                  mret
instr_end:        
                  nop

.section .data
.align 6; .global tohost; tohost: .dword 0;
.align 6; .global fromhost; fromhost: .dword 0;
.section .user_stack,"aw",@progbits;
.align 2
user_stack_start:
.rept 4999
.4byte 0x0
.endr
user_stack_end:
.4byte 0x0
.align 2
kernel_instr_start:
.text
.align           2
mtvec_handler:    
                  csrrw x12, 0x340, x12
                  add x12, x28, zero
                  1: addi x12, x12, -124
                  sw  x1, 4(x12)
                  sw  x2, 8(x12)
                  sw  x3, 12(x12)
                  sw  x4, 16(x12)
                  sw  x5, 20(x12)
                  sw  x6, 24(x12)
                  sw  x7, 28(x12)
                  sw  x8, 32(x12)
                  sw  x9, 36(x12)
                  sw  x10, 40(x12)
                  sw  x11, 44(x12)
                  sw  x12, 48(x12)
                  sw  x13, 52(x12)
                  sw  x14, 56(x12)
                  sw  x15, 60(x12)
                  sw  x16, 64(x12)
                  sw  x17, 68(x12)
                  sw  x18, 72(x12)
                  sw  x19, 76(x12)
                  sw  x20, 80(x12)
                  sw  x21, 84(x12)
                  sw  x22, 88(x12)
                  sw  x23, 92(x12)
                  sw  x24, 96(x12)
                  sw  x25, 100(x12)
                  sw  x26, 104(x12)
                  sw  x27, 108(x12)
                  sw  x28, 112(x12)
                  sw  x29, 116(x12)
                  sw  x30, 120(x12)
                  sw  x31, 124(x12)
                  csrr x26, 0x300 # MSTATUS
                  csrr x26, 0x342 # MCAUSE
                  srli x26, x26, 31
                  bne x26, x0, mmode_intr_handler

mmode_exception_handler:
                  csrr x26, 0x341 # MEPC
                  csrr x26, 0x342 # MCAUSE
                  li x31, 0x3 # BREAKPOINT
                  beq x26, x31, ebreak_handler
                  li x31, 0x8 # ECALL_UMODE
                  beq x26, x31, ecall_handler
                  li x31, 0x9 # ECALL_SMODE
                  beq x26, x31, ecall_handler
                  li x31, 0xb # ECALL_MMODE
                  beq x26, x31, ecall_handler
                  li x31, 0x1
                  beq x26, x31, instr_fault_handler
                  li x31, 0x5
                  beq x26, x31, load_fault_handler
                  li x31, 0x7
                  beq x26, x31, store_fault_handler
                  li x31, 0xc
                  beq x26, x31, pt_fault_handler
                  li x31, 0xd
                  beq x26, x31, pt_fault_handler
                  li x31, 0xf
                  beq x26, x31, pt_fault_handler
                  li x31, 0x2 # ILLEGAL_INSTRUCTION
                  beq x26, x31, illegal_instr_handler
                  csrr x31, 0x343 # MTVAL
                  1: jal x1, test_done 

ecall_handler:    
                  la x26, _start
                  sw x0, 0(x26)
                  sw x1, 4(x26)
                  sw x2, 8(x26)
                  sw x3, 12(x26)
                  sw x4, 16(x26)
                  sw x5, 20(x26)
                  sw x6, 24(x26)
                  sw x7, 28(x26)
                  sw x8, 32(x26)
                  sw x9, 36(x26)
                  sw x10, 40(x26)
                  sw x11, 44(x26)
                  sw x12, 48(x26)
                  sw x13, 52(x26)
                  sw x14, 56(x26)
                  sw x15, 60(x26)
                  sw x16, 64(x26)
                  sw x17, 68(x26)
                  sw x18, 72(x26)
                  sw x19, 76(x26)
                  sw x20, 80(x26)
                  sw x21, 84(x26)
                  sw x22, 88(x26)
                  sw x23, 92(x26)
                  sw x24, 96(x26)
                  sw x25, 100(x26)
                  sw x26, 104(x26)
                  sw x27, 108(x26)
                  sw x28, 112(x26)
                  sw x29, 116(x26)
                  sw x30, 120(x26)
                  sw x31, 124(x26)
                  j write_tohost
instr_fault_handler:
                  li x26, 0
                  csrw 0x340, x26
                  li x17, 0
                  0: csrr x26, 0x340
                  mv x6, x26
                  li x6, 0
                  beq x26, x6, 1f
                  1: csrr x31, 0x3b0
                  csrr x29, 0x3a0
                  j 17f
                  17: li x9, 4
                  csrr x26, 0x340
                  slli x26, x26, 30
                  srli x26, x26, 30
                  sub x6, x9, x26
                  addi x6, x6, -1
                  slli x6, x6, 3
                  sll x9, x29, x6
                  slli x26, x26, 3
                  add x6, x6, x26
                  srl x9, x9, x6
                  slli x6, x9, 27
                  srli x6, x6, 30
                  beqz x6, 20f
                  li x26, 1
                  beq x6, x26, 21f
                  li x26, 2
                  beq x6, x26, 25f
                  li x26, 3
                  beq x6, x26, 27f
                  j test_done
                  18: csrr x26, 0x340
                  mv x17, x31
                  addi x26, x26, 1
                  csrw 0x340, x26
                  li x31, 1
                  ble x31, x26, 19f
                  j 0b
                  19: j test_done
                  20: j 18b
                  21: csrr x26, 0x340
                  csrr x6, 0x343
                  srli x6, x6, 2
                  bnez x26, 22f
                  bltz x6, 18b
                  j 23f
                  22: bgtu x17, x6, 18b
                  23: bleu x31, x6, 18b
                  andi x6, x9, 128
                  beqz x6, 24f
                  j test_done
                  24: j 29f
                  25: csrr x26, 0x343
                  srli x26, x26, 2
                  slli x6, x31, 2
                  srli x6, x6, 2
                  bne x26, x6, 18b
                  andi x6, x9, 128
                  beqz x6, 26f
                  j test_done
                  26: j 29f
                  27: csrr x26, 0x343
                  srli x26, x26, 2
                  srli x26, x26, 0
                  slli x26, x26, 0
                  slli x6, x31, 2
                  srli x6, x6, 2
                  srli x6, x6, 0
                  slli x6, x6, 0
                  bne x26, x6, 18b
                  andi x6, x9, 128
                  beqz x6, 29f
                  j test_done
                  28: j 29f
                  29: ori x9, x9, 4
                  csrr x26, 0x340
                  li x6, 30
                  sll x26, x26, x6
                  srl x26, x26, x6
                  slli x6, x26, 3
                  sll x9, x9, x6
                  or x29, x29, x9
                  csrr x26, 0x340
                  srli x26, x26, 2
                  beqz x26, 30f
                  li x6, 1
                  beq x26, x6, 31f
                  li x6, 2
                  beq x26, x6, 32f
                  li x6, 3
                  beq x26, x6, 33f
                  30: csrw 0x3a0, x29
                  j 34f
                  31: csrw 0x3a1, x29
                  j 34f
                  32: csrw 0x3a2, x29
                  j 34f
                  33: csrw 0x3a3, x29
                  34: nop
                  lw  x1, 4(x12)
                  lw  x2, 8(x12)
                  lw  x3, 12(x12)
                  lw  x4, 16(x12)
                  lw  x5, 20(x12)
                  lw  x6, 24(x12)
                  lw  x7, 28(x12)
                  lw  x8, 32(x12)
                  lw  x9, 36(x12)
                  lw  x10, 40(x12)
                  lw  x11, 44(x12)
                  lw  x12, 48(x12)
                  lw  x13, 52(x12)
                  lw  x14, 56(x12)
                  lw  x15, 60(x12)
                  lw  x16, 64(x12)
                  lw  x17, 68(x12)
                  lw  x18, 72(x12)
                  lw  x19, 76(x12)
                  lw  x20, 80(x12)
                  lw  x21, 84(x12)
                  lw  x22, 88(x12)
                  lw  x23, 92(x12)
                  lw  x24, 96(x12)
                  lw  x25, 100(x12)
                  lw  x26, 104(x12)
                  lw  x27, 108(x12)
                  lw  x28, 112(x12)
                  lw  x29, 116(x12)
                  lw  x30, 120(x12)
                  lw  x31, 124(x12)
                  addi x12, x12, 124
                  add x28, x12, zero
                  csrrw x12, 0x340, x12
                  mret

load_fault_handler:
                  li x26, 0
                  csrw 0x340, x26
                  li x17, 0
                  0: csrr x26, 0x340
                  mv x6, x26
                  li x6, 0
                  beq x26, x6, 1f
                  1: csrr x31, 0x3b0
                  csrr x29, 0x3a0
                  j 17f
                  17: li x9, 4
                  csrr x26, 0x340
                  slli x26, x26, 30
                  srli x26, x26, 30
                  sub x6, x9, x26
                  addi x6, x6, -1
                  slli x6, x6, 3
                  sll x9, x29, x6
                  slli x26, x26, 3
                  add x6, x6, x26
                  srl x9, x9, x6
                  slli x6, x9, 27
                  srli x6, x6, 30
                  beqz x6, 20f
                  li x26, 1
                  beq x6, x26, 21f
                  li x26, 2
                  beq x6, x26, 25f
                  li x26, 3
                  beq x6, x26, 27f
                  j test_done
                  18: csrr x26, 0x340
                  mv x17, x31
                  addi x26, x26, 1
                  csrw 0x340, x26
                  li x31, 1
                  ble x31, x26, 19f
                  j 0b
                  19: j test_done
                  20: j 18b
                  21: csrr x26, 0x340
                  csrr x6, 0x343
                  srli x6, x6, 2
                  bnez x26, 22f
                  bltz x6, 18b
                  j 23f
                  22: bgtu x17, x6, 18b
                  23: bleu x31, x6, 18b
                  andi x6, x9, 128
                  beqz x6, 24f
                  j test_done
                  24: j 29f
                  25: csrr x26, 0x343
                  srli x26, x26, 2
                  slli x6, x31, 2
                  srli x6, x6, 2
                  bne x26, x6, 18b
                  andi x6, x9, 128
                  beqz x6, 26f
                  j test_done
                  26: j 29f
                  27: csrr x26, 0x343
                  srli x26, x26, 2
                  srli x26, x26, 0
                  slli x26, x26, 0
                  slli x6, x31, 2
                  srli x6, x6, 2
                  srli x6, x6, 0
                  slli x6, x6, 0
                  bne x26, x6, 18b
                  andi x6, x9, 128
                  beqz x6, 29f
                  j test_done
                  28: j 29f
                  29: ori x9, x9, 1
                  csrr x26, 0x340
                  li x6, 30
                  sll x26, x26, x6
                  srl x26, x26, x6
                  slli x6, x26, 3
                  sll x9, x9, x6
                  or x29, x29, x9
                  csrr x26, 0x340
                  srli x26, x26, 2
                  beqz x26, 30f
                  li x6, 1
                  beq x26, x6, 31f
                  li x6, 2
                  beq x26, x6, 32f
                  li x6, 3
                  beq x26, x6, 33f
                  30: csrw 0x3a0, x29
                  j 34f
                  31: csrw 0x3a1, x29
                  j 34f
                  32: csrw 0x3a2, x29
                  j 34f
                  33: csrw 0x3a3, x29
                  34: nop
                  lw  x1, 4(x12)
                  lw  x2, 8(x12)
                  lw  x3, 12(x12)
                  lw  x4, 16(x12)
                  lw  x5, 20(x12)
                  lw  x6, 24(x12)
                  lw  x7, 28(x12)
                  lw  x8, 32(x12)
                  lw  x9, 36(x12)
                  lw  x10, 40(x12)
                  lw  x11, 44(x12)
                  lw  x12, 48(x12)
                  lw  x13, 52(x12)
                  lw  x14, 56(x12)
                  lw  x15, 60(x12)
                  lw  x16, 64(x12)
                  lw  x17, 68(x12)
                  lw  x18, 72(x12)
                  lw  x19, 76(x12)
                  lw  x20, 80(x12)
                  lw  x21, 84(x12)
                  lw  x22, 88(x12)
                  lw  x23, 92(x12)
                  lw  x24, 96(x12)
                  lw  x25, 100(x12)
                  lw  x26, 104(x12)
                  lw  x27, 108(x12)
                  lw  x28, 112(x12)
                  lw  x29, 116(x12)
                  lw  x30, 120(x12)
                  lw  x31, 124(x12)
                  addi x12, x12, 124
                  add x28, x12, zero
                  csrrw x12, 0x340, x12
                  mret

store_fault_handler:
                  li x26, 0
                  csrw 0x340, x26
                  li x17, 0
                  0: csrr x26, 0x340
                  mv x6, x26
                  li x6, 0
                  beq x26, x6, 1f
                  1: csrr x31, 0x3b0
                  csrr x29, 0x3a0
                  j 17f
                  17: li x9, 4
                  csrr x26, 0x340
                  slli x26, x26, 30
                  srli x26, x26, 30
                  sub x6, x9, x26
                  addi x6, x6, -1
                  slli x6, x6, 3
                  sll x9, x29, x6
                  slli x26, x26, 3
                  add x6, x6, x26
                  srl x9, x9, x6
                  slli x6, x9, 27
                  srli x6, x6, 30
                  beqz x6, 20f
                  li x26, 1
                  beq x6, x26, 21f
                  li x26, 2
                  beq x6, x26, 25f
                  li x26, 3
                  beq x6, x26, 27f
                  j test_done
                  18: csrr x26, 0x340
                  mv x17, x31
                  addi x26, x26, 1
                  csrw 0x340, x26
                  li x31, 1
                  ble x31, x26, 19f
                  j 0b
                  19: j test_done
                  20: j 18b
                  21: csrr x26, 0x340
                  csrr x6, 0x343
                  srli x6, x6, 2
                  bnez x26, 22f
                  bltz x6, 18b
                  j 23f
                  22: bgtu x17, x6, 18b
                  23: bleu x31, x6, 18b
                  andi x6, x9, 128
                  beqz x6, 24f
                  j test_done
                  24: j 29f
                  25: csrr x26, 0x343
                  srli x26, x26, 2
                  slli x6, x31, 2
                  srli x6, x6, 2
                  bne x26, x6, 18b
                  andi x6, x9, 128
                  beqz x6, 26f
                  j test_done
                  26: j 29f
                  27: csrr x26, 0x343
                  srli x26, x26, 2
                  srli x26, x26, 0
                  slli x26, x26, 0
                  slli x6, x31, 2
                  srli x6, x6, 2
                  srli x6, x6, 0
                  slli x6, x6, 0
                  bne x26, x6, 18b
                  andi x6, x9, 128
                  beqz x6, 29f
                  j test_done
                  28: j 29f
                  29: ori x9, x9, 3
                  csrr x26, 0x340
                  li x6, 30
                  sll x26, x26, x6
                  srl x26, x26, x6
                  slli x6, x26, 3
                  sll x9, x9, x6
                  or x29, x29, x9
                  csrr x26, 0x340
                  srli x26, x26, 2
                  beqz x26, 30f
                  li x6, 1
                  beq x26, x6, 31f
                  li x6, 2
                  beq x26, x6, 32f
                  li x6, 3
                  beq x26, x6, 33f
                  30: csrw 0x3a0, x29
                  j 34f
                  31: csrw 0x3a1, x29
                  j 34f
                  32: csrw 0x3a2, x29
                  j 34f
                  33: csrw 0x3a3, x29
                  34: nop
                  lw  x1, 4(x12)
                  lw  x2, 8(x12)
                  lw  x3, 12(x12)
                  lw  x4, 16(x12)
                  lw  x5, 20(x12)
                  lw  x6, 24(x12)
                  lw  x7, 28(x12)
                  lw  x8, 32(x12)
                  lw  x9, 36(x12)
                  lw  x10, 40(x12)
                  lw  x11, 44(x12)
                  lw  x12, 48(x12)
                  lw  x13, 52(x12)
                  lw  x14, 56(x12)
                  lw  x15, 60(x12)
                  lw  x16, 64(x12)
                  lw  x17, 68(x12)
                  lw  x18, 72(x12)
                  lw  x19, 76(x12)
                  lw  x20, 80(x12)
                  lw  x21, 84(x12)
                  lw  x22, 88(x12)
                  lw  x23, 92(x12)
                  lw  x24, 96(x12)
                  lw  x25, 100(x12)
                  lw  x26, 104(x12)
                  lw  x27, 108(x12)
                  lw  x28, 112(x12)
                  lw  x29, 116(x12)
                  lw  x30, 120(x12)
                  lw  x31, 124(x12)
                  addi x12, x12, 124
                  add x28, x12, zero
                  csrrw x12, 0x340, x12
                  mret

ebreak_handler:   
                  csrr  x26, 0x341
                  addi  x26, x26, 4
                  csrw  0x341, x26
                  lw  x1, 4(x12)
                  lw  x2, 8(x12)
                  lw  x3, 12(x12)
                  lw  x4, 16(x12)
                  lw  x5, 20(x12)
                  lw  x6, 24(x12)
                  lw  x7, 28(x12)
                  lw  x8, 32(x12)
                  lw  x9, 36(x12)
                  lw  x10, 40(x12)
                  lw  x11, 44(x12)
                  lw  x12, 48(x12)
                  lw  x13, 52(x12)
                  lw  x14, 56(x12)
                  lw  x15, 60(x12)
                  lw  x16, 64(x12)
                  lw  x17, 68(x12)
                  lw  x18, 72(x12)
                  lw  x19, 76(x12)
                  lw  x20, 80(x12)
                  lw  x21, 84(x12)
                  lw  x22, 88(x12)
                  lw  x23, 92(x12)
                  lw  x24, 96(x12)
                  lw  x25, 100(x12)
                  lw  x26, 104(x12)
                  lw  x27, 108(x12)
                  lw  x28, 112(x12)
                  lw  x29, 116(x12)
                  lw  x30, 120(x12)
                  lw  x31, 124(x12)
                  addi x12, x12, 124
                  add x28, x12, zero
                  csrrw x12, 0x340, x12
                  mret

illegal_instr_handler:
                  csrr  x26, 0x341
                  addi  x26, x26, 4
                  csrw  0x341, x26
                  lw  x1, 4(x12)
                  lw  x2, 8(x12)
                  lw  x3, 12(x12)
                  lw  x4, 16(x12)
                  lw  x5, 20(x12)
                  lw  x6, 24(x12)
                  lw  x7, 28(x12)
                  lw  x8, 32(x12)
                  lw  x9, 36(x12)
                  lw  x10, 40(x12)
                  lw  x11, 44(x12)
                  lw  x12, 48(x12)
                  lw  x13, 52(x12)
                  lw  x14, 56(x12)
                  lw  x15, 60(x12)
                  lw  x16, 64(x12)
                  lw  x17, 68(x12)
                  lw  x18, 72(x12)
                  lw  x19, 76(x12)
                  lw  x20, 80(x12)
                  lw  x21, 84(x12)
                  lw  x22, 88(x12)
                  lw  x23, 92(x12)
                  lw  x24, 96(x12)
                  lw  x25, 100(x12)
                  lw  x26, 104(x12)
                  lw  x27, 108(x12)
                  lw  x28, 112(x12)
                  lw  x29, 116(x12)
                  lw  x30, 120(x12)
                  lw  x31, 124(x12)
                  addi x12, x12, 124
                  add x28, x12, zero
                  csrrw x12, 0x340, x12
                  mret

pt_fault_handler: 
                  nop

.align 2
mmode_intr_handler:
                  csrr  x26, 0x300 # MSTATUS;
                  csrr  x26, 0x304 # MIE;
                  csrr  x26, 0x344 # MIP;
                  csrrc x26, 0x344, x26 # MIP;
                  lw  x1, 4(x12)
                  lw  x2, 8(x12)
                  lw  x3, 12(x12)
                  lw  x4, 16(x12)
                  lw  x5, 20(x12)
                  lw  x6, 24(x12)
                  lw  x7, 28(x12)
                  lw  x8, 32(x12)
                  lw  x9, 36(x12)
                  lw  x10, 40(x12)
                  lw  x11, 44(x12)
                  lw  x12, 48(x12)
                  lw  x13, 52(x12)
                  lw  x14, 56(x12)
                  lw  x15, 60(x12)
                  lw  x16, 64(x12)
                  lw  x17, 68(x12)
                  lw  x18, 72(x12)
                  lw  x19, 76(x12)
                  lw  x20, 80(x12)
                  lw  x21, 84(x12)
                  lw  x22, 88(x12)
                  lw  x23, 92(x12)
                  lw  x24, 96(x12)
                  lw  x25, 100(x12)
                  lw  x26, 104(x12)
                  lw  x27, 108(x12)
                  lw  x28, 112(x12)
                  lw  x29, 116(x12)
                  lw  x30, 120(x12)
                  lw  x31, 124(x12)
                  addi x12, x12, 124
                  add x28, x12, zero
                  csrrw x12, 0x340, x12
                  mret;

kernel_instr_end: nop
.section .kernel_stack,"aw",@progbits;
.align 2
kernel_stack_start:
.rept 3999
.4byte 0x0
.endr
kernel_stack_end:
.4byte 0x0
