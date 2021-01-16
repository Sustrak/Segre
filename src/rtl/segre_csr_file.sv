import segre_pkg::*;

module segre_csr_file (
    // Clock and Reset
    input  logic clk_i,
    input  logic rsn_i,
    
    input  logic we_i,
    input  logic [CSR_SIZE-1:0] raddr_i,
    input  logic [CSR_SIZE-1:0] waddr_i,
    input  logic [WORD_SIZE-1:0] data_i,
    output logic [WORD_SIZE-1:0] data_o
);

localparam NUM_REGS = 2**CSR_SIZE;

logic [WORD_SIZE-1:0][NUM_REGS-1:0] csr_reg;
logic [WORD_SIZE-1:0][NUM_REGS-1:0] csr_reg_aux;
logic [NUM_REGS-1:0] write_enable;

always_comb begin
    for (int i = 0; i < NUM_REGS; i++) begin
        write_enable[i] = (waddr_i == 12'(i)) ? we_i : 1'b0;
    end
end

always_ff @(posedge clk_i) begin
    if (!rsn_i) begin
        csr_reg_aux <= '{default: '0};
    end
    else begin
        for (int j = 0; j < NUM_REGS; j++) begin
            if (write_enable[j])
                csr_reg_aux[j] <= data_i;
        end
    end
end

assign csr_reg = csr_reg_aux;

assign data_o = csr_reg[raddr_i];

endmodule : segre_csr_file