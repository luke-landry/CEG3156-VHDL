LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- sign extender
entity hazDetecUnit is
    port(
        idExMemRead : in std_logic;
        idExRegRt, ifIdRegRs, ifIdRegRt : in std_logic_vector(2 downto 0);
        pcWrite, ifIdWrite, controlMux : out std_logic
    );
end hazDetecUnit;

architecture rtl of hazDetecUnit is
    signal enable, activeOut : std_logic;
    signal xnors : std_logic_vector(1 downto 0);

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

    enable <= exMemRegWrite and (not (exMemRegRd));

    comp0: compNbit
        generic map(
            n => 8
        )
        port map(
            a => idExRegRt, 
            b  => ifIdRegRs,
            altb => open, 
            aeqb => xnors(0), 
            agtb => open
        );

    comp1: compNbit
        generic map(
            n => 8
        )
        port map(
            a => idExRegRt, 
            b  => ifIdRegRt,
            altb => open, 
            aeqb => xnors(1), 
            agtb => open
        );


    activeOut <= (xnors(0) or xnors(1)) and idExMemRead;

    pcWrite     <= not(activeOut);
    ifIdWrite   <= not(activeOut);
    controlMux  <= not(activeOut);


end architecture rtl;
