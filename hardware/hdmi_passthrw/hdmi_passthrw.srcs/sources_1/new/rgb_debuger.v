`timescale 1ns / 1ps


`define ST_RESET 3'b000
`define ST_WAIT_V 3'b001
`define ST_READ_B1 3'b010
`define ST_READ_H 3'b011
`define ST_READ_B3 3'b100
`define ST_DONE 3'b101

/*
    This module will be a debugging probe for looking at the RGB interface
        - It can be reset with a switch
        - It will try to lock to frame syncrhonization signals
        - Through debugging probes it will show
            - Number of horrizontal pixels
            - Number of vertical pixels
            - Sum of R, G and B components

*/
module rgb_debuger(
    // Clock and reset 
    input wire clk,
    input wire resetn,
    
    // Video signals
    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io:1.0 RGB DATA" *)
    (* mark_debug = "true" *) input wire [23:0] vid_pData,
    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io:1.0 RGB HSYNC" *)
    (* mark_debug = "true" *) input wire vid_pHSync,
    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io:1.0 RGB VSYNC" *)
    (* mark_debug = "true" *) input wire vid_pVSync,
    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io:1.0 RGB ACTIVE_VIDEO" *)
    (* mark_debug = "true" *) input wire vid_pVDE,
    
    // Control and Status 
    input wire sw_reset
    );
    

    wire [23:0] pdata = vid_pData;
    wire vsync = vid_pVSync;
    wire hsync = vid_pHSync;
    wire valid = vid_pVDE;


    (* mark_debug = "true" *) reg [2:0] curr_state;
    (* mark_debug = "true" *) reg [31:0] r_count;
    (* mark_debug = "true" *) reg [31:0] g_count;
    (* mark_debug = "true" *) reg [31:0] b_count;
    (* mark_debug = "true" *) reg [31:0] hor_count;
    (* mark_debug = "true" *) reg [31:0] hor_count_max;
    (* mark_debug = "true" *) reg [31:0] ver_count;
    
    reg vsync_d1r, hsync_d1r;
    
    always @(posedge clk) begin
        if(~sw_reset | ~resetn) begin
            // State reg
            curr_state <= `ST_RESET;  
            
            // Counter regs
            r_count <= 32'b0;
            g_count <= 32'b0;
            b_count <= 32'b0;
            hor_count <= 32'b0;
            hor_count_max <= 32'b0;
            ver_count <= 32'b0;
            
            // Other regs
            vsync_d1r <= 1'b0;
            hsync_d1r <= 1'b0;
        end else begin
            vsync_d1r <= vsync;
            hsync_d1r <= hsync;
            
            case(curr_state)
                `ST_RESET: begin
                    curr_state <= `ST_WAIT_V;
                end
                `ST_WAIT_V: begin
                        // Find start of frame - neg edge of vsync
                        if(vsync_d1r & ~vsync) begin
                            curr_state <= `ST_READ_B1;
                        end
                 end
                 `ST_READ_B1: begin
                    if(valid) begin
                        r_count[31:0] <= r_count[31:0] + {24'b0, vid_pData[7:0]};
                        g_count[31:0] <= g_count[31:0] + {24'b0, vid_pData[15:8]};
                        b_count[31:0] <= b_count[31:0] + {24'b0, vid_pData[23:16]};
                        
                        hor_count[31:0] <= hor_count[31:0] + 32'b1;
                        
                    end else begin
                        if(hsync & ~hsync_d1r) begin // Pos edge hsync
                            if(hor_count[31:0] != 32'b0) begin
                                hor_count[31:0] <= 32'b0;
                                ver_count[31:0] <= ver_count[31:0] + 32'b1;
                            end
                            if(hor_count[31:0] > hor_count_max[31:0]) begin
                                hor_count_max[31:0] <= hor_count[31:0];
                            end
                        end
                        if(vsync) begin
                            curr_state <= `ST_DONE;
                        end
                    end
                 end

                 `ST_DONE: begin
                   
                 end
            
            endcase
        end
    end // always block FSM
    

endmodule
