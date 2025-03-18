/*
  Command and Status Registers interface
*/
`ifndef CSR_IF_VH
`define CSR_IF_VH

`include "common_types.vh"
import common_types_pkg::*;

interface csr_if;

  // CSR r/w signals
  logic csr_write;
  logic [11:0] csr_waddr;
  logic [11:0] csr_raddr;
  logic [WORD_W-1:0] csr_wdata;
  logic [WORD_W-1:0] csr_rdata;

  // CSR port
  modport csr (
    input   csr_write, csr_waddr, csr_wdata,
            csr_raddr,
    output  csr_rdata
  );
  // tb port
  modport tb (
    input   csr_rdata,
    output  csr_write, csr_waddr, csr_wdata,
            csr_raddr
  );
endinterface

`endif //CSR_IF_VH
