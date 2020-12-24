import segre_pkg::*;

module segre_pipeline_wrapper (
    // Clock & Reset
    input logic clk_i,
    input logic rsn_i,

    // Decode information
    input core_pipeline_t core_pipeline_i,

    // Register File
    output rf_wdata_t rf_data_o,
    // Branch & Jump
    output logic tkbr_o,
    output logic [ADDR_SIZE-1:0] new_pc_o,

    // MMU
    input logic mmu_data_rdy_i,
    input logic [DCACHE_LANE_SIZE-1:0] mmu_data_i,
    input logic [DCACHE_INDEX_SIZE-1:0] mmu_lru_index_i,
    output logic mmu_miss_o,
    output logic [ADDR_SIZE-1:0] mmu_addr_o,
    output logic mmu_cache_access_o,
    output logic [WORD_SIZE-1:0] mmu_data_o,
    output memop_data_type_e mmu_store_data_type_o,
    output logic mmu_store_o,

    // Bypass logic to decode
    output bypass_data_t bypass_data_o
);

mem_pipeline_t mem_data;
ex_pipeline_t  ex_data;
rvm_pipeline_t rvm_data;

// Hazard signals
logic tl_hazard;

assign ex_data.hazard = 1'b0;

segre_ex_stage ex_stage (
    // Clock and Reset
    .clk_i            (clk_i),
    .rsn_i            (rsn_i),

    // Hazards
    .hazard_i         (ex_data.hazard),

    // Input
    .alu_opcode_i     (ex_data.alu_opcode),
    .alu_src_a_i      (ex_data.alu_src_a),
    .alu_src_b_i      (ex_data.alu_src_b),
    .rf_we_i          (ex_data.rf_we),
    .rf_waddr_i       (ex_data.rf_waddr),
    .br_src_a_i       (ex_data.br_src_a),
    .br_src_b_i       (ex_data.br_src_b),

    // Output
    .alu_res_o        (rf_data_o.ex_data),
    .rf_we_o          (rf_data_o.ex_we),
    .rf_waddr_o       (rf_data_o.ex_waddr),
    .tkbr_o           (tkbr_o),
    .new_pc_o         (new_pc_o)
);

segre_mem_pipeline mem_pipeline (
    // Clock and Reset
    .clk_i                 (clk_i),
    .rsn_i                 (rsn_i),

    // Input
    .alu_src_a_i           (mem_data.alu_src_a),
    .alu_src_b_i           (mem_data.alu_src_b),
    .rf_we_i               (mem_data.rf_we),
    .rf_waddr_i            (mem_data.rf_waddr),
    .rf_st_data_i          (mem_data.rf_st_data),
    .memop_rd_i            (mem_data.memop_rd),
    .memop_wr_i            (mem_data.memop_wr),
    .memop_sign_ext_i      (mem_data.memop_sign_ext),
    .memop_type_i          (mem_data.memop_type),

    // Output
    .data_o                (rf_data_o.mem_data),
    .rf_we_o               (rf_data_o.mem_we),
    .rf_waddr_o            (rf_data_o.mem_waddr),

    // MMU
    .mmu_data_rdy_i        (mmu_data_rdy_i),
    .mmu_data_i            (mmu_data_i),
    .mmu_lru_index_i       (mmu_lru_index_i),
    .mmu_miss_o            (mmu_miss_o),
    .mmu_addr_o            (mmu_addr_o),
    .mmu_cache_access_o    (mmu_cache_access_o),
    .mmu_data_o            (mmu_data_o),
    .mmu_store_data_type_o (mmu_store_data_type_o),
    .mmu_store_o           (mmu_store_o),

    // Hazards
    .tl_hazard_o           (tl_hazard)
);

segre_rvm_pipeline rvm_pipeline (
    // Clock and Reset
    .clk_i (clk_i),
    .rsn_i (rsn_i),

    .alu_opcode_i (rvm_data.alu_opcode),
    .alu_src_a_i  (rvm_data.alu_src_a),
    .alu_src_b_i  (rvm_data.alu_src_b),
    .rf_we_i      (rvm_data.rf_we),
    .rf_waddr_i   (rvm_data.rf_waddr),

    .alu_res_o    (rf_data_o.rvm_data),
    .rf_we_o      (rf_data_o.rvm_we),
    .rf_waddr_o   (rf_data_o.rvm_waddr)
);

