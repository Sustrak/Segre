package segre_pkg;

/********************
* RISC-V PARAMETERS *
********************/

parameter WORD_SIZE = 32;
parameter ADDR_SIZE = 32;
parameter REG_SIZE  = 5;
parameter NOP = 32'h00000013;

/********************
* SEGRE  PARAMETERS *
********************/
/** DATA CACHE **/
parameter DCACHE_NUM_LANES = 4;
parameter DCACHE_BYTES_PER_LANE = 16;
parameter DCACHE_LANE_SIZE = DCACHE_BYTES_PER_LANE * 8;
parameter DCACHE_BYTE_SIZE = $clog2(DCACHE_BYTES_PER_LANE);
parameter DCACHE_INDEX_SIZE = $clog2(DCACHE_NUM_LANES);
parameter DCACHE_TAG_SIZE = ADDR_SIZE - DCACHE_BYTE_SIZE;

/** INSTRUCTIONS CACHE **/
parameter ICACHE_NUM_LANES = 4;
parameter ICACHE_BYTES_PER_LANE = 16;
parameter ICACHE_LANE_SIZE = ICACHE_BYTES_PER_LANE * 8;
parameter ICACHE_BYTE_SIZE = $clog2(ICACHE_BYTES_PER_LANE);
parameter ICACHE_INDEX_SIZE = $clog2(ICACHE_NUM_LANES);
parameter ICACHE_TAG_SIZE = ADDR_SIZE - ICACHE_BYTE_SIZE;

/** STORE BUFFER **/
parameter STORE_BUFFER_NUM_ELEMS = 2;

/** RVM **/
parameter RVM_NUM_STAGES = 5;

/** TLB **/
parameter VADDR_SIZE = ADDR_SIZE-12; //Should be 20
parameter PADDR_SIZE = VADDR_SIZE-12; //Should be 8
parameter TLB_NUM_ENTRYS = 4;

/** HISTORY FILE **/
parameter HF_SIZE = 8;
parameter HF_PTR  = $clog2(HF_SIZE);

/*****************
*    OPCODES     *
*****************/
typedef enum logic [6:0] {
  OPCODE_LOAD     = 7'h03,
  OPCODE_MISC_MEM = 7'h0f,
  OPCODE_OP_IMM   = 7'h13,
  OPCODE_AUIPC    = 7'h17,
  OPCODE_STORE    = 7'h23,
  OPCODE_OP       = 7'h33,
  OPCODE_LUI      = 7'h37,
  OPCODE_BRANCH   = 7'h63,
  OPCODE_JALR     = 7'h67,
  OPCODE_JAL      = 7'h6f,
  OPCODE_SYSTEM   = 7'h73
} opcode_e;

typedef enum logic [5:0] {
    ALU_ADD,
    ALU_SUB,
    ALU_SLL,
    ALU_SLT,
    ALU_SLTU,
    ALU_XOR,
    ALU_SRL,
    ALU_SRA,
    ALU_OR,
    ALU_AND,
    ALU_JAL,
    ALU_JALR,
    ALU_BEQ,
    ALU_BNE,
    ALU_BLT,
    ALU_BGE,
    ALU_BLTU,
    ALU_BGEU,
    ALU_AUIPC,
    ALU_MUL,
    ALU_MULH,
    ALU_MULHU,
    ALU_MULHSU,
    ALU_DIV,
    ALU_DIVU,
    ALU_REM,
    ALU_REMU
} alu_opcode_e;

/*****************
* ALU PARAMETERS *
*****************/
typedef enum logic[1:0] {
    ALU_A_REG,
    ALU_A_IMM,
    ALU_A_PC
} alu_src_a_e;

typedef enum logic[1:0] {
    ALU_B_REG,
    ALU_B_IMM
} alu_src_b_e;

typedef enum logic {
    BR_A_REG,
    BR_A_PC
} br_src_a_e;

typedef enum logic {
    BR_B_REG
} br_src_b_e;

