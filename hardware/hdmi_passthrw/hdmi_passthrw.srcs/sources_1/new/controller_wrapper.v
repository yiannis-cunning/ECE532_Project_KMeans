`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/17/2025 02:54:17 PM
// Design Name: 
// Module Name: controller_wrapper
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


module controller_wrapper(
    input clk,               // fpga clk ~100MHz
    input wire resetn,
    
    // movement buttons input
   input wire [4:0] butns,
   input wire [7:0] swts,
   
   // SW input
   input wire [31:0] sw_topl,
   input wire [31:0] sw_botr,
    
    // output coordinates, 12 bits to support larger images
    output wire [31:0] topl_o,
    output wire [31:0] botr_o,
    
    output wire [1:0] leds
    );
    
    wire sw_override;
    wire [15:0] x1_t;
    wire [15:0] x2_t;
    wire [15:0] y1_t;
    wire [15:0] y2_t;
    wire [4:0] butns_db;
    
    
    assign sw_override = swts[3];
    assign topl_o = (sw_override) ? (sw_topl) : ( {y1_t, x1_t} );
    assign botr_o = (sw_override) ? (sw_botr) : ( {y2_t, x2_t} );
    
    debouncer I_dbc0( .clk(clk), .A(butns[0]), .B(butns_db[0])  );
    debouncer I_dbc1( .clk(clk), .A(butns[1]), .B(butns_db[1])  );
    debouncer I_dbc2( .clk(clk), .A(butns[2]), .B(butns_db[2])  );
    debouncer I_dbc3( .clk(clk), .A(butns[3]), .B(butns_db[3])  );
    debouncer I_dbc4( .clk(clk), .A(butns[4]), .B(butns_db[4])  );
    
    
    
    wire [1:0] mode = swts[7:6]; 
    
    // 0 - move mode controlling_module_2_mode_p
    // 1 - square mode
    // 2 - inc size mode
    // 3 - dec size mode
    controlling_module_2_mode_p I_controller(
        .clk(clk),
        .rst(~resetn | butns[4]), // swts[7] | 
        
        //.mode_sel(swts[6]), // move vs inc/dec
        //.speed_sel(swts[5]),
        //.resize_mode_sel(swts[7]),
        //.increase_mode_sel(swts[4]),
        
        .mode_sel( ~(mode[1:0] == 2'd0) ), // 0 = move mode, 1 = resize mode
        .speed_sel( {swts[5], swts[4] } ),
        .resize_mode_sel( (mode[1:0] == 2'd2) | (mode[1:0] == 2'd3) ),
        .increase_mode_sel(mode[1:0] == 2'd3),
        
        .butns(butns_db),
        .x1_o(x1_t),
        .x2_o(x2_t),
        .y1_o(y1_t),
        .y2_o(y2_t),        
        .leds(leds)
    );
    
endmodule



module controlling_module #(
    parameter IMAGE_WIDTH  = 1280,  //  width
    parameter IMAGE_HEIGHT = 720,  //  height
    parameter MIN_BOX_SIZE = 5,  
    parameter MAX_BOX_SIZE = 300,  //  max box size
    parameter INIT_BOX_SIZE = 50   // start with a larger box size initially 
)
(
    input clk,               // fpga clk ~100MHz
    input rst,               // reset button
    input mode_sel,          // mode selection switch, sw[0]
    
    // movement buttons
   input wire [4:0] butns,
    
    // output coordinates, 12 bits to support larger images
    output wire [15:0] x1_o, 
    output wire [15:0] x2_o, 
    output wire [15:0] y1_o, 
    output wire [15:0] y2_o 
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
    reg [23:0] move_counter;  // Large enough for a delay (24 bits â†’ ~167ms at 100MHz)


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




module debouncer(
    input clk,
    input A,
    output B
);
    parameter COUNT_MAX   = 15, // number of clock cycles the input must be stable for before the output will transition.
			  COUNT_WIDTH = 4;  // ceil(log2(COUNT_MAX)) suggested, number of bits for the delay counter.
			  
    localparam Idle = 2'b00, // state encoded as bit1: output, bit0: count enable.
               Tran = 2'b01,
               Off  = 2'b00,
               On   = 2'b10;
	
    reg [1:0] state = Off|Idle; // initialize state to zero, if input initially one, may cause an unnecessary transition on startup.
	reg [COUNT_WIDTH-1:0] count;
			   
    assign B = state[1];
	
    always@(posedge clk)
        if (state[0] == 1'b0)
            count <= 'b0; // Only count during a transition state, Idle state should prepare count to begin transition.
        else
            count <= count + 1'b1;
			
    always@(posedge clk)
        case (state)
        Off|Idle:
            if (A == 1'b1)
                state <= Off|Tran; // Begin low to high transition.
        Off|Tran:
            if (A == 0)
                state <= Off|Idle; // Input has failed to stay high, return to Off and Idle.
            else if (count == COUNT_MAX)
                state <= On|Idle; // Timer has completed, turn output on.
        On|Tran:
            if (A == 1)
                state <= On|Idle; // Input has failed to stay off, return to Off and Idle.
            else if (count == COUNT_MAX)
                state <= Off|Idle; // Timer has completed, turn output off.
        On|Idle:
            if (A == 0)
                state <= On|Tran; // Begin high to low transition.
        endcase
endmodule



module controlling_module_fast #(
    parameter IMAGE_WIDTH  = 1280,  //  width
    parameter IMAGE_HEIGHT = 720,  //  height
    parameter MIN_BOX_SIZE = 5,  
    parameter MAX_BOX_SIZE = 300,  //  max box size
    parameter INIT_BOX_SIZE = 50   // start with a larger box size initially 
)
(
    input clk,               // fpga clk ~100MHz
    input rst,               // reset button
    input mode_sel,          // mode selection switch, sw[0]
    
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
    reg [23:0] move_counter;  // Large enough for a delay (24 bits â†’ ~167ms at 100MHz)


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



    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // if rst asserts to high, the box will reset to its initial size and position
            x1 <= 0; 
            y1 <= 0;
            x2 <= x1 + INIT_BOX_SIZE - 1;
            y2 <= y1 + INIT_BOX_SIZE - 1;
            move_counter <= 0;
            leds <= 2'b01; // Default to Move Mode
        end 
        
        else begin        
        if (move_counter > 0)
            move_counter <= move_counter - 1;
        if (mode_sel == 0)
            leds <= 2'b01; // Move Mode (LED[0] ON)
        else
            leds <= 2'b10; // Resize Mode (LED[1] ON)
         
        if (move_counter == 0 || (button_left & ~left_delay) || (button_right & ~right_delay) || (button_up & ~up_delay) || (button_down & ~down_delay)) begin
            if (mode_sel == 0) begin // **Move Mode**
                if (button_left && x1 >= 10) begin 
                    x1 <= x1 - 10; 
                    x2 <= x2 - 10; 
                    move_counter <= 24'd1000000; // ~10ms delay
                end
                if (button_right && x2 < IMAGE_WIDTH - 10) begin 
                    x1 <= x1 + 10; 
                    x2 <= x2 + 10; 
                    move_counter <= 24'd1000000;
                end
                if (button_up && y1 >= 10) begin 
                    y1 <= y1 - 10; 
                    y2 <= y2 - 10; 
                    move_counter <= 24'd1000000;
                end
                if (button_down && y2 < IMAGE_HEIGHT - 10) begin 
                    y1 <= y1 + 10; 
                    y2 <= y2 + 10; 
                    move_counter <= 24'd1000000;
                end
            end else begin                          // **Resize Mode**
                if (button_bigger && (x2 - x1 + 1 < MAX_BOX_SIZE) && x1 > 0 && y1 > 0 && x2 < IMAGE_WIDTH - 1 && y2 < IMAGE_HEIGHT - 1) begin
                    x1 <= x1 - 10; 
                    y1 <= y1 - 10;
                    x2 <= x2 + 10; 
                    y2 <= y2 + 10;
                    move_counter <= 24'd1000000;
                end
                if (button_smaller && (x2 - x1 + 1 > MIN_BOX_SIZE + 10)) begin
                    x1 <= x1 + 10; 
                    y1 <= y1 + 10;
                    x2 <= x2 - 10; 
                    y2 <= y2 - 10;
                    move_counter <= 24'd1000000;
                end
            end
        end
    end
end
endmodule

module controlling_module_2_mode #(
    parameter IMAGE_WIDTH  = 1280,  //  width
    parameter IMAGE_HEIGHT = 720,   //  height
    parameter MIN_BOX_SIZE = 5,  
    parameter MAX_BOX_SIZE = 700,   //  max box size
    parameter INIT_BOX_SIZE = 50    // start with a larger box size initially 
)
(
    input clk,               // fpga clk ~100MHz
    input rst,               // reset button
    input mode_sel,          // move/resize mode selection switch sw[0]
    input speed_sel,         // fast/slow speed selection switch sw[1]
    input resize_mode_sel,   // resize mode selection sw[2], 0: uniform, 1: independent
    input increase_mode_sel,   // increase each side or decrease each side sw[3], 0: increase, 1: decrease each side
    
    // movement buttons
   input wire [3:0] butns,
    
    // output coordinates, 12 bits to support larger images
    output wire [15:0] x1_o, 
    output wire [15:0] x2_o, 
    output wire [15:0] y1_o, 
    output wire [15:0] y2_o,
    
    // LED outputs for mode selection indication
    output reg [2:0] leds // 4 LEDs leds[3:0] for different modes: 
    // 4'b0001 Move Mode, 4'b0010 uniform resize mode, 4'b0100 independent resize mode, 4'b1000 reserved
);

    reg [11:0] x1;
    reg [11:0] x2;
    reg [11:0] y1;
    reg [11:0] y2;
    
    assign x1_o = {4'b0, x1};
    assign x2_o = {4'b0, x2};
    assign y1_o = {4'b0, y1};
    assign y2_o = {4'b0, y2};
    
    // movement buttons
    wire button_left = butns[0];
    wire button_right = butns[1];
    wire button_up = butns[2];
    wire button_down = butns[3];
    
    // uniform resize buttons
    wire button_bigger = butns[2];
    wire button_smaller = butns[3];
    
    // independent resize buttons, adjusts each edge separately
    wire button_left_resize   = butns[0]; // left edge
    wire button_right_resize  = butns[1]; // right edge
    wire button_top_resize    = butns[2]; // top edge
    wire button_bottom_resize = butns[3]; // bottom edge

    // Internal registers to delay button inputs by one cycle
    reg left_delay, right_delay, up_delay, down_delay;
    reg bigger_delay, smaller_delay;
    reg left_resize_delay, right_resize_delay, top_resize_delay, bottom_resize_delay;
    reg [23:0] move_counter;  // Large enough for a delay (24 bits â†' ~167ms at 100MHz)

    // speed mode control: fast mode (10ms), slow mode (50ms)
    wire [23:0] speed_delay;
    assign speed_delay = (speed_sel) ? 24'd5000000 : 24'd1000000;
    
    // rising edge detection for each button
    // each button input has a delay register
    always @(posedge clk) begin
        left_delay    <= button_left;
        right_delay   <= button_right;
        up_delay      <= button_up;
        down_delay    <= button_down;
        bigger_delay  <= button_bigger;
        smaller_delay <= button_smaller;
        left_resize_delay   <= button_left_resize;
        right_resize_delay  <= button_right_resize;
        top_resize_delay    <= button_top_resize;
        bottom_resize_delay <= button_bottom_resize;
    end

    // this is the initial Position, not synthesizable
//    initial begin
//       x1 = 0; 
//        y1 = 0;
//        x2 = x1 + INIT_BOX_SIZE - 1; // 49, 0x31
//        y2 = y1 + INIT_BOX_SIZE - 1; // 49, 0x31
//        move_counter = 0;
//        leds = 3'b001; // Default LED state: Move Mode
//    end

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
            leds <= 3'b001; // default: Move Mode
        end 
        
        else if (move_counter > 0) begin
                move_counter <= move_counter - 1;
        end 
        
        else begin        
            
            // Set LEDs based on mode
            if (mode_sel == 0) begin
                leds <= 3'b001; // move mode, LED0 ON
            end 
            else if (mode_sel ==1 && resize_mode_sel == 0) begin
                leds <= 3'b010; // uniform resize mode, LED1 ON
            end 
            else if (mode_sel == 1 && resize_mode_sel == 1) begin
                leds <= 3'b100; // independent resize mode, LED2 ON
            end 
            else begin
                leds <= 3'b000; // NO LEDs ON
            end         
            
            if (move_counter == 0 || (button_left & ~left_delay) || (button_right & ~right_delay) || (button_up & ~up_delay) || (button_down & ~down_delay)) begin
                if (mode_sel == 0) begin // Move Mode
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
                end 
                
                else begin // Resize Mode
                   if (resize_mode_sel == 0) begin  // Uniform Resize Mode
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
                  
                  else begin  // Independent Resize Mode
                   // increase mode
                   if (increase_mode_sel == 0) begin
                    if (button_left_resize && x1 > 0) begin
                        x1 <= x1 - 10;  
                        move_counter <= speed_delay;
                    end
                    if (button_right_resize && x2 < IMAGE_WIDTH - 1) begin
                        x2 <= x2 + 10;  
                        move_counter <= speed_delay;
                    end
                    if (button_top_resize && y1 > 0) begin
                        y1 <= y1 - 10;  
                        move_counter <= speed_delay;
                    end
                    if (button_bottom_resize && y2 < IMAGE_HEIGHT - 1) begin
                        y2 <= y2 + 10;  
                        move_counter <= speed_delay;
                    end
                   end
                   // Decrease mode
                   else begin
                    // decrease left side
                    if (button_left_resize && (x2 - x1 + 1) > MIN_BOX_SIZE) begin
                        x1 <= x1 + 10;
                        move_counter <= speed_delay;
                    end
                    // decrease right side
                    if (button_right_resize && (x2 - x1 + 1) > MIN_BOX_SIZE) begin
                        x2 <= x2 - 10;
                        move_counter <= speed_delay;
                    end
                    // decrease top side
                    if (button_top_resize && (y2 - y1 + 1) > MIN_BOX_SIZE) begin
                        y1 <= y1 + 10;
                        move_counter <= speed_delay;
                    end
                    // decrease bottom side
                    if (button_bottom_resize && (y2 - y1 + 1) > MIN_BOX_SIZE) begin
                        y2 <= y2 - 10;
                        move_counter <= speed_delay;
                    end
                   end
                  end
                end
            end
        end
    end
endmodule

module controlling_module_2_mode_p #(
    parameter IMAGE_WIDTH  = 1280,  //  width
    parameter IMAGE_HEIGHT = 720,   //  height
    parameter MIN_BOX_SIZE = 5,  
    parameter MAX_BOX_SIZE = 700,   //  max box size
    parameter INIT_BOX_SIZE = 50    // start with a larger box size initially 
)
(
    input clk,               // fpga clk ~100MHz
    input rst,               // reset button
    input mode_sel,          // move/resize mode selection switch sw[0]
    input [1:0] speed_sel,         // fast/slow speed selection switch sw[1]
    input resize_mode_sel,   // resize mode selection sw[2], 0: uniform, 1: independent
    input increase_mode_sel,   // increase each side or decrease each side sw[3], 0: increase, 1: decrease each side
    
    // movement buttons
   input wire [3:0] butns,
    
    // output coordinates, 12 bits to support larger images
    output wire [15:0] x1_o, 
    output wire [15:0] x2_o, 
    output wire [15:0] y1_o, 
    output wire [15:0] y2_o,
    
    // LED outputs for mode selection indication
    output reg [2:0] leds // 4 LEDs leds[3:0] for different modes: 
    // 4'b0001 Move Mode, 4'b0010 uniform resize mode, 4'b0100 independent resize mode, 4'b1000 reserved
);

    reg [11:0] x1;
    reg [11:0] x2;
    reg [11:0] y1;
    reg [11:0] y2;
    
    assign x1_o = {4'b0, x1};
    assign x2_o = {4'b0, x2};
    assign y1_o = {4'b0, y1};
    assign y2_o = {4'b0, y2};
    
    // movement buttons
    wire button_left = butns[0];
    wire button_right = butns[1];
    wire button_up = butns[2];
    wire button_down = butns[3];
    
    // uniform resize buttons
    wire button_bigger = butns[2];
    wire button_smaller = butns[3];
    
    // independent resize buttons, adjusts each edge separately
    wire button_left_resize   = butns[0]; // left edge
    wire button_right_resize  = butns[1]; // right edge
    wire button_top_resize    = butns[2]; // top edge
    wire button_bottom_resize = butns[3]; // bottom edge

    // Internal registers to delay button inputs by one cycle
    reg left_delay, right_delay, up_delay, down_delay;
    reg bigger_delay, smaller_delay;
    reg left_resize_delay, right_resize_delay, top_resize_delay, bottom_resize_delay;
    reg [23:0] move_counter;  // Large enough for a delay (24 bits â†' ~167ms at 100MHz)

    // speed mode control: fast mode (10ms), slow mode (50ms)
    wire [23:0] speed_delay;
    //assign speed_delay = (speed_sel) ? 24'd5000000 : 24'd1000000;
    
    assign speed_delay = (speed_sel == 2'b00) ? 24'd5000000  :  //  00: fast 10ms
                     (speed_sel == 2'b01) ? 24'd1000000  :      //  01: regular 50ms
                     (speed_sel == 2'b10) ? 24'd10000000 :      //  10: slow 100ms
                                           24'd20000000;        //  11: super slow 200ms
    
    // rising edge detection for each button
    // each button input has a delay register
    always @(posedge clk) begin
        left_delay    <= button_left;
        right_delay   <= button_right;
        up_delay      <= button_up;
        down_delay    <= button_down;
        bigger_delay  <= button_bigger;
        smaller_delay <= button_smaller;
        left_resize_delay   <= button_left_resize;
        right_resize_delay  <= button_right_resize;
        top_resize_delay    <= button_top_resize;
        bottom_resize_delay <= button_bottom_resize;
    end

    // this is the initial Position, not synthesizable
//    initial begin
//       x1 = 0; 
//        y1 = 0;
//        x2 = x1 + INIT_BOX_SIZE - 1; // 49, 0x31
//        y2 = y1 + INIT_BOX_SIZE - 1; // 49, 0x31
//        move_counter = 0;
//        leds = 3'b001; // Default LED state: Move Mode
//    end

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
            leds <= 3'b001; // default: Move Mode
        end 
        
        else if (move_counter > 0) begin
                move_counter <= move_counter - 1;
        end 
        
        else begin        
            
            // Set LEDs based on mode
            if (mode_sel == 0) begin
                leds <= 3'b001; // move mode, LED0 ON
            end 
            else if (mode_sel ==1 && resize_mode_sel == 0) begin
                leds <= 3'b010; // uniform resize mode, LED1 ON
            end 
            else if (mode_sel == 1 && resize_mode_sel == 1) begin
                leds <= 3'b100; // independent resize mode, LED2 ON
            end 
            else begin
                leds <= 3'b000; // NO LEDs ON
            end         
            
            if (move_counter == 0 || (button_left & ~left_delay) || (button_right & ~right_delay) || (button_up & ~up_delay) || (button_down & ~down_delay)) begin
                if (mode_sel == 0) begin // Move Mode
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
                end 
                
                else begin // Resize Mode
                   if (resize_mode_sel == 0) begin  // Uniform Resize Mode
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
                  
                  else begin  // Independent Resize Mode
                   // increase mode
                   if (increase_mode_sel == 0) begin
                    if (button_left_resize && x1 > 0) begin
                        x1 <= x1 - 10;  
                        move_counter <= speed_delay;
                    end
                    if (button_right_resize && x2 < IMAGE_WIDTH - 1) begin
                        x2 <= x2 + 10;  
                        move_counter <= speed_delay;
                    end
                    if (button_top_resize && y1 > 0) begin
                        y1 <= y1 - 10;  
                        move_counter <= speed_delay;
                    end
                    if (button_bottom_resize && y2 < IMAGE_HEIGHT - 1) begin
                        y2 <= y2 + 10;  
                        move_counter <= speed_delay;
                    end
                   end
                   // Decrease mode
                   else begin
                    // decrease left side
                    if (button_left_resize && (x2 - x1 + 1) > MIN_BOX_SIZE) begin
                        x1 <= x1 + 10;
                        move_counter <= speed_delay;
                    end
                    // decrease right side
                    if (button_right_resize && (x2 - x1 + 1) > MIN_BOX_SIZE) begin
                        x2 <= x2 - 10;
                        move_counter <= speed_delay;
                    end
                    // decrease top side
                    if (button_top_resize && (y2 - y1 + 1) > MIN_BOX_SIZE) begin
                        y1 <= y1 + 10;
                        move_counter <= speed_delay;
                    end
                    // decrease bottom side
                    if (button_bottom_resize && (y2 - y1 + 1) > MIN_BOX_SIZE) begin
                        y2 <= y2 - 10;
                        move_counter <= speed_delay;
                    end
                   end
                  end
                end
            end
        end
    end
endmodule