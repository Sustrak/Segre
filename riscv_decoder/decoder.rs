use std::collections::HashMap;
use std::ffi::CString;
use std::os::raw::c_char;

#[no_mangle]
pub extern "C" fn decode_instruction(bits: u32) -> *mut c_char {
    let instr = RiscvInstr::new(&bits);
    match instr {
        Some(v) =>
            match v.riscv_type {
                RiscvInstrType::R    => return CString::new(format!("{} {}, {}, {}", v.mnemo, v.rd.unwrap(), v.rs1.unwrap(), v.rs2.unwrap())).unwrap().into_raw(),
                RiscvInstrType::I    => return CString::new(format!("{} {}, {}, {}", v.mnemo, v.rd.unwrap(), v.rs1.unwrap(), v.imm.unwrap())).unwrap().into_raw(),
                RiscvInstrType::S    => return CString::new(format!("{} {}, {}({})", v.mnemo, v.rs2.unwrap(), v.imm.unwrap(), v.rs1.unwrap())).unwrap().into_raw(),
                RiscvInstrType::B    => return CString::new(format!("{} {}, {}, {}", v.mnemo, v.rs1.unwrap(), v.rs2.unwrap(), v.imm.unwrap())).unwrap().into_raw(),
                RiscvInstrType::U    => return CString::new(format!("{} {}, {}", v.mnemo, v.rd.unwrap(), v.imm.unwrap())).unwrap().into_raw(),
                RiscvInstrType::J    => return CString::new(format!("{} {}, {}", v.mnemo, v.rd.unwrap(), v.imm.unwrap())).unwrap().into_raw(),
                RiscvInstrType::SYS  => return CString::new(format!("{}", v.mnemo)).unwrap().into_raw(),
                RiscvInstrType::CSR  => return CString::new(format!("{} {}, {}, {}", v.mnemo, v.rd.unwrap(), v.rs1.unwrap(), v.csr.unwrap())).unwrap().into_raw(),
                RiscvInstrType::CSRI => return CString::new(format!("{} {}, {}, {}", v.mnemo, v.rd.unwrap(), v.imm.unwrap(), v.csr.unwrap())).unwrap().into_raw()
            }
        None => return CString::new("Instruction not in the decoder").unwrap().into_raw()
    }
}

#[no_mangle]
pub extern "C" fn free_ptr(s: *mut c_char) {
    unsafe {
        if s.is_null() { return; }
        CString::from_raw(s)
    };
}

enum RiscvInstrType { 
    R, I, S, B, U, J, SYS, CSR, CSRI
}

struct RiscvInstr {
    riscv_type: RiscvInstrType,
    mnemo: &'static str,
    rd: Option<&'static str>,
    rs1: Option<&'static str>,
    rs2: Option<&'static str>,
    imm: Option<i32>,
    csr: Option<&'static str>
}

