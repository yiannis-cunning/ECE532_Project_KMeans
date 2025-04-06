`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/02/2025 11:33:11 AM
// Design Name: 
// Module Name: vert_avg_input
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


module vert_avg_input(
    input wire clk,
    input wire resetn,
    
    // From FIFO
    input wire [7:0] pdata,
    input wire pvalid,
    output wire pready,
    
    // To pixel buffer
    output wire [4:0] waddr,
    output wire [7:0] wdata,
    output wire we,
    
    // To control FSM
    input wire req,
    output reg ack
    );
    
    
    reg go;
    reg [4:0] index;
    
    assign wdata = pdata;
    assign waddr = index;
    assign we = pvalid & go & (index <= 27);
    assign pready = go;
        
    
    always @(posedge clk) begin
        if(~resetn) begin
            ack <= 1'b0;
            go <= 1'b0;
        end else begin
            if(go) begin
                if(we)
                    index <= index + 5'b1;
                else
                    index <= index;
            end else
                index <= 5'b0;

            
            if(req & ~ack) begin
                if(ack) begin
                    ack <= 1'b1;
                end else begin
                    if(index == 5'd28) begin
                        go <= 1'b0;
                        ack <= 1'b1;
                    end else begin
                        go <= 1'b1;
                    end
                end
            end else begin
                ack <= 1'b0;
                go <= 1'b0;
            end
        end
    end
endmodule
