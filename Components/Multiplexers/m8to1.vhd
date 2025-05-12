
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- 4 to 1 Multiplexor
entity m8to1 is
    port(
            d : in std_logic_vector(7 downto 0); -- Data inputs
            s: in std_logic_vector(2 downto 0); --Select inputs
            q : out std_logic -- Data outputs
    );
end m8to1;

architecture struct of m8to1 is
    signal m1_Out, m2_Out : std_logic;

    component m4to1 is
        port(
                d0, d1, d2, d3, s0, s1 : in std_logic;  -- d0, d1, d2, d3 are data inputs, s0, s1 are select inputs
                q0 : out std_logic                      -- q0 is data output
        );
    end component;

    component m2to1 is
        port(
                d0, d1, s0 : in std_logic;  -- d0, d1 are data inputs, s0 is select input
                q0 : out std_logic          -- q0 is data output
        );
    end component;
begin

    mux4_1 : m4to1
    port map(
        d0 => d(0), 
        d1 => d(1), 
        d2 => d(2),
        d3 => d(3), 
        s0 => s(0),
        s1 => s(1),
        q0 => m1_Out
    );

    mux4_2 : m4to1
    port map(
        d0 => d(4), 
        d1 => d(5), 
        d2 => d(6),
        d3 => d(7), 
        s0 => s(0),
        s1 => s(1),
        q0 => m2_Out
    );

    mux2 : m2to1
    port map(
        d0 => m1_Out, 
        d1 => m2_Out, 
        s0 => s(2),
        q0 => q
    );

end struct;
