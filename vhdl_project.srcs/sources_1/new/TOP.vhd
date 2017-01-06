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
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_arith.ALL;
use IEEE.NUMERIC_STD.all;

library UNISIM;
use UNISIM.vcomponents.all;


--TOP module
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
           -- SPI
           CS      :out STD_LOGIC;
           DCLK      :out STD_LOGIC;
           MOSI      :out STD_LOGIC;
           MISO      :in STD_LOGIC;
           BUSY      :in STD_LOGIC
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
           X_POS   :out STD_LOGIC_VECTOR (8 downto 0); --only valid if DISP_EN = '1';
           Y_POS   :out STD_LOGIC_VECTOR (8 downto 0)  --only valid if DISP_EN = '1';
           );
end component;

-- SPI Driver
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
        X_POS: out std_logic_vector(9 downto 0);
        Y_POS: out std_logic_vector(9 downto 0)
    );
end component;

--Dual port ram for block storage
component dual_prt_ram_block_strg IS
  PORT (
      clka : IN STD_LOGIC;
      wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
      addra : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      dina : IN STD_LOGIC_VECTOR(28 DOWNTO 0);
      douta : OUT STD_LOGIC_VECTOR(28 DOWNTO 0);
      clkb : IN STD_LOGIC;
      web : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
      addrb : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      dinb : IN STD_LOGIC_VECTOR(28 DOWNTO 0);
      doutb : OUT STD_LOGIC_VECTOR(28 DOWNTO 0)
  );
END component;

-- Component that fetches all the blocks from the block ram and draws them : uses port B of the dual port ram
component draw_blocks is
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
end component;

-- Component that moves all the blocks in the block ram : uses port B of the dual port ram
component move_blocks is
    Port ( CLK      : in  STD_LOGIC;
           RST      : in  STD_LOGIC;
           V_SYNC   : in  STD_LOGIC;
           DOUT_B   : in  STD_LOGIC_VECTOR(28 downto 0);
           DIN_B    : out STD_LOGIC_VECTOR(28 downto 0);
           WE_B     : out STD_LOGIC_VECTOR(0 downto 0);
           ADDR_B   : out STD_LOGIC_VECTOR(3 downto 0)
           );
end component;

-- Block generator : uses port A of the dual port ram
component block_generator is
    Port ( CLK        : in STD_LOGIC;
           RST        : in STD_LOGIC;
           RAND_NUM   : in std_logic_vector(7 downto 0);
           WRITE_EN_A : out std_logic_vector(0 downto 0); --write enable for port A of the block ram
           ADDR_A     : out std_logic_vector(3 downto 0); --address to write the data
           DIN_A      : out std_logic_vector(28 downto 0); --data to write to the block ram
           POS_FIRST_O: out std_logic_vector(3 downto 0) --used to create a circular buffer
           );
end component;

-- Component to draw the background
component background is
    Port ( CLK      : in STD_LOGIC;
           X_POS    : in STD_LOGIC_VECTOR(9 downto 0);
           Y_POS    : in STD_LOGIC_VECTOR(9 downto 0);
           VISIBLE  : in STD_LOGIC;
           SHOW     : out STD_LOGIC);
end component;

