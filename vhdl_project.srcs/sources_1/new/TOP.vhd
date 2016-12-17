----------------------------------------------------------------------------------
-- Company:
-- Engineer: Carleer Jasper & Jelle De Vleesshouwer
--
-- Create Date: 11/29/2016 03:41:01 PM
-- Design Name:
-- Module Name: TOP - Behavioral
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

library UNISIM;
use UNISIM.vcomponents.all;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;


entity TOP is
    Port ( CLK     :in  STD_LOGIC;
           RST     :in  STD_LOGIC;
           --control signals display
           P_CLK   :out STD_LOGIC;
           H_SYNC  :out STD_LOGIC;
           V_SYNC  :out STD_LOGIC;
           RED     :out STD_LOGIC_VECTOR (7 downto 0);
           GREEN   :out STD_LOGIC_VECTOR (7 downto 0);
           BLUE    :out STD_LOGIC_VECTOR (7 downto 0);
           DISP_EN :out STD_LOGIC;
           BL_EN   :out STD_LOGIC;
           GND     :out STD_LOGIC;
           --SPI
           CS      :out STD_LOGIC;
           DCLK    :out STD_LOGIC;
           MOSI    :out STD_LOGIC;
           MISO    :in STD_LOGIC;
           BUSY    :in STD_LOGIC
           );
end TOP;

architecture Behavioral of TOP is

---------------------------------------
--Declaration of the components
---------------------------------------
--9MHz Phase locked loop
component PLL_9MHz is
    Port ( CLK     :in  STD_LOGIC;
           RST     :in  STD_LOGIC;
           CLK_9MHz:out STD_LOGIC);
end component;
--Display driver
component display_driver is
    Port (
           --this should be a 9MHz clock generated by a PLL
           P_CLK   :in  STD_LOGIC;
           RST     :in  STD_LOGIC;

           --signals for the display
           H_SYNC  :out STD_LOGIC;
           V_SYNC  :out STD_LOGIC;
           DISP_EN :out STD_LOGIC;

           --control signals for the algoritm
           VALID   :out STD_LOGIC;
           X_POS   :out STD_LOGIC_VECTOR (9 downto 0); --only valid if DISP_EN = '1';
           Y_POS   :out STD_LOGIC_VECTOR (9 downto 0)  --only valid if DISP_EN = '1';
           );
end component;
--Touch driver to detect touches
component touch_driver_picoblaze is
    Port (
        CS   : out std_logic;
        DCLK : out std_logic;
        MOSI : out std_logic;
        VALID: out std_logic;
        BUSY : in std_logic;
        MISO : in std_logic;
        CLK  : in std_logic;
        RST  : in std_logic;
        X_POS: out std_logic_vector(11 downto 0);
        Y_POS: out std_logic_vector(11 downto 0)
    );
end component;
--Hardware that generates a control signal to draw a rectangle
component draw_rectangle is
    Port ( X_CURRENT   :in STD_LOGIC_VECTOR (9 downto 0);
           Y_CURRENT   :in STD_LOGIC_VECTOR (9 downto 0);
           VISIBLE_AREA:in STD_LOGIC;
           X_START     :in STD_LOGIC_VECTOR (9 downto 0);
           Y_START     :in STD_LOGIC_VECTOR (9 downto 0);
           X_STOP      :in STD_LOGIC_VECTOR (9 downto 0);
           Y_STOP      :in STD_LOGIC_VECTOR (9 downto 0);
           SHOW        :out STD_LOGIC
           );
end component;
--Hardware that generates a control signal to draw a line
component draw_line is
    Port ( X_CURRENT   :in STD_LOGIC_VECTOR (9 downto 0);
           Y_CURRENT   :in STD_LOGIC_VECTOR (9 downto 0);
           VISIBLE_AREA:in STD_LOGIC;
           X_START     :in STD_LOGIC_VECTOR (9 downto 0);
           Y_START     :in STD_LOGIC_VECTOR (9 downto 0);
           X_STOP      :in STD_LOGIC_VECTOR (9 downto 0);
           Y_STOP      :in STD_LOGIC_VECTOR (9 downto 0);
           SHOW        :out STD_LOGIC
           );
end component;
--code to move an object
component algoritme is
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
end component;
component background is
    Port (
        X_POS   : in STD_LOGIC_VECTOR (9 downto 0);
        Y_POS   : in STD_LOGIC_VECTOR (9 downto 0);
        VISIBLE : in STD_LOGIC;
        SHOW    : out STD_LOGIC
    );
end component;

component player_driver is
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
end component;

---------------------------------------
--signals to internally connect the different components
---------------------------------------
signal P_CLK_9MHz : std_logic;
signal X_POS      : STD_LOGIC_VECTOR (9 downto 0);
signal Y_POS      : STD_LOGIC_VECTOR (9 downto 0);
signal VALID      : std_logic;
signal SHOW       : std_logic;
signal X_START    : std_logic_vector(9 downto 0);
signal Y_START    : std_logic_vector(9 downto 0);
signal X_STOP     : std_logic_vector(9 downto 0);
signal Y_STOP     : std_logic_vector(9 downto 0);

