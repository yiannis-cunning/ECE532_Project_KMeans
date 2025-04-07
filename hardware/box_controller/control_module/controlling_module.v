`timescale 1ns / 1ps

module controlling_module #(
    parameter IMAGE_WIDTH  = 1080,  //  width
    parameter IMAGE_HEIGHT = 1920,  //  height
    parameter MIN_BOX_SIZE = 5,  
    parameter MAX_BOX_SIZE = 300,  //  max box size
    parameter INIT_BOX_SIZE = 50   // start with a larger box size initially 
)
(
    input clk,               // fpga clk ~100MHz
    input rst,               // reset button
    input mode_sel,          // mode selection switch, sw[0]
    
    // movement buttons
    input button_left, 
    input button_right, 
    input button_up, 
    input button_down, 
    input button_bigger,
    input button_smaller,   
    
    // output coordinates, 12 bits to support larger images
    output reg [11:0] x1, 
    output reg [11:0] x2, 
    output reg [11:0] y1, 
    output reg [11:0] y2 
);

    // Internal registers to delay button inputs by one cycle
    reg left_delay, right_delay, up_delay, down_delay;
    reg bigger_delay, smaller_delay;
    reg [23:0] move_counter;  // Large enough for a delay (24 bits → ~167ms at 100MHz)


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
    end

    always @(posedge clk) begin
        if (move_counter > 0)
        move_counter <= move_counter - 1;
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // if rst asserts to high, the box will reset to its initial size and position
            x1 <= 0; 
            y1 <= 0;
            x2 <= x1 + INIT_BOX_SIZE - 1;
            y2 <= y1 + INIT_BOX_SIZE - 1;
            move_counter <= 0;
        end 
        else begin
            if (mode_sel == 0) begin // **SHIFT THE BOX MODE**
                if (button_left & ~left_delay && x1 > 0) begin 
                x1 <= x1 - 1; x2 <= x2 - 1; 
                move_counter <= 24'd5000000;  // ~50ms delay
                end
                if (button_right & ~right_delay && x2 < IMAGE_WIDTH - 1) begin 
                x1 <= x1 + 1; x2 <= x2 + 1; 
                move_counter <= 24'd5000000;  // ~50ms delay
                end
                if (button_up & ~up_delay && y1 > 0) begin 
                y1 <= y1 - 1; y2 <= y2 - 1; 
                move_counter <= 24'd5000000;  // ~50ms delay
                end
                if (button_down & ~down_delay && y2 < IMAGE_HEIGHT - 1) begin 
                y1 <= y1 + 1; y2 <= y2 + 1; 
                move_counter <= 24'd5000000;  // ~50ms delay
                end
            end 
            else begin // **RESIZE THE BOX MODE**
                if (button_bigger & ~bigger_delay && (x2 - x1 + 1 < MAX_BOX_SIZE) && (x1 > 0) && (y1 > 0) && (x2 < IMAGE_WIDTH - 1) && (y2 < IMAGE_HEIGHT - 1)) begin
                    x1 <= x1 - 1; y1 <= y1 - 1;
                    x2 <= x2 + 1; y2 <= y2 + 1;
                    move_counter <= 24'd10000000; // ~100ms delay
                end
                if (button_smaller & ~smaller_delay && (x2 - x1 + 1 > MIN_BOX_SIZE)) begin
                    x1 <= x1 + 1; y1 <= y1 + 1;
                    x2 <= x2 - 1; y2 <= y2 - 1;
                    move_counter <= 24'd10000000; // ~100ms delay
                end
            end
        end
    end
endmodule
