import segre_pkg::*;

module segre_id_stage (
    // Clock and Reset
    input logic clk_i,
    input logic rsn_i,

    // Hazard
    input logic hazard_i,
    output logic hazard_o,

    // IF and ID stage
    input logic [WORD_SIZE-1:0] instr_i,
    input logic [WORD_SIZE-1:0] pc_i,

    // Register file read operands
    output logic [REG_SIZE-1:0]  rf_raddr_a_o,
    output logic [REG_SIZE-1:0]  rf_raddr_b_o,
    output logic [REG_SIZE-1:0]  rf_raddr_w_o,
    input  logic [WORD_SIZE-1:0] rf_data_a_i,
    input  logic [WORD_SIZE-1:0] rf_data_b_i,
    
    // Bypass
    input bypass_data_t bypass_data_i,

    // ID EX interface
    // History File
    output logic instr_decoded_o,
    output logic [HF_PTR-1:0] instr_id_o,
    // ALU
    output alu_opcode_e alu_opcode_o,
    output logic [WORD_SIZE-1:0] alu_src_a_o,
    output logic [WORD_SIZE-1:0] alu_src_b_o,
    // Register file
    output logic rf_we_o,
    output logic [REG_SIZE-1:0] rf_waddr_o,
    // Memop
    output memop_data_type_e memop_type_o,
    output logic memop_sign_ext_o,
    output logic memop_rd_o,
    output logic memop_wr_o,
    output logic [WORD_SIZE-1:0] memop_rf_data_o,
    // Branch | Jump
    output logic [WORD_SIZE-1:0] br_src_a_o,
    output logic [WORD_SIZE-1:0] br_src_b_o,
    // Pipeline
    output pipeline_e pipeline_o,
    // Bypass
    output bypass_e bypass_a_o,
    output bypass_e bypass_b_o
);

opcode_e opcode;
opcode_e id_opcode;
logic [WORD_SIZE-1:0] imm_u_type;
logic [WORD_SIZE-1:0] imm_i_type;
logic [WORD_SIZE-1:0] imm_s_type;
logic [WORD_SIZE-1:0] imm_j_type;
logic [WORD_SIZE-1:0] imm_b_type;
alu_src_a_e src_a_mux_sel;
alu_src_b_e src_b_mux_sel;
alu_imm_a_e a_imm_mux_sel;
alu_imm_b_e b_imm_mux_sel;
br_src_a_e br_a_mux_sel;
br_src_b_e br_b_mux_sel;
logic [WORD_SIZE-1:0] imm_a;
logic [WORD_SIZE-1:0] imm_b;
logic [REG_SIZE-1:0] rf_src_a;
logic [REG_SIZE-1:0] rf_src_b;
logic [REG_SIZE-1:0] rf_raddr_a;
logic [REG_SIZE-1:0] rf_raddr_b;
logic [REG_SIZE-1:0] rf_waddr;
logic rf_we;
logic [WORD_SIZE-1:0] alu_src_a;
logic [WORD_SIZE-1:0] alu_src_b;
logic [WORD_SIZE-1:0] br_src_a;
logic [WORD_SIZE-1:0] br_src_b;
memop_data_type_e memop_type;
logic memop_rd;
logic memop_wr;
logic memop_sign_ext;
alu_opcode_e alu_opcode;
pipeline_e pipeline;
logic [WORD_SIZE-1:0] data_a;
logic [WORD_SIZE-1:0] data_b;
logic [HF_PTR-1:0] nxt_instr_id;
logic instr_decoded;

// Bypass
bypass_e bypass_a;
bypass_e bypass_b;

logic instr_dependence, war_dependence, waw_dependence;

assign rf_src_a = (opcode == OPCODE_LUI | opcode == OPCODE_AUIPC) ? 0 : rf_raddr_a;
assign rf_src_b = (id_opcode == OPCODE_LUI | id_opcode == OPCODE_AUIPC) ? 0 : rf_raddr_b;
assign rf_raddr_a_o = rf_raddr_a;
assign rf_raddr_b_o = rf_raddr_b;
assign rf_raddr_w_o = rf_waddr;
assign instr_dependence = war_dependence | waw_dependence;
assign hazard_o = instr_dependence | hazard_i;
assign instr_decoded = ~hazard_o & instr_i != NOP;

assign nxt_instr_id = instr_decoded ? (instr_id_o + 1) % HF_SIZE : instr_id_o;

segre_decode decode (
    // Clock and Reset
    .clk_i            (clk_i),
    .rsn_i            (rsn_i),

    .instr_i          (instr_i),
    .opcode_o         (opcode),

    // Immediates
    .imm_u_type_o     (imm_u_type),
    .imm_i_type_o     (imm_i_type),
    .imm_s_type_o     (imm_s_type),
    .imm_j_type_o     (imm_j_type),
    .imm_b_type_o     (imm_b_type),

    // ALU
    .alu_opcode_o     (alu_opcode),
    .src_a_mux_sel_o  (src_a_mux_sel),
    .src_b_mux_sel_o  (src_b_mux_sel),
    .a_imm_mux_sel_o  (a_imm_mux_sel),
    .b_imm_mux_sel_o  (b_imm_mux_sel),
    .br_a_mux_sel_o   (br_a_mux_sel),
    .br_b_mux_sel_o   (br_b_mux_sel),

    // Register file
    .raddr_a_o        (rf_raddr_a),
    .raddr_b_o        (rf_raddr_b),
    .waddr_o          (rf_waddr),
    .rf_we_o          (rf_we),

    // Memop
    .memop_type_o     (memop_type),
    .memop_rd_o       (memop_rd),
    .memop_wr_o       (memop_wr),
    .memop_sign_ext_o (memop_sign_ext),

    // Pipeline
    .pipeline_o       (pipeline)
);

