import segre_pkg::*;

module segre_ex_stage (
    // Clock and Reset
    input logic clk_i,
    input logic rsn_i,
    
    // Kill
    input logic kill_i,
    
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
    // CSR file
    input logic csr_access_i,
    input logic [CSR_SIZE-1:0] csr_waddr_i,
    // Branch | Jal
    input logic [WORD_SIZE-1:0] br_src_a_i,
    input logic [WORD_SIZE-1:0] br_src_b_i,
    // Instruction ID
    input logic [HF_PTR-1:0] instr_id_i,

    // EX RF interface
    // ALU
    output logic [WORD_SIZE-1:0] alu_res_o,
    // Register file
    output logic rf_we_o,
    output logic [REG_SIZE-1:0] rf_waddr_o,
    // CSR file
    output logic csr_access_o,
    output logic [CSR_SIZE-1:0] csr_waddr_o,
    output logic [WORD_SIZE-1:0] csr_data_o,
    // Tkbr
    output logic branch_completed_o,
    output logic tkbr_o,
    output logic [WORD_SIZE-1:0] new_pc_o,
    // Instruction ID
    output logic [HF_PTR-1:0] instr_id_o
);

logic [WORD_SIZE-1:0] alu_res;
logic tkbr, branch_completed;

segre_alu alu (
    // Clock and Reset
    .clk_i (clk_i),
    .rsn_i (rsn_i),

    .alu_opcode_i (alu_opcode_i),
    .alu_src_a_i  (alu_src_a_i),
    .alu_src_b_i  (alu_src_b_i),

    .alu_res_o (alu_res)
);

segre_tkbr tkbr_inst (
    .br_src_a_i         (br_src_a_i),
    .br_src_b_i         (br_src_b_i),
    .alu_opcode_i       (alu_opcode_i),
    .tkbr_o             (tkbr),
    .branch_completed_o (branch_completed)
);

always_ff @(posedge clk_i) begin
    if (!rsn_i) begin
        alu_res_o        <= 0;
        rf_we_o          <= 0;
        rf_waddr_o       <= 0;
        tkbr_o           <= 0;
        new_pc_o         <= 0;
        instr_id_o       <= 0;
        csr_access_o     <= 0;
    end
    else if (!hazard_i) begin
        alu_res_o          <= (alu_opcode_i == ALU_JAL || alu_opcode_i == ALU_JALR) ? br_src_a_i : alu_res;
        rf_we_o            <= !kill_i & rf_we_i;
        rf_waddr_o         <= rf_waddr_i;
        tkbr_o             <= !kill_i & tkbr;
        new_pc_o           <= alu_res;
        branch_completed_o <= !kill_i & branch_completed;
        instr_id_o         <= instr_id_i;
        csr_access_o       <= !kill_i & csr_access_i;
        csr_waddr_o        <= csr_waddr_i;
        csr_data_o         <= alu_src_a_i;
    end
end


endmodule : segre_ex_stage
