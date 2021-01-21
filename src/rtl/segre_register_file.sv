import segre_pkg::*;

module segre_register_file (
    // Clock and Reset
    input  logic clk_i,
    input  logic rsn_i,

    input  logic [REG_SIZE-1:0]  raddr_a_i,
    output logic [WORD_SIZE-1:0] data_a_o,
    input  logic [REG_SIZE-1:0]  raddr_b_i,
    output logic [WORD_SIZE-1:0] data_b_o,
    input  logic [REG_SIZE-1:0]  raddr_w_i,
    output logic [WORD_SIZE-1:0] data_w_o,

    input rf_wdata_t wdata_i,

    // Recovering
    input logic recovering_i,
    input logic [REG_SIZE-1:0]  reg_recovered_i,
    input logic [WORD_SIZE-1:0] data_recovered_i
);

localparam NUM_REGS = 2**REG_SIZE;

logic [NUM_REGS-1:0][WORD_SIZE-1:0] rf_reg;
logic [NUM_REGS-1:0][WORD_SIZE-1:0] rf_reg_aux;
logic [NUM_REGS-1:0] ex_write_enable;
logic [NUM_REGS-1:0] mem_write_enable;
logic [NUM_REGS-1:0] rvm_write_enable;
logic [NUM_REGS-1:0] recov_write_enable;

always_comb begin
    for (int i = 0; i < NUM_REGS; i++) begin
        ex_write_enable[i]    = (!recovering_i && wdata_i.ex_waddr == 5'(i)) ? wdata_i.ex_we : 1'b0;
        mem_write_enable[i]   = (!recovering_i && wdata_i.mem_waddr == 5'(i)) ? wdata_i.mem_we : 1'b0;
        rvm_write_enable[i]   = (!recovering_i && wdata_i.rvm_waddr == 5'(i)) ? wdata_i.rvm_we : 1'b0;
        recov_write_enable[i] = (recovering_i  && reg_recovered_i == 5'(i)) ? 1'b1 : 1'b0;
    end
end

always_ff @(posedge clk_i) begin
    if (!rsn_i) begin
        rf_reg_aux <= '{default: '0};
    end
    else begin
        for (int j = 1; j < NUM_REGS; j++) begin
            if (ex_write_enable[j])
                rf_reg_aux[j] <= wdata_i.ex_data;
            else if (mem_write_enable[j])
                rf_reg_aux[j] <= wdata_i.mem_data;
            else if (rvm_write_enable[j])
                rf_reg_aux[j] <= wdata_i.rvm_data;
            else if (recov_write_enable[j])
                rf_reg_aux[j] <= data_recovered_i;
        end
    end
end

assign rf_reg[0] = '0;
assign rf_reg[31:1] = rf_reg_aux[31:1];

assign data_a_o = rf_reg[raddr_a_i];
assign data_b_o = rf_reg[raddr_b_i];
assign data_w_o = rf_reg[raddr_w_i];

endmodule : segre_register_file