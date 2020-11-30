import segre_pkg::*;

module segre_icache_tag
    ( input logic clk_i,
      input logic rsn_i,
      input logic req_i,
      input logic mmu_data_i,
      input logic [ICACHE_INDEX_SIZE-1:0] index_i,
      input logic [ICACHE_TAG_SIZE-1:0] tag_i,
      input logic invalidate_i,
      output logic [ICACHE_INDEX_SIZE-1:0] addr_index_o,
      output logic hit_o,
      output logic miss_o
    );

localparam ADDR_BYTE_SIZE  = ICACHE_BYTE_SIZE;
localparam ADDR_INDEX_SIZE = ICACHE_INDEX_SIZE;
localparam LANE_SIZE       = ICACHE_LANE_SIZE;
localparam TAG_SIZE        = ICACHE_TAG_SIZE;
localparam NUM_LANES       = ICACHE_NUM_LANES;
localparam INDEX_SIZE      = ICACHE_INDEX_SIZE;

typedef struct packed {
    logic valid;
    logic [TAG_SIZE-1:0] tag;
} tags_t;

tags_t [NUM_LANES-1:0] cache_tags;
logic  [NUM_LANES-1:0] hit_vector;
logic  tag_hit;

// Help Functions
function logic[INDEX_SIZE-1:0] one_hot_to_binary(logic [NUM_LANES-1:0] one_hot);
    unique case (one_hot)
        1 : return 0;
        2 : return 1;
        4 : return 2;
        8 : return 3;
    endcase
endfunction

always_ff @(posedge clk_i) begin : tag_reset
    if (!rsn_i) begin
        for (int i = 0; i < NUM_LANES; i++) begin
            cache_tags[i].valid <= 0;
            cache_tags[i].tag   <= 0;
        end
    end 
end

always_ff @(posedge clk_i) begin : invalidate_tags
    if (invalidate_i) begin
        for (int i = 0; i < NUM_LANES; i++) begin
            cache_tags[i].valid <= 0;
        end
    end 
end

always_ff @(posedge clk_i) begin : update_tag
    if (mmu_data_i) begin
        cache_tags[index_i].valid <= 1;
        cache_tags[index_i].tag <= tag_i;
    end
end

always_comb begin : tag_rd
    for(int i=0; i<NUM_LANES; i++) begin
        hit_vector[i] = (cache_tags[i].tag == tag_i) & cache_tags[i].valid;
    end
    tag_hit = |hit_vector;
end

assign addr_index_o = one_hot_to_binary(hit_vector);
assign hit_o = tag_hit & req_i;
assign miss_o = ~tag_hit & req_i;

endmodule : segre_icache_tag
