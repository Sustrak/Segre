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
    input opcode_e id_opcode_i,

    // Pipeline info
    input bypass_data_t pipeline_data_i,
        
    // Bypass
    output bypass_e bypass_a_o,
    output bypass_e bypass_b_o,
    
    // Dependece
    output logic dependence_o
);

logic dependence_src_a;
logic dependence_src_b;

assign dependence_o = dependence_src_a | dependence_src_b;

always_comb begin : data_a
    if (!rsn_i) begin
        dependence_src_a = 0;
        bypass_a_o = NO_BYPASS;
    end
    else begin
        dependence_src_a = 0;
        bypass_a_o = NO_BYPASS;

        if (src_a_i != 0) begin
            if (src_a_i == dst_id_i) begin
                //if (id_opcode_i == OPCODE_OP || id_opcode_i == OPCODE_OP_IMM || id_opcode_i == OPCODE_LUI || id_opcode_i == OPCODE_AUIPC) begin
                if (id_opcode_i == OPCODE_OP || id_opcode_i == OPCODE_OP_IMM || id_opcode_i == OPCODE_AUIPC) begin
                    bypass_a_o = BY_EX_PIPE;
                end
                else begin
                    dependence_src_a = 1'b1;
                end
            end
            else if (src_a_i == pipeline_data_i.ex_wreg) begin
                bypass_a_o = BY_EX_ID;
            end
            else if (src_a_i == pipeline_data_i.mem_wreg) begin
                bypass_a_o = BY_MEM_ID;
            end
            else if (src_a_i == pipeline_data_i.rvm5_wreg) begin
                bypass_a_o = BY_RVM5_ID;
            end
            else if (src_a_i == pipeline_data_i.rvm4_wreg) begin
                bypass_a_o = BY_RVM5_PIPE;
            end
            else if (src_a_i == pipeline_data_i.tl_wreg) begin
                bypass_a_o = BY_MEM_PIPE;
            end
            else if (src_a_i == pipeline_data_i.alu_mem_wreg ||
                     src_a_i == pipeline_data_i.rvm1_wreg    ||
                     src_a_i == pipeline_data_i.rvm2_wreg    ||
                     src_a_i == pipeline_data_i.rvm3_wreg) begin
                dependence_src_a = 1'b1;
            end
        end
    end
end

always_comb begin : data_b
    if (!rsn_i) begin
        dependence_src_b = 0;
        bypass_b_o = NO_BYPASS;
    end
    else begin
        dependence_src_b = 0;
        bypass_b_o = NO_BYPASS;

        if (src_b_i != 0) begin
            if (src_b_i == dst_id_i) begin
                //if (id_opcode_i == OPCODE_OP || id_opcode_i == OPCODE_OP_IMM || id_opcode_i == OPCODE_LUI || id_opcode_i == OPCODE_AUIPC) begin
                if (id_opcode_i == OPCODE_OP || id_opcode_i == OPCODE_LUI || id_opcode_i == OPCODE_AUIPC) begin
                    bypass_b_o = BY_EX_PIPE;
                end
                else begin
                    dependence_src_b = 1'b1;
                end
            end
            else if (src_b_i == pipeline_data_i.alu_mem_wreg) begin
                bypass_b_o = BY_MEM_TL;
            end
            else if (src_b_i == pipeline_data_i.ex_wreg) begin
                bypass_b_o = BY_EX_ID;
            end
            else if (src_b_i == pipeline_data_i.mem_wreg) begin
                bypass_b_o = BY_MEM_ID;
            end
            else if (src_b_i == pipeline_data_i.rvm5_wreg) begin
                bypass_b_o = BY_RVM5_ID;
            end
            else if (src_b_i == pipeline_data_i.rvm4_wreg) begin
                bypass_b_o = BY_RVM5_PIPE;
            end
            else if (src_b_i == pipeline_data_i.tl_wreg) begin
                bypass_b_o = BY_MEM_PIPE;
            end
            else if (src_b_i == pipeline_data_i.rvm3_wreg && instr_opcode_i == OPCODE_STORE) begin
                bypass_b_o = BY_RVM5_TL;
            end
            else if (src_b_i == pipeline_data_i.rvm1_wreg ||
                     src_b_i == pipeline_data_i.rvm2_wreg ||
                     src_b_i == pipeline_data_i.rvm3_wreg) begin
                dependence_src_b = 1'b1;
            end
        end
    end
end

endmodule : segre_bypass_controller