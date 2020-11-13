import segre_pkg::*;

module cache_subsystem_tb;
    logic clk;
    logic rsn;

    always #10 clk = ~clk;

    struct {
        // Data chache
        logic dc_miss_i;
        logic [ADDR_SIZE-1:0] dc_addr_i;
        logic dc_store_i;
        logic [DCACHE_LANE_SIZE-1:0] dc_data_i;
        logic dc_access_i;
        logic dc_mmu_data_rdy_o;
        logic [DCACHE_LANE_SIZE-1:0] dc_data_o;
        logic [ADDR_SIZE-1:0] dc_addr_o;
        logic [DCACHE_INDEX_SIZE-1:0] dc_lru_index_o;
        // Instruction cache
        logic ic_miss_i;
        logic [ADDR_SIZE-1:0] ic_addr_i;
        logic ic_mmu_data_rdy_o;
        logic [ICACHE_LANE_SIZE-1:0] ic_data_o;
        logic ic_access_i;
        logic [ADDR_SIZE-1:0] ic_addr_o;
        logic [ICACHE_INDEX_SIZE-1:0] ic_lru_index_o;
        // Main memory
        logic mm_data_rdy_i;
        logic [DCACHE_LANE_SIZE-1:0] mm_data_i; // If $D and $I have different LANE_SIZE we need to change this
        logic mm_rd_req_o;
        logic mm_wr_req_o;
        logic [ADDR_SIZE-1:0] mm_addr_o;
        logic [DCACHE_LANE_SIZE-1:0] mm_data_o;
    } mmu_if;

    struct {
      logic rd_data_i;
      logic wr_data_i;
      logic mem_wr_data_i;
      logic [WORD_SIZE-1:0] addr_i;
      memop_data_type_e memop_data_type_i;
      logic [WORD_SIZE-1:0] data_i;
      logic [DCACHE_LANE_SIZE-1:0] mem_data_i;
      logic [WORD_SIZE-1:0] data_o;
    } dc_data;
    
    struct {
      logic req_i;
      logic mmu_data_i;
      logic [WORD_SIZE-1:0] addr_i;
      logic [DCACHE_INDEX_SIZE-1:0] lru_index_i;
      logic invalidate_i;
      logic hit_o;
      logic miss_o;
    } dc_tag;

