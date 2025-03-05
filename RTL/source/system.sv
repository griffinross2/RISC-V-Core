/*******************************/
/*   Top-level System module   */
/* Contains the CPU and memory */
/*******************************/
`timescale 1ns/1ns

`include "common_types.vh"
import common_types_pkg::*;
`include "ram_dump_if.vh"
`include "cpu_ram_if.vh"
`include "ram_if.vh"

module system (
    input logic clk, nrst,
    output logic halt,
    ram_dump_if.tb cpu_ram_debug_if
);

// cpuclk
logic cpuclk;
assign cpuclk = clk;
// always_ff @(posedge clk, negedge nrst) begin
//     if(~nrst) begin
//         cpuclk <= 1'b0;
//     end else begin
//         cpuclk <= ~cpuclk;
//     end
// end

// Interfaces
cpu_ram_if mem_ctrl_ram_if();
cpu_ram_if cpu_ram_if();
ram_if ram_if();

// Connect control from TB or CPU to memory controller
assign mem_ctrl_ram_if.iren = cpu_ram_debug_if.override_ctrl ? cpu_ram_debug_if.iren : cpu_ram_if.iren;
assign mem_ctrl_ram_if.dren = cpu_ram_debug_if.override_ctrl ? cpu_ram_debug_if.dren : cpu_ram_if.dren;
assign mem_ctrl_ram_if.dwen = cpu_ram_debug_if.override_ctrl ? cpu_ram_debug_if.dwen : cpu_ram_if.dwen;
assign mem_ctrl_ram_if.iaddr = cpu_ram_debug_if.override_ctrl ? cpu_ram_debug_if.iaddr : cpu_ram_if.iaddr;
assign mem_ctrl_ram_if.daddr = cpu_ram_debug_if.override_ctrl ? cpu_ram_debug_if.daddr : cpu_ram_if.daddr;
assign mem_ctrl_ram_if.dstore = cpu_ram_debug_if.override_ctrl ? cpu_ram_debug_if.dstore : cpu_ram_if.dstore;

// Connect memory controller outputs to CPU and TB
assign cpu_ram_if.iwait = mem_ctrl_ram_if.iwait;
assign cpu_ram_if.dwait = mem_ctrl_ram_if.dwait;
assign cpu_ram_if.iload = mem_ctrl_ram_if.iload;
assign cpu_ram_if.dload = mem_ctrl_ram_if.dload;

assign cpu_ram_debug_if.iwait = mem_ctrl_ram_if.iwait;
assign cpu_ram_debug_if.dwait = mem_ctrl_ram_if.dwait;
assign cpu_ram_debug_if.iload = mem_ctrl_ram_if.iload;
assign cpu_ram_debug_if.dload = mem_ctrl_ram_if.dload;

// CPU
cpu cpu_inst(
    .clk(cpuclk),
    .nrst(nrst),
    .halt(halt),
    .cpu_ram_if(cpu_ram_if)
);

// Memory controller
memory_control memory_control_inst (
    .nrst(nrst),
    .cpu_ram_if(mem_ctrl_ram_if),
    .ram_if(ram_if)
);

// Shared Instruction-Data RAM
ram ram_inst (
    .clk(clk),
    .nrst(nrst),
    .ram_if(ram_if)
);

endmodule