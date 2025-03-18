// Exception Unit
`timescale 1ns/1ns

`include "exception_unit_if.vh"
`include "common_types.vh"
import common_types_pkg::*;

module exception_unit (
    input logic clk, nrst,
    exception_unit_if.exception_unit euif
);

// Exception handler
localparam EXCEPTION_HANDLER = 32'h8000;


endmodule