LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- Full adder
entity adder1bit is
    port(
        a, b, cIn : in std_logic; 
        sum, cOut : out std_logic

    );
end adder1bit;

architecture rtl of adder1bit is
begin
    cOut <= (a and cIN) or (b and cIn) or (a and b); --Carry out equation
    sum <= a xor b xor cIn; -- Sum equation
end architecture rtl;
