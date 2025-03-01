`include "common_types.vh"
import common_types_pkg::*;

module cpu (
  input logic clk, nrst,
  output logic halt,
  cpu_ram_if.cpu cpu_ram_if
);

// Datapath
datapath datapath_inst (
  .clk(clk),
  .nrst(nrst),
  .halt(halt),
  .cpu_ram_if(cpu_ram_if)
);
  
endmodule
