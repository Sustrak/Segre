import segre_pkg::*;

module segre_bypass_controller (
    // Clock and Reset
    input logic clk_i,
    input logic rsn_i,

    // Source registers new instruction
    input logic [REG_SIZE-1:0] src_a_i,
    input logic [REG_SIZE-1:0] src_b_i,
    input opcode_e instr_opcode_i,
    
    // Destination register instruction from ID to PIPELINE
    input logic [REG_SIZE-1:0] dst_id_i,
    
    // Pipeline info
    input bypass_data_t pipeline_data_i,
        
    // Output mux selection
    // Decode
    output bypass_id_e bypass_id_a_o,
    output bypass_id_e bypass_id_b_o,
    // Ex
    output bypass_ex_e bypass_ex_a_o,
    output bypass_ex_e bypass_ex_b_o
);

always_comb begin : data_a
    if (!rsn_i) begin
        bypass_id_a_o = BY_ID_RF;
        bypass_ex_a_o = BY_EX_ID;
    end
    else begin
        bypass_id_a_o = BY_ID_RF;
        bypass_ex_a_o = BY_EX_ID;

        if (src_a_i == dst_id_i) begin
            bypass_ex_a_o = BY_EX_EX;
        end
        else if (src_a_i == pipeline_data_i.ex_wreg) begin
            bypass_id_a_o = BY_ID_EX;
        end
    end
end

always_comb begin : data_b
    if (!rsn_i) begin
        bypass_id_b_o = BY_ID_RF;
        bypass_ex_b_o = BY_EX_ID;
    end
    else begin
        bypass_id_b_o = BY_ID_RF;
        bypass_ex_b_o = BY_EX_ID;

        if (src_b_i == dst_id_i) begin
            bypass_ex_b_o = BY_EX_EX;
        end
        else if (src_b_i == pipeline_data_i.ex_wreg) begin
            bypass_id_b_o = BY_ID_EX;
        end
    end
end


endmodule : segre_bypass_controller