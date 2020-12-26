import segre_pkg::*;

module segre_mmu (
    input  logic clk_i,
    input  logic rsn_i,
    // Data chache
    input  logic dc_miss_i,
    input  logic [ADDR_SIZE-1:0] dc_addr_i,
    input  logic dc_writeback_i,
    //input  memop_data_type_e dc_store_data_type_i,
    input  logic [DCACHE_LANE_SIZE-1:0] dc_data_i, 
    input  logic dc_access_i,
    output logic dc_mmu_data_rdy_o,
    output logic [DCACHE_LANE_SIZE-1:0] dc_data_o,
    output logic [DCACHE_INDEX_SIZE-1:0] dc_lru_index_o,
    output logic [ADDR_SIZE-1:0] dc_mm_addr_o,
    // Instruction cache
    input  logic ic_miss_i,
    input  logic [ADDR_SIZE-1:0] ic_addr_i,
    input  logic ic_access_i,
    output logic ic_mmu_data_rdy_o,
    output logic [ICACHE_LANE_SIZE-1:0] ic_data_o,
    output logic [ICACHE_INDEX_SIZE-1:0] ic_lru_index_o,
    // Main memory
    input  logic mm_data_rdy_i,
    input  logic [DCACHE_LANE_SIZE-1:0] mm_data_i, // If $D and $I have different LANE_SIZE we need to change this
    output logic mm_rd_req_o,
    output logic mm_wr_req_o,
    //output memop_data_type_e mm_wr_data_type_o,
    output logic [ADDR_SIZE-1:0] mm_addr_o,
    output logic [ADDR_SIZE-1:0] mm_wr_addr_o,
    output logic [DCACHE_LANE_SIZE-1:0] mm_data_o
);

localparam DC_LRU_WIDTH = DCACHE_NUM_LANES*(DCACHE_NUM_LANES-1) >> 1;
localparam IC_LRU_WIDTH = ICACHE_NUM_LANES*(ICACHE_NUM_LANES-1) >> 1;

// Data cache
logic dc_miss;
logic [ADDR_SIZE-1:0] dc_mm_addr;
logic [ADDR_SIZE-1:0] dc_mm_addr_pending;
logic dc_mmu_data_rdy;
logic [DCACHE_LANE_SIZE-1:0] dc_mm_data;
logic [DCACHE_INDEX_SIZE-1:0] dc_lru_index;
logic [DCACHE_INDEX_SIZE-1:0] dc_addr_index;

// Data cache LRU
logic [DC_LRU_WIDTH-1:0] dc_lru_current, dc_lru_updated;
logic [DCACHE_NUM_LANES-1:0] dc_lru_access, dc_lru_pre, dc_lru_post;

// Instruction cache
logic ic_miss;
logic [ADDR_SIZE-1:0] ic_mm_addr;
logic ic_mmu_data_rdy;
logic [ICACHE_LANE_SIZE-1:0] ic_mm_data;
logic [ICACHE_INDEX_SIZE-1:0] ic_lru_index;
logic [DCACHE_INDEX_SIZE-1:0] ic_addr_index;

// Instruction cache LRU
logic [IC_LRU_WIDTH-1:0] ic_lru_current, ic_lru_updated;
logic [ICACHE_NUM_LANES-1:0] ic_lru_access, ic_lru_pre, ic_lru_post;

// Main memory
logic mm_rd_req;
logic [ADDR_SIZE-1:0] mm_addr;
logic [DCACHE_LANE_SIZE-1:0] mm_data;
logic [DCACHE_LANE_SIZE-1:0] mm_dc_data;

// MMU
mmu_fsm_state_e fsm_state;
mmu_fsm_state_e fsm_nxt_state;

// Help Functions
function logic[DCACHE_INDEX_SIZE-1:0] one_hot_to_binary(logic [DCACHE_NUM_LANES-1:0] one_hot);
    unique case (one_hot)
        1 : return 0;
        2 : return 1;
        4 : return 2;
        8 : return 3;
    endcase
