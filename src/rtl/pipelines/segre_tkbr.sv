import segre_pkg::*;

module segre_tkbr (
    input logic [WORD_SIZE-1:0] br_src_a_i,
    input logic [WORD_SIZE-1:0] br_src_b_i,
    input alu_opcode_e alu_opcode_i,
    output logic tkbr_o,
    output logic branch_completed_o
);

always_comb begin
    unique case(alu_opcode_i)
        ALU_BEQ : begin
            tkbr_o = ($signed(br_src_a_i) == $signed(br_src_b_i)) ? 1'b1 : 1'b0;
            branch_completed_o = 1'b1;
        end
        ALU_BNE : begin
            tkbr_o = ($signed(br_src_a_i) != $signed(br_src_b_i)) ? 1'b1 : 1'b0;
            branch_completed_o = 1'b1;
        end
        ALU_BLT : begin
            tkbr_o = ($signed(br_src_a_i) < $signed(br_src_b_i))  ? 1'b1 : 1'b0;
            branch_completed_o = 1'b1;
        end
        ALU_BGE : begin
            tkbr_o = ($signed(br_src_a_i) >= $signed(br_src_b_i)) ? 1'b1 : 1'b0;
            branch_completed_o = 1'b1;
        end
        ALU_BLTU: begin
            tkbr_o = ($unsigned(br_src_a_i) < $unsigned(br_src_b_i)) ? 1'b1 : 1'b0;
            branch_completed_o = 1'b1;
        end
        ALU_BGEU: begin
            tkbr_o = ($unsigned(br_src_a_i) >= $unsigned(br_src_b_i)) ? 1'b1 : 1'b0;
            branch_completed_o = 1'b1;
        end
        ALU_JAL, ALU_JALR: begin
            tkbr_o = 1'b1;
            branch_completed_o = 1'b1;
        end
        default: begin
            tkbr_o = 0;
            branch_completed_o = 0;
        end
    endcase
end
endmodule
