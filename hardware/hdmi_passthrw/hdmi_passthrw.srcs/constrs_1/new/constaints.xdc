### This file is a general .xdc for the Nexys Video Rev. A
### To use it in a project:
### - uncomment the lines corresponding to used pins
### - rename the used ports (in each line, after get_ports) according to the top level signal names in the project


## Clock Signal
set_property -dict {PACKAGE_PIN R4 IOSTANDARD LVCMOS33} [get_ports clk]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports clk]

## FMC Transceiver clocks (Must be set to value provided by Mezzanine card, currently set to 156.25 MHz)
## Note: This clock is attached to a MGTREFCLK pin
#set_property -dict { PACKAGE_PIN E6 } [get_ports { GTP_CLK_N }];
#set_property -dict { PACKAGE_PIN F6 } [get_ports { GTP_CLK_P }];
#create_clock -add -name gtpclk0_pin -period 6.400 -waveform {0 3.200} [get_ports {GTP_CLK_P}];
#set_property -dict { PACKAGE_PIN E10 } [get_ports { FMC_MGT_CLK_N }];
#set_property -dict { PACKAGE_PIN F10 } [get_ports { FMC_MGT_CLK_P }];
#create_clock -add -name mgtclk1_pin -period 6.400 -waveform {0 3.200} [get_ports {FMC_MGT_CLK_P}];


## LEDs
set_property -dict {PACKAGE_PIN T14 IOSTANDARD LVCMOS25} [get_ports {led[0]}]
set_property -dict {PACKAGE_PIN T15 IOSTANDARD LVCMOS25} [get_ports {led[1]}]
set_property -dict {PACKAGE_PIN T16 IOSTANDARD LVCMOS25} [get_ports {led[2]}]
set_property -dict {PACKAGE_PIN U16 IOSTANDARD LVCMOS25} [get_ports {led[3]}]
set_property -dict {PACKAGE_PIN V15 IOSTANDARD LVCMOS25} [get_ports {led[4]}]
set_property -dict {PACKAGE_PIN W16 IOSTANDARD LVCMOS25} [get_ports {led[5]}]
set_property -dict {PACKAGE_PIN W15 IOSTANDARD LVCMOS25} [get_ports {led[6]}]
set_property -dict {PACKAGE_PIN Y13 IOSTANDARD LVCMOS25} [get_ports {led[7]}]


## Buttons
set_property -dict { PACKAGE_PIN B22 IOSTANDARD LVCMOS12 } [get_ports { buttons[4] }]; #IO_L20N_T3_16 Sch=btnc
set_property -dict { PACKAGE_PIN D22 IOSTANDARD LVCMOS12 } [get_ports { buttons[3] }]; #IO_L22N_T3_16 Sch=btnd
set_property -dict { PACKAGE_PIN C22 IOSTANDARD LVCMOS12 } [get_ports { buttons[0] }]; #IO_L20P_T3_16 Sch=btnl
set_property -dict { PACKAGE_PIN D14 IOSTANDARD LVCMOS12 } [get_ports { buttons[1] }]; #IO_L6P_T0_16 Sch=btnr
set_property -dict { PACKAGE_PIN F15 IOSTANDARD LVCMOS12 } [get_ports { buttons[2] }]; #IO_0_16 Sch=btnu
#set_property -dict { PACKAGE_PIN G4  IOSTANDARD LVCMOS15 } [get_ports { cpu_resetn }]; #IO_L12N_T1_MRCC_35 Sch=cpu_resetn


## Switches
set_property -dict {PACKAGE_PIN E22 IOSTANDARD LVCMOS12} [get_ports {sw[0]}]
set_property -dict {PACKAGE_PIN F21 IOSTANDARD LVCMOS12} [get_ports {sw[1]}]
set_property -dict {PACKAGE_PIN G21 IOSTANDARD LVCMOS12} [get_ports {sw[2]}]
set_property -dict {PACKAGE_PIN G22 IOSTANDARD LVCMOS12} [get_ports {sw[3]}]
set_property -dict {PACKAGE_PIN H17 IOSTANDARD LVCMOS12} [get_ports {sw[4]}]
set_property -dict {PACKAGE_PIN J16 IOSTANDARD LVCMOS12} [get_ports {sw[5]}]
set_property -dict {PACKAGE_PIN K13 IOSTANDARD LVCMOS12} [get_ports {sw[6]}]
set_property -dict {PACKAGE_PIN M17 IOSTANDARD LVCMOS12} [get_ports {sw[7]}]


## OLED Display
#set_property -dict { PACKAGE_PIN W22   IOSTANDARD LVCMOS33 } [get_ports { oled_dc }]; #IO_L7N_T1_D10_14 Sch=oled_dc
#set_property -dict { PACKAGE_PIN U21   IOSTANDARD LVCMOS33 } [get_ports { oled_res }]; #IO_L4N_T0_D05_14 Sch=oled_res
#set_property -dict { PACKAGE_PIN W21   IOSTANDARD LVCMOS33 } [get_ports { oled_sclk }]; #IO_L7P_T1_D09_14 Sch=oled_sclk
#set_property -dict { PACKAGE_PIN Y22   IOSTANDARD LVCMOS33 } [get_ports { oled_sdin }]; #IO_L9N_T1_DQS_D13_14 Sch=oled_sdin
#set_property -dict { PACKAGE_PIN P20   IOSTANDARD LVCMOS33 } [get_ports { oled_vbat }]; #IO_0_14 Sch=oled_vbat
#set_property -dict { PACKAGE_PIN V22   IOSTANDARD LVCMOS33 } [get_ports { oled_vdd }]; #IO_L3N_T0_DQS_EMCCLK_14 Sch=oled_vdd


## HDMI in
#set_property -dict { PACKAGE_PIN AA5   IOSTANDARD LVCMOS33 } [get_ports { hdmi_rx_cec }]; #IO_L10P_T1_34 Sch=hdmi_rx_cec
set_property -dict {PACKAGE_PIN W4 IOSTANDARD TMDS_33} [get_ports TMDS_0_clk_n]
set_property -dict {PACKAGE_PIN V4 IOSTANDARD TMDS_33} [get_ports TMDS_0_clk_p]
create_clock -period 12.500 -name tmds_clk_pin -waveform {0.000 6.250} -add [get_ports TMDS_0_clk_p]
set_property -dict {PACKAGE_PIN AB12 IOSTANDARD LVCMOS25} [get_ports hdmi_rx_hpd]
set_property -dict {PACKAGE_PIN Y4 IOSTANDARD LVCMOS33} [get_ports hdmi_rx_scl_io]
set_property -dict {PACKAGE_PIN AB5 IOSTANDARD LVCMOS33} [get_ports hdmi_rx_sda_io]
set_property -dict {PACKAGE_PIN R3 IOSTANDARD LVCMOS33} [get_ports hdmi_rx_txen]
set_property -dict {PACKAGE_PIN AA3 IOSTANDARD TMDS_33} [get_ports {TMDS_0_data_n[0]}]
set_property -dict {PACKAGE_PIN Y3 IOSTANDARD TMDS_33} [get_ports {TMDS_0_data_p[0]}]
set_property -dict {PACKAGE_PIN Y2 IOSTANDARD TMDS_33} [get_ports {TMDS_0_data_n[1]}]
set_property -dict {PACKAGE_PIN W2 IOSTANDARD TMDS_33} [get_ports {TMDS_0_data_p[1]}]
set_property -dict {PACKAGE_PIN V2 IOSTANDARD TMDS_33} [get_ports {TMDS_0_data_n[2]}]
set_property -dict {PACKAGE_PIN U2 IOSTANDARD TMDS_33} [get_ports {TMDS_0_data_p[2]}]


