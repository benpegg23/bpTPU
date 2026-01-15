`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Simple synchronus shift register with a shift enable and an active-low reset 
//////////////////////////////////////////////////////////////////////////////////


module shift_register # (
    parameter int INPUT_WIDTH = 8, 
    parameter int INPUT_DEPTH = 1
) (
    input logic clk,
    input logic rst_n, 
    input logic shift_enable,
    input logic [INPUT_WIDTH-1:0] in_data,
    output logic [INPUT_WIDTH-1:0] out_data
);

// data shifted in -> [0], [1], ..., [INPUT_DEPTH - 1] -> data shifted out

logic [INPUT_WIDTH-1:0] shift_reg [INPUT_DEPTH-1:0];
assign out_data = shift_reg[INPUT_DEPTH-1];
integer i;
always_ff @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < INPUT_DEPTH; i++) begin
            shift_reg[i] <= 0;
        end  
    end else if (shift_enable) begin
        shift_reg[0] <= in_data;
        for (i = 1; i < INPUT_DEPTH; i++) begin
            shift_reg[i] <= shift_reg[i-1]; 
        end
    end
end


endmodule
