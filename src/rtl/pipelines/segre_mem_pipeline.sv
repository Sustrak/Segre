import segre_pkg::*;

module segre_mem_pipeline(
    // Clock & Reset
    input logic clk_i,
    input logic rsn_i,
    
    input logic [WORD_SIZE-1:0] alu_src_a_i,
    input logic [WORD_SIZE-1:0] alu_src_b_i,
    input logic rf_we_i,
    input logic [REG_SIZE-1:0] rf_waddr_i,
    input logic [WORD_SIZE-1:0] rf_st_data_i,
    input logic memop_rd_i,
    input logic memop_wr_i,
    input logic memop_sign_ext_i,
    input memop_data_type_e memop_type_i,

    output logic [WORD_SIZE-1:0] data_o,
    output logic rf_we_o,
    output logic [REG_SIZE-1:0] rf_waddr_o,
    
    // MMU
    input logic mmu_data_rdy_i,
    input logic [DCACHE_LANE_SIZE-1:0] mmu_data_i,
    input logic [DCACHE_INDEX_SIZE-1:0] mmu_lru_index_i,
    output logic mmu_miss_o,
    output logic [ADDR_SIZE-1:0] mmu_addr_o,
    output logic mmu_cache_access_o,
    output logic [WORD_SIZE-1:0] mmu_data_o,
    output memop_data_type_e mmu_store_data_type_o,
    output logic mmu_store_o,
    
    // Hazards
    output logic tl_hazard_o
);

mem_stage_t mem_data;
tl_stage_t tl_data;

logic [WORD_SIZE-1:0] add_result;

segre_tl_stage tl_stage(
    .clk_i             (clk_i),
    .rsn_i             (rsn_i),
    // TL interface
    // ALU
    .addr_i             (tl_data.addr),
    // Register file
    .rf_we_i            (tl_data.rf_we),
    .rf_waddr_i         (tl_data.rf_waddr),
    .rf_st_data_i       (tl_data.rf_st_data),
    // Memop
    .memop_rd_i         (tl_data.memop_rd),
    .memop_wr_i         (tl_data.memop_wr),
    .memop_sign_ext_i   (tl_data.memop_sign_ext),
    .memop_type_i       (tl_data.memop_type),

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
    // Store buffer
    .sb_hit_o           (mem_data.sb_hit),
    .sb_data_o          (mem_data.sb_data),
    .sb_addr_o          (mem_data.sb_addr),

    // MMU interface
    .mmu_data_rdy_i     (mmu_data_rdy_i),
    .mmu_data_i         (mmu_data_i),
    .mmu_lru_index_i    (mmu_lru_index_i),
    .mmu_miss_o         (mmu_miss_o),
    .mmu_addr_o         (mmu_addr_o),
    .mmu_cache_access_o (mmu_cache_access_o),

    // Hazard
    .pipeline_hazard_o  (tl_hazard_o)
);

segre_mem_stage mem_stage (
    // Clock and Reset
    .clk_i             (clk_i),
    .rsn_i             (rsn_i),
    // TL MEM interface
    // ALU
    .addr_i            (mem_data.addr),
    // Register file
    .rf_we_i           (mem_data.rf_we),
    .rf_waddr_i        (mem_data.rf_waddr),
    // Memop
    .addr_index_i      (mem_data.addr_index),
    .memop_type_i      (mem_data.memop_type),
    .memop_sign_ext_i  (mem_data.memop_sign_ext),
    .memop_rd_i        (mem_data.memop_rd),
    .memop_wr_i        (mem_data.memop_wr),
    // Store Buffer
    .sb_hit_i          (mem_data.sb_hit),
    .sb_data_i         (mem_data.sb_data),
    .sb_addr_i         (mem_data.sb_addr),
    // MEM WB intereface
    .cache_data_o      (data_o),
    //Register file
    .rf_we_o           (rf_we_o),
    .rf_waddr_o        (rf_waddr_o),
    //MMU
    .mmu_data_rdy_i    (mmu_data_rdy_i),
    .mmu_data_i        (mmu_data_i),
    .mmu_lru_index_i   (mmu_lru_index_i),
    .data_o            (mmu_data_o),
    .store_data_type_o (mmu_store_data_type_o)
);

always_comb begin : adder
    add_result = $signed(alu_src_a_i) + $signed(alu_src_b_i);
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
    end
    else begin
        tl_data.addr           <= add_result;
        tl_data.rf_we          <= rf_we_i;
        tl_data.rf_waddr       <= rf_waddr_i;
        tl_data.rf_st_data     <= rf_st_data_i;
        tl_data.memop_rd       <= memop_rd_i;
        tl_data.memop_wr       <= memop_wr_i;
        tl_data.memop_sign_ext <= memop_sign_ext_i;
        tl_data.memop_type     <= memop_type_i;
    end
end

endmodule : segre_mem_pipeline