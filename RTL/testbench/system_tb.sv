`timescale 1ns/1ns

`include "common_types.vh"
import common_types_pkg::*;
`include "axi_controller_if.vh"

module system_tb;
  parameter CLOCK_PERIOD = 10ns;

  // Clock and reset
  logic clk;
  logic nrst;

  // Halt signal
  logic halt;

  // RAM dump IF
  axi_controller_if debug_amif();

  // UART
  logic rxd;
  logic txd;

  // DRAM wires
  wire [15:0] ddr3_dq;
  wire [1:0] ddr3_dm;
  wire [1:0] ddr3_dqs_p;
  wire [1:0] ddr3_dqs_n;
  wire [13:0] ddr3_addr;
  wire [2:0] ddr3_ba;
  wire [0:0] ddr3_ck_p;
  wire [0:0] ddr3_ck_n;
  wire ddr3_ras_n;
  wire ddr3_cas_n;
  wire ddr3_we_n;
  wire ddr3_reset_n;
  wire [0:0] ddr3_cke;
  wire [0:0] ddr3_odt;
  wire [0:0] ddr3_cs_n;

  // Flash wires
  wire flash_cs;
  wire [3:0] flash_dq;

  // Fake DDR3
  ddr3_model ddr3_inst (
    .rst_n(ddr3_reset_n),
    .ck(ddr3_ck_p),
    .ck_n(ddr3_ck_n),
    .cke(ddr3_cke),
    .cs_n(ddr3_cs_n),
    .ras_n(ddr3_ras_n),
    .cas_n(ddr3_cas_n),
    .we_n(ddr3_we_n),
    .dm_tdqs(ddr3_dm),
    .ba(ddr3_ba),
    .addr(ddr3_addr),
    .dq(ddr3_dq),
    .dqs(ddr3_dqs_p), 
    .dqs_n(ddr3_dqs_n),
    .tdqs_n(),
    .odt(ddr3_odt)
  );

  // Fake flash
  flash_model flash_inst (
    .clk(clk),
    .nrst(nrst),
    .clk_div(4'd1),
    .cs(flash_cs),
    .dq(flash_dq)
  );

  // Clock, reset
  logic sys_clk, sys_nrst;
  initial begin
    sys_clk = 0;
    forever #5ns sys_clk = ~sys_clk;
  end

  initial begin
    sys_nrst = 0;
    #100;
    sys_nrst = 1;
  end

  // System
  system system_inst (
    .sys_clk_i(sys_clk),
    .ck_rst(sys_nrst),
    .clk(clk),
    .nrst(nrst),
    .rxd(rxd),
    .txd(txd),
    .halt(halt),
    .debug_amif(debug_amif),
    .flash_cs(flash_cs),
    .flash_dq(flash_dq),
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
    .ddr3_cs_n(ddr3_cs_n)
  );

  task automatic dump_memory();
  `ifndef SIMULATOR
    string filename = "../../../../ramcpu.hex";
  `else
    string filename = "ramcpu.hex";
  `endif
    int memfd;

    debug_amif.addr = 0;
    debug_amif.read = 0;

    memfd = $fopen(filename,"w");
    if (memfd != 0)
      $display("Starting memory dump.");
    else
      begin $display("Failed to open %s.",filename); $finish; end

    for (int unsigned i = 0; memfd != 0 && i < 16384; i++)
    begin
      int chksum = 0;
      bit [7:0][7:0] values;
      string ihex;

      debug_amif.addr = i << 2;
      @(posedge clk);
      debug_amif.read = 1;
      @(posedge clk);
      debug_amif.read = 0;
      @(posedge clk);
      wait(debug_amif.ready == 1);
      debug_amif.done = 1;
      if (debug_amif.load != 0) begin
        values = {8'h04,16'(i<<2),8'h00,debug_amif.load};
        foreach (values[j])
          chksum += 32'(values[j]);
        chksum = 32'h100 - chksum;
        ihex = $sformatf(":04%h00%h%h",16'(i<<2),debug_amif.load,8'(chksum));
        $fdisplay(memfd,"%s",ihex.toupper());
      end
      @(posedge clk);
      debug_amif.done = 0;
      @(posedge clk);
    end //for
    if (memfd != 0)
    begin
      debug_amif.read = 0;
      $fdisplay(memfd,":00000001FF");
      $fclose(memfd);
      $display("Finished memory dump.");
    end
  endtask

  // Run CPU
  integer num_cycles = 0;
  initial begin
    @(posedge clk);
    @(posedge nrst);

    num_cycles = 0;
  
    while(!halt) begin
      @(posedge clk);
      num_cycles++;
    end

    // Zero memory dump IF
    debug_amif.read = 0;
    debug_amif.write = '0;
    debug_amif.store = '0;
    debug_amif.addr = '0;
    debug_amif.done = '0;

    // Print cycles and time
    $display("CPU halted after %d cycles, %.2f ns",num_cycles, $realtime());

    // dump_memory();

    $finish;
  end

endmodule