import segre_pkg::*;

module segre_core (
    // Clock and Reset
    input logic clk_i,
    input logic rsn_i,

    // Main memory signals
    input  logic mm_data_rdy_i,
    input  logic [DCACHE_LANE_SIZE-1:0] mm_rd_data_i,
    output logic [WORD_SIZE-1:0] mm_wr_data_o,
    output logic [ADDR_SIZE-1:0] mm_addr_o,
    output logic [ADDR_SIZE-1:0] mm_wr_addr_o,
    output logic mm_rd_o,
    output logic mm_wr_o,
    output memop_data_type_e mm_wr_data_type_o
);

core_if_t core_if;
core_id_t core_id;
core_ex_t core_ex;
core_tl_t core_tl;
core_mem_t core_mem;
core_rf_t core_rf;
core_mmu_t core_mmu;
core_hazards_t core_hazards;
core_stage_hazards_t stage_hazards;

core_fsm_state_e fsm_state;

// HAZARD CONTROL
always_comb begin : hazard_control
    if (core_hazards.tl) begin
        stage_hazards.ifs = 1;
        stage_hazards.id  = 1;
        stage_hazards.ex  = 1;
    end
    else begin
        stage_hazards.ifs = 0;
        stage_hazards.id  = 0;
        stage_hazards.ex  = 0;
        stage_hazards.tl  = 0;
        stage_hazards.mem = 0;
    end
end

segre_if_stage if_stage (
    // Clock and Reset
    .clk_i (clk_i),
    .rsn_i (rsn_i),
    // Hazard
    .hazard_i    (stage_hazards.ifs),
    // Memory
    .instr_i     (mem_rd_data_i),
    .pc_o        (core_if.addr),
    .mem_rd_o    (core_if.mem_rd),
    // FSM state
    .fsm_state_i (fsm_state),
    // IF ID interface
    .instr_o     (core_id.instr),
    // WB interface
    .tkbr_i      (core_if.tkbr),
    .new_pc_i    (core_if.new_pc)
);

segre_id_stage id_stage (
    // Clock and Reset
    .clk_i            (clk_i),
    .rsn_i            (rsn_i),
    // Hazard
    .hazard_i         (stage_hazards.id),
    // FSM State
    .fsm_state_i      (fsm_state),
    // IF ID interface
    .instr_i          (core_id.instr),
    .pc_i             (core_if.addr),
    // Register file read operands
    .rf_raddr_a_o     (core_rf.raddr_a),
    .rf_raddr_b_o     (core_rf.raddr_b),
    .rf_data_a_i      (core_rf.data_a),
    .rf_data_b_i      (core_rf.data_b),
    // ID EX interface
    // ALU
    .alu_opcode_o     (core_ex.alu_opcode),
    .alu_src_a_o      (core_ex.alu_src_a),
    .alu_src_b_o      (core_ex.alu_src_b),
    // Register file
    .rf_we_o          (core_ex.rf_we),
    .rf_waddr_o       (core_ex.rf_waddr),
    // Memop
    .memop_type_o      (core_ex.memop_type),
    .memop_rd_o        (core_ex.memop_rd),
    .memop_wr_o        (core_ex.memop_wr),
    .memop_sign_ext_o  (core_ex.memop_sign_ext),
    .memop_rf_data_o   (core_ex.rf_st_data),
    // Branch | Jump
    .br_src_a_o        (core_ex.br_src_a),
    .br_src_b_o        (core_ex.br_src_b)
);

segre_ex_stage ex_stage (
    // Clock and Reset
    .clk_i            (clk_i),
    .rsn_i            (rsn_i),
    
    // Hazards
    .hazard_i         (stage_hazards.ex),

    // ID EX interface
    // ALU
    .alu_opcode_i     (core_ex.alu_opcode),
    .alu_src_a_i      (core_ex.alu_src_a),
    .alu_src_b_i      (core_ex.alu_src_b),
    // Register file
    .rf_we_i          (core_ex.rf_we),
    .rf_waddr_i       (core_ex.rf_waddr),
    .rf_st_data_i     (core_ex.rf_st_data),
    // Memop
    .memop_type_i      (core_ex.memop_type),
    .memop_rd_i        (core_ex.memop_rd),
    .memop_wr_i        (core_ex.memop_wr),
    .memop_sign_ext_i  (core_ex.memop_sign_ext),
    // Branch | Jump
    .br_src_a_i        (core_ex.br_src_a),
    .br_src_b_i        (core_ex.br_src_b),

    // EX TL interface
    // ALU
    .alu_res_o        (core_tl.alu_res),
    // Register file
    .rf_we_o          (core_tl.rf_we),
    .rf_waddr_o       (core_tl.rf_waddr),
    .rf_st_data_o     (core_tl.rf_st_data),
    // Memop
    .memop_type_o     (core_tl.memop_type),
    .memop_rd_o       (core_tl.memop_rd),
    .memop_wr_o       (core_tl.memop_wr),
    .memop_sign_ext_o (core_tl.memop_sign_ext),
    // Branch | Jal
    .tkbr_o           (core_tl.tkbr),
    .new_pc_o         (core_tl.new_pc)
);

