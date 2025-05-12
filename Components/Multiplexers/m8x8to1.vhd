
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- 8 bit 8-to-1 multiplexer
-- This design uses an 8-bit 2-to-1 multiplexer and two 8-bit 4-to-1 multiplexers
entity m8x8to1 is
    port (
        d0, d1, d2, d3 , d4, d5, d6, d7: in std_logic_vector(7 downto 0);   -- 8x8b data inputs
        s0, s1, s2 : in std_logic;                              -- 3b select input
        q : out std_logic_vector(7 downto 0)                -- 8 bit data output         
    );
end m8x8to1;

architecture rtl of m8x8to1 is
    component m8x2to1 is
        port (
        d0, d1 : in std_logic_vector(7 downto 0);   -- d0, d1 are 8 bit data inputs
        s0 : in std_logic;                          -- s0 is the select input
        q : out std_logic_vector(7 downto 0)        -- q0 is 8 bit data output         
    );
    end component;

    component m8x4to1 is
        port (
            d0, d1, d2, d3 : in std_logic_vector(7 downto 0);   -- d0, d1, d2, d3 are 8 bit data inputs
            s0, s1 : in std_logic;                              -- s0, s1 are select inputs
            q : out std_logic_vector(7 downto 0)                -- q0 is 8 bit data output         
        );
    end component;

    signal MSN, LSN : std_logic_vector(7 downto 0);

begin

    -- select nibble multiplexer
    m8x2to1_LSN: m8x2to1
    port map (
        d0 => LSN,
        d1 => MSN,
        s0 => s2,
        q  => q      
    );

    -- least significant nibble
    m8x4to1_LSN: m8x4to1 
    port map (
        d0 => d0,
        d1 => d1,
        d2 => d2,
        d3 => d3,
        s0 => s0,
        s1 => s1,
        q  => LSN     
    );

    -- most significant nibble
    m8x4to1_MSN: m8x4to1 
    port map (
        d0 => d4,
        d1 => d5,
        d2 => d6,
        d3 => d7,
        s0 => s0,
        s1 => s1,
        q  => MSN      
    );

end architecture rtl;
