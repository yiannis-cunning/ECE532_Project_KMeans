`timescale 1ns / 1ps

module controlling_module_2_mode #(
    parameter IMAGE_WIDTH  = 1280,  //  width
    parameter IMAGE_HEIGHT = 720,   //  height
    parameter MIN_BOX_SIZE = 5,  
    parameter MAX_BOX_SIZE = 300,   //  max box size
    parameter INIT_BOX_SIZE = 50    // start with a larger box size initially 
)
(
    input clk,               // fpga clk ~100MHz
    input rst,               // reset button
    input mode_sel,          // move/resize mode selection switch sw[0]
    input speed_sel,         // fast/slow speed selection switch sw[1]
    
    // movement buttons
   input wire [4:0] butns,
    
    // output coordinates, 12 bits to support larger images
    output wire [15:0] x1_o, 
    output wire [15:0] x2_o, 
    output wire [15:0] y1_o, 
    output wire [15:0] y2_o,
    
    // LED outputs for mode selection indication
    output reg [1:0] leds
);

    reg [11:0] x1;
    reg [11:0] x2;
    reg [11:0] y1;
    reg [11:0] y2;
    
    assign x1_o = {4'b0, x1};
    assign x2_o = {4'b0, x2};
    assign y1_o = {4'b0, y1};
    assign y2_o = {4'b0, y2};
    
    wire button_left = butns[0];
    wire button_right = butns[1];
    wire button_up = butns[2];
    wire button_down = butns[3];
    
    wire button_bigger = butns[2];
    wire button_smaller = butns[3];
    
    

    // Internal registers to delay button inputs by one cycle
    reg left_delay, right_delay, up_delay, down_delay;
    reg bigger_delay, smaller_delay;
    reg [23:0] move_counter;  // Large enough for a delay (24 bits â†' ~167ms at 100MHz)

    // speed mode control: fast mode (10ms), slow mode (50ms)
    wire [23:0] speed_delay;
    assign speed_delay = (speed_sel) ? 24'd5000000 : 24'd1000000;
    
    // rising edge detection for each button
    // each button input has a 1-cycle delay register (*_delay), rising edge is detected using
    always @(posedge clk) begin
        left_delay    <= button_left;
        right_delay   <= button_right;
        up_delay      <= button_up;
        down_delay    <= button_down;
        bigger_delay  <= button_bigger;
        smaller_delay <= button_smaller;
    end

    // this is the initial Position, not synthesizable
    initial begin
        x1 = 0; 
        y1 = 0;
        x2 = x1 + INIT_BOX_SIZE - 1; // 49, 0x31
        y2 = y1 + INIT_BOX_SIZE - 1; // 49, 0x31
        move_counter = 0;
        leds = 2'b01; // Default LED state: Move Mode
    end

//    always @(posedge clk) begin
//        if (move_counter > 0)
//        move_counter <= move_counter - 1;
//    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // if rst asserts to high, the box will reset to its initial size and position
            x1 <= 0; 
            y1 <= 0;
            x2 <= x1 + INIT_BOX_SIZE - 1;
            y2 <= y1 + INIT_BOX_SIZE - 1;
            move_counter <= 0;
            leds <= 2'b01; // Default to Move Mode
        end else if (move_counter > 0) begin
                move_counter <= move_counter - 1;
                
        end else begin        
            // set LED mode
            leds <= (mode_sel == 0) ? 2'b01 : 2'b10; // Move Mode: LED[0] ON, Resize Mode: LED[1] ON
         
            if (move_counter == 0 || (button_left & ~left_delay) || (button_right & ~right_delay) || (button_up & ~up_delay) || (button_down & ~down_delay)) begin
                
                if (mode_sel == 0) begin // **Move Mode**
                    if (button_left && x1 >= 10) begin 
                        x1 <= x1 - 10; 
                        x2 <= x2 - 10; 
                        move_counter <= speed_delay; // ~10ms delay
                    end
                    if (button_right && x2 < IMAGE_WIDTH - 10) begin 
                        x1 <= x1 + 10; 
                        x2 <= x2 + 10; 
                        move_counter <= speed_delay;
                    end
                    if (button_up && y1 >= 10) begin 
                        y1 <= y1 - 10; 
                        y2 <= y2 - 10; 
                        move_counter <= speed_delay;
                    end
                    if (button_down && y2 < IMAGE_HEIGHT - 10) begin 
                        y1 <= y1 + 10; 
                        y2 <= y2 + 10; 
                        move_counter <= speed_delay;
                    end
                end else begin                          // **Resize Mode**
                    if (button_bigger && (x2 - x1 + 1 < MAX_BOX_SIZE) && x1 > 0 && y1 > 0 && x2 < IMAGE_WIDTH - 1 && y2 < IMAGE_HEIGHT - 1) begin
                        x1 <= x1 - 10; 
                        y1 <= y1 - 10;
                        x2 <= x2 + 10; 
                        y2 <= y2 + 10;
                        move_counter <= speed_delay;
                    end
                    if (button_smaller && (x2 - x1 + 1 > MIN_BOX_SIZE + 10)) begin
                        x1 <= x1 + 10; 
                        y1 <= y1 + 10;
                        x2 <= x2 - 10; 
                        y2 <= y2 - 10;
                        move_counter <= speed_delay;
                    end
                end
            end
        end
    end
endmodule