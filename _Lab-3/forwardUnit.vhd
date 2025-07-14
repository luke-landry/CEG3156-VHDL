LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- sign extender
entity forwardUnit is
    port(
        exMemRegWrite : in std_logic;
        exMemRegRd, memWbRedRd, idExRegRs, idExRegRt : in std_logic_vector(4 downto 0);
        fA, fB : out std_logic_vector(1 downto 0)
    );
end forwardUnit;

architecture rtl of forwardUnit is
    signal enable : std_logic;
    signal xnors : std_logic_vector(3 downto 0);
    
begin

    enable <= exMemRegWrite and (not (exMemRegRd));

    xnors(0) <= ((exMemRegRd xnor idExRegRs) and "1111") and enable;
    xnors(1) <= ((exMemRegRd xnor idExRegRt) and "1111") and enable;
    xnors(2) <= ((memWbRedRd xnor idExRegRs) and "1111") and enable;
    xnors(3) <= ((memWbRedRd xnor idExRegRt) and "1111") and enable;

    fA(1) <= xnors(0);
    fA(0) <= not(xnors(0)) and xnors(2);
    fB(1) <= xnors(1);
    fB(0) <= not(xnors(1)) and xnors(3);

end architecture rtl;
