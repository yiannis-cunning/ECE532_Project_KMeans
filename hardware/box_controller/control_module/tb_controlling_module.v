`timescale 1ns / 1ps

module tb_controlling_module;

    parameter IMAGE_WIDTH  = 1080;  // Image width for the test
    parameter IMAGE_HEIGHT = 1920;  // Image height for the test
    
    // signals
    reg clk, rst, mode_sel;
    reg left, right, up, down;
    reg bigger, smaller;
    wire [10:0] x1, y1, x2, y2; // supports larger images

    // Instantiate module
    controlling_module dut (
        .clk(clk), 
        .rst(rst), 
        .mode_sel(mode_sel),
        .button_left(left), 
        .button_right(right), 
        .button_up(up), 
        .button_down(down),
        .button_bigger(bigger), 
        .button_smaller(smaller),
        .x1(x1), 
        .y1(y1), 
        .x2(x2), 
        .y2(y2)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        // Initialize signals
        clk = 0; rst = 1; mode_sel = 0;
        left = 0; right = 0; up = 0; down = 0;
        bigger = 0; smaller = 0;

        // reset asserted
        #100 rst = 0;

        // **Test 1: Move Right (Simulate Hold for ~100ms)**
        #1_000_000 right = 1;  // Pressed for ~1ms
        #50_000_000 right = 0; // Released after 50ms

        // **Test 2: Move Down (Simulate Hold for ~100ms)**
        #1_000_000 down = 1;
        #50_000_000 down = 0;

        // **Test 3: Move Left (Single Press)**
        #1_000_000 left = 1;
        #50_000_000 left = 0;

        // **Test 4: Move Up (Hold for Multiple Moves)**
        #1_000_000 up = 1;
        #150_000_000 up = 0; // Holding for ~150ms (multiple moves)

        // **Switch to Resize Mode**
        #10_000_000 mode_sel = 1;

        // **Test 5: Increase Box Size**
        #1_000_000 bigger = 1;
        #50_000_000 bigger = 0;

        // **Test 6: Decrease Box Size (Hold for Multiple Steps)**
        #1_000_000 smaller = 1;
        #150_000_000 smaller = 0; // Holding to shrink multiple times

        // **Test 7: Reset**
        #10_000_000 rst = 1;
        #10_000_000 rst = 0;

        // End simulation
        #50_000_000 $stop;
    end
endmodule