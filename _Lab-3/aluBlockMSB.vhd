LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- Most significant bit ALU block from textbook "Computer Organnization and Design: MIPS Edition - D. Patterson & J. Hennessy" page B-723
entity aluBlockMSB is
    port(
        a, b, cIn, less, aInv, bInv : in std_logic;
        op : in std_logic_vector(1 downto 0); 
        result, cOut, set : out std_logic
    );
end aluBlockMSB;

architecture rtl of aluBlockMSB is
    signal aOut, bOut, andOut, orOut, addOut : std_logic;


component m2to1 is
    port(
            d0, d1, s0 : in std_logic;  -- d0, d1 are data inputs, s0 is select input
            q0 : out std_logic          -- q0 is data output
    );
end component;

component m4to1 is
    port(
            d0, d1, d2, d3, s0, s1 : in std_logic;  -- d0, d1, d2, d3 are data inputs, s0, s1 are select inputs
            q0 : out std_logic                      -- q0 is data output
    );
end component;

component full_adder is
    port(
        a, b, cIn : in std_logic; 
        sum, cOut : out std_logic
    );
end component;

begin

    aMux : m2to1
    port map(
        d0 => a, 
        d1 => not(a), 
        s0 => aInv,
        q0 => aOut
    );

    bMux : m2to1
    port map(
        d0 => b, 
        d1 => not(b), 
        s0 => bInv,
        q0 => bOut
    );

    andOut <= aOut and bOut;
    orOut <= aOut or bOut;

    fAdd : full_adder
    port map(
        a => aOut, 
        b => bOut, 
        cIn => cIn,
        sum => addOut, 
        cOut => cOut
    );

    resMux : m4to1
    port map(
        d0 => andOut, 
        d1 => orOut, 
        d2 => addOut, 
        d3 => less, 
        s0 => op(0), 
        s1 => op(1),
        q0 => result
    );

    set <= addOut;

end architecture rtl;
