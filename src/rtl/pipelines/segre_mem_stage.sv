import segre_pkg::*;

module segre_mem_stage (
    // Clock and Reset
    input logic clk_i,
    input logic rsn_i,
    input logic kill_i,

    // TL MEM interface
    // ALU
    input logic [ADDR_SIZE-1:0] addr_i, // TODO: Change this name to memop_addr_i
    // Register file
    input logic rf_we_i,
    input logic [REG_SIZE-1:0] rf_waddr_i,
    // Memop
    input logic [DCACHE_INDEX_SIZE-1:0] addr_index_i,
    input memop_data_type_e memop_type_i,
    input memop_data_type_e memop_type_flush_i,
    input logic memop_sign_ext_i,
    input logic memop_rd_i,
    input logic memop_wr_i,
    // Store buffer
    input logic sb_hit_i,
    input logic sb_flush_i,
    input logic [WORD_SIZE-1:0] sb_data_load_i,
    input logic [WORD_SIZE-1:0] sb_data_flush_i,
    input logic [ADDR_SIZE-1:0] sb_addr_i,
    // Instruction ID
    input logic [HF_PTR-1:0] instr_id_i,

    // MEM WB interface
    output logic [WORD_SIZE-1:0] cache_data_o,
    // Register file
    output logic rf_we_o,
    output logic [REG_SIZE-1:0] rf_waddr_o,
    // Instruction ID
    output logic [HF_PTR-1:0] instr_id_o,

    // MMU
    input logic mmu_data_rdy_i,
    input logic [DCACHE_LANE_SIZE-1:0] mmu_data_i,
    input logic [DCACHE_INDEX_SIZE-1:0] mmu_lru_index_i,
    output logic mmu_writeback_o,
    output logic [DCACHE_LANE_SIZE-1:0] mmu_data_o
);

dcache_data_t cache_data;

logic [WORD_SIZE-1:0] mem_data;
logic [WORD_SIZE-1:0] mem_data_aux;

assign mem_data_aux = sb_hit_i ? sb_data_load_i : cache_data.data_o;

// DCACHE_DATA
assign cache_data.rd_data               = memop_rd_i;
assign cache_data.wr_data               = memop_wr_i;
assign cache_data.mmu_wr_data           = mmu_data_rdy_i;
assign cache_data.index                 = mmu_data_rdy_i ? mmu_lru_index_i : addr_index_i;
assign cache_data.byte_i                = sb_flush_i ? sb_addr_i[DCACHE_BYTE_SIZE-1:0] : addr_i[DCACHE_BYTE_SIZE-1:0];
assign cache_data.memop_data_load_type  = memop_type_i;
assign cache_data.memop_data_store_type = memop_type_flush_i;
assign cache_data.data_i                = sb_data_flush_i; //We only write from the SB
assign cache_data.mmu_data_i              = mmu_data_i;

segre_dcache_data dcache_data (
    .clk_i                   (clk_i),
    .rsn_i                   (rsn_i),
    .rd_data_i               (cache_data.rd_data),
    .wr_data_i               (cache_data.wr_data),
    .mmu_wr_data_i           (cache_data.mmu_wr_data),
    .index_i                 (cache_data.index),
    .byte_i                  (cache_data.byte_i),
    .memop_data_type_load_i  (cache_data.memop_data_load_type),
    .memop_data_type_store_i (cache_data.memop_data_store_type),
    .data_i                  (cache_data.data_i),
    .mmu_data_i              (cache_data.mmu_data_i),
    .mmu_writeback_o         (cache_data.mmu_writeback),
    .mmu_data_o              (cache_data.mmu_data_o),
    .data_o                  (cache_data.data_o),
    .store_data_type_o       (cache_data.store_data_type_o)
);

always_comb begin : sign_extension
    if (memop_sign_ext_i) begin
        unique case(memop_type_i)
            BYTE: mem_data = { {24{mem_data_aux[7]}}, mem_data_aux[7:0] };
            HALF: mem_data = { {16{mem_data_aux[15]}}, mem_data_aux[15:0] };
            WORD: mem_data = mem_data_aux;
            default: mem_data = mem_data_aux;
        endcase
    end
    else begin
        unique case(memop_type_i)
            BYTE: mem_data = { {24{1'b0}}, mem_data_aux[7:0] };
            HALF: mem_data = { {16{1'b0}}, mem_data_aux[15:0] };
            WORD: mem_data = mem_data_aux;
            default: mem_data = mem_data_aux;
        endcase
    end
end

always_ff @(posedge clk_i) begin
    if (!rsn_i) begin
        cache_data_o <= 0;
        rf_we_o      <= 0;
        rf_waddr_o   <= 0;
        instr_id_o   <= 0;
    end
    else begin
        cache_data_o <= mem_data;
        rf_we_o      <= !kill_i & rf_we_i;
        rf_waddr_o   <= rf_waddr_i;
        instr_id_o   <= instr_id_i;
    end
end

assign mmu_writeback_o = cache_data.mmu_writeback;
assign mmu_data_o      = cache_data.mmu_data_o;

endmodule