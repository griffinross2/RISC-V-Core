/**************/
/* RAM module */
/**************/
`include "ram_if.vh"
`include "common_types.vh"
import common_types_pkg::*;

module ram (
    input logic clk, nrst,
    ram_if.ram ram_if
);

// Number of words
parameter RAM_SIZE = 16384;
parameter LAT = 0;

// Counter state
integer count;
integer count_n;

// RAM state
ram_state_t state;
ram_state_t state_n;

xpm_memory_spram #(
    .ADDR_WIDTH_A(30),                                          // 32 bit but aligned
    .MEMORY_SIZE(RAM_SIZE * 32),                                // RAM_SIZE words of 32 bits
    .MEMORY_INIT_FILE("../../../../raminit.mem"),               // Initialization file
    .WRITE_DATA_WIDTH_A(32),                                    // 32 bits data width
    .BYTE_WRITE_WIDTH_A(8),                                     // Word-wide width
    .READ_DATA_WIDTH_A(32),                                     // 32 bits data width
    .READ_LATENCY_A(LAT+1),                                     // Latency
    .RST_MODE_A("ASYNC"),                                       // Asynchronous reset
    .MEMORY_PRIMITIVE("block")                                  // Block RAM
) ram_inst (
    .clka(clk),
    .rsta(~nrst),
    .ena((count == 0) ? (ram_if.ren | (|ram_if.wen)) : 0),
    .wea(ram_if.wen),
    .addra(ram_if.addr[31:2]),
    .dina(ram_if.store),
    .douta(ram_if.load),
    .injectdbiterra(1'b0),
    .injectsbiterra(1'b0),
    .regcea(1'b1),
    .sleep(1'b0)
);

// State machine
always_ff @(posedge clk, negedge nrst) begin
    if (~nrst) begin
        count <= 0;
    end else begin
        count <= count_n;
    end
end

// Next state and output
always_comb begin
    // Nothing requested, idle default
    state = RAM_IDLE;
    count_n = 0;

    // Assert ready if finished counting
    if(count > LAT) begin
        state = RAM_DONE;
        count_n = 0;
    end

    // If a read or write is requested stop being ready
    // and wait for lat + 1 cycles
    if ((ram_if.ren | (|ram_if.wen)) && count <= LAT) begin
        count_n = count + 1;
        state = RAM_WAIT;
    end
end

assign ram_if.state = state;

endmodule
