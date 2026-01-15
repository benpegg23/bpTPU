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
) skew_buffer_dut (.*);     // autoconnect

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
            $display("TESTCASE 1 INDEX %d PASSED: Output is correct and appears at the right time :)", i);
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
    in_data[7] <= 0;
    repeat (5) @ (posedge clk);
    // check output before 
    #1;
    if (out_data[7] != 0) $error("TEST 2 FAILED: Data arrived too early. Expected 0, got %d", out_data[7]);
    @ (posedge clk); 
    #1;
    // check if data appears on time
    if (out_data[7] != 6) begin
        $error("TEST 2 FAILED: Data did not arrive. Expected 6, got %d", out_data[7]);
    end else begin
        $display("TEST 2 PASSED: Data arrived on time :D");
    end
    @ (posedge clk);
    #1;
    // check output after
    if (out_data[7] != 0) $error("TEST 2 FAILED: Data arrived too late. Expected 0, got %d", out_data[7]);
    
    repeat (10) @ (posedge clk);
    
    // ===== TEST 3: SIMPLE LOAD ===== //
    // check that data stops shifting when load stops
    // disable load, try to drive an input and ensure that our output stays the same
    
    // clear stuff
    load_data <= 1;
    for (i = 0; i < N; i++) in_data[i] <= 0;
    repeat (N+2) @ (posedge clk);

    load_data <= 0;

    // Drive inputs with a value (67)
    // Row 0 changes cuz its a wire
    // Check row 1 (has a shift reg)
    for (i = 0; i < N; i++) in_data[i] <= 8'd67;
    
    repeat (10) @ (posedge clk); // Wait a few cycles
    
    #1;
    // Check Row 1, it should still be 0 (from the clear step) because load is off.
    if (out_data[1] != 0) begin
        $error("TEST 3 FAILED: Load Disable ignored. Row 1 updated to %d when load_data was 0.", out_data[1]);
    end else begin
        $display("TEST 3 PASSED: load_data logic works correctly (Data blocked) :)");
    end
    
    
    repeat (10) @ (posedge clk);
    
    // ===== TEST 4: LOAD PAUSE ===== // 
    // check that data can pause and resume loading using the load signal
    // start loading data, disable load, wait, then enable it again
    // ensure that the data in the buffer when load was disabled is still there
    // check that the output arrives at the expected time
    
    // clear stuff
    load_data <= 1;
    for (i = 0; i < N; i++) in_data[i] <= 0;
    repeat (N+2) @ (posedge clk);

    // pulse 41 into row 7
    in_data[7] <= 8'd41;
    @ (posedge clk);
    in_data[7] <= 0; // End pulse
    
    // Wait 2 cycles
    // 41 moving inside shift regs
    repeat (2) @ (posedge clk);
    
    // pause for 5 cycles
    load_data <= 0;
    repeat (5) @ (posedge clk);
    
    // resume
    load_data <= 1;
    
    // wait for remaining latency.
    repeat (4) @ (posedge clk);
    
    #1;
    if (out_data[7] != 41) begin
        $error("TEST 4 FAILED: Pause/Resume logic. Expected 41, got %d.", out_data[7]);
    end else begin
        $display("TEST 4 PASSED: Data correctly paused and resumed :)");
    end

    repeat (10) @ (posedge clk);
    
    // ===== TEST 5: RESET ===== //
    // fill buffer then reset
    // ensure all outputs are 0
    // ensure outputs stay 0 even after reset is released (until new data is loaded)

    // fill buffer
    load_data <= 1;
    for (i = 0; i < N; i++) in_data[i] <= 8'd21;
    repeat (10) @ (posedge clk); 
    
    rst_n <= 0;
    
    #1;
    
    // make sure outputs are all zero
    // output 0 is just a wire from input 0, so we don't test that
    // output 0 accounted for in the control fsm
    // during idle/reset state (idk name rn, fsm not built yet), drive 0s on all inputs
    // ouput 0 isn't connected to a shift reg so we don't have to worry about shifting out unintended data
    for (i = 1; i < N; i++) begin
        if (out_data[i] != 0) begin
            $error("TEST 5 INDEX %d FAILED: Reset did not clear the registers. Expected 0, Got %h", i, out_data[N-1]);
        end else begin
            $display("TEST 5 INDEX %d PASSED: Registers cleared immediately :)", i);
        end
    end

    // release reset and fill buffer with new data
    repeat (10) @ (posedge clk);
    rst_n <= 1;
    for (i = 0; i < N; i++) in_data[i] <= 8'd11; 
    
    repeat (N+2) @ (posedge clk);
    if (out_data[N-1] != 8'd11) begin
        $error("TEST 5 FAILED: Inputs not buffered to output after reset release. Expected 11, got %d", out_data[N-1]);
    end else begin
        $display("TEST 5 PASSED: Can load new data after releasing reset :)");
    end 
    
    repeat (10) @ (posedge clk);
        
    $finish;
    
end





endmodule
