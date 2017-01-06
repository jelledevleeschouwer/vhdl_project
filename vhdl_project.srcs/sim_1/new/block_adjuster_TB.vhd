----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/22/2016 12:54:59 PM
-- Design Name: 
-- Module Name: block_adjuster_TB - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity block_adjuster_tb is
end;

architecture bench of block_adjuster_tb is

  component block_adjuster
    Port ( 
             CLK : in STD_LOGIC;
             RST : in STD_LOGIC;
             POS_FIRST : in std_logic_vector(3 downto 0);
             XPOS : in std_logic_vector(8 downto 0);
             YPOS : in std_logic_vector(8 downto 0);
             DISP_EN : in std_logic;
             DOUT_B : in std_logic_vector(28 downto 0);
             DIN_B  : out std_logic_vector(28 downto 0);
             ADDR_B : out std_logic_vector(3 downto 0);
             WE_B   : out std_logic_vector(0 downto 0);
             SHOW : out std_logic;
             V_SYNC : in std_logic
             );
  end component;

  signal CLK: STD_LOGIC;
  signal RST: STD_LOGIC;
  signal POS_FIRST: std_logic_vector(3 downto 0);
  signal XPOS: std_logic_vector(8 downto 0);
  signal YPOS: std_logic_vector(8 downto 0);
  signal DISP_EN: std_logic;
  signal DOUT_B: std_logic_vector(28 downto 0);
  signal DIN_B: std_logic_vector(28 downto 0);
  signal ADDR_B: std_logic_vector(3 downto 0);
  signal WE_B: std_logic_vector(0 downto 0);
  signal SHOW: std_logic;
  signal V_SYNC: std_logic ;

  constant clock_period: time := 8 ns;

begin

  uut: block_adjuster port map ( CLK       => CLK,
                                 RST       => RST,
                                 POS_FIRST => POS_FIRST,
                                 XPOS      => XPOS,
                                 YPOS      => YPOS,
                                 DISP_EN   => DISP_EN,
                                 DOUT_B    => DOUT_B,
                                 DIN_B     => DIN_B,
                                 ADDR_B    => ADDR_B,
                                 WE_B      => WE_B,
                                 SHOW      => SHOW,
                                 V_SYNC    => V_SYNC );

  stimulus: process
  begin

    RST<='1';
    V_SYNC<='1';
    DOUT_B<="00000000000000000000000000000";
    wait for clock_period*2;
    RST<='0';
    wait for clock_period*2;
    V_SYNC<='0';
    wait;

  end process;

  clocking: process
  begin
    CLK<='1';
    wait for clock_period/2;
    CLK<='0';
    wait for clock_period/2;
  end process;

end;