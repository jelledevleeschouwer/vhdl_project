----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/14/2016 12:13:00 PM
-- Design Name: 
-- Module Name: block_generator_TB - Behavioral
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

entity block_generator_tb is
end;

architecture bench of block_generator_tb is

  component block_generator
      Port ( 
             CLK        : in STD_LOGIC;
             RST        : in STD_LOGIC;
             WRITE_EN_A : out std_logic_vector(0 downto 0);
             ADDR_A     : out std_logic_vector(3 downto 0);
             DIN_A      : out std_logic_vector(28 downto 0);
             POS_FIRST_O: out std_logic_vector(3 downto 0)
             );
  end component;

  signal CLK: STD_LOGIC;
  signal RST: STD_LOGIC;
  signal WRITE_EN_A: std_logic_vector(0 downto 0);
  signal ADDR_A: std_logic_vector(3 downto 0);
  signal DIN_A: std_logic_vector(28 downto 0);
  signal POS_FIRST_O: std_logic_vector(3 downto 0) ;

  constant clock_period: time := 10 ns;

begin

  uut: block_generator port map ( CLK         => CLK,
                                  RST         => RST,
                                  WRITE_EN_A  => WRITE_EN_A,
                                  ADDR_A      => ADDR_A,
                                  DIN_A       => DIN_A,
                                  POS_FIRST_O => POS_FIRST_O );

  stimulus: process
  begin
  
  -- Put initialisation code here
  RST<='1';
  wait for clock_period*2;
  -- Put test bench stimulus code here
  RST<='0';
  wait; --wait forever
  end process;

  clocking: process
  begin
    CLK<='1';
    wait for clock_period/2;
    CLK<='0';
    wait for clock_period/2;
  end process;

end;
