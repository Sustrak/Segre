import segre_pkg::*;

module segre_tl_stage (
    input logic clk_i,
    input logic rsn_i,
    // EX TL interface
    // ALU
    input logic [WORD_SIZE-1:0] alu_res_i,
    // Register file
    input logic rf_we_i,
    input logic [REG_SIZE-1:0] rf_waddr_i,
    input logic [WORD_SIZE-1:0] rf_st_data_i,
    // Memop
    input logic memop_rd_i,
    input logic memop_wr_i,
    input logic memop_sign_ext_i,
    input memop_data_type_e memop_type_i,
    // Tkbr
    input logic tkbr_i
    input logic [WORD_SIZE-1:0] new_pc_i,

    // TL MEM interface
    // ALU
    output logic [WORD_SIZE-1:0] alu_res_o,
    // Register file
    output logic rf_we_o,
    output logic [REG_SIZE-1:0] rf_waddr_o,
    output logic [WORD_SIZE-1:0] rf_st_data_o,
    // Memop
    output logic memop_rd_o,
    output logic memop_wr_o,
    output logic memop_sign_ext_o,
    output memop_data_type_e memop_type_o,
    // Tkbr
    output logic tkbr_o
    output logic [WORD_SIZE-1:0] new_pc_o,

    // MMU interface
    input logic mmu_data_rdy_i,
    input logic [DCACHE_LANE_SIZE-1:0] mmu_data_i,
    input logic [ADDR_SIZE-1:0] mmu_addr_i,
    output logic mmu_miss_o,
    output logic [ADDR_SIZE-1:0] mmu_addr_o,
    output logic mmu_cache_access_o,

    // Hazard
    output logic pipeline_hazard_o
);

dcache_tag_t cache_tag;

logic pipeline_hazard;

assign cache_tag.req        = memop_rd_i | memop_wr_i;
assign cache_tag.mmu_data   = mmu_data_rdy_i;
assign cache_tag.addr       = mmu_data_rdy_i ? mmu_addr_i : alu_res_i;
assign cache_tag.invalidate = 0;

assign mmu_cache_access_o = cache_tag.req;
assign mmu_addr_o = cache_tag.addr;

assign pipeline_hazard_o = pipeline_hazard;

segre_dcache_tag dcache_tag (
    .clk_i        (clk_i),
    .rsn_i        (rsn_i),
    .req_i        (cache_tag.req),
    .mmu_data_i   (cache_tag.mmu_data),
    .addr_i       (cache_tag.addr),
    .lru_index_i  (cache_tag.lru_index),
    .invalidate_i (cache_tag.invalidate),
    .hit_o        (cache_tag.hit),
    .miss_o       (cache_tag.miss)
);

// TODO: Calculate in always_comb and store the value for next cycles
always_ff @(posedge clk_i) begin : pipeline_stop
    if (!rsn_i) begin
        pipeline_hazard <= 0;
    end
    else if (mmu_data_rdy_i) begin
        pipeline_hazard <= 0;
    end
    else if (!pipeline_hazard & cache_tag.miss) begin
        pipeline_hazard <= 1;
    end 
end

always_ff @(posedge clk_i) begin : stage_latch
    if (!pipeline_hazard) begin
        alu_res_o        <= alu_res_i;
        rf_we_o          <= rf_we_i;
        rf_waddr_o       <= rf_waddr_i;
        rf_st_data_o     <= rf_st_data_i;
        memop_rd_o       <= memop_rd_i;
        memop_wr_o       <= memop_wr_i;
        memop_sign_ext_o <= memop_sign_ext_i;
        memop_type_o     <= memop_type_i;
        tkbr_o           <= tkbr_i;
        new_pc_o         <= new_pc_i;
        mmu_miss_o       <= cache_tag.miss;
    end
    else begin
        rf_we_o    <= 0;
        memop_rd_o <= 0;
        memop_wr_o <= 0;
        tkbr_o     <= 0;
        mmu_miss_o <= 0;
    end
end

endmodule : segre_tl_stage
