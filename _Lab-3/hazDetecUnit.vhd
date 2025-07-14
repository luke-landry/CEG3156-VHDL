LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- sign extender
entity hazDetecUnit is
    port(
        idExMemRead : in std_logic;
        idExRegRt, ifIdRegRs, ifIdRegRt : in std_logic_vector(4 downto 0);
        pcWrite, ifIdWrite, controlMux : out std_logic
    );
end hazDetecUnit;

architecture rtl of hazDetecUnit is
    signal enable, activeOut : std_logic;
    signal xnors : std_logic_vector(1 downto 0);
    
begin

    enable <= exMemRegWrite and (not (exMemRegRd));

    xnors(0) <= ((idExRegRt xnor ifIdRegRs) and "1111");
    xnors(1) <= ((idExRegRt xnor ifIdRegRt) and "1111");

    activeOut <= (xnors(0) or xnors(1)) and idExMemRead;

    pcWrite     <= not(activeOut);
    ifIdWrite   <= not(activeOut);
    controlMux  <= not(activeOut);


end architecture rtl;
