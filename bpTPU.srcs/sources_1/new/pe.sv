`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/13/2026 03:34:49 AM
// Design Name: 
// Module Name: pe
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


module pe # (
    parameter int INPUT_WIDTH = 8,
    parameter int ACC_WIDTH = 32    // accumulator width 
) (
    input logic clk,
    input logic rst_n, // active low
    input logic load_weight,  // flag to start/stop loading weights
    
    // horizontal (activations)
    input logic signed [INPUT_WIDTH-1:0] in_h,
    output logic signed [INPUT_WIDTH-1:0] out_h,
    
    // vertical (weights/partial sums)
    input logic signed [ACC_WIDTH-1:0] in_v,
    output logic signed [ACC_WIDTH-1:0] out_v   // switches between passing in_v and partial sum based on load_weight
                                                // out_v is acc_width bits wide (to fit partial sums), but use the lowest input_width bits when passing weights
);

// note: in python script, remember to divide inputs by 2 bc inputs are signed

logic signed [INPUT_WIDTH-1:0] weight; 

always_ff @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        // reset state
        out_h <= 0;
        out_v <= 0;
        weight <= 0;
    end else begin
        // horizontal
        out_h <= in_h;
        // vertical
        if (load_weight) begin
            weight <= in_v[INPUT_WIDTH-1:0]; 
            out_v <= in_v;  // input passthrough
        end else begin
            out_v <= in_v + (in_h*weight);  // partial sum
        end
    end
end

endmodule
