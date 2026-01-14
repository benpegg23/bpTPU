`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/13/2026 05:45:17 PM
// Design Name: 
// Module Name: pe_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module pe_tb();

parameter int INPUT_WIDTH = 8;
parameter int ACC_WIDTH = 32; 

logic clk;
logic rst_n;
logic load_weight;
logic signed [INPUT_WIDTH-1:0] in_h;
logic signed [INPUT_WIDTH-1:0] out_h;
logic signed [ACC_WIDTH-1:0] in_v;
logic signed [ACC_WIDTH-1:0] out_v;

pe # (
    .INPUT_WIDTH(INPUT_WIDTH),
    .ACC_WIDTH(ACC_WIDTH)
) pe_dut (.*);  // autoconnect

initial begin: CLOCK_INITIALIZATION
    clk = 1'b1;
end

always begin: CLOCK_GENERATION
    #5 clk = ~clk;
end

initial begin: TEST_VECTORS
    rst_n <= 0;
    load_weight <= 0;
    in_h <= 0;
    in_v <= 0;
    repeat (5) @ (posedge clk);     // wait 5 clock cycles
    rst_n <= 1;
    repeat (5) @ (posedge clk);
    // ===== TEST 1: Loading Weights ===== // 
    // load weight = 5, ensure weight is passed to out_v
    load_weight <= 1; 
    in_v <= 32'd5;
    @ (posedge clk); 
    #1;   
    if (out_v != 32'd5) begin
        $error("TEST 1 FAILED: Loading weight passthrough. Expected 5, got %d.", out_v);
    end else begin
        $display("TEST 1 PASSED: Loading weight passthrough :)");
    end
    
    repeat (25) @ (posedge clk);
    // ===== TEST 2: Reset ===== // 
    // load weight = 6, activation = 7, disable load_weight, then activate reset
    // both outputs should be 0
    rst_n <= 0; 
    in_v <= 32'd6;
    in_h <= 32'd7;
    load_weight <= 0; 
    @ (posedge clk); 
    #1;
    if (out_v != 0 && out_h != 0) begin
        $error("TEST 2 FAILED: rst_n doesn't reset vertical and horizontal output. Expected out_v = 6 and out_h = 7, got out_v = %d and out_h = %d.", out_v, out_h);
    end else if (out_v != 0) begin
        $error("TEST 2 FAILED: rst_n resets horizontal but not vertical output. Expected out_v = 6 and out_h = 7, got out_v = %d and out_h = %d.", out_v, out_h);
    end else if (out_h != 0) begin
        $error("TEST 2 FAILED: rst_n resets vertical but not horizontal output. Expected out_v = 6 and out_h = 7, got out_v = %d and out_h = %d.", out_v, out_h);
    end else begin
        $display("TEST 2 PASSED: rst_n resets correctly :)");
    end
    
    repeat (25) @ (posedge clk);
    // ===== TEST 3: Positive Horizontal Propogation ===== // 
    // load activation = 3, horizontal output should be 3
    rst_n <= 1; 
    @ (posedge clk);
    in_h <= 32'd3; 
    load_weight <= 0;
    @ (posedge clk);
    #1;
    if (out_h != 3) begin
        $error("TEST 3 FAILED: Positive horizontal inputs aren't propgated to horizontal output. Expected 3, got %d.", out_h);
    end else begin
        $display("TEST 3 PASSED: Positive horizontal inputs propgated to horizontal outputs :)");
    end
    
    repeat (25) @ (posedge clk);
    // ===== TEST 4: Negative Horizontal Propogation ===== // 
    // load activation = -3, horizontal output should be -3
    rst_n <= 1; 
    @ (posedge clk);
    in_h <= -32'sd3; 
    load_weight <= 0;
    @ (posedge clk);
    #1;
    if (out_h != -3) begin
        $error("TEST 3 FAILED: Negative horizontal inputs aren't propgated to horizontal output. Expected -3, got %d.", out_h);
    end else begin
        $display("TEST 3 PASSED: Negative horizontal inputs propgated to horizontal outputs :)");
    end
    
    repeat (25) @ (posedge clk);
    // ===== TEST 5: Positive Partial Sum w/ Positive Inputs ===== // 
    // activation = 6, weight = 7
    // Step 1: Load Weight 7
    load_weight <= 1;
    in_v <= 32'd7;
    @ (posedge clk);
    
    // Step 2: Compute (Switch load off, feed activation)
    load_weight <= 0;
    in_h <= 32'd6;
    in_v <= 0;      // No partial sum from above
    @ (posedge clk);
    #1;
    if (out_v != 42) begin
        $error("TEST 5 FAILED: Positive Math. Expected 42, got %d.", out_v);
    end else begin
        $display("TEST 5 PASSED: Positive Math (6 * 7 = 42) :)");
    end

    repeat (25) @ (posedge clk);
    // ===== TEST 6: Positive Partial Sum w/ Negative Inputs ===== // 
    // activation = -6, weight = -7
    // Step 1: Load Weight -7
    load_weight <= 1;
    in_v <= -32'sd7;
    @ (posedge clk);
    
    // Step 2: Compute
    load_weight <= 0;
    in_h <= -32'sd6;
    in_v <= 0;
    @ (posedge clk);
    #1;
    if (out_v != 42) begin
        $error("TEST 6 FAILED: Negative * Negative. Expected 42, got %d.", out_v);
    end else begin
        $display("TEST 6 PASSED: Negative * Negative (-6 * -7 = 42) :)");
    end

    repeat (25) @ (posedge clk);
    // ===== TEST 7: Negative Partial Sum w/ Mixed Inputs ===== // 
    // activation = -6, weight = 7
    load_weight <= 1;
    in_v <= 32'd7;
    @ (posedge clk);
    
    load_weight <= 0;
    in_h <= -32'sd6;
    in_v <= 0;
    @ (posedge clk);
    #1;
    if (out_v != -32'sd42) begin
        $error("TEST 7 FAILED: Negative * Positive. Expected -42, got %d.", out_v);
    end else begin
        $display("TEST 7 PASSED: Negative * Positive (-6 * 7 = -42) :)");
    end

    repeat (25) @ (posedge clk);
    // ===== TEST 8: Negative Partial Sum w/ Mixed Inputs ===== // 
    // activation = 6, weight = -7
    load_weight <= 1;
    in_v <= -32'sd7;
    @ (posedge clk);
    
    load_weight <= 0;
    in_h <= 32'd6;
    in_v <= 0;
    @ (posedge clk);
    #1;
    if (out_v != -32'sd42) begin
        $error("TEST 8 FAILED: Positive * Negative. Expected -42, got %d.", out_v);
    end else begin
        $display("TEST 8 PASSED: Positive * Negative (6 * -7 = -42) :)");
    end

    repeat (25) @ (posedge clk);
    // ===== TEST 9: Weight Stationary ===== // 
    // 1. Load Weight = 10
    // 2. Do a calculation with in_v = 55 (Total garbage on the line)
    // 3. Do another calculation. If weight is still 10, it passed. If it grabbed 55, it failed.
    
    load_weight <= 1;
    in_v <= 32'd10;
    @ (posedge clk);
    
    // Cycle 1: Feed noise into in_v, but load_weight is OFF. Weight should ignore this.
    load_weight <= 0;
    in_h <= 32'd0;
    in_v <= 32'd55; 
    @ (posedge clk);
    
    // Cycle 2: Real test. Activation = 2. 
    // If weight is still 10: Result = 0 + (2 * 10) = 20.
    // If weight broke and became 55: Result = 0 + (2 * 55) = 110.
    in_h <= 32'd2;
    in_v <= 0;
    @ (posedge clk);
    #1;
    if (out_v != 20) begin
        $error("TEST 9 FAILED: Weight Stationary Check. Expected 20, got %d. (Did the weight update when it shouldn't have?)", out_v);
    end else begin
        $display("TEST 9 PASSED: Weight remained stationary :)");
    end
    
    $finish;
    
end

endmodule
