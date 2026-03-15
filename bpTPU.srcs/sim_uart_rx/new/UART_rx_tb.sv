`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// testbench for uart recieve module
//////////////////////////////////////////////////////////////////////////////////


module UART_rx_tb();

parameter int CLK_FREQ = 100_000_000;
parameter int BAUD_RATE = 115200;
parameter int OVERSAMPLE_RATE = 16;
parameter int MESSAGE_SIZE = 8;

logic clk;
logic rst_n; 
logic rx;
logic valid;
//logic error;
logic [MESSAGE_SIZE-1:0] data_buffer;

// instantiate dut
UART_rx # (
	.CLK_FREQ(CLK_FREQ),
	.BAUD_RATE(BAUD_RATE),
	.OVERSAMPLE_RATE(OVERSAMPLE_RATE),
	.MESSAGE_SIZE(MESSAGE_SIZE)
) UART_rx_dut (.*);     // autoconnect 

initial begin: CLOCK_INITIALIZATION
    clk = 1'b1;
end

always begin: CLOCK_GENERATION
    #5 clk = ~clk;
end

initial begin: TEST_VECTORS
	rst_n <= 0;
	rx <= 1; 
	repeat (5) @ (posedge clk);
    rst_n <= 1;
	$display("UART Transmission example #1");
	$display("Transmitting 01101100");
	// data bits
	rx <= 0; 
	$display("start bit asserted");	
	$display("transmission frequency: %d", CLK_FREQ / BAUD_RATE);
	// data bits
	repeat (CLK_FREQ / BAUD_RATE) @ (posedge clk);
	rx <= 0;	// [0]
	repeat (CLK_FREQ / BAUD_RATE) @ (posedge clk);
	if (data_buffer != 8'b00000000) $error("wrong");
	rx <= 0;	// [1]
	repeat (CLK_FREQ / BAUD_RATE) @ (posedge clk);
	if (data_buffer != 8'b00000000) $error("wrong");
	rx <= 1;	// [2]
	repeat (CLK_FREQ / BAUD_RATE) @ (posedge clk);
	if (data_buffer != 8'b00000100) $error("wrong");
	rx <= 1;	// [3]
	repeat (CLK_FREQ / BAUD_RATE) @ (posedge clk);
	if (data_buffer != 8'b00001100) $error("wrong");
	rx <= 0;	// [4]
	repeat (CLK_FREQ / BAUD_RATE) @ (posedge clk);
	if (data_buffer != 8'b00001100) $error("wrong");
	rx <= 1;	// [5]
	repeat (CLK_FREQ / BAUD_RATE) @ (posedge clk);
	if (data_buffer != 8'b00101100) $error("wrong");
	rx <= 1;	// [6]
	repeat (CLK_FREQ / BAUD_RATE) @ (posedge clk);
	if (data_buffer != 8'b01101100) $error("wrong");
	rx <= 0;	// [7]
	// stop bit
	repeat (CLK_FREQ / BAUD_RATE) @ (posedge clk);
	if (data_buffer != 8'b01101100) $error("wrong");
	rx <= 1;	
	$display("stop bit asserted");

	repeat (100) @ (posedge clk);

	$display("UART Transmission example #2");
	$display("Transmitting 11111111");
	// data bits
	rx <= 0; 
	$display("start bit asserted");	
	$display("transmission frequency: %d", CLK_FREQ / BAUD_RATE);
	// data bits
	repeat (CLK_FREQ / BAUD_RATE) @ (posedge clk);
	rx <= 1;	// [0]
	repeat (CLK_FREQ / BAUD_RATE) @ (posedge clk);
	if (data_buffer != 8'b00000000) $error("wrong");
	rx <= 1;	// [1]
	repeat (CLK_FREQ / BAUD_RATE) @ (posedge clk);
	if (data_buffer != 8'b00000000) $error("wrong");
	rx <= 1;	// [2]
	repeat (CLK_FREQ / BAUD_RATE) @ (posedge clk);
	if (data_buffer != 8'b00000100) $error("wrong");
	rx <= 1;	// [3]
	repeat (CLK_FREQ / BAUD_RATE) @ (posedge clk);
	if (data_buffer != 8'b00001100) $error("wrong");
	rx <= 1;	// [4]
	repeat (CLK_FREQ / BAUD_RATE) @ (posedge clk);
	if (data_buffer != 8'b00001100) $error("wrong");
	rx <= 1;	// [5]
	repeat (CLK_FREQ / BAUD_RATE) @ (posedge clk);
	if (data_buffer != 8'b00101100) $error("wrong");
	rx <= 1;	// [6]
	repeat (CLK_FREQ / BAUD_RATE) @ (posedge clk);
	if (data_buffer != 8'b01101100) $error("wrong");
	rx <= 1;	// [7]
	// stop bit
	repeat (CLK_FREQ / BAUD_RATE) @ (posedge clk);
	if (data_buffer != 8'b01101100) $error("wrong");
	rx <= 1;	
	$display("stop bit asserted");

	repeat (100) @ (posedge clk);

	$finish("done");





end


endmodule
