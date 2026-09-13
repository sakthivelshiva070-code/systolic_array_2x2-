// ============================================================================
// testbench.sv
// ============================================================================

`timescale 1ns / 1ps

module testbench;

    parameter WIDTH = 16;

    reg clk;
    reg rst;
    reg signed [WIDTH-1:0] a_in_row0, a_in_row1;
    reg signed [WIDTH-1:0] b_in_col0, b_in_col1;
    wire signed [2*WIDTH-1:0] c00, c01, c10, c11;
    
    systolic_array_2x2 #(.WIDTH(WIDTH)) dut (
        .clk       (clk),
        .rst       (rst),
        .a_in_row0 (a_in_row0),
        .a_in_row1 (a_in_row1),
        .b_in_col0 (b_in_col0),
        .b_in_col1 (b_in_col1),
        .c00 (c00), .c01 (c01), .c10 (c10), .c11 (c11)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    integer pass;

    initial begin
        $dumpfile("systolic_2x2.vcd");
        $dumpvars(0, testbench);

        rst = 1;
        a_in_row0 = 0; a_in_row1 = 0;
        b_in_col0 = 0; b_in_col1 = 0;
        @(posedge clk); #1;

        rst = 0;

        a_in_row0 = 1;  a_in_row1 = 0;
        b_in_col0 = 5;  b_in_col1 = 0;
        @(posedge clk); #1;
        $display("After cycle 0 -> c00=%0d c01=%0d c10=%0d c11=%0d", c00, c01, c10, c11);

        a_in_row0 = 2;  a_in_row1 = 3;
        b_in_col0 = 7;  b_in_col1 = 6;
        @(posedge clk); #1;
        $display("After cycle 1 -> c00=%0d c01=%0d c10=%0d c11=%0d", c00, c01, c10, c11);

        a_in_row0 = 0;  a_in_row1 = 4;
        b_in_col0 = 0;  b_in_col1 = 8;
        @(posedge clk); #1;
        $display("After cycle 2 -> c00=%0d c01=%0d c10=%0d c11=%0d", c00, c01, c10, c11);

        a_in_row0 = 0;  a_in_row1 = 0;
        b_in_col0 = 0;  b_in_col1 = 0;
        @(posedge clk); #1;
        $display("After cycle 3 -> c00=%0d c01=%0d c10=%0d c11=%0d", c00, c01, c10, c11);

        pass = 1;
        if (c00 !== 19) begin $display("MISMATCH: c00 = %0d, expected 19", c00); pass = 0; end
        if (c01 !== 22) begin $display("MISMATCH: c01 = %0d, expected 22", c01); pass = 0; end
        if (c10 !== 43) begin $display("MISMATCH: c10 = %0d, expected 43", c10); pass = 0; end
        if (c11 !== 50) begin $display("MISMATCH: c11 = %0d, expected 50", c11); pass = 0; end

        if (pass)
            $display("\n*** TEST PASSED: systolic array correctly computed A x B ***");
        else
            $display("\n*** TEST FAILED ***");

        #20;
        $finish;
    end

endmodule
