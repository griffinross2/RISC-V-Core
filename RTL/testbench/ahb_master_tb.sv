`timescale 1ns / 1ns

`include "ahb_master_if.vh"
`include "ahb_bus_if.vh"
`include "common_types.vh"
import common_types_pkg::*;

module ahb_master_tb ();

    // Signals
    logic clk;
    logic nrst;

    // Interface
    ahb_master_if amif ();
    ahb_bus_if abif ();

    ahb_master ahb_inst (
        .clk(clk),
        .nrst(nrst),
        .amif(amif),
        .abif(abif)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Tasks
    task reset_dut;
        begin
            amif.iread = 0;
            amif.dread = 0;
            amif.dwrite = 0;
            amif.iaddr = 0;
            amif.daddr = 0;
            amif.dstore = 0;
            abif.hrdata = 0;
            abif.hready = 1;
            abif.hresp = 0;
            nrst = 0;
            @(posedge clk);
            nrst = 1;
        end
    endtask
    
    task test_transfer;
        input logic iread, dread;
        input logic [1:0] dwrite;
        input word_t iaddr, daddr, dstore;
        input word_t rdata_test;
        word_t rdata;
        begin
            // Set signals to master
            amif.iread = iread;
            amif.dread = dread;
            amif.dwrite = dwrite;
            amif.iaddr = iaddr;
            amif.daddr = daddr;
            amif.dstore = dstore;

            // Go to start of data phase
            @(posedge clk);
            // Set signals to master to idle
            amif.iread = '0;
            amif.dread = '0;
            amif.dwrite = '0;
            amif.iaddr = '0;
            amif.daddr = '0;
            amif.dstore = '0;
            // Respond
            abif.hrdata = rdata_test;
            // Finish transaction
            @(negedge clk);
            if (iread) begin
                if (amif.iload != rdata_test) begin
                $display("Test failed: Expected 0x%08h, got 0x%08h", rdata_test, abif.hrdata);
            end
            end else begin
                if (amif.dload != rdata_test) begin
                $display("Test failed: Expected 0x%08h, got 0x%08h", rdata_test, abif.hrdata);
            end
            end
            @(posedge clk);
            // Set bus signals to idle
            abif.hready = 1;
            abif.hresp = 0;
        end
    endtask

    // Test sequence
    initial begin
        reset_dut;

        @(posedge clk);

        test_transfer(1, 0, 0, 32'h00000004, 32'h00000000, 32'h00000000, 32'h01234567);

        // Finish simulation
        #50;
        $finish();
    end

endmodule