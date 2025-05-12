LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- 2 bit comparator
-- Circuit diagram taken from https://de-iitr.vlabs.ac.in/exp/comparator-using-logic-gates/theory.html
entity comp2bit is
    port(
        x1, x0, y1, y0 : in std_logic;
        equal, lesser, greater : out std_logic 
    );
end comp2bit;

architecture rtl of comp2bit is

begin

    equal <= (x1 xnor y1) and (x0 xnor y0);
    greater <= (x1 and not(y1)) or (x0 and not(y1) and not(y0)) or (x1 and x0 and not(y0));
    lesser <= (not(x1) and y1) or (not(x0) and y1 and y0) or (not(x1) and not(x0) and y0);

end architecture rtl;
