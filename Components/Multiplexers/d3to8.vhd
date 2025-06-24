LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- 3 to 8 Decoder
entity d3to8 is
    port(
            d : in std_logic_vector(2 downto 0);
            q : out std_logic_vector(7 downto 0)
    );
end d3to8;

architecture rtl of d3to8 is
begin

    q(0) <= not(d(0)) and not(d(1)) and not(d(2));
    q(1) <= (d(0)) and not(d(1)) and not(d(2));
    q(2) <= not(d(0)) and (d(1)) and not(d(2));
    q(3) <= (d(0)) and (d(1)) and not(d(2)); 
    q(4) <= not(d(0)) and not(d(1)) and (d(2));
    q(5) <= (d(0)) and not(d(1)) and (d(2)); 
    q(6) <= not(d(0)) and (d(1)) and (d(2));
    q(7) <= (d(0)) and (d(1)) and (d(2)); 

end architecture rtl;