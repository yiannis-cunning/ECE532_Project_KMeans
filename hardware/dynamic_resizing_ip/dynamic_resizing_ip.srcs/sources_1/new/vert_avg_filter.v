`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/01/2025 11:15:37 PM
// Design Name: 
// Module Name: vert_avg_filter
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
`define ST_INIT 3'b001
`define ST_UPDATE_SUMS 3'b010
`define ST_INC_PIXEL 3'b011
`define ST_INC_DEST 3'b100
`define ST_DONE_FRAME 3'b101
`define ST_INC 3'b110
`define ST_INC_BOTH 3'b111

module vert_avg_filter(
    input wire clk,
    input wire resetn,
    
    // Video signals in - From FIFO
    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io:1.0 RGB_i DATA" *)
    input wire [7:0] vid_pData_i,
    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io:1.0 RGB_i HSYNC" *)
    input wire vid_pHSync_i,
    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io:1.0 RGB_i VSYNC" *)
    input wire vid_pVSync_i,
    (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io:1.0 RGB_i ACTIVE_VIDEO" *)
    input wire vid_pVDE_i,
    
    output wire vid_pReady_i,
    
    
    output wire [23:0] data_o,
    output wire valid_o,
    output reg vsync_gen_o,
    
    // Control and status
    input wire [23:0] dy,
    input wire [23:0] vdim
    );
    
    
    

        
        
    // Coordanates
    reg [23:0] pleft;
    reg [23:0] pright;
    reg [23:0] dest_left;
    reg [23:0] dest_right;
    reg [7:0] sums_num;
    
    // Coefficent vars
    reg [23:0] a;
    reg [23:0] b;
    reg [23:0] f;
    always @(*) begin
        a = (dest_left > pleft) ? (dest_left) : (pleft); // Find left bound - max of lefts
        b = (dest_right < pright) ? (dest_right) : (pright); // Find left bound - min of right
        f = (b - a);
    end
    
    
    // Req and Ack signals
    reg pix_req;
    wire pix_ack;
    reg mac_req;
    wire mac_ack;
    reg out_req;
    wire out_ack;
    
    // CONTROL FSM
    reg [2:0] curr_state;
    always @(posedge clk) begin
        if(~resetn) begin
            curr_state <= `ST_RESET;
            pix_req <= 1'b0;
            mac_req <= 1'b0;
            out_req <= 1'b0;

            sums_num <= 8'b0;
            pleft <= 24'b0;
            pright <= 24'b0;
            dest_left <= 24'b0;
            dest_right <= 24'b0;
            
            vsync_gen_o <= 1'b0;
        end else begin
            case(curr_state)
                `ST_RESET: begin
                    curr_state <= `ST_INIT;
                end
                `ST_INIT: begin
                    // Reset cords
                    sums_num <= 8'b0;
                    pleft <= 24'b0;
                    pright <= {16'b1, 8'b0};
                    dest_left <= 24'b0;
                    dest_right <= dy;
                    if(~vid_pVSync_i) begin
                        curr_state <= `ST_INC_PIXEL;
                        vsync_gen_o <= 1'b0;
                    end
                end
                `ST_UPDATE_SUMS: begin
                    // Req/ack with MAC
                    if(~mac_req & ~mac_ack) begin
                        mac_req <= 1'b1;
                    end if( mac_req & mac_ack) begin
                        mac_req <= 1'b0;
                        curr_state <= `ST_INC;
                    end
                end
                `ST_INC: begin
                    if( (dest_right == vdim) & (pright == vdim) ) begin
                        curr_state <= `ST_DONE_FRAME;
                        out_req <= 1'b1;
                    end else if(dest_right == pright) begin
                        // INCREMENT BOTH
                        pleft <= pright;
                        pright <= pright + {16'b1, 8'b0};
                        sums_num <= sums_num + 8'b1;
                        if(sums_num != 26) begin
                            dest_left <= dest_right;
                            dest_right <= dest_right + dy;
                        end else begin
                            dest_left <= dest_right;
                            dest_right <= vdim;
                        end
                        curr_state <= `ST_INC_BOTH;
                        pix_req <= 1'b1;
                        out_req <= 1'b1;
                    end else if(dest_right > pright) begin
                        // INCREMENT PIXEL
                        pleft <= pright;
                        pright <= pright + {16'b1, 8'b0};
                        curr_state <= `ST_INC_PIXEL;
                    end else begin
                        // INCREMENT SUM
                        sums_num <= sums_num + 8'b1;
                        if(sums_num != 26) begin
                            dest_left <= dest_right;
                            dest_right <= dest_right + dy;
                        end else begin
                            dest_left <= dest_right;
                            dest_right <= vdim;
                        end
                        curr_state <= `ST_INC_DEST;
                    end
                end
                `ST_INC_PIXEL: begin
                    // Req/ack with pixel load
                    if(~pix_req & ~pix_ack) begin
                        pix_req <= 1'b1;
                    end if( pix_req & pix_ack) begin
                        pix_req <= 1'b0;
                        curr_state <= `ST_UPDATE_SUMS;
                    end
                end
                `ST_INC_DEST: begin
                    // Req/ack with sum output buffer
                    if(~out_req & ~out_ack) begin
                        out_req <= 1'b1;
                    end if( out_req & out_ack) begin
                        out_req <= 1'b0;
                        curr_state <= `ST_UPDATE_SUMS;
                    end
                end
                `ST_INC_BOTH: begin
                    if(out_ack)
                        out_req <= 1'b0;
                    if(pix_ack)
                        pix_req <= 1'b0;
                    
                    if(~pix_req & ~out_req)
                        curr_state <= `ST_UPDATE_SUMS;
                end
                `ST_DONE_FRAME: begin
                    if(out_ack)
                        out_req <= 1'b0;
                    
                    if(~out_req & vid_pVSync_i) begin
                        vsync_gen_o <= 1'b1;
                        curr_state <= `ST_INIT; 
                    end
                end
            
            endcase
        end
    end



    // Pixel buffer
    wire [4:0] inp_waddr;
    wire [4:0] mac_raddr;
    
    wire [4:0] pixram_addr = (pix_req) ? (inp_waddr) : (mac_raddr);
    wire [7:0] pixram_wdata;
    wire [7:0] pixram_rdata;
    wire pixram_we;
    
    dist_mem_vert_pix_buf I_pix_buf(
        .clk(clk),
        .a(pixram_addr),
        .d(pixram_wdata),
        .spo(pixram_rdata),
        .we(pixram_we)
    );
    
    
    // Sum buffer
    // Port 1 - to output block
    wire [4:0] sumram_waddr_1;
    wire [23:0] sumram_wdata_1;
    wire sumram_we_1;
    wire [4:0] sumram_raddr_1;
    
    // Port 2 - to mac block
    wire [4:0] sumram_waddr_2;
    wire [23:0] sumram_wdata_2;
    wire sumram_we_2;
    wire [4:0] sumram_raddr_2;

    // Port mux
    wire [4:0] sumram_waddr     = (out_req) ? (sumram_waddr_1) : (sumram_waddr_2);
    wire [23:0] sumram_wdata    = (out_req) ? (sumram_wdata_1) : (sumram_wdata_2);
    wire sumram_we              = (out_req) ? (sumram_we_1) : (sumram_we_2);
    wire [4:0] sumram_raddr     = (out_req) ? (sumram_raddr_1) : (sumram_raddr_2);
    wire [23:0] sumram_rdata;
    
    dist_mem_vert_sum_buf I_sum_buf(
        .clk(clk),
        .a(sumram_waddr),   // Write
        .d(sumram_wdata),
        .we(sumram_we),
        .dpra(sumram_raddr), // Read
        .dpo(sumram_rdata)

    );


    // Sum buffer

    vert_avg_input I_input_buf(
        .clk(clk),
        .resetn(resetn),
        
        // From FIFO
        .pdata(vid_pData_i),
        .pvalid(vid_pVDE_i),
        .pready(vid_pReady_i),
        
        // To Pixel buffer
        .waddr(inp_waddr),
        .wdata(pixram_wdata),
        .we(pixram_we),
        
        // To FSM
        .req(pix_req),
        .ack(pix_ack)
    );
    
    
    


    vert_avg_mac I_mac(
        .clk(clk),
        .resetn(resetn),
        
        // Pixel buffer
        .pixel_raddr(mac_raddr),
        .pixel_rdata(pixram_rdata),
        
        // Sum buffer
        .sum_raddr(sumram_raddr_2),
        .sum_rdata(sumram_rdata),
        .sum_waddr(sumram_waddr_2),
        .sum_wdata(sumram_wdata_2),
        .sum_we(sumram_we_2),
        
        // FSM
        .f(f),
        .req(mac_req),
        .ack(mac_ack)
    );
    

    
    vert_avg_output I_output(
        .clk(clk),
        .resetn(resetn),
        
        // To sum buffer
        .sum_raddr(sumram_raddr_1),
        .sum_rdata(sumram_rdata),
        .sum_waddr(sumram_waddr_1),
        .sum_wdata(sumram_wdata_1),
        .sum_we(sumram_we_1),
        
        // To output AXIS
        .data_o(data_o),
        .valid_o(valid_o),
       
        // To FSM
        .req(out_req),
        .ack(out_ack)
    );

    
endmodule
