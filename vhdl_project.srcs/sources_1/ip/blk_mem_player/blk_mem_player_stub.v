// Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2016.2 (win64) Build 1577090 Thu Jun  2 16:32:40 MDT 2016
// Date        : Fri Jan 06 22:20:46 2017
// Host        : DESKTOP-I9KA4SE running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               Z:/Documents/School/2016-2017/Programmable_Logic/vhdl_project/vhdl_project.srcs/sources_1/ip/blk_mem_player/blk_mem_player_stub.v
// Design      : blk_mem_player
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z010clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_3_3,Vivado 2016.2" *)
module blk_mem_player(clka, addra, douta)
/* synthesis syn_black_box black_box_pad_pin="clka,addra[13:0],douta[11:0]" */;
  input clka;
  input [13:0]addra;
  output [11:0]douta;
endmodule