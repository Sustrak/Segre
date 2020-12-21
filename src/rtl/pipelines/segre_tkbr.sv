import segre_pkg::*;

module segre_tkbr (
    input logic [WORD_SIZE-1:0] br_src_a_i,
    input logic [WORD_SIZE-1:0] br_src_b_i,
    input alu_opcode_e alu_opcode_i,
    output logic tkbr_o
);

always_comb begin
    unique case(alu_opcode_i)
        ALU_BEQ : tkbr_o = ($signed(br_src_a_i) == $signed(br_src_b_i)) ? 1'b1 : 1'b0;
        ALU_BNE : tkbr_o = ($signed(br_src_a_i) != $signed(br_src_b_i)) ? 1'b1 : 1'b0;
        ALU_BLT : tkbr_o = ($signed(br_src_a_i) < $signed(br_src_b_i))  ? 1'b1 : 1'b0;
        ALU_BGE : tkbr_o = ($signed(br_src_a_i) >= $signed(br_src_b_i)) ? 1'b1 : 1'b0;
        ALU_BLTU: tkbr_o = ($unsigned(br_src_a_i) < $unsigned(br_src_b_i)) ? 1'b1 : 1'b0;
        ALU_BGEU: tkbr_o = ($unsigned(br_src_a_i) >= $unsigned(br_src_b_i)) ? 1'b1 : 1'b0;
        ALU_JAL, ALU_JALR: tkbr_o = 1'b1;
        default: tkbr_o = 0;
    endcase
end
endmodule