typedef enum logic[2:0] {
    IMM_B_I,
    IMM_B_U,
    IMM_B_J,
    IMM_B_B,
    IMM_B_S
} alu_imm_b_e;

typedef enum logic {
    IMM_A_ZERO
} alu_imm_a_e;

typedef enum logic [1:0] {
    BYTE,
    HALF,
    WORD
} memop_data_type_e;

typedef enum logic [1:0] {
    R, //READ
    W, //WRITE
    RW, //READWRITE
    EX //EXECUTION
} page_protection_e;

typedef enum logic [2:0] {
    DCACHE_REQ,
    DCACHE_WAIT,
    DCACHE_PENDING,
    ICACHE_REQ,
    ICACHE_WAIT,
    MMU_IDLE
} mmu_fsm_state_e;

typedef enum logic [1:0] {
    HAZARD_DC_MISS,
    HAZARD_SB_TROUBLE,
    MISS_IN_FLIGHT,
    TL_IDLE
} tl_fsm_state_e;

typedef enum logic [1:0] {
    IF_IDLE,
    IF_IC_MISS,
    IF_BRANCH
} if_fsm_state_e;

typedef enum logic [1:0] {
   EX_PIPELINE,
   MEM_PIPELINE,
   RVM_PIPELINE
} pipeline_e;

typedef enum logic [3:0] { 
    NO_BYPASS,
    BY_EX_ID,
    BY_MEM_ID,
    BY_RVM5_ID,
    BY_EX_PIPE,
    BY_MEM_PIPE,
    BY_RVM5_PIPE,
    BY_MEM_TL,
    BY_RVM5_TL
} bypass_e;

/********************
* SEGRE  DATATYPES  *
********************/
typedef struct packed {
    logic [REG_SIZE-1:0]  ex_wreg;
    logic [WORD_SIZE-1:0] ex_data;
    logic [REG_SIZE-1:0]  alu_mem_wreg;
    logic [REG_SIZE-1:0]  tl_wreg;
    logic [REG_SIZE-1:0]  mem_wreg;
    logic [WORD_SIZE-1:0] mem_data;
    logic [REG_SIZE-1:0]  rvm1_wreg;
    logic [REG_SIZE-1:0]  rvm2_wreg;
    logic [REG_SIZE-1:0]  rvm3_wreg;
    logic [REG_SIZE-1:0]  rvm4_wreg;
    logic [REG_SIZE-1:0]  rvm5_wreg;
    logic [WORD_SIZE-1:0] rvm5_data;
} bypass_data_t;

typedef struct packed {
    logic invalidate; 
    logic req;
    logic new_entry;
    page_protection_e access_type;
    logic [VADDR_SIZE-1:0] virtual_addr;
    logic [PADDR_SIZE-1:0] physical_addr_i;
    logic pp_exception;
    logic hit;
    logic miss;
    logic [PADDR_SIZE-1:0] physical_addr_o;
} tlb_st_t;

typedef struct packed {
    logic req;
    logic mmu_data;
    logic [DCACHE_INDEX_SIZE-1:0] index;
    logic [DCACHE_TAG_SIZE-1:0] tag;
    logic invalidate;
    logic [ADDR_SIZE-1:0] addr;
    logic [DCACHE_INDEX_SIZE-1:0] addr_index;
    logic hit;
    logic miss;
} dcache_tag_t;

typedef struct packed {
    logic req;
    logic mmu_data;
    logic [ICACHE_INDEX_SIZE-1:0] index;
    logic [ICACHE_TAG_SIZE-1:0] tag;
    logic invalidate;
    logic [ICACHE_INDEX_SIZE-1:0] addr_index;
    logic hit;
    logic miss;
} icache_tag_t;