## HDMI out
#set_property -dict { PACKAGE_PIN AA4   IOSTANDARD LVCMOS33 } [get_ports { hdmi_tx_cec }]; #IO_L11N_T1_SRCC_34 Sch=hdmi_tx_cec
set_property -dict {PACKAGE_PIN U1 IOSTANDARD TMDS_33} [get_ports TMDS_1_clk_n]
set_property -dict {PACKAGE_PIN T1 IOSTANDARD TMDS_33} [get_ports TMDS_1_clk_p]
#set_property -dict { PACKAGE_PIN AB13  IOSTANDARD LVCMOS25 } [get_ports { hdmi_tx_hpd }]; #IO_L3N_T0_DQS_13 Sch=hdmi_tx_hpd
#set_property -dict { PACKAGE_PIN U3    IOSTANDARD LVCMOS33 } [get_ports { hdmi_tx_rscl }]; #IO_L6P_T0_34 Sch=hdmi_tx_rscl
#set_property -dict { PACKAGE_PIN V3    IOSTANDARD LVCMOS33 } [get_ports { hdmi_tx_rsda }]; #IO_L6N_T0_VREF_34 Sch=hdmi_tx_rsda
set_property -dict {PACKAGE_PIN Y1 IOSTANDARD TMDS_33} [get_ports {TMDS_1_data_n[0]}]
set_property -dict {PACKAGE_PIN W1 IOSTANDARD TMDS_33} [get_ports {TMDS_1_data_p[0]}]
set_property -dict {PACKAGE_PIN AB1 IOSTANDARD TMDS_33} [get_ports {TMDS_1_data_n[1]}]
set_property -dict {PACKAGE_PIN AA1 IOSTANDARD TMDS_33} [get_ports {TMDS_1_data_p[1]}]
set_property -dict {PACKAGE_PIN AB2 IOSTANDARD TMDS_33} [get_ports {TMDS_1_data_n[2]}]
set_property -dict {PACKAGE_PIN AB3 IOSTANDARD TMDS_33} [get_ports {TMDS_1_data_p[2]}]


## Display Port
#set_property -dict { PACKAGE_PIN AB10  IOSTANDARD TMDS_33  } [get_ports { dp_tx_aux_n }]; #IO_L8N_T1_13 Sch=dp_tx_aux_n
#set_property -dict { PACKAGE_PIN AA11  IOSTANDARD TMDS_33  } [get_ports { dp_tx_aux_n }]; #IO_L9N_T1_DQS_13 Sch=dp_tx_aux_n
#set_property -dict { PACKAGE_PIN AA9   IOSTANDARD TMDS_33  } [get_ports { dp_tx_aux_p }]; #IO_L8P_T1_13 Sch=dp_tx_aux_p
#set_property -dict { PACKAGE_PIN AA10  IOSTANDARD TMDS_33  } [get_ports { dp_tx_aux_p }]; #IO_L9P_T1_DQS_13 Sch=dp_tx_aux_p
#set_property -dict { PACKAGE_PIN N15   IOSTANDARD LVCMOS33 } [get_ports { dp_tx_hpd }]; #IO_25_14 Sch=dp_tx_hpd


## Audio Codec
#set_property -dict { PACKAGE_PIN T4    IOSTANDARD LVCMOS33 } [get_ports { ac_adc_sdata }]; #IO_L13N_T2_MRCC_34 Sch=ac_adc_sdata
#set_property -dict { PACKAGE_PIN T5    IOSTANDARD LVCMOS33 } [get_ports { ac_bclk }]; #IO_L14P_T2_SRCC_34 Sch=ac_bclk
#set_property -dict { PACKAGE_PIN W6    IOSTANDARD LVCMOS33 } [get_ports { ac_dac_sdata }]; #IO_L15P_T2_DQS_34 Sch=ac_dac_sdata
#set_property -dict { PACKAGE_PIN U5    IOSTANDARD LVCMOS33 } [get_ports { ac_lrclk }]; #IO_L14N_T2_SRCC_34 Sch=ac_lrclk
#set_property -dict { PACKAGE_PIN U6    IOSTANDARD LVCMOS33 } [get_ports { ac_mclk }]; #IO_L16P_T2_34 Sch=ac_mclk


## Pmod header JA
#set_property -dict { PACKAGE_PIN AB22  IOSTANDARD LVCMOS33 } [get_ports { ja[0] }]; #IO_L10N_T1_D15_14 Sch=ja[1]
#set_property -dict { PACKAGE_PIN AB21  IOSTANDARD LVCMOS33 } [get_ports { ja[1] }]; #IO_L10P_T1_D14_14 Sch=ja[2]
#set_property -dict { PACKAGE_PIN AB20  IOSTANDARD LVCMOS33 } [get_ports { ja[2] }]; #IO_L15N_T2_DQS_DOUT_CSO_B_14 Sch=ja[3]
#set_property -dict { PACKAGE_PIN AB18  IOSTANDARD LVCMOS33 } [get_ports { ja[3] }]; #IO_L17N_T2_A13_D29_14 Sch=ja[4]
#set_property -dict { PACKAGE_PIN Y21   IOSTANDARD LVCMOS33 } [get_ports { ja[4] }]; #IO_L9P_T1_DQS_14 Sch=ja[7]
#set_property -dict { PACKAGE_PIN AA21  IOSTANDARD LVCMOS33 } [get_ports { ja[5] }]; #IO_L8N_T1_D12_14 Sch=ja[8]
#set_property -dict { PACKAGE_PIN AA20  IOSTANDARD LVCMOS33 } [get_ports { ja[6] }]; #IO_L8P_T1_D11_14 Sch=ja[9]
#set_property -dict { PACKAGE_PIN AA18  IOSTANDARD LVCMOS33 } [get_ports { ja[7] }]; #IO_L17P_T2_A14_D30_14 Sch=ja[10]


## Pmod header JB
#set_property -dict { PACKAGE_PIN V9    IOSTANDARD LVCMOS33 } [get_ports { jb[0] }]; #IO_L21P_T3_DQS_34 Sch=jb_p[1]
#set_property -dict { PACKAGE_PIN V8    IOSTANDARD LVCMOS33 } [get_ports { jb[1] }]; #IO_L21N_T3_DQS_34 Sch=jb_n[1]
#set_property -dict { PACKAGE_PIN V7    IOSTANDARD LVCMOS33 } [get_ports { jb[2] }]; #IO_L19P_T3_34 Sch=jb_p[2]
#set_property -dict { PACKAGE_PIN W7    IOSTANDARD LVCMOS33 } [get_ports { jb[3] }]; #IO_L19N_T3_VREF_34 Sch=jb_n[2]
#set_property -dict { PACKAGE_PIN W9    IOSTANDARD LVCMOS33 } [get_ports { jb[4] }]; #IO_L24P_T3_34 Sch=jb_p[3]
#set_property -dict { PACKAGE_PIN Y9    IOSTANDARD LVCMOS33 } [get_ports { jb[5] }]; #IO_L24N_T3_34 Sch=jb_n[3]
#set_property -dict { PACKAGE_PIN Y8    IOSTANDARD LVCMOS33 } [get_ports { jb[6] }]; #IO_L23P_T3_34 Sch=jb_p[4]
#set_property -dict { PACKAGE_PIN Y7    IOSTANDARD LVCMOS33 } [get_ports { jb[7] }]; #IO_L23N_T3_34 Sch=jb_n[4]


## Pmod header JC
#set_property -dict { PACKAGE_PIN Y6    IOSTANDARD LVCMOS33 } [get_ports { jc[0] }]; #IO_L18P_T2_34 Sch=jc_p[1]
#set_property -dict { PACKAGE_PIN AA6   IOSTANDARD LVCMOS33 } [get_ports { jc[1] }]; #IO_L18N_T2_34 Sch=jc_n[1]
#set_property -dict { PACKAGE_PIN AA8   IOSTANDARD LVCMOS33 } [get_ports { jc[2] }]; #IO_L22P_T3_34 Sch=jc_p[2]
#set_property -dict { PACKAGE_PIN AB8   IOSTANDARD LVCMOS33 } [get_ports { jc[3] }]; #IO_L22N_T3_34 Sch=jc_n[2]
#set_property -dict { PACKAGE_PIN R6    IOSTANDARD LVCMOS33 } [get_ports { jc[4] }]; #IO_L17P_T2_34 Sch=jc_p[3]
#set_property -dict { PACKAGE_PIN T6    IOSTANDARD LVCMOS33 } [get_ports { jc[5] }]; #IO_L17N_T2_34 Sch=jc_n[3]
#set_property -dict { PACKAGE_PIN AB7   IOSTANDARD LVCMOS33 } [get_ports { jc[6] }]; #IO_L20P_T3_34 Sch=jc_p[4]
#set_property -dict { PACKAGE_PIN AB6   IOSTANDARD LVCMOS33 } [get_ports { jc[7] }]; #IO_L20N_T3_34 Sch=jc_n[4]


