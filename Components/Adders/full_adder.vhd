LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- Full adder
entity full_adder is
    port(
        a, b, cIn : in std_logic; 
        sum, cOut : out std_logic
    );
end full_adder;

architecture rtl of full_adder is
begin
    cOut <=(a and b) or (a and cIn)or (b and cIn); --Carry out equation
    sum <= a xor b xor cIn; -- Sum equation
end architecture rtl;
