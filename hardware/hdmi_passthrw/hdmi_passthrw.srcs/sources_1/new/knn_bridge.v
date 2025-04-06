`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/17/2025 08:50:44 PM
// Design Name: 
// Module Name: knn_bridge
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


`define ST_RESET 3'b000
`define ST_IDLE 3'b001
`define ST_LOAD 3'b010
`define ST_INFER 3'b011

module knn_bridge(
    input wire clk,
    input wire resetn,

    // Input from resizer
    input wire [7:0] pdata,
    input wire pvalid,
    input wire pvsync,

    // Control and status
    input wire enable,
    output wire [3:0] detected
    );
    
        
    // RAM interface
    reg [7:0] myram [1023:0];
    
    wire [9:0] raddr;
    reg  [7:0] rdata;
    wire r_en;
    
    wire [9:0] waddr;
    wire [7:0] wdata;
    wire w_en;
    
    // R/W ports
    always @(posedge clk) begin
        if(w_en) begin
            myram[waddr] <= wdata;
        end
        if(r_en) begin
            rdata <= myram[raddr];
        end
    end


    
    // Interface from KNN 
    wire knn_done;
    wire knn_ready;
    wire knn_idle;
    
    wire knn_valid;
    wire [31:0] result;
    
    reg knn_start;
    
    
    knn_top_0 your_instance_name (
      .ap_clk(clk),                             // input wire ap_clk
      .ap_rst(~resetn),                         // input wire ap_rst
      
      .ap_start(knn_start),                     // input wire ap_start
      
      .ap_done(knn_done),                       // output wire ap_done
      .ap_idle(knn_idle),                       // output wire ap_idle
      .ap_ready(knn_ready),                     // output wire ap_ready
      
      .image_r_address0(raddr),                 // output wire [9 : 0] image_r_address0
      .image_r_ce0(r_en),                       // output wire image_r_ce0
      .image_r_q0(rdata),                       // input wire [7 : 0] image_r_q0
      
      .result(result),                          // output wire [31 : 0] result
      .result_ap_vld(knn_valid)                 // output wire result_ap_vld
    );
    
    
    
  
    reg [3:0] detected_r;
    reg load_en;
    reg [10:0] counter;
    
    reg [7:0] pdata_d1r;
    reg pvalid_d1r;
    reg [9:0] paddr_d1r;
    
    always @(posedge clk) begin
        if(~resetn) begin
            counter <= 11'b0;
            
            pdata_d1r <= 8'd0;
            pvalid_d1r <= 1'b0;;
            paddr_d1r <= 10'b0;
        end else begin
            if(pvalid) begin
                counter <= counter + 11'd1;
            end else if(pvsync) begin
                counter <= 11'b0;
            end
            
            pdata_d1r <= pdata;
            pvalid_d1r <= pvalid;
            paddr_d1r <= counter[9:0];
        end
    end
    
    assign wdata = pdata_d1r;
    assign w_en = pvalid_d1r & load_en;
    assign waddr = paddr_d1r;
    
  
    // Control FSM
    reg [2:0] curr_state;
    always @(posedge clk) begin
        if(~resetn) begin
            curr_state <= `ST_RESET;
            detected_r <= 4'b1111;
            load_en <= 1'b0;
            knn_start <= 1'b0;
        end else begin
        
            if(knn_valid) begin
                detected_r <= result[3:0];
            end
            
            
            case(curr_state)
                `ST_RESET : begin
                    curr_state <= `ST_IDLE;
                end
                `ST_IDLE: begin
                    if(enable) begin
                        curr_state <= `ST_LOAD;
                    end
                end
                `ST_LOAD: begin
                    // Allow 28*28 words to be written to the RAM
                    if( (counter == 11'd0) & pvalid) begin
                        load_en <= 1'b1;
                    end
                    if( (paddr_d1r == 11'd783) & load_en & pvalid_d1r) begin
                        curr_state <= `ST_INFER;
                        load_en <= 1'b0;
                    end
                end
                `ST_INFER: begin
                    if(~knn_start & knn_idle) begin
                        knn_start <= 1'b1;
                    end
                    
                    if(knn_start) begin
                        knn_start <= 1'b0;
                    end
                    
                    if(knn_done) begin
                        curr_state <= `ST_IDLE;
                    end
                end
            endcase
        end
    end
    
    
    assign detected = detected_r;
    
    
endmodule
