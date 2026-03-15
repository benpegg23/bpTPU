`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/13/2026 10:06:47 PM
// Design Name: 
// Module Name: relu_tb
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


module relu_tb();

parameter int N = 8;
parameter int INPUT_WIDTH = 32;

logic signed [INPUT_WIDTH-1:0] vec[N-1:0]; 
logic signed [INPUT_WIDTH-1:0] vec_relu[N-1:0];

logic clk;

relu # (
	.INPUT_WIDTH(INPUT_WIDTH),
	.N(N)
) relu_dut (.*);	// autoconnect

initial begin: CLOCK_INITIALIZATION
    clk = 1'b1;
end

always begin: CLOCK_GENERATION
    #5 clk = ~clk;
end

initial begin: TEST_VECTORS
	$display("starting test vectors...");
	// reset vec (all zeros) 
	for (int i = 0; i < N; i++) begin
		vec[i] <= '0;
	end

	repeat (10) @ (posedge clk);

	for (int i = 0; i < N; i++) begin
		if (vec_relu[i] != 8'b0000_0000) begin
			$error("fails, vec_relu[%d] is wrong. got %d, expected 0000_0000", i, vec_relu[i]);
		end
	end

	// set vec to some stuff

	vec[0] <= 8'b1000_0000; 
	// expect vec_relu[0] = 0000_0000

	vec[1] <= 8'b0111_1111; 
	// expect vec_relu[1] = 0111_1111

	vec[2] <= 8'b1111_1111; 
	// expect vec_relu[2] = 0000_0000

	vec[3] <= 8'b1010_1010; 
	// expect vec_relu[3] = 0000_0000

	vec[4] <= 8'b0101_0101; 
	// expect vec_relu[4] = 0101_0101 	

	vec[5] <= 8'b0001_1000; 
	// expect vec_relu[5] = 0001_1000	

	vec[6] <= 8'b0110_1111; 
	// expect vec_relu[6] = 0110_1111 	

	vec[7] <= 8'b1110_1111; 
	// expect vec_relu[7] = 0000_0000	

	if (vec[0] != '0) $error("vec_relu[0] wrong, expected 0000_0000, got %d", vec_relu[0]);
	if (vec[1] != '0) $error("vec_relu[1] wrong, expected 0111_1111, got %d", vec_relu[1]);
	if (vec[2] != '0) $error("vec_relu[2] wrong, expected 0000_0000, got %d", vec_relu[2]);
	if (vec[3] != '0) $error("vec_relu[3] wrong, expected 0000_0000, got %d", vec_relu[3]);
	if (vec[4] != '0) $error("vec_relu[4] wrong, expected 0101_0101, got %d", vec_relu[4]);
	if (vec[5] != '0) $error("vec_relu[5] wrong, expected 0001_1000, got %d", vec_relu[5]);
	if (vec[6] != '0) $error("vec_relu[6] wrong, expected 0110_1111, got %d", vec_relu[6]);
	if (vec[7] != '0) $error("vec_relu[7] wrong, expected 0000_0000, got %d", vec_relu[7]);

	repeat (10) @ (posedge clk);

	$finish("done");




end


endmodule
