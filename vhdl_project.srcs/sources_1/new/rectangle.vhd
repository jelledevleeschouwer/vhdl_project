----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Carleer Jasper
-- 
-- Create Date: 12/02/2016 06:23:50 PM
-- Design Name: 
-- Module Name: rectangle - Behavioral
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
use IEEE.numeric_std.ALL;  --to be able to use +,-,.. and the signed type


entity draw_rectangle is
    Port ( X_CURRENT   :in STD_LOGIC_VECTOR (9 downto 0);
           Y_CURRENT   :in STD_LOGIC_VECTOR (9 downto 0);
           VISIBLE_AREA:in STD_LOGIC; --is '1' if we are in the visible area
           X_START     :in STD_LOGIC_VECTOR (9 downto 0);
           Y_START     :in STD_LOGIC_VECTOR (9 downto 0);
           X_LENGTH      :in STD_LOGIC_VECTOR (9 downto 0);
           Y_LENGTH      :in STD_LOGIC_VECTOR (9 downto 0);
           SHOW        :out STD_LOGIC -- '1' if we need to change the RGB to the rectangle color
           );
end draw_rectangle;

architecture Behavioral of draw_rectangle is

begin

--asynchronous process that generates a control system for the mux to switch between colors
rectangle_process: process(X_CURRENT,Y_CURRENT,VISIBLE_AREA)

begin

    if  (X_CURRENT <  std_logic_vector(signed(X_START) + signed(X_LENGTH) )) and
        (X_CURRENT >= X_START)                                               and 
        (Y_CURRENT <  std_logic_vector(signed(Y_START) + signed(Y_LENGTH) )) and 
        (Y_CURRENT >= Y_START)                                               and 
        (VISIBLE_AREA = '1'  )
        then
        SHOW <= '1';
     else
        SHOW <= '0';
    end if;
    
end process;


end Behavioral;
