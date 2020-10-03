`include "uvm_macros.svh"

import segre_pkg::*;
import uvm_pkg::*;

// We should free the pointer but could't find a way to do it with the free_ptr funciton
// because SV seems to lose the ptr since pointers are not a thing in SV
import "DPI-C" function string decode_instruction(unsigned bits);
import "DPI-C" function void free_ptr(chandle ptr);

localparam NUM_REGS = 2**REG_SIZE;

module top_tb;

    timeunit 1ns;
    timeprecision 1ps;

    logic clk;
    logic clk_mem;
    logic rsn;

    string test_name;
    int result_file_fd;

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
        // Check for test files and setup fds for the test bench and memory
        if (!$value$plusargs("TEST_NAME=%s", test_name))
            `uvm_fatal(get_type_name(), "Couldn't find the TEST_NAME argument, please provide it with +TEST_NAME=<testname>")
        else
            `uvm_info(get_type_name(), $sformatf("Starting test: %s", test_name), UVM_LOW)

        tb_mem.hex_file_fd = $fopen($sformatf("../../tests/hex_segre/%s.hex", test_name), "r");
        if (!tb_mem.hex_file_fd)
            `uvm_fatal(get_type_name(), $sformatf("Couldn't find the hex file for %s", test_name))

        result_file_fd = $fopen($sformatf("../../tests/result_segre/%s.result", test_name), "r");
        if (!result_file_fd)
            `uvm_warning(get_type_name(), $sformatf("Couldn't find the result file for %s", test_name))
        
    end

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
        fork
            run_tb;
            monitor_tb;
        join_any
        check_results;
        `uvm_info(get_type_name(), "End Of Test", UVM_LOW)
        $finish;
    end

    task run_tb begin
        while(keep_running_tb) @(posedge clk);
    endtask

    function bit keep_running_tb;
        if (segre_core_if.addr < tb_mem.DATA_REGION && segre_core_if.mem_rd_data == 32'hfff01073)
            return 0;
        return 1;
    endfunction

    function void check_results;
        int golden_results [32];
        int counter = 0;
        logic [WORD_SIZE-1:0][NUM_REGS-1:0] segre_rf;
        string line;

        assign segre_rf = dut.segre_register_file.rf_reg;

        // Read results from file
        while (!$feof(result_file_fd)) begin
            if ($fgets(line, result_file_fd)) begin
                golden_results[counter] = line.atohex();
            end
        end 
    endfunction

    task monitor_tb begin
        `uvm_info(get_type_name(), "Starting tb monitor", UVM_LOW)
        forever begin
            @(segre_core_if.mem_rd);
            if (segre_core_if.addr < tb_mem.DATA_REGION) begin
                string instr_decoded = decode_instruction(segre_core_if.mem_rd_data);
                `uvm_info(get_type_name(), $sformatf("PC: 0x%0h: %s (0x%0h) "), segre_core_if.addr, instr_decoded, segre_core_if.mem_rd_data)
            end
        end
        `uvm_fatal(get_type_name(), "Shouldn't have reach this part of the monitor_tb")
    endtask

endmodule
