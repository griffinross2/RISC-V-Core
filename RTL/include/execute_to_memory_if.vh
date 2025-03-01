/*
  Control Unit interface
*/
`ifndef EXECUTE_TO_MEMORY_IF_VH
`define EXECUTE_TO_MEMORY_IF_VH

`include "common_types.vh"
import common_types_pkg::*;

interface execute_to_memory_if;

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
  // Register file
  reg_t rd;
  // Memory control
  logic     dread;
  logic [1:0] dwrite;
  // Register write source (ALU output or memory)
  logic [1:0] reg_wr_src;   // 0 - alu, 1 - memory, 2 - pc + 4
  // Branch/jump control
  logic     branch_pol;     // 0 - branch if alu.zero = 1, branch if alu.zero - 0
  logic [1:0] pc_ctrl;      // 0 - PC increment, 1 - PC branch, 2 - JAL, 3 - JALR

  /*****************/
  /* Register File */
  /*****************/
  word_t rdat2;

  /*******/
  /* ALU */
  /*******/
  word_t alu_out;
  logic alu_zero;



  /*****************/
  /* PC Arithmetic */
  /*****************/
  word_t pc_plus_imm;
endinterface

`endif // EXECUTE_TO_MEMORY_IF_VH
