`timescale 1ns/1ns

`include "common_types.vh"
import common_types_pkg::*;
`include "ram_dump_if.vh"

module system_tb;
  parameter CLOCK_PERIOD = 10ns;

  // Clock and reset
  logic clk;
  logic nrst;

  // Halt signal
  logic halt;

  // RAM dump IF
  ram_dump_if cpu_ram_if();

  // System
  system system_inst (
    .clk(clk),
    .nrst(nrst),
    .halt(halt),
    .cpu_ram_debug_if(cpu_ram_if)
  );

  task automatic dump_memory();
    string filename = "../../../../ramcpu.hex";
    int memfd;

    cpu_ram_if.iaddr = 0;
    cpu_ram_if.iren = 0;

    memfd = $fopen(filename,"w");
    if (memfd)
      $display("Starting memory dump.");
    else
      begin $display("Failed to open %s.",filename); $finish; end

    for (int unsigned i = 0; memfd && i < 16384; i++)
    begin
      int chksum = 0;
      bit [7:0][7:0] values;
      string ihex;

      cpu_ram_if.iaddr = i << 2;
      @(posedge clk);
      cpu_ram_if.iren = 1;
      @(negedge clk);
      wait(~cpu_ram_if.iwait);
      if (cpu_ram_if.iload === 0)
        continue;
      values = {8'h04,16'(i),8'h00,cpu_ram_if.iload};
      foreach (values[j])
        chksum += values[j];
      chksum = 16'h100 - chksum;
      ihex = $sformatf(":04%h00%h%h",16'(i),cpu_ram_if.iload,8'(chksum));
      $fdisplay(memfd,"%s",ihex.toupper());
    end //for
    if (memfd)
    begin
      cpu_ram_if.iren = 0;
      $fdisplay(memfd,":00000001FF");
      $fclose(memfd);
      $display("Finished memory dump.");
    end
  endtask

  // Clock generation
  initial begin
    clk = 0;
    forever #(CLOCK_PERIOD/2) clk = ~clk;
  end

  // Run CPU
  initial begin
    cpu_ram_if.override_ctrl = 0;
    nrst = 1;
    #10;
    nrst = 0;
    #10;
    nrst = 1;
  
    while(!halt) begin
      @(posedge clk);
    end

    // Zero memory dump IF
    cpu_ram_if.iren = 0;
    cpu_ram_if.dren = 0;
    cpu_ram_if.dwen = 0;
    cpu_ram_if.dstore = 0;
    cpu_ram_if.iaddr = 0;
    cpu_ram_if.daddr = 0;

    // Take control of the memory
    cpu_ram_if.override_ctrl = 1;

    dump_memory();

    $finish;
  end

endmodule