library ieee;
use ieee.std_logic_1164.all;

-- n bit ALU that can perform addition and subtraction

entity aluNbit is
    generic(
        n : integer -- must be >= 3
    );
    port(
        a, b : in std_logic_vector((n-1) downto 0);
        addbar_sub : in std_logic;

        result : out std_logic_vector((n-1) downto 0);
        cOut, zero : out std_logic
    );
end entity aluNbit;

architecture structural of aluNbit is

    signal int_cOut, int_result : std_logic_vector((n-1) downto 0);
    signal int_resultOr : std_logic;

    component aluBlock
    port (
            a, b, cIn, addbar_sub : in std_logic;
            result, cOut : out std_logic
        );
    end component;

    component orNbit
    generic(
        n : integer
    );
    port(
        d : in std_logic_vector((n-1) downto 0);
        q : out std_logic
    );
    end component;

    begin

    -- ensure that bit width is >= 3
    assert n >= 3 report "Bit width (n) of aluNbit must be >= 3" severity failure;

    aluLSB : aluBlock
    port map(
        a => a(0),
        b => b(0),
        cIn => addbar_sub,
        addbar_sub => addbar_sub,
        result => int_result(0),
        cOut => int_cOut(0)
    );

    -- generate middle bits between MSB and LSB
    genBits : for i in 1 to n-2 generate
        aluBi : aluBlock
        port map(
            a => a(i),
            b => b(i),
            cIn => int_cOut(i-1),
            addbar_sub => addbar_sub,
            result => int_result(i),
            cOut => int_cOut(i)
        );
    end generate;


    aluMSB : aluBlock
    port map(
        a => a(n-1),
        b => b(n-1),
        cIn => int_cOut(n-2),
        addbar_sub => addbar_sub,
        result => int_result(n-1),
        cOut => int_cOut(n-1)
    );

    resultOr : orNbit
    generic map(
        n => n
    )
    port map(
        d => int_result,
        q => int_resultOr
    );

    zero <= not int_resultOr;
    result <= int_result;
    cOut <= int_cOut(n-1);

end architecture structural;