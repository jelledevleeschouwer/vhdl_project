----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/10/2016 09:28:19 AM
-- Design Name: 
-- Module Name: block_generator - Behavioral
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
--This module should generate a new block every X seconds
--This block is than stored in the dual port ram
--To know where to store the block a circular buffer principle is used

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity block_generator is
    Port ( 
           CLK        : in STD_LOGIC;
           RST        : in STD_LOGIC;
           
           WRITE_EN_A : out std_logic_vector(0 downto 0); --write enable for port A of the block ram
           ADDR_A     : out std_logic_vector(3 downto 0); --address to write the data 
           DIN_A      : out std_logic_vector(28 downto 0); --data to write to the block ram
           POS_FIRST_O: out std_logic_vector(3 downto 0) --used to create a circular buffer
           );
end block_generator;

architecture Behavioral of block_generator is
--parameters --149999999
constant prescale_count_limit          : integer :=100; --rate at which the blocks are added -> 2Hz
constant last_block                    : integer :=9; --index of the last element in the block ram
--signals
signal put_block     : std_logic; --put_block is one when we should add a new block to the DUAL PORT RAM

begin

prescaler: process(CLK)
variable count_value : integer range prescale_count_limit downto 0:=0;  

begin
    if(CLK'event and CLK='1')then
        if(RST='1')then
            put_block <= '0';
            count_value := 0;
        else
            count_value := count_value + 1; --increment count_value by one
            if(count_value = prescale_count_limit) then
                put_block <= '1'; --make put_block '1' for one clock pulse
                count_value := 0;
            else
                put_block <= '0';
            end if; --end delay
        end if; --end reset
    end if; --end clock

end process;

add_block: process(CLK)
variable pos_first : integer range last_block downto 0:=0; --variable to know the position of the first block
variable first_time : std_logic;
begin
    if(CLK'event and CLK='1')then
        if(RST='1')then
            WRITE_EN_A<="0";
            ADDR_A<="0000";
            DIN_A<="00000000000000000000000000000";
            pos_first:=last_block; --at reset set the pointer to the last element in the block ram
            first_time := '0';
        else
            if(first_time = '0')then
            if(put_block = '1')then
                --increment the position
                pos_first := pos_first + 1;
                if (pos_first = (last_block+1)) then
                    pos_first := 0; --wrap around
                end if; --end limit pos_first;
                
                --apply the right signals to the block ram
                ADDR_A      <= std_logic_vector(to_unsigned(pos_first,4)); --apply the right address 
                
                --*****************************************************
                --Case added for testing this should be replaced by a random generator
                --*****************************************************
                case pos_first is
                    when 0 => DIN_A <= "000000000" & "000110010" & "000011110" & "01";
                    when 1 => DIN_A <= "000110010" & "001100100" & "000110011" & "01";
                    when 2 => DIN_A <= "001100100" & "010010110" & "001001000" & "01";
                    when 3 => DIN_A <= "010010110" & "011001000" & "001011101" & "10";
                    when 4 => DIN_A <= "011001000" & "011111010" & "001110010" & "10";
                    when 5 => DIN_A <= "011111010" & "100101100" & "010000111" & "10";
                    when 6 => DIN_A <= "100101100" & "101011110" & "010011100" & "11";
                    when 7 => DIN_A <= "101011110" & "110010000" & "010110001" & "11";
                    when 8 => DIN_A <= "110010000" & "111000010" & "011000110" & "11";
                    when 9 => DIN_A <= "111000010" & "111100000" & "011011011" & "11";
                    
                    when  others => DIN_A <= "000000000" & "000000000" & "000000000" & "00";
                    
                end case;
                
                WRITE_EN_A  <= "1"; --make write enable 1
                
                --update the circular buffer
                POS_FIRST_O <= std_logic_vector(to_unsigned(pos_first,4)); --put the new pos_first on the output
                
            else
                WRITE_EN_A <= "0";
            end if; --end put_block
        end if; --end reset
    end if; --end clock
    
end process;

end Behavioral;
