`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/01/2025 12:51:29 AM
// Design Name: 
// Module Name: hor_avg_filter
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
`define ST_IDLE 3'b001
`define ST_DOROW 3'b010

module hor_avg_filter(
    input wire clk,
    input wire resetn,
    
    // Video signals in
    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io:1.0 RGB_i DATA" *)
    input wire [7:0] vid_pData_i,
    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io:1.0 RGB_i HSYNC" *)
    input wire vid_pHSync_i,
    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io:1.0 RGB_i VSYNC" *)
    input wire vid_pVSync_i,
    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io:1.0 RGB_i ACTIVE_VIDEO" *)
    input wire vid_pVDE_i,
    
    output wire vid_pReady_o,

     // Video signals out
    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io:1.0 RGB_o DATA" *)
    output wire [23:0] vid_pData_o,
    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io:1.0 RGB_o HSYNC" *)
    output wire vid_pHSync_o,
    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io:1.0 RGB_o VSYNC" *)
    output wire vid_pVSync_o,
    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io:1.0 RGB_o ACTIVE_VIDEO" *)
    output wire vid_pVDE_o,
    
    // Control and Status
    input wire sw_reset,
    input wire [23:0] dx,
    input wire [23:0] hdim
    );
    
    wire valid_i = vid_pVDE_i;
    
    reg [2:0] curr_state;
    reg hsync_d1r;
    reg ready_out;
    
    // Fixed-point values
    reg [23:0] pleft;
    reg [23:0] pright;
    reg [23:0] dest_left;
    reg [23:0] dest_right;
    reg [7:0] sums_num;
    
    reg [23:0] a;
    reg [23:0] b;
    reg [23:0] f;
    reg send_sum;
    

    always @(*) begin
        a = (dest_left > pleft) ? (dest_left) : (pleft); // Find left bound - max of lefts
        b = (dest_right < pright) ? (dest_right) : (pright); // Find left bound - min of right
        f = (b - a);
        
        if(valid_i)begin
            if(dest_right == pright) begin
                // increment both
                ready_out = 1'b1;
                send_sum = 1'b1;
            end else if(dest_right > pright) begin
                // increment pixel
                ready_out = 1'b1;
                send_sum = 1'b0;
            end else begin
                // increment sum
                ready_out = 1'b0;
                send_sum = 1'b1;
            end
        end else begin
            ready_out = 1'b0;
            send_sum = 1'b0;
        end
    end
    
    assign vid_pReady_o = ready_out;
    
    // Control FSM
    always @(posedge clk) begin
        if(~resetn) begin
            curr_state <= `ST_RESET;
            hsync_d1r <= 1'b0;
            sums_num <= 8'b0;
            
            pleft <= 24'b0;
            pright <= 24'b0;
            dest_left <= 24'b0;
            dest_right <= 24'b0;

        end else begin
            hsync_d1r <= vid_pHSync_i;
        
            case(curr_state)
                `ST_RESET: begin
                    curr_state <= `ST_IDLE;
                end
                `ST_IDLE: begin // Wait for Hsync
                    pleft <= 24'b0;
                    pright <= {16'b1, 8'b0};
                    dest_left <= 24'b0;
                    dest_right <= dx;
                    sums_num <= 8'b0;
                  
                    if(hsync_d1r & ~vid_pHSync_i) begin // neg edge hsync
                        curr_state <= `ST_DOROW;
                    end
                end
                `ST_DOROW: begin
                    //if( (pright == hdim) & (dest_right == hdim) ) begin // Done the row
                    if(vid_pHSync_i) begin
                        curr_state <= `ST_IDLE;
                    end
                
                    if(valid_i) begin
                        if(dest_right == pright) begin
                            // INCREMENT BOTH
                            pleft <= pright;
                            pright <= pright + {16'b1, 8'b0};
                            sums_num <= sums_num + 8'b1;
                            if(sums_num != 26) begin
                                dest_left <= dest_right;
                                dest_right <= dest_right + dx;
                            end else begin
                                dest_left <= dest_right;
                                dest_right <= hdim;
                            end
                        end else if(dest_right > pright) begin
                            // INCREMENT PIXEL
                            pleft <= pright;
                            pright <= pright + {16'b1, 8'b0};
                        end else begin
                            // INCREMENT SUM
                            sums_num <= sums_num + 8'b1;
                            if(sums_num != 26) begin
                                dest_left <= dest_right;
                                dest_right <= dest_right + dx;
                            end else begin
                                dest_left <= dest_right;
                                dest_right <= hdim;
                            end
                        end
                    end
                end
            endcase
        end
    end
    
    
    // Math FSM
    //      combo inputs:
    //          - f = fixed point number, between 0 and 1
    //          - value = 256b input pixel value
    //          - send_sum = do the computation and then send this value out
    //          - valid = data is valid
    reg [8:0] f_r1;
    reg [7:0] value_r1;
    reg [15:0] mult_res_r2;
    reg send_sum_r1, send_sum_r2, send_sum_r3;
    reg valid_r1, valid_r2;
    reg [23:0] sum_r;
    
    wire [17:0] mult_res_next;
    wire [23:0] sum_next = (send_sum_r3) ? (24'b0) : (sum_r);
    
    always @(posedge clk) begin
        if(~resetn) begin
            // reg 1
            f_r1 <= 9'b0;
            value_r1 <= 8'b0; 
            send_sum_r1 <= 1'b0;
            valid_r1 <= 1'b0;
            
            // reg 2
            mult_res_r2 <= 16'b0;
            send_sum_r2 <= 1'b0;
            valid_r2 <= 1'b0;
            
            // reg out
            sum_r <= 24'b0;
            send_sum_r3 <= 1'b0;
            
        end else begin
            // 1) send_sum is passthorugh
            send_sum_r1 <= send_sum;
            send_sum_r2 <= send_sum_r1;
            send_sum_r3 <= send_sum_r2;
            
            // 2) valid
            valid_r1 <= valid_i;
            valid_r2 <= valid_r1;
            
            // 3) value
            f_r1 <= f[8:0];
            value_r1 <= vid_pData_i;
            mult_res_r2 <= (f_r1[8]) ? ( {value_r1, 8'b0}) : (mult_res_next[15:0]);
            
            if(valid_r2) begin
                sum_r <= sum_next + {8'b0, mult_res_r2};
            end else begin
                sum_r <= sum_next;
            end
            
        end
    end
    dsp_macro_hor_filter I_dsp( .A( { 1'b0, f_r1[7:0] }), .B( { 1'b0, value_r1 }), .P(mult_res_next) ); //  .CLK(clk), 
    
    
    // RGB output
    assign vid_pData_o = sum_r;
    assign vid_pVDE_o = send_sum_r3;
    assign vid_pVSync_o = vid_pVSync_i;
    assign vid_pHSync_o = vid_pHSync_i;
    
endmodule
