import segre_pkg::*;

module segre_pipeline_wrapper (
    // Clock & Reset
    input logic clk_i,
    input logic rsn_i,

    // Decode information
    input core_pipeline_t core_pipeline_i,

    // Register File
    output rf_wdata_t rf_data_o,
    // CSR File
    output logic csr_access_o,
    output logic [CSR_SIZE-1:0] csr_waddr_o,
    output logic [WORD_SIZE-1:0] csr_data_o,
    // Instruction ID
    output logic [HF_PTR-1:0] ex_instr_id_o,
    output logic [HF_PTR-1:0] mem_instr_id_o,
    output logic [HF_PTR-1:0] rvm_instr_id_o,
    // Store completed
    output logic mem_wr_done_o,
    output logic [HF_PTR-1:0] mem_wr_done_id_o,
    // Branch & Jump
    output logic branch_completed_o,
    output logic tkbr_o,
    output logic [ADDR_SIZE-1:0] new_pc_o,

    // MMU
    input logic mmu_data_rdy_i,
    input logic [ADDR_SIZE-1:0] mmu_addr_i,
    input logic [DCACHE_LANE_SIZE-1:0] mmu_data_i,
    input logic [DCACHE_INDEX_SIZE-1:0] mmu_lru_index_i,
    output logic mmu_miss_o,
    output logic [ADDR_SIZE-1:0] mmu_addr_o,
    output logic mmu_cache_access_o,
    output logic [DCACHE_LANE_SIZE-1:0] mmu_data_o,
    output logic mmu_writeback_o,

    // Bypass logic to decode
    output bypass_data_t bypass_data_o,

    // Hazard signals
    output logic tl_hazard_o,

    //Privilege mode / Virtual mem
    input logic [WORD_SIZE-1:0] csr_priv_i,
    input logic [WORD_SIZE-1:0] csr_satp_i,
    output logic dtlb_exception_o
);

mem_pipeline_t mem_data;
ex_pipeline_t  ex_data;
rvm_pipeline_t rvm_data;

// Bypass signals
logic alu_mem_rf_we;
logic [REG_SIZE-1:0] alu_mem_rf_waddr;
logic tl_rf_we;
logic [REG_SIZE-1:0] tl_rf_waddr;
logic rvm1_we;
logic [REG_SIZE-1:0] rvm1_waddr;
logic rvm2_we;
logic [REG_SIZE-1:0] rvm2_waddr;
logic rvm3_we;
logic [REG_SIZE-1:0] rvm3_waddr;
logic rvm4_we;
logic [REG_SIZE-1:0] rvm4_waddr;

assign ex_data.hazard = 1'b0;

segre_ex_stage ex_stage (
    // Clock and Reset
    .clk_i              (clk_i),
    .rsn_i              (rsn_i),

    // Hazards
    .hazard_i           (ex_data.hazard),

    // Input
    .alu_opcode_i       (ex_data.alu_opcode),
    .alu_src_a_i        (ex_data.alu_src_a),
    .alu_src_b_i        (ex_data.alu_src_b),
    .rf_we_i            (ex_data.rf_we),
    .rf_waddr_i         (ex_data.rf_waddr),
    .br_src_a_i         (ex_data.br_src_a),
    .br_src_b_i         (ex_data.br_src_b),
    .instr_id_i         (ex_data.instr_id),
    .csr_access_i       (ex_data.csr_access),
    .csr_waddr_i        (ex_data.csr_waddr),

    // Output
    .alu_res_o          (rf_data_o.ex_data),
    .rf_we_o            (rf_data_o.ex_we),
    .rf_waddr_o         (rf_data_o.ex_waddr),
    .branch_completed_o (branch_completed_o),
    .tkbr_o             (tkbr_o),
    .new_pc_o           (new_pc_o),
    .instr_id_o         (ex_instr_id_o),
    .csr_access_o       (csr_access_o),
    .csr_waddr_o        (csr_waddr_o),
    .csr_data_o         (csr_data_o)
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
    .instr_id_i            (mem_data.instr_id),
    .store_permission_i    (mem_data.store_permission),

    // Output
    .data_o                (rf_data_o.mem_data),
    .rf_we_o               (rf_data_o.mem_we),
    .rf_waddr_o            (rf_data_o.mem_waddr),
    .instr_id_o            (mem_instr_id_o),
    .mem_wr_done_o         (mem_wr_done_o),
    .mem_wr_done_id_o      (mem_wr_done_id_o),

    // MMU
    .mmu_data_rdy_i        (mmu_data_rdy_i),
    .mmu_addr_i            (mmu_addr_i),
    .mmu_data_i            (mmu_data_i),
    .mmu_lru_index_i       (mmu_lru_index_i),
    .mmu_miss_o            (mmu_miss_o),
    .mmu_addr_o            (mmu_addr_o),
    .mmu_cache_access_o    (mmu_cache_access_o),
    .mmu_data_o            (mmu_data_o),
    .mmu_writeback_o       (mmu_writeback_o),

    // Hazards
    .tl_hazard_o           (tl_hazard_o),

    // Bypass
    .bypass_b_i            (core_pipeline_i.bypass_b),
    .bypass_rvm5_data_i    (rf_data_o.rvm_data),
    .alu_mem_rf_we_o       (alu_mem_rf_we),
    .alu_mem_rf_waddr_o    (alu_mem_rf_waddr),
    .tl_rf_we_o            (tl_rf_we),
    .tl_rf_waddr_o         (tl_rf_waddr),
    .csr_priv_i            (csr_priv_i),
    .csr_satp_i            (csr_satp_i),
    .dtlb_exception_o      (dtlb_exception_o)
);

