import segre_pkg::*;

module segre_icache_data (
    input logic clk_i,
    input logic rsn_i,
    input logic rd_data_i,
    input logic [ICACHE_LANE_SIZE-1:0] mmu_wr_data_i,
    input logic [ICACHE_INDEX_SIZE-1:0] index_i,
    input logic [ICACHE_BYTE_SIZE-1:0] byte_i,
    input logic mmu_data_i,
    output logic [WORD_SIZE-1:0] data_o
);

localparam ADDR_BYTE_SIZE  = ICACHE_BYTE_SIZE;
localparam ADDR_INDEX_SIZE = ICACHE_INDEX_SIZE;
localparam LANE_SIZE       = ICACHE_LANE_SIZE;
localparam TAG_SIZE        = ICACHE_TAG_SIZE;
localparam NUM_LANES       = ICACHE_NUM_LANES;
localparam INDEX_SIZE      = ICACHE_INDEX_SIZE;

logic [NUM_LANES-1:0][LANE_SIZE/8-1:0][7:0] cache_data;

logic [WORD_SIZE-1:0] data;

always_ff @(posedge clk_i) begin : cache_reset
    if (!rsn_i) begin
        for (int i = 0; i < NUM_LANES; i++) begin
            cache_data[i] <= 0;
        end
    end 
end

always_comb begin : cache_read
    if (rd_data_i) begin
        data_o = {cache_data[index_i][byte_i+3], 
                  cache_data[index_i][byte_i+2],
                  cache_data[index_i][byte_i+1],
                  cache_data[index_i][byte_i]
                 };
    end
end

always_ff @(posedge clk_i) begin : cache_write
    if (mmu_data_i) begin
        cache_data[index_i] <= mmu_wr_data_i;
    end
end

endmodule : segre_icache_data