## XADC Header
#set_property -dict { PACKAGE_PIN J14   IOSTANDARD LVCMOS33 } [get_ports { xa_p[0] }]; #IO_L3P_T0_DQS_AD1P_15 Sch=xa_p[1]
#set_property -dict { PACKAGE_PIN H14   IOSTANDARD LVCMOS33 } [get_ports { xa_n[0] }]; #IO_L3N_T0_DQS_AD1N_15 Sch=xa_n[1]
#set_property -dict { PACKAGE_PIN H13   IOSTANDARD LVCMOS33 } [get_ports { xa_p[1] }]; #IO_L1P_T0_AD0P_15 Sch=xa_p[2]
#set_property -dict { PACKAGE_PIN G13   IOSTANDARD LVCMOS33 } [get_ports { xa_n[1] }]; #IO_L1N_T0_AD0N_15 Sch=xa_n[2]
#set_property -dict { PACKAGE_PIN G15   IOSTANDARD LVCMOS33 } [get_ports { xa_p[2] }]; #IO_L2P_T0_AD8P_15 Sch=xa_p[3]
#set_property -dict { PACKAGE_PIN G16   IOSTANDARD LVCMOS33 } [get_ports { xa_n[2] }]; #IO_L2N_T0_AD8N_15 Sch=xa_n[3]
#set_property -dict { PACKAGE_PIN J15   IOSTANDARD LVCMOS33 } [get_ports { xa_p[3] }]; #IO_L5P_T0_AD9P_15 Sch=xa_p[4]
#set_property -dict { PACKAGE_PIN H15   IOSTANDARD LVCMOS33 } [get_ports { xa_n[3] }]; #IO_L5N_T0_AD9N_15 Sch=xa_n[4]


## UART
#set_property -dict { PACKAGE_PIN AA19  IOSTANDARD LVCMOS33 } [get_ports { uart_rx_out }]; #IO_L15P_T2_DQS_RDWR_B_14 Sch=uart_rx_out
#set_property -dict { PACKAGE_PIN V18   IOSTANDARD LVCMOS33 } [get_ports { uart_tx_in }]; #IO_L14P_T2_SRCC_14 Sch=uart_tx_in


## Ethernet
#set_property -dict { PACKAGE_PIN Y14   IOSTANDARD LVCMOS25 } [get_ports { eth_int_b }]; #IO_L6N_T0_VREF_13 Sch=eth_int_b
#set_property -dict { PACKAGE_PIN AA16  IOSTANDARD LVCMOS25 } [get_ports { eth_mdc }]; #IO_L1N_T0_13 Sch=eth_mdc
#set_property -dict { PACKAGE_PIN Y16   IOSTANDARD LVCMOS25 } [get_ports { eth_mdio }]; #IO_L1P_T0_13 Sch=eth_mdio
#set_property -dict { PACKAGE_PIN W14   IOSTANDARD LVCMOS25 } [get_ports { eth_pme_b }]; #IO_L6P_T0_13 Sch=eth_pme_b
#set_property -dict { PACKAGE_PIN U7    IOSTANDARD LVCMOS33 } [get_ports { eth_rst_b }]; #IO_25_34 Sch=eth_rst_b
#set_property -dict { PACKAGE_PIN V13   IOSTANDARD LVCMOS25 } [get_ports { eth_rxck }]; #IO_L13P_T2_MRCC_13 Sch=eth_rxck
#set_property -dict { PACKAGE_PIN W10   IOSTANDARD LVCMOS25 } [get_ports { eth_rxctl }]; #IO_L10N_T1_13 Sch=eth_rxctl
#set_property -dict { PACKAGE_PIN AB16  IOSTANDARD LVCMOS25 } [get_ports { eth_rxd[0] }]; #IO_L2P_T0_13 Sch=eth_rxd[0]
#set_property -dict { PACKAGE_PIN AA15  IOSTANDARD LVCMOS25 } [get_ports { eth_rxd[1] }]; #IO_L4P_T0_13 Sch=eth_rxd[1]
#set_property -dict { PACKAGE_PIN AB15  IOSTANDARD LVCMOS25 } [get_ports { eth_rxd[2] }]; #IO_L4N_T0_13 Sch=eth_rxd[2]
#set_property -dict { PACKAGE_PIN AB11  IOSTANDARD LVCMOS25 } [get_ports { eth_rxd[3] }]; #IO_L7P_T1_13 Sch=eth_rxd[3]
#set_property -dict { PACKAGE_PIN AA14  IOSTANDARD LVCMOS25 } [get_ports { eth_txck }]; #IO_L5N_T0_13 Sch=eth_txck
#set_property -dict { PACKAGE_PIN V10   IOSTANDARD LVCMOS25 } [get_ports { eth_txctl }]; #IO_L10P_T1_13 Sch=eth_txctl
#set_property -dict { PACKAGE_PIN Y12   IOSTANDARD LVCMOS25 } [get_ports { eth_txd[0] }]; #IO_L11N_T1_SRCC_13 Sch=eth_txd[0]
#set_property -dict { PACKAGE_PIN W12   IOSTANDARD LVCMOS25 } [get_ports { eth_txd[1] }]; #IO_L12N_T1_MRCC_13 Sch=eth_txd[1]
#set_property -dict { PACKAGE_PIN W11   IOSTANDARD LVCMOS25 } [get_ports { eth_txd[2] }]; #IO_L12P_T1_MRCC_13 Sch=eth_txd[2]
#set_property -dict { PACKAGE_PIN Y11   IOSTANDARD LVCMOS25 } [get_ports { eth_txd[3] }]; #IO_L11P_T1_SRCC_13 Sch=eth_txd[3]


## Fan PWM
#set_property -dict { PACKAGE_PIN U15   IOSTANDARD LVCMOS25 } [get_ports { fan_pwm }]; #IO_L14P_T2_SRCC_13 Sch=fan_pwm


## DPTI/DSPI
#set_property -dict { PACKAGE_PIN Y18   IOSTANDARD LVCMOS33 } [get_ports { prog_clko }]; #IO_L13P_T2_MRCC_14 Sch=prog_clko
#set_property -dict { PACKAGE_PIN U20   IOSTANDARD LVCMOS33 } [get_ports { prog_d[0]}]; #IO_L11P_T1_SRCC_14 Sch=prog_d0/sck
#set_property -dict { PACKAGE_PIN P14   IOSTANDARD LVCMOS33 } [get_ports { prog_d[1] }]; #IO_L19P_T3_A10_D26_14 Sch=prog_d1/mosi
#set_property -dict { PACKAGE_PIN P15   IOSTANDARD LVCMOS33 } [get_ports { prog_d[2] }]; #IO_L22P_T3_A05_D21_14 Sch=prog_d2/miso
#set_property -dict { PACKAGE_PIN U17   IOSTANDARD LVCMOS33 } [get_ports { prog_d[3]}]; #IO_L18P_T2_A12_D28_14 Sch=prog_d3/ss
#set_property -dict { PACKAGE_PIN R17   IOSTANDARD LVCMOS33 } [get_ports { prog_d[4] }]; #IO_L24N_T3_A00_D16_14 Sch=prog_d[4]
#set_property -dict { PACKAGE_PIN P16   IOSTANDARD LVCMOS33 } [get_ports { prog_d[5] }]; #IO_L24P_T3_A01_D17_14 Sch=prog_d[5]
#set_property -dict { PACKAGE_PIN R18   IOSTANDARD LVCMOS33 } [get_ports { prog_d[6] }]; #IO_L20P_T3_A08_D24_14 Sch=prog_d[6]
#set_property -dict { PACKAGE_PIN N14   IOSTANDARD LVCMOS33 } [get_ports { prog_d[7] }]; #IO_L23N_T3_A02_D18_14 Sch=prog_d[7]
#set_property -dict { PACKAGE_PIN V17   IOSTANDARD LVCMOS33 } [get_ports { prog_oen }]; #IO_L16P_T2_CSI_B_14 Sch=prog_oen
#set_property -dict { PACKAGE_PIN P19   IOSTANDARD LVCMOS33 } [get_ports { prog_rdn }]; #IO_L5P_T0_D06_14 Sch=prog_rdn
#set_property -dict { PACKAGE_PIN N17   IOSTANDARD LVCMOS33 } [get_ports { prog_rxen }]; #IO_L21P_T3_DQS_14 Sch=prog_rxen
#set_property -dict { PACKAGE_PIN P17   IOSTANDARD LVCMOS33 } [get_ports { prog_siwun }]; #IO_L21N_T3_DQS_A06_D22_14 Sch=prog_siwun
#set_property -dict { PACKAGE_PIN R14   IOSTANDARD LVCMOS33 } [get_ports { prog_spien }]; #IO_L19N_T3_A09_D25_VREF_14 Sch=prog_spien
#set_property -dict { PACKAGE_PIN Y19   IOSTANDARD LVCMOS33 } [get_ports { prog_txen }]; #IO_L13N_T2_MRCC_14 Sch=prog_txen
#set_property -dict { PACKAGE_PIN R19   IOSTANDARD LVCMOS33 } [get_ports { prog_wrn }]; #IO_L5N_T0_D07_14 Sch=prog_wrn