segre_bypass_controller bypass_controller (
    // Clock and Reset
    .clk_i            (clk_i),
    .rsn_i            (rsn_i),

    // Source registers new instruction
    .src_a_i          (rf_src_a),
    .src_b_i          (rf_src_b),
    .src_dest_i       (rf_waddr),
    .instr_opcode_i   (opcode),
    .pipeline_i       (pipeline),
    
    // Destination register instruction from ID to PIPELINE
    .dst_id_i         (rf_waddr_o),
    .id_opcode_i      (id_opcode),
    .id_pipeline_i    (pipeline_o),
    
    // Pipeline info
    .pipeline_data_i  (bypass_data_i),
        
    // Output mux selection
    .bypass_a_o       (bypass_a),
    .bypass_b_o       (bypass_b),
    
    // Dependence
    .war_dependence_o (war_dependence),
    .waw_dependence_o (waw_dependence)
);

// For the moment imm_a will always be 0
assign imm_a = '0;

always_comb begin : alu_imm_b_mux
    unique case(b_imm_mux_sel)
        IMM_B_U: imm_b = imm_u_type;
        IMM_B_I: imm_b = imm_i_type;
        IMM_B_S: imm_b = imm_s_type;
        IMM_B_J: imm_b = imm_j_type;
        IMM_B_B: imm_b = imm_b_type;
        default: ;
    endcase
end

always_comb begin : alu_src_a_mux
    unique case(src_a_mux_sel)
        ALU_A_REG: alu_src_a = data_a;
        ALU_A_IMM: alu_src_a = imm_a;
        ALU_A_PC : alu_src_a = pc_i;
        default: ;
    endcase
end

always_comb begin : alu_src_b_mux
    unique case(src_b_mux_sel)
        ALU_B_REG: alu_src_b = data_b;
        ALU_B_IMM: alu_src_b = imm_b;
        default: ;
    endcase
end

always_comb begin : br_src_a_mux
    unique case (br_a_mux_sel)
        BR_A_REG: br_src_a = data_a;
        BR_A_PC : br_src_a = pc_i + 4; // Next PC
        default : ;
    endcase
end

always_comb begin : br_src_b_mux
    unique case (br_b_mux_sel)
        BR_B_REG: br_src_b = data_b;
        default: ;
    endcase
end

always_comb begin : bypass_data
    unique case (bypass_a)
        NO_BYPASS   : data_a = rf_data_a_i;
        BY_EX_ID    : data_a = bypass_data_i.ex_data;
        BY_MEM_ID   : data_a = bypass_data_i.mem_data;
        BY_RVM5_ID  : data_a = bypass_data_i.rvm5_data;
        default: data_a = rf_data_a_i;
    endcase

    unique case (bypass_b)
        NO_BYPASS   : data_b = rf_data_b_i;
        BY_EX_ID    : data_b = bypass_data_i.ex_data;
        BY_MEM_ID   : data_b = bypass_data_i.mem_data;
        BY_RVM5_ID  : data_b = bypass_data_i.rvm5_data;
        default: data_b = rf_data_b_i;
    endcase
end

always_ff @(posedge clk_i) begin
    if (!rsn_i) begin
        memop_wr_o      <= 0;
        memop_rd_o      <= 0;
        rf_we_o         <= 0;
        instr_decoded_o <= 0;
        instr_id_o      <= ~{HF_PTR{1'b0}};
    end
    else if (instr_dependence) begin
        rf_we_o         <= 0;
        memop_wr_o      <= 0;
        memop_rd_o      <= 0;
        instr_decoded_o <= 0;
    end
    else if (!hazard_i) begin
        alu_src_a_o      <= alu_src_a;
        alu_src_b_o      <= alu_src_b;
        rf_we_o          <= instr_i == NOP ? 1'b0 : rf_we;
        rf_waddr_o       <= rf_waddr;
        memop_sign_ext_o <= memop_sign_ext;
        memop_type_o     <= memop_type;
        memop_rd_o       <= memop_rd;
        memop_wr_o       <= memop_wr;
        br_src_a_o       <= br_src_a;
        br_src_b_o       <= br_src_b;
        alu_opcode_o     <= alu_opcode;
        memop_rf_data_o  <= rf_data_b_i;
        pipeline_o       <= pipeline;
        bypass_a_o       <= bypass_a;
        bypass_b_o       <= bypass_b;
        id_opcode        <= opcode;
        instr_id_o       <= nxt_instr_id;
        instr_decoded_o  <= instr_decoded;
    end
end

endmodule
