/*******************************/
/*   Top-level System module   */
/* Contains the CPU and memory */
/*******************************/
`timescale 1ns/1ns

`include "common_types.vh"
import common_types_pkg::*;
`include "axi_controller_if.vh"
`include "axi_bus_if.vh"
`include "ahb_bus_if.vh"
`include "ram_if.vh"

module system (
    input logic sys_clk_i, ck_rst,
    output logic clk, nrst,
    input logic rxd,
    output logic txd,
    output logic halt,
    axi_controller_if.axi_controller debug_amif,
    output logic flash_cs,
    inout wire [3:0] flash_dq,
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
    output [0:0] ddr3_cs_n
);

// Interrupt lines
logic [31:0] interrupt_in_sync;
logic uart_rx_int;

always_comb begin
    interrupt_in_sync = 32'b0;
    interrupt_in_sync[16] = uart_rx_int;
end

// Interfaces
axi_controller_if fetch_amif();
axi_controller_if mem_amif();

axi_bus_if multiplexor_abif();
axi_bus_if debug_abif();
axi_bus_if icache_abif();
axi_bus_if dcache_abif();
axi_bus_if sram_abif();
axi_bus_if flash_abif();
axi_bus_if dram_abif();
axi_bus_if ahb_abif();
ahb_bus_if controller_ahb();
ahb_bus_if uart_ahb();
ahb_bus_if def_ahb();

ram_if ram_if();

// Datapath
datapath datapath_inst (
    .clk(clk),
    .nrst(nrst),
    .interrupt_in_sync(interrupt_in_sync),
    .halt(halt),
    .amif_fetch(fetch_amif),
    .amif_mem(mem_amif)
);

// AXI interconnect
axi_interconnect axi_interconnect_inst (
    .clk(clk),
    .nrst(nrst),
    .abif_to_icache(icache_abif),
    .abif_to_dcache(dcache_abif),
    .abif_to_dma(debug_abif),   // Plug debug into DMA for now
    .abif_to_sram(sram_abif),
    .abif_to_flash(flash_abif),
    .abif_to_dram(dram_abif),
    .abif_to_ahb(ahb_abif)
);

// Debug AXI controller
axi_controller debug_controller (
    .clk(clk),
    .nrst(nrst),
    .amif(debug_amif),
    .abif(debug_abif)
);

// AXI ICache controller
// No icache rn
axi_controller icache_controller (
    .clk(clk),
    .nrst(nrst),
    .amif(fetch_amif),
    .abif(icache_abif)
);

// AXI DCache controller
// No dcache rn
axi_controller dcache_controller (
    .clk(clk),
    .nrst(nrst),
    .amif(mem_amif),
    .abif(dcache_abif)
);

// AXI Flash controller
axi_flash_controller flash_controller (
    .clk(clk),
    .nrst(nrst),
    .abif(flash_abif),
    .clk_div(4'd1),
    .flash_cs(flash_cs),
    .flash_dq(flash_dq)
);

// AXI ROM controller
axi_rom_controller rom_controller (
    .clk(clk),
    .nrst(nrst),
    .abif(sram_abif),
    .ram_if(ram_if)
);

// ROM
rom rom_inst (
    .clk(clk),
    .nrst(nrst),
    .ram_if(ram_if)
);

// AXI DRAM controller
axi_dram_controller dram_controller (
    .sys_clk_i(sys_clk_i),
    .ck_rst(ck_rst),
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
    .ddr3_cs_n(ddr3_cs_n),
    .clk(clk),
    .nrst(nrst),
    .abif(dram_abif)
);

// AXI to AHB-Lite bridge
axi_to_ahb_bridge axi_to_ahb_inst (
    .clk(clk),
    .nrst(nrst),
    .axi(ahb_abif),
    .ahb(controller_ahb)
);

// AHB-Lite Multiplexor
ahb_multiplexor ahb_multiplexor_inst (
    .clk(clk),
    .nrst(nrst),
    .abif_to_controller(controller_ahb),
    .abif_to_uart(uart_ahb),
    .abif_to_def(def_ahb)
);

// AHB-Lite UART satellite
ahb_uart_satellite ahb_uart_inst (
    .clk(clk),
    .nrst(nrst),
    .abif(uart_ahb),
    .rxd(rxd),
    .txd(txd),
    .rxi(uart_rx_int)
);

// AHB-Lite default satellite
ahb_default_satellite ahb_default_inst (
    .clk(clk),
    .nrst(nrst),
    .abif(def_ahb)
);

endmodule