typedef struct packed {
    logic rd_data;
    logic wr_data;
    logic mmu_wr_data;
    memop_data_type_e memop_data_load_type;
    memop_data_type_e memop_data_store_type;
    logic [WORD_SIZE-1:0] data_i;
    logic [DCACHE_INDEX_SIZE-1:0] index;
    logic [DCACHE_BYTE_SIZE-1:0] byte_i;
    logic [DCACHE_LANE_SIZE-1:0] mmu_data_i;
    logic mmu_writeback;
    logic [DCACHE_LANE_SIZE-1:0] mmu_data_o;
    logic [WORD_SIZE-1:0] data_o;
    memop_data_type_e store_data_type_o;
} dcache_data_t;

typedef struct packed {
    logic rd_data;
    logic mmu_data;
    logic [ICACHE_INDEX_SIZE-1:0] index;
    logic [ICACHE_BYTE_SIZE-1:0] byte_i;
    logic [ICACHE_LANE_SIZE-1:0] mmu_wr_data;
    logic [WORD_SIZE-1:0] data_o;
} icache_data_t;

typedef struct packed {
    logic req_store;
    logic req_load;
    logic flush_chance;
    logic [ADDR_SIZE-1:0] addr_i;
    logic [WORD_SIZE-1:0] data_i;
    memop_data_type_e memop_data_type_i;
    logic hit;
    logic miss;
    //logic full;
    logic data_valid;
    logic trouble;
    memop_data_type_e memop_data_type_o;
    logic [WORD_SIZE-1:0] data_load_o;
    logic [WORD_SIZE-1:0] data_flush_o;
    logic [ADDR_SIZE-1:0] addr_o;
    logic [HF_PTR-1:0] instr_id;
    logic buffer_merge;
} store_buffer_t;

typedef struct packed {
    logic [WORD_SIZE-1:0] addr;
    logic mem_rd;
    logic [WORD_SIZE-1:0] new_pc;
    logic tkbr;
    logic branch_completed;
} core_if_t;

typedef struct packed {
    logic [WORD_SIZE-1:0] instr;
    logic [ADDR_SIZE-1:0] pc;
    bypass_data_t bypass_data;
} core_id_t;

typedef struct packed {
    pipeline_e pipeline;
    memop_data_type_e memop_type;
    logic [WORD_SIZE-1:0] alu_src_a;
    logic [WORD_SIZE-1:0] alu_src_b;
    logic [WORD_SIZE-1:0] rf_st_data;
    logic rf_we;
    logic [REG_SIZE-1:0] rf_waddr;
    alu_opcode_e alu_opcode;
    logic memop_rd;
    logic memop_wr;
    logic memop_sign_ext;
    logic [WORD_SIZE-1:0] br_src_a;
    logic [WORD_SIZE-1:0] br_src_b;
    bypass_e bypass_a;
    bypass_e bypass_b;
    logic [HF_PTR-1:0] instr_id;
    logic store_permission;
} core_pipeline_t;

typedef struct packed {
    logic [WORD_SIZE-1:0] alu_src_a;
    logic [WORD_SIZE-1:0] alu_src_b;
    logic rf_we;
    logic [REG_SIZE-1:0] rf_waddr;
    logic [WORD_SIZE-1:0] rf_st_data;
    logic memop_rd;
    logic memop_wr;
    logic memop_sign_ext;
    memop_data_type_e memop_type;
    logic [WORD_SIZE-1:0] data;
    logic rf_we_o;
    logic [REG_SIZE-1:0] rf_waddr_o;
    logic [HF_PTR-1:0] instr_id;
    logic store_permission;
} mem_pipeline_t;

typedef struct packed {
    logic hazard;
    alu_opcode_e alu_opcode;
    logic [WORD_SIZE-1:0] alu_src_a;
    logic [WORD_SIZE-1:0] alu_src_b;
    logic rf_we;
    logic [REG_SIZE-1:0] rf_waddr;
    logic [WORD_SIZE-1:0] br_src_a;
    logic [WORD_SIZE-1:0] br_src_b;
    logic [HF_PTR-1:0] instr_id;
} ex_pipeline_t;

