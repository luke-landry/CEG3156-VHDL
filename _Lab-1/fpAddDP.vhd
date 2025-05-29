LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- Datapath of floating point adder
entity fpAddDP is
    port(
        -- data inputs
        signA, signB : in std_logic;
        exponentA, exponentB : in std_logic_vector(6 downto 0);
        mantissaA, mantissaB : in std_logic_vector(7 downto 0);

        -- data output
        signResult : out std_logic;
        exponentResult : out std_logic_vector(6 downto 0);
        mantissaResult : out std_logic_vector(7 downto 0);

        -- control signals
        loadSignA, loadExpA, loadSgfdA, loadSignB, loadExpB, loadSgfdB : in std_logic;
        selLdSgfdAShR, selLdSgfdBShR : in std_logic;
        selAlu7bX, selAlu7bY, selAlu24bX, selAlu24bY, selLdShR, selLdExpRes : in std_logic_vector(1 downto 0);
        LSShR, RSShR : in std_logic;
        loadExpDif, loadSignRes, loadExpRes, loadManRes : in std_logic;
        clrSignRes, setSignRes, setOverflow : in std_logic;
        alu7bAddBarSub, alu24bAddBarSub : in std_logic;

        -- status signals
        signAgtB, signAeqB, signAltB : out std_logic;
        expAgtB, expAeqB, expAltB : out std_logic;
        sgfdAgtB, sgfdAeqB, sgfdAltB : out std_logic;
        alu24bCout, roundUp : out std_logic;

        -- global system
        clk, reset : in std_logic
    );
end entity fpAddDP;

architecture structural of fpAddDP is

    -- Components

    ---- registers

    component flagReg
        port (
            clk, reset : in std_logic;
            d, syncSet, syncReset, load : in std_logic;
            q : out std_logic
        );
    end component;

    component regNASR
        generic(
            n : integer
        );
        port (
            d : in std_logic_vector(n-1 downto 0); -- n bit input vector
            clk, load, reset : in std_logic;
            q : out std_logic_vector(n-1 downto 0) -- n bit output vector
        );
    end component;

    component shiftRegN
        generic(
            n : integer
        );
        port(
            d : in std_logic_vector((n-1) downto 0); -- data in
            q : out std_logic_vector((n-1) downto 0); -- data out
            opSel : in std_logic_vector(1 downto 0);
            shiftL_Rbar : in std_logic;
            ariShift_logShiftBar : in std_logic;
            clk : in std_logic;
            reset : in std_logic
        );
    end component;

    ---- multiplexers

    component m2to1
        port(
            d0, d1, s0 : in std_logic;  -- d0, d1 are data inputs, s0 is select input
            q0 : out std_logic          -- q0 is data output
        );
    end component;

    component m4to1
        port(
            d0, d1, d2, d3, s0, s1 : in std_logic;  -- d0, d1, d2, d3 are data inputs, s0, s1 are select inputs
            q0 : out std_logic                      -- q0 is data output
        );
    end component;

    ---- comparator

    component compNbit
        generic(
            n : integer -- must be >= 3
        );
        port(
            a, b : in std_logic_vector((n-1) downto 0);
            altb, aeqb, agtb : out std_logic
        );
    end component;

    ---- ALU

    component aluNbit
        generic(
            n : integer -- must be >= 3
        );
        port(
            a, b : in std_logic_vector((n-1) downto 0);
            addbar_sub : in std_logic;
    
            result : out std_logic_vector((n-1) downto 0);
            cOut, zero : out std_logic
        );
    end component;

    -- Signals
    signal s_signA, s_signB : std_logic;
    signal s_expA, s_expB, s_expDif, s_alu7b : std_logic_vector(7 downto 0);
    signal s_sgfdA, s_sgfdB, s_shiftReg, s_alu24b : std_logic_vector(23 downto 0);
    signal s_guard, s_round, s_sticky : std_logic;
    signal s_muxSgfdA, s_muxSgfdB, s_muxAlu7bX, s_muxAlu7bY, s_muxAlu24bX, s_muxAlu24bY, s_muxShR, s_muxExpRes : std_logic;

begin

    regSignA : flagReg
    port map(
        clk => clk,
        reset => reset,
        d => signA,
        syncSet => '0',
        syncReset => '0',
        load => loadSignA,
        q => s_signA
    );

    regExpA : regNASR
    generic map(
        n => 7
    )
    port map(
        d => exponentA,
        clk => clk,
        load => loadExpA,
        reset => reset,
        q => s_expA
    );

    muxSgfdA : mux2to1
    port map(
        d0 => "01" & mantissaA & "00000000000000",
        d1 => s_shiftReg,
        s0 => selLdSgfdAShR,
        q0 : out std_logic          -- q0 is data output
    );

    regSgfdA : regNASR
    generic map(
        n => 24
    )
    port map(
        d => exponentA,
        clk => clk,
        load => loadExpA,
        reset => reset,
        q => s_expA
    );

    regSignB : flagReg
    port map(
        clk => clk,
        reset => reset,
        d => signB,
        syncSet => '0',
        syncReset => '0',
        load => loadSignB,
        q => s_signB
    );

    regExpB : regNASR
    generic map(
        n => 7
    )
    port map(
        d => exponentB,
        clk => clk,
        load => loadExpB,
        reset => reset,
        q => s_expB
    );

end architecture structural;
