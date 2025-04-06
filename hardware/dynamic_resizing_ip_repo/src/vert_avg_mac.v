`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/02/2025 12:21:52 PM
// Design Name: 
// Module Name: vert_avg_mac
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


module vert_avg_mac(
    input wire clk,
    input wire resetn,
    
    // From pixel buffer
    output wire [4:0] pixel_raddr,
    input wire [7:0] pixel_rdata,
    
    // From/To sum buffer
    output wire [4:0] sum_raddr,
    input wire [23:0] sum_rdata,
    
    output wire [4:0]sum_waddr,
    output wire [23:0] sum_wdata,
    output wire sum_we,
    
    // From FSM
    input wire [23:0] f,
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
    
    assign pixel_raddr = index; // to get - pixel_rdata
   
    // Pipeline - stage 1
    reg [8:0] f_r1;
    reg [7:0] pix_value_r1;
    reg [4:0] index_r1;
    reg valid_r1;
    always @(posedge clk) begin
        if(~resetn) begin
            f_r1 <= 9'b0;
            pix_value_r1 <= 8'b0;
            index_r1 <= 5'b0;
            valid_r1 <= 1'b0;
        end else begin
            f_r1 <= f[8:0];     // From FSM
            index_r1 <= index;
            valid_r1 <= valid;
            pix_value_r1 <= pixel_rdata;
        end
    end
    
    
    assign sum_raddr = index_r1;    // to get - sum_rdata
    wire [17:0] mult_res_next;      // From DSP
    
    // Pipeline - stage 2
    reg [15:0] toadd_r2;
    reg [23:0] prev_sum_r2;
    reg [4:0] index_r2;
    reg valid_r2;
    always @(posedge clk) begin
        if(~resetn) begin
            toadd_r2 <= 16'b0;
            prev_sum_r2 <= 24'b0;
            index_r2 <= 5'b0;
            valid_r2 <= 1'b0;
        end else begin
            toadd_r2 <= (f_r1[8]) ? ( {pix_value_r1, 8'b0}) : (mult_res_next[15:0]);
            prev_sum_r2 <= sum_rdata;
            index_r2 <= index_r1;
            valid_r2 <= valid_r1;
        end
    end
    
        
    // DSP unit
    dsp_macro_hor_filter I_dsp( .A( { 1'b0, f_r1[7:0] }), .B( { 1'b0, pix_value_r1 }), .P(mult_res_next) ); //  .CLK(clk), 
    
    
    // write back to sums
    assign sum_waddr = index_r2;
    assign sum_wdata = prev_sum_r2[23:0] + {8'b0, toadd_r2[15:0]};
    assign sum_we = valid_r2;
    
endmodule
