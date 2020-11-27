import segre_pkg::*;

module segre_dcache_data (
    input logic clk_i,
    input logic rsn_i,
    input logic rd_data_i,
    input logic wr_data_i,
    input logic mmu_wr_data_i,
    input logic [WORD_SIZE-1:0] addr_i,
    input memop_data_type_e memop_data_type_i,
    input logic [WORD_SIZE-1:0] data_i,
    input logic [DCACHE_LANE_SIZE-1:0] mmu_data_i,
    input logic [DCACHE_INDEX_SIZE-1:0] addr_index_i,
    output logic [WORD_SIZE-1:0] data_o,
    output memop_data_type_e store_data_type_o //Type of store for the write-through
);

localparam ADDR_BYTE_SIZE  = DCACHE_BYTE_SIZE;
localparam ADDR_INDEX_SIZE = DCACHE_INDEX_SIZE;
localparam LANE_SIZE       = DCACHE_LANE_SIZE;
localparam TAG_SIZE        = DCACHE_TAG_SIZE;
localparam NUM_LANES       = DCACHE_NUM_LANES;
localparam INDEX_SIZE = DCACHE_INDEX_SIZE;
logic [NUM_LANES-1:0][LANE_SIZE/8-1:0][7:0] cache_data;

logic [ADDR_BYTE_SIZE-1:0] addr_byte;
logic [ADDR_INDEX_SIZE-1:0] addr_index;
logic [WORD_SIZE-1:0] data;

assign store_data_type_o = memop_data_type_i;
assign addr_index = addr_index_i;
//assign addr_index = addr_i[ADDR_INDEX_SIZE+ADDR_BYTE_SIZE-1:ADDR_BYTE_SIZE];

assign addr_byte  = addr_i[ADDR_BYTE_SIZE-1:0];

always_ff @(posedge clk_i) begin : cache_reset
    if (!rsn_i) begin
        for (int i = 0; i < NUM_LANES; i++) begin
            cache_data[i] <= 0;
        end
    end 
end

always_comb begin : cache_read
    if (rd_data_i) begin
        data <= {cache_data[addr_index][addr_byte+3], 
                 cache_data[addr_index][addr_byte+2],
                 cache_data[addr_index][addr_byte+1],
                 cache_data[addr_index][addr_byte]
                };
    end
end

always_ff @(posedge clk_i) begin : cache_write
    if (wr_data_i) begin
        unique case (memop_data_type_i)
            BYTE: cache_data[addr_index][addr_byte]   <= data_i[7:0];
            HALF: begin
                    cache_data[addr_index][addr_byte+1] <= data_i[15:8];
                    cache_data[addr_index][addr_byte]   <= data_i[7:0];
            end
            WORD: begin
                    cache_data[addr_index][addr_byte+3] <= data_i[31:24];
                    cache_data[addr_index][addr_byte+2] <= data_i[23:16];
                    cache_data[addr_index][addr_byte+1] <= data_i[15:8];
                    cache_data[addr_index][addr_byte]   <= data_i[7:0];
            end
            default: ;
        endcase
    end
    else if (mmu_wr_data_i) begin
        cache_data[addr_index] <= mmu_data_i;
    end
end

always_ff @(posedge clk_i) begin
    data_o = data;
end

endmodule : segre_dcache_data
