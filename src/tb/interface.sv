import segre_pkg::*;
interface segre_core_if_t;
    logic clk;
    logic rsn;
    logic [ADDR_SIZE-1:0] addr;
    logic [WORD_SIZE-1:0] mem_rd_data;
    logic [WORD_SIZE-1:0] mem_wr_data;
    logic mem_rd;
    logic mem_wr;
    memop_data_type_e mem_data_type;
endinterface : segre_core_if_t