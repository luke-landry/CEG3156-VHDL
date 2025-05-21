library IEEE;
USE IEEE.std_logic_1164.all;

-- 8 bit register
entity regNASR is
    generic(
        n : integer;
    );
    port ( 
            d : in std_logic_vector(n-1 downto 0); -- 8 bit input vector
            clk, load, reset : in std_logic;
            q : out std_logic_vector(n-1 downto 0) -- 8 bit output vector
        );
end regNASR;

architecture rtl of regNASR is
    signal int_d : std_logic_vector(n-1 downto 0);  -- Mux output signal
    signal int_q : std_logic_vector(n-1 downto 0);  -- DFF output signal

    component m2to1 
    port(
            d0, d1, s0 : in std_logic;  -- d0, d1 are data inputs, s0 is select input
            q0 : out std_logic          -- q0 is data output
    );
    end component;

    component d_FF_ASR
	port(
                i_set, i_reset : IN STD_LOGIC;
                i_d : IN STD_LOGIC;
                i_clock : IN STD_LOGIC;
                o_q, o_qBar : OUT STD_LOGIC
        );
    end component;
begin
    
    gen_m2to1 : for i in n-1 downto 0 generate
        MuxD : m2to1
        port map (
            d0 => int_q(i),
            d1 => d(i),
            s0 => load,
            q0 => int_d(i)
        );
    end generate;

    gen_dFF : for i in n-1 downto 0 generate
        dFFB : d_FF_ASR
        port map (
            i_clock => clk,
            i_set => '1',
            i_reset => reset,
            i_d => int_d(i),
            o_q => int_q(i),
            o_qBar => open
        );
    end generate;

    -- bitwise assign outputs
    q <= int_q;

end architecture rtl;
            
            