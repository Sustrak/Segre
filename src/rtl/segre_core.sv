import segre_pkg::*;

module segre_core (
    // Clock and Reset
    input logic clk_i,
    input logic rsn_i,

    // Main memory signals
    input  logic mm_data_rdy_i,
    input  logic [DCACHE_LANE_SIZE-1:0] mm_rd_data_i,
    output logic [DCACHE_LANE_SIZE-1:0] mm_wr_data_o,
    output logic [ADDR_SIZE-1:0] mm_addr_o,
    output logic [ADDR_SIZE-1:0] mm_wr_addr_o,
    output logic mm_rd_o,
    output logic mm_wr_o
    //output memop_data_type_e mm_wr_data_type_o
);

core_if_t core_if;
core_id_t core_id;
core_pipeline_t core_pipeline;
rf_wdata_t rf_wdata;
decode_rf_t decode_rf;
core_mmu_t core_mmu;
core_hazards_t core_hazards;
core_stage_hazards_t stage_hazards;


logic controller_hazard;

core_fsm_state_e fsm_state;

//assign controller_hazard = stage_hazards.ifs | stage_hazards.id |
//                           stage_hazards.ex  | stage_hazards.tl | 
//                           stage_hazards.mem;

// HAZARD CONTROL
/*
always_comb begin : hazard_control
    if (core_hazards.tl) begin
        stage_hazards.ifs = 1;
        stage_hazards.id  = 1;
        stage_hazards.ex  = 1;
    end
    else if(core_hazards.ifs) begin
        stage_hazards.ifs = 1;
    end
    else begin
        stage_hazards.ifs = 0;
        stage_hazards.id  = 0;
        stage_hazards.ex  = 0;
        stage_hazards.tl  = 0;
        stage_hazards.mem = 0;
    end
end
*/
assign stage_hazards.ifs = 0;
assign stage_hazards.id  = 0;
assign stage_hazards.ex  = 0;
assign stage_hazards.mem = 0;

logic tl_hazard;

segre_if_stage if_stage (
    // Clock and Reset
    .clk_i              (clk_i),
    .rsn_i              (rsn_i),
    // Hazard
    .hazard_i           (tl_hazard),
    .hazard_o           (core_hazards.ifs),
    // FSM state
    .fsm_state_i        (fsm_state),
    // IF ID interface
    .instr_o            (core_id.instr),
    .pc_o               (core_id.pc),
    // WB interface
    .tkbr_i             (core_if.tkbr),
    .new_pc_i           (core_if.new_pc),
    .branch_completed_i (core_if.branch_completed),
    // MMU interface
    .mmu_data_i         (core_mmu.ic_mmu_data_rdy),
    .mmu_wr_data_i      (core_mmu.ic_data),
    .mmu_lru_index_i    (core_mmu.ic_lru_index),
    .ic_miss_o          (core_mmu.ic_miss),
    .ic_addr_o          (core_mmu.ic_addr_i),
    .ic_access_o        (core_mmu.ic_access)
);

segre_id_stage id_stage (
    // Clock and Reset
    .clk_i            (clk_i),
    .rsn_i            (rsn_i),
    // Hazard
    .hazard_i         (tl_hazard),
    // FSM State
    .fsm_state_i      (fsm_state),
    // IF ID interface   
    .instr_i          (core_id.instr),
    .pc_i             (core_id.pc),
    // Register file read operands
    .rf_raddr_a_o     (decode_rf.raddr_a),
    .rf_raddr_b_o     (decode_rf.raddr_b),
    .rf_data_a_i      (decode_rf.data_a),
    .rf_data_b_i      (decode_rf.data_b),
    // Bypass
    .bypass_data_i    (core_id.bypass_data),
    // ID EX interface   
    // ALU
    .alu_opcode_o     (core_pipeline.alu_opcode),
    .alu_src_a_o      (core_pipeline.alu_src_a),
    .alu_src_b_o      (core_pipeline.alu_src_b),
    // Register file
    .rf_we_o          (core_pipeline.rf_we),
    .rf_waddr_o       (core_pipeline.rf_waddr),
    // Memop
    .memop_type_o     (core_pipeline.memop_type),
    .memop_rd_o       (core_pipeline.memop_rd),
    .memop_wr_o       (core_pipeline.memop_wr),
    .memop_sign_ext_o (core_pipeline.memop_sign_ext),
    .memop_rf_data_o  (core_pipeline.rf_st_data),
    // Branch | Jump
    .br_src_a_o       (core_pipeline.br_src_a),
    .br_src_b_o       (core_pipeline.br_src_b),
    // Pipeline
    .pipeline_o       (core_pipeline.pipeline),
    // Bypass
    .bypass_a_o       (core_pipeline.bypass_a),
    .bypass_b_o       (core_pipeline.bypass_b)
);

