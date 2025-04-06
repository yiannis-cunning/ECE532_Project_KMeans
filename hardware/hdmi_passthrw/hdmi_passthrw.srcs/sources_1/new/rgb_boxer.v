`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/21/2025 02:55:45 PM
// Design Name: 
// Module Name: rgb_boxer
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
`define ST_READ_H 3'b011
`define ST_ERROR 3'b100
`define ST_DONE 3'b101


module rgb_boxer( 
    input wire clk,
    input wire resetn,
    
    // Video signals in
    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io:1.0 RGB_i DATA" *)
    input wire [23:0] vid_pData_i,
    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io:1.0 RGB_i HSYNC" *)
    input wire vid_pHSync_i,
    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io:1.0 RGB_i VSYNC" *)
    input wire vid_pVSync_i,
    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io:1.0 RGB_i ACTIVE_VIDEO" *)
    input wire vid_pVDE_i,

     // Video signals out
    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io:1.0 RGB_o DATA" *)
    output wire [23:0] vid_pData_o,
    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io:1.0 RGB_o HSYNC" *)
    output wire vid_pHSync_o,
    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io:1.0 RGB_o VSYNC" *)
    output wire vid_pVSync_o,
    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io:1.0 RGB_o ACTIVE_VIDEO" *)
    output wire vid_pVDE_o,
    
    
    // Control and Status
    input wire sw_reset,
    input wire box_en,
    
    input wire [31:0] top_left,
    input wire [31:0] bottom_right,
    input wire [7:0]  thickness,
    
    input wire [23:0] color
    
    );
    
    
    reg [2:0] curr_state;
    reg [31:0] hor_count;
    reg [31:0] ver_count;
    reg vsync_d1r;
    reg hsync_d1r;
    
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
 
        end else begin
            vsync_d1r <= vid_pVSync_i;
            hsync_d1r <= vid_pHSync_i;    
                       
            case(curr_state)
                `ST_RESET: begin
                    curr_state <= `ST_WAIT_V;
                end
                `ST_WAIT_V: begin
                        ver_count[31:0] <= 32'b0;
                        // Find start of frame - neg edge of vsync
                        if(vsync_d1r & ~vid_pVSync_i) begin
                            curr_state <= `ST_READ_B1;
                        end
                 end
                 `ST_READ_B1: begin
                    if(vid_pVDE_i) begin
                        hor_count[31:0] <= hor_count[31:0] + 32'b1;
                    end else begin
                        if(vid_pHSync_i & ~hsync_d1r) begin // Pos edge hsync
                            if(hor_count[31:0] != 32'b0) begin
                                hor_count[31:0] <= 32'b0;
                                ver_count[31:0] <= ver_count[31:0] + 32'b1;
                            end
                        end
                        if(vid_pVSync_i) begin
                            curr_state <= `ST_WAIT_V;
                        end
                    end
                 end
                 `ST_ERROR: begin
                    
                 end
            
            endcase
        end
    end // always block FSM
    
    
    reg [63:0] outter_box;
    reg [63:0] inner_box;
    always @(posedge clk) begin
        if(~resetn | ~sw_reset) begin
            outter_box <= 64'b0;
            inner_box <= 64'b0;
        end else begin
        
        
            // OUTTER BOX
            
            // 1) Smallest X
            if(top_left[15:0] > {8'b0, thickness[7:0]}) 
                outter_box[15:0] <= top_left[15:0] - {8'b0, thickness[7:0]}; //28
            else
                outter_box[15:0] <= 16'b0;
            
            // 2) Smallest Y
            if(top_left[31:16] > {8'b0, thickness[7:0]}) 
                outter_box[31:16] <= top_left[31:16] - {8'b0, thickness[7:0]};
            else
                outter_box[31:16] <= 16'b0;
                
            // 3) Largest X
            outter_box[47:32] <= bottom_right[15:0] + {8'b0, thickness[7:0]};
            
            // 4) Largest Y
            outter_box[63:48] <= bottom_right[31:16] + {8'b0, thickness[7:0]};
            
            
            // INNER BOX
            // Smallest X
            inner_box[15:0] <= top_left[15:0] + {8'b0, thickness[7:0]};
            // Smallest Y
            inner_box[31:16] <= top_left[31:16] + {8'b0, thickness[7:0]};
            // Largest X
            inner_box[47:32] <= bottom_right[15:0] - {8'b0, thickness[7:0]};
            // Largest Y
            inner_box[63:48] <= bottom_right[31:16] - {8'b0, thickness[7:0]};
            
        end
    end
    
    wire inside_outter;
    wire inside_inner;
    inrange I_outside( 
        .x(hor_count),
        .y(ver_count),
        .x1(outter_box[15:0]),
        .y1(outter_box[31:16]),
        .x2(outter_box[47:32]),
        .y2(outter_box[63:48]),
        
        .is_inside(inside_outter)
        );
    inrange I_inside( 
        .x(hor_count),
        .y(ver_count),
        .x1(inner_box[15:0]),
        .y1(inner_box[31:16]),
        .x2(inner_box[47:32]),
        .y2(inner_box[63:48]),
        
        .is_inside(inside_inner)
        );
        
    assign inrange = inside_outter & ~inside_inner;

    

    assign vid_pHSync_o = vid_pHSync_i;
    assign vid_pVSync_o = vid_pVSync_i;
    assign vid_pVDE_o = vid_pVDE_i;
    assign vid_pData_o = (inrange & box_en) ? (color) : (vid_pData_i);
    
endmodule


module inrange(
    input wire [31:0] x,
    input wire [31:0] y,
    input wire [31:0] x1,
    input wire [31:0] x2,
    input wire [31:0] y1,
    input wire [31:0] y2,
    output wire is_inside
);
    assign is_inside = (x >= x1) & (x <= x2) & (y >= y1) & (y <= y2);

endmodule
