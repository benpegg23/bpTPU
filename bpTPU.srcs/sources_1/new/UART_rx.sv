`timescale 1ns / 1ps

module UART_rx # (
	parameter int CLK_FREQ = 100_000_000, // 100 Mhz
	parameter int BAUD_RATE = 115200,
	parameter int OVERSAMPLE_RATE = 16,
	parameter int MESSAGE_SIZE = 8 // bits
) (
	input logic clk,
	input logic rst_n, 
	input logic rx,
	output logic valid, // data_buffer full
	//output logic error,
	output logic [MESSAGE_SIZE-1:0] data_buffer
);

// baud stuff
localparam int MAX_COUNT = CLK_FREQ / (BAUD_RATE * OVERSAMPLE_RATE);
localparam int COUNTER_WIDTH = $clog2(MAX_COUNT);
localparam int BIT_PERIOD_MIDDLE = OVERSAMPLE_RATE / 2;
logic [COUNTER_WIDTH-1:0] baud_counter;
logic baud_tick;
logic [$clog2(OVERSAMPLE_RATE)-1:0] tick_counter, tick_counter_next; // position within bit period

logic [$clog2(MESSAGE_SIZE)-1:0] bits_read, bits_read_next;	 

logic [MESSAGE_SIZE-1:0] data_buffer_next; 
logic valid_next; 

// baud tick generation
always_ff @ (posedge clk) begin
	if (!rst_n) begin
		baud_counter <= '0;
		baud_tick <= 1'b0;  
	end else begin
		if (baud_counter == MAX_COUNT - 1) begin
			baud_tick <= 1'b1; // baud_tick is high for 1 clock cycle in middle and edges of each bit period
			baud_counter <= '0; 
		end else begin
			baud_counter <= baud_counter + 1'b1; 
			baud_tick <= 1'b0; 
		end
	end
end

// fsm
typedef enum logic [1:0] {
	s_idle = 2'b00,
	s_start = 2'b01,
	s_recieve = 2'b10,
	s_stop = 2'b11
} state_t; 

state_t state, state_next;


// TODO: for all counters, explicitly reset 
always_comb begin
	// defaults
	state_next = state; 	// stay in same state
	bits_read_next = bits_read; 
	tick_counter_next = tick_counter;
	data_buffer_next = data_buffer; 
	valid_next = 1'b0; 		// only assert valid during transition from recieve to stop
							// otherwise valid is implicity set to 0 
	unique case (state)
		s_idle: begin
			if (~rx) begin
				state_next = s_start;
				tick_counter_next = '0;
			end
		end

		s_start: begin
			tick_counter_next = tick_counter + 1'b1; 
			if (tick_counter == BIT_PERIOD_MIDDLE - 1 && ~rx) begin 	// check middle of start bit
				state_next = s_recieve;
				tick_counter_next = '0; 
				bits_read_next = '0; 
			end else if (tick_counter == BIT_PERIOD_MIDDLE - 1 && rx) begin 	// start bit not asserted for long enough
				state_next = s_idle; 
			end
		end

		s_recieve: begin
			tick_counter_next = tick_counter + 1'b1; 
			if (tick_counter == OVERSAMPLE_RATE - 1) begin
				data_buffer_next[bits_read] = rx; 
				tick_counter_next = '0; 

				if (bits_read == MESSAGE_SIZE - 1) begin
					state_next = s_stop; 
					valid_next = 1'b1; 
				end else begin
					bits_read_next = bits_read + 1'b1;
				end
			end
		end

		s_stop: begin
			tick_counter_next = tick_counter + 1'b1; 
			if (tick_counter == OVERSAMPLE_RATE - 1) begin
				state_next = s_idle; 
				tick_counter_next = '0;
			end
		end

		default: begin 
            // defaults assigned at top
        end    
	endcase
end

always_ff @ (posedge clk) begin
	if (~rst_n) begin
		state <= s_idle; 
		bits_read <= '0; 
		tick_counter <= '0;
		data_buffer <= '0;
		valid <= '0;
	end else if (baud_tick) begin  // advance state based on baud ticks 
		state <= state_next;  
		bits_read <= bits_read_next; 
		tick_counter <= tick_counter_next;
		data_buffer <= data_buffer_next; 
		valid <= valid_next; 
	end 
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

/*

`timescale 1ns / 1ps

