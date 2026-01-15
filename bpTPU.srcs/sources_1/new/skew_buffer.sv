`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Skew Buffer
// Input at index 0 is output immediately
// Input at index 1 is output after 1 clock cycle
// ... 
// Input at index N is output after N clock cycles
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

// _ = shift reg
// | = output
// * = input
// 0         * | 
// 1       * _ |
// 2     * _ _ |
// 3   * _ _ _ |
// ...

// create shift regs for each input
genvar i, j;
generate
    for (i = 0; i < N; i++) begin : ROW
        if (i == 0) begin
            assign out_data[0] = in_data[0];
        end else begin
            shift_register # (
                .INPUT_WIDTH(INPUT_WIDTH),
                .INPUT_DEPTH(i)
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
