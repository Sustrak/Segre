import segre_pkg::*;

module segre_if_stage (
    // Clock and Reset
    input  logic clk_i,
    input  logic rsn_i,

    // Hazard
    input logic hazard_i,
    output logic hazard_o,

    // FSM state
    input core_fsm_state_e fsm_state_i,

    // IF ID interface
    output logic [WORD_SIZE-1:0] instr_o,

    // WB interface
    input logic tkbr_i,
    input logic [WORD_SIZE-1:0] new_pc_i,

    // MMU interface
    input logic mmu_data_i,
    input logic [DCACHE_LANE_SIZE-1:0] mmu_wr_data_i,
    input logic [ADDR_SIZE-1:0] mmu_addr_i,
    output logic ic_miss_o,
    output logic [ADDR_SIZE-1:0] ic_addr_o,
    output logic ic_access_o
);

logic [ADDR_SIZE-1:0] pc;
logic [ADDR_SIZE-1:0] nxt_pc;

if_fsm_state_e if_fsm_state;
if_fsm_state_e if_fsm_nxt_state;

icache_tag_t cache_tag;
icache_data_t cache_data;

logic pipeline_hazard;

assign cache_tag.addr    = mmu_data_i ? mmu_addr_i : pc;
assign cache_tag.req = (if_fsm_state == IF_IDLE && fsm_state_i == IF_STATE) ? 1'b1 : 1'b0;
assign ic_access_o = cache_tag.req;

assign cache_data.rd_data = fsm_state_i == IF_STATE ? 1'b1 : 1'b0;
assign cache_data.addr    = mmu_data_i ? mmu_addr_i : pc;

assign hazard_o = pipeline_hazard;

segre_icache_tag icache_tag (
    .clk_i        (clk_i),
    .rsn_i        (rsn_i),
    .req_i        (cache_tag.req),
    .mmu_data_i   (mmu_data_i),
    .addr_i       (cache_tag.addr),
    .invalidate_i (1'b0),
    .hit_o        (cache_tag.hit),
    .miss_o       (cache_tag.miss)
);

segre_icache_data icache_data (
    .clk_i         (clk_i),
    .rsn_i         (rsn_i),
    .rd_data_i     (cache_data.rd_data),
    .mmu_wr_data_i (mmu_wr_data_i),
    .addr_i        (cache_data.addr),
    .mmu_data_i    (mmu_data_i),
    .data_o        (cache_data.data_o)
);

always_comb begin : if_fsm
    if (!rsn_i) begin
        if_fsm_nxt_state = IF_IDLE;
    end else begin
        unique case (if_fsm_state)
            IF_IC_MISS: if (mmu_data_i) if_fsm_nxt_state = IF_IDLE;
            IF_IDLE: if (cache_tag.miss) if_fsm_nxt_state = IF_IC_MISS;
            default: ;
        endcase
    end
end

always_comb begin : pc_logic
    if (!rsn_i) begin
        nxt_pc <= 0;
    end else if (!hazard_i | if_fsm_state == IF_IC_MISS) begin
        if (tkbr_i && fsm_state_i == WB_STATE) begin
            nxt_pc <= new_pc_i;
        end else if (fsm_state_i == WB_STATE) begin
            nxt_pc <= nxt_pc + 4;
        end
    end else begin
        nxt_pc <= nxt_pc;
    end
end

always_comb begin : pipeline_stop
    if (!rsn_i) begin
        pipeline_hazard = 0;
    end
    else begin
        unique case (if_fsm_state)
            IF_IC_MISS: pipeline_hazard = 1;
            IF_IDLE: pipeline_hazard = cache_tag.miss;
            default:;
        endcase
    end
end

always_ff @(posedge clk_i) begin
    if (pipeline_hazard) begin
        instr_o <= NOP;
    end
    else if (!hazard_i) begin
        instr_o <= cache_data.data_o;
        pc      <= nxt_pc;
    end
    if_fsm_state <= if_fsm_nxt_state;
end


endmodule : segre_if_stage
