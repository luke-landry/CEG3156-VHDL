library ieee;
use ieee.std_logic_1164.all;

-- A concrete width orNbit wrapper for testing
-- to change width, update d's width in the test_orNbit port declaration
-- and then update the generic-n in the orNbit instantiation
entity test_orNbit is
    port (
        d : in std_logic_vector(2 downto 0);
        q : out std_logic
    );
end entity test_orNbit;

architecture structural of test_orNbit is

    component orNbit
        generic (
            n : integer
        );
        port (
            d : in std_logic_vector((n - 1) downto 0);
            q : out std_logic
        );
    end component;

begin

    or_gate : orNbit
        generic map (
            n => 3
        )
        port map (
            d => d,
            q => q
        );

end architecture structural;
