/*
  Forward Unit
*/
`ifndef FORWARD_UNIT_VH
`define FORWARD_UNIT_VH

`include "common_types.vh"
import common_types_pkg::*;

interface forward_unit_if;

  logic [1:0] forward_a; // 0 - rdat1, 1 - ex_alu_out, 2 - mem_alu_out  
  logic [1:0] forward_b; // 0 - rdat2, 2 - ex_alu_out, 2 - mem_alu_out

  reg_t id_rsel1;
  reg_t id_rsel2;

  reg_t mem_rd;
  reg_t wb_rd;

  modport forward_unit (
    input id_rsel1, id_rsel2, mem_rd, wb_rd,
    output forward_a, forward_b
  );

  modport tb (
    output id_rsel1, id_rsel2, mem_rd, wb_rd,
    input forward_a, forward_b
  );


endinterface

`endif
