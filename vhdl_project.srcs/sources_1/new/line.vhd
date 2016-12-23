----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/02/2016 07:15:11 PM
-- Design Name: 
-- Module Name: line - Behavioral
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
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all; --Library to perform arithmatic :  http://www.synthworks.com/papers/vhdl_math_tricks_mapld_2003.pdf

entity draw_line is
    Port ( X_CURRENT   :in STD_LOGIC_VECTOR (9 downto 0);
           Y_CURRENT   :in STD_LOGIC_VECTOR (9 downto 0);
           VISIBLE_AREA:in STD_LOGIC; 
           X_START     :in STD_LOGIC_VECTOR (9 downto 0);
           Y_START     :in STD_LOGIC_VECTOR (9 downto 0);
           X_STOP      :in STD_LOGIC_VECTOR (9 downto 0);
           Y_STOP      :in STD_LOGIC_VECTOR (9 downto 0);
           SHOW        :out STD_LOGIC
           );
end draw_line;


architecture Behavioral of draw_line is

begin
--asynchronous process that generates a control system for the mux to switch between colors
line_process: process(X_CURRENT,Y_CURRENT,VISIBLE_AREA)

constant delta : integer := 5;

begin
    if(((signed(Y_CURRENT) - signed(Y_START))*(signed(X_START)-signed(X_STOP)))=((signed(Y_START)-signed(Y_STOP))*(signed(X_CURRENT)-signed(X_START)))) and
      (X_CURRENT <= X_STOP ) and
      (X_CURRENT >= X_START) and 
      (Y_CURRENT <= Y_STOP ) and 
      (Y_CURRENT >= Y_START) and 
      (VISIBLE_AREA = '1' ) then
        SHOW <= '1';
     else
        SHOW <= '0';
    end if;
    
end process;

end Behavioral;
