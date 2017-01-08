library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all; --to be able to use +,-,... and use signed types

entity draw_blocks is
    Port ( CLK      : in  STD_LOGIC;
           RST      : in  STD_LOGIC;

           XPOS     : in  STD_LOGIC_VECTOR(8  downto 0);
           YPOS     : in  STD_LOGIC_VECTOR(8  downto 0);
           DISP_EN  : in  STD_LOGIC;

           POS_FIRST: in  STD_LOGIC_VECTOR(3 downto 0);

           DOUT_B   : in  STD_LOGIC_VECTOR(28 downto 0);
           ADDR_B   : out STD_LOGIC_VECTOR(3  downto 0);

           LANE     : in STD_LOGIC_VECTOR(1 downto 0);
           LOST     : out STD_LOGIC;

           SHOW     : out STD_LOGIC
           );
end draw_blocks;

architecture Behavioral of draw_blocks is

    -- Constants
    constant lose_position: integer :=224;
    -- Signals
    signal update   : std_logic;

begin

-- If we are past the last pixel of the block ask for an address update
determine_update: process(CLK)

    -- Variables
    variable first_time : std_logic:='1';
    variable new_x_limit: integer;
    variable new_y_limit: integer;

begin
    if (CLK'event and CLK='1') then

        update <= '0';

        if (RST='1') then
            update <= '0';
            first_time := '1';
        else

            -- Clip the values to avoid out of screen values
            -- X
            if (unsigned(DOUT_B(19 downto 11)) > 479) then
                new_x_limit := 479;
            else
                new_x_limit := to_integer(unsigned(DOUT_B(19 downto 11)));
            end if;
            -- Y
            if (unsigned(DOUT_B(10 downto 2)) > 271) then
                new_y_limit := 271;
            else
                new_y_limit := to_integer(unsigned(DOUT_B(10 downto 2)));
            end if;

            -- If we are on the last pixel of the block
            if ((unsigned(XPOS) = new_x_limit + 1) and
               (unsigned(YPOS) = new_y_limit + 1)) then
                if( first_time = '1' )then
                    update <= '1';
                    first_time := '0';
                end if;

            else
                first_time := '1';
            end if; -- End position check
        end if; -- End reset
     end if; -- End clock
end process;


-- Check for losing player
lose_process: process(CLK)
begin
    if (CLK'event and CLK='1') then
        if (RST ='1') then
            LOST<='0';
        else
            --if the player is in the same lane als the obstacle when the obstacle crosses the player -> lose
            if (DOUT_B(1 downto 0) = LANE) and
               (signed(DOUT_B(10 downto 2)) >= lose_position) then
                LOST<='1';
            end if; -- End lose check
        end if; -- End reset
    end if; -- End clock
end process;

-- Update the address when asked for
update_address: process(CLK)
variable addrb: integer range 10 downto 0:=0;
begin
    if (CLK'event and CLK = '1') then
        if (RST = '1') then
            addrb := to_integer(unsigned(POS_FIRST)); -- Normally use this one
            -- Debug
            --addrb := 0;
        else
            if (update = '1') then
                addrb := addrb + 1; -- Increment the address
                if (addrb = 10) then -- Wrap around
                    addrb := 0;
                end if;
            end if;

            -- If we come across a block with lane 0, you don't need to draw this block and the following blocks so return to the first one
            if (DOUT_B(1 downto 0) = "00") then
                -- POS_FIRST could have become (POS_FIRST - 1) % 9 after a few iterations
                addrb := to_integer(unsigned(POS_FIRST));
            end if;
        end if;
        ADDR_B <= std_logic_vector(to_unsigned(addrb,4)); --update the address
    end if;

end process;

draw_block: process(CLK)
begin
    if (CLK'event and CLK='1') then
        if (RST = '1') then
            SHOW<='0';
        else
            if (DISP_EN = '1') and
               (XPOS >= DOUT_B(28 downto 20)) and
               (XPOS <= DOUT_B(19 downto 11)) and
               (YPOS >= std_logic_vector(signed(DOUT_B(10 downto 2))-( signed( DOUT_B(19 downto 11) ) - signed( DOUT_B(28 downto 20) ) )/4 )) and
               (YPOS <= DOUT_B(10 downto 2)) and
               (DOUT_B(1 downto 0) /= "00")
               then
               SHOW <= '1';
            else
               SHOW <= '0';
            end if; -- End rectangle area check
        end if; -- End reset
    end if; -- End clock
end process;

end Behavioral;
