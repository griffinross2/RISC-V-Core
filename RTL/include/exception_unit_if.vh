/*
  Exception Unit interface
*/
`ifndef EXCEPTION_UNIT_IF_VH
`define EXCEPTION_UNIT_IF_VH

`include "common_types.vh"
import common_types_pkg::*;

interface exception_unit_if;

  // From decode
  word_t f2dif_pc;
  logic illegal_inst;

  // To hazard
  logic exception;
  logic exception_target;

  // exception ports
  modport exception_unit (
    input   illegal_inst, f2dif_pc,
    output  exception, exception_target
  );
  // exception tb
  modport tb (
    input   exception, exception_target,
    output  illegal_inst, f2dif_pc
  );
endinterface

`endif //EXCEPTION_IF_VH
