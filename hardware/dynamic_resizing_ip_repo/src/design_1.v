//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2023.2 (win64) Build 4029153 Fri Oct 13 20:14:34 MDT 2023
//Date        : Mon Mar  3 09:52:16 2025
//Host        : DESKTOP-EDGHBVS running 64-bit major release  (build 9200)
//Command     : generate_target design_1.bd
//Design      : design_1
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "design_1,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=design_1,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=9,numReposBlks=9,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=7,numPkgbdBlks=0,bdsource=USER,synth_mode=Hierarchical}" *) (* HW_HANDOFF = "design_1.hwdef" *) 
module design_1
   (bot_right_x_0,
    bot_right_y_0,
    clk,
    data_o_0,
    enable_sub_image_filter,
    resetn,
    resetn_sub_image_filter,
    rgb_i_active_video,
    rgb_i_data,
    rgb_i_hsync,
    rgb_i_vsync,
    top_left_x_0,
    top_left_y_0,
    update_0,
    valid_o_0,
    vsync_gen_o_0);
  input [15:0]bot_right_x_0;
  input [15:0]bot_right_y_0;
  input clk;
  output [7:0]data_o_0;
  input enable_sub_image_filter;
  input resetn;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.RESETN_SUB_IMAGE_FILTER RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.RESETN_SUB_IMAGE_FILTER, INSERT_VIP 0, POLARITY ACTIVE_LOW" *) input resetn_sub_image_filter;
  (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io:1.0 rgb_i ACTIVE_VIDEO" *) input rgb_i_active_video;
  (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io:1.0 rgb_i DATA" *) input [23:0]rgb_i_data;
  (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io:1.0 rgb_i HSYNC" *) input rgb_i_hsync;
  (* X_INTERFACE_INFO = "xilinx.com:interface:vid_io:1.0 rgb_i VSYNC" *) input rgb_i_vsync;
  input [15:0]top_left_x_0;
  input [15:0]top_left_y_0;
  input update_0;
  output valid_o_0;
  output vsync_gen_o_0;

  wire [7:0]axis_data_fifo_0_m_axis_tdata;
  wire axis_data_fifo_0_m_axis_tvalid;
  wire [7:0]axis_data_fifo_1_m_axis_tdata;
  wire axis_data_fifo_1_m_axis_tvalid;
  wire [15:0]bot_right_x_0_1;
  wire [15:0]bot_right_y_0_1;
  wire clk_1;
  wire [31:0]constant_control_0_botr;
  wire [23:0]constant_control_0_dx;
  wire [23:0]constant_control_0_dy;
  wire [16:0]constant_control_0_factor_h;
  wire [16:0]constant_control_0_factor_w;
  wire [23:0]constant_control_0_hdim_w;
  wire [31:0]constant_control_0_topl;
  wire [23:0]constant_control_0_vdim_h;
  wire enable_sub_image_filter_1;
  wire hor_avg_filter_0_RGB_o_ACTIVE_VIDEO;
  wire [23:0]hor_avg_filter_0_RGB_o_DATA;
  wire hor_avg_filter_0_RGB_o_HSYNC;
  wire hor_avg_filter_0_RGB_o_VSYNC;
  wire hor_avg_filter_0_vid_pReady_i;
  wire [7:0]luminance_filter_0_vid_pData_o;
  wire luminance_filter_0_vid_pHSync_o;
  wire luminance_filter_0_vid_pVDE_o;
  wire luminance_filter_0_vid_pVSync_o;
  wire [7:0]normalizer_0_vid_pData_o;
  wire normalizer_0_vid_pHSync_o;
  wire normalizer_0_vid_pVDE_o;
  wire normalizer_0_vid_pVSync_o;
  wire [7:0]normalizer_1_vid_pData_o;
  wire normalizer_1_vid_pVDE_o;
  wire normalizer_1_vid_pVSync_o;
  wire resetn_1;
  wire rgb_i_1_ACTIVE_VIDEO;
  wire [23:0]rgb_i_1_DATA;
  wire rgb_i_1_HSYNC;
  wire rgb_i_1_VSYNC;
  wire sub_image_filter_0_RGB_o_ACTIVE_VIDEO;
  wire [23:0]sub_image_filter_0_RGB_o_DATA;
  wire sub_image_filter_0_RGB_o_HSYNC;
  wire sub_image_filter_0_RGB_o_VSYNC;
  wire sw_reset_0_1;
  wire [15:0]top_left_x_0_1;
  wire [15:0]top_left_y_0_1;
  wire update_0_1;
  wire [23:0]vert_avg_filter_0_data_o;
  wire vert_avg_filter_0_valid_o;
  wire vert_avg_filter_0_vid_pReady_i;
  wire vert_avg_filter_0_vsync_gen_o;

  assign bot_right_x_0_1 = bot_right_x_0[15:0];
  assign bot_right_y_0_1 = bot_right_y_0[15:0];
  assign clk_1 = clk;
  assign data_o_0[7:0] = normalizer_1_vid_pData_o;
  assign enable_sub_image_filter_1 = enable_sub_image_filter;
  assign resetn_1 = resetn;
  assign rgb_i_1_ACTIVE_VIDEO = rgb_i_active_video;
  assign rgb_i_1_DATA = rgb_i_data[23:0];
  assign rgb_i_1_HSYNC = rgb_i_hsync;
  assign rgb_i_1_VSYNC = rgb_i_vsync;
  assign sw_reset_0_1 = resetn_sub_image_filter;
  assign top_left_x_0_1 = top_left_x_0[15:0];
  assign top_left_y_0_1 = top_left_y_0[15:0];
  assign update_0_1 = update_0;
  assign valid_o_0 = normalizer_1_vid_pVDE_o;
  assign vsync_gen_o_0 = normalizer_1_vid_pVSync_o;
  design_1_axis_data_fifo_0_1 axis_data_fifo_0
       (.m_axis_tdata(axis_data_fifo_0_m_axis_tdata),
        .m_axis_tready(hor_avg_filter_0_vid_pReady_i),
        .m_axis_tvalid(axis_data_fifo_0_m_axis_tvalid),
        .s_axis_aclk(clk_1),
        .s_axis_aresetn(resetn_1),
        .s_axis_tdata(luminance_filter_0_vid_pData_o),
        .s_axis_tvalid(luminance_filter_0_vid_pVDE_o));
  design_1_axis_data_fifo_1_0 axis_data_fifo_1
       (.m_axis_tdata(axis_data_fifo_1_m_axis_tdata),
        .m_axis_tready(vert_avg_filter_0_vid_pReady_i),
        .m_axis_tvalid(axis_data_fifo_1_m_axis_tvalid),
        .s_axis_aclk(clk_1),
        .s_axis_aresetn(resetn_1),
        .s_axis_tdata(normalizer_0_vid_pData_o),
        .s_axis_tvalid(normalizer_0_vid_pVDE_o));
  design_1_constant_control_0_0 constant_control_0
       (.bot_right_x(bot_right_x_0_1),
        .bot_right_y(bot_right_y_0_1),
        .botr(constant_control_0_botr),
        .clk(clk_1),
        .dx(constant_control_0_dx),
        .dy(constant_control_0_dy),
        .factor_h(constant_control_0_factor_h),
        .factor_w(constant_control_0_factor_w),
        .hdim_w(constant_control_0_hdim_w),
        .resetn(resetn_1),
        .top_left_x(top_left_x_0_1),
        .top_left_y(top_left_y_0_1),
        .topl(constant_control_0_topl),
        .update(update_0_1),
        .vdim_h(constant_control_0_vdim_h),
        .vsync(luminance_filter_0_vid_pVSync_o));
  design_1_hor_avg_filter_0_0 hor_avg_filter_0
       (.clk(clk_1),
        .dx(constant_control_0_dx),
        .hdim(constant_control_0_hdim_w),
        .resetn(resetn_1),
        .sw_reset(sw_reset_0_1),
        .vid_pData_i(axis_data_fifo_0_m_axis_tdata),
        .vid_pData_o(hor_avg_filter_0_RGB_o_DATA),
        .vid_pHSync_i(luminance_filter_0_vid_pHSync_o),
        .vid_pHSync_o(hor_avg_filter_0_RGB_o_HSYNC),
        .vid_pReady_o(hor_avg_filter_0_vid_pReady_i),
        .vid_pVDE_i(axis_data_fifo_0_m_axis_tvalid),
        .vid_pVDE_o(hor_avg_filter_0_RGB_o_ACTIVE_VIDEO),
        .vid_pVSync_i(luminance_filter_0_vid_pVSync_o),
        .vid_pVSync_o(hor_avg_filter_0_RGB_o_VSYNC));
  design_1_luminance_filter_0_0 luminance_filter_0
       (.clk(clk_1),
        .resetn(resetn_1),
        .sw_reset(sw_reset_0_1),
        .vid_pData_i(sub_image_filter_0_RGB_o_DATA),
        .vid_pData_o(luminance_filter_0_vid_pData_o),
        .vid_pHSync_i(sub_image_filter_0_RGB_o_HSYNC),
        .vid_pHSync_o(luminance_filter_0_vid_pHSync_o),
        .vid_pVDE_i(sub_image_filter_0_RGB_o_ACTIVE_VIDEO),
        .vid_pVDE_o(luminance_filter_0_vid_pVDE_o),
        .vid_pVSync_i(sub_image_filter_0_RGB_o_VSYNC),
        .vid_pVSync_o(luminance_filter_0_vid_pVSync_o));
  design_1_normalizer_0_0 normalizer_0
       (.clk(clk_1),
        .factor(constant_control_0_factor_w),
        .resetn(resetn_1),
        .sw_reset(sw_reset_0_1),
        .vid_pData_i(hor_avg_filter_0_RGB_o_DATA),
        .vid_pData_o(normalizer_0_vid_pData_o),
        .vid_pHSync_i(hor_avg_filter_0_RGB_o_HSYNC),
        .vid_pHSync_o(normalizer_0_vid_pHSync_o),
        .vid_pVDE_i(hor_avg_filter_0_RGB_o_ACTIVE_VIDEO),
        .vid_pVDE_o(normalizer_0_vid_pVDE_o),
        .vid_pVSync_i(hor_avg_filter_0_RGB_o_VSYNC),
        .vid_pVSync_o(normalizer_0_vid_pVSync_o));
  design_1_normalizer_1_0 normalizer_1
       (.clk(clk_1),
        .factor(constant_control_0_factor_h),
        .resetn(resetn_1),
        .sw_reset(sw_reset_0_1),
        .vid_pData_i(vert_avg_filter_0_data_o),
        .vid_pData_o(normalizer_1_vid_pData_o),
        .vid_pHSync_i(normalizer_0_vid_pHSync_o),
        .vid_pVDE_i(vert_avg_filter_0_valid_o),
        .vid_pVDE_o(normalizer_1_vid_pVDE_o),
        .vid_pVSync_i(vert_avg_filter_0_vsync_gen_o),
        .vid_pVSync_o(normalizer_1_vid_pVSync_o));
  design_1_sub_image_filter_0_0 sub_image_filter_0
       (.bottom_right(constant_control_0_botr),
        .clk(clk_1),
        .enable(enable_sub_image_filter_1),
        .resetn(resetn_1),
        .sw_reset(sw_reset_0_1),
        .top_left(constant_control_0_topl),
        .vid_pData_i(rgb_i_1_DATA),
        .vid_pData_o(sub_image_filter_0_RGB_o_DATA),
        .vid_pHSync_i(rgb_i_1_HSYNC),
        .vid_pHSync_o(sub_image_filter_0_RGB_o_HSYNC),
        .vid_pVDE_i(rgb_i_1_ACTIVE_VIDEO),
        .vid_pVDE_o(sub_image_filter_0_RGB_o_ACTIVE_VIDEO),
        .vid_pVSync_i(rgb_i_1_VSYNC),
        .vid_pVSync_o(sub_image_filter_0_RGB_o_VSYNC));
  design_1_vert_avg_filter_0_0 vert_avg_filter_0
       (.clk(clk_1),
        .data_o(vert_avg_filter_0_data_o),
        .dy(constant_control_0_dy),
        .resetn(resetn_1),
        .valid_o(vert_avg_filter_0_valid_o),
        .vdim(constant_control_0_vdim_h),
        .vid_pData_i(axis_data_fifo_1_m_axis_tdata),
        .vid_pHSync_i(normalizer_0_vid_pHSync_o),
        .vid_pReady_i(vert_avg_filter_0_vid_pReady_i),
        .vid_pVDE_i(axis_data_fifo_1_m_axis_tvalid),
        .vid_pVSync_i(normalizer_0_vid_pVSync_o),
        .vsync_gen_o(vert_avg_filter_0_vsync_gen_o));
endmodule
