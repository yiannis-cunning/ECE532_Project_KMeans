`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/28/2025 08:14:48 PM
// Design Name: 
// Module Name: sub_image_filter
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
`define ST_WAIT_V 3'b001
`define ST_READ_B1 3'b010
`define ST_READ_H 3'b011
`define ST_ERROR 3'b100
`define ST_DONE 3'b101

module sub_image_filter(
    input wire clk,
    input wire resetn,
    
    // Video signals in
    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io:1.0 RGB_i DATA" *)
    input wire [23:0] vid_pData_i,
    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io:1.0 RGB_i HSYNC" *)
    input wire vid_pHSync_i,
    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io:1.0 RGB_i VSYNC" *)
    input wire vid_pVSync_i,
    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io:1.0 RGB_i ACTIVE_VIDEO" *)
    input wire vid_pVDE_i,

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
    
    input wire [31:0] top_left,
    input wire [31:0] bottom_right,
    input wire enable
    );
    
    
    reg [2:0] curr_state;
    reg [15:0] hor_count;
    reg [15:0] ver_count;
    reg vsync_d1r;
    reg hsync_d1r;
    
    always @(posedge clk) begin
        if(~sw_reset | ~resetn) begin
            // State reg
            curr_state <= `ST_RESET;  
            
            // Counter regs
            hor_count <= 16'b0;
            ver_count <= 16'b0;
            
            // Other regs
            vsync_d1r <= 1'b0;
            hsync_d1r <= 1'b0;
 
        end else begin
            vsync_d1r <= vid_pVSync_i;
            hsync_d1r <= vid_pHSync_i;    
                       
            case(curr_state)
                `ST_RESET: begin
                    curr_state <= `ST_READ_B1;
                end
                `ST_WAIT_V: begin
                        ver_count[15:0] <= 16'b0;
                        // Find start of frame - neg edge of vsync
                        if(vsync_d1r & ~vid_pVSync_i) begin
                            curr_state <= `ST_READ_B1;
                        end
                 end
                 `ST_READ_B1: begin
                    if(vid_pVDE_i) begin
                        hor_count[15:0] <= hor_count[15:0] + 16'b1;
                    end else begin
                        if(vid_pHSync_i & ~hsync_d1r) begin // Pos edge hsync
                            if(hor_count[15:0] != 16'b0) begin
                                hor_count[15:0] <= 16'b0;
                                ver_count[15:0] <= ver_count[15:0] + 16'b1;
                            end
                        end
                        if(vid_pVSync_i) begin
                            curr_state <= `ST_WAIT_V;
                        end
                    end
                 end
            
            endcase
        end
    end // always block FSM
        
        
    wire [15:0] xmin = top_left[15:0];
    wire [15:0] xmax = bottom_right[15:0];
    wire [15:0] ymin = top_left[31:16];
    wire [15:0] ymax = bottom_right[31:16];
    
    wire inbounds_x = (hor_count[15:0] >= xmin) & (hor_count[15:0] <= xmax);
    wire inbounds_y = (ver_count[15:0] >= ymin) & (ver_count[15:0] <= ymax);
    wire inbounds = inbounds_x & inbounds_y;
    
    assign vid_pHSync_o = vid_pHSync_i;
    assign vid_pVSync_o = vid_pVSync_i;
    assign vid_pVDE_o = vid_pVDE_i & inbounds & enable;
    assign vid_pData_o = vid_pData_i;
    
endmodule