## HID port
#set_property -dict { PACKAGE_PIN W17   IOSTANDARD LVCMOS33   PULLUP true } [get_ports { ps2_clk }]; #IO_L16N_T2_A15_D31_14 Sch=ps2_clk
#set_property -dict { PACKAGE_PIN N13   IOSTANDARD LVCMOS33   PULLUP true } [get_ports { ps2_data }]; #IO_L23P_T3_A03_D19_14 Sch=ps2_data


## QSPI
#set_property -dict { PACKAGE_PIN T19   IOSTANDARD LVCMOS33 } [get_ports { qspi_cs }]; #IO_L6P_T0_FCS_B_14 Sch=qspi_cs
#set_property -dict { PACKAGE_PIN P22   IOSTANDARD LVCMOS33 } [get_ports { qspi_dq[0] }]; #IO_L1P_T0_D00_MOSI_14 Sch=qspi_dq[0]
#set_property -dict { PACKAGE_PIN R22   IOSTANDARD LVCMOS33 } [get_ports { qspi_dq[1] }]; #IO_L1N_T0_D01_DIN_14 Sch=qspi_dq[1]
#set_property -dict { PACKAGE_PIN P21   IOSTANDARD LVCMOS33 } [get_ports { qspi_dq[2] }]; #IO_L2P_T0_D02_14 Sch=qspi_dq[2]
#set_property -dict { PACKAGE_PIN R21   IOSTANDARD LVCMOS33 } [get_ports { qspi_dq[3] }]; #IO_L2N_T0_D03_14 Sch=qspi_dq[3]


## SD card
#set_property -dict { PACKAGE_PIN W19   IOSTANDARD LVCMOS33 } [get_ports { sd_cclk }]; #IO_L12P_T1_MRCC_14 Sch=sd_cclk
#set_property -dict { PACKAGE_PIN T18   IOSTANDARD LVCMOS33 } [get_ports { sd_cd }]; #IO_L20N_T3_A07_D23_14 Sch=sd_cd
#set_property -dict { PACKAGE_PIN W20   IOSTANDARD LVCMOS33 } [get_ports { sd_cmd }]; #IO_L12N_T1_MRCC_14 Sch=sd_cmd
#set_property -dict { PACKAGE_PIN V19   IOSTANDARD LVCMOS33 } [get_ports { sd_d[0] }]; #IO_L14N_T2_SRCC_14 Sch=sd_d[0]
#set_property -dict { PACKAGE_PIN T21   IOSTANDARD LVCMOS33 } [get_ports { sd_d[1] }]; #IO_L4P_T0_D04_14 Sch=sd_d[1]
#set_property -dict { PACKAGE_PIN T20   IOSTANDARD LVCMOS33 } [get_ports { sd_d[2] }]; #IO_L6N_T0_D08_VREF_14 Sch=sd_d[2]
#set_property -dict { PACKAGE_PIN U18   IOSTANDARD LVCMOS33 } [get_ports { sd_d[3] }]; #IO_L18N_T2_A11_D27_14 Sch=sd_d[3]
#set_property -dict { PACKAGE_PIN V20   IOSTANDARD LVCMOS33 } [get_ports { sd_reset }]; #IO_L11N_T1_SRCC_14 Sch=sd_reset


## I2C
#set_property -dict { PACKAGE_PIN W5    IOSTANDARD LVCMOS33 } [get_ports { scl }]; #IO_L15N_T2_DQS_34 Sch=scl
#set_property -dict { PACKAGE_PIN V5    IOSTANDARD LVCMOS33 } [get_ports { sda }]; #IO_L16N_T2_34 Sch=sda


## Voltage Adjust
#set_property -dict { PACKAGE_PIN AA13  IOSTANDARD LVCMOS25 } [get_ports { set_vadj[0] }]; #IO_L3P_T0_DQS_13 Sch=set_vadj[0]
#set_property -dict { PACKAGE_PIN AB17  IOSTANDARD LVCMOS25 } [get_ports { set_vadj[1] }]; #IO_L2N_T0_13 Sch=set_vadj[1]
#set_property -dict { PACKAGE_PIN V14   IOSTANDARD LVCMOS25 } [get_ports { vadj_en }]; #IO_L13N_T2_MRCC_13 Sch=vadj_en


