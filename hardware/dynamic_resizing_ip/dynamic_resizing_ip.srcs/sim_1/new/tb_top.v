`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/28/2025 08:28:37 PM
// Design Name: 
// Module Name: tb_top
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
`define IMAGE_SIZE 921600

module tb_top(

    );
    
    // Clock and resetn gen
    reg clk = 1'b0;
    reg resetn = 1'b0;
    initial forever #5 clk = ~clk;
    initial begin
        #50
        resetn = 1'b1;
    end
    
    
    // Generate video data from file
    reg [23:0] image [`IMAGE_SIZE - 1:0];
    initial begin
        $readmemh("input_image.mem", image);
    end
    
    wire [31:0] vidin_tdata = {8'b0, image[pixcnt]};;
    reg vidin_tlast = 1'b0;
    wire vidin_tready;
    reg vidin_tvalid = 1'b1;
    
    integer pixcnt;
    always @(posedge clk) begin
        if(~resetn) begin
            pixcnt = 0;
        end else begin
            if(vidin_tready)
                #1 pixcnt = (pixcnt + 1) % `IMAGE_SIZE;
        end
    
    end;
    
    wire [23:0] vidin_pData;
    wire vidin_pHSync;
    wire vidin_pVSync;
    wire vidin_pVDE;
    
    // Stream to video
    rgb_gen I_vidgen(
     .clk(clk),
    .resetn(resetn),
    
    .vid_pData(vidin_pData),
    .vid_pHSync(vidin_pHSync),
    .vid_pVSync(vidin_pVSync),
    .vid_pVDE(vidin_pVDE),
    
    .m_axis_tdata(vidin_tdata),
    .m_axis_tlast(vidin_tlast),
    .m_axis_tready(vidin_tready),
    .m_axis_tvalid(vidin_tvalid),
    
    .sw_resetn(1'b1),
    .hdim_m1(32'd1279),
    .vdim_m1(32'd719),
    .ref_rate(32'd267)
    );
    
    
    wire [7:0] vidout_pData;
    wire vidout_pHSync;
    wire vidout_pVSync;
    wire vidout_pVDE;
    
    
    
   
    

    reg update;
    reg [15:0] boxes [24];
    reg vsync_d1r_upper;
    integer boxcount;
    integer cyclecount;
    
    initial begin
        // Read in box coordanate inputs
        $readmemh("boxes_inp.mem", boxes);
    end
    

    
    reg do_updates;
    always @(posedge clk) begin
        if(~resetn) begin
            boxcount = 0;
            cyclecount = 0;
            update = 0;
            vsync_d1r_upper <= 1'b0;
            do_updates = 0;
        end else begin
            vsync_d1r_upper <= vidout_pVSync;
            if(cyclecount == 10 & do_updates) begin
                update = 1;
            end else if(cyclecount == 11) begin
                update = 0;
            end
            
            if(~vidout_pVSync & vsync_d1r_upper) begin
                cyclecount = 0;
                boxcount += 4;
                do_updates = 1;
            end
            
            cyclecount += 1;
        end
    
    end
    wire [15:0] topl_x = boxes[boxcount];
    wire [15:0] topl_y = boxes[boxcount + 1];
    wire [15:0] botr_x = boxes[boxcount + 2];
    wire [15:0] botr_y = boxes[boxcount + 3];
    
    design_1_wrapper I_dut(
        .clk(clk),
        .resetn(resetn),
        
        .top_left_x_0(topl_x),
        .top_left_y_0(topl_y),
        .bot_right_x_0(botr_x),
        .bot_right_y_0(botr_y),
        .update_0(update),
        
        .enable_sub_image_filter(1'b1),
        .resetn_sub_image_filter(1'b1),
        
        .rgb_i_active_video(vidin_pVDE),
        .rgb_i_data(vidin_pData),
        .rgb_i_hsync(vidin_pHSync),
        .rgb_i_vsync(vidin_pVSync),
        
        //.rgb_o_active_video(vidout_pVDE),
        //.rgb_o_data(vidout_pData),
        //.rgb_o_hsync(vidout_pHSync),
        //.rgb_o_vsync(vidout_pVSync)
        .data_o_0(vidout_pData),
        .valid_o_0(vidout_pVDE),
        .vsync_gen_o_0(vidout_pVSync)
     );
    
    
        
    
    // RGB output 
    reg [23:0] img_out [`IMAGE_SIZE - 1:0];
    
    integer outcount;
    integer img_out_count;
    reg vsync_d1r;
    always @(posedge clk) begin
        if(~resetn) begin
            outcount = 0;
            vsync_d1r = 1'b0;
            img_out_count = 0;
        end else begin
            vsync_d1r <= vidout_pVSync;
            if(vidout_pVSync & ~vsync_d1r) begin // save at pos edge vsync
                $writememh($sformatf("ouput_image%0d.mem", img_out_count), img_out);
                $display("Done capturing image, writing it to file. To %s", $sformatf("ouput_image%0d.mem", img_out_count));
                outcount = 0;
                img_out_count += 1;
            end
        
            if(vidout_pVDE) begin
                img_out[outcount] = {vidout_pData, vidout_pData, vidout_pData};
                outcount = outcount + 1;
            end
            
        end
    
    end
    
endmodule
