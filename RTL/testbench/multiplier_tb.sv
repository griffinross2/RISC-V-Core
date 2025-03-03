`include "multiplier_if.vh"

module multiplier_tb;

logic clk, nrst;

multiplier_if multiplier_if();

multiplier multiplier(
    .clk(clk),
    .nrst(nrst),
    .multiplier_if(multiplier_if)
);

task test_multiply (
    input logic [31:0] a, b
);
begin
    multiplier_if.a = a;
    multiplier_if.b = b;
    multiplier_if.is_signed = 0;
    #100;
    if(multiplier_if.out != a*b) begin
        $fatal("Test failed: %d * %d = %d, expected %d", a, b, multiplier_if.out, a*b);
    end else begin
        $display("Test passed: %d * %d = %d", a, b, multiplier_if.out);
    end
end
endtask

task test_multiply_signed (
    input logic [31:0] a, b
);
begin
    multiplier_if.a = a;
    multiplier_if.b = b;
    multiplier_if.is_signed = 1;
    #100;
    if($signed(multiplier_if.out) != $signed(a)*$signed(b)) begin
        $fatal("Test failed: %d * %d = %d, expected %d", $signed(a), $signed(b), $signed(multiplier_if.out), $signed(a)*$signed(b));
    end else begin
        $display("Test passed: %d * %d = %d", $signed(a), $signed(b), $signed(multiplier_if.out));
    end
end
endtask

logic [31:0] a, b;
integer i;
initial begin
    clk = 0;
    nrst = 0;
    #10;
    nrst = 1;

    a = 0;
    b = 0;

    for (i = 0; i <= 100; i+=1) begin
        a = $urandom();
        b = $urandom();
        test_multiply(a, b);
    end

    for (i = 0; i <= 100; i+=1) begin
        a = $random();
        b = $random();
        test_multiply_signed(a, b);
    end

    $finish;
end

endmodule
