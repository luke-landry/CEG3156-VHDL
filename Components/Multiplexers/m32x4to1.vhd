library ieee;
use ieee.std_logic_1164.all;

-- 32-bit wide 4-to-1 multiplexer using 32 instances of 1-bit m4to1
entity m32x4to1 is
    port (
        d0, d1, d2, d3 : in std_logic_vector(31 downto 0);  -- Four 32-bit inputs
        s0, s1         : in std_logic;                     -- 2-bit select
        q              : out std_logic_vector(31 downto 0) -- 32-bit output
    );
end m32x4to1;

architecture rtl of m32x4to1 is

    component m4to1
        port (
            d0, d1, d2, d3 : in std_logic;
            s0, s1         : in std_logic;
            q0             : out std_logic
        );
    end component;

begin

    -- Structural generate for 32-bit wide mux using 1-bit m4to1 components
    gen_mux: for i in 0 to 31 generate
        mux_inst: m4to1
            port map (
                d0 => d0(i),
                d1 => d1(i),
                d2 => d2(i),
                d3 => d3(i),
                s0 => s0,
                s1 => s1,
                q0 => q(i)
            );
    end generate gen_mux;

end architecture rtl;