segre_tl_stage tl_stage(
    .clk_i             (clk_i),
    .rsn_i             (rsn_i),
    // EX TL interface
    // ALU
    .alu_res_i          (core_tl.alu_res),
    // Register file
    .rf_we_i            (core_tl.rf_we),
    .rf_waddr_i         (core_tl.rf_waddr),
    .rf_st_data_i       (core_tl.rf_st_data),
    // Memop
    .memop_rd_i         (core_tl.memop_rd),
    .memop_wr_i         (core_tl.memop_wr),
    .memop_sign_ext_i   (core_tl.memop_sign_ext),
    .memop_type_i       (core_tl.memop_type),
    // Tkbr
    .tkbr_i             (core_tl.tkbr),
    .new_pc_i           (core_tl.new_pc),

    // TL MEM interface
    // ALU
    .alu_res_o          (core_mem.alu_res),
    // Register file
    .rf_we_o            (core_mem.rf_we),
    .rf_waddr_o         (core_mem.rf_waddr),
    // Memop
    .memop_rd_o         (core_mem.memop_rd),
    .memop_wr_o         (core_mem.memop_wr),
    .memop_sign_ext_o   (core_mem.memop_sign_ext),
    .memop_type_o       (core_mem.memop_type),
    // Tkbr
    .tkbr_o             (core_mem.tkbr),
    .new_pc_o           (core_mem.new_pc),
    // Store buffer
    .sb_hit_o           (core_mem.sb_hit),
    .sb_data_o          (core_mem.sb_data),
    .sb_addr_o          (core_mem.sb_addr),

    // MMU interface
    .mmu_data_rdy_i     (core_mmu.dc_mmu_data_rdy),
    .mmu_data_i         (core_mmu.dc_data_o),
    .mmu_addr_i         (core_mmu.dc_addr_o),
    .mmu_miss_o         (core_mmu.dc_miss),
    .mmu_addr_o         (core_mmu.dc_addr_i),
    .mmu_cache_access_o (core_mmu.dc_access),

    // Hazard
    .pipeline_hazard_o  (core_hazards.tl)
);

segre_mem_stage mem_stage (
    // Clock and Reset
    .clk_i            (clk_i),
    .rsn_i            (rsn_i),

    // TL MEM interface
    // ALU
    .alu_res_i        (core_mem.alu_res),
    // Register file
    .rf_we_i          (core_mem.rf_we),
    .rf_waddr_i       (core_mem.rf_waddr),
    .rf_st_data_i     (core_mem.rf_st_data),
    // Memop
    .memop_type_i     (core_mem.memop_type),
    .memop_rd_i       (core_mem.memop_rd),
    .memop_wr_i       (core_mem.memop_wr),
    .memop_sign_ext_i (core_mem.memop_sign_ext),
    // Branch | Jal
    .tkbr_i           (core_mem.tkbr),
    .new_pc_i         (core_mem.new_pc),
    // Store Buffer
    .sb_hit_i         (core_mem.sb_hit),
    .sb_data_i        (core_mem.sb_data),
    .sb_addr_i        (core_mem.sb_addr),

    // MEM WB intereface
    .op_res_o         (core_rf.data_w),
    .rf_we_o          (core_rf.we),
    .rf_waddr_o       (core_rf.waddr_w),
    .tkbr_o           (core_if.tkbr),
    .new_pc_o         (core_if.new_pc)
);

segre_register_file segre_rf (
    // Clock and Reset
    .clk_i       (clk_i),
    .rsn_i       (rsn_i),

    .we_i        (core_rf.we),
    .raddr_a_i   (core_rf.raddr_a),
    .data_a_o    (core_rf.data_a),
    .raddr_b_i   (core_rf.raddr_b),
    .data_b_o    (core_rf.data_b),
    .waddr_i     (core_rf.waddr_w),
    .data_w_i    (core_rf.data_w)
);

segre_controller controller (
    // Clock and Reset
    .clk_i (clk_i),
    .rsn_i (rsn_i),

    // State
    .state_o (fsm_state)
);

segre_mmu mmu (
    .clk_i             (clk_i),
    .rsn_i             (rsn_i),
    // Data chache
    .dc_miss_i         (core_mmu.dc_miss),
    .dc_addr_i         (core_mmu.dc_addr_i),
    .dc_store_i        (core_mmu.dc_store),
    .dc_data_i         (core_mmu.dc_data_i),
    .dc_access_i       (core_mmu.dc_access),
    .dc_mmu_data_rdy_o (core_mmu.dc_mmu_data_rdy),
    .dc_data_o         (core_mmu.dc_data_o),
    .dc_addr_o         (core_mmu.dc_addr_o),
    // Instruction cache
    .ic_miss_i         (core_mmu.ic_miss),
    .ic_addr_i         (core_mmu.ic_addr_i),
    .ic_access_i       (core_mmu.ic_access),
    .ic_mmu_data_rdy_o (core_mmu.ic_mmu_data_rdy),
    .ic_data_o         (core_mmu.ic_data),
    .ic_addr_o         (core_mmu.ic_addr_o),
    // Main memory
    .mm_data_rdy_i     (mm_data_rdy_i),
    .mm_data_i         (mm_rd_data_i), // If $D and $I have different LANE_SIZE we need to change this
    .mm_rd_req_o       (mm_rd_o),
    .mm_wr_req_o       (mm_wr_o),
    .mm_wr_data_type_o (mm_wr_data_type_o),
    .mm_addr_o         (mm_addr_o),
    .mm_wr_addr_o      (mm_wr_addr_o),
    .mm_data_o         (mm_wr_data_o)
);

endmodule : segre_core