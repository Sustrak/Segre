import segre_pkg::*;

module segre_history_file (
    // Clock & Reset
    input logic clk_i,
    input logic rsn_i,

    // Input data from id
    input logic req_i,
    input logic [REG_SIZE-1:0] dest_reg_i,
    input logic [WORD_SIZE-1:0] current_value_i,
    
    input logic exc_i,
    input logic [HF_SIZE-1:0] exc_id_i,
    input logic complete_i,
    input logic [HF_SIZE-1:0] complete_id_i,
    
    output logic full_o,
    output logic empty_o,

    output logic recovering_o,
    output logic [REG_SIZE-1:0] dest_reg_o,
    output logic [REG_SIZE-1:0] value_o
);

typedef enum logic {
    NORMAL,
    RECOVERING
} hf_status_e;

typedef enum logic [1:0] {
    EMPTY,
    EXECUTNG,
    EXEC_OK,
    EXCEPTION
} entry_status_e;

typedef struct packed {
    logic [REG_SIZE-1:0] dest_reg;
    logic [WORD_SIZE-1:0] current_value;
    entry_status_e status;
} hf_t;

hf_t [HF_SIZE-1:0] hf;
logic [HF_SIZE-1:0] head, nxt_head, tail, nxt_tail;
hf_status_e hf_status, nxt_hf_status;


assign empty_o = head == tail;
assign full_o  = head-1 == tail;

// Output data
assign recovering_o = hf_status == RECOVERING ? 1'b1 : 1'b0;
assign dest_reg_o = hf[tail].dest_reg;
assign value_o    = hf[tail].current_value;

always_ff @(posedge clk_i) begin : new_entry
    if (req_i) begin
        hf[tail].dest_reg      <= dest_reg_i;
        hf[tail].current_value <= current_value_i;
        hf[tail].status        <= EXECUTNG;
    end
end

always_ff @(posedge clk_i) begin : hf_events
    if (complete_i) begin
        hf[complete_id_i].status <= EXEC_OK;
    end
    if (exc_i) begin
        hf[exc_id_i].status <= EXCEPTION;
    end
end

always_comb begin : fsm_control
    unique case (hf_status)
        NORMAL: begin
            if (hf[head].status == EXCEPTION) nxt_hf_status = RECOVERING;
        end
        RECOVERING: begin
            if (empty_o) nxt_hf_status = NORMAL;
        end
    endcase
end

/*
always_comb begin : queue_control
    unique case (hf_status)
        NORMAL: begin
            if (req_i) begin
                nxt_tail = tail + 1;
            end
            if ((complete_i && complete_id_i == head) || (hf[head].status == EXEC_OK)) begin
                nxt_head = head + 1;
            end
        end
        RECOVERING: begin
            nxt_tail = tail - 1;
        end
    endcase
end
*/

always_ff @(posedge clk_i) begin : queue_control
    unique case (hf_status)
        NORMAL: begin
            if (req_i) begin
                tail <= tail + 1;
            end
            if ((complete_i && complete_id_i == head) || (hf[head].status == EXEC_OK)) begin
                head <= head + 1;
                hf[head].status <= EMPTY;
            end
        end
        RECOVERING: begin
            tail <= tail - 1;
            hf[tail].status <= EMPTY;
        end
    endcase
end

always_ff @(posedge clk_i) begin : latch
    if (rsn_i) begin
        for (int i = 0; i < HF_SIZE; i++) begin
            hf[i].dest_reg      <= 0;
            hf[i].current_value <= 0;
            hf[i].status        <= EXECUTNG;
        end
        tail <= 0;
        head <= 0;
        nxt_tail <= 0;
        nxt_head <= 0;
    end
    else begin
        //tail <= nxt_tail;
        //head <= nxt_head;
        hf_status <= nxt_hf_status;
    end
end

// Verification
assert property (disable iff(!rsn_i) @(posedge clk_i) full_o && req_i) else $fatal("%m: Buffer is full and a new request has arrived");
assert property (disable iff(!rsn_i) @(posedge clk_i) empty_o && complete_i) else $fatal("%m: Buffer is empty and an instruction completed");
assert property (disable iff(!rsn_i) @(posedge clk_i) complete_i |-> hf[complete_id_i].status == EXECUTNG) else $fatal("%m: Completing an instruction that is not executing");

endmodule : segre_history_file