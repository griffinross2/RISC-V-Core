`ifndef MULTIPLIER_IF
`define MULTIPLIER_IF

`include "common_types.vh"
import common_types_pkg::*;

interface multiplier_if;
    
    logic en, ready;
    logic [31:0] a, b;
    logic [63:0] out;

    modport mult (
        input en, a, b,
        output out, ready
    );
endinterface

`endif // MULTIPLIER_IF