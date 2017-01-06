----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/22/2016 01:56:10 PM
-- Design Name: 
-- Module Name: move_blocks - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

entity move_blocks is

    Port ( 
           CLK      : in  STD_LOGIC;
           RST      : in  STD_LOGIC;
           V_SYNC   : in  STD_LOGIC;
           DOUT_B   : in  STD_LOGIC_VECTOR(28 downto 0);
           DIN_B    : out STD_LOGIC_VECTOR(28 downto 0);
           WE_B     : out STD_LOGIC_VECTOR(0 downto 0);
           ADDR_B   : out STD_LOGIC_VECTOR(3 downto 0)

           );
           
end move_blocks;


architecture Behavioral of move_blocks is

--constants
constant increment_value: integer :=1;
constant delay_value : integer :=14999999;

--signals
signal move : std_logic;

begin


move_blocks: process(CLK)
variable read_delay : integer range 2 downto 0:=0;
variable addrb : integer range 10 downto 0:=0;
variable first_time : std_logic;
variable write : std_logic;
variable done : std_logic;
variable new_x1 : integer range 479 downto -479:=0;
variable new_x2 : integer range 479 downto -479:=0;
variable new_y  : integer range 300 downto 0:=0;
begin

if(CLK'event and CLK='1')then
    WE_B <= "0";
    
    if(RST ='1')then
        --RESET ROUTINE
        WE_B <="0";
        addrb := 0;
        first_time := '1';
        read_delay := 2;
        write := '0';
        done := '1';
        
    else
        if(move = '1')then --move the blocks at the timer interval
            done := '0';
        end if;
        
        if(V_SYNC = '0' and done = '0')then --if we are in the "update region" and not yet done updating the blocks
            
            if(first_time = '1')then --apply the first address
                first_time := '0';
                addrb := 0;
                read_delay := 2; --delay to allow the block ram to provide the right information
                write := '0';
            else
                if(read_delay = 0)then --data is valid
                    if(write = '0')then
                        
                        --increment y and make the block start at 96
                        new_y  := to_integer(unsigned(DOUT_B(10 downto 2)) + unsigned(DOUT_B(10 downto 2))/16);    
                        if(new_y <= 96)then
                            new_y := 96;
                        end if;
                        --!!this value should be altered!!
                        if(new_y >=300)then
                            DIN_B<="00000000000000000000000000000"; --remove the block
                        else
                            --check which lane and alter accordingly
                            --X = ((Y-YO)*(X1-X0)/(Y1-Y0) + X0  
                            case DOUT_B(1 downto 0) is 
                                when "01" => --Lane 1
                                    new_x1 := ((new_y - 96)*(-1))+144;        --equation r6
                                    if(new_x1 < 0)then
                                        new_x1 := 0;
                                    end if;
                                    new_x2 := ((new_y - 96)*(-3)/8)+208;         --equation r5
                                    DIN_B<=std_logic_vector(to_signed(new_x1,9)) & std_logic_vector(to_signed(new_x2,9)) & std_logic_vector(to_signed(new_y,9)) & DOUT_B(1 downto 0);   
    
                                when "10" => --Lane 2
                                    new_x1 := ((new_y - 96)*(-3)/8)+208;        --equation r5
                                    new_x2 := ((new_y - 96)* 3/8)+272;            --equation r0  
                                    DIN_B<=std_logic_vector(to_signed(new_x1,9)) & std_logic_vector(to_signed(new_x2,9)) & std_logic_vector(to_signed(new_y,9)) & DOUT_B(1 downto 0);
                                    
                                when "11" => --Lane 3                            
                                    new_x1 := ((new_y - 96)* 3/8)+272;        --equation r0
                                    new_x2 := ((new_y - 96)* 1)+336;         --equation r1  
                                    DIN_B<=std_logic_vector(to_signed(new_x1,9)) & std_logic_vector(to_signed(new_x2,9)) & std_logic_vector(to_signed(new_y,9)) & DOUT_B(1 downto 0);
                                     
                                when others =>
                                    DIN_B<=DOUT_B;
                                    --Do nothing
                            end case;
                        end if;
                        --write to the block ram
                        WE_B <= "1";
                        write := '1'; 
                    else
                        write := '0';
                        addrb:= addrb + 1; --increment the address
                        if(addrb = 10)then --if we are finished
                            first_time := '1';
                            done := '1';
                            addrb := 0;
                        end if;
                        read_delay := 2;
                    end if;
                else --data is not valid, wait untill it is
                    read_delay := read_delay - 1;
                end if;    
            end if; --end first_time check 
        end if; --end update region check
    end if; --end reset
    ADDR_B <= std_logic_vector(to_unsigned(addrb,4));
end if; --end clock

end process;

--This process makes move high every time the counter overflows
delay: process(CLK)

variable delay: integer range delay_value downto 0:=0;

begin
if(CLK'event and CLK='1')then
    if(RST='1')then
        delay := 0;
    else
        delay := delay + 1;
        if(delay = delay_value)then
            delay := 0;
            move <= '1'; --make move high for 1 pulse
        else
            move <= '0';
        end if; --end delay 
    end if; --end reset
end if; --end clock
end process;

end Behavioral;
