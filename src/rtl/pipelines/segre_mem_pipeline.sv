import segre_pkg::*;

module segre_mem_pipeline(
    // Clock & Reset
    input logic clk_i,
    input logic rsn_i,
    
    // Kill
    input logic kill_i,
    
    input logic [WORD_SIZE-1:0] alu_src_a_i,
    input logic [WORD_SIZE-1:0] alu_src_b_i,
    input logic rf_we_i,
    input logic [REG_SIZE-1:0] rf_waddr_i,
    input logic [WORD_SIZE-1:0] rf_st_data_i,
    input logic memop_rd_i,
    input logic memop_wr_i,
    input logic memop_sign_ext_i,
    input memop_data_type_e memop_type_i,
    input logic [HF_PTR-1:0] instr_id_i,
    input logic store_permission_i,

    output logic [WORD_SIZE-1:0] data_o,
    output logic rf_we_o,
    output logic [REG_SIZE-1:0] rf_waddr_o,
    output logic [HF_PTR-1:0] instr_id_o,
    output logic mem_wr_done_o,
    output logic [HF_PTR-1:0] mem_wr_done_id_o,
    
    // MMU
    input logic mmu_data_rdy_i,
    input logic [ADDR_SIZE-1:0] mmu_addr_i,
    input logic [DCACHE_LANE_SIZE-1:0] mmu_data_i,
    input logic [DCACHE_INDEX_SIZE-1:0] mmu_lru_index_i,
    output logic mmu_miss_o,
    output logic [ADDR_SIZE-1:0] mmu_addr_o,
    output logic mmu_cache_access_o,
    output logic [DCACHE_LANE_SIZE-1:0] mmu_data_o,
    output logic mmu_writeback_o,

    // Hazards
    output logic tl_hazard_o,

    // Bypass
    input bypass_e bypass_b_i,
    input logic [WORD_SIZE-1:0] bypass_rvm5_data_i,
    output logic alu_mem_rf_we_o,
    output logic [REG_SIZE-1:0] alu_mem_rf_waddr_o,
    output logic tl_rf_we_o,
    output logic [REG_SIZE-1:0] tl_rf_waddr_o,

     //Privilege mode/Virtual Memory
    input logic [WORD_SIZE-1:0] csr_priv_i,
    input logic [WORD_SIZE-1:0] csr_satp_i,

    // Exception
    output logic pp_exception_o,
    output logic [HF_PTR-1:0] pp_exception_id_o,
    output logic [ADDR_SIZE-1:0] pp_addr_o
);

mem_stage_t mem_data;
tl_stage_t tl_data;

logic [WORD_SIZE-1:0] add_result;
logic [WORD_SIZE-1:0] tl_store_data;
logic sb_buffer_merge;

assign mem_wr_done_o = mem_data.memop_wr | sb_buffer_merge;
assign mem_wr_done_id_o = mem_data.instr_id;

segre_tl_stage tl_stage(
    .clk_i             (clk_i),
    .rsn_i             (rsn_i),
    .kill_i            (kill_i),
    // TL interface
    // ALU
    .addr_i             (tl_data.addr),
    // Register file
    .rf_we_i            (tl_data.rf_we),
    .rf_waddr_i         (tl_data.rf_waddr),
    .rf_st_data_i       (tl_store_data),
    // Memop
    .memop_rd_i         (tl_data.memop_rd),
    .memop_wr_i         (tl_data.memop_wr),
    .memop_sign_ext_i   (tl_data.memop_sign_ext),
    .memop_type_i       (tl_data.memop_type),
    // Instruction ID
    .instr_id_i         (tl_data.instr_id),
    // Store permission from HF
    .store_permission_i (store_permission_i),

    // TL MEM interface
    // ALU
    .addr_o             (mem_data.addr),
    // Register file
    .rf_we_o            (mem_data.rf_we),
    .rf_waddr_o         (mem_data.rf_waddr),
    // Memop
    .addr_index_o       (mem_data.addr_index),
    .memop_rd_o         (mem_data.memop_rd),
    .memop_wr_o         (mem_data.memop_wr),
    .memop_sign_ext_o   (mem_data.memop_sign_ext),
    .memop_type_o       (mem_data.memop_type),
    .memop_type_flush_o (mem_data.memop_type_flush),
    // Store buffer
    .sb_hit_o           (mem_data.sb_hit),
    .sb_flush_o         (mem_data.sb_flush),
    .sb_data_load_o     (mem_data.sb_data_load),
    .sb_data_flush_o    (mem_data.sb_data_flush),
    .sb_addr_o          (mem_data.sb_addr),
    .sb_buffer_merge_o  (sb_buffer_merge),
    // Instruction ID
    .instr_id_o         (mem_data.instr_id),

    // MMU interface
    .mmu_data_rdy_i     (mmu_data_rdy_i),
    .mmu_data_i         (mmu_data_i),
    .mmu_lru_index_i    (mmu_lru_index_i),
    .mmu_addr_i         (mmu_addr_i),
    .mmu_miss_o         (mmu_miss_o),
    .mmu_addr_o         (mmu_addr_o),
    .mmu_cache_access_o (mmu_cache_access_o),

    // Hazard
    .pipeline_hazard_o  (tl_hazard_o),
    //Privilege mode
    .csr_priv_i         (csr_priv_i),
    //Virtual mem
    .csr_satp_i         (csr_satp_i),

    // Exceptions
    .pp_exception_o     (pp_exception_o),
    .pp_exception_id_o  (pp_exception_id_o),
    .pp_addr_o          (pp_addr_o)
);

