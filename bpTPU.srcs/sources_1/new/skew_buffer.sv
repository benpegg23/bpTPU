`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Skew Buffer
//////////////////////////////////////////////////////////////////////////////////


module skew_buffer # (
    parameter int INPUT_WIDTH = 8,
    parameter int N = 8
) (
    input logic clk,
    input logic rst_n, 
    input logic load_data,
    input logic signed [INPUT_WIDTH-1:0] in_data [N-1:0],
    output logic signed [INPUT_WIDTH-1:0] out_data [N-1:0]
);

genvar i, j;
generate
    for (i = 0; i < N; i++) begin : ROW
        if (i == 0) begin
            assign out_data[0] = in_data[0];
        end else begin
            // i shift registers
            for (int j = 0; j < i; j++) begin
                
            end
        end 
    end

endgenerate



endmodule