segre_rvm_pipeline rvm_pipeline (
    // Clock and Reset
    .clk_i (clk_i),
    .rsn_i (rsn_i),

    // Input
    .alu_opcode_i (rvm_data.alu_opcode),
    .alu_src_a_i  (rvm_data.alu_src_a),
    .alu_src_b_i  (rvm_data.alu_src_b),
    .rf_we_i      (rvm_data.rf_we),
    .rf_waddr_i   (rvm_data.rf_waddr),
    .instr_id_i   (rvm_data.instr_id),

    // Output
    .alu_res_o    (rf_data_o.rvm_data),
    .rf_we_o      (rf_data_o.rvm_we),
    .rf_waddr_o   (rf_data_o.rvm_waddr),
    .instr_id_o   (rvm_instr_id_o),

    // Bypass
    .rvm1_we_o    (rvm1_we),
    .rvm1_waddr_o (rvm1_waddr),
    .rvm2_we_o    (rvm2_we),
    .rvm2_waddr_o (rvm2_waddr),
    .rvm3_we_o    (rvm3_we),
    .rvm3_waddr_o (rvm3_waddr),
    .rvm4_we_o    (rvm4_we),
    .rvm4_waddr_o (rvm4_waddr)
    
);

always_comb begin : input_decoder
    // EX PIPELINE
    ex_data.alu_opcode        = core_pipeline_i.alu_opcode;
    ex_data.instr_id          = core_pipeline_i.instr_id;
    ex_data.csr_access        = core_pipeline_i.csr_access;
    ex_data.csr_waddr         = core_pipeline_i.csr_waddr;
    // MEM PIPELINE
    mem_data.memop_sign_ext   = core_pipeline_i.memop_sign_ext;
    mem_data.memop_type       = core_pipeline_i.memop_type;
    mem_data.rf_st_data       = core_pipeline_i.rf_st_data;
    mem_data.instr_id         = core_pipeline_i.instr_id;
    mem_data.store_permission = core_pipeline_i.store_permission;
    // RVM PIPELINE
    rvm_data.alu_opcode       = core_pipeline_i.alu_opcode;
    rvm_data.instr_id         = core_pipeline_i.instr_id;
    
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
    unique case (core_pipeline_i.bypass_a)
        NO_BYPASS: begin
            ex_data.alu_src_a   = core_pipeline_i.alu_src_a;
            ex_data.br_src_a    = core_pipeline_i.br_src_a;
            mem_data.alu_src_a  = core_pipeline_i.alu_src_a;
            rvm_data.alu_src_a  = core_pipeline_i.alu_src_a;
        end
        BY_EX_PIPE: begin
            if (core_pipeline_i.is_branch_jal) ex_data.alu_src_a = core_pipeline_i.alu_src_a;
            else ex_data.alu_src_a = rf_data_o.ex_data;

            ex_data.br_src_a    = rf_data_o.ex_data;
            mem_data.alu_src_a  = rf_data_o.ex_data;
            rvm_data.alu_src_a  = rf_data_o.ex_data;
        end
        BY_MEM_PIPE: begin
            if (core_pipeline_i.is_branch_jal) ex_data.alu_src_a = core_pipeline_i.alu_src_a;
            else ex_data.alu_src_a = rf_data_o.mem_data;

            ex_data.br_src_a    = rf_data_o.mem_data;
            mem_data.alu_src_a  = rf_data_o.mem_data;
            rvm_data.alu_src_a  = rf_data_o.mem_data;
        end
        BY_RVM5_PIPE: begin
            if (core_pipeline_i.is_branch_jal) ex_data.alu_src_a = core_pipeline_i.alu_src_a;
            else ex_data.alu_src_a = rf_data_o.rvm_data;

            ex_data.br_src_a    = rf_data_o.rvm_data;
            mem_data.alu_src_a  = rf_data_o.rvm_data;
            rvm_data.alu_src_a  = rf_data_o.rvm_data;
        end
        default: begin
            ex_data.alu_src_a   = core_pipeline_i.alu_src_a;
            ex_data.br_src_a    = core_pipeline_i.br_src_a;
            mem_data.alu_src_a  = core_pipeline_i.alu_src_a;
            rvm_data.alu_src_a  = core_pipeline_i.alu_src_a;
        end
    endcase

    unique case (core_pipeline_i.bypass_b)
        NO_BYPASS: begin
            ex_data.alu_src_b   = core_pipeline_i.alu_src_b;
            ex_data.br_src_b    = core_pipeline_i.br_src_b;
            mem_data.alu_src_b  = core_pipeline_i.alu_src_b;
            rvm_data.alu_src_b  = core_pipeline_i.alu_src_b;
        end
        BY_EX_PIPE: begin
            if (core_pipeline_i.is_branch_jal) ex_data.alu_src_b = core_pipeline_i.alu_src_b;
            else ex_data.alu_src_b = rf_data_o.ex_data;

            ex_data.br_src_b    = rf_data_o.ex_data;
            mem_data.alu_src_b  = rf_data_o.ex_data;
            rvm_data.alu_src_b  = rf_data_o.ex_data;
        end
        BY_MEM_PIPE: begin
            if (core_pipeline_i.is_branch_jal) ex_data.alu_src_b = core_pipeline_i.alu_src_b;
            else ex_data.alu_src_b = rf_data_o.mem_data;

            ex_data.br_src_b    = rf_data_o.mem_data;
            mem_data.alu_src_b  = rf_data_o.mem_data;
            rvm_data.alu_src_b  = rf_data_o.mem_data;
        end
        BY_RVM5_PIPE: begin
            if (core_pipeline_i.is_branch_jal) ex_data.alu_src_b = core_pipeline_i.alu_src_b;
            else ex_data.alu_src_b = rf_data_o.rvm_data;

            ex_data.br_src_b    = rf_data_o.rvm_data;
            mem_data.alu_src_b  = rf_data_o.rvm_data;
            rvm_data.alu_src_b  = rf_data_o.rvm_data;
        end
        default: begin
            ex_data.alu_src_b   = core_pipeline_i.alu_src_b;
            ex_data.br_src_b    = core_pipeline_i.br_src_b;
            mem_data.alu_src_b  = core_pipeline_i.alu_src_b;
            rvm_data.alu_src_b  = core_pipeline_i.alu_src_b;
        end
    endcase
