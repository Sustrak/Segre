package segre_pkg;

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
    MEM_STATE,
    WB_STATE
} fsm_state_e;

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
    IDLE
} mmu_fsm_state_e;

/********************
* RISC-V PARAMETERS *
********************/

parameter WORD_SIZE = 32;
parameter ADDR_SIZE = 32;
parameter REG_SIZE  = 5;

/********************
* SEGRE  PARAMETERS *
********************/
/** DATA CACHE **/
parameter DCACHE_NUM_LANES = 4;
parameter DCACHE_BYTES_PER_LANE = 16;
parameter DCACHE_LANE_SIZE = DCACHE_BYTES_PER_LANE * 8;
parameter DCACHE_BYTE_SIZE = $clog2(DCACHE_BYTES_PER_LANE);
parameter DCACHE_INDEX_SIZE = $clog2(DCACHE_NUM_LANES);
parameter DCACHE_TAG_SIZE = ADDR_SIZE - DCACHE_BYTE_SIZE - DCACHE_INDEX_SIZE;

/** INSTRUCTIONS CACHE **/
parameter ICACHE_NUM_LANES = 4;
parameter ICACHE_BYTES_PER_LANE = 16;
parameter ICACHE_LANE_SIZE = ICACHE_BYTES_PER_LANE * 8;
parameter ICACHE_BYTE_SIZE = $clog2(ICACHE_BYTES_PER_LANE);
parameter ICACHE_INDEX_SIZE = $clog2(ICACHE_NUM_LANES);
parameter ICACHE_TAG_SIZE = ADDR_SIZE - ICACHE_BYTE_SIZE - ICACHE_INDEX_SIZE;

endpackage : segre_pkg
