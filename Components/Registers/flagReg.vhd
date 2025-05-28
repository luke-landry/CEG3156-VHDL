library ieee;
use ieee.std_logic_1164.all;

entity flagReg is
    port(
        clk, reset : in std_Logic;
        d, syncSet, syncReset : in std_logic;
        q : out std_logic
    );
end entity flagReg;

architecture structural of flagReg is
    signal int_d : std_logic;

    component d_FF_ASR
	port(
        i_set, i_reset : in std_logic;
        i_d : in std_logic;
        i_clock : in std_logic;
        o_q, o_qBar : out std_logic
    );
    end component;

    begin
    -- priority order: syncReset, syncSet, d
    int_d <= (not syncReset) and (syncSet or d);
    
    dFF : d_FF_ASR
    port map(
        i_set => '1',
        i_reset => reset,
        i_d => int_d,
        i_clock => clk,
        o_q => q,
        o_qBar => open
    );

end architecture structural;