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

localparam NUM_WORDS = 1024 * 64; // 64Kb
localparam TEXT_REGION = 0;
localparam DATA_REGION = 1024*32;

logic [7:0] mem [NUM_WORDS-1:0];

logic [WORD_SIZE-1:0] rd_data;

int num_of_instructions = 0;

initial begin
    static int ret, addr = 0, fd;
    static string line, hex_file_name;

    // Read the hex file path and open the file in read mode
    if (!$value$plusargs("HEX_FILE=%s", hex_file_name))
        `uvm_fatal(get_type_name(), "Start the simulation with +HEX_FILE to load the test into the memory")

    fd = $fopen(hex_file_name, "r");
    if (!fd)
        `uvm_fatal(get_type_name(), $sformatf("%s, couldn't be opened", hex_file_name))

    num_of_instructions = 0;

    while (!$feof(fd)) begin
        if ($fgets(line, fd)) begin
            assert (addr < DATA_REGION) else `uvm_fatal(get_type_name(), ".text was about to get written in .data section")
            `uvm_info(get_type_name(), $sformatf("Writting in %h the data %d", addr, line), UVM_DEBUG);
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
    if (rd_i && addr_i < DATA_REGION)
        `uvm_info(get_type_name(), $sformatf("Reading Instruction: %s (%h)", "NOT_IMPLEMENTED", rd_data), UVM_INFO)
    if (rd_i && addr_i >= DATA_REGION)
        `uvm_info(get_type_name(), $sformatf("Reading data: %h from %h", rd_data, addr_i), UVM_INFO)
    if (wr_i)
        `uvm_info(get_type_name(), $sformatf("Writing %s: %h at %h", data_type_i, data_i, addr_i), UVM_INFO)
endtask

endmodule
