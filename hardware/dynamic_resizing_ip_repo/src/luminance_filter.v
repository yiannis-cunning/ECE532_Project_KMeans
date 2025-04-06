`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/28/2025 11:14:47 PM
// Design Name: 
// Module Name: luminance_filter
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


module luminance_filter(
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
    output wire [7:0] vid_pData_o,
    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io:1.0 RGB_o HSYNC" *)
    output wire vid_pHSync_o,
    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io:1.0 RGB_o VSYNC" *)
    output wire vid_pVSync_o,
    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io:1.0 RGB_o ACTIVE_VIDEO" *)
    output wire vid_pVDE_o,
    
    
    // Control and Status
    input wire sw_reset
    );
    
    
    
    // 1) input flop stages
    reg hsync_d1r, vsync_d1r, valid_d1r;
    reg hsync_d2r, vsync_d2r, valid_d2r;
    reg [23:0] data_r;
    reg [7:0] luminance;
    wire [17:0] luminance_full;
    always @(posedge clk) begin
        if(~resetn) begin
            data_r <= 24'b0;
            hsync_d1r <= 1'b0;
            vsync_d1r <= 1'b0;
            valid_d1r <= 1'b0;
            hsync_d2r <= 1'b0;
            vsync_d2r <= 1'b0;
            valid_d2r <= 1'b0;
        end else begin
            // first flop stage
            data_r <= vid_pData_i;           
            hsync_d1r <= vid_pHSync_i;
            vsync_d1r <= vid_pVSync_i;
            valid_d1r <= vid_pVDE_i;
            // second flop stage
            luminance <= luminance_full[15:8];
            hsync_d2r <= hsync_d1r;
            vsync_d2r <= vsync_d1r;
            valid_d2r <= valid_d1r;
        end
    end
    
    // 2) Luminance ~= 0.299*R + 0.587*G + 0.114*B
    // 8 bit fixed point
    // 0.299 ~= '0.0b01001101' = 0.30078125
    // 0.587 ~= '0.0b10010110' = 0.5859375
    // 0.114 ~= '0b11101' = 0.11328125
    
   wire [17:0] red_out;
   wire [17:0] green_out;
   wire [17:0] blue_out;
   
   dsp_macro_0 I_red(    .A( { 1'b0, data_r[23:16] }),  .B(9'b01001101),  .P(red_out)); //  .CLK(clk),
   dsp_macro_0 I_green(  .A( { 1'b0, data_r[15:8]  }),  .B(9'b10010110),  .P(green_out));
   dsp_macro_0 I_blue(   .A( { 1'b0, data_r[7:0]   }),  .B(9'b11101),     .P(blue_out));
    
   assign luminance_full = (red_out + green_out + blue_out);

   
   // 3) Assign outputs
   assign vid_pData_o = luminance;
   assign vid_pHSync_o = hsync_d2r;
   assign vid_pVSync_o = vsync_d2r;
   assign vid_pVDE_o = valid_d2r;


endmodule