impl RiscvInstr {
    fn new(instr: &u32) -> Option<Self> {
        let riscv_reg = vec![ "zero", "ra", "sp", "gp", "tp", "t0", "t1", "t2", 
            "s0", "s1", "a0", "a1", "a2", "a3", "a4", "a5",
            "a6", "a7", "s2", "s3", "s4", "s5", "s6", "s7",
            "s8", "s9", "s10", "s11", "t3", "t4", "t5", "t6"
        ];
        let riscv_csr: HashMap<u16, &'static str> = [
            (0x000, "ustatus"), (0x004, "uie"), (0x005, "utvec"), (0x040, "uscratch"), (0x041, "uepc"),
            (0x042, "ucause"), (0x043, "utval"), (0x044, "uip"), (0x300, "mstatus"), (0x301, "misa"),
            (0x302, "medeleg"), (0x303, "mideleg"), (0x304, "mie"), (0x305, "mtvec"), (0x306, "mcounteren"),
            (0x310, "mstatush")
        ].iter().cloned().collect();
        let decode_r_type = |bits: &u32| -> RiscvInstr {
            RiscvInstr {
                riscv_type : RiscvInstrType::R,
                mnemo: "",
                rd  : Some(riscv_reg[((bits >> 7)  & 0b11111) as usize]),
                rs1 : Some(riscv_reg[((bits >> 15) & 0b11111) as usize]),
                rs2 : Some(riscv_reg[((bits >> 20) & 0b11111) as usize]),
                imm : None,
                csr : None
            }
        };
        let decode_i_type = |bits: &u32| -> RiscvInstr {
            RiscvInstr {
                riscv_type : RiscvInstrType::I,
                mnemo: "",
                rd  : Some(riscv_reg[((bits >> 7)  & 0b11111) as usize]),
                rs1 : Some(riscv_reg[((bits >> 15) & 0b11111) as usize]),
                rs2 : None,
                imm : Some((bits >> 20) as i32),
                csr : None
            }
        };
        let decode_s_type = |bits: &u32| -> RiscvInstr {
            RiscvInstr {
                riscv_type : RiscvInstrType::S,
                mnemo: "",
                rd  : None,
                rs1 : Some(riscv_reg[((bits >> 15) & 0b11111) as usize]),
                rs2 : Some(riscv_reg[((bits >> 20) & 0b11111) as usize]),
                imm : Some(((bits >> 20 & 0xfe) | (bits >> 7 & 0x1f)) as i32),
                csr : None
            }
        };
        let decode_b_type = |bits: &u32| -> RiscvInstr {
            RiscvInstr {
                riscv_type : RiscvInstrType::B,
                mnemo: "",
                rd  : None,
                rs1 : Some(riscv_reg[((bits >> 15) & 0b11111) as usize]),
                rs2 : Some(riscv_reg[((bits >> 20) & 0b11111) as usize]),
                imm : Some((((bits & 0x8000_0000) >> 19) | ((bits & 0x7e00_0000) >> 20) | ((bits & 0x0000_0f00) >> 7) | ((bits & 0x0000_0080) << 4)) as i32),
                csr : None
            }
        };
        let decode_u_type = |bits: &u32| -> RiscvInstr {
            RiscvInstr {
                riscv_type : RiscvInstrType::U,
                mnemo: "",
                rd  : Some(riscv_reg[((bits >> 7)  & 0b11111) as usize]),
                rs1 : None,
                rs2 : None,
                imm : Some((bits & 0xfffff000) as i32),
                csr : None
            }
        };
        let decode_j_type = |bits: &u32| -> RiscvInstr {
            RiscvInstr {
                riscv_type : RiscvInstrType::J,
                mnemo: "",
                rd  : Some(riscv_reg[((bits >> 7)  & 0b11111) as usize]),
                rs1 : None,
                rs2 : None,
                imm : Some((((bits & 0x8000_0000) >> 11) | ((bits & 0x7fe0_0000) >> 20) | ((bits & 0x0010_0000) >> 9) | (bits & 0x000f_f000)) as i32),
                csr : None
            }
        };
        let decode_csr_type = |bits: &u32| -> RiscvInstr {
            RiscvInstr {
                riscv_type : RiscvInstrType::CSR,
                mnemo : "",
                rd  : Some(riscv_reg[((bits >> 7)  & 0b11111) as usize]),
                rs1 : Some(riscv_reg[((bits >> 15) & 0b11111) as usize]),
                rs2 : None,
                imm : None,
                csr : Some(riscv_csr.get(&((bits >> 20) as u16)).unwrap_or(&"CSR_NOT_LISTED"))
            }
        };
        let decode_csri_type = |bits: &u32| -> RiscvInstr {
            RiscvInstr {
                riscv_type : RiscvInstrType::CSRI,
                mnemo : "",
                rd  : Some(riscv_reg[((bits >> 7)  & 0b11111) as usize]),
                rs1 : None,
                rs2 : None,
                imm : Some(((bits >> 15) & 0b11111) as i32),
                csr : Some(riscv_csr.get(&((bits >> 20) as u16)).unwrap_or(&"CRS_NOT_LISTED"))
            }
        };
        let decision_bits = ((instr >> 2) & 0b111, (instr >> 5) & 0b11);
        match decision_bits {
            (0b000, 0b00) => {
                // Load
                let mut ret: RiscvInstr = decode_i_type(instr);
                ret.mnemo = match instr >> 12 & 0b111 {
                    0b000 => "lb",
                    0b001 => "lh",
                    0b010 => "lw",
                    0b100 => "lbu",
                    0b101 => "lhu",
                    _ => "UNIMPLEMENTED_LOAD"
                };
                Some(ret)
            }
            (0b000, 0b01) => {
                // Store
                let mut ret: RiscvInstr = decode_s_type(instr);
                ret.mnemo = match instr >> 12 & 0b111 {
                    0b000 => "sb",
                    0b001 => "sh",
                    0b010 => "sw",
                    _ => "UNIMPLEMENTED_STORE"
                };
                Some(ret)
            }
            (0b000, 0b11) => {
                // Branch
                let mut ret: RiscvInstr = decode_b_type(instr);
                ret.mnemo = match instr >> 12 & 0b111 {
                    0b000 => "beq",
                    0b001 => "bne",
                    0b100 => "blt",
                    0b101 => "bge",
                    0b110 => "bltu",
                    0b111 => "bgeu",
                    _ => "UNIMPLEMENTED_STORE"
                };
                Some(ret)
            }
            (0b001, 0b11) => {
                // JALR
                let mut ret: RiscvInstr = decode_i_type(instr);
                ret.mnemo = "jalr";
                Some(ret)
            }
            (0b011, 0b11) => {
                // JAL
                let mut ret: RiscvInstr = decode_j_type(instr);
                ret.mnemo = "jal";
                Some(ret)
            }
            (0b100, 0b00) => {
                // OP IMM
                let mut ret: RiscvInstr = decode_i_type(instr);
                ret.mnemo = match instr >> 12 & 0b111 {
                    0b000 => "addi",
                    0b010 => "slti",
                    0b011 => "sltiu",
                    0b100 => "xori",
                    0b110 => "ori",
                    0b111 => "andi",
                    0b001 => "slli",
                    0b101 => match instr >> 25 {
                                0b0000000 => "srli",
                                0b0100000 => "srai",
                                _ => "UNIMPLEMENTED_OP_IMM"
                             },
                    _ => "UNIMPLEMENTED_OP_IMM"
                };
                Some(ret)
            }
            (0b100, 0b01) => {
                // OP
                let mut ret: RiscvInstr = decode_r_type(instr);
                ret.mnemo = match instr >> 12 & 0b111 {
                    0b000 => match instr >> 25 {
                                0b0000000 => "add",
                                0b0100000 => "sub",
                                0b0000001 => "mul",
                                _ => "UNIMPLEMENTED_OP"
                             },
                    0b001 => match instr >> 25 {
                                0b0000000 => "sll",
                                0b0000001 => "mulh",
                                _ => "UNIMPLEMENTED_OP"
                             },
                    0b010 => match instr >> 25 {
                                0b0000000 => "slt",
                                0b0000001 => "mulhsu",
                                _ => "UNIMPLEMENTED_OP"
                             },
                    0b011 => match instr >> 25 {
                                0b0000000 => "sltu",
                                0b0000001 => "mulhu",
                                _ => "UNIMPLEMENTED_OP"
                             },
                    0b100 => match instr >> 25 {
                                0b0000000 => "xor",
                                0b0000001 => "div",
                                _ => "UNIMPLEMENTED_OP"
                             },
                    0b101 => match instr >> 25 {
                                0b0000000 => "srl",
                                0b0100000 => "sra",
                                0b0000001 => "divu",
                                _ => "UNIMPLEMENTED_OP"
                             },
                    0b110 => match instr >> 25 {
                                0b0000000 => "or",
                                0b0000001 => "rem",
                                _ => "UNIMPLEMENTED_OP"
                             },
                    0b111 => match instr >> 25 {
                                0b0000000 => "and",
                                0b0000001 => "remu",
                                _ => "UNIMPLEMENTED_OP"
                             },
                    _ => "UNIMPLEMENTED_OP"
                };
                Some(ret)
            }
            (0b100, 0b11) => {
                // SYSTEM
                match instr >> 12 & 0b111 {
                    0b00 => Some(RiscvInstr {
                                riscv_type : RiscvInstrType::SYS,
                                mnemo : match instr >> 20 {
                                            0b000000000000 => "ecall",
                                            0b000000000001 => "ebreak",
                                            _ => "UNIMPLEMENTED_SYSTEM"
                                        },
                                rd  : None,
                                rs1 : None,
                                rs2 : None,
                                imm : None,
                                csr : None
                            }),
                    0b001 => {
                        let mut ret: RiscvInstr = decode_csr_type(instr);
                        ret.mnemo = "CSRRW";
                        Some(ret)
                    }
                    0b010 => {
                        let mut ret: RiscvInstr = decode_csr_type(instr);
                        ret.mnemo = "CSRRS";
                        Some(ret)
                    }
                    0b011 => {
                        let mut ret: RiscvInstr = decode_csr_type(instr);
                        ret.mnemo = "CSRRC";
                        Some(ret)
                    }
                    0b101 => {
                        let mut ret: RiscvInstr = decode_csri_type(instr);
                        ret.mnemo = "CSRRWI";
                        Some(ret)
                    }
                    0b110 => {
                        let mut ret: RiscvInstr = decode_csri_type(instr);
                        ret.mnemo = "CSRRSI";
                        Some(ret)
                    }
                    0b111 => {
                        let mut ret: RiscvInstr = decode_csri_type(instr);
                        ret.mnemo = "CSRRCI";
                        Some(ret)
                    }
                    _ => None
                }
            }
            (0b101, 0b00) => {
                // AUIPC
                let mut ret: RiscvInstr = decode_u_type(instr);
                ret.mnemo = "auipc";
                Some(ret) 
            }
            (0b101, 0b01) => {
                // LUI
                let mut ret: RiscvInstr = decode_u_type(instr);
                ret.mnemo = "lui";
                Some(ret) 
            }
            _ => None
        }
    }
}
