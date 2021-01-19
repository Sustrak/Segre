import segre_pkg::*;

module segre_csr_file (
    // Clock and Reset
    input  logic clk_i,
    input  logic rsn_i,
    
    input  logic we_i,
    input  logic [CSR_SIZE-1:0] raddr_i,
    input  logic [CSR_SIZE-1:0] waddr_i,
    input  logic [WORD_SIZE-1:0] data_i,
    output logic [WORD_SIZE-1:0] data_o,

    output logic [WORD_SIZE-1:0] csr_satp_o,
    output logic [WORD_SIZE-1:0] csr_priv_o,
    output logic [WORD_SIZE-1:0] csr_sie_o,
    output logic [WORD_SIZE-1:0] csr_scause_o,
    output logic [WORD_SIZE-1:0] csr_sepc_o,
    output logic [WORD_SIZE-1:0] csr_stval_o,
    output logic [WORD_SIZE-1:0] csr_stvec_o
);

localparam NUM_REGS = 2**CSR_SIZE;

logic [NUM_REGS-1:0][WORD_SIZE-1:0] csr_reg;
logic [NUM_REGS-1:0][WORD_SIZE-1:0] csr_reg_aux;
logic [NUM_REGS-1:0] write_enable;

always_comb begin
    for (int i = 0; i < NUM_REGS; i++) begin
        write_enable[i] = (waddr_i == 12'(i)) ? we_i : 1'b0;
    end
end

always_ff @(posedge clk_i) begin
    if (!rsn_i) begin
        csr_reg_aux[NUM_REGS-1:7] <= '{default: '0};
        csr_reg_aux[CSR_SATP]   <= 32'h0000_8000;
        csr_reg_aux[CSR_PRIV]   <= 32'h2;
        csr_reg_aux[CSR_SIE]    <= 32'h1;
        csr_reg_aux[CSR_SCAUSE] <= 32'h0;
        csr_reg_aux[CSR_SEPC]   <= 32'h0;
        csr_reg_aux[CSR_STVAL]  <= 32'h0;
        csr_reg_aux[CSR_STVEC]  <= 32'h0000_2000;
    end
    else begin
        for (int j = 0; j < NUM_REGS; j++) begin
            if (write_enable[j])
                csr_reg_aux[j] <= data_i;
        end
    end
end

always_comb begin : csr_outputs
    csr_satp_o   = csr_reg[CSR_SATP];
    csr_priv_o   = csr_reg[CSR_PRIV];
    csr_sie_o    = csr_reg[CSR_SIE];
    csr_scause_o = csr_reg[CSR_SCAUSE];
    csr_sepc_o   = csr_reg[CSR_SEPC];
    csr_stval_o  = csr_reg[CSR_STVAL];
    csr_stvec_o  = csr_reg[CSR_STVEC];
end

assign csr_reg = csr_reg_aux;
assign data_o = csr_reg[raddr_i];

endmodule : segre_csr_file