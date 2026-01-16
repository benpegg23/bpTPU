`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Deskew buffer
// Skew buffer but backwards
// Input width is wider bc input output of array (32 bits)
//////////////////////////////////////////////////////////////////////////////////


module deskew_buffer # (
    parameter int INPUT_WIDTH = 32,
    parameter int N = 8     // number of inputs
) (
    input logic clk,
    input logic rst_n, 
    input logic load_data,
    input logic signed [INPUT_WIDTH-1:0] in_data [N-1:0],
    output logic signed [INPUT_WIDTH-1:0] out_data [N-1:0]
);

// create shift regs for each input
// same as skew buffer but just in reverse type shi
genvar i;
generate
    for (i = 0; i < N; i++) begin : ROW
        if (i == N-1) begin     // inverted from skew buffer
            assign out_data[i] = in_data[i];
        end else begin
            shift_register # (
                .INPUT_WIDTH(INPUT_WIDTH),
                .INPUT_DEPTH((N-1)-i)   // inverted from skew buffer
            ) shift_register_inst (
                .clk(clk),
                .rst_n(rst_n),
                .shift_enable(load_data),
                .in_data(in_data[i]),
                .out_data(out_data[i])
            );
        end 
    end
endgenerate


endmodule