## FMC
#set_property -dict { PACKAGE_PIN H19   IOSTANDARD LVCMOS12 } [get_ports { fmc_clk0_m2c_n }]; #IO_L12N_T1_MRCC_15 Sch=fmc_clk0_m2c_n
#set_property -dict { PACKAGE_PIN J19   IOSTANDARD LVCMOS12 } [get_ports { fmc_clk0_m2c_p }]; #IO_L12P_T1_MRCC_15 Sch=fmc_clk0_m2c_p
#set_property -dict { PACKAGE_PIN C19   IOSTANDARD LVCMOS12 } [get_ports { fmc_clk1_m2c_n }]; #IO_L13N_T2_MRCC_16 Sch=fmc_clk1_m2c_n
#set_property -dict { PACKAGE_PIN C18   IOSTANDARD LVCMOS12 } [get_ports { fmc_clk1_m2c_p }]; #IO_L13P_T2_MRCC_16 Sch=fmc_clk1_m2c_p
#set_property -dict { PACKAGE_PIN K19   IOSTANDARD LVCMOS12 } [get_ports { fmc_la00_cc_n }]; #IO_L13N_T2_MRCC_15 Sch=fmc_la00_cc_n
#set_property -dict { PACKAGE_PIN K18   IOSTANDARD LVCMOS12 } [get_ports { fmc_la00_cc_p }]; #IO_L13P_T2_MRCC_15 Sch=fmc_la00_cc_p
#set_property -dict { PACKAGE_PIN J21   IOSTANDARD LVCMOS12 } [get_ports { fmc_la01_cc_n }]; #IO_L11N_T1_SRCC_15 Sch=fmc_la01_cc_n
#set_property -dict { PACKAGE_PIN J20   IOSTANDARD LVCMOS12 } [get_ports { fmc_la01_cc_p }]; #IO_L11P_T1_SRCC_15 Sch=fmc_la01_cc_p
#set_property -dict { PACKAGE_PIN L18   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_n[02] }]; #IO_L16N_T2_A27_15 Sch=fmc_la_n[02]
#set_property -dict { PACKAGE_PIN M18   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_p[02] }]; #IO_L16P_T2_A28_15 Sch=fmc_la_p[02]
#set_property -dict { PACKAGE_PIN N19   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_n[03] }]; #IO_L17N_T2_A25_15 Sch=fmc_la_n[03]
#set_property -dict { PACKAGE_PIN N18   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_p[03] }]; #IO_L17P_T2_A26_15 Sch=fmc_la_p[03]
#set_property -dict { PACKAGE_PIN M20   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_n[04] }]; #IO_L18N_T2_A23_15 Sch=fmc_la_n[04]
#set_property -dict { PACKAGE_PIN N20   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_p[04] }]; #IO_L18P_T2_A24_15 Sch=fmc_la_p[04]
#set_property -dict { PACKAGE_PIN L21   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_n[05] }]; #IO_L10N_T1_AD11N_15 Sch=fmc_la_n[05]
#set_property -dict { PACKAGE_PIN M21   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_p[05] }]; #IO_L10P_T1_AD11P_15 Sch=fmc_la_p[05]
#set_property -dict { PACKAGE_PIN M22   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_n[06] }]; #IO_L15N_T2_DQS_ADV_B_15 Sch=fmc_la_n[06]
#set_property -dict { PACKAGE_PIN N22   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_p[06] }]; #IO_L15P_T2_DQS_15 Sch=fmc_la_p[06]
#set_property -dict { PACKAGE_PIN L13   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_n[07] }]; #IO_L20N_T3_A19_15 Sch=fmc_la_n[07]
#set_property -dict { PACKAGE_PIN M13   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_p[07] }]; #IO_L20P_T3_A20_15 Sch=fmc_la_p[07]
#set_property -dict { PACKAGE_PIN M16   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_n[08] }]; #IO_L24N_T3_RS0_15 Sch=fmc_la_n[08]
#set_property -dict { PACKAGE_PIN M15   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_p[08] }]; #IO_L24P_T3_RS1_15 Sch=fmc_la_p[08]
#set_property -dict { PACKAGE_PIN G20   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_n[09] }]; #IO_L8N_T1_AD10N_15 Sch=fmc_la_n[09]
#set_property -dict { PACKAGE_PIN H20   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_p[09] }]; #IO_L8P_T1_AD10P_15 Sch=fmc_la_p[09]
#set_property -dict { PACKAGE_PIN K22   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_n[10] }]; #IO_L9N_T1_DQS_AD3N_15 Sch=fmc_la_n[10]
#set_property -dict { PACKAGE_PIN K21   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_p[10] }]; #IO_L9P_T1_DQS_AD3P_15 Sch=fmc_la_p[10]
#set_property -dict { PACKAGE_PIN L15   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_n[11] }]; #IO_L22N_T3_A16_15 Sch=fmc_la_n[11]
#set_property -dict { PACKAGE_PIN L14   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_p[11] }]; #IO_L22P_T3_A17_15 Sch=fmc_la_p[11]
#set_property -dict { PACKAGE_PIN L20   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_n[12] }]; #IO_L14N_T2_SRCC_15 Sch=fmc_la_n[12]
#set_property -dict { PACKAGE_PIN L19   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_p[12] }]; #IO_L14P_T2_SRCC_15 Sch=fmc_la_p[12]
#set_property -dict { PACKAGE_PIN J17   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_n[13] }]; #IO_L21N_T3_DQS_A18_15 Sch=fmc_la_n[13]
#set_property -dict { PACKAGE_PIN K17   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_p[13] }]; #IO_L21P_T3_DQS_15 Sch=fmc_la_p[13]
#set_property -dict { PACKAGE_PIN H22   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_n[14] }]; #IO_L7N_T1_AD2N_15 Sch=fmc_la_n[14]
#set_property -dict { PACKAGE_PIN J22   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_p[14] }]; #IO_L7P_T1_AD2P_15 Sch=fmc_la_p[14]
#set_property -dict { PACKAGE_PIN K16   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_n[15] }]; #IO_L23N_T3_FWE_B_15 Sch=fmc_la_n[15]
#set_property -dict { PACKAGE_PIN L16   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_p[15] }]; #IO_L23P_T3_FOE_B_15 Sch=fmc_la_p[15]
#set_property -dict { PACKAGE_PIN G18   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_n[16] }]; #IO_L4N_T0_15 Sch=fmc_la_n[16]
#set_property -dict { PACKAGE_PIN G17   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_p[16] }]; #IO_L4P_T0_15 Sch=fmc_la_p[16]
#set_property -dict { PACKAGE_PIN B18   IOSTANDARD LVCMOS12 } [get_ports { fmc_la17_cc_n }]; #IO_L11N_T1_SRCC_16 Sch=fmc_la17_cc_n
#set_property -dict { PACKAGE_PIN B17   IOSTANDARD LVCMOS12 } [get_ports { fmc_la17_cc_p }]; #IO_L11P_T1_SRCC_16 Sch=fmc_la17_cc_p
#set_property -dict { PACKAGE_PIN C17   IOSTANDARD LVCMOS12 } [get_ports { fmc_la18_cc_n }]; #IO_L12N_T1_MRCC_16 Sch=fmc_la18_cc_n
#set_property -dict { PACKAGE_PIN D17   IOSTANDARD LVCMOS12 } [get_ports { fmc_la18_cc_p }]; #IO_L12P_T1_MRCC_16 Sch=fmc_la18_cc_p
#set_property -dict { PACKAGE_PIN A19   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_n[19] }]; #IO_L17N_T2_16 Sch=fmc_la_n[19]
#set_property -dict { PACKAGE_PIN A18   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_p[19] }]; #IO_L17P_T2_16 Sch=fmc_la_p[19]
#set_property -dict { PACKAGE_PIN F20   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_n[20] }]; #IO_L18N_T2_16 Sch=fmc_la_n[20]
#set_property -dict { PACKAGE_PIN F19   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_p[20] }]; #IO_L18P_T2_16 Sch=fmc_la_p[20]
#set_property -dict { PACKAGE_PIN D19   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_n[21] }]; #IO_L14N_T2_SRCC_16 Sch=fmc_la_n[21]
#set_property -dict { PACKAGE_PIN E19   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_p[21] }]; #IO_L14P_T2_SRCC_16 Sch=fmc_la_p[21]
#set_property -dict { PACKAGE_PIN D21   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_n[22] }]; #IO_L23N_T3_16 Sch=fmc_la_n[22]
#set_property -dict { PACKAGE_PIN E21   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_p[22] }]; #IO_L23P_T3_16 Sch=fmc_la_p[22]
#set_property -dict { PACKAGE_PIN A21   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_n[23] }]; #IO_L21N_T3_DQS_16 Sch=fmc_la_n[23]
#set_property -dict { PACKAGE_PIN B21   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_p[23] }]; #IO_L21P_T3_DQS_16 Sch=fmc_la_p[23]
#set_property -dict { PACKAGE_PIN B16   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_n[24] }]; #IO_L7N_T1_16 Sch=fmc_la_n[24]
#set_property -dict { PACKAGE_PIN B15   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_p[24] }]; #IO_L7P_T1_16 Sch=fmc_la_p[24]
#set_property -dict { PACKAGE_PIN E17   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_n[25] }]; #IO_L2N_T0_16 Sch=fmc_la_n[25]
#set_property -dict { PACKAGE_PIN F16   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_p[25] }]; #IO_L2P_T0_16 Sch=fmc_la_p[25]
#set_property -dict { PACKAGE_PIN E18   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_n[26] }]; #IO_L15N_T2_DQS_16 Sch=fmc_la_n[26]
#set_property -dict { PACKAGE_PIN F18   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_p[26] }]; #IO_L15P_T2_DQS_16 Sch=fmc_la_p[26]
#set_property -dict { PACKAGE_PIN A20   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_n[27] }]; #IO_L16N_T2_16 Sch=fmc_la_n[27]
#set_property -dict { PACKAGE_PIN B20   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_p[27] }]; #IO_L16P_T2_16 Sch=fmc_la_p[27]
#set_property -dict { PACKAGE_PIN B13   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_n[28] }]; #IO_L8N_T1_16 Sch=fmc_la_n[28]
#set_property -dict { PACKAGE_PIN C13   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_p[28] }]; #IO_L8P_T1_16 Sch=fmc_la_p[28]
#set_property -dict { PACKAGE_PIN C15   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_n[29] }]; #IO_L3N_T0_DQS_16 Sch=fmc_la_n[29]
#set_property -dict { PACKAGE_PIN C14   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_p[29] }]; #IO_L3P_T0_DQS_16 Sch=fmc_la_p[29]
#set_property -dict { PACKAGE_PIN A14   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_n[30] }]; #IO_L10N_T1_16 Sch=fmc_la_n[30]
#set_property -dict { PACKAGE_PIN A13   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_p[30] }]; #IO_L10P_T1_16 Sch=fmc_la_p[30]
#set_property -dict { PACKAGE_PIN E14   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_n[31] }]; #IO_L4N_T0_16 Sch=fmc_la_n[31]
#set_property -dict { PACKAGE_PIN E13   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_p[31] }]; #IO_L4P_T0_16 Sch=fmc_la_p[31]
#set_property -dict { PACKAGE_PIN A16   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_n[32] }]; #IO_L9N_T1_DQS_16 Sch=fmc_la_n[32]
#set_property -dict { PACKAGE_PIN A15   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_p[32] }]; #IO_L9P_T1_DQS_16 Sch=fmc_la_p[32]
#set_property -dict { PACKAGE_PIN F14   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_n[33] }]; #IO_L1N_T0_16 Sch=fmc_la_n[33]
#set_property -dict { PACKAGE_PIN F13   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_p[33] }]; #IO_L1P_T0_16 Sch=fmc_la_p[33]


