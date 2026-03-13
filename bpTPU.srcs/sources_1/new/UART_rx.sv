`timescale 1ns / 1ps

module UART_rx # (
	parameter int CLK_FREQ = 100_000_000; // 100 Mhz
	parameter int BAUD_RATE = 115200;
	parameter int OVERSAMPLE_RATE = 16;
	parameter int MESSAGE_SIZE = 8; // 8 bit message size

) (
	input logic clk,
	input logic rst_n, 
	input logic rx,
	output logic valid, // data_buffer full
	output logic error,
	output logic [MESSAGE_SIZE-1:0] data_buffer
);

// baud stuff
localparam int MAX_COUNT = CLK_FREQ / (BAUD_RATE * OVERSAMPLE_RATE);
localparam int COUNTER_WIDTH = $clog2(MAX_COUNT);
logic [COUNTER_WIDTH-1:0] baud_counter;
logic baud_tick;

logic [$clog2(MESSAGE_SIZE) - 1:0] bits_read, bits_read_next;	 

// baud tick generation
always_ff @ (posedge clk) begin
	if (!rst_n) begin
		baud_counter <= '0;
		baud_tick <= 1'b0;  
	end else begin
		if (baud_counter == MAX_COUNT - 1) begin
			baud_tick <= 1'b0; // baud_tick is high for 1 clock cycle in middle and edges of each bit period
			baud_counter <= '0; 
		end else begin
			baud_counter <= baud_counter + 1'b1; 
			baud_tick <= 1'b0; 
		end
	end
end

// fsm
typedef enum logic {
	s_idle = 1'b0,
	s_recieve = 1'b1
} state_t; 

state_t state, state_next;

always_comb begin
	// defaults
	state_next = state; 	// stay in same state
	bits_read_next = bits_read; 
	unique case (state)
		s_idle: begin
			if (!rx) begin 	// start bit
				state_next = s_recieve; 
				bits_read_next = '0; 	// reset bit counter
			end
		end

		s_recieve: begin
			if (bits_read == MESSAGE_SIZE) begin 	// TODO: do we have to wait for a stop bit here if we want to detect frame errors? 
				state_next = s_idle; 
			end else begin
				output_logic[bits_read] = rx; 
				bits_read += 1'b1; 
			end
		end

		default: // defaults assigned at top

	endcase
end

always_ff @ (posedge clk) begin
	state <= state_next;  
	bits_read <= bits_read_next; 
end

// use clk to generate baud rate thing
// baud should tick at twice the baud rate so we can sample data in the middle of the baud "pulse"?
// idk what the terminology is but ykwim
// UART fsm:
// IDLE:
// stay in idle while rx is high
// data output is X
// valid output is 0
// have a valid bit to indicate when data is valid? 
// maybe redundant
// transition to recieve when rx goes low (start bit)
// RECIEVE: 
// internal bits_read reg to store track how many bits read in current message
// stay in recieve and continue writing to data_buffer while in recieve
// when bits_read = MESSAGE_SIZE, make sure stop bit is asserted (rx pulled high by master), reset bits_read, and transition to IDLE
// do we need some sort of error checking?



endmodule