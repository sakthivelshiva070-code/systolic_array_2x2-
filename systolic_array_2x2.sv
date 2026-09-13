// ============================================================================
// systolic_array_2x2.sv -- Wires four PEs into a 2x2 output-stationary
// systolic array for multiplying two 2x2 matrices: C = A x B
//
//                 a_in_row0                 a_in_row1
//                    |                          |
//                    v                          v
//   b_in_col0 --> [ PE00 ]--a00_out-->[ PE01 ]     (top row,  i = 0)
//                    |  \b00_out          |  \b01_out
//                    |   \                |   \
//                    v    \               v    \
//   b_in_col1 ------------>[ PE10 ]--a10_out-->[ PE11 ]   (bottom row, i = 1)
//
// PE(i,j) ends up holding C[i][j] once the array has fully "drained" --
// see the accompanying report / simulation guide for the exact cycle count
// and a worked numeric example.
// ============================================================================

module systolic_array_2x2 #(
    parameter WIDTH = 16
)(
    input  wire                       clk,
    input  wire                       rst,

    // Left-edge inputs: one A value per row, per cycle
    input  wire signed [WIDTH-1:0]    a_in_row0,   // feeds PE00 (row 0)
    input  wire signed [WIDTH-1:0]    a_in_row1,   // feeds PE10 (row 1)

    // Top-edge inputs: one B value per column, per cycle
    input  wire signed [WIDTH-1:0]    b_in_col0,   // feeds PE00 (col 0)
    input  wire signed [WIDTH-1:0]    b_in_col1,   // feeds PE01 (col 1)

    // Final results: C[i][j], valid once the array has drained
    output wire signed [2*WIDTH-1:0]  c00,
    output wire signed [2*WIDTH-1:0]  c01,
    output wire signed [2*WIDTH-1:0]  c10,
    output wire signed [2*WIDTH-1:0]  c11
);

    // Internal wires carrying A rightward and B downward between PEs
    wire signed [WIDTH-1:0] a00_out, a10_out;   // A leaving column 0, entering column 1
    wire signed [WIDTH-1:0] b00_out, b01_out;   // B leaving row 0, entering row 1

    // Top-left PE: both inputs come from the array boundary
    PE #(.WIDTH(WIDTH)) PE00 (
        .clk   (clk),
        .rst   (rst),
        .a_in  (a_in_row0),
        .b_in  (b_in_col0),
        .a_out (a00_out),
        .b_out (b00_out),
        .acc   (c00)
    );

    // Top-right PE: A comes from PE00 (to its left), B from the boundary
    PE #(.WIDTH(WIDTH)) PE01 (
        .clk   (clk),
        .rst   (rst),
        .a_in  (a00_out),
        .b_in  (b_in_col1),
        .a_out (),            // rightmost column -- nothing to its right
        .b_out (b01_out),
        .acc   (c01)
    );

    // Bottom-left PE: A comes from the boundary, B from PE00 (above it)
    PE #(.WIDTH(WIDTH)) PE10 (
        .clk   (clk),
        .rst   (rst),
        .a_in  (a_in_row1),
        .b_in  (b00_out),
        .a_out (a10_out),
        .b_out (),            // bottom row -- nothing below it
        .acc   (c10)
    );

    // Bottom-right PE: A comes from PE10, B comes from PE01
    PE #(.WIDTH(WIDTH)) PE11 (
        .clk   (clk),
        .rst   (rst),
        .a_in  (a10_out),
        .b_in  (b01_out),
        .a_out (),
        .b_out (),
        .acc   (c11)
    );

endmodule
