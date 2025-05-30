library ieee;
use ieee.std_logic_1164.all;

-- ORs every bit of a given n-bit vector

entity orNbit is
    generic(
        n : integer
    );
    port(
        d : in std_logic_vector((n-1) downto 0);
        q : out std_logic
    );
end entity orNbit;

architecture structural of orNbit is
    signal or_chain : std_logic_vector((n-2) downto 0);
begin
    -- ensure that bit width is >= 2
    assert n >= 2 report "Bit width (n) of orNbit must be >= 2" severity failure;

    -- First OR
    or_chain(0) <= d(0) or d(1);

    -- Generate remaining OR chain
    gen_or : for i in 2 to n - 1 generate
        or_chain(i-1) <= or_chain(i-2) or d(i);
    end generate;

    q <= or_chain(n-2);
end architecture structural;
