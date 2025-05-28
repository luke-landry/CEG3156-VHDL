library ieee;
use ieee.std_logic_1164.all;

-- n bit ALU that can perform addition and subtraction

entity aluNbit is
    generic(
        n : integer -- must be >= 2
    );
    port(
        a, b : in std_logic_vector((n-1) downto 0);
        addbar_sub : in std_logic;

        result : out std_logic_vector((n-1) downto 0);
        cOut : out std_logic
    );
end entity aluNbit;

architecture structural of aluNbit is

    signal int_cOut, int_result : std_logic_vector((n-1) downto 0);

    component aluBlock
    port (
            a, b, cIn, addbar_sub : in std_logic;
            result, cOut : out std_logic
        );
    end component;

    begin

    aluLSB : aluBlock
    port map(
        a => a(0),
        b => b(0),
        cIn => addbar_sub,
        addbar_sub => addbar_sub,
        result => int_result(0),
        cOut => int_cOut(0)
    );

    
    -- Defining components for bits between MSB and LSB of register
    -- Using loop bounds i = 2 to n-1 to cover middle bits (bit index = n - i)
    -- This allows n = 2 to be valid, because i = 2 to 1 is a legal empty loop
    -- A loop from i = 1 to n-2 would be invalid when n = 2 (i = 1 to 0 is illegal in VHDL)
    genBits : for i in 2 to n-1 generate
        aluBi : aluBlock
        port map(
            a => a(n-i),
            b => b(n-i),
            cIn => int_cOut(n-i-1),
            addbar_sub => addbar_sub,
            result => int_result(0),
            cOut => int_cOut(0)
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


    result <= int_result;
    cOut <= int_cOut(n-1);


end architecture structural;