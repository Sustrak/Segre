import segre_pkg::*;

module segre_register_file (
    // Clock and Reset
    input  logic clk_i,
    input  logic rsn_i,

    input  logic we_i,
    input  logic [REG_SIZE-1:0]  raddr_a_i,
    output logic [WORD_SIZE-1:0] data_a_o,
    input  logic [REG_SIZE-1:0]  raddr_b_i,
    output logic [WORD_SIZE-1:0] data_b_o,
    input  logic [REG_SIZE-1:0]  waddr_i,
    input logic [WORD_SIZE-1:0] data_w_i
);

localparam NUM_REGS = 2**REG_SIZE;

logic [WORD_SIZE-1:0][NUM_REGS-1:0] rf_reg;
logic [WORD_SIZE-1:0][NUM_REGS-1:0] rf_reg_aux;
logic [NUM_REGS-1:0] write_enable;

always_comb begin
    for (int i = 0; i < NUM_REGS; i++) begin
        write_enable[i] = (waddr_i == 5'(i)) ? we_i : 1'b0;
    end
end

always_ff @(posedge clk_i) begin
    if (!rsn_i) begin
        rf_reg_aux <= '{default: '0};
    end
    else begin
        for (int j = 1; j < NUM_REGS; j++) begin
            if (write_enable[j])
                rf_reg_aux[j] <= data_w_i;
        end
    end
end

assign rf_reg[0] = '0;
assign rf_reg[31:1] = rf_reg_aux[31:1];

assign data_a_o = rf_reg[raddr_a_i];
assign data_b_o = rf_reg[raddr_b_i];

endmodule : segre_register_file