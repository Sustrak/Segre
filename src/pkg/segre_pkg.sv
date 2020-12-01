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

typedef enum logic [2:0] {
    IF_STATE = 0,
    ID_STATE,
    EX_STATE,
    TL_STATE,
    MEM_STATE,
    WB_STATE
} core_fsm_state_e;

typedef enum logic [1:0] {
    BYTE,
    HALF,
    WORD
} memop_data_type_e;

typedef enum logic [2:0] {
    DCACHE_REQ,
    DCACHE_WAIT,
    ICACHE_REQ,
    ICACHE_WAIT,
    MMU_IDLE
} mmu_fsm_state_e;

typedef enum logic [1:0] {
    HAZARD_DC_MISS,
    HAZARD_SB_TROUBLE,
    TL_IDLE
} tl_fsm_state_e;

typedef enum logic {
    IF_IC_MISS,
    IF_IDLE
} if_fsm_state_e;

/********************
* SEGRE  DATATYPES  *
********************/
typedef struct packed {
    logic req;
    logic mmu_data;
    logic [DCACHE_INDEX_SIZE-1:0] index;
    logic [DCACHE_TAG_SIZE-1:0] tag;
    logic invalidate;
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
    memop_data_type_e memop_data_type;
    logic [WORD_SIZE-1:0] data_i;
    logic [DCACHE_INDEX_SIZE-1:0] index;
    logic [DCACHE_BYTE_SIZE-1:0] byte_i;
    logic [DCACHE_LANE_SIZE-1:0] mmu_data;
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
    logic full;
    logic data_valid;
    logic trouble;
    memop_data_type_e memop_data_type_o;
    logic [WORD_SIZE-1:0] data_o;
    logic [ADDR_SIZE-1:0] addr_o;
} store_buffer_t;

typedef struct packed {
    logic [WORD_SIZE-1:0] addr;
    logic mem_rd;
    logic [WORD_SIZE-1:0] new_pc;
    logic tkbr;
} core_if_t;

typedef struct packed {
    logic [WORD_SIZE-1:0] instr;
    logic [ADDR_SIZE-1:0] pc;
} core_id_t;

typedef struct packed {
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
} core_ex_t;

typedef struct packed {
    logic [WORD_SIZE-1:0] alu_res;
    logic rf_we;
    logic [REG_SIZE-1:0] rf_waddr;
    logic [WORD_SIZE-1:0] rf_st_data;
    logic memop_rd;
    logic memop_wr;
    logic memop_sign_ext;
    memop_data_type_e memop_type;
    logic tkbr;
    logic [WORD_SIZE-1:0] new_pc;
    logic sb_hit;
    logic [WORD_SIZE-1:0] sb_data;
    logic [DCACHE_INDEX_SIZE-1:0] addr_index;
} core_tl_t;

typedef struct packed {
    memop_data_type_e memop_type;
    memop_data_type_e data_type;
    logic [WORD_SIZE-1:0] alu_res;
    logic [WORD_SIZE-1:0] addr;
    logic [WORD_SIZE-1:0] wr_data;
    logic [WORD_SIZE-1:0] rf_st_data;
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
    logic [WORD_SIZE-1:0] sb_data;
    logic [ADDR_SIZE-1:0] sb_addr;
    //logic [DCACHE_INDEX_SIZE-1:0] addr_index;
} core_mem_t;

typedef struct packed {
    logic [REG_SIZE-1:0] raddr_a;
    logic [REG_SIZE-1:0] raddr_b;
    logic [REG_SIZE-1:0] waddr_w;
    logic [WORD_SIZE-1:0] data_a;
    logic [WORD_SIZE-1:0] data_b;
    logic [WORD_SIZE-1:0] data_w;
    logic we;
} core_rf_t;

typedef struct packed {
    logic dc_miss;
    logic [ADDR_SIZE-1:0] dc_addr_i;
    logic dc_store;
    memop_data_type_e dc_store_data_type_i;
    logic [WORD_SIZE-1:0] dc_data_i;
    logic dc_access;
    logic dc_mmu_data_rdy;
    logic [DCACHE_LANE_SIZE-1:0] dc_data_o;
    logic [DCACHE_INDEX_SIZE-1:0] dc_lru_index;
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
    logic ex;
    logic tl;
    logic mem;
} core_hazards_t;

typedef struct packed {
    logic ifs;
    logic id;
    logic ex;
    logic tl;
    logic mem;
} core_stage_hazards_t;

endpackage : segre_pkg