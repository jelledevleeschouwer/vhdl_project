// Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2016.2 (win64) Build 1577090 Thu Jun  2 16:32:40 MDT 2016
// Date        : Sat Dec 10 09:26:36 2016
// Host        : Jasper-laptop running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               c:/Users/jasper/Documents/Schooljaar_2016-2017/Programmable_logic/vhdl_project/vhdl_project.srcs/sources_1/ip/dual_prt_ram_block_strg/dual_prt_ram_block_strg_stub.v
// Design      : dual_prt_ram_block_strg
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z010clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_3_3,Vivado 2016.2" *)
module dual_prt_ram_block_strg(clka, rsta, ena, wea, addra, dina, douta, clkb, rstb, enb, web, addrb, dinb, doutb)
/* synthesis syn_black_box black_box_pad_pin="clka,rsta,ena,wea[0:0],addra[5:0],dina[9:0],douta[9:0],clkb,rstb,enb,web[0:0],addrb[5:0],dinb[9:0],doutb[9:0]" */;
  input clka;
  input rsta;
  input ena;
  input [0:0]wea;
  input [5:0]addra;
  input [9:0]dina;
  output [9:0]douta;
  input clkb;
  input rstb;
  input enb;
  input [0:0]web;
  input [5:0]addrb;
  input [9:0]dinb;
  output [9:0]doutb;
endmodule
