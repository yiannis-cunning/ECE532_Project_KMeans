`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/17/2025 10:27:24 PM
// Design Name: 
// Module Name: tb_knn_2
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

`define IMAGE_SIZE (28*28)


module tb_knn_2(

    );
        
    reg clk = 1'b0;
    reg resetn = 1'b0;
    
    
    
    reg vsync;
    reg pvalid;
 
 
    initial forever #10 clk = ~clk;
    initial #100 resetn = 1'b1;


    // Generate video data from file
    reg [7:0] image [`IMAGE_SIZE - 1:0];
    initial begin
        $readmemh("input_image.mem", image);
    end
    
    wire [7:0] pdata = image[pixcnt -1];
    
    integer pixcnt;
    integer cycles;
    always @(posedge clk) begin
        if(~resetn) begin
            pixcnt <= 0;
            cycles <= 0;
            vsync <= 0;
            pvalid <= 0;
        end else begin
            if( (cycles % 10) == 9) begin
                if(pixcnt == `IMAGE_SIZE) begin
                    pixcnt <= 0;
                    vsync <= 1'b1;
                end else begin
                    pixcnt <= (pixcnt + 1) % (`IMAGE_SIZE + 1);
                    pvalid <= 1'b1;
                end
            end
            
            if(pvalid == 1'b1) begin
                pvalid <= 1'b0;
            end
            
           if(vsync == 1'b1) begin
                vsync <= 1'b0;
            end
            
            cycles <= cycles + 1;
        end
    
    end
    
    knn_bridge I_dut(
        .clk(clk),
        .resetn(resetn),
        
        .pdata(pdata),
        .pvalid(pvalid),
        .pvsync(vsync),
        
        .enable(1'b1),
        .detected()
    );
    
endmodule
