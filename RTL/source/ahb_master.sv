/*************************/
/*  AHB-Lite Bus Master  */
/*************************/
`timescale 1ns/1ns

`include "ahb_master_if.vh"
`include "ahb_bus_if.vh"

`include "common_types.vh"
import common_types_pkg::*;

module ahb_master (
    input logic clk, nrst,
    ahb_master_if.ahb_master amif,
    ahb_bus_if.master abif
);

word_t hwdata_n;

typedef enum logic [1:0] {
    TRANSFER_IDLE,
    TRANSFER_IREAD,
    TRANSFER_DREAD,
    TRANSFER_DWRITE
} transfer_t;

// Transfer in data phase
transfer_t data_transfer;

// Transfer in addr phase (next data phase)
transfer_t addr_transfer;

always_ff @(posedge clk, negedge nrst) begin
    if (~nrst) begin
        abif.hwdata <= '0;
        data_transfer <= TRANSFER_IDLE;
    end else begin
        abif.hwdata <= hwdata_n;
        data_transfer <= addr_transfer;
    end
end

always_comb begin
    // Default to no change
    hwdata_n = abif.hwdata;
    addr_transfer = data_transfer;
    
    // Output signals
    amif.ihit = 1'b0;
    amif.dhit = 1'b0;
    amif.iload = '0;
    amif.dload = '0;

    if (abif.hready) begin
        // Finish the current transaction
        casez (data_transfer)
            TRANSFER_IREAD: begin
                amif.iload = abif.hrdata;
                amif.ihit = 1'b1;
            end
            TRANSFER_DREAD: begin
                amif.dload = abif.hrdata;
                amif.dhit = 1'b1;
            end
            TRANSFER_DWRITE: begin
                amif.dhit = 1'b1;
            end
            default: begin
                // Idle, do nothing
            end
        endcase

        // Start a new transaction
        if (amif.dread) begin
            abif.haddr = amif.daddr;
            abif.hburst = 3'b000;
            abif.hsize = 2'b10;
            abif.htrans = HTRANS_NONSEQ;
            hwdata_n = '0;
            abif.hwrite = 1'b0;
            addr_transfer = TRANSFER_DREAD;
        end else if (|amif.dwrite) begin
            abif.haddr = amif.daddr;
            abif.hburst = 3'b000;
            casez (amif.dwrite)
                2'b01: abif.hsize = 2'b00; // byte
                2'b10: abif.hsize = 2'b01; // halfword
                2'b11: abif.hsize = 2'b10; // word
                default: abif.hsize = 2'b10;
            endcase
            abif.htrans = HTRANS_NONSEQ;
            hwdata_n = amif.dstore;
            abif.hwrite = 1'b1;
            addr_transfer = TRANSFER_DWRITE;
        end else if (amif.iread) begin
            abif.haddr = amif.iaddr;
            abif.hburst = 3'b000;
            abif.hsize = 2'b10;
            abif.htrans = HTRANS_NONSEQ;
            hwdata_n = '0;
            abif.hwrite = 1'b0;
            addr_transfer = TRANSFER_IREAD;
        end else begin
            abif.haddr = '0;
            abif.hburst = '0;
            abif.hsize = '0;
            abif.htrans = HTRANS_IDLE;
            hwdata_n = '0;
            abif.hwrite = '0;
            addr_transfer = TRANSFER_IDLE;
        end
    end
end

endmodule