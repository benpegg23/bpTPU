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
    parameter int ADDR_WIDTH = 10   // BRAM 
) (
    input logic clk,
    input logic rst_n,
    // instructions
    
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
);


endmodule
