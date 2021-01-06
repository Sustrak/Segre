import segre_pkg::*;

module segre_rvm_pipeline (
    input logic clk_i,
    input logic rsn_i,
    
    // ALU
    input alu_opcode_e alu_opcode_i,
    input logic [WORD_SIZE-1:0] alu_src_a_i,
    input logic [WORD_SIZE-1:0] alu_src_b_i,
    // Register file
    input logic rf_we_i,
    input logic [REG_SIZE-1:0] rf_waddr_i,
    
    // ALU
    output logic [WORD_SIZE-1:0] alu_res_o,
    // Register file
    output logic rf_we_o,
    output logic [REG_SIZE-1:0] rf_waddr_o,

    // Bypass
    output logic rvm1_we_o,
    output logic [REG_SIZE-1:0] rvm1_waddr_o,
    output logic rvm2_we_o,
    output logic [REG_SIZE-1:0] rvm2_waddr_o,
    output logic rvm3_we_o,
    output logic [REG_SIZE-1:0] rvm3_waddr_o,
    output logic rvm4_we_o,
    output logic [REG_SIZE-1:0] rvm4_waddr_o
);

typedef struct packed {
    logic [WORD_SIZE-1:0] alu_res;
    logic rf_we;
    logic [REG_SIZE-1:0] rf_waddr;
} rvm_data_t;

rvm_data_t rvm_stage_1, rvm_stage_2, rvm_stage_3, rvm_stage_4, rvm_stage_5;

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

always_comb begin : output_logic
    if (!rsn_i) begin
        alu_res_o    = 0;
        rf_we_o      = 0;
        rf_waddr_o   = 0;
    end
    else begin
        alu_res_o    = rvm_stage_5.alu_res;
        rf_we_o      = rvm_stage_5.rf_we;
        rf_waddr_o   = rvm_stage_5.rf_waddr;
    end
end

always_comb begin : bypass_data
    rvm1_we_o    = rvm_stage_1.rf_we;
    rvm1_waddr_o = rvm_stage_1.rf_waddr;
    rvm2_we_o    = rvm_stage_2.rf_we;
    rvm2_waddr_o = rvm_stage_2.rf_waddr;
    rvm3_we_o    = rvm_stage_3.rf_we;
    rvm3_waddr_o = rvm_stage_3.rf_waddr;
    rvm4_we_o    = rvm_stage_4.rf_we;
    rvm4_waddr_o = rvm_stage_4.rf_waddr;
end

always_ff @(posedge clk_i) begin : latches
    rvm_stage_1.alu_res    <= alu_res;
    rvm_stage_1.rf_we      <= rf_we_i;
    rvm_stage_1.rf_waddr   <= rf_waddr_i;

    rvm_stage_2 <= rvm_stage_1;
    rvm_stage_3 <= rvm_stage_2;
    rvm_stage_4 <= rvm_stage_3;
    rvm_stage_5 <= rvm_stage_4;
end

endmodule : segre_rvm_pipeline