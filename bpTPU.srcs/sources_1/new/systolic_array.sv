`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/13/2026 11:18:03 PM
// Design Name: 
// Module Name: systolic_array
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


module systolic_array # (
    parameter int N = 8,    // grid size (NxN)
    parameter int INPUT_WIDTH = 8,
    parameter int ACC_WIDTH = 64
) (
    input logic clk,
    input logic rst_n,
    input logic load_weight,
    // N inputs/outputs that are input_width bits wide
    // horizontal 
    input logic signed [INPUT_WIDTH-1:0] in_h [N-1:0], 
    // neglect horizontal outputs because they're just the same as the horizontal input   
    // vertical 
    input logic signed [ACC_WIDTH-1:0] in_v [N-1:0], 
    output logic signed [ACC_WIDTH-1:0] out_v [N-1:0]
);

// total wires = 2*[N*(N+1)]
// vertical wires: N x (N+1)
//                 N cols, N+1 rows
// horizontal wires: (N+1) x N
//                   N+1 cols, N rows

// horizontal wires
logic signed [INPUT_WIDTH-1:0] wires_h [N-1:0][N:0];
// vertical wires
logic signed [ACC_WIDTH-1:0] wires_v [N:0][N-1:0];

// instantiate PEs and connect wires to inputs/outputs
genvar col, row;
generate
    for (row = 0; row < N; row++) begin : ROW
        for (col = 0; col < N; col++) begin : COL
            pe # (
                .INPUT_WIDTH(INPUT_WIDTH),
                .ACC_WIDTH(ACC_WIDTH)
            ) pe_inst (
                .clk(clk),
                .rst_n(rst_n),
                .load_weight(load_weight),
                .in_h(wires_h[row][col]),
                .out_h(wires_h[row][col+1]),
                .in_v(wires_v[row][col]),
                .out_v(wires_v[row+1][col])
            );
        end
    end
endgenerate

// connect edges of systolic array to inputs/outputs
genvar i; 
generate 
    // horizontal input
    for (i = 0; i < N; i++) begin
        // col 0
        assign wires_h[i][0] = in_h[i];
    end
    // vertical input
    for (i = 0; i < N; i++) begin
        // row 0
        assign wires_v[0][i] = in_v[i];
    end
    // vertical output
    for (i = 0; i < N; i++) begin
        // row N+1
        assign out_v[i] = wires_v[N][i];
    end
endgenerate

endmodule
