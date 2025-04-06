`timescale 1ns / 1ps


`define ST_RESET 3'b000
`define ST_WAIT_V 3'b001
`define ST_READ_B1 3'b010
`define ST_READ_H 3'b011
`define ST_ERROR 3'b100
`define ST_DONE 3'b101



module rgb_to_stream
    (
    // Clock and reset 
    input wire clk,
    input wire resetn,
    
    // Video signals
    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io:1.0 RGB DATA" *)
    input wire [23:0] vid_pData,
    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io:1.0 RGB HSYNC" *)
    input wire vid_pHSync,
    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io:1.0 RGB VSYNC" *)
    input wire vid_pVSync,
    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io:1.0 RGB ACTIVE_VIDEO" *)
    input wire vid_pVDE,
    
    
    // AXIS output
    (* mark_debug = "true" *) output wire [31:0] m_axis_tdata,
    (* mark_debug = "true" *) output wire m_axis_tlast,
    (* mark_debug = "true" *) input wire m_axis_tready,
    (* mark_debug = "true" *) output wire m_axis_tvalid,
    
    // Control and Status 
    input wire sw_reset,
    input wire send_frame,
    input wire [31:0] hdim_m1,
    input wire [31:0] vdim_m1,
    
    
    (* mark_debug = "true" *)input wire [31:0] fifo_counter
    );
    
    
    // Input RGB data
    wire [23:0] pdata = vid_pData;
    wire vsync = vid_pVSync;
    wire hsync = vid_pHSync;
    wire valid = vid_pVDE;
    
    
    
    (* mark_debug = "true" *) reg [2:0] curr_state;
    (* mark_debug = "true" *) reg [31:0] hor_count;
    (* mark_debug = "true" *) reg [31:0] ver_count;
    reg vsync_d1r, hsync_d1r;
    
    reg [23:0] tdata_r;
    reg tlast_r;
    reg tvalid_r;
    
    // Frame control
    reg send_frame_d1r;
    (* mark_debug = "true" *) reg frame_pulse;
    (* mark_debug = "true" *) reg do_frame;
    always @(posedge clk) begin
        if(~sw_reset | ~resetn) begin
            send_frame_d1r <= 1'b0;
        end else begin
            send_frame_d1r <= send_frame;
            if(send_frame_d1r & ~send_frame) begin // Neg edge
                frame_pulse <= 1'b1;
            end else begin
                frame_pulse <= 1'b0;
            end
            
        end
    end
    
    
    always @(posedge clk) begin
        if(~sw_reset | ~resetn) begin
            // State reg
            curr_state <= `ST_RESET;  
            
            // Counter regs
            hor_count <= 32'b0;
            ver_count <= 32'b0;
            
            // Other regs
            vsync_d1r <= 1'b0;
            hsync_d1r <= 1'b0;
            do_frame <= 1'b0;
            
            // AXIS regs
            tlast_r <= 1'b0;
            tvalid_r <= 1'b0;
            tdata_r <= 24'b0;
            
            
        end else begin
            vsync_d1r <= vsync;
            hsync_d1r <= hsync;
            tdata_r[23:0] <= vid_pData[23:0];

            if(frame_pulse) begin
                do_frame <= 1'b1;
            end
           
            
                       
            case(curr_state)
                `ST_RESET: begin
                    curr_state <= `ST_WAIT_V;
                end
                `ST_WAIT_V: begin
                        ver_count[31:0] <= 32'b0;
                        // Find start of frame - neg edge of vsync
                        if(vsync_d1r & ~vsync & do_frame) begin
                            curr_state <= `ST_READ_B1;
                            if(~frame_pulse)
                                do_frame <= 1'b0;
                        end
                 end
                 `ST_READ_B1: begin
                    if(~m_axis_tready & tvalid_r ) begin
                            curr_state <= `ST_ERROR; // FIFO not able to recive the data
                    end
                    
                    
                    if(valid) begin
                        tvalid_r <= 1'b1;
                        
                        hor_count[31:0] <= hor_count[31:0] + 32'b1;
                        
                        //  (hor_count[31:0] == (hdim_m1[31:0] - 1)) // REMOVE THE MINUS ONE ON HDIM_M1 
                        if( (hor_count[31:0] == (hdim_m1[31:0])) & (ver_count[31:0] == vdim_m1[31:0])) begin
                            tlast_r <= 1'b1;
                        end else begin
                            tlast_r <= 1'b0;
                        end
                        
                    end else begin
                        tvalid_r <= 1'b0;
                        tlast_r <= 1'b0;
                        if(hsync & ~hsync_d1r) begin // Pos edge hsync
                            if(hor_count[31:0] != 32'b0) begin
                                hor_count[31:0] <= 32'b0;
                                ver_count[31:0] <= ver_count[31:0] + 32'b1;
                            end
                        end
                        if(vsync) begin
                            curr_state <= `ST_WAIT_V;
                        end
                    end
                 end
                 `ST_ERROR: begin
                    
                 end
            
            endcase
        end
    end // always block FSM
    
    
    
    // Valid will follow upx1-9
    reg [3:0] counter;
    always @(posedge clk) begin
        if(~sw_reset | ~resetn) begin
            counter <= 4'b0;
        end else begin
            if(tvalid_r) begin
                if(counter >= 4'd3) begin
                    counter <= 4'd0;
                end else
                    counter <= counter + 4'b1;
            end

        end
    end

   
    
    assign m_axis_tdata[31:0] = {8'b0, tdata_r[23:0]};
    assign m_axis_tlast = tlast_r;
    //  (tvalid_r) & (counter != 4'd3);
    assign m_axis_tvalid = tvalid_r;
    
endmodule
