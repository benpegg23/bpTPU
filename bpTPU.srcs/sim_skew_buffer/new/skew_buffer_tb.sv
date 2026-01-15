`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// testbench for skew buffer
//////////////////////////////////////////////////////////////////////////////////


module skew_buffer_tb();

parameter int INPUT_WIDTH = 8;
parameter int N = 8;
logic clk;
logic rst_n; 
logic load_data;
logic signed [INPUT_WIDTH-1:0] in_data [N-1:0];
logic signed [INPUT_WIDTH-1:0] out_data [N-1:0]; 

skew_buffer # (
    .INPUT_WIDTH(INPUT_WIDTH),
    .N(N)
) (.*);     // autoconnect

initial begin: CLOCK_INITIALIZATION
    clk = 1'b1;
end

always begin: CLOCK_GENERATION
    #5 clk = ~clk;
end






endmodule
