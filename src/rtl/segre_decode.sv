import segre_pkg::*;

`define REG_RS1 19:15
`define REG_RS2 24:20
`define REG_RD 11:7
`define FUNC_3 14:12
`define FUNC_7 31:25

module segre_decode(
    // Clock and Reset
    input logic clk_i,
    input logic rsn_i,

    input logic [WORD_SIZE-1:0] instr_i,

    // Immediates
    output logic [WORD_SIZE-1:0] imm_u_type_o,
    output logic [WORD_SIZE-1:0] imm_i_type_o,
    output logic [WORD_SIZE-1:0] imm_s_type_o,
    output logic [WORD_SIZE-1:0] imm_j_type_o,
    output logic [WORD_SIZE-1:0] imm_b_type_o,

    // ALU
    output alu_opcode_e alu_opcode_o,
    output alu_src_a_e  src_a_mux_sel_o,
    output alu_src_b_e  src_b_mux_sel_o,
    output alu_imm_a_e  a_imm_mux_sel_o,
    output alu_imm_b_e  b_imm_mux_sel_o,
    output br_src_a_e   br_a_mux_sel_o,
    output br_src_b_e   br_b_mux_sel_o,

    // Register file
    output logic [REG_SIZE-1:0] raddr_a_o,
    output logic [REG_SIZE-1:0] raddr_b_o,
    output logic [REG_SIZE-1:0] waddr_o,
    output logic rf_we_o,

    // Memop
    output memop_data_type_e memop_type_o,
    output logic memop_sign_ext_o,
    output logic memop_rd_o,
    output logic memop_wr_o
);

opcode_e instr_opcode;
opcode_e alu_instr_opcode;

logic illegal_ins;

assign imm_i_type_o = { {20{instr_i[31]}}, instr_i[31:20] };
assign imm_u_type_o = { instr_i[31:12], 12'b0 };
assign imm_s_type_o = { {20{instr_i[31]}}, instr_i[31:25], instr_i[11:7] };
assign imm_j_type_o = { {12{instr_i[31]}}, instr_i[19:12], instr_i[20], instr_i[30:21], 1'b0 };
assign imm_b_type_o = { {19{instr_i[31]}}, instr_i[31], instr_i[7], instr_i[30:25], instr_i[11:8], 1'b0 };

// Source registers
assign raddr_a_o = instr_i[`REG_RS1];
assign raddr_b_o = instr_i[`REG_RS2];

// Destination registers
assign waddr_o = instr_i[`REG_RD];

/*****************
*    DECODER     *
*****************/
always_comb begin
    rf_we_o          = 1'b0;
    illegal_ins      = 1'b0;
    memop_rd_o       = 1'b0;
    memop_wr_o       = 1'b0;
    memop_sign_ext_o = 1'b0;
    memop_type_o     = WORD;
    instr_opcode     = opcode_e'(instr_i[6:0]);

    unique case(instr_opcode)

        /*****************
        *      ALU       *
        *****************/
        OPCODE_LUI: begin // Load Upper Immediate
            rf_we_o = 1'b1;
        end
        OPCODE_OP_IMM: begin
            rf_we_o = 1'b1;
        end
        OPCODE_OP: begin
            rf_we_o = 1'b1;
        end
        OPCODE_LOAD: begin
            rf_we_o = 1'b1;
            memop_rd_o = 1'b1;
            memop_sign_ext_o = ~instr_i[14];
            unique case(instr_i[`FUNC_3])
                3'b000, 3'b100: memop_type_o = BYTE;
                3'b001, 3'b101: memop_type_o = HALF;
                3'b010:         memop_type_o = WORD;
                default: ;
            endcase
        end
        OPCODE_STORE: begin
            memop_wr_o = 1'b1;
            unique case(instr_i[`FUNC_3])
                3'b000: memop_type_o = BYTE;
                3'b001: memop_type_o = HALF;
                3'b010: memop_type_o = WORD;
                default: ;
            endcase
        end
        OPCODE_JAL: begin
            rf_we_o = 1'b1;
        end
        OPCODE_JALR: begin
            rf_we_o = 1'b1;
        end
        OPCODE_AUIPC: begin
            rf_we_o = 1'b1;
        end
        default: begin
            if (rsn_i) begin
                illegal_ins = 1'b1;
                assert (0) else $display("OPCODE: %h not implemented", instr_opcode);
            end
        end
    endcase
end

