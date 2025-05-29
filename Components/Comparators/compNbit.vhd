library ieee;
use ieee.std_logic_1164.all;

-- n bit comparator that compares two unsigned operands using subtraction

entity compNbit is
    generic(
        n : integer -- must be >= 3
    );
    port(
        a, b : in std_logic_vector((n-1) downto 0);
        altb, aeqb, agtb : out std_logic
    );
end entity compNbit;

architecture structural of compNbit is

    signal int_cOut, int_zero : std_logic;

    component aluNbit
    generic (
        n : integer
    );
    port (
            a, b : in std_logic_vector((n-1) downto 0);
            addbar_sub : in std_logic;
            result : out std_logic_vector((n-1) downto 0);
            cOut, zero : out std_logic
        );
    end component;

    begin
        
    -- ensure that bit width is >= 3
    assert n >= 3 report "Bit width (n) of compNbit must be >= 3" severity failure;

    alu : aluNbit
    generic map(
        n => n
    )
    port map(
        a => a,
        b => b,
        addbar_sub => '1', -- always subtract to compare operands
        result => open,
        cOut => int_cOut,
        zero => int_zero

    );

    -- carry out indicates subtraction had a carry out bit, meaning a >= b
    -- no carry out indicates that the subtraction did not cause a carry out, so a < b
    -- zero indicates a == b

    altb <= not int_cOut;
    aeqb <= int_zero;
    agtb <= int_cOut and (not int_zero);

end architecture structural;