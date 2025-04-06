`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/01/2025 10:40:48 PM
// Design Name: 
// Module Name: normalizer
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


module normalizer(
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
    input wire sw_reset,
    input wire [16:0] factor // 5 bit . 12 bit
    );
    
    
    // out = data * factor
    wire [42:0] result;
    dsp_normalizer I_upper( 
            .A( {1'b0, vid_pData_i[23:0]} ), 
            .B( {1'b0, factor[16:0]} ), 
            .P(result),
            .CLK(clk)
    );
    assign vid_pData_o = result[27:20];
    
    // Delay other signals
    shift_reg_delay_normalizer I_shifter(
        .CLK(clk),
        .D({vid_pHSync_i, vid_pVSync_i, vid_pVDE_i}),
        .Q({vid_pHSync_o, vid_pVSync_o, vid_pVDE_o})
    );
    
    
endmodule
