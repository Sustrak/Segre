import segre_pkg::*;

module segre_bypass_controller (
    // Clock and Reset
    input logic clk_i,
    input logic rsn_i,

    // Source registers
    input logic [REG_SIZE-1:0] src_a_i,
    input logic [REG_SIZE-1:0] src_b_i,
    input opcode_e instr_opcode_i,

    // Instruction data stages
    input logic [REG_SIZE-1:0]                     dst_ex_stage_i,
    input logic [REG_SIZE-1:0]                     dst_tl_stage_i,
    input logic [REG_SIZE-1:0]                     dst_mem_stage_i,
    input logic [REG_SIZE-1:0][RVM_NUM_STAGES-1:0] dst_rvm_stages_i,
    input logic [REG_SIZE-1:0]                     dst_wb_stage_i,

    output bypass_src_reg_t ex_ex_o;
    output bypass_src_reg_t mem_mem_o;

);

endmodule : segre_bypass_controller