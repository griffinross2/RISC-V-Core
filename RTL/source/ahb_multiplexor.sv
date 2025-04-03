/******************************/
/*  AHB-Lite Bus Multiplexor  */
/******************************/
`timescale 1ns/1ns

`include "ahb_bus_if.vh"

`include "common_types.vh"
import common_types_pkg::*;

module ahb_multiplexor (
    input logic clk, nrst,
    ahb_bus_if.mux_to_master abif_to_master,
    ahb_bus_if.mux_to_slave abif_to_def,
    ahb_bus_if.mux_to_slave abif_to_ram
);

    integer sel_i;
    integer sel_i_reg;

    word_t haddr_reg;
    htrans_t htrans_reg;
    logic readyout;

    always_ff @(posedge clk, negedge nrst) begin
        if (~nrst) begin
            haddr_reg <= '0;
            htrans_reg <= HTRANS_IDLE;
            sel_i_reg <= 0;
        end else begin
            // Latch the address from the master interface if the current slave is ready
            haddr_reg <= readyout ? abif_to_master.haddr : haddr_reg;
            htrans_reg <= readyout ? abif_to_master.htrans : htrans_reg;
            sel_i_reg <= readyout ? sel_i : sel_i_reg;
        end
    end

    
    always_comb begin
        // Default slave
        sel_i = 0;

        // Default response
        abif_to_master.hrdata = '0;
        abif_to_master.hresp = 1'b0;
        readyout = '1;

        // Select the appropriate slave based on the address
        abif_to_def.hsel = 1'b0;
        abif_to_ram.hsel = 1'b0;

        // RAM address range = 0x0000_0000 to 0x0000_FFFF
        if (abif_to_master.htrans != HTRANS_IDLE && abif_to_master.haddr < 32'h0001_0000) begin
            abif_to_ram.hsel = 1'b1;
            sel_i = 1;
        end else begin
            abif_to_def.hsel = 1'b1;
            sel_i = 0;
        end

        casez(sel_i_reg)
            0: begin // Default slave
                abif_to_master.hrdata = abif_to_def.hrdata;
                readyout = abif_to_def.hreadyout;
                abif_to_master.hresp = abif_to_def.hresp;
            end

            1: begin // RAM slave
                abif_to_master.hrdata = abif_to_ram.hrdata;
                readyout = abif_to_ram.hreadyout;
                abif_to_master.hresp = abif_to_ram.hresp;
            end

            default: begin // Invalid address, default to default slave
                abif_to_master.hrdata = abif_to_def.hrdata;
                readyout = abif_to_def.hreadyout;
                abif_to_master.hresp = abif_to_def.hresp;
            end
        endcase

        // Send ready output
        abif_to_master.hready = readyout;

        // Send signals to all slaves
        abif_to_def.hwdata = abif_to_master.hwdata;
        abif_to_def.haddr = abif_to_master.haddr;
        abif_to_def.hburst = abif_to_master.hburst;
        abif_to_def.hsize = abif_to_master.hsize;
        abif_to_def.htrans = abif_to_master.htrans;
        abif_to_def.hwrite = abif_to_master.hwrite;
        abif_to_def.hready = readyout;

        abif_to_ram.hwdata = abif_to_master.hwdata;
        abif_to_ram.haddr = abif_to_master.haddr;
        abif_to_ram.hburst = abif_to_master.hburst;
        abif_to_ram.hsize = abif_to_master.hsize;
        abif_to_ram.htrans = abif_to_master.htrans;
        abif_to_ram.hwrite = abif_to_master.hwrite;
        abif_to_ram.hready = readyout;
    end
endmodule