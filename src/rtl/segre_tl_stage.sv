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
    input logic tkbr_i,
    input logic [WORD_SIZE-1:0] new_pc_i,

    // TL MEM interface
    // ALU
    output logic [WORD_SIZE-1:0] alu_res_o,
    // Register file
    output logic rf_we_o,
    output logic [REG_SIZE-1:0] rf_waddr_o,
    // Memop
    output logic memop_rd_o,
    output logic memop_wr_o,
    output logic memop_sign_ext_o,
    output memop_data_type_e memop_type_o,
    // Tkbr
    output logic tkbr_o,
    output logic [WORD_SIZE-1:0] new_pc_o,
    // Store buffer
    output logic sb_hit_o,
    output logic [WORD_SIZE-1:0] sb_data_o,
    output logic [ADDR_SIZE-1:0] sb_addr_o,

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
store_buffer_t sb;

tl_fsm_state_e fsm_state;
tl_fsm_state_e fsm_nxt_state;
logic pipeline_hazard;

assign cache_tag.req        = memop_rd_i | memop_wr_i;
assign cache_tag.mmu_data   = mmu_data_rdy_i;
assign cache_tag.addr       = mmu_data_rdy_i ? mmu_addr_i : alu_res_i;
assign cache_tag.invalidate = 0;

assign mmu_cache_access_o = cache_tag.req;
assign mmu_addr_o = alu_res_i;

assign pipeline_hazard_o = pipeline_hazard;

// STORE BUFFER
assign sb.req_store = memop_wr_i;
assign sb.req_load  = memop_rd_i;
assign sb.flush_chance = (!memop_wr_i & !memop_rd_i) | fsm_state != TL_IDLE;
assign sb.addr_i    = alu_res_i;
assign sb.data_i    = rf_st_data_i;
assign sb.memop_data_type_i = memop_type_i;

segre_dcache_tag dcache_tag (
    .clk_i        (clk_i),
    .rsn_i        (rsn_i),
    .req_i        (cache_tag.req),
    .mmu_data_i   (cache_tag.mmu_data),
    .addr_i       (cache_tag.addr),
    .invalidate_i (cache_tag.invalidate),
    .hit_o        (cache_tag.hit),
    .miss_o       (cache_tag.miss)
);

segre_store_buffer store_buffer (
    .clk_i             (clk_i),
    .rsn_i             (rsn_i),
    .req_store_i       (sb.req_store),
    .req_load_i        (sb.req_load),
    .flush_chance_i    (sb.flush_chance),
    .addr_i            (sb.addr_i),
    .data_i            (sb.data_i),
    .memop_data_type_i (sb.memop_data_type_i),
    .hit_o             (sb.hit),
    .miss_o            (sb.miss),
    .full_o            (sb.full),
    .trouble_o         (sb.trouble),
    .data_valid_o      (sb.data_valid),
    .memop_data_type_o (sb.memop_data_type_o),
    .data_o            (sb.data_o),
    .addr_o            (sb.addr_o)
);

//TODO: Include the trouble from Store Buffer
always_comb begin : pipeline_stop
    if (!rsn_i) begin
        pipeline_hazard = 0;
    end
    else begin
        unique case (fsm_state)
            HAZARD_DC_MISS, HAZARD_SB_TROUBLE: pipeline_hazard = 1;
            TL_IDLE: pipeline_hazard = sb.trouble | cache_tag.miss;
            default:;
        endcase
    end
end

always_comb begin : tl_fsm
    if (!rsn_i) begin
        fsm_nxt_state = TL_IDLE;
    end else begin
        unique case (fsm_state)
            HAZARD_DC_MISS: begin
                if (mmu_data_i) fsm_nxt_state = TL_IDLE;
            end
            HAZARD_SB_TROUBLE: begin
                if (!sb.trouble) fsm_nxt_state = TL_IDLE;
            end
            TL_IDLE: begin
                if (cache_tag.miss)  fsm_nxt_state = HAZARD_DC_MISS;
                else if (sb.trouble) fsm_nxt_state = HAZARD_SB_TROUBLE;
                else                 fsm_nxt_state = TL_IDLE;
            end
            default:;
        endcase
    end
end

always_ff @(posedge clk_i) begin : stage_latch
    if (!pipeline_hazard) begin
        if(sb.flush_chance & sb.data_valid) begin
            // Flush data from store buffer to the data cache
            sb_addr_o        <= sb.addr_o;
            sb_data_o        <= sb.data_o;
            sb_hit_o         <= 1'b0;
            memop_rd_o       <= 1'b0;
            memop_wr_o       <= sb.data_valid;
            memop_type_o     <= sb.memop_data_type_o;
        end
        else if(sb.hit) begin
            //Load or Store hit at store buffer, no need to access cache
            sb_data_o        <= sb.data_o;
            sb_hit_o         <= sb.hit;
            memop_rd_o       <= 1'b0; //We have already read
            memop_wr_o       <= 1'b0; //We have already write
            memop_type_o     <= sb.memop_data_type_o;
        end
        else begin
            // Miss in store buffer or no memory operation and store buffer empty
            memop_rd_o       <= memop_rd_i;
            memop_wr_o       <= memop_wr_i;
            memop_type_o     <= memop_type_i;
        end
        alu_res_o        <= alu_res_i;
        rf_we_o          <= rf_we_i;
        rf_waddr_o       <= rf_waddr_i;
        memop_sign_ext_o <= memop_sign_ext_i;
        tkbr_o           <= tkbr_i;
        new_pc_o         <= new_pc_i;
        mmu_miss_o       <= cache_tag.miss & sb.miss;
    end
    else begin
        rf_we_o    <= 0;
        memop_rd_o <= 0;
        memop_wr_o <= 0;
        tkbr_o     <= 0;
        mmu_miss_o <= 0;
    end
    
    fsm_state <= fsm_nxt_state;
end

endmodule : segre_tl_stage
