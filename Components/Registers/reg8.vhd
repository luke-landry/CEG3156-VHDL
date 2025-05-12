library IEEE;
USE IEEE.std_logic_1164.all;

-- 8 bit register
entity reg8 is
    port ( 
            d0, d1, d2, d3, d4, d5, d6, d7, clk, load : in STD_LOGIC;   -- d0-d7 are input bits, clk is the clock signal, load is the command to load DFF with new data 
            q0, q1, q2, q3, q4, q5, q6, q7 : out STD_LOGIC              -- q0-q7 are the output bits
        );
end reg8;

architecture rtl of reg8 is
    signal int_d0, int_d1, int_d2, int_d3, int_d4, int_d5, int_d6, int_d7 : std_logic;  -- Mux output signal
    signal int_q0, int_q1, int_q2, int_q3, int_q4, int_q5, int_q6, int_q7 : std_logic;  -- DFF output signal

    component m2to1 
    port(
            d0, d1, s0 : in std_logic;
            q0 : out std_logic
    );
    end component;

    component d_FF
	port(
                i_d, i_clock : IN STD_LOGIC;
                o_q, o_qBar : OUT STD_LOGIC
        );
    end component;
begin

    m7: m2to1   -- 2 to 1 Mux to control load. No load signal causes DFF to store previous state (no change)
    port map(
        d0 => int_q7,   -- Previous state
        d1 => d7,       -- New state
        s0 => load,
        q0 => int_d7
    );

    m6: m2to1
    port map(
        d0 => int_q6,
        d1 => d6,
        s0 => load,
        q0 => int_d6
    );

    m5: m2to1
    port map(
        d0 => int_q5,
        d1 => d5,
        s0 => load,
        q0 => int_d5
    );

    m4: m2to1
    port map(
        d0 => int_q4,
        d1 => d4,
        s0 => load,
        q0 => int_d4
    );

    m3: m2to1
    port map(
        d0 => int_q3,
        d1 => d3,
        s0 => load,
        q0 => int_d3
    );

    m2: m2to1
    port map(
        d0 => int_q2,
        d1 => d2,
        s0 => load,
        q0 => int_d2
    );

    m1: m2to1
    port map(
        d0 => int_q1,
        d1 => d1,
        s0 => load,
        q0 => int_d1
    );

    m0: m2to1
    port map(
        d0 => int_q0,
        d1 => d0,
        s0 => load,
        q0 => int_d0
    );

    r7: d_FF
    port map(
        i_d => int_d7, -- mux7 output
        i_clock => clk,
        o_q => int_q7,
        o_qBar => open
    );

    r6: d_FF
    port map(
        i_d => int_d6, -- mux6 output
        i_clock => clk,
        o_q => int_q6,
        o_qBar => open
    );

    r5: d_FF
    port map(
        i_d => int_d5, --...
        i_clock => clk,
        o_q => int_q5,
        o_qBar => open
    );

    r4: d_FF
    port map(
        i_d => int_d4,
        i_clock => clk,
        o_q => int_q4,
        o_qBar => open
    );

    r3: d_FF
    port map(
        i_d => int_d3,
        i_clock => clk,
        o_q => int_q3,
        o_qBar => open
    );

    r2: d_FF
    port map(
        i_d => int_d2,
        i_clock => clk,
        o_q => int_q2,
        o_qBar => open
    );

    r1: d_FF
    port map(
        i_d => int_d1,
        i_clock => clk,
        o_q => int_q1,
        o_qBar => open
    );

    r0: d_FF
    port map(
        i_d => int_d0,
        i_clock => clk,
        o_q => int_q0,
        o_qBar => open
    );

    -- Load output bits
    q7 <= int_q7;
    q6 <= int_q6;
    q5 <= int_q5;
    q4 <= int_q4;
    q3 <= int_q3;
    q2 <= int_q2;
    q1 <= int_q1;
    q0 <= int_q0;
end architecture rtl;
            
            