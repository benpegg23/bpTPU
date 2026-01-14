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
) dut (.*); // autoconnect

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
        // Feed '1' into every column
        for (j = 0; j < N; j++) in_v[j] <= 32'd1;
        @ (posedge clk);
    end
    
    // Stop loading
    load_weight <= 0;
    // Clear the vertical inputs so they don't mess up the math later (set partial sums to 0)
    for (j = 0; j < N; j++) in_v[j] <= 0;
    
    @ (posedge clk);
    $display("TEST 1 PASSED: Weights Loaded (Assumed, verified by math below).");


    // ===== TEST 2: Basic Computation Flow ===== // 
    // We will inject the value '5' into Row 0, Column 0.
    // 
    // Expected Behavior:
    // 1. PE[0][0] sees in_h=5, weight=1. Result = 5.
    // 2. This '5' travels DOWN to PE[1][0].
    // 3. PE[1][0] sees in_h=0 (since we only drove Row 0), weight=1. Result = 0.
    // 4. It adds the '5' from above. Sum = 5.
    // 5. This repeats until it falls out of the bottom of Col 0.
    //
    // Latency Calculation:
    // It takes N cycles for the partial sum to travel from Row 0 to Output.
    
    $display("Injecting Activation '5' into Row 0...");
    in_h[0] <= 8'd5;
    
    // Wait for propagation (N cycles for depth + buffer)
    repeat (N + 2) @ (posedge clk); 
    
    #1; // Delay for stable read
    
    // Check Output of Column 0
    if (out_v[0] != 32'd5) begin
        $error("TEST 2 FAILED: Expected 5 at out_v[0], got %d. (Did the signal reach the bottom?)", out_v[0]);
    end else begin
        $display("TEST 2 PASSED: Vertical Propagation Correct. Output is 5 :)");
    end
    
    // Verify other columns are clean (should be 0)
    if (out_v[1] != 0) begin
        $error("TEST 2 FAILED: Leakage! out_v[1] should be 0, got %d.", out_v[1]);
    end

    // ===== TEST 3: Horizontal Flow ===== //
    // If we keep in_h[0] = 5 held high, it should eventually reach Column 1, then Column 2...
    // Let's reset inputs first.
    in_h[0] <= 0;
    repeat (5) @ (posedge clk);
    
    // Inject '2' into Row 0.
    in_h[0] <= 8'd2;
    // Wait 1 cycle. This moves the '2' from PE[0][0] to PE[0][1].
    @ (posedge clk);
    // Stop injecting (make it a pulse)
    in_h[0] <= 0;
    
    // The '2' is now inside the array moving right.
    // It started at Col 0 (Cycle 0).
    // It reaches Col 1 at Cycle 1.
    // It reaches Col 7 at Cycle 7.
    //
    // Once it hits Col 7 (Row 0), it produces a result.
    // That result takes 8 cycles (N) to fall down Col 7 to the output.
    // Total wait needed: ~16 cycles.
    
    repeat (20) @ (posedge clk);
    
    #1;
    if (out_v[N-1] != 32'd2) begin
        // Note: out_v[N-1] is the output of the last column (Col 7)
        $error("TEST 3 FAILED: Horizontal Propagation. Expected 2 at last column, got %d.", out_v[N-1]);
    end else begin
        $display("TEST 3 PASSED: Horizontal Propagation Correct (Input reached last column) :)");
    end

    $finish;
    
end

endmodule