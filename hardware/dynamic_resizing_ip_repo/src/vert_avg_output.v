`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/02/2025 01:04:26 PM
// Design Name: 
// Module Name: vert_avg_output
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


module vert_avg_output(
    input wire clk,
    input wire resetn,

    // From/To sum buffer
    output wire [4:0] sum_raddr,
    input wire [23:0] sum_rdata,
    
    output wire [4:0] sum_waddr,
    output wire [23:0] sum_wdata,
    output wire sum_we,
    
    // To output AXIS
    output wire [23:0] data_o,
    output wire valid_o,
    
    // From FSM
    input wire req,
    output reg ack
    );
    
    
    // 1) Generate Index = 0-27    
    reg [4:0] index;
    reg valid;
    always @(posedge clk) begin
        if(~resetn) begin
            index <= 0;
            ack <= 0;
            valid <= 0;
        end else begin    
            if(req) begin
                if(~ack)begin
                    valid <= 1'b1;
                    if(valid)
                        index <= index + 1;
                    if(index == 5'd27) begin
                        ack <= 1'b1;
                        valid <= 1'b0;
                        index <= 5'b0;
                    end
                end
                // else do nothing
            end else begin
                valid <= 0;
                ack <= 0;
                index <= 0;
            end
        end
    end
    
    
    assign sum_raddr = index; // to get - sum_rdata
    
    // 2) Single flop stage before output
    reg valid_r1;
    reg [4:0] index_r1;
    reg [23:0] value_r1;
    
    always @(posedge clk) begin
        if(~resetn) begin
            valid_r1 <= 1'b0;
            index_r1 <= 5'b0;
            value_r1 <= 24'b0;
        end else begin
            valid_r1 <= valid;
            index_r1 <= index;
            value_r1 <= sum_rdata;
        end
    end
    
    
    // 3) Clear sum buffer to 0
    assign sum_waddr = index_r1;
    assign sum_wdata = 24'b0;
    assign sum_we = valid_r1;
    
    // 4) Ouput the data to AXIS
    assign data_o = value_r1;
    assign valid_o = valid_r1;
    
endmodule