## Configuration options, can be used for all designs
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]



connect_debug_port u_ila_1/probe0 [get_nets [list {design_1_i/axi_dma_0_M_AXI_S2MM_AWBURST[0]}]]
connect_debug_port u_ila_1/probe1 [get_nets [list {design_1_i/dvi_out_0/inst/m_axis_tdata[0]} {design_1_i/dvi_out_0/inst/m_axis_tdata[1]} {design_1_i/dvi_out_0/inst/m_axis_tdata[2]} {design_1_i/dvi_out_0/inst/m_axis_tdata[3]} {design_1_i/dvi_out_0/inst/m_axis_tdata[4]} {design_1_i/dvi_out_0/inst/m_axis_tdata[5]} {design_1_i/dvi_out_0/inst/m_axis_tdata[6]} {design_1_i/dvi_out_0/inst/m_axis_tdata[7]} {design_1_i/dvi_out_0/inst/m_axis_tdata[8]} {design_1_i/dvi_out_0/inst/m_axis_tdata[9]} {design_1_i/dvi_out_0/inst/m_axis_tdata[10]} {design_1_i/dvi_out_0/inst/m_axis_tdata[11]} {design_1_i/dvi_out_0/inst/m_axis_tdata[12]} {design_1_i/dvi_out_0/inst/m_axis_tdata[13]} {design_1_i/dvi_out_0/inst/m_axis_tdata[14]} {design_1_i/dvi_out_0/inst/m_axis_tdata[15]} {design_1_i/dvi_out_0/inst/m_axis_tdata[16]} {design_1_i/dvi_out_0/inst/m_axis_tdata[17]} {design_1_i/dvi_out_0/inst/m_axis_tdata[18]} {design_1_i/dvi_out_0/inst/m_axis_tdata[19]} {design_1_i/dvi_out_0/inst/m_axis_tdata[20]} {design_1_i/dvi_out_0/inst/m_axis_tdata[21]} {design_1_i/dvi_out_0/inst/m_axis_tdata[22]} {design_1_i/dvi_out_0/inst/m_axis_tdata[23]} {design_1_i/dvi_out_0/inst/m_axis_tdata[24]} {design_1_i/dvi_out_0/inst/m_axis_tdata[25]} {design_1_i/dvi_out_0/inst/m_axis_tdata[26]} {design_1_i/dvi_out_0/inst/m_axis_tdata[27]} {design_1_i/dvi_out_0/inst/m_axis_tdata[28]} {design_1_i/dvi_out_0/inst/m_axis_tdata[29]} {design_1_i/dvi_out_0/inst/m_axis_tdata[30]} {design_1_i/dvi_out_0/inst/m_axis_tdata[31]}]]
connect_debug_port u_ila_1/probe2 [get_nets [list design_1_i/dvi_out_0/inst/m_axis_tlast]]
connect_debug_port u_ila_1/probe3 [get_nets [list design_1_i/dvi_out_0/inst/m_axis_tready]]
connect_debug_port u_ila_1/probe4 [get_nets [list design_1_i/dvi_out_0/inst/m_axis_tvalid]]
connect_debug_port dbg_hub/clk [get_nets clk_1]

