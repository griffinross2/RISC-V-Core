`include "ram_if.vh"
`include "cpu_ram_if.vh"
`include "common_types.vh"
import common_types_pkg::*;

module memory_control (
  input logic nrst,
  cpu_ram_if.ramctrl cpu_ram_if,
  ram_if.ramctrl ram_if
);

  always_comb begin
    // Default to just reading instructions
    ram_if.ren = 1'b0;
    ram_if.wen = 4'b0;
    ram_if.addr = '0;
    
    cpu_ram_if.iwait = 1'b1;
    cpu_ram_if.dwait = 1'b1;

    ram_if.store = cpu_ram_if.dstore;
    cpu_ram_if.iload = ram_if.load;
    cpu_ram_if.dload = ram_if.load;

    // Don't do things in reset
    if(nrst) begin
      // If a data write is requested, do that with high priority
      if(|cpu_ram_if.dwen) begin
        // Give RAM the data
        ram_if.addr = cpu_ram_if.daddr;
        ram_if.wen = cpu_ram_if.dwen;

        // RAM ready
        if(ram_if.state == RAM_DONE) begin
          cpu_ram_if.dwait = 1'b0;
        end
      end else
      // If a data read is requested, do that instead
      if(cpu_ram_if.dren) begin
        ram_if.addr = cpu_ram_if.daddr;
        ram_if.ren = 1;

        // RAM ready
        if(ram_if.state == RAM_DONE) begin
          cpu_ram_if.dwait = 1'b0;
        end
      end else
      // If an instruction read (and no other operation) is requested, do that
      if(cpu_ram_if.iren) begin
        ram_if.addr = cpu_ram_if.iaddr;
        ram_if.ren = 1;

        // RAM ready
        if(ram_if.state == RAM_DONE) begin
          cpu_ram_if.iwait = 1'b0;
        end
      end
    end
  end

endmodule
