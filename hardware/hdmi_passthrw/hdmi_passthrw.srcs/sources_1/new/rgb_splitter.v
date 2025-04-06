`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/21/2025 02:42:27 PM
// Design Name: 
// Module Name: rgb_splitter
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

module rgb_splitter(
    // Video signals
    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io:1.0 RGB_i DATA" *)
    input wire [23:0] vid_pData_i,
    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io:1.0 RGB_i HSYNC" *)
    input wire vid_pHSync_i,
    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io:1.0 RGB_i VSYNC" *)
    input wire vid_pVSync_i,
    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io:1.0 RGB_i ACTIVE_VIDEO" *)
    input wire vid_pVDE_i,
    
    // Video signals
    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io:1.0 RGB1_o DATA" *)
    output wire [23:0] vid_pData_o1,
    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io:1.0 RGB1_o HSYNC" *)
    output wire vid_pHSync_o1,
    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io:1.0 RGB1_o VSYNC" *)
    output wire vid_pVSync_o1,
    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io:1.0 RGB1_o ACTIVE_VIDEO" *)
    output wire vid_pVDE_o1, 
    
    // Video signals
    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io:1.0 RGB2_o DATA" *)
    output wire [23:0] vid_pData_o2,
    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io:1.0 RGB2_o HSYNC" *)
    output wire vid_pHSync_o2,
    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io:1.0 RGB2_o VSYNC" *)
    output wire vid_pVSync_o2,
    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io:1.0 RGB2_o ACTIVE_VIDEO" *)
    output wire vid_pVDE_o2,
    
     // Video signals
    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io:1.0 RGB3_o DATA" *)
    output wire [23:0] vid_pData_o3,
    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io:1.0 RGB3_o HSYNC" *)
    output wire vid_pHSync_o3,
    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io:1.0 RGB3_o VSYNC" *)
    output wire vid_pVSync_o3,
    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io:1.0 RGB3_o ACTIVE_VIDEO" *)
    output wire vid_pVDE_o3,
    
         // Video signals
    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io:1.0 RGB4_o DATA" *)
    output wire [23:0] vid_pData_o4,
    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io:1.0 RGB4_o HSYNC" *)
    output wire vid_pHSync_o4,
    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io:1.0 RGB4_o VSYNC" *)
    output wire vid_pVSync_o4,
    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io:1.0 RGB4_o ACTIVE_VIDEO" *)
    output wire vid_pVDE_o4
    );
    
    assign vid_pData_o1 = vid_pData_i;
    assign vid_pHSync_o1 = vid_pHSync_i;
    assign vid_pVSync_o1 = vid_pVSync_i;
    assign vid_pVDE_o1 = vid_pVDE_i;
    
    assign vid_pData_o2 = vid_pData_i;
    assign vid_pHSync_o2 = vid_pHSync_i;
    assign vid_pVSync_o2 = vid_pVSync_i;
    assign vid_pVDE_o2 = vid_pVDE_i;
    
    assign vid_pData_o3 = vid_pData_i;
    assign vid_pHSync_o3 = vid_pHSync_i;
    assign vid_pVSync_o3 = vid_pVSync_i;
    assign vid_pVDE_o3 = vid_pVDE_i;
    
    assign vid_pData_o4 = vid_pData_i;
    assign vid_pHSync_o4 = vid_pHSync_i;
    assign vid_pVSync_o4 = vid_pVSync_i;
    assign vid_pVDE_o4 = vid_pVDE_i;

endmodule 
