library ieee;
use ieee.std_logic_1164.ALL;

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
        overflow : out std_logic;

        -- control signals
        loadSignA, loadExpA, loadSgfdA, loadSignB, loadExpB, loadSgfdB : in std_logic;
        selLdSgfdAShR, selLdSgfdBShR, selLdManResClr : in std_logic;
        selAlu8bX, selAlu8bY, selAlu32bX, selAlu32bY, selLdShR, selLdExpRes : in std_logic_vector(1 downto 0);
        LSShR, RSShR, loadShR : in std_logic;
        loadExpDif, loadShiftCount, loadSignRes, loadExpRes, loadManRes : in std_logic;
        clrSignRes, setSignRes, setOverflow : in std_logic;
        alu8bAddBarSub, alu32bAddBarSub : in std_logic;

        -- status signals
        signAStored : out std_logic;
        signAeqB : out std_logic;
        expAeqB, expAltB : out std_logic;
        sgfdAeqB, sgfdAltB : out std_logic;
        shiftCountltExpDif : out std_logic;
        alu32bCout, roundUp : out std_logic;
        shiftRegMSB, shiftReg2ndMSB : out std_logic;

        -- debug outputs
        db_expA, db_expB, db_expDif : out std_logic_vector(7 downto 0);
        db_sgfdA, db_sgfdB : out std_logic_vector(31 downto 0);

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
    component m8x2to1
        port(
            d0, d1 : in std_logic_vector(7 downto 0);   -- d0, d1 are 8 bit data inputs
            s0 : in std_logic;                          -- s0 is the select input
            q : out std_logic_vector(7 downto 0)        -- q0 is 8 bit data output     
        );
    end component;

    component m8x4to1
        port(
            d0, d1, d2, d3 : in std_logic_vector(7 downto 0);   -- d0, d1, d2, d3 are 8 bit data inputs
            s0, s1 : in std_logic;                              -- s0, s1 are select inputs
            q : out std_logic_vector(7 downto 0)                -- q0 is 8 bit data output   
        );
    end component;

    component m32x2to1
        port(
            d0, d1 : in std_logic_vector(31 downto 0);  -- Two 32-bit inputs
            s0 : in std_logic;                     -- 1-bit select
            q : out std_logic_vector(31 downto 0) -- 32-bit output
        );
    end component;

    component m32x4to1
        port(
            d0, d1, d2, d3 : in std_logic_vector(31 downto 0);  -- Four 32-bit inputs
            s0, s1         : in std_logic;                     -- 2-bit select
            q              : out std_logic_vector(31 downto 0) -- 32-bit output
        );
    end component;

    ---- comparators

    component comp1bit
        port(
            x, y : in std_logic;
            equal, lesser, greater : out std_logic 
        );
    end component;

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

    -- Or

    component orNbit
        generic(
            n : integer
        );
        port(
            d : in std_logic_vector((n-1) downto 0);
            q : out std_logic
        );
    end component;

    -- Data widths for exponent and significand components within the datapath
    constant expWidth : integer := 8;
    constant manWidth : integer := 8;
    constant sgfdWidth : integer := 32;

    -- Value to add at guard bit position in round-up increment
    constant b22Set_32b : std_logic_vector(31 downto 0) := "00000000010000000000000000000000";

    -- Signals
    signal s_signA, s_signB : std_logic;
    signal s_expA, s_expB, s_expDif, s_expRes, s_alu8b : std_logic_vector((expWidth-1) downto 0);
    signal s_sgfdA, s_sgfdB, s_shiftReg, s_alu32b : std_logic_vector((sgfdWidth-1) downto 0);
    signal s_guardBit, s_roundBit, s_stickyBit : std_logic;
    signal s_muxSgfdA, s_muxSgfdB, s_muxAlu32bX, s_muxAlu32bY, s_muxShR : std_logic_vector((sgfdWidth-1) downto 0);
    signal s_muxAlu8bX, s_muxAlu8bY, s_muxExpRes, s_muxManRes : std_logic_vector((expWidth-1) downto 0);
    signal s_shiftRegOpSel : std_logic_vector(1 downto 0);
    signal s_shiftRegShiftL_RBar : std_logic;
    signal s_shiftCount : std_logic_vector(7 downto 0);