always_comb begin : input_decoder
    // EX PIPELINE
    ex_data.alu_opcode      = core_pipeline_i.alu_opcode;
    ex_data.br_src_a        = core_pipeline_i.br_src_a;
    ex_data.br_src_b        = core_pipeline_i.br_src_b;
    // MEM PIPELINE
    mem_data.memop_sign_ext = core_pipeline_i.memop_sign_ext;
    mem_data.memop_type     = core_pipeline_i.memop_type;
    mem_data.rf_st_data     = core_pipeline_i.rf_st_data;
    // RVM PIPELINE
    rvm_data.alu_opcode     = core_pipeline_i.alu_opcode;
    
    if (core_pipeline_i.pipeline == EX_PIPELINE) begin
        ex_data.rf_we    = core_pipeline_i.rf_we;
        ex_data.rf_waddr = core_pipeline_i.rf_waddr;
    end
    else begin
        ex_data.rf_we    = 0;
        ex_data.rf_waddr = 0;
    end
    
    if (core_pipeline_i.pipeline == MEM_PIPELINE) begin
        mem_data.rf_we       = core_pipeline_i.rf_we;
        mem_data.rf_waddr    = core_pipeline_i.rf_waddr;
        mem_data.memop_rd    = core_pipeline_i.memop_rd;
        mem_data.memop_wr    = core_pipeline_i.memop_wr;
    end
    else begin
        mem_data.rf_we       = 0;
        mem_data.rf_waddr    = 0;
        mem_data.memop_rd    = 0;
        mem_data.memop_wr    = 0;
    end

    if (core_pipeline_i.pipeline == RVM_PIPELINE) begin
        rvm_data.rf_we    = core_pipeline_i.rf_we;
        rvm_data.rf_waddr = core_pipeline_i.rf_waddr;
    end
    else begin
        rvm_data.rf_we    = 0;
        rvm_data.rf_waddr = 0;
    end

end

always_comb begin : bypass
    unique case (core_pipeline_i.bypass_ex_a)
        BY_EX_ID: begin
            ex_data.alu_src_a  = core_pipeline_i.alu_src_a;
            mem_data.alu_src_a = core_pipeline_i.alu_src_a;
            rvm_data.alu_src_a = core_pipeline_i.alu_src_a;
        end
        BY_EX_EX: begin
            ex_data.alu_src_a  = rf_data_o.ex_data;
            mem_data.alu_src_a = rf_data_o.ex_data;
            rvm_data.alu_src_a = rf_data_o.ex_data;
        end
        default: if (rsn_i) $fatal("Other cases not implemented yet");
    endcase

    unique case (core_pipeline_i.bypass_ex_b)
        BY_EX_ID: begin
            ex_data.alu_src_b  = core_pipeline_i.alu_src_b;
            mem_data.alu_src_b = core_pipeline_i.alu_src_b;
            rvm_data.alu_src_b = core_pipeline_i.alu_src_b;
        end
        BY_EX_EX: begin
            ex_data.alu_src_b  = rf_data_o.ex_data;
            mem_data.alu_src_b = rf_data_o.ex_data;
            rvm_data.alu_src_b = rf_data_o.ex_data;
        end
        default: if (rsn_i) $fatal("Other cases not implemented yet");
    endcase
end

always_comb begin : bypass_output_data
    if (rf_data_o.ex_we) begin
        bypass_data_o.ex_wreg = rf_data_o.ex_waddr;
        bypass_data_o.ex_data = rf_data_o.ex_data;
    end else begin
        bypass_data_o.ex_wreg = 0;
        bypass_data_o.ex_data = 0;
    end
end

// VERIFICATION
property not_same_waddr_p(we, waddr, we2, waddr2);
    @(posedge clk_i) we |-> !(we2 && (waddr == waddr2));
endproperty

assert property (disable iff(!rsn_i) 
    not_same_waddr_p(rf_data_o.ex_we, rf_data_o.ex_waddr, rf_data_o.mem_we, rf_data_o.mem_waddr)   and
    not_same_waddr_p(rf_data_o.ex_we, rf_data_o.ex_waddr, rf_data_o.rvm_we, rf_data_o.rvm_waddr)   and
    not_same_waddr_p(rf_data_o.mem_we, rf_data_o.mem_waddr, rf_data_o.ex_we, rf_data_o.ex_waddr)   and 
    not_same_waddr_p(rf_data_o.mem_we, rf_data_o.mem_waddr, rf_data_o.rvm_we, rf_data_o.rvm_waddr) and 
    not_same_waddr_p(rf_data_o.rvm_we, rf_data_o.rvm_waddr, rf_data_o.ex_we, rf_data_o.ex_waddr)   and 
    not_same_waddr_p(rf_data_o.rvm_we, rf_data_o.rvm_waddr, rf_data_o.mem_we, rf_data_o.mem_waddr)
) else begin
    $fatal("%m: Writing to same register");
end 

endmodule : segre_pipeline_wrapper