/********************
* ALU LOGIC DECODER *
*********************/
always_comb begin
    src_a_mux_sel_o = ALU_A_REG;
    src_b_mux_sel_o = ALU_B_REG;
    a_imm_mux_sel_o = IMM_A_ZERO;
    b_imm_mux_sel_o = IMM_B_U;
    br_b_mux_sel_o  = BR_B_REG;
    br_a_mux_sel_o  = BR_A_REG;
    alu_instr_opcode      = opcode_e'(instr_i[6:0]);

    unique case(alu_instr_opcode)

        /*****************
        *      ALU       *
        *****************/
        OPCODE_LUI: begin // Load Upper Immediate
            src_a_mux_sel_o = ALU_A_IMM;
            src_b_mux_sel_o = ALU_B_IMM;
            a_imm_mux_sel_o = IMM_A_ZERO;
            b_imm_mux_sel_o = IMM_B_U;
            alu_opcode_o    = ALU_ADD;
        end
        OPCODE_OP_IMM: begin
            src_a_mux_sel_o = ALU_A_REG;
            src_b_mux_sel_o = ALU_B_IMM;
            b_imm_mux_sel_o = IMM_B_I;
            unique case (instr_i[`FUNC_3])
                3'b000: alu_opcode_o = ALU_ADD;  // ADDI
                3'b010: alu_opcode_o = ALU_SLT;  // SLTI
                3'b011: alu_opcode_o = ALU_SLTU; // SLTIU
                3'b100: alu_opcode_o = ALU_XOR;  // XORI
                3'b110: alu_opcode_o = ALU_OR;   // ORI
                3'b111: alu_opcode_o = ALU_AND;  // ANDI
                3'b001: alu_opcode_o = ALU_SLL;  // SSLI
                3'b101: begin
                    unique case(instr_i[`FUNC_7])
                        7'b000_0000: alu_opcode_o = ALU_SRL; // SRLI
                        7'b010_0000: alu_opcode_o = ALU_SRA; // SRAI
                        default: ;
                    endcase
                end
                default: ;
            endcase
        end
        OPCODE_OP: begin
            src_a_mux_sel_o = ALU_A_REG;
            src_b_mux_sel_o = ALU_B_REG;
            unique case ({instr_i[`FUNC_7], instr_i[`FUNC_3]})
                {7'b000_0000, 3'b000}: alu_opcode_o = ALU_ADD;  // ADD
                {7'b010_0000, 3'b000}: alu_opcode_o = ALU_SUB;  // SUB
                {7'b000_0000, 3'b001}: alu_opcode_o = ALU_SLL;  // SLL
                {7'b000_0000, 3'b010}: alu_opcode_o = ALU_SLT;  // SLT
                {7'b000_0000, 3'b011}: alu_opcode_o = ALU_SLTU; // SLTU
                {7'b000_0000, 3'b100}: alu_opcode_o = ALU_XOR;  // XOR
                {7'b000_0000, 3'b101}: alu_opcode_o = ALU_SRL;  // SRL
                {7'b010_0000, 3'b101}: alu_opcode_o = ALU_SRA;  // SRA
                {7'b000_0000, 3'b110}: alu_opcode_o = ALU_OR;   // OR
                {7'b000_0000, 3'b111}: alu_opcode_o = ALU_AND;  // AND
                default: ;
            endcase
        end
        OPCODE_LOAD: begin
            src_a_mux_sel_o = ALU_A_REG;
            src_b_mux_sel_o = ALU_B_IMM;
            b_imm_mux_sel_o = IMM_B_I;
            alu_opcode_o = ALU_ADD;
        end
        OPCODE_STORE: begin
            src_a_mux_sel_o = ALU_A_REG;
            src_b_mux_sel_o = ALU_B_IMM;
            b_imm_mux_sel_o = IMM_B_S;
            alu_opcode_o = ALU_ADD;
        end
        OPCODE_JAL: begin
            src_a_mux_sel_o = ALU_A_PC;
            src_b_mux_sel_o = ALU_B_IMM;
            br_a_mux_sel_o  = BR_A_PC;
            b_imm_mux_sel_o = IMM_B_J;
            alu_opcode_o    = ALU_JAL;
        end
        OPCODE_JALR: begin
            src_a_mux_sel_o = ALU_A_REG;
            src_b_mux_sel_o = ALU_B_IMM;
            b_imm_mux_sel_o = IMM_B_I;
            br_a_mux_sel_o  = BR_A_PC;
            alu_opcode_o    = ALU_JALR;
        end
        OPCODE_BRANCH: begin
            src_a_mux_sel_o = ALU_A_PC;
            src_b_mux_sel_o = ALU_B_IMM;
            b_imm_mux_sel_o = IMM_B_B;
            br_a_mux_sel_o  = BR_A_REG;
            br_b_mux_sel_o  = BR_B_REG;
            unique case (instr_i[`FUNC_3])
                3'b000: alu_opcode_o = ALU_BEQ;
                3'b001: alu_opcode_o = ALU_BNE;
                3'b100: alu_opcode_o = ALU_BLT;
                3'b101: alu_opcode_o = ALU_BGE;
                3'b110: alu_opcode_o = ALU_BLTU;
                3'b111: alu_opcode_o = ALU_BGEU;
                default: ;
            endcase
        end
        OPCODE_AUIPC: begin
            src_a_mux_sel_o = ALU_A_PC;
            src_b_mux_sel_o = ALU_B_IMM;
            b_imm_mux_sel_o = IMM_B_U;
            alu_opcode_o    = ALU_ADD;
        end
        default: ;
    endcase
end

endmodule
