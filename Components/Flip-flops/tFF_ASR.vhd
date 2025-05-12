
library ieee;
use ieee.std_logic_1164.all;

-- T-flip-flop implemented with an internal dFF, with asyncronous active low set and reset
entity t_FF_ASR is 
    port( 
        i_set, i_reset : IN STD_LOGIC;
        i_t : IN STD_LOGIC;
        i_clock : IN STD_LOGIC;
        o_q, o_qBar : OUT STD_LOGIC
    );
end t_FF_ASR;

architecture structural of t_FF_ASR is

    signal int_d, int_q, int_qBar : std_logic;

   component d_FF_ASR
	port(       
                i_set, i_reset : in std_logic;
                i_d, i_clock : in std_logic;
                o_q, o_qBar : out std_logic
        );
    end component;

    begin

    int_d <= int_q xor i_t;

    internal_dFF_ASR : d_FF_ASR
    port map(
        i_set => i_set,
        i_reset => i_reset,
        i_d => int_d,
        i_clock => i_clock,
        o_q => int_q,
        o_qBar => int_qBar
    );

    o_q <= int_q;
    o_qBar <= int_qBar;

end structural;