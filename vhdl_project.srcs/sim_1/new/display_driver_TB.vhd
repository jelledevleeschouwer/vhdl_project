----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Carleer Jasper
-- 
-- Create Date: 11/28/2016 07:03:04 PM
-- Design Name: 
-- Module Name: display_driver_TB - Behavioral
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

entity display_driver_tb is
end;

architecture bench of display_driver_tb is

  component display_driver
      Port (
             P_CLK : in STD_LOGIC; 
             RST : in STD_LOGIC;
             H_SYNC : out STD_LOGIC;
             V_SYNC : out STD_LOGIC;
             DISP_EN : out STD_LOGIC;
             VALID : out STD_LOGIC;
             X_POS : out STD_LOGIC_VECTOR (9 downto 0);
             Y_POS : out STD_LOGIC_VECTOR (9 downto 0);
             RED : out STD_LOGIC_VECTOR (3 downto 0);
             GREEN : out STD_LOGIC_VECTOR (3 downto 0);
             BLUE : out STD_LOGIC_VECTOR (2 downto 0)         
             );
  end component;

  signal P_CLK: STD_LOGIC;
  signal RST: STD_LOGIC;
  signal H_SYNC: STD_LOGIC;
  signal V_SYNC: STD_LOGIC;
  signal DISP_EN: STD_LOGIC;
  signal VALID: STD_LOGIC;
  signal X_POS: STD_LOGIC_VECTOR (9 downto 0);
  signal Y_POS: STD_LOGIC_VECTOR (9 downto 0);
  signal RED: STD_LOGIC_VECTOR (3 downto 0);
  signal GREEN: STD_LOGIC_VECTOR (3 downto 0);
  signal BLUE: STD_LOGIC_VECTOR (2 downto 0) ;

  constant clock_period: time := 1 ns;

begin

  uut: display_driver port map ( P_CLK   => P_CLK,
                                 RST     => RST,
                                 H_SYNC  => H_SYNC,
                                 V_SYNC  => V_SYNC,
                                 DISP_EN => DISP_EN,
                                 VALID   => VALID,
                                 X_POS   => X_POS,
                                 Y_POS   => Y_POS,
                                 RED     => RED,
                                 GREEN   => GREEN,
                                 BLUE    => BLUE );

  stimulus: process
  begin
  
    -- Put initialisation code here
    RST<='1';
    wait for clock_period*5;
    RST<='0';
    wait;
  end process;

  clocking: process
  begin
    P_CLK<='1';
    wait for clock_period/2;
    P_CLK<='0';
    wait for clock_period/2;
  end process;

end;