import segre_pkg::*;

module top_tb;

    timeunit 1ns;
    timeprecision 1ps;

    logic clk;
    logic clk_mem;
    logic rsn;

    segre_core_if_t segre_core_if();

    assign segre_core_if.clk = clk;
    assign segre_core_if.rsn = rsn;

    segre_core dut(
        .clk_i           (segre_core_if.clk),
        .rsn_i           (segre_core_if.rsn),
        .mem_rd_data_i   (segre_core_if.mem_rd_data),
        .mem_wr_data_o   (segre_core_if.mem_wr_data),
        .addr_o          (segre_core_if.addr),
        .mem_rd_o        (segre_core_if.mem_rd),
        .mem_wr_o        (segre_core_if.mem_wr),
        .mem_data_type_o (segre_core_if.mem_data_type)
    );

    memory tb_mem (
        .clk_i       (clk_mem),
        .rsn_i       (rsn),
        .data_i      (segre_core_if.mem_wr_data),
        .data_o      (segre_core_if.mem_rd_data),
        .addr_i      (segre_core_if.addr),
        .rd_i        (segre_core_if.mem_rd),
        .wr_i        (segre_core_if.mem_wr),
        .data_type_i (segre_core_if.mem_data_type)
    );

    initial begin
        clk <= 0;
        clk_mem <= 0;
        rsn <= 0;
    end

    always #10 clk = ~clk;
    always #5  clk_mem = ~clk_mem;

    initial begin
        repeat(2) @(posedge clk);
        rsn <= 1;
        repeat(tb_mem.num_of_instructions) repeat(5) @(posedge clk);
        $finish;
    end

endmodule