signal TOUCH_VALID: std_logic;
signal TOUCH_X    : std_logic_vector(11 downto 0);
signal TOUCH_Y    : std_logic_vector(11 downto 0);
signal NEW_X      : std_logic_vector(9 downto 0);
signal NEW_Y      : std_logic_vector(9 downto 0);

signal SHOW_BG    : std_logic;

signal V_SYNC_INT : std_logic;

signal PLAYER_X : STD_LOGIC_VECTOR (9 downto 0);
signal PLAYER_R : STD_LOGIC_VECTOR (7 downto 0);
signal PLAYER_G : STD_LOGIC_VECTOR (7 downto 0);
signal PLAYER_B : STD_LOGIC_VECTOR (7 downto 0);
signal PLAYER_V : STD_LOGIC;

begin

V_SYNC <= V_SYNC_INT;

---------------------------------------
--port mapping of the components
---------------------------------------
pll:        PLL_9MHz       port map (CLK=>CLK,RST=>RST,CLK_9MHz=>P_CLK_9MHz);
disp_drive: display_driver port map (P_CLK=>P_CLK_9MHz,RST=>RST,H_SYNC=>H_SYNC,V_SYNC=>V_SYNC_INT,DISP_EN=>DISP_EN,VALID=>VALID,X_POS=>X_POS,Y_POS=>Y_POS);
spi_driver: touch_driver_picoblaze port map (CS=>CS, DCLK=>DCLK, MOSI=>MOSI, VALID=>TOUCH_VALID,BUSY=>BUSY, MISO=>MISO,CLK=>CLK,RST=>RST,X_POS=>TOUCH_X,Y_POS=>TOUCH_Y);
rectangle1: draw_rectangle port map (X_CURRENT=>X_POS,Y_CURRENT=>Y_POS,VISIBLE_AREA=>VALID,X_START=>X_START,Y_START=>Y_START,X_STOP=>X_STOP,Y_STOP=>Y_STOP,SHOW=>SHOW);
--line1:      draw_line           port map (X_CURRENT=>X_POS,Y_CURRENT=>Y_POS,VISIBLE_AREA=>VALID,X_START=>"0000110010",Y_START=>"0000110010",X_STOP=>"0001100000",Y_STOP=>"0001100000",SHOW=>SHOW);
--buffer for the clock made by the pll
b0:         BUFG           port map (O => P_CLK, I => P_CLK_9MHz);
background1: background port map (X_POS=>X_POS, Y_POS=>Y_POS, VISIBLE=>VALID, SHOW=>SHOW_BG);
--algo1:      algoritme port map(CLK=>CLK,RST=>RST,DISP_EN=>VALID,X_START_IN=>"0000000000",Y_START_IN=>"0000000000",X_STOP_IN=>"0000001010",Y_STOP_IN=>"0000001010",X_START_OUT=>X_START,Y_START_OUT=>Y_START,X_STOP_OUT=>X_STOP,Y_STOP_OUT=>Y_STOP);
pd: player_driver port map (CLK=>CLK,RST=>RST,V_SYNC=>V_SYNC_INT,VALID=>VALID,
                            X_TOUCH=>NEW_X,Y_TOUCH=>NEW_Y,X_POS=>X_POS,
                            Y_POS=>Y_POS,PLAYER_X=>PLAYER_X,
                            PLAYER_R=>PLAYER_R,PLAYER_G=>PLAYER_G,PLAYER_B=>PLAYER_B,
                            PLAYER_V=>PLAYER_V);
--------------------------------------
--control signals display
--------------------------------------
GND<='0';
BL_EN<='1'; -- back light enable!

update_touch: process(CLK)
    variable x_val : integer range 4095 downto 0;
    variable y_val : integer range 4095 downto 0;
begin
    if (CLK'event and CLK='1') then
        if (TOUCH_VALID = '1') then
            x_val := to_integer(shift_right(unsigned(TOUCH_X), 3));
            y_val := to_integer(shift_right(unsigned(TOUCH_Y), 4));
            NEW_X <= std_logic_vector(to_unsigned(x_val, 10));
            NEW_Y <= std_logic_vector(to_unsigned(y_val, 10));
        end if;
    end if;
end process;

update_rect: process(CLK)
begin
    if (CLK'event and CLK='1') then
        if (V_SYNC_INT = '0') then
            X_START <= std_logic_vector(unsigned(NEW_X));
            Y_START <= std_logic_vector(unsigned(NEW_Y));
            X_STOP <= std_logic_vector(unsigned(NEW_X) + 20);
            Y_STOP <= std_logic_vector(unsigned(NEW_Y) + 20);
        end if;
    end if;
end process;

show_figure: process(CLK)

begin
if(CLK'event and CLK='1') then
    if (PLAYER_V = '1') then
        RED <= PLAYER_R;
        GREEN <= PLAYER_G;
        BLUE<= PLAYER_B;
    elsif (SHOW_BG = '1') then
        RED <= X"EB";
        GREEN <= X"42";
        BLUE <= X"D9";
    else
        RED <=X"17";
        GREEN <=X"10";
        BLUE<=X"5D";
    end if; --end show
end if; -- end clock

end process;

end Behavioral;
