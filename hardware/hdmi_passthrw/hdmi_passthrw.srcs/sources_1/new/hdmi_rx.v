`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/10/2025 03:49:50 PM
// Design Name: 
// Module Name: pixel_rx
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
`define ST_WAIT_V 3'b001
`define ST_READ_B1 3'b010
`define ST_READ_B2 3'b011
`define ST_READ_B3 3'b100
`define ST_DONE 3'b101


module hdmi_rx(

    // Clock and reset 
    input wire aclk,
    input wire aresetn,
    
    // Video signals
    input wire [23:0] m_axis_video_tdata,
    input wire m_axis_video_tlast,
    output wire m_axis_video_tready,
    input wire m_axis_video_tuser,
    input wire m_axis_video_tvalid,
    
    // HDMI sigs
    output wire hpd,
    
    // Control and Status 
    input wire [3:0] control,
    output wire [3:0] status
    );
    
    wire [23:0] pdata = m_axis_video_tdata;
    wire last = m_axis_video_tlast;
    wire first = m_axis_video_tuser;
    wire valid = m_axis_video_tvalid;
    
    
    assign m_axis_video_tready = 1'b1;
    
    
    reg [2:0] curr_state;
    reg [23:0] pix_value;
    (* mark_debug = "true" *) reg [31:0] pcount;
    (* mark_debug = "true" *) reg [63:0] psum;
    
    always @(posedge aclk) begin
        if(~control[0] | ~aresetn) begin
            curr_state <= `ST_RESET;  
            pcount <= 32'b0;
            pix_value <= 24'b0;
            psum <= 64'b0;
        end else begin
            case(curr_state)
                `ST_RESET: begin
                    curr_state <= `ST_WAIT_V;
                end
                `ST_WAIT_V: begin
                        // Start of frame
                        if((first == 1'b1) & (valid)) begin
                            pix_value <= pdata;
                            curr_state <= `ST_READ_B1;
                            pcount <= 32'b1;
                            psum <= pdata;
                        end
                 end
                 `ST_READ_B1: begin
                    if(valid) begin
                        pcount <= pcount + 1;
                        psum <= psum + pdata;
                        if(last) begin
                            curr_state <= `ST_DONE;
                        end
                    end
                 end
                 `ST_DONE: begin
                   
                 end
            
            endcase
        end
    end // always block FSM
    
    assign status[2:0] = curr_state[2:0];
    assign status[3] = 1'b0;
    assign hpd = control[1];
endmodule
