`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/13/2026 05:45:17 PM
// Design Name: 
// Module Name: pe_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module pe_tb();

parameter int INPUT_WIDTH = 8;
parameter int ACC_WIDTH = 32; 

logic clk;
logic rst_n;
logic load_weight;
logic signed [INPUT_WIDTH-1:0] in_h;
logic signed [INPUT_WIDTH-1:0] out_h;
logic signed [ACC_WIDTH-1:0] in_v;
logic signed [ACC_WIDTH-1:0] out_v;

pe # (
    .INPUT_WIDTH(INPUT_WIDTH),
    .ACC_WIDTH(ACC_WIDTH)
) pe_dut (.*);  // autoconnect

initial begin: CLOCK_INITIALIZATION
    clk = 1'b1;
end

initial begin: CLOCK_GENERATION
    #1 clk = ~clk;
end

endmodule
