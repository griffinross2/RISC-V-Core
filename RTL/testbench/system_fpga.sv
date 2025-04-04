`timescale 1ns/1ns

`include "common_types.vh"
import common_types_pkg::*;
`include "ram_dump_if.vh"

module system_fpga (
  input logic CLK,
  input logic ck_rst,
  input logic uart_txd_in,
  output logic UART_TXD,
  output logic LED [0:2]
);

  // Clock and reset
  logic clk_50;
  logic nrst;

  // Halt signal
  logic halt;

  // RAM dump IF
  ram_dump_if cpu_ram_if();

  // UART
  logic rxd;
  logic txd;

  initial begin
    clk_50 = 1'b0;
  end

  always_ff @(posedge CLK) begin
    clk_50 <= ~clk_50;  // Divide by 2
  end

  assign nrst = ck_rst;
  assign UART_TXD = txd;
  assign rxd = uart_txd_in;
  assign LED[0] = ~txd;
  assign LED[1] = ~rxd;
  assign LED[2] = halt;

  assign cpu_ram_if.override_ctrl = 0;

  // System
  system system_inst (
    .clk(clk_50),
    .nrst(nrst),
    .rxd(rxd),
    .txd(txd),
    .halt(halt),
    .cpu_ram_debug_if(cpu_ram_if)
  );

endmodule