typedef struct packed {
    alu_opcode_e alu_opcode;
    logic [WORD_SIZE-1:0] alu_src_a;
    logic [WORD_SIZE-1:0] alu_src_b;
    logic rf_we;
    logic [REG_SIZE-1:0]  rf_waddr;
    logic [HF_PTR-1:0] instr_id;
} rvm_pipeline_t;

typedef struct packed {
    logic [WORD_SIZE-1:0] addr;
    logic rf_we;
    logic [REG_SIZE-1:0] rf_waddr;
    logic [WORD_SIZE-1:0] rf_st_data;
    logic memop_rd;
    logic memop_wr;
    logic memop_sign_ext;
    memop_data_type_e memop_type;
    bypass_e bypass_b;
    logic [HF_PTR-1:0] instr_id;
} tl_stage_t;

typedef struct packed {
    memop_data_type_e memop_type;
    memop_data_type_e memop_type_flush;
    memop_data_type_e data_type;
    logic [WORD_SIZE-1:0] addr;
    logic [WORD_SIZE-1:0] wr_data;
    logic [REG_SIZE-1:0]  rf_waddr;
    logic memop_rd;
    logic memop_wr;
    logic memop_sign_ext;
    logic rf_we;
    logic rd;
    logic wr;
    logic tkbr;
    logic [WORD_SIZE-1:0] new_pc;
    logic sb_hit;
    logic sb_flush;
    logic [WORD_SIZE-1:0] sb_data_load;
    logic [WORD_SIZE-1:0] sb_data_flush;
    logic [ADDR_SIZE-1:0] sb_addr;
    logic [DCACHE_INDEX_SIZE-1:0] addr_index;
    logic [HF_PTR-1:0] instr_id;
} mem_stage_t;

typedef struct packed {
    logic [REG_SIZE-1:0] raddr_a;
    logic [REG_SIZE-1:0] raddr_b;
    logic [WORD_SIZE-1:0] data_a;
    logic [WORD_SIZE-1:0] data_b;
} decode_rf_t;

typedef struct packed {
    logic dc_miss;
    logic [ADDR_SIZE-1:0] dc_addr_i;
    logic dc_mmu_writeback;
    logic dc_access;
    logic dc_mmu_data_rdy;
    logic [DCACHE_LANE_SIZE-1:0] dc_data_o;
    logic [DCACHE_LANE_SIZE-1:0] dc_data_i;
    logic [DCACHE_INDEX_SIZE-1:0] dc_lru_index;
    logic [ADDR_SIZE-1:0] dc_mm_addr_o;
    logic ic_miss;
    logic [ADDR_SIZE-1:0] ic_addr_i;
    logic ic_access;
    logic ic_mmu_data_rdy;
    logic [ICACHE_LANE_SIZE-1:0] ic_data;
    logic [ICACHE_INDEX_SIZE-1:0] ic_lru_index;
} core_mmu_t;

typedef struct packed {
    logic ifs;
    logic id;
    logic pipeline;
} core_hazards_t;

typedef struct packed {
    logic ex_we;
    logic [REG_SIZE-1:0] ex_waddr;
    logic [WORD_SIZE-1:0] ex_data;
    logic mem_we;
    logic [REG_SIZE-1:0] mem_waddr;
    logic [WORD_SIZE-1:0] mem_data;
    logic rvm_we;
    logic [REG_SIZE-1:0] rvm_waddr;
    logic [WORD_SIZE-1:0] rvm_data;
} rf_wdata_t;

typedef struct packed {
    logic new_hf_entry;
    logic [WORD_SIZE-1:0] rf_data;
    logic ex_complete;
    logic [HF_PTR-1:0] ex_complete_id;
    logic mem_complete;
    logic [HF_PTR-1:0] mem_complete_id;
    logic rvm_complete;
    logic [HF_PTR-1:0] rvm_complete_id;
    logic full;
    logic empty;
    logic recovering;
    logic [REG_SIZE-1:0] dest_reg;
    logic [WORD_SIZE-1:0] value;
} core_hf_t;

endpackage : segre_pkg