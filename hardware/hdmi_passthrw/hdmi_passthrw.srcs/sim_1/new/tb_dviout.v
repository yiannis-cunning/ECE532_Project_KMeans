`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/19/2025 10:06:34 PM
// Design Name: 
// Module Name: tb_dviout
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


module tb_dviout(

    );
    
    reg clk = 1'b0;
    reg resetn = 1'b0;
    
    initial forever #10 clk = ~clk;
    
    initial begin
        #155 resetn = 1'b1;
    end

    rgb_boxer I_dut2(
        .clk(clk),
        .resetn(resetn),
        .box_en(1'b1),
        .bottom_right( {16'd100, 16'd100} ),
        .top_left ( {16'd10, 16'd10} ),
        .thickness( 8'd3 ),
        .color( 24'd777777 ),
        .sw_reset(1'b1)
    );
    
    
    dvi_out I_dut(
        .clk(clk),
        .resetn(resetn),
        .sw_resetn(1'b1),
        .hdim_m1(32'd1279),
        .vdim_m1(32'd719)
    );
endmodule