endfunction : one_hot_to_binary

function logic[ICACHE_NUM_LANES-1:0] binary_to_one_hot(logic [ICACHE_INDEX_SIZE-1:0] index);
    unique case (index)
        0 : return 1;
        1 : return 2;
        2 : return 4;
        3 : return 8;
    endcase
endfunction : binary_to_one_hot

assign dc_addr_index = dc_addr_i[DCACHE_INDEX_SIZE-1:0];
assign ic_addr_index = ic_addr_i[ICACHE_INDEX_SIZE-1:0];

// Bypass store signals directly to main memory
assign mm_wr_req_o = dc_writeback_i;
assign mm_wr_addr_o = dc_addr_i;
assign mm_data_o = dc_data_i;
//assign mm_wr_data_type_o = dc_store_data_type_i;

mor1kx_cache_lru #(.NUMWAYS(DCACHE_NUM_LANES)) dc_lru_mor1kx (
    .current  (dc_lru_current),
    .update   (dc_lru_updated),
    .access   (dc_lru_access),
    .lru_pre  (dc_lru_pre),
    .lru_post (dc_lru_post)
);

mor1kx_cache_lru #(.NUMWAYS(ICACHE_NUM_LANES)) ic_lru_mor1kx (
    .current  (ic_lru_current),
    .update   (ic_lru_updated),
    .access   (ic_lru_access),
    .lru_pre  (ic_lru_pre),
    .lru_post (ic_lru_post)
);

always_comb begin : dc_lru
    if (!rsn_i) begin
        dc_lru_access  = 0;
        dc_lru_current = 0;
    end
    else if (dc_access_i & !dc_miss_i) begin
        dc_lru_current = dc_lru_updated;
        dc_lru_access = binary_to_one_hot(dc_addr_index);
    end
    else if (dc_mmu_data_rdy_o) begin
        dc_lru_current = dc_lru_updated;
        dc_lru_access = binary_to_one_hot(dc_lru_index_o);
    end
    else begin
        dc_lru_access  = 0;
        dc_lru_index   = one_hot_to_binary(dc_lru_post);
    end
end

always_comb begin : ic_lru
    if (!rsn_i) begin
        ic_lru_access  = 0;
        ic_lru_current = 0;
    end
    else if (ic_access_i && !ic_miss_i) begin
        ic_lru_current = ic_lru_updated;
        ic_lru_access = binary_to_one_hot(ic_addr_index);
    end
    else begin
        ic_lru_access  = 0;
        ic_lru_index   = one_hot_to_binary(ic_lru_post);
    end
end

