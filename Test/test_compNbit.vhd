library ieee;
use ieee.std_logic_1164.all;

-- A concrete-width 8-bit compNbit wrapper for testing
-- To change width, update a, b widths in the port declaration
-- and update the generic 'n' value in the compNbit instantiation

entity test_compNbit is
    port (
        a, b : in std_logic_vector(7 downto 0);
        altb, aeqb, agtb : out std_logic
    );
end entity test_compNbit;

architecture structural of test_compNbit is

    component compNbit
        generic (
            n : integer
        );
        port (
            a, b : in std_logic_vector((n-1) downto 0);
            altb, aeqb, agtb : out std_logic
        );
    end component;

begin

    comp : compNbit
        generic map (
            n => 8
        )
        port map (
            a => a,
            b => b,
            altb => altb,
            aeqb => aeqb,
            agtb => agtb
        );

end architecture structural;
