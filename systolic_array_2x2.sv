// ============================================================================
// systolic_array_2x2.sv
// ============================================================================

module systolic_array_2x2 #(
    parameter WIDTH = 16
)(
    input  wire                       clk,
    input  wire                       rst,

    input  wire signed [WIDTH-1:0]    a_in_row0,   
    input  wire signed [WIDTH-1:0]    a_in_row1,   

    input  wire signed [WIDTH-1:0]    b_in_col0,   
    input  wire signed [WIDTH-1:0]    b_in_col1,   

    output wire signed [2*WIDTH-1:0]  c00,
    output wire signed [2*WIDTH-1:0]  c01,
    output wire signed [2*WIDTH-1:0]  c10,
    output wire signed [2*WIDTH-1:0]  c11
);

    wire signed [WIDTH-1:0] a00_out, a10_out;   
    wire signed [WIDTH-1:0] b00_out, b01_out;   

    PE #(.WIDTH(WIDTH)) PE00 (
        .clk   (clk),
        .rst   (rst),
        .a_in  (a_in_row0),
        .b_in  (b_in_col0),
        .a_out (a00_out),
        .b_out (b00_out),
        .acc   (c00)
    );

    PE #(.WIDTH(WIDTH)) PE01 (
        .clk   (clk),
        .rst   (rst),
        .a_in  (a00_out),
        .b_in  (b_in_col1),
        .a_out (),            
        .b_out (b01_out),
        .acc   (c01)
    );

    PE #(.WIDTH(WIDTH)) PE10 (
        .clk   (clk),
        .rst   (rst),
        .a_in  (a_in_row1),
        .b_in  (b00_out),
        .a_out (a10_out),
        .b_out (),            
        .acc   (c10)
    );

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
