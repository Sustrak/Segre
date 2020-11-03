import EPI_pkg::*;

module segre_cache
    #(parameter NUM_LANES = 4,
      parameter BYTES_PER_LANE = 16
    )(input logic clk_i,
      input logic rsn_i,
      input logic req_i,
      input logic data_from_mm,
      input logic [WORD_SIZE-1:0] addr_i,
      input logic [WORD_SIZE-1:0] data_i,
      output logic hit_o,
      output logic miss_o,
      output logic [WORD_SIZE-1:0] data_o
    );

localparam ELEMS_PER_LANE = BYTES_PER_LANE/(WORD_SIZE/8);
localparam ADDR_BYTE_SIZE = $clog2(BYTES_PER_LANE);
localparam ADDR_INDEX_SIZE = $clog2(NUM_LANES);
localparam LANE_SIZE = WORD_SIZE * ELEMS_PER_LANE;
localparam TAG_SIZE  = WORD_SIZE - ADDR_BYTE_SIZE - ADDR_INDEX_SIZE;

logic [NUM_LANES-1:0] cache_lane_valid;
logic [TAG_SIZE-1:0][NUM_LANES-1:0] cache_tags;
logic [LANE_SIZE/8-1:0][NUM_LANES-1:0] cache_data;

logic [ADDR_BYTE_SIZE-1:0] addr_byte;
logic [ADDR_INDEX_SIZE-1:0] addr_index;
logic [TAG_SIZE-1:0] addr_tag;

logic tag_hit;
logic [WORD_SIZE-1:0] data;
logic [ADDR_INDEX_SIZE-1:0] lru_lane;

assign addr_tag   = addr_i[WORD_SIZE-1:ADDR_INDEX_SIZE+ADDR_BYTE_SIZE];
assign addr_index = addr_i[ADDR_INDEX_SIZE+ADDR_BYTE_SIZE-1:ADDR_BYTE_SIZE];
assign addr_byte  = addr_i[ADDR_BYTE_SIZE-1:0];

always_ff @(posedge clk_i) begin : cache_reset
    if (!rsn_i) begin
        cache_lane_valid <= 0;
        lru_lane <= 0;
    end 
end

always_ff @(posedge clk_i) begin : cache_read
    if (req_i) begin
        tag_hit <= cache_tag[addr_index] == addr_tag;
        data <= {cache_data[addr_index][addr_byte+3], 
                 cache_data[addr_index][addr_byte+2],
                 cache_data[addr_index][addr_byte+1],
                 cache_data[addr_index][addr_byte]
                };
    end
end


endmodule : segre_cache
      
