// ============================================================================
// testbench.sv -- Drives the 2x2 systolic array with a known test case and
// checks the result against hand-calculated matrix multiplication.
//
// Test matrices:
//   A = | 1  2 |        B = | 5  6 |
//       | 3  4 |            | 7  8 |
//
//   Expected C = A x B = | 1*5+2*7   1*6+2*8 |   = | 19  22 |
//                        | 3*5+4*7   3*6+4*8 |     | 43  50 |
//
// This testbench feeds A row-by-row and B column-by-column with the
// staggered ("skewed") timing that a systolic array needs:
//   - Row 0 of A starts at cycle 0.   Row 1 of A starts at cycle 1.
//   - Col 0 of B starts at cycle 0.   Col 1 of B starts at cycle 1.
// This is exactly one clock cycle of delay per row/column index -- see the
// simulation guide for why that specific stagger is required.
// ============================================================================

`timescale 1ns / 1ps

module testbench;

    parameter WIDTH = 16;

    reg clk;
    reg rst;
    reg signed [WIDTH-1:0] a_in_row0, a_in_row1;
    reg signed [WIDTH-1:0] b_in_col0, b_in_col1;
    wire signed [2*WIDTH-1:0] c00, c01, c10, c11;

    // Instantiate the design under test (DUT)
    systolic_array_2x2 #(.WIDTH(WIDTH)) dut (
        .clk       (clk),
        .rst       (rst),
        .a_in_row0 (a_in_row0),
        .a_in_row1 (a_in_row1),
        .b_in_col0 (b_in_col0),
        .b_in_col1 (b_in_col1),
        .c00 (c00), .c01 (c01), .c10 (c10), .c11 (c11)
    );

    // 100 MHz-style clock: 10 ns period
    initial clk = 0;
    always #5 clk = ~clk;

    integer pass;

    initial begin
        $dumpfile("systolic_2x2.vcd");
        $dumpvars(0, testbench);

        // ---- Reset ----
        rst = 1;
        a_in_row0 = 0; a_in_row1 = 0;
        b_in_col0 = 0; b_in_col1 = 0;
        @(posedge clk); #1;

        rst = 0;

        // ---- Cycle 0: feed A[0][0]=1, B[0][0]=5 ----
        a_in_row0 = 1;  a_in_row1 = 0;
        b_in_col0 = 5;  b_in_col1 = 0;
        @(posedge clk); #1;
        $display("After cycle 0 -> c00=%0d c01=%0d c10=%0d c11=%0d", c00, c01, c10, c11);

        // ---- Cycle 1: feed A[0][1]=2, A[1][0]=3, B[1][0]=7, B[0][1]=6 ----
        a_in_row0 = 2;  a_in_row1 = 3;
        b_in_col0 = 7;  b_in_col1 = 6;
        @(posedge clk); #1;
        $display("After cycle 1 -> c00=%0d c01=%0d c10=%0d c11=%0d", c00, c01, c10, c11);

        // ---- Cycle 2: feed A[1][1]=4, B[1][1]=8 (rows/cols 0 are exhausted) ----
        a_in_row0 = 0;  a_in_row1 = 4;
        b_in_col0 = 0;  b_in_col1 = 8;
        @(posedge clk); #1;
        $display("After cycle 2 -> c00=%0d c01=%0d c10=%0d c11=%0d", c00, c01, c10, c11);

        // ---- Cycle 3: nothing left to feed, let the array drain ----
        a_in_row0 = 0;  a_in_row1 = 0;
        b_in_col0 = 0;  b_in_col1 = 0;
        @(posedge clk); #1;
        $display("After cycle 3 -> c00=%0d c01=%0d c10=%0d c11=%0d", c00, c01, c10, c11);

        // ---- Check results ----
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
