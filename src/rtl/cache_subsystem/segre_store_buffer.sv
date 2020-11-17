import segre_pkg::*;

module segre_store_buffer (
    input logic clk_i,
    input logic rsn_i,
    input logic req_store_i,
    input logic req_load_i,
    input logic flush_chance_i, //our chance to flush elements!
    input logic [ADDR_SIZE-1:0] addr_i,
    input logic [WORD_SIZE-1:0] data_i,
    input memop_data_type_e memop_data_type_i,
    output logic hit_o,
    output logic miss_o,
    output logic full_o,
    output logic data_valid_o,
    output logic [WORD_SIZE-1:0] data_o,
    output logic [ADDR_SIZE-1:0] addr_o
);

localparam NUM_ELEMS = STORE_BUFFER_NUM_ELEMS;
localparam INDEX_SIZE = $clog2(NUM_ELEMS);

//Logic variables to store the data
logic [NUM_ELEMS-1:0] buf_position_valid;
logic [ADDR_SIZE-1:0][NUM_ELEMS-1:0] buf_address;
logic [WORD_SIZE-1:0][NUM_ELEMS-1:0] buf_data;

//Pointers of the circular buffer
logic [NUM_ELEMS-1:0] head; //where to write NEXT element
logic [NUM_ELEMS-1:0] tail; //oldest element in the buffer

//Logic elements to manage data and output it
logic [WORD_SIZE-1:0] data_load;
logic [WORD_SIZE-1:0] data_flush;
logic [ADDR_SIZE-1:0] address;
logic full;
logic [NUM_ELEMS-1:0]hit_vector;
logic hit;
logic data_valid;

// Help Functions
function logic[INDEX_SIZE-1:0] one_hot_to_binary(logic [NUM_ELEMS-1:0] one_hot);
    logic [INDEX_SIZE-1:0] ret;
    foreach(one_hot[index]) begin
        if (one_hot[index] == 1'b1) begin
            ret |= index;
        end
    end
    return ret;
endfunction


//TODO change this in the case we scale the size
always_comb begin : buffer_full
    full = &buf_position_valid && req_store_i; //If every position is full and the processor wants to perform a store, we must stall the pipeline
end

always_comb begin : buffer_hit
    for(int i=0; i<NUM_ELEMS; i++) begin
        //We save the exact hit because it will be useful
        hit_vector[i] <= (buf_position_valid[i] & (buf_address[i] == addr_i));
    end
    hit = |hit_vector;
end

always_comb begin : buffer_load //The proc issued a load and maybe we are holding that value
    //for + if
    data_load <= buf_data[one_hot_to_binary(hit_vector)];
    /*unique case(hit_vector)
        01 : data_load = buf_data[0];
        10 : data_load = buf_data[1];
        default : ;
        //Compare all tags
        //if hit, say it and output the desired value
        //else say it's a miss
        //IMPORTANT: do not erase the data, it's not written to cache!!!
    endcase*/
end

always_ff @(posedge clk_i) begin : buffer_reset //Invalidate all positions and restart the pointers
    if (!rsn_i) begin
        for(int i=0; i<NUM_ELEMS; i++) begin
            buf_position_valid[i] <= 0;
            head[i] <= 0;
            tail[i] <= 0;
        end
    end 
end

//FIXME: Do this actually work?
//The idea is that the values are hold correctly during the whole cycle and at the end the always_ff invalidates the position
always_comb begin : buffer_flush_comb
    data_flush <= buf_data[tail];
    address <= buf_address[tail];
    data_valid <= (memop_data_type_i && (tail != head || full) && buf_position_valid[tail]);
end

always_ff @(posedge clk_i) begin : buffer_flush //the cache it's not busy, so we can send an element to the cache
    if (memop_data_type_i) begin
        if((tail != head || full) && buf_position_valid[tail]) begin
            //data_flush <= buf_data[tail];
            //address <= buf_address[tail];
            buf_position_valid[tail] <= 0;
            //data_valid <= 1;
            tail = tail+1;
        end
        //if tail != head or full (when empty, they are equal)
        //select the position pointed by tail and output it
        //invalidate tail position and update the tail pointer
    end
end

always_ff @(posedge clk_i) begin : buffer_store
    if (req_store_i) begin
        if (hit) begin
            for (int j = 0; j < NUM_ELEMS; j++) begin
                if (hit_vector[j]) //Just one of these bits should be set
                    buf_data[j] <= data_i; //We just need to write the data since the @ will be the same
            end
        end
        else begin
            if (!full) begin
                buf_address[head] <= addr_i;
                buf_data[head] <= data_i;
                buf_position_valid[head] <= 1;
                head = head+1;
            end
        end
        //Compare all tags
        //if hit, write in the hit position
        //else
            //if buffer is full, notify it
            //else, store the data at the head position
    end
end

assign full_o = full & (!hit);
assign hit_o = hit;
assign miss_o = !hit;
assign data_o = (req_load_i) ? data_load : data_flush;
assign addr_o = address;
assign data_valid_o = data_valid;

endmodule