end

always_comb begin : bypass_output_data
    // EX STAGE
    bypass_data_o.ex_wreg = rf_data_o.ex_we ? rf_data_o.ex_waddr : 0;
    bypass_data_o.ex_data = rf_data_o.ex_we ? rf_data_o.ex_data : 0;
    // ALU MEM
    bypass_data_o.alu_mem_wreg = alu_mem_rf_we ? alu_mem_rf_waddr : 0;
    // TL STAGE
    bypass_data_o.tl_wreg = tl_rf_we ? tl_rf_waddr : 0;
    // MEM STAGE
    bypass_data_o.mem_wreg = rf_data_o.mem_we ? rf_data_o.mem_waddr : 0;
    bypass_data_o.mem_data = rf_data_o.mem_we ? rf_data_o.mem_data : 0;
    // RVM
    bypass_data_o.rvm1_wreg = rvm1_we ? rvm1_waddr : 0;
    bypass_data_o.rvm2_wreg = rvm2_we ? rvm2_waddr : 0;
    bypass_data_o.rvm3_wreg = rvm3_we ? rvm3_waddr : 0;
    bypass_data_o.rvm4_wreg = rvm4_we ? rvm4_waddr : 0;
    bypass_data_o.rvm5_wreg = rf_data_o.rvm_we ? rf_data_o.rvm_waddr : 0;
    bypass_data_o.rvm5_data = rf_data_o.rvm_we ? rf_data_o.rvm_data : 0;
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