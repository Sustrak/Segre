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
    output logic [ADDR_SIZE-1:0] pc_o,

    // WB interface
    input logic branch_completed_i,
    input logic tkbr_i,
    input logic [WORD_SIZE-1:0] new_pc_i,

    // MMU interface
    input logic mmu_data_i,
    input logic [ICACHE_LANE_SIZE-1:0] mmu_wr_data_i,
    input logic [ICACHE_INDEX_SIZE-1:0] mmu_lru_index_i,
    output logic ic_miss_o,
    output logic [ADDR_SIZE-1:0] ic_addr_o,
    output logic ic_access_o
);

logic [ADDR_SIZE-1:0] nxt_pc;
logic [ADDR_SIZE-1:0] pc;

if_fsm_state_e if_fsm_state;
if_fsm_state_e if_fsm_nxt_state;

icache_tag_t cache_tag;
icache_data_t cache_data;

logic pipeline_hazard;

assign cache_tag.index      = mmu_lru_index_i;
assign cache_tag.tag        = pc[WORD_SIZE-1:ICACHE_BYTE_SIZE];
assign cache_tag.req        = if_fsm_state == IF_IDLE ? 1'b1 : 1'b0;
assign cache_tag.invalidate = 1'b0;
assign cache_tag.mmu_data   = mmu_data_i;

assign cache_data.rd_data     = if_fsm_state == IF_IDLE ? 1'b1 : 1'b0;
assign cache_data.index       = mmu_data_i ? mmu_lru_index_i : cache_tag.addr_index;
assign cache_data.byte_i      = pc[ICACHE_BYTE_SIZE-1:0];
assign cache_data.mmu_wr_data = mmu_wr_data_i;
assign cache_data.mmu_data    = mmu_data_i;

assign ic_access_o = cache_tag.req & rsn_i;
assign ic_miss_o   = cache_tag.miss;

assign ic_addr_o   = cache_tag.miss ? pc : {{WORD_SIZE-ICACHE_INDEX_SIZE{1'b0}}, cache_tag.addr_index};

assign hazard_o = pipeline_hazard;
assign pc_o = (pc - 4);

segre_icache_tag icache_tag (
    .clk_i        (clk_i),
    .rsn_i        (rsn_i),
    .req_i        (cache_tag.req),
    .mmu_data_i   (cache_tag.mmu_data),
    .index_i      (cache_tag.index),
    .tag_i        (cache_tag.tag),
    .invalidate_i (cache_tag.invalidate),
    .addr_index_o (cache_tag.addr_index),
    .hit_o        (cache_tag.hit),
    .miss_o       (cache_tag.miss)
);

segre_icache_data icache_data (
    .clk_i         (clk_i),
    .rsn_i         (rsn_i),
    .rd_data_i     (cache_data.rd_data),
    .mmu_wr_data_i (cache_data.mmu_wr_data),
    .index_i       (cache_data.index),
    .byte_i        (cache_data.byte_i),
    .mmu_data_i    (cache_data.mmu_data),
    .data_o        (cache_data.data_o)
);

always_comb begin : if_fsm
    if (!rsn_i) begin
        if_fsm_nxt_state = IF_IDLE;
    end else begin
        unique case (if_fsm_state)
            IF_IC_MISS: begin
                if (mmu_data_i) if_fsm_nxt_state = IF_IDLE;
                else if_fsm_nxt_state = IF_IC_MISS;
            end
            IF_IDLE: begin
                if (cache_tag.miss) if_fsm_nxt_state = IF_IC_MISS;
                else if (cache_data.data_o[6:0] == OPCODE_BRANCH || cache_data.data_o[6:0] == OPCODE_JAL || cache_data.data_o[6:0] == OPCODE_JALR) begin
                    if_fsm_nxt_state = IF_BRANCH;
                end
                else if_fsm_nxt_state = IF_IDLE;
            end
            IF_BRANCH: begin
                if (branch_completed_i) if_fsm_nxt_state = IF_IDLE;
                else if_fsm_nxt_state = IF_BRANCH;
            end
            default: ;
        endcase
    end
end

always_comb begin : pc_logic
    if (!rsn_i) begin
        nxt_pc = 0;
    end else begin
        if (tkbr_i) begin
            nxt_pc = new_pc_i;
        end else if (if_fsm_state == IF_IC_MISS || if_fsm_state == IF_BRANCH) begin
            nxt_pc = pc;
        end else begin
            nxt_pc = pc + 4;
        end
    end
end

always_comb begin : pipeline_stop
    if (!rsn_i) begin
        pipeline_hazard = 0;
    end
    else begin
        unique case (if_fsm_state)
            IF_IC_MISS: pipeline_hazard = 1;
            IF_IDLE:    pipeline_hazard = cache_tag.miss;
            default:;
        endcase
    end
end

always_ff @(posedge clk_i) begin
    if(!rsn_i) begin
        instr_o <= NOP;
        pc <= 0;
    end
    else if (pipeline_hazard) begin
        instr_o <= NOP;
    end
    else if (!hazard_i) begin
        instr_o <= cache_data.data_o;
        pc    <= nxt_pc;
    end
    if_fsm_state <= if_fsm_nxt_state;
end


endmodule : segre_if_stage
