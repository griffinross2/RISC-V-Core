`timescale 1ns/1ns

`include "common_types.vh"
import common_types_pkg::*;
`include "axi_controller_if.vh"

module system_fpga (
    input sys_clk_i, ck_rst,
    output qspi_cs,
    inout [3:0] qspi_dq,
    inout [15:0] ddr3_dq,
    output [1:0] ddr3_dm,
    inout [1:0] ddr3_dqs_p,
    inout [1:0] ddr3_dqs_n,
    output [13:0] ddr3_addr,
    output [2:0] ddr3_ba,
    output [0:0] ddr3_ck_p,
    output [0:0] ddr3_ck_n,
    output ddr3_ras_n,
    output ddr3_cas_n,
    output ddr3_we_n,
    output ddr3_reset_n,
    output [0:0] ddr3_cke,
    output [0:0] ddr3_odt,
    output [0:0] ddr3_cs_n,
    output LED [0:3],
    output UART_TXD,
    input uart_txd_in
);

  // Clock and reset
  (* keep = "true", dont_touch = "true", mark_debug = "true" *) wire clk;
  logic nrst;

  // Halt signal
  logic halt;

  // UART
  logic rxd;
  logic txd;

  axi_controller_if debug_amif();

  assign UART_TXD = txd;
  assign rxd = uart_txd_in;
  assign LED[0] = ~txd;
  assign LED[1] = ~rxd;
  assign LED[2] = halt;
  assign LED[3] = nrst;

  // Zero out dump interface
  always_comb begin
    debug_amif.read = '0;
    debug_amif.write = '0;
    debug_amif.addr = '0;
    debug_amif.store = '0;
    debug_amif.done = '0;
  end

  // System
  system system_inst (
    .sys_clk_i(sys_clk_i),
    .ck_rst(ck_rst),
    .clk(clk),
    .nrst(nrst),
    .rxd(rxd),
    .txd(txd),
    .halt(halt),
    .debug_amif(debug_amif),
    .flash_cs(qspi_cs),
    .flash_dq(qspi_dq),
    .ddr3_dq(ddr3_dq),
    .ddr3_dm(ddr3_dm),
    .ddr3_dqs_p(ddr3_dqs_p),
    .ddr3_dqs_n(ddr3_dqs_n),
    .ddr3_addr(ddr3_addr),
    .ddr3_ba(ddr3_ba),
    .ddr3_ck_p(ddr3_ck_p),
    .ddr3_ck_n(ddr3_ck_n),
    .ddr3_ras_n(ddr3_ras_n),
    .ddr3_cas_n(ddr3_cas_n),
    .ddr3_we_n(ddr3_we_n),
    .ddr3_reset_n(ddr3_reset_n),
    .ddr3_cke(ddr3_cke),
    .ddr3_odt(ddr3_odt),
    .ddr3_cs_n(ddr3_cs_n)
  );

endmodule