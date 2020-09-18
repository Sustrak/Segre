import segre_pkg::*;

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
    static string line;
    static int ret;
    static int addr = 0;
    static int fd = $fopen(`HEX_FILE, "r");


    if (!fd) $fatal($sformatf("%s, couldn't be opened", `HEX_FILE));
    num_of_instructions = 0;

    while (!$feof(fd)) begin
        if ($fgets(line, fd)) begin
            assert (addr < DATA_REGION) else $fatal(".text was about to get written in .data section");
            `ifdef DEBUG
                $display("DEBUG: Writting in %h the data %d", addr, line);
            `endif
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
end

always @(posedge clk_i) data_o <= rd_data;

endmodule