begin

    -- Operand storage

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
    signAStored <= s_signA;

    regExpA : regNASR
    generic map(
        n => expWidth
    )
    port map(
        d => '0' & exponentA,
        clk => clk,
        load => loadExpA,
        reset => reset,
        q => s_expA
    );

    muxSgfdA : m32x2to1
    port map(
        d0 => "01" & mantissaA & "0000000000000000000000",
        d1 => s_shiftReg,
        s0 => selLdSgfdAShR,
        q => s_muxSgfdA
    );

    regSgfdA : regNASR
    generic map(
        n => sgfdWidth
    )
    port map(
        d => s_muxSgfdA,
        clk => clk,
        load => loadSgfdA,
        reset => reset,
        q => s_sgfdA
    );

    -- Operand B

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
        n => expWidth
    )
    port map(
        d => '0' & exponentB,
        clk => clk,
        load => loadExpB,
        reset => reset,
        q => s_expB
    );

    muxSgfdB : m32x2to1
    port map(
        d0 => "01" & mantissaB & "0000000000000000000000",
        d1 => s_shiftReg,
        s0 => selLdSgfdBShR,
        q => s_muxSgfdB
    );

    regSgfdB : regNASR
    generic map(
        n => sgfdWidth
    )
    port map(
        d => s_muxSgfdB,
        clk => clk,
        load => loadSgfdB,
        reset => reset,
        q => s_sgfdB
    );

    -- Operand comparators 

    compSign : comp1bit
    port map(
        x => s_signA,
        y => s_signB,
        equal => signAeqB,
        lesser => open,
        greater => open
    );

    compExp : compNbit
    generic map(
        n => expWidth
    )
    port map(
        a => s_expA,
        b => s_expB,
        altb => expAltB, 
        aeqb => expAeqB, 
        agtb => open
    );

    compSgfd : compNbit
    generic map(
        n => sgfdWidth
    )
    port map(
        a => s_sgfdA,
        b => s_sgfdB,
        altb => sgfdAltB, 
        aeqb => sgfdAeqB, 
        agtb => open
    );

    -- 8 bit ALU

    muxAlu8bX : m8x4to1
    port map(
        d0 => s_expA,
        d1 => s_expRes,
        d2 => s_shiftCount,
        d3 => "00000000",
        s0 => selAlu8bX(0),
        s1 => selAlu8bX(1),
        q => s_muxAlu8bX
    );

    muxAlu8bY : m8x4to1
    port map(
        d0 => s_expB,
        d1 => s_expRes,
        d2 => s_expDif,
        d3 => "00000001",
        s0 => selAlu8bY(0),
        s1 => selAlu8bY(1),
        q => s_muxAlu8bY
    );

    alu8b : aluNbit
    generic map(
        n => expWidth
    )
    port map(
        a => s_muxAlu8bX,
        b => s_muxAlu8bY,
        addbar_sub => alu8bAddBarSub,
        result => s_alu8b,
        cOut => open,
        zero => open
    );

    -- 32 bit ALU

    muxAlu32bX : m32x4to1
    port map(
        d0 => s_sgfdA,
        d1 => s_sgfdB,
        d2 => s_shiftReg,
        d3 => s_shiftReg,
        s0 => selAlu32bX(0),
        s1 => selAlu32bX(1),
        q => s_muxAlu32bX
    );

    muxAlu32bY : m32x4to1
    port map(
        d0 => s_sgfdA,
        d1 => s_sgfdB,
        d2 => b22Set_32b,
        d3 => b22Set_32b,
        s0 => selAlu32bY(0),
        s1 => selAlu32bY(1),
        q => s_muxAlu32bY
    );

    alu32b : aluNbit
    generic map(
        n => sgfdWidth
    )
    port map(
        a => s_muxAlu32bX,
        b => s_muxAlu32bY,
        addbar_sub => alu32bAddBarSub,
        result => s_alu32b,
        cOut => alu32bCout,
        zero => open
    );

    -- Shift register

    muxShR : m32x4to1
    port map(
        d0 => s_sgfdA,
        d1 => s_sgfdB,
        d2 => s_alu32b,
        d3 => s_alu32b,
        s0 => selLdShR(0),
        s1 => selLdShR(1),
        q => s_muxShR
    );

    -- conversion of simplified logic signals to shift register control signals
    -- LSShR -> logical left shift -> opSel = 01, ShiftL_RBar = 1
    -- RSShR -> logical right shift -> opSel = 01, ShiftL_RBar= 0
    -- loadShr -> load shift register -> opSel = 10
    s_shiftRegShiftL_RBar <= LSShR;
    s_shiftRegOpSel(0) <= (LSShR or RSShR) and (not loadShR);
    s_shiftRegOpSel(1) <= loadShR;

    shiftReg : shiftRegN
    generic map(
        n => sgfdWidth
    )
    port map(
        d => s_muxShR,
        q => s_shiftReg,
        opSel => s_shiftRegOpSel,
        shiftL_Rbar => s_shiftRegShiftL_RBar,
        ariShift_logShiftBar => '0',
        clk => clk,
        reset => reset
    );

    shiftRegMSB <= s_shiftReg(sgfdWidth-1);
    shiftReg2ndMSB <= s_shiftReg(sgfdWidth-2);

    -- Rounding signals
    s_guardbit <= s_shiftReg(22);
    s_roundBit <= s_shiftReg(21);

    stickyOr : orNbit
    generic map(
        n => 21 -- shiftReg bits 20..0
    )
    port map(
        d => s_shiftReg(20 downto 0),
        q => s_stickyBit
    );

    roundUp <= (s_guardBit and s_roundBit) or (s_roundBit and s_stickyBit);

    -- Exponent difference and shift count

    regExpDif : regNASR
    generic map(
        n => expWidth
    )
    port map(
        d => s_alu8b,
        clk => clk,
        load => loadExpDif,
        reset => reset,
        q => s_expDif
    );

    regShiftCount : regNASR
    generic map(
        n => expWidth
    )
    port map(
        d => s_alu8b,
        clk => clk,
        load => loadShiftCount,
        reset => reset,
        q => s_shiftCount
    );

    compExpShift : compNbit
    generic map(
        n => expWidth
    )
    port map(
        a => s_shiftCount,
        b => s_expDif,
        altb => shiftCountltExpDif, 
        aeqb => open, 
        agtb => open
    );

    -- Result storage
    
    regSignRes : flagReg
    port map(
        clk => clk,
        reset => reset,
        d => s_signA,
        syncSet => setSignRes,
        syncReset => clrSignRes,
        load => loadSignRes,
        q => signResult
    );

    muxExpRes : m8x4to1
    port map(
        d0 => s_expA,
        d1 => s_expB,
        d2 => s_alu8b,
        d3 => "00000000",
        s0 => selLdExpRes(0),
        s1 => selLdExpRes(1),
        q => s_muxExpRes
    );

    regExpRes : regNASR
    generic map(
        n => expWidth
    )
    port map(
        d => s_muxExpRes,
        clk => clk,
        load => loadExpRes,
        reset => reset,
        q => s_expRes
    );

    exponentResult <= s_expRes(6 downto 0); -- only 7 bits of exponent

    muxManRes : m8x2to1
    port map(
        d0 => s_shiftReg(29 downto 22), -- 8 bits of mantissa after decimal
        d1 => "00000000",
        s0 => selLdManResClr,
        q => s_muxManRes
    );

    regManRes : regNASR
    generic map(
        n => manWidth -- 8 bit
    )
    port map(
        d => s_muxManRes,
        clk => clk,
        load => loadManRes,
        reset => reset,
        q => mantissaResult
    );

    -- Overflow flag

    regOverflow : flagReg
    port map(
        clk => clk,
        reset => reset,
        d => '0',
        syncSet => setOverflow,
        syncReset => '0',
        load => '0',
        q => overflow
    );

    -- Debug assignments
    db_expA <= s_expA;
    db_expB <= s_expB;
    db_expDif <= s_expDif;
    db_sgfdA <= s_sgfdA;
    db_sgfdB <= s_sgfdB;

end architecture structural;
