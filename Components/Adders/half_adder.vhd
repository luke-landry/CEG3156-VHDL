LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- Full adder
entity half_adder is
    port(
        a, b : in std_logic; 
        sum, cOut : out std_logic
    );
end half_adder;

architecture rtl of half_adder is
begin
    cOut <= a and b; --Carry out equation
    sum <= a xor b; -- Sum equation
end architecture rtl;
