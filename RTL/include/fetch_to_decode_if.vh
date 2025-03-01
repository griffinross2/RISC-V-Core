/*
  Control Unit interface
*/
`ifndef FETCH_TO_DECODE_IF_VH
`define FETCH_TO_DECODE_IF_VH

`include "common_types.vh"
import common_types_pkg::*;

interface fetch_to_decode_if;

  // Enable/Flush
  logic en;
  logic flush;

  // Latched stuff

  /*******************/
  /* Program Counter */
  /*******************/
  word_t pc;

  /***************/
  /* Instruction */
  /***************/
  word_t inst;
endinterface

`endif // FETCH_TO_DECODE_IF_VH
