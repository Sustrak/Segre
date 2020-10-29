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
logic [WORD_SIZE*2-1:0] mul_res;
logic [WORD_SIZE*2-1:0] mulu_res;
logic [WORD_SIZE*2-1:0] mulsu_res;
logic [WORD_SIZE-1:0] div_res;
logic [WORD_SIZE-1:0] divu_res;
logic [WORD_SIZE-1:0] rem_res;
logic [WORD_SIZE-1:0] remu_res;

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
        ALU_MUL   : alu_res = mul_res[WORD_SIZE-1:0];
        ALU_MULH  : alu_res = mul_res[WORD_SIZE*2-1:WORD_SIZE];
        ALU_MULHU : alu_res = mulu_res[WORD_SIZE*2-1:WORD_SIZE];
        ALU_MULHSU: alu_res = mulsu_res[WORD_SIZE*2-1:WORD_SIZE];
        ALU_DIV   : alu_res = div_res;
        ALU_DIVU  : alu_res = divu_res;
        ALU_REM   : alu_res = rem_res;
        ALU_REMU  : alu_res = remu_res;
        default: ;
    endcase
end

always_comb begin
    mul_res = $signed(alu_src_b_i) * $signed(alu_src_b_i);
    mulu_res = $unsigned(alu_src_b_i) * $unsigned(alu_src_b_i);
    mulsu_res = alu_src_a_i[WORD_SIZE-1] ? - $signed(mulu_res) : mulu_res;
    
    // DIV
    if (alu_src_b_i == 0) begin
        div_res = {WORD_SIZE{1'b1}};
    end
    else if (alu_src_a_i == 32'h8000_0000 && alu_src_b_i == 32'hffff_ffff) begin
        div_res = 32'h8000_0000;
    end
    else begin
        div_res = $signed(alu_src_a_i) / $signed(alu_src_b_i);
    end
    
    // DIVU
    if (alu_src_b_i == 0) begin
        div_res = {WORD_SIZE{1'b1}};
    end
    else begin
        div_res = $unsigned(alu_src_a_i) / $unsigned(alu_src_b_i);
    end
    
    // REM
    if (alu_src_b_i == 0) begin
        rem_res = alu_src_a_i;
    end
    else if (alu_src_a_i == 32'h8000_0000 && alu_src_b_i == 32'hffff_ffff) begin
        rem_res = 0;
    end
    else begin
        rem_res = $signed(alu_src_a_i) % $signed(alu_src_b_i);
    end

    // REMU
    if (alu_src_b_i == 0) begin
        rem_res = alu_src_a_i;
    end
    else begin
        rem_res = $unsigned(alu_src_a_i) % $unsigned(alu_src_b_i);
    end
end

assign alu_res_o = alu_res;

endmodule : segre_alu
