`timescale 1ns/1ns

`include "ahb_bus_if.vh"

`include "common_types.vh"
import common_types_pkg::*;

module cpu (
  input logic clk, nrst,
  output logic halt,
  ahb_bus_if.master_to_mux abif
);

// Datapath
datapath datapath_inst (
  .clk(clk),
  .nrst(nrst),
  .halt(halt),
  .abif(abif)
);
  
endmodule
