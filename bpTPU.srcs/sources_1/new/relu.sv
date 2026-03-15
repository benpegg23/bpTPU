`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// takes a vector and relus everything in it type shi
//////////////////////////////////////////////////////////////////////////////////

// TODO: currently wrong (see tb)

module relu # (
	parameter int INPUT_WIDTH = 32,
	parameter int N = 8	// vector width
) (
	input logic signed [INPUT_WIDTH-1:0] vec[N-1:0],  
	output logic signed [INPUT_WIDTH-1:0] vec_relu[N-1:0]
);

genvar i; 
generate
    for (i = 0; i < N; i++) begin
        assign vec_relu[i] = (vec[i] < 0) ? vec[i] : '0; 
    end
endgenerate

endmodule
