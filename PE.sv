// ============================================================================
// PE.sv -- Single Processing Element (PE)
// ============================================================================

module PE #(
    parameter WIDTH = 16                 
)(
    input  wire                    clk,
    input  wire                    rst,      
    input  wire signed [WIDTH-1:0] a_in,     
    input  wire signed [WIDTH-1:0] b_in,     
    output reg  signed [WIDTH-1:0] a_out,    
    output reg  signed [WIDTH-1:0] b_out,    
    output reg  signed [2*WIDTH-1:0] acc     
);

    always @(posedge clk) begin
        if (rst) begin
            a_out <= {WIDTH{1'b0}};
            b_out <= {WIDTH{1'b0}};
            acc   <= {(2*WIDTH){1'b0}};
        end else begin
            a_out <= a_in;                       
            b_out <= b_in;                       
            acc   <= acc + (a_in * b_in);          
        end
    end

endmodule
