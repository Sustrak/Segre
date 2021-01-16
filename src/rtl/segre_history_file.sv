import segre_pkg::*;

module segre_history_file (
    // Clock & Reset
    input logic clk_i,
    input logic rsn_i,

    // Input data from id
    input logic req_i,
    input logic store_i,
    input logic [REG_SIZE-1:0] dest_reg_i,
    input logic [WORD_SIZE-1:0] current_value_i,

    input logic exc_i,
    input logic [HF_PTR-1:0] exc_id_i,
    input logic complete_ex_i,
    input logic [HF_PTR-1:0] complete_ex_id_i,
    input logic complete_mem_i,
    input logic [HF_PTR-1:0] complete_mem_id_i,
    input logic complete_st_i,
    input logic [HF_PTR-1:0] complete_st_id_i,
    input logic complete_rvm_i,
    input logic [HF_PTR-1:0] complete_rvm_id_i,

    output logic full_o,
    output logic empty_o,

    output logic store_permission_o,

    output logic recovering_o,
    output logic [REG_SIZE-1:0] dest_reg_o,
    output logic [WORD_SIZE-1:0] value_o
);

typedef enum logic {
    NORMAL,
    RECOVERING
} hf_status_e;

typedef enum logic [2:0] {
    EMPTY,
    EXECUTNG,
    EXECUTING_STORE,
    EXEC_OK,
    EXCEPTION
} entry_status_e;

typedef struct packed {
    logic [REG_SIZE-1:0] dest_reg;
    logic [WORD_SIZE-1:0] current_value;
    entry_status_e status;
} hf_t;

hf_t [HF_SIZE-1:0] hf;
logic [HF_PTR-1:0] head, tail, nxt_head, nxt_tail;
hf_status_e hf_status, nxt_hf_status;


assign empty_o = (head == tail);
assign full_o  = (head-1 == tail);
assign store_permission_o = (hf[head].status == EXECUTING_STORE);

// Output data
assign recovering_o = hf_status == RECOVERING ? 1'b1 : 1'b0;
assign dest_reg_o = hf[tail].dest_reg;
assign value_o    = hf[tail].current_value;

always_comb begin : fsm_control
    nxt_hf_status = hf_status;
    unique case (hf_status)
        NORMAL: begin
            if (hf[head].status == EXCEPTION) nxt_hf_status = RECOVERING;
        end
        RECOVERING: begin
            if (empty_o) nxt_hf_status = NORMAL;
        end
    endcase
end

always_comb begin : queue_control
    unique case (hf_status)
        NORMAL: begin
            int instr_ended;
            if (req_i) nxt_tail = tail + 1;
            else nxt_tail = tail;

            instr_ended = complete_ex_i + complete_mem_i + complete_rvm_i + complete_st_i;
            nxt_head = head;
            for (int i = 0; i < instr_ended; i++) begin
                if (complete_ex_id_i == nxt_head || complete_mem_id_i == nxt_head || complete_rvm_id_i == nxt_head || complete_st_id_i == nxt_head || hf[nxt_head].status == EXEC_OK) begin
                    nxt_head++;
                end
            end
        end
        RECOVERING: begin
            nxt_tail = tail - 1;
        end
    endcase
end

always_ff @(posedge clk_i) begin : latch
    if (!rsn_i) begin
        for (int i = 0; i < HF_SIZE; i++) begin
            hf[i].dest_reg      <= 0;
            hf[i].current_value <= 0;
            hf[i].status        <= EMPTY;
        end
        tail <= 0;
        head <= 0;
        hf_status <= NORMAL;
    end
    else begin
        hf_status <= nxt_hf_status;
        head <= nxt_head;
        tail <= nxt_tail;

        unique case (hf_status)
            NORMAL: begin
                if (req_i) begin
                    hf[tail].dest_reg      <= dest_reg_i;
                    hf[tail].current_value <= current_value_i;
                    if (store_i) hf[tail].status <= EXECUTING_STORE;
                    else hf[tail].status <= EXECUTNG;
                end

                if (complete_ex_i)  hf[complete_ex_id_i].status <= EXEC_OK;
                if (complete_mem_i) hf[complete_mem_id_i].status <= EXEC_OK;
                if (complete_rvm_i) hf[complete_rvm_id_i].status <= EXEC_OK;
                if (complete_st_i)  hf[complete_st_id_i].status <= EXEC_OK; 
                if (exc_i) hf[exc_id_i].status <= EXCEPTION;
            end
            RECOVERING: begin
                hf[tail].status <= EMPTY;
            end
            default: ;
        endcase
    end
end

// Verification
//assert property (disable iff(!rsn_i) @(posedge clk_i) req_i |-> !full_o)
//    else $fatal("%m: Buffer is full and a new request has arrived");
//assert property (disable iff(!rsn_i) @(posedge clk_i) (complete_ex_i | complete_mem_i | complete_rvm_i) && !req_i |-> !empty_o)
//    else $fatal("%m: Buffer is empty and an instruction completed");
//assert property (disable iff(!rsn_i) @(posedge clk_i) complete_ex_i |-> hf[complete_ex_id_i].status == EXECUTNG)
//    else $fatal("%m: Completing an instruction that is not executing");
//assert property (disable iff(!rsn_i) @(posedge clk_i) complete_mem_i |-> hf[complete_mem_id_i].status == EXECUTNG)
//    else $fatal("%m: Completing an instruction that is not executing");
//assert property (disable iff(!rsn_i) @(posedge clk_i) complete_rvm_i |-> hf[complete_rvm_id_i].status == EXECUTNG)
//    else $fatal("%m: Completing an instruction that is not executing");

property not_same_id_p(completed, id, completed2, id2);
    @(posedge clk_i) completed |-> !(completed2 && (id == id2));
endproperty

assert property (disable iff(!rsn_i)
    not_same_id_p(complete_ex_i, complete_ex_id_i, complete_mem_i, complete_mem_id_i)   and
    not_same_id_p(complete_ex_i, complete_ex_id_i, complete_rvm_i, complete_rvm_id_i)   and
    not_same_id_p(complete_ex_i, complete_ex_id_i, complete_st_i, complete_st_id_i)     and
    not_same_id_p(complete_mem_i, complete_mem_id_i, complete_ex_i, complete_ex_id_i)   and
    not_same_id_p(complete_mem_i, complete_mem_id_i, complete_rvm_i, complete_rvm_id_i) and
    not_same_id_p(complete_mem_i, complete_mem_id_i, complete_st_i, complete_st_id_i)   and
    not_same_id_p(complete_rvm_i, complete_rvm_id_i, complete_ex_i, complete_ex_id_i)   and
    not_same_id_p(complete_rvm_i, complete_rvm_id_i, complete_mem_i, complete_mem_id_i) and
    not_same_id_p(complete_rvm_i, complete_rvm_id_i, complete_st_i, complete_st_id_i)
) else begin
    $fatal("%m: Different pipelines completing instruction with same id");
end

endmodule : segre_history_file