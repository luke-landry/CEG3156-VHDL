LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- 2 to 1 Multiplexor
entity m2to1 is
    port(
            d0, d1, s0 : in std_logic;  -- d0, d1 are data inputs, s0 is select input
            q0 : out std_logic          -- q0 is data output
    );
end m2to1;

architecture rtl of m2to1 is
    signal int_s0Bar, int_and0, int_and1  : std_logic;  -- intermediate signals
begin
    int_s0Bar <= not(s0);

    int_and0 <= int_s0Bar and d0;   -- d0 when s0 is low
    int_and1 <= s0 and d1;          -- d1 when s1 is high

    q0 <= int_and0 or int_and1;     -- Load q0 
end architecture rtl;