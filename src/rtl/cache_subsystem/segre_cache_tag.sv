import EPI_pkg::*;

module segre_cache_tag
    #(parameter NUM_LANES = 4,
      parameter BYTES_PER_LANE = 16
    )(input logic clk_i,
      input logic rsn_i,
      input logic req_i,
      input logic data_from_mm_i,
      input logic [WORD_SIZE-1:0] addr_i,
      input logic [ADDR_INDEX_SIZE-1:0] lru_index_i;
      output logic hit_o,
      output logic miss_o,
    );

localparam ELEMS_PER_LANE = BYTES_PER_LANE/(WORD_SIZE/8);
localparam ADDR_BYTE_SIZE = $clog2(BYTES_PER_LANE);
localparam ADDR_INDEX_SIZE = $clog2(NUM_LANES);
localparam LANE_SIZE = WORD_SIZE * ELEMS_PER_LANE;
localparam TAG_SIZE  = WORD_SIZE - ADDR_BYTE_SIZE - ADDR_INDEX_SIZE;

typedef struct packed {
    logic valid;
    logic [TAG_SIZE-1:0] tag;
} tags_t;

tags_t [NUM_LANES-1:0] cache_tags;
logic  [TAG_SIZE-1:0] addr_tag;
logic  [ADDR_INDEX_SIZE-1:0] addr_index;
logic  tag_hit;

assign addr_tag   = addr_i[WORD_SIZE-1:ADDR_INDEX_SIZE+ADDR_BYTE_SIZE];
assign addr_index = addr_i[ADDR_INDEX_SIZE+ADDR_BYTE_SIZE-1:ADDR_BYTE_SIZE];

always_ff @(posedge clk_i) begin : tag_reset
    if (!rsn_i) begin
        for (int i = 0; i < NUM_LANES; i++) begin
            cache_tags[i].valid <= 0;
            cache_tags[i].tag   <= 0;
        end
    end 
end

always_ff @(posedge clk_i) begin : update_tag
    if (data_from_mm) begin
        cache_tags[lru_index_i].valid <= 1;
        cache_tags[lru_index_i].tag <= addr_tag;
    end
end

always_comb begin : tag_rd
    tag_hit = (cache_tags[addr_index].tag == addr_tag) & cache_tags[addr_index].valid;
end

assign hit_o = tag_hit & req_i;
assign miss_o = ~tag_hit & req_i;

endmodule : segre_cache_tag
