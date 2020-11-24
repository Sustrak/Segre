import segre_pkg::*;

module segre_controller (
    // Clock and Reset
    input logic clk_i,
    input logic rsn_i,

    // State
    output core_fsm_state_e state_o
);

core_fsm_state_e state = IF_STATE;
core_fsm_state_e next_state;

always_ff @(posedge clk_i) begin
    next_state = IF_STATE;
    unique case(state)
        IF_STATE: next_state = ID_STATE;
        ID_STATE: next_state = EX_STATE;
        EX_STATE: next_state = MEM_STATE;
        MEM_STATE: next_state = WB_STATE;
        default: ;
    endcase
end

always_ff @(posedge clk_i) begin
    if (!rsn_i)
        state = IF_STATE;
    else
        state = next_state;
end

assign state_o = state;
endmodule