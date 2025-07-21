LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- sign extender
entity forwardUnit is
    port(
        exMemRegWrite : in std_logic;
        exMemRegRd, memWbRedRd, idExRegRs, idExRegRt : in std_logic_vector(2 downto 0);
        fA, fB : out std_logic_vector(1 downto 0)
    );
end forwardUnit;

architecture rtl of forwardUnit is
    signal enable : std_logic;
    signal comps, xnors : std_logic_vector(3 downto 0);

        component compNbit is
        generic(
            n : integer -- must be >= 3
        );
        port(
            a, b : in std_logic_vector((n-1) downto 0);
            altb, aeqb, agtb : out std_logic
        );
    end component compNbit;
    
begin

    enable <= exMemRegWrite and (exMemRegRd(0) or exMemRegRd(1) or exMemRegRd(2));

    comp0: compNbit
        generic map(
            n => 3
        )
        port map(
            a => exMemRegRd, 
            b  => idExRegRs,
            altb => open, 
            aeqb => comps(0), 
            agtb => open
        );

    comp1: compNbit
        generic map(
            n => 3
        )
        port map(
            a => exMemRegRd, 
            b  => idExRegRt,
            altb => open, 
            aeqb => comps(1), 
            agtb => open
        );

    comp2: compNbit
        generic map(
            n => 3
        )
        port map(
            a => memWbRedRd, 
            b  => idExRegRs,
            altb => open, 
            aeqb => comps(2), 
            agtb => open
        );

    comp3: compNbit
        generic map(
            n => 3
        )
        port map(
            a => memWbRedRd, 
            b  => idExRegRt,
            altb => open, 
            aeqb => comps(3), 
            agtb => open
        );

    xnors(0) <= comps(0) and enable;
    xnors(1) <= comps(1) and enable;
    xnors(2) <= comps(2) and enable;
    xnors(3) <= comps(3) and enable;

    fA(1) <= xnors(0);
    fA(0) <= not(xnors(0)) and xnors(2);
    fB(1) <= xnors(1);
    fB(0) <= not(xnors(1)) and xnors(3);

end architecture rtl;
