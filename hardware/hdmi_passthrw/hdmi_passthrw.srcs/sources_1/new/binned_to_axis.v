`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/03/2025 11:04:02 AM
// Design Name: 
// Module Name: binned_to_axis
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


module binned_to_axis(
    input wire clk,
    input wire resetn,
    
    input wire [7:0] data,
    input wire valid,
    input wire vsync,
    
    output wire [7:0] m_axis_tdata,
    output wire m_axis_tvalid,
    output wire m_axis_tlast,
    
    input wire save_frame
    );
    
    
    reg save_frame_d1r;
    reg passthr;
    reg wait_v1;
    reg vsync_d1r;
    reg [15:0] counter;
    always @(posedge clk) begin
        if(~resetn) begin
            save_frame_d1r <= 1'b0;
            wait_v1 <= 1'b0;
            passthr <= 1'b0;
            vsync_d1r <= 1'b0;
            counter <= 16'b0;
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
                counter <= 16'b0;
           end else if( valid & passthr) begin
                counter <= counter + 16'b1;
           end
        end

    end
    
    
    assign m_axis_tdata = data;
    assign m_axis_tvalid = valid & passthr;
    assign m_axis_tlast = (counter == 783);
    
    
endmodule
