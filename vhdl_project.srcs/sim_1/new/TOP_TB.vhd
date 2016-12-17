----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/29/2016 03:59:09 PM
-- Design Name: 
-- Module Name: TOP_TB - Behavioral
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

entity TOP_tb is
end;

architecture bench of TOP_tb is

  component TOP
      Port ( CLK     :in  STD_LOGIC;
             RST     :in  STD_LOGIC;
             H_SYNC  :out STD_LOGIC;
             V_SYNC  :out STD_LOGIC;
             DISP_EN :out STD_LOGIC;
             RED     :out STD_LOGIC_VECTOR (3 downto 0);
             GREEN   :out STD_LOGIC_VECTOR (3 downto 0);
             BLUE    :out STD_LOGIC_VECTOR (2 downto 0)   
             );
  end component;

  signal CLK: STD_LOGIC;
  signal RST: STD_LOGIC;
  signal H_SYNC: STD_LOGIC;
  signal V_SYNC: STD_LOGIC;
  signal DISP_EN: STD_LOGIC;
  signal RED: STD_LOGIC_VECTOR (3 downto 0);
  signal GREEN: STD_LOGIC_VECTOR (3 downto 0);
  signal BLUE: STD_LOGIC_VECTOR (2 downto 0);
  
  constant clock_period: time := 8 ns;

begin

  uut: TOP port map ( CLK     => CLK,
                      RST     => RST,
                      H_SYNC  => H_SYNC,
                      V_SYNC  => V_SYNC,
                      DISP_EN => DISP_EN,
                      RED     => RED,
                      GREEN   => GREEN,
                      BLUE    => BLUE );

  stimulus: process
  begin
    RST<='1';
    wait for clock_period*2;
    RST<='0';
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