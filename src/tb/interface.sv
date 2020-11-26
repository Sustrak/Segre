import segre_pkg::*;
interface segre_core_if_t;
    logic clk;
    logic rsn;
    logic [ADDR_SIZE-1:0] mm_addr;
    logic [ADDR_SIZE-1:0] mm_wr_addr;
    logic [DCACHE_LANE_SIZE-1:0] mm_rd_data;
    logic [WORD_SIZE-1:0] mm_wr_data;
    logic mm_rd;
    logic mm_wr;
    logic mm_data_rdy;
    memop_data_type_e mm_data_type;
endinterface : segre_core_if_t