`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/17/2025 09:52:20 AM
// Design Name: 
// Module Name: axis_to_rgb
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

`define ST_UP 3'b000
`define ST_DOWN1 3'b001
`define ST_DATA 3'b010
`define ST_DOWN2 3'b011


`define ST_WAIT_DATA 2'b00
`define ST_WAIT_H 2'b01
`define ST_C 2'b10

module axis_to_rgb(
    // Clock and reset 
    input wire clk,
    input wire resetn,

    // AXIS input
    (* mark_debug = "true" *) input wire [31:0] m_axis_tdata,
    (* mark_debug = "true" *)input wire m_axis_tlast,
    (* mark_debug = "true" *) output wire m_axis_tready,
    (* mark_debug = "true" *) input wire m_axis_tvalid,
    
    // RGB output
    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io:1.0 RGB DATA" *)
    output wire [23:0] vid_pData,
    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io:1.0 RGB HSYNC" *)
    output wire vid_pHSync,
    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io:1.0 RGB VSYNC" *)
    output wire vid_pVSync,
    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io:1.0 RGB ACTIVE_VIDEO" *)
    output wire vid_pVDE,
    
    
    // Control and Status 
    input wire sw_reset,
    input wire send_frame,
    input wire [31:0] hdim_m1,
    input wire [31:0] vdim_m1
    
    );
    
    
    // HSYNC block
    // 50 up, 200 down, H_DIM down, 100 down -> repeat
    reg [2:0] h_state;
    reg [31:0] counter;
    always @(posedge clk) begin
        if(~resetn | ~sw_reset) begin
            h_state <= `ST_RESET;
            counter <= 32'b0;
        end else begin
            case(h_state)
                `ST_RESET: begin
                    h_state <= `ST_UP;
                    counter <= 32'b0;
                end
                `ST_UP: begin
                    if(counter < 50) begin
                        counter <= counter + 32'b1;
                    end else begin
                        counter <= 32'b0;
                        h_state <= `ST_DOWN1;
                    end
                end // end ST_UP
                `ST_DOWN1: begin
                    if(counter < 200) begin
                        counter <= counter + 32'b1;
                    end else begin
                        counter <= 32'b0;
                        h_state <= `ST_DATA;
                    end
                end // end ST_DOWN1
                `ST_DATA: begin
                    if(counter < hdim_m1) begin
                        counter <= counter + 32'b1;
                    end else begin
                        counter <= 32'b0;
                        h_state <= `ST_DOWN2;
                    end
                end // end ST_DATA
                `ST_DOWN2: begin
                    if(counter < 100) begin
                        counter <= counter + 32'b1;
                    end else begin
                        counter <= 32'b0;
                        h_state <= `ST_UP;
                    end
                end // end ST_DOWN2
            endcase
        end
    end // END HSYNC always block
    
    assign vid_pHSync = (h_state == `ST_UP);
    
            // Output generation
    reg [23:0] pdata;
    reg hsync;
    reg vsync;
    reg valid;
    
    
    
    assign vid_pData[23:0] = pdata[23:0];
    assign vid_pVSync = vsync;
    assign vid_pVDE = valid;
    
    
    // VSYNC/Data block
    reg [2:0] v_state;
    reg send_frame_d1r;
    reg tready;
    always @(posedge clk) begin
        if(~resetn | ~sw_reset) begin
            v_state <= `ST_RESET;
            tready <= 1'b0;
        end else begin
            case(v_state)
                `ST_RESET: begin
                    v_state <= `ST_RESET;
                end
                `ST_WAIT_DATA: begin
                    if(m_axis_tvalid) begin // when fifo has data
                        v_state <= `ST_WAIT_H;
                    end
                end // ST_WAIT_DATA
            
            endcase
        end
    end // END VSYNC/DATA always block
    
    
    
endmodule
