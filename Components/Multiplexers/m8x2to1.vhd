
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- 8 bit x 2 input Multiplexor
-- This design uses 8, 2 bit Multiplexors to handle the 8 bits of each of the 2 inputs
entity m8x2to1 is
    port (
        d0, d1 : in std_logic_vector(7 downto 0);   -- d0, d1 are 8 bit data inputs
        s0 : in std_logic;                          -- s0 is the select input
        q : out std_logic_vector(7 downto 0)        -- q0 is 8 bit data output         
    );
end m8x2to1;

architecture rtl of m8x2to1 is
    component m2to1
        port (
            d0, d1, s0 : in std_logic;  -- d0, d1 are data inputs, s0 is select input
            q0 : out std_logic  
        );
    end component;

begin

    mux0: m2to1 
    port map (
        d0 => d0(0), d1 => d1(0), -- Load 0th bit of each 8 bit input into data inputs of 2x1 mux
        s0 => s0,
        q0 => q(0)  -- Load the 0th bit of the 8 bit output 
    );

    mux1: m2to1 
    port map (
        d0 => d0(1), d1 => d1(1), -- Load 1st bit of each 8 bit input into data inputs of 2x1 mux
        s0 => s0,
        q0 => q(1) -- Load the 1st bit of the 8 bit output 
    );

    mux2: m2to1 
    port map (
        d0 => d0(2), d1 => d1(2), -- ...
        s0 => s0,
        q0 => q(2) -- ...
    );

    mux3: m2to1 
    port map (
        d0 => d0(3), d1 => d1(3),
        s0 => s0,
        q0 => q(3)
    );

    mux4: m2to1 
    port map (
        d0 => d0(4), d1 => d1(4),
        s0 => s0,
        q0 => q(4)
    );

    mux5: m2to1 
    port map (
        d0 => d0(5), d1 => d1(5),
        s0 => s0,
        q0 => q(5)
    );

    mux6: m2to1 
    port map (
        d0 => d0(6), d1 => d1(6),
        s0 => s0,
        q0 => q(6)
    );

    mux7: m2to1 
    port map (
        d0 => d0(7), d1 => d1(7),
        s0 => s0,
        q0 => q(7)
    );
end architecture rtl;