/*
    struct {
    } ic_data;
    
    struct {
    } ic_tag;
*/

    segre_mmu mmu (
        .clk_i             (clk),
        .rsn_i             (rsn),
        .dc_miss_i         (mmu_if.dc_miss_i),
        .dc_addr_i         (mmu_if.dc_addr_i),
        .dc_store_i        (mmu_if.dc_store_i),
        .dc_data_i         (mmu_if.dc_data_i),
        .dc_access_i       (mmu_if.dc_access_i),
        .dc_mmu_data_rdy_o (mmu_if.dc_mmu_data_rdy_o),
        .dc_data_o         (mmu_if.dc_data_o),
        .dc_addr_o         (mmu_if.dc_addr_o),
        .dc_lru_index_o    (mmu_if.dc_lru_index_o),
        .ic_miss_i         (mmu_if.ic_miss_i),
        .ic_addr_i         (mmu_if.ic_addr_i),
        .ic_access_i       (mmu_if.ic_access_i),
        .ic_mmu_data_rdy_o (mmu_if.ic_mmu_data_rdy_o),
        .ic_data_o         (mmu_if.ic_data_o),
        .ic_addr_o         (mmu_if.ic_addr_o),
        .ic_lru_index_o    (mmu_if.ic_lru_index_o),
        .mm_data_rdy_i     (mmu_if.mm_data_rdy_i),
        .mm_data_i         (mmu_if.mm_data_i),
        .mm_rd_req_o       (mmu_if.mm_rd_req_o),
        .mm_wr_req_o       (mmu_if.mm_wr_req_o),
        .mm_addr_o         (mmu_if.mm_addr_o),
        .mm_data_o         (mmu_if.mm_data_o)
    );

    segre_dcache_data dcache_data (
        .clk_i             (clk),
        .rsn_i             (rsn),
        .rd_data_i         (dc_data.rd_data_i),
        .wr_data_i         (dc_data.wr_data_i),
        .mem_wr_data_i     (dc_data.mem_wr_data_i),
        .addr_i            (dc_data.addr_i),
        .memop_data_type_i (dc_data.memop_data_type_i),
        .data_i            (dc_data.data_i),
        .mem_data_i        (dc_data.mem_data_i),
        .data_o            (dc_data.data_o)
    );

    segre_dcache_tag dcache_tag (
        .clk_i        (clk),
        .rsn_i        (rsn),
        .req_i        (dc_tag.req_i),
        .mmu_data_i   (dc_tag.mmu_data_i),
        .addr_i       (dc_tag.addr_i),
        .lru_index_i  (dc_tag.lru_index_i),
        .invalidate_i (dc_tag.invalidate_i),
        .hit_o        (dc_tag.hit_o),
        .miss_o       (dc_tag.miss_o) 
    );

    task test_cache_data;
        cd_fill_lane(0);
        cd_fill_lane(1);
        cd_fill_lane(2);
        cd_fill_lane(3);
        cd_read_item(.index(0), .cbyte(0));
        cd_read_item(.index(1), .cbyte(4));
        cd_read_item(.index(1), .cbyte(8));
        cd_read_item(.index(1), .cbyte(12));
        cd_read_item(.index(2), .cbyte(0));
        cd_write_item(.index(2), .cbyte(8), .access(WORD));
        cd_write_item(.index(2), .cbyte(14), .access(HALF));
        cd_write_item(.index(2), .cbyte(7), .access(BYTE));
    endtask : test_cache_data
    
    task dc_data_set_initial_values;
        dc_data.mem_wr_data_i <= 0;
        dc_data.wr_data_i <= 0; 
        dc_data.rd_data_i <= 0;
        dc_data.addr_i <= 0;
        dc_data.memop_data_type_i <= WORD;
        dc_data.data_i <= 0;
        dc_data.mem_data_i <= 0;
    endtask : dc_data_set_initial_values

    task cd_fill_lane(logic [DCACHE_INDEX_SIZE-1:0] index);
        @(posedge clk);
        dc_data.mem_wr_data_i <= 1;
        dc_data.mem_data_i <= 128'hff_ee_dd_cc_bb_aa_99_88_77_66_55_44_33_22_11_00;
        dc_data.addr_i <= {{DCACHE_TAG_SIZE{1'b0}}, index, {DCACHE_BYTE_SIZE{1'b0}}};
        @(posedge clk);
        dc_data.mem_wr_data_i <= 0;
        dc_data.mem_data_i <= 0;
        dc_data.addr_i <= 0;
        @(posedge clk);
    endtask : cd_fill_lane

    task cd_read_item(logic [DCACHE_INDEX_SIZE-1:0] index, logic [DCACHE_BYTE_SIZE-1:0] cbyte);
        @(posedge clk);
        dc_data.rd_data_i <= 1;
        dc_data.addr_i <= {{DCACHE_TAG_SIZE{1'b0}}, index, cbyte};
        @(posedge clk);
        dc_data.rd_data_i <= 0;
        dc_data.addr_i <= 0;
        @(posedge clk);
    endtask : cd_read_item

    task cd_write_item(logic [DCACHE_INDEX_SIZE-1:0] index,
                       logic [DCACHE_BYTE_SIZE-1:0] cbyte,
                       memop_data_type_e access);
        @(posedge clk);
        dc_data.wr_data_i <= 1;
        dc_data.addr_i <= {{DCACHE_TAG_SIZE{1'b0}}, index, cbyte};
        dc_data.data_i <= 32'hcafe_cafe;
        dc_data.memop_data_type_i <= access;
        @(posedge clk);
        dc_data.wr_data_i <= 0;
        dc_data.addr_i <= 0;
        dc_data.data_i <= 0;
        @(posedge clk);
    endtask : cd_write_item

    task test_cache_tag;
        ct_read_item(.index(0));
        ct_fill_lane(0);
        ct_read_item(.index(0));
        ct_read_item(.index(0), .different_tag(1));
        ct_fill_lane(1);
        ct_fill_lane(2);
        ct_fill_lane(3);
        ct_invalidate;
        ct_read_item(.index(0));
    endtask : test_cache_tag

    task dc_tag_set_initial_values;
        dc_tag.req_i <= 0;
        dc_tag.invalidate_i <= 0;
        dc_tag.mmu_data_i <= 0;
        dc_tag.addr_i <= 0;
        dc_tag.lru_index_i <= 0;
    endtask : dc_tag_set_initial_values

    task ct_read_item(bit different_tag=0, logic [ICACHE_INDEX_SIZE-1:0] index);
        @(posedge clk);
        dc_tag.req_i <= 1;
        if (different_tag)
            dc_tag.addr_i <= {{ICACHE_TAG_SIZE{1'b0}}, index, {ICACHE_BYTE_SIZE{1'b0}}};
        else
            dc_tag.addr_i <= {{ICACHE_TAG_SIZE{1'b1}}, index, {ICACHE_BYTE_SIZE{1'b0}}};
        @(posedge clk);
        dc_tag.req_i <= 0;
        dc_tag.addr_i <= 0;
        @(posedge clk);
    endtask : ct_read_item

    task ct_fill_lane(logic [ICACHE_INDEX_SIZE-1:0] index);
        @(posedge clk);
        dc_tag.mmu_data_i <= 1;
        dc_tag.addr_i <= {{ICACHE_TAG_SIZE{1'b1}}, {ICACHE_INDEX_SIZE{1'b0}}, {ICACHE_BYTE_SIZE{1'b0}}};
        dc_tag.lru_index_i <= index; 
        @(posedge clk);
        dc_tag.mmu_data_i <= 0;
        dc_tag.addr_i <= 0;
        dc_tag.lru_index_i <= 0;
        @(posedge clk);
    endtask : ct_fill_lane

    task ct_invalidate;
        @(posedge clk);
        dc_tag.invalidate_i <= 1;
        @(posedge clk);
        dc_tag.invalidate_i <= 0;
        @(posedge clk);
    endtask : ct_invalidate

    task test_mmu;
    endtask : test_mmu
    
    initial begin
        clk = 0;
        rsn = 0;
        repeat(4) @(posedge clk);
        rsn = 1;
        dc_data_set_initial_values;
        @(posedge clk);
        $display("Starting test_cache_data");
        test_cache_data;
        $display("End test_cache_data");
        $display("Starting test_cace_tag");
        test_cache_tag;
        $display("End test_cache_tag");
        $finish;
    end

endmodule : cache_subsystem_tb
