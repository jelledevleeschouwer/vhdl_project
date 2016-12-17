----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/06/2016 03:25:11 PM
-- Design Name: 
-- Module Name: algoritme - Behavioral
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
--use IEEE.STD_LOGIC_arith.ALL;
use IEEE.NUMERIC_STD.all;



entity algoritme is
    Port ( CLK : in STD_LOGIC;
           RST : in STD_LOGIC;
        
           DISP_EN : in STD_LOGIC;
           
           X_START_IN  : in std_logic_vector(9 downto 0);
           Y_START_IN  : in std_logic_vector(9 downto 0);
           X_STOP_IN   : in std_logic_vector(9 downto 0);
           Y_STOP_IN   : in std_logic_vector(9 downto 0);
           
           X_START_OUT : out std_logic_vector(9 downto 0);
           Y_START_OUT : out std_logic_vector(9 downto 0);
           X_STOP_OUT  : out std_logic_vector(9 downto 0);
           Y_STOP_OUT  : out std_logic_vector(9 downto 0)
           );
end algoritme;

architecture Behavioral of algoritme is

signal enable_counter   : std_logic;
shared variable new_x_start : integer range 480 downto 0:=to_integer(unsigned(X_START_IN));
shared variable new_y_start : integer range 272 downto 0:=to_integer(unsigned(Y_START_IN));
shared variable new_x_stop  : integer range 480 downto 0:=to_integer(unsigned(X_STOP_IN));
shared variable new_y_stop  : integer range 272 downto 0:=to_integer(unsigned(Y_STOP_IN));

begin

prescaler: process(CLK)
variable delay : integer range 125000001 downto 0:=0; --to generate an enable every 1Hz

begin

if (CLK'event and CLK='1') then
    if (RST='1') then
        delay := 0;
        enable_counter <= '0'; 
    else
        delay := delay + 1;
    end if; --end RST
    
    if delay = 125000000 then
        delay := 0;
        enable_counter <='1';
    else
        enable_counter <='0';
    end if;
    
end if; --end CLK

end process; --end prescaler process

move_object: process(CLK)

begin
    if (CLK'event and CLK='1') then
        if (RST='1') then
            new_x_start :=to_integer(unsigned(X_START_IN));
            new_y_start :=to_integer(unsigned(Y_START_IN));
            new_x_stop  :=to_integer(unsigned(X_STOP_IN));
            new_y_stop  :=to_integer(unsigned(Y_STOP_IN));
        elsif (enable_counter <='1') then
            new_x_start :=new_x_start + 1;
            new_y_start :=new_y_start + 1;
            new_x_stop  :=new_x_stop + 1;
            new_y_stop  :=new_y_stop +1;
        end if; --end reset
    end if; --end clock
end process;


assign_process: process(DISP_EN)

begin
    if (DISP_EN<='0') then
        X_START_OUT<=std_logic_vector(to_unsigned(new_x_start,10));
        Y_START_OUT<=std_logic_vector(to_unsigned(new_y_start,10));
        X_STOP_OUT<=std_logic_vector(to_unsigned(new_x_stop,10));
        Y_STOP_OUT<=std_logic_vector(to_unsigned(new_y_stop,10));
    end if;
end process;
        

end Behavioral;