always_ff @(posedge clk_i) begin : dc_miss_block
    if (!rsn_i) begin
        dc_miss <= 0;
        dc_mm_addr <= 0;
        dc_mm_addr_pending <= 0;
    end 
    else begin
        if(fsm_state == DCACHE_PENDING & fsm_nxt_state == DCACHE_REQ) begin
            dc_miss <= 1; //En teoria no seria necessari, but who knows
            dc_mm_addr <= dc_mm_addr_pending;
        end
        else if (dc_miss_i & !(dc_miss)) begin
            dc_miss <= dc_miss_i;
            dc_mm_addr <= {dc_addr_i[ADDR_SIZE-1:DCACHE_BYTE_SIZE], {DCACHE_BYTE_SIZE{1'b0}}};
        end
        if (dc_miss && fsm_state == DCACHE_WAIT && mm_data_rdy_i) begin
            dc_miss <= 0;
        end
        if (dc_miss_i & dc_miss) begin
            dc_mm_addr_pending <= {dc_addr_i[ADDR_SIZE-1:DCACHE_BYTE_SIZE], {DCACHE_BYTE_SIZE{1'b0}}};
        end
    end
end

always_ff @(posedge clk_i) begin : ic_miss_block
    if (!rsn_i) begin
        ic_miss <= 0;
        ic_mm_addr <= 0;
    end else begin
        if (ic_miss_i) begin
            ic_miss <= ic_miss_i;
            ic_mm_addr <= {ic_addr_i[ADDR_SIZE-1:ICACHE_BYTE_SIZE], {ICACHE_BYTE_SIZE{1'b0}}};
        end
        if (ic_miss && fsm_state == ICACHE_WAIT && mm_data_rdy_i) begin
            ic_miss <= 0;
        end
    end
end

always_comb begin : mm_data_ready
    if (mm_data_rdy_i) begin
        if (fsm_state == DCACHE_WAIT | fsm_state == DCACHE_PENDING) begin
            dc_mmu_data_rdy = 1;
            dc_mm_data  = mm_data_i;
        end
        else if (fsm_state == ICACHE_WAIT) begin
            ic_mmu_data_rdy = 1;
            ic_mm_data      = mm_data_i;
        end
    end
    else begin
        dc_mmu_data_rdy = 0;
        ic_mmu_data_rdy = 0;
    end
end

always_comb begin : mmu_fsm
    unique case (fsm_state)
        DCACHE_REQ : begin
            fsm_nxt_state = DCACHE_WAIT;
        end
        DCACHE_WAIT : begin
            if (mm_data_rdy_i) begin
                if (ic_miss) fsm_nxt_state = ICACHE_REQ;
                else fsm_nxt_state = MMU_IDLE;
            end
            else if (dc_miss_i & (dc_mm_addr != {dc_addr_i[ADDR_SIZE-1:DCACHE_BYTE_SIZE], {DCACHE_BYTE_SIZE{1'b0}}})) begin
                fsm_nxt_state = DCACHE_PENDING;
            end
        end
        DCACHE_PENDING: begin
            if (mm_data_rdy_i) begin
                fsm_nxt_state = DCACHE_REQ;
            end
        end
        ICACHE_REQ  : begin
            fsm_nxt_state = ICACHE_WAIT;
        end
        ICACHE_WAIT : begin
            if (mm_data_rdy_i) begin
                if (dc_miss) fsm_nxt_state = DCACHE_REQ;
                else fsm_nxt_state = MMU_IDLE;
            end
        end
        MMU_IDLE  : begin
            if (dc_miss) fsm_nxt_state = DCACHE_REQ;
            else if (ic_miss) fsm_nxt_state = ICACHE_REQ;
            else fsm_nxt_state = MMU_IDLE;
        end
    endcase
end

always_comb begin : main_memory_req
    unique case (fsm_state)
        DCACHE_REQ: begin
            mm_rd_req = 1;
            mm_addr = dc_mm_addr;
        end
        ICACHE_REQ: begin
            mm_rd_req = 1;
            mm_addr = ic_mm_addr;
        end
        DCACHE_WAIT, ICACHE_WAIT, DCACHE_PENDING : begin
            mm_rd_req = 0;
        end
        MMU_IDLE: begin
            mm_rd_req = 0;
        end
    endcase
end

always_ff @(posedge clk_i) begin
    if (!rsn_i) begin
        fsm_state <= MMU_IDLE;
        ic_mmu_data_rdy_o <= 0;
        dc_mmu_data_rdy_o <= 0;
        mm_rd_req_o <= 0;
    end
    else begin
        fsm_state   <= fsm_nxt_state;
        // Main memory
        mm_rd_req_o <= mm_rd_req;
        mm_addr_o   <= mm_addr;
        // Data cache
        dc_mmu_data_rdy_o <= dc_mmu_data_rdy;
        dc_data_o <= dc_mm_data;
        dc_lru_index_o <= dc_lru_index;
        dc_mm_addr_o <= dc_mm_addr; 
        // Instruction cache
        ic_mmu_data_rdy_o <= ic_mmu_data_rdy;
        ic_data_o <= ic_mm_data;
        ic_lru_index_o <= ic_lru_index;
    end
end

endmodule : segre_mmu
