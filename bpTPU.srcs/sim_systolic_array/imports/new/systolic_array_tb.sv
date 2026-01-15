`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Testbench for Systolic Array
//////////////////////////////////////////////////////////////////////////////////

module systolic_array_tb();

parameter int N = 8;
parameter int INPUT_WIDTH = 8;
parameter int ACC_WIDTH = 32; 

logic clk;
logic rst_n;
logic load_weight;

// Arrays for Inputs/Outputs
logic signed [INPUT_WIDTH-1:0] in_h [N-1:0];
logic signed [ACC_WIDTH-1:0]   in_v [N-1:0];
logic signed [ACC_WIDTH-1:0]   out_v [N-1:0];

// Instantiate the Array
systolic_array # (
    .N(N),
    .INPUT_WIDTH(INPUT_WIDTH),
    .ACC_WIDTH(ACC_WIDTH)
) systoloic_array_dut (.*); // autoconnect

initial begin: CLOCK_INITIALIZATION
    clk = 1'b1;
end

always begin: CLOCK_GENERATION
    #5 clk = ~clk;
end

integer i, j;
initial begin: TEST_VECTORS
    rst_n <= 0;
    load_weight <= 0;
    // array initialization
    for (i = 0; i < N; i++) begin
        in_h[i] <= 0;
        in_v[i] <= 0;
    end

    repeat (5) @ (posedge clk);
    rst_n <= 1;
    repeat (5) @ (posedge clk);

    // ===== TEST 1: Loading Weights ===== // 
    // load a weight of 1 into every PE
    // push the weights in for N cycles
    // first value pushed ends up at the bottom (row N-1)
    // last value pushed ends up at the top (row 0).
    
    $display("Loading Weights...");
    load_weight <= 1;
    
    for (i = 0; i < N; i++) begin
        for (j = 0; j < N; j++) in_v[j] <= 32'd1;
        @ (posedge clk);
    end
    
    repeat (10) @ (posedge clk);
    
    load_weight <= 0;
    
    for (j = 0; j < N; j++) in_v[j] <= 0;
    
    @ (posedge clk);
    $display("TEST 1 \"PASSED\": Weights Loaded (check waveform for incorrect loading if subsequent tests fail)");


    // ===== TEST 2: Basic Computation Flow ===== // 
    // inject 5 into in_h[0]
    // 
    // Expected Behavior:
    // 1. PE[0][0] sees in_h=5, weight=1. Result = 5
    // 2. 5 travels DOWN to PE[1][0].
    // 3. PE[1][0] sees in_h=0 (since we only drove Row 0), weight=1. Result = 0.
    // 4. It adds the '5' from above. Sum = 5.
    // 5. This repeats until it falls out of the bottom of Col 0.
    //
    // Latency Calculation:
    // It takes N cycles for the partial sum to travel from Row 0 to Output.
    
    in_h[0] <= 8'd5;
    
    // Wait for propagation (N cycles for depth + buffer)
    repeat (N + 2) @ (posedge clk); 
    
    #1; // Delay for stable read
    
    // Check Output of Column 0
    if (out_v[0] != 32'd5) begin
        $error("TEST 2 FAILED: Expected 5 at out_v[0], got %d.", out_v[0]);
    end else begin
        $display("TEST 2 PASSED: Vertical Propagation Correct. Output is 5 :)");
    end
    
    // check other columns
    if (out_v[1] != 32'd5) $error("TEST 2 FAILED: Column 1 propagated incorrect value. Expected 5, got %d.", out_v[1]);

    // ===== TEST 3: Horizontal Flow ===== //
    // pulse a 2 into input
    
    in_h[0] <= 0;
    repeat (5) @ (posedge clk);
    in_h[0] <= 8'd2;
    @ (posedge clk);
    // pulse
    in_h[0] <= 0;
    
    // 2 takes 15 cycles from the time it's pulsed to reach output 
    // 7 cycles to reach col 7
    // 8 cycles to reach output (technically row 8)
    // (rows/cols are zero-indexed)
    
    repeat (14) @ (posedge clk);
    
    #1;
    if (out_v[N-1] != 32'd2) begin
        $error("TEST 3 FAILED: Horizontal Propagation. Expected 2 at last column, got %d.", out_v[N-1]);
        $display("Last column: %d, %d, %d, %d, %d, %d, %d, %d", out_v[N-1], out_v[N-2], out_v[N-3], out_v[N-4], out_v[N-5], out_v[N-6], out_v[N-7], out_v[N-8]);
    end else begin
        $display("TEST 3 PASSED: Horizontal Propagation Correct (Input reached last column) :)");
    end

    repeat (5) @ (posedge clk);
    
    // ===== TEST 4: Skew ===== //
    // Add skew manually so we can test systolic array without skew buffers
    // Pulse a 6 input at in_h[0]
    // Pulse another 7 input at in_h[1] one clock cycle after
    // output of col 0 should be (6*1)+(7*1) = 13
    
    // reset inputs
    for (i = 0; i < N; i++) in_h[i] <= 0;
    repeat (5) @ (posedge clk);
    in_h[0] <= 8'd6; 
    @ (posedge clk);
    in_h[0] <= 0;
    in_h[1] <= 8'd7;
    @ (posedge clk);
    in_h[1] <= 0;
    // output at out_v[N-1] 15 cycles after first input is pulsed
    repeat (14) @ (posedge clk);
    
    if (out_v[N-1] != 8'd13) begin
        $error("TEST 4 FAILED: Wrong product, expected 13, got %d", out_v[N-1]);
        $display("Last column: %d, %d, %d, %d, %d, %d, %d, %d", out_v[N-1], out_v[N-2], out_v[N-3], out_v[N-4], out_v[N-5], out_v[N-6], out_v[N-7], out_v[N-8]);
    end else begin
        $display("TEST 4 PASSED: Skew Test :)");
    end

    repeat (5) @ (posedge clk);

    $finish;
    
end

endmodule