`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/19/2025 09:33:30 PM
// Design Name: 
// Module Name: dvi_out
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
`define ST_DOWN1 3'b001
`define ST_DOWN2 3'b010
`define ST_UP 3'b011
`define ST_DATA 3'b100



module dvi_out(
    input wire clk,
    input wire resetn,

    // RGB output
    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io:1.0 RGB DATA" *)
    output wire [23:0] vid_pData,
    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io:1.0 RGB HSYNC" *)
    output wire vid_pHSync,
    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io:1.0 RGB VSYNC" *)
    output wire vid_pVSync,
    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io:1.0 RGB ACTIVE_VIDEO" *)
    output wire vid_pVDE,
    
    
    // AXIS input
    (* mark_debug = "true" *) input wire [31:0] m_axis_tdata,
    (* mark_debug = "true" *) input wire m_axis_tlast,
    (* mark_debug = "true" *) output wire m_axis_tready,
    (* mark_debug = "true" *) input wire m_axis_tvalid,
    
    
    input wire sw_resetn,
    input wire [31:0] hdim_m1,
    input wire [31:0] vdim_m1,
    input wire [31:0] ref_rate,
    output err_r
    );
    
    
    // HSYNC block
    // 50 up, 200 down, H_DIM down, 100 down -> repeat = 350 + hdim
    reg [2:0] h_state;
    reg [31:0] counter;
    reg hup;
    always @(posedge clk) begin
        if(~resetn | ~sw_resetn) begin
            h_state <= `ST_RESET;
            counter <= 32'b0;
            hup <= 1'b0;
        end else begin
            case(h_state)
                `ST_RESET: begin
                    h_state <= `ST_UP;
                    counter <= 32'b0;
                end
                `ST_UP: begin
                    hup <= 1'b0;
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
                        hup <= 1'b1;
                    end
                end // end ST_DOWN2
            endcase
        end
    end // END HSYNC always block
    
    
    // DATA block
    /*reg [23:0] data;
    always @(posedge clk) begin
        if(~resetn | ~sw_resetn) begin
            data <= 24'b0;
        end else begin 
            data <= data + 24'b1;
        end
    end*/ // DATA always block
    wire [23:0] data;
    assign data[23:0] = 24'h123456;
    
    // hcylce = (350 + hdim)
    
    // 1 frame time = (N + vdim + 10)*(350 + hdim) * 10ns (clk = 100MHz)
    // N = (desired_frame_time/((350 + hdim)*10ns) - vdim - 10
    // at 720x1280
    //      - 60fps/16ms = 
    
    /* py code
fps = 24
hdim = 1280
vdim = 720
   
desired_frame_time_ns = (1/fps)*1000*1000*1000
(desired_frame_time_ns/((350 + hdim)*10)) - vdim - 10
    
    */
    
    // rep every 1022 hsyncs
    // N (293) down, vdim down, 5 down, 5 up - rep = N + vdim + 10
    reg [2:0] v_state;
    reg [31:0] vcount;
    reg pull_data;
    always @(posedge clk) begin
        if(~resetn | ~sw_resetn) begin
            v_state <= `ST_RESET;
            vcount <= 32'b0;
            pull_data <= 1'b0;
        end else begin
            if(hup) begin
                case(v_state)
                `ST_RESET: begin
                    v_state <= `ST_DOWN1;
                    vcount <= 32'b0;
                 end
                `ST_DOWN1: begin
                    if(vcount < ref_rate) begin
                        vcount <= vcount + 32'b1;
                    end else begin
                        if(m_axis_tvalid) begin // FIFO has the next frame
                            pull_data <= 1'b1;
                        end else begin
                            pull_data <= 1'b0;
                        end
                        vcount <= 32'b0;
                        v_state <= `ST_DATA;
                    end
                end
                `ST_DATA: begin
                    if(vcount < vdim_m1) begin
                        vcount <= vcount + 32'b1;
                    end else begin
                        vcount <= 32'b0;
                        v_state <= `ST_DOWN2;
                    end
                end
                `ST_DOWN2: begin
                    if(vcount <= 5) begin
                        vcount <= vcount + 32'b1;
                    end else begin
                        vcount <= 32'b0;
                        v_state <= `ST_UP;
                    end
                end
                `ST_UP: begin
                    if(vcount <= 5) begin
                        vcount <= vcount + 32'b1;
                    end else begin
                        vcount <= 32'b0;
                        v_state <= `ST_DOWN1;
                    end
                end
                endcase
            end
        end
    end // End VSYNC block
    
    
    // VSYNC block
    
    assign vid_pHSync = (h_state == `ST_UP);
    assign vid_pVSync = (v_state == `ST_UP);
    assign vid_pVDE = (h_state == `ST_DATA) & (v_state == `ST_DATA);
   
   // AXIS/Data
    assign vid_pData[23:0] = (pull_data) ? (m_axis_tdata[23:0]) : (data);
    assign m_axis_tready = (pull_data) ? ((h_state == `ST_DATA) & (v_state == `ST_DATA)) : (1'b0);
    assign error = m_axis_tready & ~m_axis_tvalid;
    // m_axis_tlast
    
    
    reg err_r;
    always @(posedge clk) begin
        if(~resetn | ~sw_resetn) begin
            err_r <= 1'b0;
        end else begin
            if(error) begin
                err_r <= 1'b1;
            end else
                err_r <= err_r;
        end
    
    end
    
   
endmodule
