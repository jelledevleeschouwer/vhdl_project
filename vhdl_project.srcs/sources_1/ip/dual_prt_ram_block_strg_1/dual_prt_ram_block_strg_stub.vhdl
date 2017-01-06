-- Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2016.2 (win64) Build 1577090 Thu Jun  2 16:32:40 MDT 2016
-- Date        : Tue Jan 03 20:30:01 2017
-- Host        : DESKTOP-I9KA4SE running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               Z:/Documents/School/2016-2017/Programmable_Logic/vhdl_project_copy/vhdl_project.srcs/sources_1/ip/dual_prt_ram_block_strg_1/dual_prt_ram_block_strg_stub.vhdl
-- Design      : dual_prt_ram_block_strg
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7z010clg400-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity dual_prt_ram_block_strg is
  Port ( 
    clka : in STD_LOGIC;
    wea : in STD_LOGIC_VECTOR ( 0 to 0 );
    addra : in STD_LOGIC_VECTOR ( 3 downto 0 );
    dina : in STD_LOGIC_VECTOR ( 28 downto 0 );
    douta : out STD_LOGIC_VECTOR ( 28 downto 0 );
    clkb : in STD_LOGIC;
    web : in STD_LOGIC_VECTOR ( 0 to 0 );
    addrb : in STD_LOGIC_VECTOR ( 3 downto 0 );
    dinb : in STD_LOGIC_VECTOR ( 28 downto 0 );
    doutb : out STD_LOGIC_VECTOR ( 28 downto 0 )
  );

end dual_prt_ram_block_strg;

architecture stub of dual_prt_ram_block_strg is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clka,wea[0:0],addra[3:0],dina[28:0],douta[28:0],clkb,web[0:0],addrb[3:0],dinb[28:0],doutb[28:0]";
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "blk_mem_gen_v8_3_3,Vivado 2016.2";
begin
end;
