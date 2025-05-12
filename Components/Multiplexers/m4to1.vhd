
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- 4 to 1 Multiplexor
entity m4to1 is
    port(
            d0, d1, d2, d3, s0, s1 : in std_logic;  -- d0, d1, d2, d3 are data inputs, s0, s1 are select inputs
            q0 : out std_logic                      -- q0 is data output
    );
end m4to1;

architecture rtl of m4to1 is
    signal int_s0Bar, int_s1Bar, int_and0, int_and1, int_and2, int_and3  : std_logic; -- intermediate signals
begin
    int_s0Bar <= not(s0);
    int_s1Bar <= not(s1);

    int_and0 <= int_s1Bar and int_s0Bar and d0; -- d0 when s0 and s1 are low
    int_and1 <= int_s1Bar and s0 and d1;        -- d1 when s0 is high and s1 is low
    int_and2 <= s1 and int_s0Bar and d2;        -- d2 when s0 is low and s1 is high
    int_and3 <= s1 and s0 and d3;               -- d3 when s0 and s1 are high

    q0 <= int_and0 or int_and1 or int_and2 or int_and3; -- Load q0 
end architecture rtl;
