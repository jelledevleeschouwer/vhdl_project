library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity player_driver is
    Generic (
        area_width   : unsigned(8 downto 0) := to_unsigned(192, 9);
        area_height  : unsigned(8 downto 0) := to_unsigned(128, 9);
        screen_width : unsigned(8 downto 0) := to_unsigned(480, 9);
        screen_height: unsigned(8 downto 0) := to_unsigned(272, 9);
        period_pre   : unsigned(19 downto 0) := to_unsigned(1250000, 20)
    );
    Port (
        CLK      : in STD_LOGIC;                      -- 125 MHz
        PCLK     : in STD_LOGIC;                      -- 9 MHz
        RST      : in STD_LOGIC;

        V_SYNC   : in STD_LOGIC;                      -- Update signal (off-screen)

        VALID    : in STD_LOGIC;                      -- Draw cursor is in visible portion
        X_TOUCH  : in STD_LOGIC_VECTOR (8 downto 0);  -- X-coordinate of latest _valid_ touch
        Y_TOUCH  : in STD_LOGIC_VECTOR (8 downto 0);  -- Y-coordinate of latest _valid_ touch
        X_POS    : in STD_LOGIC_VECTOR (8 downto 0);  -- Current X-position of draw cursor
        Y_POS    : in STD_LOGIC_VECTOR (8 downto 0);  -- Current Y-position of draw cursor

        LANE     : out STD_LOGIC_VECTOR (1 downto 0); -- Lane in wich the user has pressed

        PLAYER_R : out STD_LOGIC_VECTOR (7 downto 0); -- Red component to source color-MUX with
        PLAYER_G : out STD_LOGIC_VECTOR (7 downto 0); -- Green component to source color-MUX with
        PLAYER_B : out STD_LOGIC_VECTOR (7 downto 0); -- Blue component to source color-MUX with
        PLAYER_V : out STD_LOGIC;                     -- Control signal to apply to color-MUX

        SEED     : out STD_LOGIC                      -- Seed signal to reiterate PRNG
    );
end player_driver;

architecture Behavioral of player_driver is

    -- Block ROM declaration
    component blk_mem_player is
        Port (
            clka : IN STD_LOGIC;
            addra : IN STD_LOGIC_VECTOR(13 DOWNTO 0);
            douta : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
        );
    end component;

    -- CONSTANTS
    constant PLAYER_WIDTH: unsigned(8 downto 0) := to_unsigned(96, 9);
    constant PLAYER_HEIGHT : unsigned(8 downto 0) := to_unsigned(96, 9);
    constant Y: unsigned(8 downto 0) := screen_height - PLAYER_HEIGHT;

    -- Prescaler clock enable signal
    signal EN_100 : STD_LOGIC;

    -- Horizontal position of the player centered in a lane
    signal x : unsigned(8 downto 0);
    signal new_x : unsigned(8 downto 0);

    -- Signal regarding the block ROM
    signal addr_int: std_logic_vector(13 downto 0);
    signal data_int: std_logic_vector(11 downto 0);

    -- Signals the visibility of the player
    signal opaque: std_logic;   -- Whether current pixel is not translucent
    signal show: std_logic;     -- Whether player is currently visible
begin

    -- Block ROM instantation
    b0: blk_mem_player port map (clka => CLK, addra => addr_int, douta => data_int);

    -- Prescaler process for touch detection
    prescaler: process (CLK)
        variable prescale : unsigned(19 downto 0) := to_unsigned(0,20);
    begin
        if (CLK'event and CLK='1') then
            EN_100 <= '0';

            if RST = '1' then
                -- Reinitialize upon reset
                prescale := to_unsigned(0, 20);
            else
                -- Increment prescale count as long as prescale < prescale_pre - 1
                if (prescale < period_pre - 1) then
                    prescale := prescale + 1;
                else
                    prescale := to_unsigned(0, 20);
                end if;

                -- Carry on period_pre - 1 so it can be clocked in when it becomes zero
                if (prescale = period_pre - 1) then
                    EN_100 <= '1';
                end if;
            end if;
        end if;
    end process;

    -- Update player position
    update_player: process(CLK)
        -- Horizontal center
        constant mid : unsigned(8 downto 0) := screen_width srl 1;

        -- Horizontal boundaries
        constant half : unsigned(8 downto 0) := area_width srl 1;
        constant xl : unsigned(8 downto 0) := mid - half;
        constant xr : unsigned(8 downto 0) := mid + half;

        -- Vertical boundaries
        constant top : unsigned(8 downto 0) := screen_height - area_height;
        constant bottom : unsigned(8 downto 0) := screen_height;

        -- Internal process coördinate variables
        variable xt : unsigned(8 downto 0);
        variable yt : unsigned(8 downto 0);
    begin
        if (CLK'event and CLK='1') then
            SEED <= '0';

            xt := unsigned(X_TOUCH);
            yt := unsigned(Y_TOUCH);

            if (EN_100 = '1') then
                if (yt >= top and yt < bottom) then
                    SEED <= '1';
                    if (xt < xl) then
                        LANE <= std_logic_vector(to_unsigned(1, 2));
                        new_x <= to_unsigned(64, 9);
                    elsif (xt >= xl and xt <= xr) then
                        LANE <= std_logic_vector(to_unsigned(2, 2));
                        new_x <= to_unsigned(192, 9);
                    elsif (xt > xr) then
                        LANE <= std_logic_vector(to_unsigned(3, 2));
                        new_x <= to_unsigned(320, 9);
                    end if;
                end if;
            end if;

            -- Only update when we're off-screen
            if (V_SYNC = '0') then
                x <= new_x;
            end if;
        end if;
    end process; -- EOF update_player

    -- Update colors of player with new color coming from block ROM
    update_color: process(CLK)
    begin
        if (CLK'event and CLK='1') then
        end if;
    end process;

    -- Only 4 MSBs of color channels are stored in block ROM
    PLAYER_R <= data_int(11 downto 8) & "0000";
    PLAYER_G <= data_int(7 downto 4) & "0000";
    PLAYER_B <= data_int(3 downto 0) & "0000";

    -- Color has to be opaque and cursor has to be in player boundaries to pass
    PLAYER_V <= show and opaque;

    -- Draw player on screen
    draw_player: process(CLK)
        variable xt : unsigned(8 downto 0);
        variable yt : unsigned(8 downto 0);
        variable a : unsigned(17 downto 0);
    begin
        if (CLK'event and CLK = '1') then
            xt := unsigned(X_POS);
            yt := unsigned(Y_POS);

            if (xt >= x and xt < x + PLAYER_WIDTH and yt >= Y and yt < Y + PLAYER_HEIGHT) then
                -- Address = (x - x0) + ((y - y0) * width)
                a := (xt - x) + ((yt - Y) * PLAYER_WIDTH);
                addr_int <= std_logic_vector(a(13 downto 0));
                show <= '1'; -- Player is visible
            else
                show <= '0';
            end if;

            if (data_int = x"000") then
                opaque <= '0'; -- Pixel supposed to be transluscent
            else
                opaque <= '1'; -- Pixel is opaque
            end if;
        end if;
    end process;

end Behavioral;
