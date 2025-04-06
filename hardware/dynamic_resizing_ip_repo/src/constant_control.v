`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/02/2025 06:05:33 PM
// Design Name: 
// Module Name: constant_control
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

`define ST_RESET 3'b000
`define ST_WAIT 3'b001
`define ST_UPDATE_NEXTS 3'b010
`define ST_WAIT_DIV1 3'b100
`define ST_WAIT_VSYNC 3'b011


module constant_control(
    input wire clk,
    input wire resetn,

    input wire [15:0] top_left_x,
    input wire [15:0] top_left_y,
    input wire [15:0] bot_right_x,
    input wire [15:0] bot_right_y,

    input wire update,
    input wire vsync,
    
    output reg [31:0] topl,        // {y1, x1}
    output reg [31:0] botr,        // {y2, x2}
    output reg [23:0] dx,          // = width/28 = 16b.8b
    output reg [23:0] dy,          // = height/28 = 16b.8b
    output reg [23:0] hdim_w,      // width = x2 - x1 + 1 = 16b.8b
    output reg [23:0] vdim_h,      // width = y2 - y1 + 1 = 16b.8b
    output reg [16:0] factor_w,    // factor_w = 28/width = 5b.12b
    output reg [16:0] factor_h    // factor_h = 28/height = 5b.12b
    );
    
    // Output control
    reg vsync_d1r;
    reg sent;
    
    // Inputs
    reg [15:0] top_left_x_r;
    reg [15:0] top_left_y_r;
    reg [15:0] bot_right_x_r;
    reg [15:0] bot_right_y_r;
    
    // Intermediate coffeificents
    reg [31:0] topl_next;
    reg [31:0] botr_next;
    reg [23:0] dx_next;
    reg [23:0] dy_next;
    reg [23:0] hdim_w_next;
    reg [23:0] vdim_h_next;
    reg [16:0] factor_w_next;
    reg [16:0] factor_h_next;
   
    
    // Update FSM
    reg [3:0] curr_state;
    reg [5:0] counter;
    reg valid;
    
    // Multiplier control + divider control
    reg [11:0] mult_inp;
    wire [23:0] mult_out;
    
    reg [11:0] divider;
    reg div_valid;
    wire [23:0] div_out;
    
    always @(posedge clk) begin
        if(~resetn) begin
            curr_state <= `ST_RESET;
            counter <= 6'b0;
            valid <= 1'b0;
            
            // Input flop stage
            top_left_x_r <= 16'b0;
            top_left_y_r <= 16'b0;
            bot_right_x_r <= 16'b0;
            bot_right_y_r <= 16'b0;
                       
            // coffs
            topl_next <= 32'b0;
            botr_next <= 32'b0;
            dx_next <= 24'b0;
            dy_next <= 24'b0;
            hdim_w_next <= 24'b0;
            vdim_h_next <= 24'b0;
            factor_w_next <= 17'b0;
            factor_h_next <= 17'b0;
        end else begin
            case(curr_state)
                `ST_RESET: begin
                    curr_state <= `ST_WAIT;
                end
                `ST_WAIT: begin
                    if(update) begin
                        curr_state <= `ST_UPDATE_NEXTS;
                        counter <= 6'd0;
                        top_left_x_r <= top_left_x;
                        top_left_y_r <= top_left_y;
                        bot_right_x_r <= bot_right_x;
                        bot_right_y_r <= bot_right_y;
                    end
                end
                `ST_UPDATE_NEXTS: begin
                    counter <= counter + 1;
                    case(counter)
                        6'd0: begin
                            topl_next[31:0] <=   {top_left_y_r[15:0],   top_left_x_r[15:0]};
                            botr_next[31:0] <=   {bot_right_y_r[15:0],  bot_right_x_r[15:0]};                    
                            hdim_w_next[23:0] <= {bot_right_x_r[15:0] - top_left_x_r[15:0] + 1, 8'd0};
                            vdim_h_next[23:0] <= {bot_right_y_r[15:0] - top_left_y_r[15:0] + 1, 8'd0};
                            
                            mult_inp[11:0] <= bot_right_x_r[11:0] - top_left_x_r[11:0] + 1; // Send first mult - width * (1/28)
                            divider[11:0]  <= bot_right_x_r[11:0] - top_left_x_r[11:0] + 1; // Send first div - 28 / width
                            div_valid <= 1'b1;
                        end
                        6'd1: begin
                            mult_inp[11:0] <= bot_right_y_r[11:0] - top_left_y_r[11:0] + 1; // Send second mult - height * (1/28)
                            divider[11:0] <=  bot_right_y_r[11:0] - top_left_y_r[11:0] + 1;  // Send second div - 28 / height
                        end
                        6'd2: begin
                            div_valid <= 1'b0;
                        end
                        6'd3: begin
                            dx_next[23:0] <= {8'b0, mult_out[23:8]};
                        end
                        6'd4: begin
                            dy_next[23:0] <= {8'b0, mult_out[23:8]};
                        end
                        6'd25: begin
                            factor_w_next[16:0] <= div_out[21:5]; // 7b.17b -> 5b.12b
                        end
                        6'd26: begin
                            factor_h_next[16:0] <= div_out[21:5];
                            counter <= 6'd0;
                            curr_state <= `ST_WAIT_VSYNC;
                        end
                    endcase
                    
                end
                `ST_WAIT_VSYNC: begin
                    valid <= 1'b1;
                    if(sent) begin
                        valid <= 1'b0;
                        curr_state <= `ST_WAIT;
                    end
                end
            
            
            endcase
        end
    end
    
    div_coffs I_divider(
        .aclk(clk),
        // Divisor
        .s_axis_divisor_tdata({4'b0, divider}),
        .s_axis_divisor_tvalid(div_valid),
        // Dividend
        .s_axis_dividend_tdata(8'd28),
        .s_axis_dividend_tvalid(1'b1),
        
        // Output
        .m_axis_dout_tdata(div_out),
        .m_axis_dout_tvalid()
        
    );
    
    mult_coffs I_mult(
        .CLK(clk),
        .A(mult_inp),   // width*1/28
        .P(mult_out)    // 12b.16b
    );
    
    

    always @(posedge clk) begin
        if(~resetn) begin
            topl <= 32'h000a000a;
            botr <= 32'h00640064;
            dx <= 24'h340;
            dy <= 24'h340;
            hdim_w <= 24'h5b00;
            vdim_h <= 24'h5b00;
            factor_w <= 24'h4ec;
            factor_h <= 24'h4ec;
            
            sent <= 1'b0;
        end else begin
            vsync_d1r <= vsync;
            if(~vsync_d1r & vsync & valid) begin // Update coffs on vsync rising edge if valid.
                topl <= topl_next;
                botr <= botr_next;
                dx <= dx_next;
                dy <= dy_next;
                hdim_w <= hdim_w_next;
                vdim_h <= vdim_h_next;
                factor_w <= factor_w_next;
                factor_h <= factor_h_next;
                sent <= 1'b1;
            end else begin
                sent <= 1'b0;
            end
        end
    end
    
    
    
    
endmodule
