// Exception Unit
`timescale 1ns/1ns

`include "exception_unit_if.vh"
`include "common_types.vh"
import common_types_pkg::*;

module exception_unit (
    input logic clk, nrst,
    exception_unit_if.exception_unit euif
);

always_comb begin
    euif.exception = 0;
    euif.exception_pc = euif.e2mif_pc;
    euif.exception_cause = 0;
    euif.exception_target = euif.mtvec_base;
    euif.interrupt = 0;
    
    euif.f2dif_flush = 0;
    euif.d2eif_flush = 0;
    euif.e2mif_flush = 0;
    euif.m2wif_flush = 0;

    if (euif.illegal_inst) begin
        // Illegal instruction
        euif.exception = 1;
        euif.exception_cause = 32'd2;
    end

    if (euif.exception) begin
        // Exceptions are handled in memory, because thats where
        // branch is handled, so flush all stages through memory.
        euif.f2dif_flush = 1;
        euif.d2eif_flush = 1;
        euif.e2mif_flush = 1;
        euif.m2wif_flush = 1;
    end

    if (euif.interrupt) begin
        if (euif.mtvec_mode == 2'd1) begin
            // Vectored interrupt mode: target address is mtvec_base + 4*cause
            euif.exception_target = euif.mtvec_base + (euif.exception_cause << 2);
        end
    end
end

endmodule