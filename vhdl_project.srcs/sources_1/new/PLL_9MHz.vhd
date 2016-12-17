----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/28/2016 08:16:55 PM
-- Design Name: 
-- Module Name: PLL_9MHz - Behavioral
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

entity PLL_9MHz is
    Port ( CLK : in STD_LOGIC;
           RST : in STD_LOGIC;
           CLK_9MHz: out STD_LOGIC);
end PLL_9MHz;

architecture Behavioral of PLL_9MHz is

    signal CLK_9MHz_NO_BUF: std_logic;
    --signal CLK_9MHz: std_logic;
    signal CLK_FEEDBACK: std_logic;

begin
   -----------------------------------------------
   --Code for the PLL--
   --This pll is used to make the 9MHz pixel clock
   -- F_in--|Divide|------| PLL |-------|Divide(portwise)|--F_out
   --                |              |
   --                |_|Multiply|___|
   --Divide : 25
   --Multiply: 9
   --Divide(portwise): 5
   -----------------------------------------------
   PLLE2_BASE_inst : PLLE2_BASE
   generic map (
      BANDWIDTH => "OPTIMIZED",  -- OPTIMIZED, HIGH, LOW   
      --Multiply
      CLKFBOUT_MULT => 36,       -- Multiply value for all CLKOUT, (2-64)   
      CLKFBOUT_PHASE => 0.0,     -- Phase offset in degrees of CLKFB, (-360.000-360.000).
      CLKIN1_PERIOD => 8.0,      -- Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
      --Divide(portwise) (1-128)  
      CLKOUT0_DIVIDE => 100,
      CLKOUT1_DIVIDE => 1,
      CLKOUT2_DIVIDE => 1,
      CLKOUT3_DIVIDE => 1,
      CLKOUT4_DIVIDE => 1,
      CLKOUT5_DIVIDE => 1,
      -- CLKOUT0_DUTY_CYCLE - CLKOUT5_DUTY_CYCLE: Duty cycle for each CLKOUT (0.001-0.999).
      CLKOUT0_DUTY_CYCLE => 0.5,
      CLKOUT1_DUTY_CYCLE => 0.5,
      CLKOUT2_DUTY_CYCLE => 0.5,
      CLKOUT3_DUTY_CYCLE => 0.5,
      CLKOUT4_DUTY_CYCLE => 0.5,
      CLKOUT5_DUTY_CYCLE => 0.5,
      -- CLKOUT0_PHASE - CLKOUT5_PHASE: Phase offset for each CLKOUT (-360.000-360.000).
      CLKOUT0_PHASE => 0.0,
      CLKOUT1_PHASE => 0.0,
      CLKOUT2_PHASE => 0.0,
      CLKOUT3_PHASE => 0.0,
      CLKOUT4_PHASE => 0.0,
      CLKOUT5_PHASE => 0.0,
      --Divide  
      DIVCLK_DIVIDE => 5,        -- Master division value, (1-56)    
      REF_JITTER1 => 0.0,        -- Reference input jitter in UI, (0.000-0.999).
      STARTUP_WAIT => "FALSE"    -- Delay DONE until PLL Locks, ("TRUE"/"FALSE")
   )
      
   --Port map for the PLL
   port map (
      CLKIN1 => CLK,     -- 1-bit input: Input clock
      RST => RST,           -- 1-bit input: Reset
      CLKOUT0 => CLK_9MHz_NO_BUF,   -- 1-bit output: CLKOUT0
      CLKFBIN => CLK_FEEDBACK,    -- 1-bit input: Feedback clock
      CLKFBOUT => CLK_FEEDBACK, -- 1-bit output: Feedback clock
      PWRDWN => '0'     -- 1-bit input: Power-down
   );
   
CLK_9MHz<=CLK_9MHz_NO_BUF;
--b0: BUFG port map (O => CLK_9MHz, I => CLK_9MHz_NO_BUF);

end Behavioral;