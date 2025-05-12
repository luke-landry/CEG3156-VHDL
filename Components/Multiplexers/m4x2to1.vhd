
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- 4 bit x 2 input Multiplexor
-- This design uses 4, 2 bit Multiplexors to handle the 8 bits of each 4 inputs
entity m4x2to1 is
    port (
        d0, d1 : in std_logic_vector(3 downto 0);   -- d0, d1 are 4 bit data inputs
        s0 : in std_logic;                          -- s0 is the select input
        q : out std_logic_vector(3 downto 0)        -- q0 is 4 bit data output         
    );
end m4x2to1;

architecture rtl of m4x2to1 is
    component m2to1
        port (
            d0, d1, s0 : in std_logic;  -- d0, d1 are data inputs, s0 is select input
            q0 : out std_logic  
        );
    end component;

begin

    mux0: m2to1 
    port map (
        d0 => d0(0), d1 => d1(0), -- Load 0th bit of each 4 bit input into data inputs of 2x1 mux
        s0 => s0,
        q0 => q(0)  -- Load the 0th bit of the 4 bit output 
    );

    mux1: m2to1 
    port map (
        d0 => d0(1), d1 => d1(1), -- Load 1st bit of each 4 bit input into data inputs of 2x1 mux
        s0 => s0,
        q0 => q(1)  -- Load the 1st bit of the 4 bit output 
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
end architecture rtl;
