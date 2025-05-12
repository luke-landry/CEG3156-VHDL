LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- 1 bit comparator
entity comp1bit is
    port(
        x, y : in std_logic;
        equal, lesser, greater : out std_logic 
    );
end comp1bit;

architecture rtl of comp1bit is
begin
    equal <= x xnor y;
    greater <= x and not(y);
    lesser <= not(x) and y;

end architecture rtl;
