import segre_pkg::*;

module segre_tlb (
    // Clock & Reset
    input logic clk_i,
    input logic rsn_i,

    // Virtual address
    input logic invalidate_i, //Request for invalidations of the whole TLB
    input logic req_i, //Request for a TLB translation
    input logic new_entry_i, //Request for a TLB write
    input page_protection_e access_type_i, //When doing a request we expect R, W or EX, not RW
    input logic [VADDR_SIZE-1:0] virtual_addr_i,
    input logic [PADDR_SIZE-1:0] physical_addr_i,
    
    output logic pp_exception_o, //Page Protection Exception
    output logic hit_o,
    output logic miss_o,
    output logic [PADDR_SIZE-1:0] physical_addr_o
);

localparam INDEX_SIZE = $clog2(TLB_NUM_ENTRYS);

typedef struct packed {
    logic valid;
    logic [VADDR_SIZE-1:0] vaddr;
    logic [PADDR_SIZE-1:0] paddr;
    page_protection_e page_protection;
} tlb_entry_t;

tlb_entry_t [TLB_NUM_ENTRYS-1:0] tlb;

logic [PADDR_SIZE-1:0] paddr;

logic [TLB_NUM_ENTRYS-1:0] hit_vector;
logic hit;
logic pp_exception;
logic [INDEX_SIZE-1:0] write_position; //Position for the next TLB Write. Round robin fashion.

function logic[INDEX_SIZE-1:0] one_hot_to_binary(logic [TLB_NUM_ENTRYS-1:0] one_hot);
    unique case (one_hot)
        1 : return 0;
        2 : return 1;
        4 : return 2;
        8 : return 3;
        default: return 0;
    endcase
endfunction

always_comb begin : tlb_hit
    for(int i=0; i<TLB_NUM_ENTRYS; i++) begin
        hit_vector[i] = (tlb[i].valid && (tlb[i].vaddr == virtual_addr_i));
    end
    hit = |hit_vector;
end

always_comb begin : tlb_read
    if(!rsn_i) begin
        paddr <= 0;
        pp_exception <= 0;
    end
    else if(tlb[one_hot_to_binary(hit_vector)].valid) begin
        if (tlb[one_hot_to_binary(hit_vector)].page_protection == access_type_i
            | (tlb[one_hot_to_binary(hit_vector)].page_protection == RW & (access_type_i == R | access_type_i == W))) begin
            paddr <= tlb[one_hot_to_binary(hit_vector)].paddr;
            pp_exception <= 0;
        end
        else begin
            pp_exception <= 1;
        end
    end
    else begin
        pp_exception <= 0;        
    end
end

always_ff @(posedge clk_i) begin : tlb_write
    if (!rsn_i) begin
        write_position <= 0;
    end
    else if(new_entry_i) begin
        tlb[write_position].valid <= 1;
        tlb[write_position].vaddr <= virtual_addr_i;
        tlb[write_position].paddr <= physical_addr_i;
        tlb[write_position].page_protection <= access_type_i;
        write_position = write_position+1;
    end
    else if (invalidate_i) begin
        for(int i=0; i<TLB_NUM_ENTRYS; i++) begin
            tlb[i].valid <= 0;
        end
        write_position <= 0;
    end
end

always_ff @(posedge clk_i) begin : tlb_reset
    if (!rsn_i) begin
        tlb[0].valid <= 0;
        tlb[0].vaddr <= 0;
        tlb[0].paddr <= 0;
        tlb[0].page_protection <= EX;
        tlb[1].valid <= 0;
        tlb[1].vaddr <= 20'h0000A;
        tlb[1].paddr <= 8'h0A;
        tlb[1].page_protection <= RW;
        for(int i=2; i<TLB_NUM_ENTRYS; i++) begin
            tlb[i].valid <= 0;
            tlb[i].vaddr <= 0;
            tlb[i].paddr <= 0;
            tlb[i].page_protection <= R;
        end
    end
end

assign physical_addr_o = paddr;
assign pp_exception_o = pp_exception & req_i;
assign hit_o  = hit & req_i;
assign miss_o = !hit & req_i;

endmodule : segre_tlb
