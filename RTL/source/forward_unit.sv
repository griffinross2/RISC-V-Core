`timescale 1ns/1ns

`include "forward_unit_if.vh"

`include "common_types.vh"
import common_types_pkg::*;

module forward_unit(
  forward_unit_if.forward_unit fuif
);

  always_comb begin
    fuif.forward_a = '0;
    fuif.forward_b = '0;
    // Forward from WB
    if(fuif.wb_rd != 0 && fuif.wb_rd == fuif.id_rsel1) fuif.forward_a = 2'd2;
    if(fuif.wb_rd != 0 && fuif.wb_rd == fuif.id_rsel2) fuif.forward_b = 2'd2;
    // Forward from MEM with priority
    if(fuif.mem_rd != 0 && fuif.mem_rd == fuif.id_rsel1) fuif.forward_a = 2'd1;
    if(fuif.mem_rd != 0 && fuif.mem_rd == fuif.id_rsel2) fuif.forward_b = 2'd1;
  end

endmodule