segre_mem_stage mem_stage (
    // Clock and Reset
    .clk_i              (clk_i),
    .rsn_i              (rsn_i),
    .kill_i             (kill_i),
    // TL MEM interface
    // ALU
    .addr_i             (mem_data.addr),
    // Register file
    .rf_we_i            (mem_data.rf_we),
    .rf_waddr_i         (mem_data.rf_waddr),
    // Memop
    .addr_index_i       (mem_data.addr_index),
    .memop_type_i       (mem_data.memop_type),
    .memop_type_flush_i (mem_data.memop_type_flush),
    .memop_sign_ext_i   (mem_data.memop_sign_ext),
    .memop_rd_i         (mem_data.memop_rd),
    .memop_wr_i         (mem_data.memop_wr),
    // Store Buffer
    .sb_hit_i           (mem_data.sb_hit),
    .sb_flush_i         (mem_data.sb_flush),
    .sb_data_load_i     (mem_data.sb_data_load),
    .sb_data_flush_i    (mem_data.sb_data_flush),
    .sb_addr_i          (mem_data.sb_addr),
    // Instruction ID
    .instr_id_i         (mem_data.instr_id),
    // MEM WB intereface
    .cache_data_o       (data_o),
    //Register file
    .rf_we_o            (rf_we_o),
    .rf_waddr_o         (rf_waddr_o),
    // Instruction ID
    .instr_id_o         (instr_id_o),
    //MMU
    .mmu_data_rdy_i     (mmu_data_rdy_i),
    .mmu_data_i         (mmu_data_i),
    .mmu_lru_index_i    (mmu_lru_index_i),
    .mmu_writeback_o    (mmu_writeback_o),
    .mmu_data_o         (mmu_data_o)
);

always_comb begin : adder
    add_result = $signed(alu_src_a_i) + $signed(alu_src_b_i);
end

always_comb begin :  bypass_data
    alu_mem_rf_we_o    = tl_data.rf_we;
    alu_mem_rf_waddr_o = tl_data.rf_waddr;
    tl_rf_we_o         = mem_data.rf_we;
    tl_rf_waddr_o      = mem_data.rf_waddr;
end

always_comb begin : bypass
    if (tl_data.bypass_b == BY_RVM5_TL) begin
        tl_store_data = bypass_rvm5_data_i;
    end
    else if (tl_data.bypass_b == BY_MEM_TL) begin
        tl_store_data = data_o;
    end
    else begin
        tl_store_data = tl_data.rf_st_data;
    end
end

always_ff @(posedge clk_i) begin : latch
    if (!rsn_i) begin
        tl_data.addr           <= 0;
        tl_data.rf_we          <= 0;
        tl_data.rf_waddr       <= 0;
        tl_data.rf_st_data     <= 0;
        tl_data.memop_rd       <= 0;
        tl_data.memop_wr       <= 0;
        tl_data.memop_sign_ext <= 0;
        tl_data.memop_type     <= WORD;
        tl_data.bypass_b       <= NO_BYPASS;
        tl_data.instr_id       <= 0;
    end
    else if (!tl_hazard_o) begin
        tl_data.addr           <= add_result;
        tl_data.rf_we          <= !kill_i & rf_we_i;
        tl_data.rf_waddr       <= rf_waddr_i;
        tl_data.rf_st_data     <= rf_st_data_i;
        tl_data.memop_rd       <= !kill_i & memop_rd_i;
        tl_data.memop_wr       <= !kill_i & memop_wr_i;
        tl_data.memop_sign_ext <= memop_sign_ext_i;
        tl_data.memop_type     <= memop_type_i;
        tl_data.bypass_b       <= bypass_b_i;
        tl_data.instr_id       <= instr_id_i;
    end
end

endmodule : segre_mem_pipeline