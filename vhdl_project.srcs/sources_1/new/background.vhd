library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity background is
    Port (
        X_POS   : in STD_LOGIC_VECTOR (9 downto 0);
        Y_POS   : in STD_LOGIC_VECTOR (9 downto 0);
        VISIBLE : in STD_LOGIC;
        SHOW    : out STD_LOGIC
    );
end background;

architecture Behavioral of background is
begin
background_proc: process(X_POS, Y_POS, VISIBLE)
    constant d: signed(9 downto 0) := to_signed(2, 10) srl 1;

    constant width : signed(9 downto 0) := to_signed(480, 10);
    constant lane_f : signed(9 downto 0) := to_signed(192, 10);
    constant lane_b : signed(9 downto 0) := to_signed(64, 10);
    constant width_b : signed(9 downto 0) := lane_b srl 1;
    constant width_f : signed(9 downto 0) := lane_f srl 1;

    constant y0 : signed(9 downto 0) := to_signed(96, 10);
    constant y1 : signed(9 downto 0) := to_signed(272, 10);
    constant dy : signed(9 downto 0) := y1 - y0;
    constant de : signed(19 downto 0) := d * dy;

    constant y2 : signed(9 downto 0) := y0 + 6;
    constant y3 : signed(9 downto 0) := y2 + 4;
    constant y4 : signed(9 downto 0) := y3 + 8;
    constant y5 : signed(9 downto 0) := y4 + 16;
    constant y6 : signed(9 downto 0) := y5 + 36;
    constant y7 : signed(9 downto 0) := y6 + 64;
    constant y8 : signed(9 downto 0) := y7 + 72;

    constant x0_b : signed(9 downto 0) := (width srl 1) + width_b;
    constant x1_b : signed(9 downto 0) := x0_b + lane_b;
    constant x2_b : signed(9 downto 0) := x1_b + lane_b;
    constant x3_b : signed(9 downto 0) := x2_b + lane_b;
    constant x4_b : signed(9 downto 0) := (width srl 1) + width_b;
    constant x5_b : signed(9 downto 0) := x4_b - lane_b;
    constant x6_b : signed(9 downto 0) := x5_b - lane_b;
    constant x7_b : signed(9 downto 0) := x6_b - lane_b;
    constant x0_f : signed(9 downto 0) := (width srl 1) + width_f;
    constant x1_f : signed(9 downto 0) := x0_f + lane_f;
    constant x2_f : signed(9 downto 0) := x1_f + lane_f;
    constant x3_f : signed(9 downto 0) := x2_f + lane_f;
    constant x4_f : signed(9 downto 0) := (width srl 1) + width_f;
    constant x5_f : signed(9 downto 0) := x4_f - lane_f;
    constant x6_f : signed(9 downto 0) := x5_f - lane_f;
    constant x7_f : signed(9 downto 0) := x6_f - lane_f;

    variable r0 : signed (19 downto 0);
    variable r1 : signed (19 downto 0);
    variable r2 : signed (19 downto 0);
    variable r3 : signed (19 downto 0);
    variable r4 : signed (19 downto 0);
    variable r5 : signed (19 downto 0);
    variable r6 : signed (19 downto 0);
    variable r7 : signed (19 downto 0);

    variable x : signed(9 downto 0);
    variable y : signed(9 downto 0);
    
begin
    x := signed(X_POS);
    y := signed(Y_POS);

    if (VISIBLE = '1') then
        if y >= y0 then
            r0 := (dy * (x - x0_b)) - ((x0_f - x0_b) * (y - y0));
            r1 := (dy * (x - x1_b)) - ((x1_f - x1_b) * (y - y0));
            r2 := (dy * (x - x2_b)) - ((x2_f - x2_b) * (y - y0));
            r3 := (dy * (x - x3_b)) - ((x3_f - x3_b) * (y - y0));
            r4 := (dy * (x - x4_b)) - ((x4_f - x4_b) * (y - y0));
            r5 := (dy * (x - x5_b)) - ((x5_f - x5_b) * (y - y0));
            r6 := (dy * (x - x6_b)) - ((x6_f - x6_b) * (y - y0));
            r7 := (dy * (x - x7_b)) - ((x7_f - x7_b) * (y - y0));

            if
            ((y >= y0 and y <= y0 + 1) or (y = y0 + 3)) or
            (y >= y2 and y < y2 + 1) or
            (y > y3 and y <= y3 + 1) or
            (y >= y4 and y <= y4 + 1) or
            (y >= y5 and y <= y5 + 1) or
            (y >= y6 and y <= y6 + 1) or
            (y >= y7 and y <= y7 + 2) or
            (y >= y8 and y <= y8 + 2) or

            -- Perspective
            (r0 > -dy - de and r0 <= de) or
            (r1 > -dy - de and r1 <= de) or
            (r2 > -dy - de and r2 <= de) or
            (r3 > -dy - de and r3 <= de) or
            (r4 > -dy - de and r4 <= de) or
            (r5 > -dy - de and r5 <= de) or
            (r6 > -dy - de and r6 <= de) or
            (r7 > -dy - de and r7 <= de)
            then
                SHOW <= '1';
            else
                SHOW <= '0';
            end if;
        end if;
    end if;

end process;

end Behavioral;