-- Component for position of player
component player_driver is
    Generic (
        area_width   : signed(9 downto 0) := to_signed(192, 10);
        area_height  : signed(9 downto 0) := to_signed(88, 10);
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
end component;

-- Component for RNG
component rand_driver is
    Port (
        SEED : in STD_LOGIC;
        RAND : out STD_LOGIC_VECTOR (7 downto 0);
        CLK : in STD_LOGIC;
        RST : in STD_LOGIC
    );
end component;


---------------------------------------
--constants
---------------------------------------
constant color_delay : integer := 14999999;

---------------------------------------
--signals to internally connect the different components
---------------------------------------
--for the display driver
signal P_CLK_9MHz : std_logic;
signal X_POS      : STD_LOGIC_VECTOR (8 downto 0);
signal Y_POS      : STD_LOGIC_VECTOR (8 downto 0);
signal VALID      : std_logic;
signal V_SYNC_SIG : std_logic;

--blocks
signal SHOW_BLOCK       : std_logic;
signal red_sig   : std_logic_vector(7 downto 0);
signal green_sig : std_logic_vector(7 downto 0);
signal blue_sig  : std_logic_vector(7 downto 0);

--background
signal SHOW_BG          : std_logic;
signal XPOS_BG          : std_logic_vector(9 downto 0);
signal YPOS_BG          : std_logic_vector(9 downto 0);

--control signal dual port ram
--port A
signal write_en_a_sig : std_logic_vector(0 downto 0);
signal addra_sig      : std_logic_vector(3 downto 0);
signal dina_sig       : std_logic_vector(28 downto 0);
signal douta_sig      : std_logic_vector(28 downto 0);
--port B
signal write_en_b_sig : std_logic_vector(0 downto 0);
signal addrb_sig      : std_logic_vector(3 downto 0);
signal dinb_sig       : std_logic_vector(28 downto 0);
signal doutb_sig      : std_logic_vector(28 downto 0);
--
signal ADDR_B_1       : std_logic_vector(3 downto 0);
signal ADDR_B_2       : std_logic_vector(3 downto 0);
signal first_block    : std_logic_vector(3 downto 0);
--
signal LOST           : std_logic;

signal TOUCH_VALID    : std_logic;
signal TOUCH_X        : std_logic_vector(9 downto 0);
signal TOUCH_Y        : std_logic_vector(9 downto 0);
signal NEW_X          : std_logic_vector(9 downto 0);
signal NEW_Y          : std_logic_vector(9 downto 0);

signal PLAYER_LANE : STD_LOGIC_VECTOR (1 downto 0);
signal PLAYER_X : STD_LOGIC_VECTOR (9 downto 0);
signal PLAYER_R : STD_LOGIC_VECTOR (7 downto 0);
signal PLAYER_G : STD_LOGIC_VECTOR (7 downto 0);
signal PLAYER_B : STD_LOGIC_VECTOR (7 downto 0);
signal PLAYER_V : STD_LOGIC;

signal SEED     : STD_LOGIC;
signal RAND_NUM : STD_LOGIC_VECTOR(7 downto 0);

signal CS_I     : STD_LOGIC;
signal DCLK_I   : STD_LOGIC;
signal MOSI_I   : STD_LOGIC;
signal BUSY_I   : STD_LOGIC;
signal MISO_I   : STD_LOGIC;

signal PRIOR    : STD_LOGIC;
signal RECT_X   : std_logic_vector(9 downto 0);
signal RECT_Y   : std_logic_vector(9 downto 0);

signal DRAW     : STD_LOGIC;

begin

---------------------------------------
--port mapping of the components
---------------------------------------
b0:             BUFG                    port map (O => P_CLK, I => P_CLK_9MHz);
pll:            PLL_9MHz                port map (CLK=>CLK,RST=>RST,CLK_9MHz=>P_CLK_9MHz);
disp_drive:     display_driver          port map (P_CLK=>P_CLK_9MHz,RST=>RST,H_SYNC=>H_SYNC,V_SYNC=>V_SYNC_SIG,DISP_EN=>DISP_EN,VALID=>VALID,X_POS=>X_POS,Y_POS=>Y_POS);
block_mover:    move_blocks             port map (CLK=>CLK,RST=>RST,V_SYNC=>V_SYNC_SIG,DOUT_B=>doutb_sig,DIN_B=>dinb_sig,WE_B=>write_en_b_sig,ADDR_B=>ADDR_B_2);
block_disp:     draw_blocks             port map (CLK=>CLK,RST=>RST,XPOS=>X_POS,YPOS=>Y_POS,DISP_EN=>VALID,DOUT_B=>doutb_sig,ADDR_B=>ADDR_B_1,SHOW=>DRAW,POS_FIRST=>first_block,LOST=>LOST,LANE=>PLAYER_LANE);
block_ram:      dual_prt_ram_block_strg port map (clka=>CLK,wea=>write_en_a_sig,addra=>addra_sig,dina=>dina_sig,douta=>douta_sig,clkb=>CLK,web=>write_en_b_sig,addrb=>addrb_sig,dinb=>dinb_sig,doutb=>doutb_sig);
block_gen:      block_generator         port map (CLK=>CLK,RST=>RST,RAND_NUM=>RAND_NUM,WRITE_EN_A=>write_en_a_sig,ADDR_A=>addra_sig,DIN_A=>dina_sig,POS_FIRST_O=>first_block);
bg1:            background              port map (CLK=>CLK,X_POS=>XPOS_BG,Y_POS=>YPOS_BG,VISIBLE=>VALID,SHOW=>SHOW_BG);
spi_driver:     touch_driver_picoblaze  port map (CS=>CS_I, DCLK=>DCLK_I, MOSI=>MOSI_I, VALID=>TOUCH_VALID,BUSY=>BUSY_I, MISO=>MISO_I,CLK=>CLK,RST=>RST, X_POS=>TOUCH_X,Y_POS=>TOUCH_Y);
pd:             player_driver           port map (CLK=>CLK,PCLK=>P_CLK_9MHz,RST=>RST,V_SYNC=>V_SYNC_SIG,VALID=>VALID, X_TOUCH=>NEW_X,Y_TOUCH=>NEW_Y,X_POS=>XPOS_BG, Y_POS=>YPOS_BG, LANE=>PLAYER_LANE, PLAYER_X=>PLAYER_X, PLAYER_R=>PLAYER_R,PLAYER_G=>PLAYER_G,PLAYER_B=>PLAYER_B, PLAYER_V=>PLAYER_V, SEED=>SEED);
rng:            rand_driver             port map (SEED => SEED, RAND=>RAND_NUM, CLK=>CLK, RST => RST);

--------------------------------------
--control signals display
--------------------------------------
GND<='0';
BL_EN<='1'; -- back light enable!

V_SYNC<=V_SYNC_SIG;
XPOS_BG <= "0" & X_POS;
YPOS_BG <= "0" & Y_POS;

-- DEBUGING SPI
CS <= CS_I;
DCLK <= DCLK_I;
MOSI <= MOSI_I;
BUSY_I <= BUSY;
MISO_I <= MISO;

-- DEBUGGING TOUCH POSITION
SHOW_BLOCK <= PRIOR or DRAW;

-- Update touch coordinates when they're valid
update_touch: process(CLK)
    variable xt : unsigned(9 downto 0) := to_unsigned(0, 10);
    variable yt : unsigned(9 downto 0) := to_unsigned(0, 10);
begin
    if (CLK'event and CLK='1') then
        xt := unsigned(RECT_X);
        yt := unsigned(RECT_Y);
    
        if (TOUCH_VALID = '1') then
            NEW_X <= TOUCH_X;
            NEW_Y <= TOUCH_Y;
        end if;
        
        -- DEBUGGING TOUCH DRIVER
        if (V_SYNC_SIG = '0') then 
            RECT_X <= NEW_X; 
            RECT_Y <= NEW_Y;
        end if;
        
        if unsigned(XPOS_BG) > xt and unsigned(XPOS_BG) <= xt + to_unsigned(32, 10) 
        and unsigned(YPOS_BG) > yt and unsigned(YPOS_BG) <= yt + to_unsigned(32, 10) then
            PRIOR <= '0';
        else 
            PRIOR <= '0';
        end if;
    end if;
end process;

--------------------------------------------------------
--process to allow multiple drivers for the ADDR_B bus
--------------------------------------------------------

address_mux: process(V_SYNC_SIG)
begin
    if(V_SYNC_SIG = '0')then
        addrb_sig <= ADDR_B_2;
    else
        addrb_sig <= ADDR_B_1;
    end if;--end mux
end process;

-------------------------------------------------------
--change color to show the progress
-------------------------------------------------------
change_color: process(CLK)
variable delay: integer range color_delay downto 0;
begin
    if(CLK'event and CLK='1')then
        if(RST ='1')then
            red_sig<=X"FF";
            green_sig<=X"FF";
            blue_sig<=X"FF";
            delay:=0;
        else
           delay := delay + 1; --increment the delay
           if(delay = color_delay)then
                if(red_sig = X"00")then
                    if(green_sig = X"00")then
                        if(blue_sig = X"00")then
                            red_sig<=X"FF";
                            green_sig<=X"FF";
                            blue_sig<=X"FF";
                        else
                            blue_sig <= std_logic_vector(unsigned(blue_sig)-1);
                        end if;
                    else
                        green_sig <= std_logic_vector(unsigned(green_sig)-1);
                    end if;
                else
                    red_sig <= std_logic_vector(unsigned(red_sig)-1);
                end if;

                delay := 0;
           end if;
        end if; --end reset
    end if; --end clock
end process;


show_figure: process(CLK)
variable lost_int : std_logic:='0';
begin
if(CLK'event and CLK='1') then
    if(RST='1')then
        lost_int := '0';
    else
        if(LOST ='1' or lost_int = '1')then
            lost_int := '1';
            RED<=X"FF";
            BLUE<=X"00";
            GREEN<=X"00";
        else
            if (PLAYER_V = '1') then
                RED <= PLAYER_R;
                GREEN <= PLAYER_G;
                BLUE <= PLAYER_B;
            else
                if (SHOW_BLOCK = '1') then
                    RED<=red_sig;
                    GREEN<=green_sig;
                    BLUE<=blue_sig;
                else
                    if (SHOW_BG = '1') then
                        RED <=X"00";
                        GREEN <=X"FF";
                        BLUE<=X"00";
                    else
                        RED <=X"00";
                        GREEN <=X"00";
                        BLUE<=X"00";
                    end if;
                end if; --end show
            end if; --end player
            
            --DEBUG SPI ON PMOD C
            --RED <= CS_I & DCLK_I & MOSI_I & BUSY_I & MISO_I & "000";
        end if;  --end lost
    end if; --end reset
end if; -- end clock
end process;

end Behavioral;
