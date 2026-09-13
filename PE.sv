// ============================================================================
// PE.sv -- Single Processing Element (PE) for a systolic matrix-multiply array
//
// Role of this PE (output-stationary systolic dataflow, after Kung & Leiserson
// 1978): every PE holds ONE running accumulator ("acc") that is never handed
// to another PE. On every clock edge it does three things at once:
//   1. Multiplies its two CURRENT inputs (a_in, b_in) and adds the result
//      into its own accumulator.
//   2. Latches a_in into a_out, so the value is handed to the PE on its
//      right one cycle later ("A flows left-to-right").
//   3. Latches b_in into b_out, so the value is handed to the PE below it
//      one cycle later ("B flows top-to-bottom").
//
// Because A and B values ripple through the grid with a one-cycle delay per
// hop, and because the testbench feeds each row/column starting at a
// different, carefully staggered cycle (see testbench.sv), the right pair of
// A and B values always meets at the right PE at the right time. That
// staggering is what makes a "systolic" array work -- nothing inside the PE
// itself needs to know its own (row, col) position.
// ============================================================================

module PE #(
    parameter WIDTH = 16                 // bit-width of one matrix element
)(
    input  wire                    clk,
    input  wire                    rst,      // synchronous, active-high
    input  wire signed [WIDTH-1:0] a_in,     // A value arriving from the left
    input  wire signed [WIDTH-1:0] b_in,     // B value arriving from above
    output reg  signed [WIDTH-1:0] a_out,    // A value handed to the PE on the right
    output reg  signed [WIDTH-1:0] b_out,    // B value handed to the PE below
    output reg  signed [2*WIDTH-1:0] acc     // running partial sum (this PE's C element)
);

    always @(posedge clk) begin
        if (rst) begin
            a_out <= {WIDTH{1'b0}};
            b_out <= {WIDTH{1'b0}};
            acc   <= {(2*WIDTH){1'b0}};
        end else begin
            a_out <= a_in;                       // pass A rightward, 1-cycle delay
            b_out <= b_in;                        // pass B downward, 1-cycle delay
            acc   <= acc + (a_in * b_in);          // multiply-accumulate (MAC)
        end
    end

endmodule
