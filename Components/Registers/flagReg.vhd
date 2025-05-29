library ieee;
use ieee.std_logic_1164.all;

entity flagReg is
    port(
        clk, reset : in std_Logic;
        d, syncSet, syncReset, load : in std_logic;
        q : out std_logic
    );
end entity flagReg;

architecture structural of flagReg is
    signal int_d, int_q, int_nextNonLoad : std_logic;

    component m2to1
    port(
        d0, d1, s0 : in std_logic;  -- d0, d1 are data inputs, s0 is select input
        q0 : out std_logic          -- q0 is data output
    );
    end component;

    component d_FF_ASR
	port(
        i_set, i_reset : in std_logic;
        i_d : in std_logic;
        i_clock : in std_logic;
        o_q, o_qBar : out std_logic
    );
    end component;

    begin

    -- Synchronous non-load next-state with priority: syncReset > syncSet > hold
    int_nextNonLoad <= (not syncReset) and (syncSet or int_q);

    mux : m2to1
    port map(
        d0 => int_nextNonLoad,
        d1 => d,
        s0 => load,
        q0 => int_d
    );

    dFF : d_FF_ASR
    port map(
        i_set => '1',
        i_reset => reset,
        i_d => int_d,
        i_clock => clk,
        o_q => int_q,
        o_qBar => open
    );

    q <= int_q;

end architecture structural;