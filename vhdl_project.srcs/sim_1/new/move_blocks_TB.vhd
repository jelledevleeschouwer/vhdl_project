----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/22/2016 02:31:18 PM
-- Design Name: 
-- Module Name: move_blocks_TB - Behavioral
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

entity move_blocks_tb is
end;

architecture bench of move_blocks_tb is

  component move_blocks
      Port ( 
             CLK      : in  STD_LOGIC;
             RST      : in  STD_LOGIC;
             V_SYNC   : in  STD_LOGIC;
             DOUT_B   : in  STD_LOGIC_VECTOR(28 downto 0);
             DIN_B    : out STD_LOGIC_VECTOR(28 downto 0);
             WE_B     : out STD_LOGIC_VECTOR(0 downto 0);
             ADDR_B   : out STD_LOGIC_VECTOR(3 downto 0)
             );
  end component;

  signal CLK: STD_LOGIC;
  signal RST: STD_LOGIC;
  signal V_SYNC: STD_LOGIC;
  signal DOUT_B: STD_LOGIC_VECTOR(28 downto 0);
  signal DIN_B: STD_LOGIC_VECTOR(28 downto 0);
  signal WE_B: STD_LOGIC_VECTOR(0 downto 0);
  signal ADDR_B: STD_LOGIC_VECTOR(3 downto 0) ;

  constant clock_period: time := 8 ns;

begin

  uut: move_blocks port map ( CLK    => CLK,
                              RST    => RST,
                              V_SYNC => V_SYNC,
                              DOUT_B => DOUT_B,
                              DIN_B  => DIN_B,
                              WE_B   => WE_B,
                              ADDR_B => ADDR_B );

  stimulus: process
  begin
  
    -- Put initialisation code here
    RST<='1';
    V_SYNC<='1';
    DOUT_B <= "00000000000000000000000000000";
    wait for clock_period*2;
    RST<='0';
    wait for clock_period*20;
    V_SYNC<='0';
    wait;

    -- Put test bench stimulus code here


  end process;

  clocking: process
  begin
    CLK<='1';
    wait for clock_period/2;
    CLK<='0';
    wait for clock_period/2;
  end process;

end;