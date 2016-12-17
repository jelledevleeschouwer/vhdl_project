library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity player_driver is
    Generic (
        area_width   : signed(9 downto 0) := to_signed(192, 10);
        area_height  : signed(9 downto 0) := to_signed(64, 10);
        screen_width : signed(9 downto 0) := to_signed(480, 10);
        screen_height: signed(9 downto 0) := to_signed(272, 10);
        period_pre   : unsigned(19 downto 0) := to_unsigned(1250000, 20)
    );
    Port (
        CLK      : in STD_LOGIC;
        RST      : in STD_LOGIC;
        V_SYNC   : in STD_LOGIC;
        VALID    : in STD_LOGIC;
        X_TOUCH  : in STD_LOGIC_VECTOR (9 downto 0);
        Y_TOUCH  : in STD_LOGIC_VECTOR (9 downto 0);
        X_POS    : in STD_LOGIC_VECTOR (9 downto 0);
        Y_POS    : in STD_LOGIC_VECTOR (9 downto 0);
        PLAYER_X : out STD_LOGIC_VECTOR (9 downto 0);
        PLAYER_R : out STD_LOGIC_VECTOR (7 downto 0);
        PLAYER_G : out STD_LOGIC_VECTOR (7 downto 0);
        PLAYER_B : out STD_LOGIC_VECTOR (7 downto 0);
        PLAYER_V : out STD_LOGIC
    );
end player_driver;

architecture Behavioral of player_driver is

    -- Prescaler enable signal
    signal EN_100 : STD_LOGIC;

    -- FSM state type definition
    type fsm_state_t is (
        IDLE, LANE_L, LANE_C, LANE_R
    );

    -- FSM states
    signal state, new_state : fsm_state_t;

    -- Constant values regarding the position of the player
    constant player_width: signed(9 downto 0) := to_signed(32, 10);
    constant player_height : signed(9 downto 0) := to_signed(32, 10);
    constant v_offset : signed(9 downto 0) := to_signed(32, 10);
    constant y: signed(9 downto 0) := screen_height - v_offset - player_height;

    -- Horizontal position of the player centered in a lane
    signal x : signed(9 downto 0);
    signal new_x : signed(9 downto 0);

begin

    -- Prescaler process for touch FSM
    prescaler: process (CLK)
        variable prescale : unsigned(19 downto 0) := to_unsigned(0,20);
    begin
        if (CLK'event and CLK='1') then
            prescale := prescale + 1;
            if (prescale = period_pre) then
                EN_100 <= '1';
                prescale := to_unsigned(0, 20);
            else
                EN_100 <= '0';
            end if;
        end if;
    end process;

    -- Update player position
    update_player: process(CLK)

        -- Horizontal center
        constant mid : signed(9 downto 0) := screen_width srl 1;

        -- Horizontal boundaries
        constant half : signed(9 downto 0) := area_width srl 1;
        constant xl : signed(9 downto 0) := mid - half;
        constant xll : signed(9 downto 0) := xl - area_width;
        constant xr : signed(9 downto 0) := mid + half;
        constant xrr : signed(9 downto 0) := xr + area_width;

        -- Vertical boundaries
        constant top : signed(9 downto 0) := screen_height - area_height;
        constant bottom : signed(9 downto 0) := screen_height;

        variable xt : signed(9 downto 0);
        variable yt : signed(9 downto 0);
    begin
        if (CLK'event and CLK='1') then
            xt := signed(X_TOUCH);
            yt := signed(Y_TOUCH);

            if (EN_100 = '1') then
                if (yt >= top and yt < bottom) then
                    if (xt >= xll and xt < xl) then
                        PLAYER_X <= std_logic_vector(xll + half);
                        new_x <= xll + half - (player_width srl 1);
                    elsif (xt >= xl and xt <= xr) then
                        PLAYER_X <= std_logic_vector(xl + half);
                        new_x <= xl + half - (player_width srl 1);
                    elsif (xt > xr and xt <= xrr) then
                        PLAYER_X <= std_logic_vector(xr + half);
                        new_x <= xr + half - (player_width srl 1);
                    end if;
                end if;
            end if;

            if (V_SYNC = '0') then
                x <= new_x;
            end if;
        end if;
    end process; -- EOF update_player

    -- Draw player on screen
    draw_player: process(CLK)
        variable xt : signed(9 downto 0);
        variable yt : signed(9 downto 0);
    begin
        if (CLK'event and CLK = '1') then
            xt := signed(X_POS);
            yt := signed(Y_POS);

            if (xt >= x and xt < x + player_width and yt >= y and yt < y + player_height) then
                -- Put colors on display
                PLAYER_R <= X"1A";
                PLAYER_G <= X"E4";
                PLAYER_B <= X"FF";
                PLAYER_V <= '1';
                -- TODO: Use blockRAM to draw a figure
            else
                PLAYER_V <= '0';
            end if;
        end if;
    end process;

end Behavioral;
