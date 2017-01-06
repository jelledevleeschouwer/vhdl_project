library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity rand_driver is
    Port (
        SEED : in STD_LOGIC;
        RAND : out STD_LOGIC_VECTOR (7 downto 0);
        CLK : in STD_LOGIC;
        RST : in STD_LOGIC
    );
end rand_driver;    -- EOF ENTITY

architecture Behavioral of rand_driver is
begin

    seed_process: process(CLK)
        variable s0 : unsigned(7 downto 0) := to_unsigned(21, 8);
        variable s1 : unsigned(7 downto 0) := to_unsigned(229, 8);
        variable s2 : unsigned(7 downto 0) := to_unsigned(181, 8);
        variable s3 : unsigned(7 downto 0) := to_unsigned(51, 8);
        variable t : unsigned(7 downto 0);
        variable c : unsigned(7 downto 0);
    begin
        if (CLK'event and CLK='1') then
            if RST = '1' then
                s0 := to_unsigned(21, 8);
                s1 := to_unsigned(229, 8);
                s2 := to_unsigned(181, 8);
                s3 := to_unsigned(51, 8);
            elsif SEED = '1' then
                s1 := s0 xor (s0 sll 1);
                s0 := s3;
                s3 := s3 xor s2 xor (s1 srl 3);
            else
                c := c + 1;
                if (c = t) then
                    t := s0 xor (s0 sll 3);
                    s0 := s1;
                    s1 := s2;
                    s2 := s3;
                    s3 := s3 xor (s3 srl 5) xor (t xor (t srl 2));
                end if;
            end if;

            -- Put the new value on the output
            RAND <= std_logic_vector(s3);
        end if;
    end process;


end Behavioral;     -- EOF BEHAVIORAL
