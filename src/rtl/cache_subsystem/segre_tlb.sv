import segre_pkg::*;

module segre_tlb (
    // Clock & Reset
    input logic clk_i,
    input logic rsn_i,

    // Virtual address
    input logic req_i,
    input logic new_entry_i,
    input logic [VADDR_SIZE-1:0] virtual_addr_i,
    input logic [PADDR_SIZE-1:0] physical_addr_i,
    
    output logic hit_o,
    output logic miss_o,
    output logic [PADDR_SIZE-1:0] physical_addr_o
);

typedef struct packed {
    logic [VADDR_SIZE-1:0] vaddr;
    logic [PADDR_SIZE-1:0] paddr;

    logic valid;
} tlb_entry_t;

tlb_entry_t [TLB_NUM_ENTRYS-1:0] tlb;


endmodule : segre_tlb
