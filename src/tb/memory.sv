`include "uvm_macros.svh"

import segre_pkg::*;
import uvm_pkg::*;

module memory (
    input logic clk_i,
    input logic rsn_i,
    input logic rd_i,
    input logic wr_i,
    input memop_data_type_e data_type_i,
    input logic [WORD_SIZE-1:0] addr_i,
    input logic [WORD_SIZE-1:0] data_i,
    output logic [WORD_SIZE-1:0] data_o
);

parameter NUM_WORDS = 1024 * 64; // 64Kb
parameter TEXT_REGION = 0;
parameter DATA_REGION = 1024*32;

logic [7:0] mem [NUM_WORDS-1:0];

logic [WORD_SIZE-1:0] rd_data;

int num_of_instructions = 0;

int hex_file_fd;
string test_name;

initial begin
    int addr = 0;
    static string line, hex_file_name;

    // Read the hex file path and open the file in read mode
    num_of_instructions = 0;

    // Check for test files and setup fds for the test bench and memory
    if (!$value$plusargs("TEST_NAME=%s", test_name))
        `uvm_fatal("top_tb", "Couldn't find the TEST_NAME argument, please provide it with +TEST_NAME=<testname>")
    else
        `uvm_info("top_tb", $sformatf("Starting test: %s", test_name), UVM_LOW)

    hex_file_fd = $fopen($sformatf("./tests/hex_segre/%s.hex", test_name), "r");
    if (!hex_file_fd)
        `uvm_fatal("top_tb", $sformatf("Couldn't find the hex file for %s", test_name))


    while (!$feof(hex_file_fd)) begin
        if ($fgets(line, hex_file_fd)) begin
            assert (addr < DATA_REGION) else `uvm_fatal("memory", ".text was about to get written in .data section")
            `uvm_info("memory", $sformatf("Writting in %h the data %d", addr, line), UVM_LOW);
            mem[addr]   = line.substr(6, 7).atohex();
            mem[addr+1] = line.substr(4, 5).atohex();
            mem[addr+2] = line.substr(2, 3).atohex();
            mem[addr+3] = line.substr(0, 1).atohex();
            addr += 4;
            num_of_instructions++;
        end
    end
end

always @(posedge clk_i) begin
    if (rd_i) begin
        rd_data = {mem[addr_i+3], mem[addr_i+2], mem[addr_i+1], mem[addr_i]};
    end
    if (wr_i) begin
        case(data_type_i)
            BYTE: begin
                mem[addr_i] = data_i[1:0];
            end
            HALF: begin
                mem[addr_i] = data_i[1:0];
                mem[addr_i+1] = data_i[3:2];
            end
            WORD: begin
                mem[addr_i] = data_i[1:0];
                mem[addr_i+1] = data_i[3:2];
                mem[addr_i+2] = data_i[5:4];
                mem[addr_i+3] = data_i[7:6];
            end
            default: ;
        endcase
    end
    memory_verbose();
end

always @(posedge clk_i) data_o <= rd_data;

task memory_verbose;
    if (rd_i)
        `uvm_info("memory", $sformatf("Reading data: %h from %h", rd_data, addr_i), UVM_INFO)
    if (wr_i)
        `uvm_info("memory", $sformatf("Writing %s: %h at %h", data_type_i, data_i, addr_i), UVM_INFO)
endtask

endmodule
