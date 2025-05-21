library ieee;
use ieee.std_logic_1164.all;

--- n-bit shift register that can perform
--- left and right shifts, both arithmetic and logical

entity shiftRegN is
    generic(
        n : integer -- n should be >= 2
    );
    port(
        -- PIPO data lines
        d : in std_logic_vector((n-1) downto 0); -- data in
        q : out std_logic_vector((n-1) downto 0); -- data out

        -- operation data lines
        -- 0 (00) : keep previous value
        -- 1 (01) : shift
        -- 2 (10) : load
        -- 3 (11) : clear
        opSel : in std_logic_vector(1 downto 0);

        -- shift direction select
        -- 0 : right shift
        -- 1 : left shift
        shiftL_Rbar : in std_logic;

        -- shift type select
        -- 0 : logical shift
        -- 1 : arithmetic shift
        ariShift_logShiftBar : in std_logic;
        
        clk : in std_logic;
        reset : in std_logic
    );
end entity shiftRegN;

architecture structural of shiftRegN is
    signal int_q : std_logic_vector((n-1) downto 0);
    signal int_shiftMuxOut, int_opMuxOut : std_logic_vector((n-1) downto 0);
    signal int_MSBAriRShiftIn : std_logic;

    component m2to1 is
        port(
                d0, d1, s0 : in std_logic;  -- d0, d1 are data inputs, s0 is select input
                q0 : out std_logic          -- q0 is data output
        );
    end component;

    component m4to1
    port(
        d0, d1, d2, d3, s0, s1 : in std_logic;
        q0 : out std_logic
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

        -- ensure that bit width is >= 2
        assert n >= 2 report "Bit width (n) of shiftRegN must be >= 2" severity failure;

        -- 1 if previous state of MSB was 1 and arithmetic shift is selected
        -- 0 if previous state of MSB was 0 or logical shift is selected
        int_MSBAriRShiftIn <= int_q(n-1) and ariShift_logShiftBar;

        -- Defining components for MSB of register
        shiftMuxMSB: m2to1
        port map(
            d0 => int_MSBAriRShiftIn, -- Rshift input needs computation for MSB
            d1 => int_q(n-2),
            s0 => shiftL_Rbar,
            q0 => int_shiftMuxOut(n-1)
        );

        opMuxMSB : m4to1
        port map(
            d0 => int_q(n-1),
            d1 => int_shiftMuxOut(n-1),
            d2 => d(n-1),
            d3 => '0',
            s0 => opSel(0),
            s1 => opSel(1),
            q0 => int_opMuxOut(n-1)
        );

        rMSB : d_FF_ASR
        port map(
            i_set => '1',
            i_reset => reset,
            i_d => int_opMuxOut(n-1),
            i_clock => clk,
            o_q => int_q(n-1),
            o_qBar => open
        );

        -- Defining components for LSB of register
        shiftMuxLSB: m2to1
        port map(
            d0 => int_q(1),
            d1 => '0', -- Lshift for LSB of register is 0
            s0 => shiftL_Rbar,
            q0 => int_shiftMuxOut(0)
        );
 
        opMuxLSB : m4to1
        port map(
            d0 => int_q(0),
            d1 => int_shiftMuxOut(0),
            d2 => d(0),
            d3 => '0',
            s0 => opSel(0),
            s1 => opSel(1),
            q0 => int_opMuxOut(0)
        );
 
        rLSB : d_FF_ASR
        port map(
            i_set => '1',
            i_reset => reset,
            i_d => int_opMuxOut(0),
            i_clock => clk,
            o_q => int_q(0),
            o_qBar => open
        );

        -- Defining components for bits between MSB and LSB of register
        -- Using loop bounds i = 2 to n-1 to cover middle bits (bit index = n - i)
        -- This allows n = 2 to be valid, because i = 2 to 1 is a legal empty loop
        -- A loop from i = 1 to n-2 would be invalid when n = 2 (i = 1 to 0 is illegal in VHDL)
        for i in 2 to n-1 generate
            shiftMuxi : m2to1
            port map(
                d0 => int_q((n-i)+1), -- rshift gets input from register to left
                d1 => int_q((n-i)-1), -- lshift gets input from register to right
                s0 => shiftL_Rbar,
                q0 => int_shiftMuxOut(n-i)
            );

            opMuxi : m4to1
            port map(
                d0 => int_q(n-i), -- input is current bit's previous output for keep previous value
                d1 => int_shiftMuxOut(n-i),
                d2 => d(n-i),
                d3 => '0',
                s0 => opSel(0),
                s1 => opSel(1),
                q0 => int_opMuxOut(n-i)
            );

            ri : d_FF_ASR
            port map(
                i_set => '1',
                i_reset => reset,
                i_d => int_opMuxOut(n-i),
                i_clock => clk,
                o_q => int_q(n-i),
                o_qBar => open
            );
        end generate;

        q <= int_q;

end architecture structural;