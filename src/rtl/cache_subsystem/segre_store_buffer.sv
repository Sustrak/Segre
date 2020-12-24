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
    //output logic full_o,
    output logic trouble_o,
    output logic data_valid_o,
    output memop_data_type_e memop_data_type_o,
    output logic [WORD_SIZE-1:0] data_load_o, //Support for load and flush at the same cycle
    output logic [WORD_SIZE-1:0] data_flush_o,
    output logic [ADDR_SIZE-1:0] addr_o
);

localparam NUM_ELEMS = 2;
localparam INDEX_SIZE = $clog2(NUM_ELEMS);

typedef struct packed{
    logic valid;
    logic [ADDR_SIZE-1:0] address;
    logic [3:0][7:0] data ;
    memop_data_type_e data_type;
} buf_elem;

buf_elem [NUM_ELEMS-1:0] buffer;

//Logic variables to store the data
/*logic [NUM_ELEMS-1:0] buf_position_valid;
logic [ADDR_SIZE-1:0][NUM_ELEMS-1:0] buf_address;
logic [WORD_SIZE-1:0][NUM_ELEMS-1:0] buf_data;
memop_data_type_e [NUM_ELEMS-1:0] buf_type;*/ 

//Pointers of the circular buffer
logic [NUM_ELEMS-2:0] head; //where to write NEXT element
logic [NUM_ELEMS-2:0] tail; //oldest element in the buffer

//Logic elements to manage data and output it
memop_data_type_e memop_data_type;
logic [WORD_SIZE-1:0] data_load;
logic [WORD_SIZE-1:0] data_flush;
logic [ADDR_SIZE-1:0] address;
logic full;
logic [NUM_ELEMS-1:0]hit_vector;
logic hit;
logic data_valid;
logic trouble;

// Help Functions
/*function logic[INDEX_SIZE-1:0] one_hot_to_binary(logic [NUM_ELEMS-1:0] one_hot);
    logic [INDEX_SIZE-1:0] ret;
    foreach(one_hot[index]) begin
        if (one_hot[index] == 1'b1) begin
            ret |= index;
        end
    end
    return ret;
endfunction*/
function logic[INDEX_SIZE-1:0] one_hot_to_binary(logic [NUM_ELEMS-1:0] one_hot);
    unique case (one_hot)
        1 : return 0;
        2 : return 1;
        4 : return 2;
        8 : return 3;
        default: return 0;
    endcase
endfunction

always_comb begin : buffer_full
    /*static logic aux = buffer[0].valid;
    for(int i=1; i<NUM_ELEMS; i++) begin
        aux &= buffer[i].valid;
    end
    full = aux && req_store_i;*/
    full = buffer[0].valid & buffer[1].valid; //& req_store_i;
    //full = &buf_position_valid && req_store_i; //If every position is full and the processor wants to perform a store, we must stall the pipeline
end

always_comb begin : buffer_hit
    for(int i=0; i<NUM_ELEMS; i++) begin
        //We save the exact hit because it will be useful
        //TODO: I THINK WE SHOULD PUT A UNIQUE CASE HERE, BASED ON THE MEMOP_DATA_TYPE
        hit_vector[i] = (buffer[i].valid && ((buffer[i].address & ~2'b11) == (addr_i & ~2'b11))); //We make the comparison mod 4
    end
    hit = |hit_vector;
end

