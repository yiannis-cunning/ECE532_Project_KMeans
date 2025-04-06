`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/09/2025 12:58:16 PM
// Design Name: 
// Module Name: resized_to_mm
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


module resized_to_mm(
    input wire clk,
    input wire resetn,
    
    input wire [7:0] data,
    input wire valid,
    input wire vsync,
    
    output wire [7:0] m_axi_tdata,
    output wire [31:0] m_axi_taddr,
    output wire m_axi_tvalid,
    
    input wire save_frame
    );
    
    
    reg save_frame_d1r;
    reg passthr;
    reg wait_v1;
    reg vsync_d1r;
    reg waddr;
    always @(posedge clk) begin
        if(~resetn) begin
            save_frame_d1r <= 1'b0;
            wait_v1 <= 1'b0;
            passthr <= 1'b0;
            vsync_d1r <= 1'b0;
            waddr <= 32'b0;
        end else begin
            save_frame_d1r <= save_frame;
            vsync_d1r <= vsync;
            
            if(save_frame & ~save_frame_d1r) begin // Neg edge save_frame
                wait_v1 <= 1'b1;
            end
            
            if(wait_v1 & ~vsync & vsync_d1r) begin // Wait for neg-edge vsync
                passthr <= 1'b1;
                wait_v1 <= 1'b0;
            end
            if(passthr & vsync_d1r) begin
                passthr <= 1'b0;
            end
           
           if(vsync) begin
                waddr <= 16'b0;
           end else if( valid & passthr) begin
                waddr <= waddr + 16'b1;
           end
        end

    end
    
    
    assign m_axi_tdata = data;
    assign m_axi_tvalid = valid & passthr;
    assign m_axi_taddr = waddr;
endmodule
