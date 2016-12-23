----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Carleer Jasper & Jelle De Vleesshouwer
-- 
-- Create Date: 
-- Design Name: 
-- Module Name: block_adjuster - Behavioral
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
use IEEE.NUMERIC_STD.all; --to be able to use +,-,... and use signed types

entity block_adjuster is
  Port ( 
           CLK : in STD_LOGIC;
           RST : in STD_LOGIC;
           
           POS_FIRST : in std_logic_vector(3 downto 0); --position of the first block
           
           --information about current position
           XPOS : in std_logic_vector(8 downto 0); --current x position
           YPOS : in std_logic_vector(8 downto 0); --current y position
           DISP_EN : in std_logic; --in valid region

           DOUT_B : in std_logic_vector(28 downto 0); --data from the ram block port B
           DIN_B  : out std_logic_vector(28 downto 0); --data to the ram block port B
           ADDR_B : out std_logic_vector(3 downto 0);
           WE_B   : out std_logic_vector(0 downto 0);
           SHOW : out std_logic;
           V_SYNC : in std_logic
  
           );
end block_adjuster;

architecture Behavioral of block_adjuster is
--constants
constant move_delay: integer :=149999999; --149999999
constant lower     : integer :=5;
--signals

--signals for address update
--addr_b is driven by two process so we need some kind of arbiter
signal update   : std_logic; 
signal move     : std_logic;
signal ADDR_B_1 :std_logic_vector(3 downto 0);
signal ADDR_B_2 :std_logic_vector(3 downto 0);
signal w_en_delay : std_logic;

begin


--if we are past the last pixel of the block ask for an address update
determine_update: process(CLK)
variable not_first_time : std_logic:='0';
variable new_x_limit: integer;
variable new_y_limit: integer;
begin
    if(CLK'event and CLK='1')then
        update <= '0';
        if(RST='1')then
            update <= '0';
        else
            if(V_SYNC = '1')then --als we aan het displayen zijn
                --clip the values to avoid out of screen values
                --X
                if(unsigned(DOUT_B(19 downto 11)) > 479)then
                    new_x_limit := 479;
                else
                    new_x_limit := to_integer(unsigned(DOUT_B(19 downto 11)));
                end if;
                --Y
                if(unsigned(DOUT_B(10 downto 2)) > 271)then
                    new_y_limit := 271;
                else
                    new_y_limit := to_integer(unsigned(DOUT_B(10 downto 2)));
                end if;
                
                --if we are on the last pixel of the block
                if((unsigned(XPOS) = new_x_limit + 1) and
                   (unsigned(YPOS) = new_y_limit + 1)) or
                   (DOUT_B(1 downto 0) = "00"       ) then 
                    if( not_first_time = '0' )then    
                        update <= '1'; 
                        not_first_time := '1';   
                    end if;
                    
                else
                    not_first_time := '0';    
                end if; --end position check
            end if;
        end if; --end reset
     end if; --end clock
end process;

--update the address when asked for
update_address: process(CLK)
variable addrb : integer range 10 downto 0:=0;
begin

if(CLK'event and CLK='1')then
    if(RST='1')then
    
        --addrb:=to_integer(signed(POS_FIRST)); --normally use this one
        addrb := 0; --debug
        
    else
        if(update = '1')then
        
            addrb := addrb+1; --increment the address
            if(addrb = 10)then --wrap around
            
                addrb := 0;
                
            end if;
        end if;   
    end if;
    ADDR_B_1 <= std_logic_vector(to_unsigned(addrb,4)); --update the address
end if;

end process;

draw_block: process(CLK)
begin
    if(CLK'event and CLK='1')then
        if(RST='1')then
            SHOW<='0';
        else
            if(DISP_EN = '1') and 
              (XPOS >= DOUT_B(28 downto 20)) and 
              (XPOS <= DOUT_B(19 downto 11)) and 
              (YPOS >= std_logic_vector(signed(DOUT_B(10 downto 2))-15)) and 
              (YPOS <= DOUT_B(10 downto 2)) and
              (DOUT_B(1 downto 0) /= "00")
              then
               SHOW<='1';
            else
               SHOW<='0';
            end if; --end rectangle area check
        end if; --end reset
    end if; --end clock
end process;




-------------------------------------------------
-- Processes to move the blocks
-------------------------------------------------
-- 1) wacht totdat we uit het scherm zijn 
-- 2) leg het eerste address aan
-- 3) wacht op de data
-- 4) pas de data aan
-- 5) schrijf de data terug naar de block ram
-- 6) update the address and repeat

move_blocks: process(CLK)

variable move_block : std_logic:='0';
variable addrb : integer range 10 downto 0:=0;
begin
    if(CLK'event and CLK='1')then
        if(RST='1')then
            move_block := '0';
            addrb := 0;
            --!!change this with first_pos!!
        else
            --check if there is a update request
            if(move = '1')then
                move_block := '1';
            end if;
            
            --check if we are out of the screen and move_block is 1
            if(V_SYNC = '0' and move_block = '1')then
                --juiste address ligt al aan,              
                --din wordt deze waarde
                --create W_EN_B 1 clock pulse later
                --DIN_B <= DOUT_B(28 downto 11) & std_logic_vector(signed(DOUT_B(10 downto 2)) + lower) & DOUT_B(1 downto 0);
                DIN_B <= DOUT_B(28 downto 11) & std_logic_vector(signed(DOUT_B(10 downto 2)) + lower) & "01";
                --w_en_delay <= '1';
                WE_B <= "1";
                move_block := '0';
            else
                --w_en_delay <= '0';
                WE_B <= "0";
            end if;        
        end if;
        --ADDR_B_2 <= std_logic_vector(to_unsigned(addrb,4)); --update the address
        ADDR_B_2 <= "0000";
    end if;

end process;



delay: process(CLK)

variable delay: integer range move_delay downto 0:= 0;

begin

if(CLK'event and CLK='1')then
    if(RST='1')then
        delay := 0;
        move <= '0';
    else
        delay := delay + 1; --increment delay
        if(delay = move_delay)then
            delay := 0;
            move <= '1';
        else
            move <= '0';
        end if;
    end if;
end if;

end process;



--------------------------------------------------------
--process to allow multiple drivers for the ADDR_B bus
--------------------------------------------------------

address_mux: process(V_SYNC)

begin
    if(V_SYNC = '0')then
        ADDR_B <= ADDR_B_2;

    else
        ADDR_B <= ADDR_B_1;

    end if;--end mux
end process;

end Behavioral;
