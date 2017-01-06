----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/28/2016 08:39:21 PM
-- Design Name: 
-- Module Name: PLL_9MHz_TB - Behavioral
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

entity PLL_9MHz_tb is
end;

architecture bench of PLL_9MHz_tb is

  component PLL_9MHz
      Port ( CLK : in STD_LOGIC;
             RST : in STD_LOGIC;
             CLK_9MHz: out STD_LOGIC);
  end component;

  signal CLK: STD_LOGIC;
  signal RST: STD_LOGIC;
  signal CLK_9MHz: STD_LOGIC;

  constant clock_period: time := 8 ns;
begin

  uut: PLL_9MHz port map ( CLK      => CLK,
                           RST      => RST,
                           CLK_9MHz => CLK_9MHz );

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