/*
always_comb begin : buffer_load //The proc issued a load and maybe we are holding that value
    //for + if
    static int aux = one_hot_to_binary(hit_vector);
    //TODO: Can I do this in a single sentence now?
    unique case (buffer[aux].data_type)
        BYTE: data_load[7:0] <= buffer[aux].data[buffer[aux].address[1:0]];
        HALF: begin
            data_load[7:0] <= buffer[aux].data[{buffer[aux].address[1:1], 1'b0}];
            data_load[15:8] <= buffer[aux].data[{buffer[aux].address[1:1], 1'b1}];
        end
        WORD: begin
            data_load[7:0] <= buffer[aux].data[0];
            data_load[15:8] <= buffer[aux].data[1];
            data_load[23:16] <= buffer[aux].data[2];
            data_load[31:24] <= buffer[aux].data[3];
        end
        default: ;
    endcase
    
end*/
always_comb begin : buffer_load //The proc issued a load and maybe we are holding that value
    unique case (buffer[one_hot_to_binary(hit_vector)].data_type)
        BYTE: data_load[7:0] <= buffer[one_hot_to_binary(hit_vector)].data[buffer[one_hot_to_binary(hit_vector)].address[1:0]];
        HALF: begin
            data_load[7:0] <= buffer[one_hot_to_binary(hit_vector)].data[{buffer[one_hot_to_binary(hit_vector)].address[1:1], 1'b0}];
            data_load[15:8] <= buffer[one_hot_to_binary(hit_vector)].data[{buffer[one_hot_to_binary(hit_vector)].address[1:1], 1'b1}];
        end
        WORD: begin
            data_load[7:0] <= buffer[one_hot_to_binary(hit_vector)].data[0];
            data_load[15:8] <= buffer[one_hot_to_binary(hit_vector)].data[1];
            data_load[23:16] <= buffer[one_hot_to_binary(hit_vector)].data[2];
            data_load[31:24] <= buffer[one_hot_to_binary(hit_vector)].data[3];
        end
        default: ;
    endcase
    
end

always_ff @(posedge clk_i) begin : buffer_reset //Invalidate all positions and restart the pointers
    if (!rsn_i) begin
        for(int i=0; i<NUM_ELEMS; i++) begin
            buffer[i].valid <= 0;
            buffer[i].address <= 0;
            buffer[i].data[0] <= 0;
            buffer[i].data[1] <= 0;
            buffer[i].data[2] <= 0;
            buffer[i].data[3] <= 0;
            buffer[i].data_type <= WORD;
        end
        head <= 0;
        tail <= 0;
    end 
end

//FIXME: Do this actually work?
//The idea is that the values are hold correctly during the whole cycle and at the end the always_ff invalidates the position
always_comb begin : buffer_flush_comb
    unique case (buffer[tail].data_type)
        BYTE: data_flush[7:0] <= buffer[tail].data[buffer[tail].address[1:0]];
        HALF: begin
            data_flush[7:0] <= buffer[tail].data[{buffer[tail].address[1:1], 1'b0}];
            data_flush[15:8] <= buffer[tail].data[{buffer[tail].address[1:1], 1'b1}];
        end
        WORD: begin
            data_flush[7:0] <= buffer[tail].data[0];
            data_flush[15:8] <= buffer[tail].data[1];
            data_flush[23:16] <= buffer[tail].data[2];
            data_flush[31:24] <= buffer[tail].data[3];
        end
        default: ;
    endcase
    address <= buffer[tail].address;
    memop_data_type <= buffer[tail].data_type;
    data_valid <= (flush_chance_i && (tail != head || full) && buffer[tail].valid);
end

always_ff @(posedge clk_i) begin : buffer_flush //the cache it's not busy, so we can send an element to the cache
    if (flush_chance_i) begin
        if((tail != head || full) && buffer[tail].valid) begin
            buffer[tail].valid <= 0;
            tail = tail+1;
        end
        //if tail != head or full (when empty, they are equal)
        //select the position pointed by tail and output it
        //invalidate tail position and update the tail pointer
    end
end

always_comb begin : buffer_store_problematic 
    if (hit) begin
        //static int aux = one_hot_to_binary(hit_vector);
        unique case (buffer[one_hot_to_binary(hit_vector)].data_type) 
            BYTE : trouble <= (memop_data_type_i != BYTE) | ((buffer[one_hot_to_binary(hit_vector)].address[1:0] != addr_i[1:0]));
            HALF : begin
                unique case(memop_data_type_i)
                BYTE: begin
                    if((buffer[one_hot_to_binary(hit_vector)].address & ~1'b1) != (addr_i & ~1'b1)) begin
                        trouble <= 1;
                    end
                    else begin
                        trouble <= 0;
                    end
                end
                WORD: trouble <= 1;
                default: ;
                endcase
            end
            WORD: trouble <= 0;
            default: ;
        endcase
    end
    else begin
        trouble <= 0;
    end
end

always_ff @(posedge clk_i) begin : buffer_store
    if (req_store_i) begin
        if (hit) begin //
            if(!trouble) begin //If there's a problematic store we should flush the buffer content
                //static int aux = one_hot_to_binary(hit_vector);
                unique case (buffer[one_hot_to_binary(hit_vector)].data_type) 
                    BYTE: buffer[one_hot_to_binary(hit_vector)].data[addr_i[1:0]] <= data_i[7:0];
                    HALF: begin
                        unique case(memop_data_type_i) 
                            BYTE: buffer[one_hot_to_binary(hit_vector)].data[addr_i[1:0]] <= data_i[7:0];
                            HALF: begin
                                buffer[one_hot_to_binary(hit_vector)].data[{addr_i[1:1], 1'b0}] <= data_i[7:0];
                                buffer[one_hot_to_binary(hit_vector)].data[{addr_i[1:1], 1'b1}] <= data_i[15:8];
                            end
                            default: ;
                        endcase
                    end
                    WORD: begin
                        unique case (memop_data_type_i) 
                            BYTE: buffer[one_hot_to_binary(hit_vector)].data[0] <= data_i[7:0];
                            HALF: begin
                                buffer[one_hot_to_binary(hit_vector)].data[0] <= data_i[7:0];
                                buffer[one_hot_to_binary(hit_vector)].data[1] <= data_i[15:8];
                            end
                            WORD: begin
                                buffer[one_hot_to_binary(hit_vector)].data[0] <= data_i[7:0];
                                buffer[one_hot_to_binary(hit_vector)].data[1] <= data_i[15:8];
                                buffer[one_hot_to_binary(hit_vector)].data[2] <= data_i[23:16];
                                buffer[one_hot_to_binary(hit_vector)].data[3] <= data_i[31:24];
                            end
                            default: ;
                        endcase
                    end
                    default: ;
                endcase
            end
        end
        else begin 
            if (!full) begin
                unique case (memop_data_type_i) 
                    BYTE: buffer[head].data[addr_i[1:0]] <= data_i[7:0];
                    HALF: begin
                        buffer[head].data[{addr_i[1:1], 1'b0}] <= data_i[7:0];
                        buffer[head].data[{addr_i[1:1], 1'b1}] <= data_i[15:8];
                    end
                    WORD: begin
                        buffer[head].data[0] <= data_i[7:0];
                        buffer[head].data[1] <= data_i[15:8];
                        buffer[head].data[2] <= data_i[23:16];
                        buffer[head].data[3] <= data_i[31:24];
                    end
                    default: ;
                endcase
                buffer[head].address <= addr_i;
                buffer[head].valid <= 1;
                buffer[head].data_type <= memop_data_type_i;
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

assign trouble_o = trouble || (full & (!hit) & req_store_i);
//assign full_o = full & (!hit);
assign hit_o = hit & (req_load_i | req_store_i);
assign miss_o = !hit & (req_load_i | req_store_i);
//assign data_o = (req_load_i) ? data_load : data_flush;
assign memop_data_type_o = memop_data_type;
assign data_load_o = data_load;
assign data_flush_o = data_flush;
assign addr_o = address;
assign data_valid_o = data_valid;

endmodule