segre_pipeline_wrapper pipeline_wrapper (
    // Clock & Reset
    .clk_i                 (clk_i),
    .rsn_i                 (rsn_i),
    // Decode information
    .core_pipeline_i       (core_pipeline),
    // Register File
    .rf_data_o             (rf_wdata),
    // Branch & Jump
    .branch_completed_o    (core_if.branch_completed),
    .tkbr_o                (core_if.tkbr),
    .new_pc_o              (core_if.new_pc),
    // MMU
    .mmu_data_rdy_i        (core_mmu.dc_mmu_data_rdy),
    .mmu_addr_i            (core_mmu.dc_mm_addr_o),
    .mmu_data_i            (core_mmu.dc_data_o),
    .mmu_lru_index_i       (core_mmu.dc_lru_index),
    .mmu_miss_o            (core_mmu.dc_miss),
    .mmu_addr_o            (core_mmu.dc_addr_i),
    .mmu_cache_access_o    (core_mmu.dc_access),
    .mmu_data_o            (core_mmu.dc_data_i),
    .mmu_writeback_o       (core_mmu.dc_mmu_writeback),
    // Bypass
    .bypass_data_o         (core_id.bypass_data),
    // Hazard
    .tl_hazard_o           (tl_hazard)
);

segre_register_file segre_rf (
    // Clock and Reset
    .clk_i       (clk_i),
    .rsn_i       (rsn_i),

    .raddr_a_i   (decode_rf.raddr_a),
    .data_a_o    (decode_rf.data_a),
    .raddr_b_i   (decode_rf.raddr_b),
    .data_b_o    (decode_rf.data_b),
    .wdata_i     (rf_wdata)
);

segre_controller controller (
    // Clock and Reset
    .clk_i (clk_i),
    .rsn_i (rsn_i),
    .hazard_i (1'b0),

    // State
    .state_o (fsm_state)
);

segre_mmu mmu (
    .clk_i                (clk_i),
    .rsn_i                (rsn_i),
    // Data chache
    .dc_miss_i            (core_mmu.dc_miss),
    .dc_addr_i            (core_mmu.dc_addr_i),
    .dc_writeback_i       (core_mmu.dc_mmu_writeback),
    .dc_data_i            (core_mmu.dc_data_i),
    .dc_access_i          (core_mmu.dc_access),
    .dc_mmu_data_rdy_o    (core_mmu.dc_mmu_data_rdy),
    .dc_data_o            (core_mmu.dc_data_o),
    .dc_lru_index_o       (core_mmu.dc_lru_index),
    .dc_mm_addr_o         (core_mmu.dc_mm_addr_o),
    // Instruction cache
    .ic_miss_i            (core_mmu.ic_miss),
    .ic_addr_i            (core_mmu.ic_addr_i),
    .ic_access_i          (core_mmu.ic_access),
    .ic_mmu_data_rdy_o    (core_mmu.ic_mmu_data_rdy),
    .ic_data_o            (core_mmu.ic_data),
    .ic_lru_index_o       (core_mmu.ic_lru_index),
    // Main memory
    .mm_data_rdy_i        (mm_data_rdy_i),
    .mm_data_i            (mm_rd_data_i), // If $D and $I have different LANE_SIZE we need to change this
    .mm_rd_req_o          (mm_rd_o),
    .mm_wr_req_o          (mm_wr_o),
    //.mm_wr_data_type_o    (mm_wr_data_type_o),
    .mm_addr_o            (mm_addr_o),
    .mm_wr_addr_o         (mm_wr_addr_o),
    .mm_data_o            (mm_wr_data_o)
);

endmodule : segre_core