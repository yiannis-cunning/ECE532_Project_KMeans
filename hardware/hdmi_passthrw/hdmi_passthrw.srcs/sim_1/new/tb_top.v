`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/13/2025 06:44:43 PM
// Design Name: 
// Module Name: tb_top
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


module tb_top(
    );
    
    
    reg clk = 1'b0;
    reg resetn = 1'b0;
    
    reg [23:0] pdata;
    reg hsync;
    reg vsync;
    reg valid;
    reg send_frame;
    
    
    initial forever #10 clk = ~clk;
    initial begin 
        pdata = 24'b0;
        hsync = 1'b0;
        vsync = 1'b0;
        valid = 1'b0;
        send_frame = 1'b0;
        # 25
        resetn = 1'b1;
        # 300
        send_frame = 1'b1;
        #300
        send_frame = 1'b0;
    end
    
    integer hcount = 0;
    integer vcount = 0;
    always @(posedge clk) begin
        if(resetn) begin
            
            if( hcount <= 9)
                hsync <= 1'b1;
            else
                hsync <= 1'b0;
            
            pdata <= pdata + 1;
            
            if ((vcount >= 2) & (vcount <= 1081) & (hcount >= 20) & (hcount <= 1939))
                valid <= 1'b1;
            else
                valid <= 1'b0;
            
            if(vcount == 1084)
                vsync <= 1'b1;
            else
                vsync <= 1'b0;
                
            
            
            
            if(hcount == 1949) begin
                hcount <= 0;
                if(vcount == 1085)
                    vcount <= 0;
                else
                    vcount <= vcount + 1;
            end else
                hcount <= hcount + 1;
            
        end
    end
    
    
    
    wire [31:0] axis_data;
    wire axis_tlast, axis_tready, axis_tvalid;
    
    rgb_debuger I_dut1(
        .clk(clk),
        .resetn(resetn),
        
        .vid_pData(pdata),
        .vid_pHSync(hsync),
        .vid_pVSync(vsync),
        .vid_pVDE(valid),
        
        .sw_reset(1'b1)
    );
    
   rgb_to_stream I_dut2(
        .clk(clk),
        .resetn(resetn),
        
        .vid_pData(pdata),
        .vid_pHSync(hsync),
        .vid_pVSync(vsync),
        .vid_pVDE(valid),

        .m_axis_tdata(axis_data),
        .m_axis_tlast(axis_tlast),
        .m_axis_tready(axis_tready),
        .m_axis_tvalid(axis_tvalid),
        
        
        .sw_reset(1'b1),
        .send_frame(send_frame),
        .hdim_m1(32'd1919),
        .vdim_m1(32'd1079)
        
    );


    axis_to_rgb I_dut3(
        .clk(clk),
        .resetn(resetn),
        
        .m_axis_tdata(axis_data),
        .m_axis_tlast(axis_tlast),
        .m_axis_tready(axis_tready),
        .m_axis_tvalid(axis_tvalid),
        
        .sw_reset(1'b1)
    );
    
    
    
    
 
    
endmodule
