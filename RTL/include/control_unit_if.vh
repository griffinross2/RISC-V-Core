/*
  Control Unit interface
*/
`ifndef CONTROL_UNIT_IF_VH
`define CONTROL_UNIT_IF_VH

`include "common_types.vh"
import common_types_pkg::*;

interface control_unit_if;

  // Control Unit input
  word_t    inst;
  
  // ALU
  reg_t rs1, rs2, rd;
  alu_op_t   alu_op;
  // Register file
  logic     rf_wen;
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
  // Halt
  logic halt;

  // control ports
  modport control_unit (
    input   inst,
    output  rs1, rs2, rd, rf_wen,   // Register File
            alu_op,                 // ALU
            dread, dwrite,          // Request Unit
            immediate,              // Immediate Generator
            alu_src1, alu_src2,     // ALU source mux
            reg_wr_src,             // Reg File writeback source
            branch_pol, pc_ctrl,    // Program Counter
            halt                    // Halt
  );
  // control tb
  modport tb (
    input   rs1, rs2, rd, rf_wen,   // Register File
            alu_op,                 // ALU
            dread, dwrite,          // Request Unit
            immediate,              // Immediate Generator
            alu_src1, alu_src2,     // ALU source mux
            reg_wr_src,             // Reg File writeback source
            branch_pol, pc_ctrl,    // Program Counter
            halt,                   // Halt
    output  inst
  );
endinterface

`endif //CONTROL_IF_VH
