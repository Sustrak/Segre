import segre_pkg::*;

`define ADDR_TAG ADDR_SIZE-1:DCACHE_BYTE_SIZE

module segre_tl_stage (
    input logic clk_i,
    input logic rsn_i,
    input logic kill_i,
    // EX TL interface
    // ALU
    input logic [WORD_SIZE-1:0] addr_i,
    // Register file
    input logic rf_we_i,
    input logic [REG_SIZE-1:0] rf_waddr_i,
    input logic [WORD_SIZE-1:0] rf_st_data_i,
    // Memop
    input logic memop_rd_i,
    input logic memop_wr_i,
    input logic memop_sign_ext_i,
    input memop_data_type_e memop_type_i,
    // Instruction ID
    input logic [HF_PTR-1:0] instr_id_i,
    // Store permission from HF
    input logic store_permission_i, // TODO: Connect this signal so the SB only writes to cache if it is up

    // TL MEM interface
    // ALU
    output logic [WORD_SIZE-1:0] addr_o,
    // Register file
    output logic rf_we_o,
    output logic [REG_SIZE-1:0] rf_waddr_o,
    // Memop
    output logic [DCACHE_INDEX_SIZE-1:0] addr_index_o,
    output logic memop_rd_o,
    output logic memop_wr_o,
    output logic memop_sign_ext_o,
    output memop_data_type_e memop_type_o,
    output memop_data_type_e memop_type_flush_o,
    // Store buffer
    output logic sb_hit_o,
    output logic sb_flush_o,
    output logic [WORD_SIZE-1:0] sb_data_load_o,
    output logic [WORD_SIZE-1:0] sb_data_flush_o,
    output logic [ADDR_SIZE-1:0] sb_addr_o,
    output logic sb_buffer_merge_o,
    // Instruction ID
    output logic [HF_PTR-1:0] instr_id_o,

    // MMU interface
    input logic mmu_data_rdy_i,
    input logic [DCACHE_LANE_SIZE-1:0] mmu_data_i,
    input logic [DCACHE_INDEX_SIZE-1:0] mmu_lru_index_i,
    input logic [ADDR_SIZE-1:0] mmu_addr_i,
    output logic mmu_miss_o,
    output logic [ADDR_SIZE-1:0] mmu_addr_o,
    output logic mmu_cache_access_o,

    // Hazard
    output logic pipeline_hazard_o,

    //Privilege mode / Virual mem
    input logic [WORD_SIZE-1:0] csr_priv_i,
    input logic [WORD_SIZE-1:0] csr_satp_i,

    // Exceptions
    output logic pp_exception_o,
    output logic [HF_PTR-1:0] pp_exception_id_o,
    output logic [ADDR_SIZE-1:0] pp_addr_o
);

dcache_tag_t cache_tag;
store_buffer_t sb;
tlb_st_t tlb_st;

logic [ADDR_SIZE-1:0] tlb_faulting_address;
logic [ADDR_SIZE-1:0] physical_addr_aux;

tl_fsm_state_e fsm_state;
tl_fsm_state_e fsm_nxt_state;
logic pipeline_hazard;

logic [DCACHE_TAG_SIZE-1:0] tag_in_flight_next;
logic valid_tag_in_flight_next;
logic [DCACHE_TAG_SIZE-1:0] tag_in_flight_reg;
logic valid_tag_in_flight_reg;
logic miss_in_fligt_miss;

// Exceptions
assign pp_exception_o    = tlb_st.pp_exception;
assign pp_exception_id_o = instr_id_i;
assign pp_addr_o         = {tlb_st.physical_addr_i, {ADDR_SIZE-PADDR_SIZE{1'b0}}};

//TLB
//assign tlb_st.access_type = memop_wr_i ? W : R;
assign physical_addr_aux = csr_satp_i + tlb_faulting_address;
assign tlb_st.physical_addr_i = physical_addr_aux[VADDR_SIZE-1:12];
assign tlb_st.invalidate = 1'b0; //TODO: Actualitzar quan afegim excepcions
assign tlb_st.new_entry = (fsm_state == HAZARD_DTLB_MISS);

always_comb begin : access_type_selection
    if (fsm_state == HAZARD_DTLB_MISS) begin
        tlb_st.access_type = RW;
    end
    else begin
        if (memop_wr_i) tlb_st.access_type = W;
        else tlb_st.access_type = R;
    end
end

always_comb begin : tlb_faulting_address_source_selection
    if (sb.flush_chance & sb.data_valid) tlb_faulting_address = sb.addr_o;
    else if (mmu_data_rdy_i)             tlb_faulting_address = mmu_addr_i;
    else                                 tlb_faulting_address = addr_i;
end

always_comb begin : tlb_vaddr_selection
    if (sb.flush_chance & sb.data_valid) tlb_st.virtual_addr = sb.addr_o [WORD_SIZE-1:12];
    else if (mmu_data_rdy_i)             tlb_st.virtual_addr = mmu_addr_i[WORD_SIZE-1:12];
    else                                 tlb_st.virtual_addr = addr_i [WORD_SIZE-1:12];
end

always_comb begin : tlb_request
    if(csr_priv_i == 1) begin
        tlb_st.req <= 0;
    end
    else begin
        if (fsm_state == TL_IDLE | fsm_state == MISS_IN_FLIGHT) begin
            tlb_st.req <= (memop_rd_i | memop_wr_i);
        end
        else begin
            tlb_st.req <= 0;
        end
    end
end

always_comb begin : cache_tag_selection
    if(csr_priv_i == 1) begin
        if (sb.flush_chance & sb.data_valid) cache_tag.tag = sb.addr_o [`ADDR_TAG];
        else if (mmu_data_rdy_i)             cache_tag.tag = mmu_addr_i[`ADDR_TAG];
        else                                 cache_tag.tag = addr_i [`ADDR_TAG];
    end
    else begin
        //TODO: Revisar aixo
        if (sb.flush_chance & sb.data_valid) cache_tag.tag = {12'h000,tlb_st.physical_addr_o,sb.addr_o[11:DCACHE_BYTE_SIZE]};
        else if (mmu_data_rdy_i)             cache_tag.tag = mmu_addr_i[`ADDR_TAG];//{12'h000,tlb_st.physical_addr_o,mmu_addr_i[11:DCACHE_BYTE_SIZE]};
        else                                 cache_tag.tag = {12'h000,tlb_st.physical_addr_o,addr_i[11:DCACHE_BYTE_SIZE]};
    end
end

assign cache_tag.req        = (fsm_state == TL_IDLE | fsm_state == MISS_IN_FLIGHT) ? (memop_rd_i | memop_wr_i) : 1'b0;
assign cache_tag.mmu_data   = mmu_data_rdy_i;
assign cache_tag.index      = mmu_lru_index_i;

/*always_comb begin : cache_tag_selection
    if (sb.flush_chance & sb.data_valid) cache_tag.tag = sb.addr_o [`ADDR_TAG];
    else if (mmu_data_rdy_i)             cache_tag.tag = mmu_addr_i[`ADDR_TAG];
    else                                 cache_tag.tag = addr_i [`ADDR_TAG];
end*/

always_comb begin : mmu_addr_selection
    if(mmu_data_rdy_i) begin
        mmu_addr_o <= cache_tag.addr; //Possible writeback. As cache store PA, we can send it to Memory as it is.
    end
    else if(csr_priv_i == 1) begin
        if (cache_tag.miss | memop_wr_i) begin
            mmu_addr_o <= addr_i; //Requesting a line to cache
        end
        else begin
            mmu_addr_o <= {{WORD_SIZE-DCACHE_INDEX_SIZE{1'b0}}, cache_tag.addr_index};
        end
    end
    else begin
        if (cache_tag.miss | memop_wr_i) begin
            mmu_addr_o <= {12'h000,tlb_st.physical_addr_o,addr_i[11:0]}; //Requesting a line to cache
        end
        else begin
            mmu_addr_o <= {{WORD_SIZE-DCACHE_INDEX_SIZE{1'b0}}, cache_tag.addr_index};
        end
    end
end

assign cache_tag.invalidate = 0;

// MMU
assign mmu_cache_access_o = (cache_tag.req | sb.req_store | sb.req_load) & !tlb_st.miss;
//assign mmu_addr_o         = (cache_tag.miss | memop_wr_i) ? alu_res_i : {{WORD_SIZE-DCACHE_INDEX_SIZE{1'b0}}, cache_tag.addr_index};
assign mmu_miss_o         = (csr_priv_i == 1) ? rsn_i & (cache_tag.miss & sb.miss) : rsn_i & (cache_tag.miss & sb.miss) & !tlb_st.miss; 
//assign mmu_miss_o         = rsn_i & ((cache_tag.miss | sb.miss | !(valid_tag_in_flight_reg & (memop_rd_i | memop_wr_i) & (tag_in_flight_reg == addr_i[`ADDR_TAG])); 
assign pipeline_hazard_o  = pipeline_hazard;
// Write through
//assign mmu_wr_o           = memop_wr_i;
//assign mmu_wr_data_type_o = memop_type_i;
//assign mmu_data_o         = rf_st_data_i;

// STORE BUFFER
assign sb.req_store         = (fsm_state == TL_IDLE || fsm_state == MISS_IN_FLIGHT) ? memop_wr_i & !tlb_st.miss : 1'b0;
//assign sb.req_store         = (fsm_state == TL_IDLE || fsm_state == MISS_IN_FLIGHT) ? (memop_wr_i & !pipeline_hazard_o) : 1'b0;
assign sb.req_load          = (fsm_state == TL_IDLE || fsm_state == MISS_IN_FLIGHT) ? memop_rd_i : 1'b0;
assign sb.addr_i            = addr_i;
assign sb.data_i            = rf_st_data_i;
assign sb.memop_data_type_i = memop_type_i;

segre_tlb dtlb (
    .clk_i           (clk_i),
    .rsn_i           (rsn_i),
    .invalidate_i    (tlb_st.invalidate),
    .req_i           (tlb_st.req),
    .new_entry_i     (tlb_st.new_entry),
    .access_type_i   (tlb_st.access_type),
    .virtual_addr_i  (tlb_st.virtual_addr),
    .physical_addr_i (tlb_st.physical_addr_i),
    .pp_exception_o  (tlb_st.pp_exception),
    .hit_o           (tlb_st.hit),
    .miss_o          (tlb_st.miss),
    .physical_addr_o (tlb_st.physical_addr_o)
);

segre_dcache_tag dcache_tag (
    .clk_i        (clk_i),
    .rsn_i        (rsn_i),
    .req_i        (cache_tag.req),
    .mmu_data_i   (cache_tag.mmu_data),
    .index_i      (cache_tag.index),
    .tag_i        (cache_tag.tag),
    .invalidate_i (cache_tag.invalidate),
    .addr_o       (cache_tag.addr),
    .addr_index_o (cache_tag.addr_index),
    .hit_o        (cache_tag.hit),
    .miss_o       (cache_tag.miss)
);

segre_store_buffer store_buffer (
    .clk_i             (clk_i),
    .rsn_i             (rsn_i),
    .empty_i           (kill_i),
    .req_store_i       (sb.req_store),
    .req_load_i        (sb.req_load),
    .flush_chance_i    (sb.flush_chance),
    .addr_i            (sb.addr_i),
    .data_i            (sb.data_i),
    .memop_data_type_i (sb.memop_data_type_i),
    .instr_id_i        (instr_id_i),
    .hit_o             (sb.hit),
    .miss_o            (sb.miss),
    //.full_o            (sb.full),
    .trouble_o         (sb.trouble),
    .data_valid_o      (sb.data_valid),
    .memop_data_type_o (sb.memop_data_type_o), //Only for flushing purposes
    .data_load_o       (sb.data_load_o),
    .data_flush_o      (sb.data_flush_o),
    .addr_o            (sb.addr_o),
    .instr_id_o        (sb.instr_id),
    .buffer_merge_o    (sb.buffer_merge)
);

/*always_comb begin : sb_req_store
    unique case (fsm_state)
        TL_IDLE : sb.req_store <= memop_wr_i;
        MISS_IN_FLIGHT : sb.req_store <= memop_wr_i & (!valid_tag_in_flight_reg | (tag_in_flight_reg != alu_res_i[`ADDR_TAG]));
        HAZARD_DC_MISS : sb.req_store <= 0;
        HAZARD_SB_TROUBLE : sb.req_store <= 0;
        default: sb.req_store <= 0; 
    endcase
end*/

always_comb begin : sb_flush_chance
    unique case (fsm_state)
        MISS_IN_FLIGHT:    sb.flush_chance = 0;
        TL_IDLE:           sb.flush_chance = store_permission_i & (!memop_wr_i & !memop_rd_i);
        HAZARD_DC_MISS:    sb.flush_chance = 0;
        HAZARD_DTLB_MISS:  sb.flush_chance = 0;
        HAZARD_SB_TROUBLE: sb.flush_chance = store_permission_i;
        default:           sb.flush_chance = 0;
    endcase
end

always_comb begin : pipeline_stop
    if (!rsn_i) begin
        pipeline_hazard = 0;
    end
    else begin
        unique case (fsm_state)
            HAZARD_DC_MISS:    pipeline_hazard = 1;
            HAZARD_SB_TROUBLE: pipeline_hazard = 1;
            HAZARD_DTLB_MISS:  pipeline_hazard = 1;
            MISS_IN_FLIGHT: begin
                //TODO:Josep, Mira aixo dels static bit
                //static bit different_tag = valid_tag_in_flight_reg & (tag_in_flight_reg != addr_i[`ADDR_TAG]);
                //static bit same_tag      = valid_tag_in_flight_reg & (tag_in_flight_reg == addr_i[`ADDR_TAG]);
                pipeline_hazard = (tlb_st.miss & (memop_rd_i | memop_wr_i)) |
                    (memop_rd_i & (cache_tag.miss & ( (valid_tag_in_flight_reg & (tag_in_flight_reg != addr_i[`ADDR_TAG])) | sb.miss | sb.trouble))) |
                    (memop_wr_i & (cache_tag.hit | (valid_tag_in_flight_reg & (tag_in_flight_reg != addr_i[`ADDR_TAG])) | ( (valid_tag_in_flight_reg & (tag_in_flight_reg == addr_i[`ADDR_TAG]))& sb.trouble)));
                    //(memop_wr_i & (cache_tag.hit | different_tag | (same_tag & sb.trouble)));
            end
            TL_IDLE: begin 
                if(memop_wr_i) begin
                    pipeline_hazard = sb.trouble | tlb_st.miss; //All stores go through the SB, we don't have to check the cache.
                end
                else begin
                    pipeline_hazard = tlb_st.miss | (sb.miss & cache_tag.miss); //Load cannot be served from the SB or the cache
                end
            end
            default:;
        endcase
    end
end

always_comb begin : tl_fsm
    if (!rsn_i) begin
        fsm_nxt_state = TL_IDLE;
    end else begin
        unique case (fsm_state)
            MISS_IN_FLIGHT: begin
                if(mmu_data_rdy_i) fsm_nxt_state = TL_IDLE;
                else if (tlb_st.miss) fsm_nxt_state = HAZARD_DTLB_MISS;
                else if(memop_wr_i) begin //When a new store arrives and don't have the same tag as the first faulty one we need to stall
                    /*if(cache_tag.hit) //I think this is necessary to protect the write-through strategy
                        fsm_nxt_state = HAZARD_DC_MISS;*/
                    if(valid_tag_in_flight_reg && (tag_in_flight_reg != addr_i[`ADDR_TAG])) begin
                        fsm_nxt_state = HAZARD_DC_MISS;
                    end //We must also take into account the SB problematic
                    else if((valid_tag_in_flight_reg && (tag_in_flight_reg == addr_i[`ADDR_TAG])) && sb.trouble) begin
                        fsm_nxt_state = HAZARD_DC_MISS;
                    end
                    else fsm_nxt_state = MISS_IN_FLIGHT;
                end
                else if (memop_rd_i) begin //A new load arrives: In this case we won't issue a new request if the load has the same tag as the faulty store, or if it hits (obviously).
                    if(cache_tag.miss) begin //In general, we want to stall in a miss, but if the store buffer can serve the load it's not necessary
                        if (valid_tag_in_flight_reg && (tag_in_flight_reg != addr_i[`ADDR_TAG])) begin
                            fsm_nxt_state = HAZARD_DC_MISS;
                        end //Maybe the store buffer can provide the element
                        else if(sb.miss || sb.trouble) begin
                            fsm_nxt_state = HAZARD_DC_MISS;
                        end
                        else begin
                            fsm_nxt_state = MISS_IN_FLIGHT;
                        end
                    end
                end
                else fsm_nxt_state = MISS_IN_FLIGHT;                
            end
            HAZARD_DC_MISS: begin
                if (mmu_data_rdy_i) fsm_nxt_state = TL_IDLE;
                else fsm_nxt_state = HAZARD_DC_MISS;
            end
            HAZARD_SB_TROUBLE: begin
                if (!sb.trouble) fsm_nxt_state = TL_IDLE;
                else fsm_nxt_state = HAZARD_SB_TROUBLE;
            end
            HAZARD_DTLB_MISS: begin
                if(valid_tag_in_flight_reg) fsm_nxt_state = MISS_IN_FLIGHT;
                else fsm_nxt_state = TL_IDLE;
            end
            TL_IDLE: begin
                if (tlb_st.miss) fsm_nxt_state = HAZARD_DTLB_MISS;
                else if (valid_tag_in_flight_next) begin
                    if(sb.trouble) fsm_nxt_state = HAZARD_SB_TROUBLE; //Miss on a store, but SB can't store the data
                    else fsm_nxt_state = MISS_IN_FLIGHT; //Failing a store and SB can store the data
                end
                else if (cache_tag.miss) fsm_nxt_state = HAZARD_DC_MISS;
                else if (sb.trouble)     fsm_nxt_state = HAZARD_SB_TROUBLE;
                else                     fsm_nxt_state = TL_IDLE;
            end
            default:;
        endcase
    end
end

always_comb begin : miss_in_fligt
    tag_in_flight_next <= addr_i[`ADDR_TAG];
    valid_tag_in_flight_next <= memop_wr_i & (!tlb_st.miss & !sb.trouble & cache_tag.miss);
    //miss_in_fligt_miss <= (memop_rd_i | memop_wr_i)
end

always_ff @(posedge clk_i) begin : miss_in_fligt_latch
    if(!rsn_i) begin
        tag_in_flight_reg <= 0;
        valid_tag_in_flight_reg <= 0;
    end
    else begin
        if(fsm_state == TL_IDLE) begin// && fsm_nxt_state != HAZARD_DTLB_MISS) begin
            tag_in_flight_reg <= tag_in_flight_next;
            valid_tag_in_flight_reg <= valid_tag_in_flight_next;
        end
        //Else don't update the reg
    end
end

always_ff @(posedge clk_i) begin : stage_latch
    if (!rsn_i) begin
        addr_o             <= 0;
        rf_we_o            <= 0;
        rf_waddr_o         <= 0;
        addr_index_o       <= 0;
        memop_rd_o         <= 0;
        memop_wr_o         <= 0;
        memop_sign_ext_o   <= 0;
        memop_type_o       <= WORD;
        memop_type_flush_o <= WORD;
        sb_hit_o           <= 0;
        sb_data_flush_o    <= 0;
        sb_data_flush_o    <= 0;
        sb_addr_o          <= 0;
        sb_flush_o         <= 0;
        sb_buffer_merge_o  <= 0;
        instr_id_o         <= 0;
    end 
    else begin
        if (!pipeline_hazard) begin
            if(sb.flush_chance & sb.data_valid) begin
                // Flush data from store buffer to the data cache
                sb_addr_o        <= sb.addr_o;
                sb_data_load_o   <= sb.data_load_o;
                sb_data_flush_o  <= sb.data_flush_o;
                sb_hit_o         <= 1'b0;
                memop_rd_o       <= 1'b0;
                memop_wr_o       <= !kill_i & sb.data_valid;
                instr_id_o       <= sb.instr_id;
            end
            else if(sb.hit) begin
                //Load or Store hit at store buffer, no need to access cache
                sb_data_load_o   <= sb.data_load_o;
                sb_data_flush_o  <= sb.data_flush_o;
                sb_hit_o         <= sb.hit;
                memop_rd_o       <= !kill_i & memop_rd_i; //We have already read
                memop_wr_o       <= 1'b0; //We have already write

                if(memop_rd_i) instr_id_o  <= instr_id_i;
                else instr_id_o  <= sb.instr_id;
            end
            else begin
                // Miss in store buffer or no memory operation and store buffer empty
                memop_rd_o       <= !kill_i & memop_rd_i;
                memop_wr_o       <= 1'b0;
                instr_id_o       <= instr_id_i;
            end
            addr_o             <= addr_i;
            rf_we_o            <= !kill_i & rf_we_i;
            rf_waddr_o         <= rf_waddr_i;
            memop_sign_ext_o   <= memop_sign_ext_i;
            addr_index_o       <= cache_tag.addr_index;
            memop_type_o       <= memop_type_i;
            memop_type_flush_o <= sb.memop_data_type_o;
            sb_flush_o         <= sb.data_valid;
            sb_buffer_merge_o  <= sb.buffer_merge;
        end
        else begin
            if(fsm_state == HAZARD_SB_TROUBLE) begin
                sb_addr_o        <= sb.addr_o;
                sb_data_load_o   <= sb.data_load_o;
                sb_data_flush_o  <= sb.data_flush_o;
                sb_hit_o         <= 1'b0;
                memop_wr_o       <= !kill_i & sb.data_valid;
                sb_flush_o       <= sb.data_valid;
                addr_index_o     <= cache_tag.addr_index;
                instr_id_o       <= sb.instr_id;
            end
            else begin
                memop_wr_o <= 0;
                sb_flush_o <= 0;
            end
            rf_we_o           <= 0;
            memop_rd_o        <= 0;
            sb_buffer_merge_o <= 0;
        end       
        fsm_state <= fsm_nxt_state;
    end
end

endmodule : segre_tl_stage
