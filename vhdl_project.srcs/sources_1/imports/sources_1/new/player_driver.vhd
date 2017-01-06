library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity player_driver is
    Generic (
        area_width   : signed(9 downto 0) := to_signed(192, 10);
        area_height  : signed(9 downto 0) := to_signed(128, 10);
        screen_width : signed(9 downto 0) := to_signed(480, 10);
        screen_height: signed(9 downto 0) := to_signed(272, 10);
        period_pre   : unsigned(19 downto 0) := to_unsigned(1250000, 20)
    );
    Port (
        CLK      : in STD_LOGIC;
        PCLK     : in STD_LOGIC;
        RST      : in STD_LOGIC;
        V_SYNC   : in STD_LOGIC;
        VALID    : in STD_LOGIC;
        X_TOUCH  : in STD_LOGIC_VECTOR (9 downto 0);
        Y_TOUCH  : in STD_LOGIC_VECTOR (9 downto 0);
        X_POS    : in STD_LOGIC_VECTOR (9 downto 0);
        Y_POS    : in STD_LOGIC_VECTOR (9 downto 0);
        LANE     : out STD_LOGIC_VECTOR (1 downto 0);
        PLAYER_X : out STD_LOGIC_VECTOR (9 downto 0);
        PLAYER_R : out STD_LOGIC_VECTOR (7 downto 0);
        PLAYER_G : out STD_LOGIC_VECTOR (7 downto 0);
        PLAYER_B : out STD_LOGIC_VECTOR (7 downto 0);
        PLAYER_V : out STD_LOGIC;
        SEED     : out STD_LOGIC
    );
end player_driver;

architecture Behavioral of player_driver is

    -- Prescaler enable signal
    signal EN_100 : STD_LOGIC;

    -- Constant values regarding the position of the player
    constant player_width: signed(9 downto 0) := to_signed(96, 10);
    constant player_height : signed(9 downto 0) := to_signed(96, 10);
    constant y: signed(9 downto 0) := screen_height - player_height;

    -- Horizontal position of the player centered in a lane
    signal x : signed(9 downto 0);
    signal new_x : signed(9 downto 0);
    
    COMPONENT blk_mem_player IS
      PORT (
        clka : IN STD_LOGIC;
        addra : IN STD_LOGIC_VECTOR(13 DOWNTO 0);
        douta : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
      );
    END COMPONENT;
    
    signal addr_int: std_logic_vector(13 downto 0);
    signal data_int: std_logic_vector(11 downto 0);
begin

b0: blk_mem_player port map (clka => CLK, addra => addr_int, douta => data_int);

    -- Prescaler process for touch FSM
    prescaler: process (CLK)
        variable prescale : unsigned(19 downto 0) := to_unsigned(0,20);
    begin
        if (CLK'event and CLK='1') then
            if RST = '1' then 
                prescale := to_unsigned(0, 20);
            else 
                prescale := prescale + 1;
                if (prescale = period_pre) then
                    EN_100 <= '1';
                    prescale := to_unsigned(0, 20);
                else
                    EN_100 <= '0';
                end if;
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
        constant xr : signed(9 downto 0) := mid + half;

        -- Vertical boundaries
        constant top : signed(9 downto 0) := screen_height - area_height;
        constant bottom : signed(9 downto 0) := screen_height;

        variable xt : signed(9 downto 0);
        variable yt : signed(9 downto 0);
    begin
        if (CLK'event and CLK='1') then
            SEED <= '0';

            xt := signed(X_TOUCH);
            yt := signed(Y_TOUCH);

            if (EN_100 = '1') then
                if (yt >= top and yt < bottom) then
                    SEED <= '1';
                    if (xt < xl) then
                        LANE <= std_logic_vector(to_signed(1, 2));
                        PLAYER_X <= std_logic_vector(to_signed(0, 10) + half);
                        new_x <= to_signed(0, 10) + half - (player_width srl 1) + 20;
                    elsif (xt >= xl and xt <= xr) then
                        LANE <= std_logic_vector(to_signed(2, 2));
                        PLAYER_X <= std_logic_vector(xl + half);
                        new_x <= xl + half - (player_width srl 1);
                    elsif (xt > xr) then
                        LANE <= std_logic_vector(to_signed(3, 2));
                        PLAYER_X <= std_logic_vector(to_signed(479, 0) - half);
                        new_x <= to_signed(479, 10) - half - (player_width srl 1) - 20;
                    end if;
                end if;
            end if;

            if (V_SYNC = '0') then
                x <= new_x;
            end if;
        end if;
    end process; -- EOF update_player
    
    -- Update colors of player with new color coming from block ROM
    update_color: process(data_int)
    begin
        if (data_int = x"000") then
            PLAYER_V <= '0';
        else
            PLAYER_V <= '1';
            PLAYER_R <= data_int(11 downto 8) & "0000";
            PLAYER_G <= data_int(7 downto 4) & "0000";
            PLAYER_B <= data_int(3 downto 0) & "0000";
        end if;
    end process;

    -- Draw player on screen
    draw_player: process(PCLK)
        variable xt : signed(9 downto 0);
        variable yt : signed(9 downto 0);
        
        variable addr_nxt : unsigned(13 downto 0) := to_unsigned(0, 14);
    begin
        if (PCLK'event and PCLK = '1') then
            xt := signed(X_POS);
            yt := signed(Y_POS);
            
            if (xt >= x and xt < x + player_width and yt >= y and yt < y + player_height) then
                addr_nxt := addr_nxt + 1;
                if (addr_nxt = to_unsigned(9216, 14)) then 
                    addr_nxt := to_unsigned(0, 14);
                end if;
                
                addr_int <= std_logic_vector(addr_nxt);
            end if;
        end if;
    end process;

end Behavioral;