create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list design_1_i/dvi2rgb_0/U0/GenerateBUFG.ResyncToBUFG_X/CLK]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 3 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {design_1_i/rgb_debuger_0/inst/curr_state[0]} {design_1_i/rgb_debuger_0/inst/curr_state[1]} {design_1_i/rgb_debuger_0/inst/curr_state[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 32 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {design_1_i/rgb_debuger_0/inst/g_count[0]} {design_1_i/rgb_debuger_0/inst/g_count[1]} {design_1_i/rgb_debuger_0/inst/g_count[2]} {design_1_i/rgb_debuger_0/inst/g_count[3]} {design_1_i/rgb_debuger_0/inst/g_count[4]} {design_1_i/rgb_debuger_0/inst/g_count[5]} {design_1_i/rgb_debuger_0/inst/g_count[6]} {design_1_i/rgb_debuger_0/inst/g_count[7]} {design_1_i/rgb_debuger_0/inst/g_count[8]} {design_1_i/rgb_debuger_0/inst/g_count[9]} {design_1_i/rgb_debuger_0/inst/g_count[10]} {design_1_i/rgb_debuger_0/inst/g_count[11]} {design_1_i/rgb_debuger_0/inst/g_count[12]} {design_1_i/rgb_debuger_0/inst/g_count[13]} {design_1_i/rgb_debuger_0/inst/g_count[14]} {design_1_i/rgb_debuger_0/inst/g_count[15]} {design_1_i/rgb_debuger_0/inst/g_count[16]} {design_1_i/rgb_debuger_0/inst/g_count[17]} {design_1_i/rgb_debuger_0/inst/g_count[18]} {design_1_i/rgb_debuger_0/inst/g_count[19]} {design_1_i/rgb_debuger_0/inst/g_count[20]} {design_1_i/rgb_debuger_0/inst/g_count[21]} {design_1_i/rgb_debuger_0/inst/g_count[22]} {design_1_i/rgb_debuger_0/inst/g_count[23]} {design_1_i/rgb_debuger_0/inst/g_count[24]} {design_1_i/rgb_debuger_0/inst/g_count[25]} {design_1_i/rgb_debuger_0/inst/g_count[26]} {design_1_i/rgb_debuger_0/inst/g_count[27]} {design_1_i/rgb_debuger_0/inst/g_count[28]} {design_1_i/rgb_debuger_0/inst/g_count[29]} {design_1_i/rgb_debuger_0/inst/g_count[30]} {design_1_i/rgb_debuger_0/inst/g_count[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 32 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {design_1_i/rgb_debuger_0/inst/ver_count[0]} {design_1_i/rgb_debuger_0/inst/ver_count[1]} {design_1_i/rgb_debuger_0/inst/ver_count[2]} {design_1_i/rgb_debuger_0/inst/ver_count[3]} {design_1_i/rgb_debuger_0/inst/ver_count[4]} {design_1_i/rgb_debuger_0/inst/ver_count[5]} {design_1_i/rgb_debuger_0/inst/ver_count[6]} {design_1_i/rgb_debuger_0/inst/ver_count[7]} {design_1_i/rgb_debuger_0/inst/ver_count[8]} {design_1_i/rgb_debuger_0/inst/ver_count[9]} {design_1_i/rgb_debuger_0/inst/ver_count[10]} {design_1_i/rgb_debuger_0/inst/ver_count[11]} {design_1_i/rgb_debuger_0/inst/ver_count[12]} {design_1_i/rgb_debuger_0/inst/ver_count[13]} {design_1_i/rgb_debuger_0/inst/ver_count[14]} {design_1_i/rgb_debuger_0/inst/ver_count[15]} {design_1_i/rgb_debuger_0/inst/ver_count[16]} {design_1_i/rgb_debuger_0/inst/ver_count[17]} {design_1_i/rgb_debuger_0/inst/ver_count[18]} {design_1_i/rgb_debuger_0/inst/ver_count[19]} {design_1_i/rgb_debuger_0/inst/ver_count[20]} {design_1_i/rgb_debuger_0/inst/ver_count[21]} {design_1_i/rgb_debuger_0/inst/ver_count[22]} {design_1_i/rgb_debuger_0/inst/ver_count[23]} {design_1_i/rgb_debuger_0/inst/ver_count[24]} {design_1_i/rgb_debuger_0/inst/ver_count[25]} {design_1_i/rgb_debuger_0/inst/ver_count[26]} {design_1_i/rgb_debuger_0/inst/ver_count[27]} {design_1_i/rgb_debuger_0/inst/ver_count[28]} {design_1_i/rgb_debuger_0/inst/ver_count[29]} {design_1_i/rgb_debuger_0/inst/ver_count[30]} {design_1_i/rgb_debuger_0/inst/ver_count[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 32 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {design_1_i/rgb_debuger_0/inst/hor_count_max[0]} {design_1_i/rgb_debuger_0/inst/hor_count_max[1]} {design_1_i/rgb_debuger_0/inst/hor_count_max[2]} {design_1_i/rgb_debuger_0/inst/hor_count_max[3]} {design_1_i/rgb_debuger_0/inst/hor_count_max[4]} {design_1_i/rgb_debuger_0/inst/hor_count_max[5]} {design_1_i/rgb_debuger_0/inst/hor_count_max[6]} {design_1_i/rgb_debuger_0/inst/hor_count_max[7]} {design_1_i/rgb_debuger_0/inst/hor_count_max[8]} {design_1_i/rgb_debuger_0/inst/hor_count_max[9]} {design_1_i/rgb_debuger_0/inst/hor_count_max[10]} {design_1_i/rgb_debuger_0/inst/hor_count_max[11]} {design_1_i/rgb_debuger_0/inst/hor_count_max[12]} {design_1_i/rgb_debuger_0/inst/hor_count_max[13]} {design_1_i/rgb_debuger_0/inst/hor_count_max[14]} {design_1_i/rgb_debuger_0/inst/hor_count_max[15]} {design_1_i/rgb_debuger_0/inst/hor_count_max[16]} {design_1_i/rgb_debuger_0/inst/hor_count_max[17]} {design_1_i/rgb_debuger_0/inst/hor_count_max[18]} {design_1_i/rgb_debuger_0/inst/hor_count_max[19]} {design_1_i/rgb_debuger_0/inst/hor_count_max[20]} {design_1_i/rgb_debuger_0/inst/hor_count_max[21]} {design_1_i/rgb_debuger_0/inst/hor_count_max[22]} {design_1_i/rgb_debuger_0/inst/hor_count_max[23]} {design_1_i/rgb_debuger_0/inst/hor_count_max[24]} {design_1_i/rgb_debuger_0/inst/hor_count_max[25]} {design_1_i/rgb_debuger_0/inst/hor_count_max[26]} {design_1_i/rgb_debuger_0/inst/hor_count_max[27]} {design_1_i/rgb_debuger_0/inst/hor_count_max[28]} {design_1_i/rgb_debuger_0/inst/hor_count_max[29]} {design_1_i/rgb_debuger_0/inst/hor_count_max[30]} {design_1_i/rgb_debuger_0/inst/hor_count_max[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 32 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {design_1_i/rgb_debuger_0/inst/r_count[0]} {design_1_i/rgb_debuger_0/inst/r_count[1]} {design_1_i/rgb_debuger_0/inst/r_count[2]} {design_1_i/rgb_debuger_0/inst/r_count[3]} {design_1_i/rgb_debuger_0/inst/r_count[4]} {design_1_i/rgb_debuger_0/inst/r_count[5]} {design_1_i/rgb_debuger_0/inst/r_count[6]} {design_1_i/rgb_debuger_0/inst/r_count[7]} {design_1_i/rgb_debuger_0/inst/r_count[8]} {design_1_i/rgb_debuger_0/inst/r_count[9]} {design_1_i/rgb_debuger_0/inst/r_count[10]} {design_1_i/rgb_debuger_0/inst/r_count[11]} {design_1_i/rgb_debuger_0/inst/r_count[12]} {design_1_i/rgb_debuger_0/inst/r_count[13]} {design_1_i/rgb_debuger_0/inst/r_count[14]} {design_1_i/rgb_debuger_0/inst/r_count[15]} {design_1_i/rgb_debuger_0/inst/r_count[16]} {design_1_i/rgb_debuger_0/inst/r_count[17]} {design_1_i/rgb_debuger_0/inst/r_count[18]} {design_1_i/rgb_debuger_0/inst/r_count[19]} {design_1_i/rgb_debuger_0/inst/r_count[20]} {design_1_i/rgb_debuger_0/inst/r_count[21]} {design_1_i/rgb_debuger_0/inst/r_count[22]} {design_1_i/rgb_debuger_0/inst/r_count[23]} {design_1_i/rgb_debuger_0/inst/r_count[24]} {design_1_i/rgb_debuger_0/inst/r_count[25]} {design_1_i/rgb_debuger_0/inst/r_count[26]} {design_1_i/rgb_debuger_0/inst/r_count[27]} {design_1_i/rgb_debuger_0/inst/r_count[28]} {design_1_i/rgb_debuger_0/inst/r_count[29]} {design_1_i/rgb_debuger_0/inst/r_count[30]} {design_1_i/rgb_debuger_0/inst/r_count[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 24 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list {design_1_i/rgb_debuger_0/inst/vid_pData[0]} {design_1_i/rgb_debuger_0/inst/vid_pData[1]} {design_1_i/rgb_debuger_0/inst/vid_pData[2]} {design_1_i/rgb_debuger_0/inst/vid_pData[3]} {design_1_i/rgb_debuger_0/inst/vid_pData[4]} {design_1_i/rgb_debuger_0/inst/vid_pData[5]} {design_1_i/rgb_debuger_0/inst/vid_pData[6]} {design_1_i/rgb_debuger_0/inst/vid_pData[7]} {design_1_i/rgb_debuger_0/inst/vid_pData[8]} {design_1_i/rgb_debuger_0/inst/vid_pData[9]} {design_1_i/rgb_debuger_0/inst/vid_pData[10]} {design_1_i/rgb_debuger_0/inst/vid_pData[11]} {design_1_i/rgb_debuger_0/inst/vid_pData[12]} {design_1_i/rgb_debuger_0/inst/vid_pData[13]} {design_1_i/rgb_debuger_0/inst/vid_pData[14]} {design_1_i/rgb_debuger_0/inst/vid_pData[15]} {design_1_i/rgb_debuger_0/inst/vid_pData[16]} {design_1_i/rgb_debuger_0/inst/vid_pData[17]} {design_1_i/rgb_debuger_0/inst/vid_pData[18]} {design_1_i/rgb_debuger_0/inst/vid_pData[19]} {design_1_i/rgb_debuger_0/inst/vid_pData[20]} {design_1_i/rgb_debuger_0/inst/vid_pData[21]} {design_1_i/rgb_debuger_0/inst/vid_pData[22]} {design_1_i/rgb_debuger_0/inst/vid_pData[23]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 32 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list {design_1_i/rgb_debuger_0/inst/b_count[0]} {design_1_i/rgb_debuger_0/inst/b_count[1]} {design_1_i/rgb_debuger_0/inst/b_count[2]} {design_1_i/rgb_debuger_0/inst/b_count[3]} {design_1_i/rgb_debuger_0/inst/b_count[4]} {design_1_i/rgb_debuger_0/inst/b_count[5]} {design_1_i/rgb_debuger_0/inst/b_count[6]} {design_1_i/rgb_debuger_0/inst/b_count[7]} {design_1_i/rgb_debuger_0/inst/b_count[8]} {design_1_i/rgb_debuger_0/inst/b_count[9]} {design_1_i/rgb_debuger_0/inst/b_count[10]} {design_1_i/rgb_debuger_0/inst/b_count[11]} {design_1_i/rgb_debuger_0/inst/b_count[12]} {design_1_i/rgb_debuger_0/inst/b_count[13]} {design_1_i/rgb_debuger_0/inst/b_count[14]} {design_1_i/rgb_debuger_0/inst/b_count[15]} {design_1_i/rgb_debuger_0/inst/b_count[16]} {design_1_i/rgb_debuger_0/inst/b_count[17]} {design_1_i/rgb_debuger_0/inst/b_count[18]} {design_1_i/rgb_debuger_0/inst/b_count[19]} {design_1_i/rgb_debuger_0/inst/b_count[20]} {design_1_i/rgb_debuger_0/inst/b_count[21]} {design_1_i/rgb_debuger_0/inst/b_count[22]} {design_1_i/rgb_debuger_0/inst/b_count[23]} {design_1_i/rgb_debuger_0/inst/b_count[24]} {design_1_i/rgb_debuger_0/inst/b_count[25]} {design_1_i/rgb_debuger_0/inst/b_count[26]} {design_1_i/rgb_debuger_0/inst/b_count[27]} {design_1_i/rgb_debuger_0/inst/b_count[28]} {design_1_i/rgb_debuger_0/inst/b_count[29]} {design_1_i/rgb_debuger_0/inst/b_count[30]} {design_1_i/rgb_debuger_0/inst/b_count[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 32 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list {design_1_i/rgb_debuger_0/inst/hor_count[0]} {design_1_i/rgb_debuger_0/inst/hor_count[1]} {design_1_i/rgb_debuger_0/inst/hor_count[2]} {design_1_i/rgb_debuger_0/inst/hor_count[3]} {design_1_i/rgb_debuger_0/inst/hor_count[4]} {design_1_i/rgb_debuger_0/inst/hor_count[5]} {design_1_i/rgb_debuger_0/inst/hor_count[6]} {design_1_i/rgb_debuger_0/inst/hor_count[7]} {design_1_i/rgb_debuger_0/inst/hor_count[8]} {design_1_i/rgb_debuger_0/inst/hor_count[9]} {design_1_i/rgb_debuger_0/inst/hor_count[10]} {design_1_i/rgb_debuger_0/inst/hor_count[11]} {design_1_i/rgb_debuger_0/inst/hor_count[12]} {design_1_i/rgb_debuger_0/inst/hor_count[13]} {design_1_i/rgb_debuger_0/inst/hor_count[14]} {design_1_i/rgb_debuger_0/inst/hor_count[15]} {design_1_i/rgb_debuger_0/inst/hor_count[16]} {design_1_i/rgb_debuger_0/inst/hor_count[17]} {design_1_i/rgb_debuger_0/inst/hor_count[18]} {design_1_i/rgb_debuger_0/inst/hor_count[19]} {design_1_i/rgb_debuger_0/inst/hor_count[20]} {design_1_i/rgb_debuger_0/inst/hor_count[21]} {design_1_i/rgb_debuger_0/inst/hor_count[22]} {design_1_i/rgb_debuger_0/inst/hor_count[23]} {design_1_i/rgb_debuger_0/inst/hor_count[24]} {design_1_i/rgb_debuger_0/inst/hor_count[25]} {design_1_i/rgb_debuger_0/inst/hor_count[26]} {design_1_i/rgb_debuger_0/inst/hor_count[27]} {design_1_i/rgb_debuger_0/inst/hor_count[28]} {design_1_i/rgb_debuger_0/inst/hor_count[29]} {design_1_i/rgb_debuger_0/inst/hor_count[30]} {design_1_i/rgb_debuger_0/inst/hor_count[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 32 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list {design_1_i/rgb_to_stream_0/inst/hor_count[0]} {design_1_i/rgb_to_stream_0/inst/hor_count[1]} {design_1_i/rgb_to_stream_0/inst/hor_count[2]} {design_1_i/rgb_to_stream_0/inst/hor_count[3]} {design_1_i/rgb_to_stream_0/inst/hor_count[4]} {design_1_i/rgb_to_stream_0/inst/hor_count[5]} {design_1_i/rgb_to_stream_0/inst/hor_count[6]} {design_1_i/rgb_to_stream_0/inst/hor_count[7]} {design_1_i/rgb_to_stream_0/inst/hor_count[8]} {design_1_i/rgb_to_stream_0/inst/hor_count[9]} {design_1_i/rgb_to_stream_0/inst/hor_count[10]} {design_1_i/rgb_to_stream_0/inst/hor_count[11]} {design_1_i/rgb_to_stream_0/inst/hor_count[12]} {design_1_i/rgb_to_stream_0/inst/hor_count[13]} {design_1_i/rgb_to_stream_0/inst/hor_count[14]} {design_1_i/rgb_to_stream_0/inst/hor_count[15]} {design_1_i/rgb_to_stream_0/inst/hor_count[16]} {design_1_i/rgb_to_stream_0/inst/hor_count[17]} {design_1_i/rgb_to_stream_0/inst/hor_count[18]} {design_1_i/rgb_to_stream_0/inst/hor_count[19]} {design_1_i/rgb_to_stream_0/inst/hor_count[20]} {design_1_i/rgb_to_stream_0/inst/hor_count[21]} {design_1_i/rgb_to_stream_0/inst/hor_count[22]} {design_1_i/rgb_to_stream_0/inst/hor_count[23]} {design_1_i/rgb_to_stream_0/inst/hor_count[24]} {design_1_i/rgb_to_stream_0/inst/hor_count[25]} {design_1_i/rgb_to_stream_0/inst/hor_count[26]} {design_1_i/rgb_to_stream_0/inst/hor_count[27]} {design_1_i/rgb_to_stream_0/inst/hor_count[28]} {design_1_i/rgb_to_stream_0/inst/hor_count[29]} {design_1_i/rgb_to_stream_0/inst/hor_count[30]} {design_1_i/rgb_to_stream_0/inst/hor_count[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 3 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list {design_1_i/rgb_to_stream_0/inst/curr_state[0]} {design_1_i/rgb_to_stream_0/inst/curr_state[1]} {design_1_i/rgb_to_stream_0/inst/curr_state[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
set_property port_width 32 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list {design_1_i/rgb_to_stream_0/inst/ver_count[0]} {design_1_i/rgb_to_stream_0/inst/ver_count[1]} {design_1_i/rgb_to_stream_0/inst/ver_count[2]} {design_1_i/rgb_to_stream_0/inst/ver_count[3]} {design_1_i/rgb_to_stream_0/inst/ver_count[4]} {design_1_i/rgb_to_stream_0/inst/ver_count[5]} {design_1_i/rgb_to_stream_0/inst/ver_count[6]} {design_1_i/rgb_to_stream_0/inst/ver_count[7]} {design_1_i/rgb_to_stream_0/inst/ver_count[8]} {design_1_i/rgb_to_stream_0/inst/ver_count[9]} {design_1_i/rgb_to_stream_0/inst/ver_count[10]} {design_1_i/rgb_to_stream_0/inst/ver_count[11]} {design_1_i/rgb_to_stream_0/inst/ver_count[12]} {design_1_i/rgb_to_stream_0/inst/ver_count[13]} {design_1_i/rgb_to_stream_0/inst/ver_count[14]} {design_1_i/rgb_to_stream_0/inst/ver_count[15]} {design_1_i/rgb_to_stream_0/inst/ver_count[16]} {design_1_i/rgb_to_stream_0/inst/ver_count[17]} {design_1_i/rgb_to_stream_0/inst/ver_count[18]} {design_1_i/rgb_to_stream_0/inst/ver_count[19]} {design_1_i/rgb_to_stream_0/inst/ver_count[20]} {design_1_i/rgb_to_stream_0/inst/ver_count[21]} {design_1_i/rgb_to_stream_0/inst/ver_count[22]} {design_1_i/rgb_to_stream_0/inst/ver_count[23]} {design_1_i/rgb_to_stream_0/inst/ver_count[24]} {design_1_i/rgb_to_stream_0/inst/ver_count[25]} {design_1_i/rgb_to_stream_0/inst/ver_count[26]} {design_1_i/rgb_to_stream_0/inst/ver_count[27]} {design_1_i/rgb_to_stream_0/inst/ver_count[28]} {design_1_i/rgb_to_stream_0/inst/ver_count[29]} {design_1_i/rgb_to_stream_0/inst/ver_count[30]} {design_1_i/rgb_to_stream_0/inst/ver_count[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
set_property port_width 1 [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list design_1_i/rgb_to_stream_0/inst/do_frame]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe12]
set_property port_width 1 [get_debug_ports u_ila_0/probe12]
connect_debug_port u_ila_0/probe12 [get_nets [list design_1_i/rgb_to_stream_0/inst/frame_pulse]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe13]
set_property port_width 1 [get_debug_ports u_ila_0/probe13]
connect_debug_port u_ila_0/probe13 [get_nets [list design_1_i/rgb_to_stream_0/inst/m_axis_tlast]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe14]
set_property port_width 1 [get_debug_ports u_ila_0/probe14]
connect_debug_port u_ila_0/probe14 [get_nets [list design_1_i/rgb_to_stream_0/inst/m_axis_tvalid]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe15]
set_property port_width 1 [get_debug_ports u_ila_0/probe15]
connect_debug_port u_ila_0/probe15 [get_nets [list design_1_i/rgb_debuger_0/inst/vid_pHSync]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe16]
set_property port_width 1 [get_debug_ports u_ila_0/probe16]
connect_debug_port u_ila_0/probe16 [get_nets [list design_1_i/rgb_debuger_0/inst/vid_pVDE]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe17]
set_property port_width 1 [get_debug_ports u_ila_0/probe17]
connect_debug_port u_ila_0/probe17 [get_nets [list design_1_i/rgb_debuger_0/inst/vid_pVSync]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets u_ila_0_CLK]
