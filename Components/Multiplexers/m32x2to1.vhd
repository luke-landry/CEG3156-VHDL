LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- 32-bit 2-to-1 multiplexer using 32 instances of m2to1
entity m32x2to1 is
    port (
        d0, d1 : in std_logic_vector(31 downto 0);  -- Two 32-bit inputs
        s0     : in std_logic;                     -- 1-bit select
        q      : out std_logic_vector(31 downto 0) -- 32-bit output
    );
end m32x2to1;

architecture rtl of m32x2to1 is

    component m2to1
        port (
            d0, d1, s0 : in std_logic;
            q0         : out std_logic
        );
    end component;

begin

    gen_mux: for i in 0 to 31 generate
        mux_inst: m2to1
            port map (
                d0 => d0(i),
                d1 => d1(i),
                s0 => s0,
                q0 => q(i)
            );
    end generate gen_mux;

end architecture rtl;
