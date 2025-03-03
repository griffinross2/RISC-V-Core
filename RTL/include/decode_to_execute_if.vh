/*
  Control Unit interface
*/
`ifndef DECODE_TO_EXECUTE_IF_VH
`define DECODE_TO_EXECUTE_IF_VH

`include "common_types.vh"
import common_types_pkg::*;

interface decode_to_execute_if;

  // Enable/Flush
  logic en;
  logic flush;

  // Latched stuff

  /*******************/
  /* Program Counter */
  /*******************/
  word_t pc;

  /****************/
  /* Control Unit */
  /****************/
  logic halt;
  // ALU
  alu_op_t   alu_op;
  // Multiplier
  logic     mult;
  logic     mult_half;      // 0 - low half, 1 - high half
  logic     mult_signed_a, mult_signed_b;
  // Register file
  reg_t rd;
  reg_t rs1;
  reg_t rs2;
  // Memory control
  logic     dread;
  logic [1:0] dwrite;
  // Immediate generator out
  word_t    immediate;
  // ALU source 1 (RS2 or PC)
  logic     alu_src1;       // 0 - rs1, 1 - PC
  // ALU source 2 (RS1 or immediate)
  logic     alu_src2;       // 0 - rs2, 1 - immediate
  // Register write source (ALU output or memory)
  logic [1:0] reg_wr_src;   // 0 - alu, 1 - memory, 2 - pc + 4
  // Branch/jump control
  logic     branch_pol;     // 0 - branch if alu.zero = 1, branch if alu.zero - 0
  logic [1:0] pc_ctrl;      // 0 - PC increment, 1 - PC branch, 2 - JAL, 3 - JALR

  /*****************/
  /* Register File */
  /*****************/
  word_t rdat1;
  word_t rdat2;

  // Interface to hazard unit
endinterface

`endif // DECODE_TO_EXECUTE_IF_VH
