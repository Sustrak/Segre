import segre_pkg::*;

module segre_mem_stage (
    // Clock and Reset
    input logic clk_i,
    input logic rsn_i,

    // Memory
    input logic  [WORD_SIZE-1:0] data_i,
    output logic [WORD_SIZE-1:0] data_o,
    output logic [WORD_SIZE-1:0] addr_o,
    output logic memop_rd_o,
    output logic memop_wr_o,
    output memop_data_type_e memop_type_o,

    // EX MEM interface
    // ALU
    input logic [WORD_SIZE-1:0] alu_res_i,
    // Register file
    input logic rf_we_i,
    input logic [REG_SIZE-1:0] rf_waddr_i,
    input logic [WORD_SIZE-1:0] rf_st_data_i,
    // Memop
    input memop_data_type_e memop_type_i,
    input logic memop_sign_ext_i,
    input logic memop_rd_i,
    input logic memop_wr_i,
    // Branch | Jal
    input logic tkbr_i,
    input logic [WORD_SIZE-1:0] new_pc_i,

    // MEM WB interface
    output logic [WORD_SIZE-1:0] op_res_o,
    // Register file
    output logic rf_we_o,
    output logic [REG_SIZE-1:0] rf_waddr_o,
    // Branch | Jal
    output logic tkbr_o,
    output logic [WORD_SIZE-1:0] new_pc_o
);

logic [WORD_SIZE-1:0] mem_data;

always_comb begin
    if (memop_sign_ext_i) begin
        unique case(memop_type_i)
            BYTE: mem_data = { {24{data_i[7]}}, data_i[7:0] };
            HALF: mem_data = { {16{data_i[15]}}, data_i[15:0] };
            WORD: mem_data = data_i;
            default: mem_data = data_i;
        endcase
    end
    else begin
        unique case(memop_type_i)
            BYTE: mem_data = { {24{1'b0}}, data_i[7:0] };
            HALF: mem_data = { {16{1'b0}}, data_i[15:0] };
            WORD: mem_data = data_i;
            default: mem_data = data_i;
        endcase
    end
end

// To memory
assign memop_rd_o   = memop_rd_i;
assign memop_wr_o   = memop_wr_i;
assign addr_o       = alu_res_i;
assign memop_type_o = memop_type_i;
assign data_o       = rf_st_data_i;

always_ff @(posedge clk_i) begin
    // To WB
    op_res_o   = memop_rd_i ? mem_data : alu_res_i;
    rf_we_o    = rf_we_i;
    rf_waddr_o = rf_waddr_i;
    tkbr_o     = tkbr_i;
    new_pc_o   = new_pc_i;
end
endmodule