`ifndef COMMON_TYPES_VH
`define COMMON_TYPES_VH

// Common types package
package common_types_pkg;

    /*********/
    /* Sizes */
    /*********/
    
    parameter WORD_W = 32;
    parameter OP_W = 7;
    parameter FUNCT3_W = 3;
    parameter FUNCT7_W = 7;
    parameter REG_W = 5;
    parameter IMM_W_I = 12;
    parameter IMM_W_U_J = 20;

    /*********/
    /* Types */
    /*********/

    // Word
    typedef logic [WORD_W-1:0] word_t;
    
    // Opcode
    typedef logic [OP_W-1:0] op_t;
    
    // Funct3
    typedef logic [FUNCT3_W-1:0] funct3_t;
    
    // Funct7
    typedef logic [FUNCT7_W-1:0] funct7_t;
    
    // Register number
    typedef logic [REG_W-1:0] reg_t;

    // ALU operation
    typedef enum logic [3:0] {
        ALU_SLL,
        ALU_SRL,
        ALU_SRA,
        ALU_ADD,
        ALU_SUB,
        ALU_AND,
        ALU_OR,
        ALU_XOR,
        ALU_SLT,
        ALU_SLTU
    } alu_op_t;

    typedef enum logic [OP_W-1:0] {
        RTYPE     = 7'b0110011,
        ITYPE     = 7'b0010011,
        ITYPE_LW  = 7'b0000011,
        JALR      = 7'b1100111,
        STYPE     = 7'b0100011,
        BTYPE     = 7'b1100011,
        JAL       = 7'b1101111,
        LUI       = 7'b0110111,
        AUIPC     = 7'b0010111,
        LR_SC     = 7'b0101111,
        ENV       = 7'b1110011
    } opcode_t;
  
    typedef enum logic [FUNCT3_W-1:0] {
        SLL_MULH    = 3'h1,
        SRL_SRA     = 3'h5,
        ADD_SUB_MUL = 3'h0,
        AND         = 3'h7,
        OR          = 3'h6,
        XOR         = 3'h4,
        SLT_MULHSU  = 3'h2,
        SLTU_MULHU  = 3'h3
    } funct3_r_t;

    typedef enum logic [FUNCT3_W-1:0] {
        ADDI    = 3'h0,
        XORI    = 3'h4,
        ORI     = 3'h6,
        ANDI    = 3'h7,
        SLLI    = 3'h1,
        SRLI_SRAI = 3'h5,
        SLTI    = 3'h2,
        SLTIU   = 3'h3
    } funct3_i_t;

    typedef enum logic [FUNCT3_W-1:0] {
        LB      = 3'h0,
        LH      = 3'h1,
        LW      = 3'h2,
        LBU     = 3'h4,
        LHU     = 3'h5
    } funct3_ld_i_t;

    typedef enum logic [FUNCT3_W-1:0] {
        ENV_CALL_BREAK  = 3'h0
    } funct3_env_i_t;

    typedef enum logic [FUNCT3_W-1:0] {
        SB      = 3'h0,
        SH      = 3'h1,
        SW      = 3'h2
    } funct3_s_t;

    typedef enum logic [FUNCT3_W-1:0] {
        BEQ     = 3'h0,
        BNE     = 3'h1,
        BLT     = 3'h4,
        BGE     = 3'h5,
        BLTU    = 3'h6,
        BGEU    = 3'h7
    } funct3_b_t;

    typedef enum logic [FUNCT7_W-1:0] {
        ADD     = 7'h00,
        SUB     = 7'h20,
        MULT    = 7'h01
    } funct7_r_t;

    typedef enum logic [FUNCT7_W-1:0] {
        SRA     = 7'h20,
        SRL     = 7'h00
    } funct7_srla_r_t;

    typedef enum logic [IMM_W_I-1:0] {
        ECALL   = 7'h0,
        EBREAK  = 7'h1
    } imm_env_i_t;

    // uj type
    typedef struct packed {
        logic [IMM_W_U_J-1:0]   imm;
        reg_t                   rd;
        op_t                    opcode;
    } j_t;

    // u type
    typedef struct packed {
        logic [IMM_W_U_J-1:0]   imm;
        reg_t                   rd;
        op_t                    opcode;
    } u_t;

    // sb type
    typedef struct packed {
        logic [7-1:0]           imm2;
        reg_t                   rs2;
        reg_t                   rs1;
        funct3_b_t              funct3;
        logic [5-1:0]           imm1;
        op_t                    opcode;
    } b_t;

    // s type
    typedef struct packed {
        logic [7-1:0]           imm2;
        reg_t                   rs2;
        reg_t                   rs1;
        funct3_s_t              funct3;
        logic [5-1:0]           imm1;
        op_t                    opcode;
    } s_t;

    // i type
    typedef struct packed {
        logic [IMM_W_I-1:0]     imm;
        reg_t                   rs1;
        funct3_i_t              funct3;
        reg_t                   rd;
        op_t                    opcode;
    } i_t;

    // r type
    typedef struct packed {
        funct7_r_t              funct7;
        reg_t                   rs2;
        reg_t                   rs1;
        funct3_r_t              funct3;
        reg_t                   rd;
        op_t                    opcode;
    } r_t;

    // RAM state
    typedef enum logic [1:0] {
        RAM_IDLE,
        RAM_WAIT,
        RAM_DONE
    } ram_state_t;

endpackage

`endif // COMMON_TYPES_VH