module UART_rx # (
    parameter int CLK_FREQ = 100_000_000, // 100 MHz
    parameter int BAUD_RATE = 115200,
    parameter int OVERSAMPLE_RATE = 16,
    parameter int MESSAGE_SIZE = 8        // bits
) (
    input  logic clk,
    input  logic rst_n, 
    input  logic rx,
    output logic valid, 
    output logic error,
    output logic [MESSAGE_SIZE-1:0] data_buffer
);

    // Derived Constants
    localparam int MAX_COUNT = CLK_FREQ / (BAUD_RATE * OVERSAMPLE_RATE);
    localparam int COUNTER_WIDTH = $clog2(MAX_COUNT);
    localparam int BIT_PERIOD_MIDDLE = OVERSAMPLE_RATE / 2;

    // Baud Generator Registers
    logic [COUNTER_WIDTH-1:0] baud_counter;
    logic baud_tick;

    // FSM Datapath Registers
    logic [$clog2(OVERSAMPLE_RATE)-1:0] tick_counter, tick_counter_next;
    logic [$clog2(MESSAGE_SIZE)-1:0]    bits_read, bits_read_next; 
    logic [MESSAGE_SIZE-1:0]            data_buffer_next; 
    logic valid_next, error_next;

    // Baud Tick Generation (System Clock Domain)
    always_ff @ (posedge clk) begin
        if (~rst_n) begin
            baud_counter <= '0;
            baud_tick    <= 1'b0;  
        end else begin
            if (baud_counter == MAX_COUNT - 1) begin
                baud_tick    <= 1'b1; 
                baud_counter <= '0; 
            end else begin
                baud_counter <= baud_counter + 1'b1; 
                baud_tick    <= 1'b0; 
            end
        end
    end

    // FSM State Encoding
    typedef enum logic [1:0] {
        s_idle    = 2'b00,
        s_start   = 2'b01,
        s_recieve = 2'b10,
        s_stop    = 2'b11
    } state_t; 

    state_t state, state_next;

    // FSM Combinational Next-State Logic
    always_comb begin
        // Defaults to prevent latches
        state_next        = state;    
        bits_read_next    = bits_read; 
        tick_counter_next = tick_counter;
        data_buffer_next  = data_buffer; 
        valid_next        = 1'b0;
        error_next        = 1'b0;

        unique case (state)
            s_idle: begin
                if (~rx) begin
                    state_next = s_start;
                    tick_counter_next = '0;
                end
            end

            s_start: begin
                tick_counter_next = tick_counter + 1'b1; 
                if (tick_counter == BIT_PERIOD_MIDDLE - 1) begin
                    if (~rx) begin    
                        // Valid start bit confirmed
                        state_next = s_recieve;
                        tick_counter_next = '0; 
                        bits_read_next = '0; 
                    end else begin    
                        // Glitch detected, abort
                        state_next = s_idle; 
                        tick_counter_next = '0;
                    end
                end
            end

            s_recieve: begin
                tick_counter_next = tick_counter + 1'b1; 
                if (tick_counter == OVERSAMPLE_RATE - 1) begin
                    data_buffer_next[bits_read] = rx; 
                    tick_counter_next = '0; // Reset for the next bit
                    
                    if (bits_read == MESSAGE_SIZE - 1) begin
                        state_next = s_stop; 
                    end else begin
                        bits_read_next = bits_read + 1'b1; 
                    end
                end
            end

            s_stop: begin
                tick_counter_next = tick_counter + 1'b1; 
                if (tick_counter == OVERSAMPLE_RATE - 1) begin
                    state_next = s_idle; 
                    tick_counter_next = '0;
                    
                    // Hardware frame verification
                    if (rx == 1'b1) begin
                        valid_next = 1'b1;
                    end else begin
                        error_next = 1'b1;
                    end
                end
            end

            default: begin 
                state_next = s_idle;
            end    
        endcase
    end

    // FSM Sequential Logic (Gated by Baud Tick Enable)
    always_ff @ (posedge clk) begin
        if (~rst_n) begin
            state        <= s_idle; 
            bits_read    <= '0; 
            tick_counter <= '0;
            data_buffer  <= '0;
            valid        <= 1'b0;
            error        <= 1'b0;
        end else if (baud_tick) begin  
            state        <= state_next;  
            bits_read    <= bits_read_next; 
            tick_counter <= tick_counter_next;
            data_buffer  <= data_buffer_next;
            valid        <= valid_next;
            error        <= error_next;
        end 
    end

endmodule

*/