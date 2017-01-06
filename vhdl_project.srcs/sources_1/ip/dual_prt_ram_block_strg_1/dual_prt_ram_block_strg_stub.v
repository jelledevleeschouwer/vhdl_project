// Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2016.2 (win64) Build 1577090 Thu Jun  2 16:32:40 MDT 2016
// Date        : Tue Jan 03 20:30:01 2017
// Host        : DESKTOP-I9KA4SE running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               Z:/Documents/School/2016-2017/Programmable_Logic/vhdl_project_copy/vhdl_project.srcs/sources_1/ip/dual_prt_ram_block_strg_1/dual_prt_ram_block_strg_stub.v
// Design      : dual_prt_ram_block_strg
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z010clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_3_3,Vivado 2016.2" *)
module dual_prt_ram_block_strg(clka, wea, addra, dina, douta, clkb, web, addrb, dinb, doutb)
/* synthesis syn_black_box black_box_pad_pin="clka,wea[0:0],addra[3:0],dina[28:0],douta[28:0],clkb,web[0:0],addrb[3:0],dinb[28:0],doutb[28:0]" */;
  input clka;
  input [0:0]wea;
  input [3:0]addra;
  input [28:0]dina;
  output [28:0]douta;
  input clkb;
  input [0:0]web;
  input [3:0]addrb;
  input [28:0]dinb;
  output [28:0]doutb;
endmodule
