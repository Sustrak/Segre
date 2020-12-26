import segre_pkg::*;

module segre_dcache_data (
    input logic clk_i,
    input logic rsn_i,
    input logic rd_data_i,
    input logic wr_data_i,
    input logic mmu_wr_data_i,
    input logic [DCACHE_INDEX_SIZE-1:0] index_i,
    input logic [DCACHE_BYTE_SIZE-1:0] byte_i,
    input memop_data_type_e memop_data_type_load_i,
    input memop_data_type_e memop_data_type_store_i,
    input logic [WORD_SIZE-1:0] data_i,
    input logic [DCACHE_LANE_SIZE-1:0] mmu_data_i,
    output logic mmu_writeback_o,
    output logic [DCACHE_LANE_SIZE-1:0] mmu_data_o,
    output logic [WORD_SIZE-1:0] data_o,
    output memop_data_type_e store_data_type_o //Type of store for the write-through
);

localparam ADDR_BYTE_SIZE  = DCACHE_BYTE_SIZE;
localparam ADDR_INDEX_SIZE = DCACHE_INDEX_SIZE;
localparam LANE_SIZE       = DCACHE_LANE_SIZE;
localparam TAG_SIZE        = DCACHE_TAG_SIZE;
localparam NUM_LANES       = DCACHE_NUM_LANES;
localparam INDEX_SIZE = DCACHE_INDEX_SIZE;

typedef struct packed{
    logic dirty;
    logic [LANE_SIZE/8-1:0][7:0] data;
} cache_data_t;

cache_data_t [NUM_LANES-1:0] cache_data;

logic [WORD_SIZE-1:0] data;

assign store_data_type_o = memop_data_type_store_i;

always_ff @(posedge clk_i) begin : cache_reset
    if (!rsn_i) begin
        for (int i = 0; i < NUM_LANES; i++) begin
            cache_data[i].dirty <= 0;
            cache_data[i].data <= 0;
        end
    end 
end

always_comb begin : cache_replacement
    if(mmu_wr_data_i) begin //Cache_data values are updated at the end of the cycle, we take profit of that.
        mmu_writeback_o <= cache_data[index_i].dirty;
    end
end

always_comb begin : cache_read
    if (rd_data_i) begin
        unique case (memop_data_type_load_i)
            BYTE: data_o = {{24{1'b0}}, cache_data[index_i].data[byte_i]};
            HALF: data_o = {{16{1'b0}}, cache_data[index_i].data[byte_i+1], cache_data[index_i].data[byte_i]};
            WORD: data_o = {cache_data[index_i].data[byte_i+3], 
                            cache_data[index_i].data[byte_i+2],
                            cache_data[index_i].data[byte_i+1],
                            cache_data[index_i].data[byte_i]
                           };
            default: ;
        endcase
    end
end

always_ff @(posedge clk_i) begin : cache_write
    if (wr_data_i) begin
        unique case (memop_data_type_store_i)
            BYTE: cache_data[index_i].data[byte_i]   <= data_i[7:0];
            HALF: begin
                    cache_data[index_i].data[byte_i+1] <= data_i[15:8];
                    cache_data[index_i].data[byte_i]   <= data_i[7:0];
            end
            WORD: begin
                    cache_data[index_i].data[byte_i+3] <= data_i[31:24];
                    cache_data[index_i].data[byte_i+2] <= data_i[23:16];
                    cache_data[index_i].data[byte_i+1] <= data_i[15:8];
                    cache_data[index_i].data[byte_i]   <= data_i[7:0];
            end
            default: ;
        endcase
        cache_data[index_i].dirty <= 1;
    end
    else if (mmu_wr_data_i) begin
        cache_data[index_i].data  <= mmu_data_i;
        cache_data[index_i].dirty <= 0;
    end
end

assign mmu_data_o = cache_data[index_i].data;

endmodule : segre_dcache_data
