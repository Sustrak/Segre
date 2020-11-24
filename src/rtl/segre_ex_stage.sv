import segre_pkg::*;

module segre_ex_stage (
    // Clock and Reset
    input logic clk_i,
    input logic rsn_i,
    
    // Hazard
    input logic hazard_i,

    // ID EX interface
    // ALU
    input alu_opcode_e alu_opcode_i,
    input logic [WORD_SIZE-1:0] alu_src_a_i,
    input logic [WORD_SIZE-1:0] alu_src_b_i,
    // Register file
    input logic rf_we_i,
    input logic [REG_SIZE-1:0] rf_waddr_i,
    input logic [WORD_SIZE-1:0] rf_st_data_i,
    // Memop
    input memop_data_type_e memop_type_i,
    input logic memop_rd_i,
    input logic memop_wr_i,
    input logic memop_sign_ext_i,
    // Branch | Jal
    input logic [WORD_SIZE-1:0] br_src_a_i,
    input logic [WORD_SIZE-1:0] br_src_b_i,

    // EX TL interface
    // ALU
    output logic [WORD_SIZE-1:0] alu_res_o,
    // Register file
    output logic rf_we_o,
    output logic [REG_SIZE-1:0] rf_waddr_o,
    output logic [WORD_SIZE-1:0] rf_st_data_o,
    // Memop
    output memop_data_type_e memop_type_o,
    output logic memop_rd_o,
    output logic memop_wr_o,
    output logic memop_sign_ext_o,
    // Tkbr
    output logic tkbr_o,
    output logic [WORD_SIZE-1:0] new_pc_o
);

logic [WORD_SIZE-1:0] alu_res;
logic tkbr;

segre_alu alu (
    // Clock and Reset
    .clk_i (clk_i),
    .rsn_i (rsn_i),

    .alu_opcode_i (alu_opcode_i),
    .alu_src_a_i  (alu_src_a_i),
    .alu_src_b_i  (alu_src_b_i),

    .alu_res_o (alu_res)
);

segre_tkbr trbr (
    .br_src_a_i   (br_src_a_i),
    .br_src_b_i   (br_src_b_i),
    .alu_opcode_i (alu_opcode_i),
    .tkbr_o       (tkbr)
);

always_ff @(posedge clk_i) begin
    if (!hazard_i) begin
        alu_res_o        <= (alu_opcode_i == ALU_JAL || alu_opcode_i == ALU_JALR) ? br_src_a_i : alu_res;
        rf_we_o          <= rf_we_i;
        rf_waddr_o       <= rf_waddr_i;
        rf_st_data_o     <= rf_st_data_i;
        memop_type_o     <= memop_type_i;
        memop_rd_o       <= memop_rd_i;
        memop_wr_o       <= memop_wr_i;
        memop_sign_ext_o <= memop_sign_ext_i;
        tkbr_o           <= tkbr;
        new_pc_o         <= alu_res;
    end else begin
        rf_we_o    <= 0;
        memop_rd_o <= 0;
        memop_wr_o <= 0;
        tkbr_o     <= 0;
    end
end


endmodule : segre_ex_stage
