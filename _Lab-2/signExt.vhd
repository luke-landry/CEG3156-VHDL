LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- sign extender
entity signExt is
    port(
        inp : in std_logic_vector(15 downto 0); 
        res : out std_logic_vector(31 downto 0)
    );
end signExt;

architecture rtl of signExt is
begin

    res(15 downto 0)  <= inp;
    res(31 downto 16) <= (others => inp(15));

end architecture rtl;
