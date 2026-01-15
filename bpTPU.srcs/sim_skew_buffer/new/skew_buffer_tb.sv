`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// testbench for skew buffer
//////////////////////////////////////////////////////////////////////////////////


module skew_buffer_tb();

parameter int INPUT_WIDTH = 8;
parameter int N = 8;
logic clk;
logic rst_n; 
logic load_data;
logic signed [INPUT_WIDTH-1:0] in_data [N-1:0];
logic signed [INPUT_WIDTH-1:0] out_data [N-1:0]; 

skew_buffer # (
    .INPUT_WIDTH(INPUT_WIDTH),
    .N(N)
) (.*);     // autoconnect

initial begin: CLOCK_INITIALIZATION
    clk = 1'b1;
end

always begin: CLOCK_GENERATION
    #5 clk = ~clk;
end

integer i;
initial begin: TEST_VECTORS
    rst_n <= 1; 
    load_data <= 1;
    @ (posedge clk);
    rst_n <= 0; 
    @ (posedge clk);
    rst_n <= 1; 
    
    // ===== TESTCASE 1: All 5s ===== //
    // input a bunch of 5s and make sure they appear at the right time
    @ (posedge clk);
    // load entire input vector with 5s
    for (i = 0; i < N; i++) begin
        in_data[i] <= 8'd5;
    end
    @ (posedge clk);
    for (i = 0; i < N; i++) begin
        if (out_data[i] != 5) begin     // check for correct output at expected spot
            $error("TESTCASE 1 FAILED: Output didn't appear at the expected time. Expected 5, got %d", out_data[i]);
        end else if (((i+1)<N) && (out_data[i+1] != 0)) begin        // ensure that output didn't appear too early
            $error("TESTCASE 1 FAILED: Output appeared too early. Expected 0, got %d", out_data[i]);
        end else begin
            $display("TESTCASE 1.%d PASSED: Output is correct and appears at the right  :)", i);
        end
        @ (posedge clk);     // clock cycle delay to keep timing correct
    end  
    
    repeat (10) @ (posedge clk);
    // ===== TESTCASE 2: Pulse ===== // 
    // drive zeroes then pulse a 6 in the 7th index
    // ensure the 6 appears 7 clock cycles later
    
    // load entire input vector with 0s
    for (i = 0; i < N; i++) begin
        in_data[i] <= 0;
    end
    
    repeat (10) @ (posedge clk);    // wait for inputs to ripple thru buffer
    
    in_data[7] <= 6; 
    // wait for 7 cycles for output to appear
    @ (posedge clk);
    in_data[7] <= 6;
    repeat (5) @ (posedge clk);
    // check output before 
    if (out_data[7] != 0) $error("TESTCASE 2 FAILED: Data arrived too early. Expected 0, got %d", out_data[7]);
    @ (posedge clk); 
    // check if data appears on time
    if (out_data[7] != 6) $error("TESTCASE 2 FAILED: Data did not arrive. Expected 6, got %d", out_data[7]);
    // check output after
    if (out_data[7] != 0) $error("TESTCASE 2 FAILED: Data arrived too late. Expected 0, got %d", out_data[7]);
    
    repeat (10) @ (posedge clk);
    
    // ===== TEST 3: SIMPLE LOAD ===== //
    // check that data stops shifting when load stops
    // disable load, try to drive an input and ensure that our output stays the same
    
    
    // ===== TEST 4: LOAD PAUSE ===== // 
    // check that data can pause and resume loading using the load signal
    // start loading data, disable load, wait, then enable it again
    // ensure that the data in the buffer when load was disabled is still there
    // check that the output arrives at the expected time
    
end





endmodule
