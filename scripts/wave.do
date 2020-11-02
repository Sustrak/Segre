onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -group CORE -divider {Clock and Reset}
add wave -noupdate -group CORE -radix hexadecimal /top_tb/dut/clk_i
add wave -noupdate -group CORE -radix hexadecimal /top_tb/dut/rsn_i
add wave -noupdate -group CORE -divider {FSM STATE}
add wave -noupdate -group CORE /top_tb/dut/fsm_state
add wave -noupdate -group CORE -divider {TB Memory}
add wave -noupdate -group CORE -radix hexadecimal /top_tb/dut/addr_o
add wave -noupdate -group CORE -radix hexadecimal /top_tb/dut/mem_rd_data_i
add wave -noupdate -group CORE -radix hexadecimal /top_tb/dut/mem_wr_data_o
add wave -noupdate -group CORE -radix hexadecimal /top_tb/dut/mem_rd_o
add wave -noupdate -group CORE -radix hexadecimal /top_tb/dut/mem_wr_o
add wave -noupdate -group CORE -radix hexadecimal /top_tb/dut/mem_data_type_o
add wave -noupdate -group CORE -divider Fetch
add wave -noupdate -group CORE -radix hexadecimal /top_tb/dut/if_addr
add wave -noupdate -group CORE -radix hexadecimal /top_tb/dut/if_mem_rd
add wave -noupdate -group CORE -divider Decoder
add wave -noupdate -group CORE -radix hexadecimal top_tb/dut/id_instr
add wave -noupdate -group CORE -radix hexadecimal top_tb/dut/rf_raddr_a
add wave -noupdate -group CORE -radix hexadecimal top_tb/dut/rf_raddr_b
add wave -noupdate -group CORE -radix hexadecimal top_tb/dut/rf_data_a
add wave -noupdate -group CORE -radix hexadecimal top_tb/dut/rf_data_b
add wave -noupdate -group CORE -divider Execution
add wave -noupdate -group CORE -radix hexadecimal top_tb/dut/ex_alu_opcode
add wave -noupdate -group CORE -radix hexadecimal top_tb/dut/ex_alu_src_a
add wave -noupdate -group CORE -radix hexadecimal top_tb/dut/ex_alu_src_b
add wave -noupdate -group CORE -radix hexadecimal top_tb/dut/ex_rf_st_data
add wave -noupdate -group CORE -radix hexadecimal top_tb/dut/ex_rf_we
add wave -noupdate -group CORE -radix hexadecimal top_tb/dut/ex_rf_waddr
add wave -noupdate -group CORE -radix hexadecimal top_tb/dut/ex_memop_type
add wave -noupdate -group CORE -radix hexadecimal top_tb/dut/ex_memop_rd
add wave -noupdate -group CORE -radix hexadecimal top_tb/dut/ex_memop_wr
add wave -noupdate -group CORE -radix hexadecimal top_tb/dut/ex_memop_sign_ext
add wave -noupdate -group CORE -divider Memory
add wave -noupdate -group CORE -radix hexadecimal top_tb/dut/mem_alu_res
add wave -noupdate -group CORE -radix hexadecimal top_tb/dut/mem_rf_waddr
add wave -noupdate -group CORE -radix hexadecimal top_tb/dut/mem_rf_we
add wave -noupdate -group CORE -radix hexadecimal top_tb/dut/mem_memop_type
add wave -noupdate -group CORE -radix hexadecimal top_tb/dut/mem_data_type
add wave -noupdate -group CORE -radix hexadecimal top_tb/dut/mem_addr
add wave -noupdate -group CORE -radix hexadecimal top_tb/dut/mem_wr_data
add wave -noupdate -group CORE -radix hexadecimal top_tb/dut/mem_rf_st_data
add wave -noupdate -group CORE -radix hexadecimal top_tb/dut/mem_memop_rd
add wave -noupdate -group CORE -radix hexadecimal top_tb/dut/mem_memop_wr
add wave -noupdate -group CORE -radix hexadecimal top_tb/dut/mem_rd
add wave -noupdate -group CORE -radix hexadecimal top_tb/dut/mem_wr
add wave -noupdate -group CORE -radix hexadecimal top_tb/dut/mem_memop_sign_ext
add wave -noupdate -group CORE -divider WB
add wave -noupdate -group CORE -radix hexadecimal top_tb/dut/wb_res
add wave -noupdate -group CORE -radix hexadecimal top_tb/dut/wb_rf_waddr
add wave -noupdate -group CORE -radix hexadecimal top_tb/dut/wb_rf_we
add wave -noupdate -group {IF Stage} -divider {CLK & RSN}
add wave -noupdate -group {IF Stage} /top_tb/dut/if_stage/clk_i
add wave -noupdate -group {IF Stage} /top_tb/dut/if_stage/rsn_i
add wave -noupdate -group {IF Stage} -divider {FSM STATE}
add wave -noupdate -group {IF Stage} /top_tb/dut/if_stage/fsm_state_i
add wave -noupdate -group {IF Stage} -divider PC
add wave -noupdate -group {IF Stage} -radix hexadecimal top_tb/dut/if_stage/tkbr_i
add wave -noupdate -group {IF Stage} -radix hexadecimal top_tb/dut/if_stage/new_pc_i
add wave -noupdate -group {IF Stage} -radix hexadecimal top_tb/dut/if_stage/nxt_pc
add wave -noupdate -group {IF Stage} -radix hexadecimal top_tb/dut/if_stage/pc_o
add wave -noupdate -group {IF Stage} -radix hexadecimal top_tb/dut/if_stage/mem_rd_o
add wave -noupdate -group {IF Stage} -divider INSTRUCTION
add wave -noupdate -group {IF Stage} -radix hexadecimal top_tb/dut/if_stage/instr_i
add wave -noupdate -group {IF Stage} -radix hexadecimal top_tb/dut/if_stage/instr_o
add wave -noupdate -group {ID Stage} -group Decode -divider {CLK & RSN}
add wave -noupdate -group {ID Stage} -group Decode -radix hexadecimal top_tb/dut/id_stage/decode/clk_i
add wave -noupdate -group {ID Stage} -group Decode -radix hexadecimal top_tb/dut/id_stage/decode/rsn_i
add wave -noupdate -group {ID Stage} -group Decode -divider INSTRUCTION
add wave -noupdate -group {ID Stage} -group Decode -radix hexadecimal top_tb/dut/id_stage/decode/instr_i
add wave -noupdate -group {ID Stage} -group Decode -radix hexadecimal top_tb/dut/id_stage/decode/illegal_ins
add wave -noupdate -group {ID Stage} -group Decode -divider OPCODES
add wave -noupdate -group {ID Stage} -group Decode -radix hexadecimal top_tb/dut/id_stage/decode/instr_opcode
add wave -noupdate -group {ID Stage} -group Decode -radix hexadecimal top_tb/dut/id_stage/decode/alu_instr_opcode
add wave -noupdate -group {ID Stage} -group Decode -radix hexadecimal top_tb/dut/id_stage/decode/alu_opcode_o
add wave -noupdate -group {ID Stage} -group Decode -divider IMMEDIATES
add wave -noupdate -group {ID Stage} -group Decode -radix hexadecimal top_tb/dut/id_stage/decode/imm_u_type_o
add wave -noupdate -group {ID Stage} -group Decode -radix hexadecimal top_tb/dut/id_stage/decode/imm_i_type_o
add wave -noupdate -group {ID Stage} -group Decode -radix hexadecimal top_tb/dut/id_stage/decode/imm_s_type_o
add wave -noupdate -group {ID Stage} -group Decode -divider MUX
add wave -noupdate -group {ID Stage} -group Decode -radix hexadecimal top_tb/dut/id_stage/decode/src_a_mux_sel_o
add wave -noupdate -group {ID Stage} -group Decode -radix hexadecimal top_tb/dut/id_stage/decode/src_b_mux_sel_o
add wave -noupdate -group {ID Stage} -group Decode -radix hexadecimal top_tb/dut/id_stage/decode/a_imm_mux_sel_o
add wave -noupdate -group {ID Stage} -group Decode -radix hexadecimal top_tb/dut/id_stage/decode/b_imm_mux_sel_o
add wave -noupdate -group {ID Stage} -group Decode -divider RF
add wave -noupdate -group {ID Stage} -group Decode -radix hexadecimal top_tb/dut/id_stage/decode/raddr_a_o
add wave -noupdate -group {ID Stage} -group Decode -radix hexadecimal top_tb/dut/id_stage/decode/raddr_b_o
add wave -noupdate -group {ID Stage} -group Decode -radix hexadecimal top_tb/dut/id_stage/decode/waddr_o
add wave -noupdate -group {ID Stage} -group Decode -radix hexadecimal top_tb/dut/id_stage/decode/rf_we_o
add wave -noupdate -group {ID Stage} -divider MEMOP
add wave -noupdate -group {ID Stage} -radix hexadecimal top_tb/dut/id_stage/decode/memop_type_o
add wave -noupdate -group {ID Stage} -radix hexadecimal top_tb/dut/id_stage/decode/memop_sign_ext_o
add wave -noupdate -group {ID Stage} -radix hexadecimal top_tb/dut/id_stage/decode/memop_rd_o
add wave -noupdate -group {ID Stage} -radix hexadecimal top_tb/dut/id_stage/decode/memop_wr_o
add wave -noupdate -group {ID Stage} -divider {CLK & RSN}
add wave -noupdate -group {ID Stage} -radix hexadecimal top_tb/dut/id_stage/clk_i
add wave -noupdate -group {ID Stage} -radix hexadecimal top_tb/dut/id_stage/rsn_i
add wave -noupdate -group {ID Stage} -divider {FSM STATE}
add wave -noupdate -group {ID Stage} -radix hexadecimal /top_tb/dut/id_stage/fsm_state_i
add wave -noupdate -group {ID Stage} -divider INSTRUCTION
add wave -noupdate -group {ID Stage} -radix hexadecimal /top_tb/dut/id_stage/instr_i
add wave -noupdate -group {ID Stage} -divider {DATA A}
add wave -noupdate -group {ID Stage} -radix hexadecimal /top_tb/dut/id_stage/rf_raddr_a
add wave -noupdate -group {ID Stage} -radix hexadecimal /top_tb/dut/id_stage/rf_raddr_a_o
add wave -noupdate -group {ID Stage} -radix hexadecimal top_tb/dut/id_stage/src_a_mux_sel
add wave -noupdate -group {ID Stage} -radix hexadecimal top_tb/dut/id_stage/rf_data_a_i
add wave -noupdate -group {ID Stage} -radix hexadecimal top_tb/dut/id_stage/imm_a
add wave -noupdate -group {ID Stage} -radix hexadecimal top_tb/dut/id_stage/alu_src_a
add wave -noupdate -group {ID Stage} -radix hexadecimal top_tb/dut/id_stage/alu_src_a_o
add wave -noupdate -group {ID Stage} -divider {DATA B}
add wave -noupdate -group {ID Stage} -radix hexadecimal top_tb/dut/id_stage/rf_raddr_b
add wave -noupdate -group {ID Stage} -radix hexadecimal top_tb/dut/id_stage/rf_raddr_b_o
add wave -noupdate -group {ID Stage} -radix hexadecimal top_tb/dut/id_stage/src_b_mux_sel
add wave -noupdate -group {ID Stage} -radix hexadecimal top_tb/dut/id_stage/rf_data_b_i
add wave -noupdate -group {ID Stage} -radix hexadecimal top_tb/dut/id_stage/imm_b
add wave -noupdate -group {ID Stage} -radix hexadecimal top_tb/dut/id_stage/alu_src_b
add wave -noupdate -group {ID Stage} -radix hexadecimal top_tb/dut/id_stage/alu_src_b_o
add wave -noupdate -group {ID Stage} -divider {BRANCH PORTS}
add wave -noupdate -group {ID Stage} -radix hexadecimal top_tb/dut/id_stage/br_a_mux_sel
add wave -noupdate -group {ID Stage} -radix hexadecimal top_tb/dut/id_stage/br_b_mux_sel
add wave -noupdate -group {ID Stage} -radix hexadecimal top_tb/dut/id_stage/br_src_a
add wave -noupdate -group {ID Stage} -radix hexadecimal top_tb/dut/id_stage/br_src_b
add wave -noupdate -group {ID Stage} -divider MEMORY
add wave -noupdate -group {ID Stage} -radix hexadecimal top_tb/dut/id_stage/memop_type
add wave -noupdate -group {ID Stage} -radix hexadecimal top_tb/dut/id_stage/memop_type_o
add wave -noupdate -group {ID Stage} -radix hexadecimal top_tb/dut/id_stage/memop_sign_ext
add wave -noupdate -group {ID Stage} -radix hexadecimal top_tb/dut/id_stage/memop_sign_ext_o
add wave -noupdate -group {ID Stage} -radix hexadecimal top_tb/dut/id_stage/memop_rd
add wave -noupdate -group {ID Stage} -radix hexadecimal top_tb/dut/id_stage/memop_rd_o
add wave -noupdate -group {ID Stage} -radix hexadecimal top_tb/dut/id_stage/memop_wr
add wave -noupdate -group {ID Stage} -radix hexadecimal top_tb/dut/id_stage/memop_wr_o
add wave -noupdate -group {ID Stage} -radix hexadecimal top_tb/dut/id_stage/memop_rf_data_o
add wave -noupdate -group {ID Stage} -divider IMMEDIATE
add wave -noupdate -group {ID Stage} -radix hexadecimal top_tb/dut/id_stage/imm_u_type
add wave -noupdate -group {ID Stage} -radix hexadecimal top_tb/dut/id_stage/imm_i_type
add wave -noupdate -group {ID Stage} -radix hexadecimal top_tb/dut/id_stage/imm_s_type
add wave -noupdate -group {ID Stage} -radix hexadecimal top_tb/dut/id_stage/imm_j_type
add wave -noupdate -group {ID Stage} -radix hexadecimal top_tb/dut/id_stage/imm_b_type
add wave -noupdate -group {ID Stage} -radix hexadecimal top_tb/dut/id_stage/a_imm_mux_sel
add wave -noupdate -group {ID Stage} -radix hexadecimal top_tb/dut/id_stage/b_imm_mux_sel
add wave -noupdate -group {ID Stage} -divider {WB REG}
add wave -noupdate -group {ID Stage} -radix hexadecimal top_tb/dut/id_stage/rf_we
add wave -noupdate -group {ID Stage} -radix hexadecimal top_tb/dut/id_stage/rf_we_o
add wave -noupdate -group {ID Stage} -radix hexadecimal top_tb/dut/id_stage/rf_waddr
add wave -noupdate -group {ID Stage} -radix hexadecimal top_tb/dut/id_stage/rf_waddr_o
add wave -noupdate -group {ID Stage} -divider OPCODE
add wave -noupdate -group {ID Stage} -radix hexadecimal /top_tb/dut/id_stage/alu_opcode_o
add wave -noupdate -group {Ex Stage} -divider {CLK & RSN}
add wave -noupdate -group {Ex Stage} /top_tb/dut/ex_stage/clk_i
add wave -noupdate -group {Ex Stage} /top_tb/dut/ex_stage/rsn_i
add wave -noupdate -group {Ex Stage} -divider {ALU IN}
add wave -noupdate -group {Ex Stage} -radix hexadecimal top_tb/dut/ex_stage/alu_opcode_i
add wave -noupdate -group {Ex Stage} -radix hexadecimal top_tb/dut/ex_stage/alu_src_a_i
add wave -noupdate -group {Ex Stage} -radix hexadecimal top_tb/dut/ex_stage/alu_src_b_i
add wave -noupdate -group {Ex Stage} -divider {ALU OUT}
add wave -noupdate -group {Ex Stage} -radix hexadecimal top_tb/dut/ex_stage/alu_res
add wave -noupdate -group {Ex Stage} -radix hexadecimal top_tb/dut/ex_stage/alu_res_o
add wave -noupdate -group {Ex Stage} -divider {RF IN}
add wave -noupdate -group {Ex Stage} -radix hexadecimal top_tb/dut/ex_stage/rf_we_i
add wave -noupdate -group {Ex Stage} -radix hexadecimal top_tb/dut/ex_stage/rf_waddr_i
add wave -noupdate -group {Ex Stage} -radix hexadecimal top_tb/dut/ex_stage/rf_st_data_i
add wave -noupdate -group {Ex Stage} -divider {RF OUT}
add wave -noupdate -group {Ex Stage} -radix hexadecimal top_tb/dut/ex_stage/rf_we_o
add wave -noupdate -group {Ex Stage} -radix hexadecimal top_tb/dut/ex_stage/rf_waddr_o
add wave -noupdate -group {Ex Stage} -radix hexadecimal top_tb/dut/ex_stage/rf_st_data_o
add wave -noupdate -group {Ex Stage} -divider {MEMOP IN}
add wave -noupdate -group {Ex Stage} -radix hexadecimal top_tb/dut/ex_stage/memop_type_i
add wave -noupdate -group {Ex Stage} -radix hexadecimal top_tb/dut/ex_stage/memop_rd_i
add wave -noupdate -group {Ex Stage} -radix hexadecimal top_tb/dut/ex_stage/memop_wr_i
add wave -noupdate -group {Ex Stage} -radix hexadecimal top_tb/dut/ex_stage/memop_sign_ext_i
add wave -noupdate -group {Ex Stage} -divider {MEMOP OUT}
add wave -noupdate -group {Ex Stage} -radix hexadecimal top_tb/dut/ex_stage/memop_type_o
add wave -noupdate -group {Ex Stage} -radix hexadecimal top_tb/dut/ex_stage/memop_rd_o
add wave -noupdate -group {Ex Stage} -radix hexadecimal top_tb/dut/ex_stage/memop_wr_o
add wave -noupdate -group {Ex Stage} -radix hexadecimal top_tb/dut/ex_stage/memop_sign_ext_o
add wave -noupdate -group {Ex Stage} -divider BRANCH
add wave -noupdate -group {Ex Stage} -radix hexadecimal top_tb/dut/ex_stage/br_src_a_i
add wave -noupdate -group {Ex Stage} -radix hexadecimal top_tb/dut/ex_stage/br_src_b_i
add wave -noupdate -group {Ex Stage} -radix hexadecimal top_tb/dut/ex_stage/tkbr_o
add wave -noupdate -group {Ex Stage} -divider {NEW PC}
add wave -noupdate -group {Ex Stage} -radix hexadecimal top_tb/dut/ex_stage/new_pc_o
add wave -noupdate -group {MEM Stage} -divider {CLK & RSN}
add wave -noupdate -group {MEM Stage} /top_tb/dut/mem_stage/clk_i
add wave -noupdate -group {MEM Stage} /top_tb/dut/mem_stage/rsn_i
add wave -noupdate -group {MEM Stage} -divider MEMORY
add wave -noupdate -group {MEM Stage} -radix hexadecimal top_tb/dut/mem_stage/data_i
add wave -noupdate -group {MEM Stage} -radix hexadecimal top_tb/dut/mem_stage/mem_data
add wave -noupdate -group {MEM Stage} -radix hexadecimal top_tb/dut/mem_stage/data_o
add wave -noupdate -group {MEM Stage} -radix hexadecimal top_tb/dut/mem_stage/addr_o
add wave -noupdate -group {MEM Stage} -radix hexadecimal top_tb/dut/mem_stage/memop_rd_o
add wave -noupdate -group {MEM Stage} -radix hexadecimal top_tb/dut/mem_stage/memop_wr_o
add wave -noupdate -group {MEM Stage} -radix hexadecimal top_tb/dut/mem_stage/memop_type_o
add wave -noupdate -group {MEM Stage} -divider {MEMOP IN}
add wave -noupdate -group {MEM Stage} -radix hexadecimal top_tb/dut/mem_stage/memop_type_i
add wave -noupdate -group {MEM Stage} -radix hexadecimal top_tb/dut/mem_stage/memop_sign_ext_i
add wave -noupdate -group {MEM Stage} -radix hexadecimal top_tb/dut/mem_stage/memop_rd_i
add wave -noupdate -group {MEM Stage} -radix hexadecimal top_tb/dut/mem_stage/memop_wr_i
add wave -noupdate -group {MEM Stage} -divider {OP RES}
add wave -noupdate -group {MEM Stage} -radix hexadecimal top_tb/dut/mem_stage/alu_res_i
add wave -noupdate -group {MEM Stage} -radix hexadecimal top_tb/dut/mem_stage/op_res_o
add wave -noupdate -group {MEM Stage} -divider RF
add wave -noupdate -group {MEM Stage} -radix hexadecimal top_tb/dut/mem_stage/rf_st_data_i
add wave -noupdate -group {MEM Stage} -radix hexadecimal top_tb/dut/mem_stage/rf_we_i
add wave -noupdate -group {MEM Stage} -radix hexadecimal top_tb/dut/mem_stage/rf_we_o
add wave -noupdate -group {MEM Stage} -radix hexadecimal top_tb/dut/mem_stage/rf_waddr_i
add wave -noupdate -group {MEM Stage} -radix hexadecimal top_tb/dut/mem_stage/rf_waddr_o
add wave -noupdate -group {MEM Stage} -divider BRANCH
add wave -noupdate -group {MEM Stage} -radix hexadecimal top_tb/dut/mem_stage/tkbr_i
add wave -noupdate -group {MEM Stage} -radix hexadecimal top_tb/dut/mem_stage/tkbr_o
add wave -noupdate -group {MEM Stage} -radix hexadecimal top_tb/dut/mem_stage/new_pc_o
add wave -noupdate -group {Register File} -divider {CLK & RSN}
add wave -noupdate -group {Register File} /top_tb/dut/segre_rf/clk_i
add wave -noupdate -group {Register File} /top_tb/dut/segre_rf/rsn_i
add wave -noupdate -group {Register File} -divider READ
add wave -noupdate -group {Register File} -radix hexadecimal top_tb/dut/segre_rf/raddr_a_i
add wave -noupdate -group {Register File} -radix hexadecimal top_tb/dut/segre_rf/data_a_o
add wave -noupdate -group {Register File} -radix hexadecimal top_tb/dut/segre_rf/raddr_b_i
add wave -noupdate -group {Register File} -radix hexadecimal top_tb/dut/segre_rf/data_b_o
add wave -noupdate -group {Register File} -divider WRITE
add wave -noupdate -group {Register File} -radix hexadecimal top_tb/dut/segre_rf/we_i
add wave -noupdate -group {Register File} -radix hexadecimal top_tb/dut/segre_rf/waddr_i
add wave -noupdate -group {Register File} -radix hexadecimal top_tb/dut/segre_rf/data_w_i
add wave -noupdate -group {Register File} -divider REGISTERS
add wave -noupdate -group {Register File} -expand -radix hexadecimal /top_tb/dut/segre_rf/rf_reg
add wave -noupdate -group {Register File} -radix hexadecimal top_tb/dut/segre_rf/rf_reg_aux
add wave -noupdate -group {Register File} -radix hexadecimal top_tb/dut/segre_rf/write_enable
add wave -noupdate -group Controller -divider {CLK & RSN}
add wave -noupdate -group Controller /top_tb/dut/controller/clk_i
add wave -noupdate -group Controller /top_tb/dut/controller/rsn_i
add wave -noupdate -group Controller -divider STATE
add wave -noupdate -group Controller /top_tb/dut/controller/next_state
add wave -noupdate -group Controller /top_tb/dut/controller/state
add wave -noupdate -group Controller /top_tb/dut/controller/state_o
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {446650 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 348
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {105636 ps} {552335 ps}
