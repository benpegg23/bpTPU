`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Control Unit
// Manages instruction input
// Manages data input/output
// Manages control flow
//////////////////////////////////////////////////////////////////////////////////


module control # (
    parameter int INSTRUCTION_WIDTH = 4, 
    parameter int WEIGHT_ADDR_WIDTH = 10,
    parameter int DATA_WIDTH = 8,
    parameter int ADDR_WIDTH = 10,   // BRAM 
	parameter int CLK_FREQ = 100_000_000, // 100 Mhz
	parameter int BAUD_RATE = 115200,
	parameter int OVERSAMPLE_RATE = 16,
	parameter int MESSAGE_SIZE = 8
) (
    input logic clk,
    input logic rst_n,
    // instructions
	
); 

logic [...] data_buffer;

UART_rx # (
	.CLK_FREQ(CLK_FREQ),
	.BAUD_RATE(BAUD_RATE),
	.OVERSAMPLE_RATE(OVERSAMPLE_RATE),
	.MESSAGE_SIZE(MESSAGE_SIZE)
) UART_rx_inst (		// use default parameters
	.clk(clk),
	.rst_n(rst_n),
	.rx(rx), // TODO: add some usb driver that captures ts
	
	.valid(),
	.data_buffer(data_buffer)
);


UART_tx # (

) UART_tx_inst (

);



/*
psuedocode:

logic [23:0] instruction 

if (valid) 
	instruction.push_back(data_buffer) 
	if (3 data buffer pushes to instruction) // valid instruction, 8*3=24
		state_next = decode

case state:
	...
	decode: 
		instruction[23:16] = opcode
		if (opcode = reg_imm type)
			instruction[15:8] = reg
			instruction[7:0] = imm
	

	...

case opcode:
	0x00:
	0x01:
	0x10:
	0x11: 
*/ 


    /* 
    inputs:
    instructions from computer over UART
    instruction ready/done
    outputs:
    select bit for input mux to activation skew buffer (mux between input bram and ReLU)
    mmu control signals (switch load_weight on and off)
    skew/deskew buffer control signals (load_data)
    weight BRAM read/write control (enable and address)
    output BRAM read/write control (enable, address, and data)
    input BRAM read/write control (enable, address, and data)
    */



endmodule
