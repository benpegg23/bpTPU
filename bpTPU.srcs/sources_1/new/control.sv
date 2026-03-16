`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Control Unit
// Manages instruction input
// Manages data input/output
// Manages control flow
//////////////////////////////////////////////////////////////////////////////////


module control # (
	parameter int DATA_WIDTH = 8,
	parameter int ADDR_WIDTH = 10
) (
    input logic clk,
    input logic rst_n,

    // uart
	input logic rx_valid, 
	input logic [7:0] rx_data, 

	output logic tx_start, 
	output logic [7:0] tx_data,
	input logic tx_busy,

	// weight bram
	output logic weight_we,
	output logic [ADDR_WIDTH-1:0] input_addr, 
	output logic [DATA_WIDTH-1:0] input_din, 

	// datapath
	
); 

logic [...] data_buffer;



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
