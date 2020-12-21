import segre_pkg::*;

module segre_alu (
    // Clock and Reset
    input logic clk_i,
    input logic rsn_i,

    input alu_opcode_e alu_opcode_i,
    input logic [WORD_SIZE-1:0] alu_src_a_i,
    input logic [WORD_SIZE-1:0] alu_src_b_i,

    output logic [WORD_SIZE-1:0] alu_res_o
);

logic [WORD_SIZE-1:0] alu_res;

always_comb begin
    unique case (alu_opcode_i)
        ALU_JAL, ALU_JALR, ALU_BEQ,
        ALU_BNE, ALU_BLT, ALU_BGE,
        ALU_BLTU, ALU_BGEU: alu_res = $unsigned(alu_src_a_i) + $signed(alu_src_b_i);
        ALU_ADD   : alu_res = $signed(alu_src_a_i) + $signed(alu_src_b_i);
        ALU_SUB   : alu_res = $signed(alu_src_a_i) - $signed(alu_src_b_i);
        ALU_SLL   : alu_res = $signed(alu_src_a_i) << $signed(alu_src_b_i[4:0]);
        ALU_SRL   : alu_res = $signed(alu_src_a_i) >> $signed(alu_src_b_i[4:0]);
        ALU_SRA   : alu_res = $signed(alu_src_a_i) >>> $signed(alu_src_b_i[4:0]);
        ALU_XOR   : alu_res = alu_src_a_i ^ alu_src_b_i;
        ALU_OR    : alu_res = alu_src_a_i | alu_src_b_i;
        ALU_AND   : alu_res = alu_src_a_i & alu_src_b_i;
        ALU_SLT   : alu_res = $signed(alu_src_a_i) < $signed(alu_src_b_i) ? 32'b1 : 32'b0;
        ALU_SLTU  : alu_res = $unsigned(alu_src_a_i) < $unsigned(alu_src_b_i) ? 32'b1 : 32'b0;
        default: ;
    endcase
end

assign alu_res_o = alu_res;

endmodule : segre_alu
