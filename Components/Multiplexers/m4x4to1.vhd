
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- 4 bit x 4 input Multiplexor
-- This design uses 4, 4 bit Multiplexors to handle the 8 bits of each 4 inputs
entity m4x4to1 is
    port (
        d0, d1, d2, d3 : in std_logic_vector(3 downto 0);   -- d0, d1, d2, d3 are 4 bit data inputs
        s0, s1 : in std_logic;                              -- s0, s1 are select inputs
        q : out std_logic_vector(3 downto 0)                -- q0 is 4 bit data output         
    );
end m4x4to1;

architecture rtl of m4x4to1 is
    component m4to1
        port (
            d0, d1, d2, d3, s0, s1 : in std_logic;
            q0 : out std_logic
        );
    end component;

begin

    mux0: m4to1 
    port map (
        d0 => d0(0), d1 => d1(0), d2 => d2(0), d3 => d3(0), -- Load 0th bit of each 4 bit input into data inputs of 4x1 mux
        s0 => s0, s1 => s1,
        q0 => q(0)  -- Load the 0th bit of the 4 bit output 
    );

    mux1: m4to1 
    port map (
        d0 => d0(1), d1 => d1(1), d2 => d2(1), d3 => d3(1), -- Load 1st bit of each 4 bit input into data inputs of 4x1 mux
        s0 => s0, s1 => s1,
        q0 => q(1)  -- Load the 1st bit of the 4 bit output 
    );

    mux2: m4to1 
    port map (
        d0 => d0(2), d1 => d1(2), d2 => d2(2), d3 => d3(2), -- ...
        s0 => s0, s1 => s1,
        q0 => q(2) -- ...
    );

    mux3: m4to1 
    port map (
        d0 => d0(3), d1 => d1(3), d2 => d2(3), d3 => d3(3), 
        s0 => s0, s1 => s1,
        q0 => q(3)
    );
end architecture rtl;
