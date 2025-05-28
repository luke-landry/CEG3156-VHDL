LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- Full adder
entity fpMultDP is
    port(
        gClock, gReset : in std_logic;
        signA, signB : in std_logic;
        mantissaA, mantissaB : in std_logic_vector(7 downto 0);
        exponentA, exponentB : in std_logic_vector(6 downto 0);

        signOut, overFlow : out std_logic;
        mantissaOut : out std_logic_vector(7 downto 0);
        exponentOut : out std_logic_vector(6 downto 0);

        lA, lB, lEA, lEB, lMA, lMB, m50, m00, lMR, slMR, m1, clr, lSO, lEO, addbar_sub, lMO, m01 : in std_logic;
        eq0, eq1, eq2, rORs, v : out std_logic
    );
end fpMultDP;

architecture rtl of fpMultDP is
    signal sAQ, sBQ, sOQ, overF : std_logic;
    signal lAQ, lBQ, mAQ, mbQ, add0Out, add1Out, lEOQ, lMOQ : std_logic_vector(7 downto 0);
    signal mux5Q, mux0Q, mux1Q : std_logic_vector(7 downto 0);
    signal mult9Q, reg18Q : std_logic_vector(17 downto 0);
    signal shiftSel : std_logic_vector(1 downto 0);
    
    component d_FF_ASR IS
        port(
                i_set, i_reset : IN STD_LOGIC;
                i_d : IN STD_LOGIC;
                i_clock : IN STD_LOGIC;
                o_q, o_qBar : OUT STD_LOGIC
            );
    end component;

    component regNASR is
        generic(
            n : integer 
        );
        port ( 
                d : in std_logic_vector(n-1 downto 0); -- n bit input vector
                clk, load, reset : in std_logic;
                q : out std_logic_vector(n-1 downto 0) -- n bit output vector
            );
    end component;

    component adder8bit is
        port(
            x, y : in std_logic_vector(7 downto 0);
            addbar_sub : in std_logic;
            s : out std_logic_vector(7 downto 0); 
            cOut : out std_logic
        );
    end component;

    component m8x4to1 is
        port (
            d0, d1, d2, d3 : in std_logic_vector(7 downto 0);   -- d0, d1, d2, d3 are 8 bit data inputs
            s0, s1 : in std_logic;                              -- s0, s1 are select inputs
            q : out std_logic_vector(7 downto 0)                -- q0 is 8 bit data output         
        );
    end component;

    component m8x2to1 is
        port (
            d0, d1 : in std_logic_vector(7 downto 0);   -- d0, d1 are 8 bit data inputs
            s0 : in std_logic;                          -- s0 is the select input
            q : out std_logic_vector(7 downto 0)        -- q0 is 8 bit data output         
        );
    end component;

    component shiftRegN is
        generic(
            n : integer -- n should be >= 2
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

    component comp1bit is
        port(
            x, y : in std_logic;
            equal, lesser, greater : out std_logic 
        );
    end component;

begin

    signAReg : d_FF_ASR
    port map(
        i_set => '1', 
        i_reset => gReset,
        i_d => signA,
        i_clock => gClock,
        o_q => sAQ, 
        o_qBar => open
    );

    signBReg : d_FF_ASR
    port map(
        i_set => '1', 
        i_reset => gReset,
        i_d => signB,
        i_clock => gClock,
        o_q => sBQ, 
        o_qBar => open
    );

    sOQ <= sAQ xor sBQ;

    signOReg : d_FF_ASR
    port map(
        i_set => '1', 
        i_reset => gReset,
        i_d => sOQ,
        i_clock => gClock,
        o_q => signOut, 
        o_qBar => open
    );

    expAReg : regNASR
    generic map(
        n => 8
    )
    port map(
        d => '0' & exponentA,
        clk => gClock,
        load => lEA,
        reset => gReset,
        q => lAQ
    );

    expBReg : regNASR
    generic map(
        n => 8
    )
    port map(
        d => '0' & exponentA,
        clk => gClock,
        load => lEB,
        reset => gReset,
        q => lBQ
    );

    manAReg : regNASR
    generic map(
        n => 8
    )
    port map(
        d => mantissaA,
        clk => gClock,
        load => lMA,
        reset => gReset,
        q => mAQ
    );

    manBReg : regNASR
    generic map(
        n => 8
    )
    port map(
        d => mantissaB,
        clk => gClock,
        load => lMB,
        reset => gReset,
        q => mBQ
    );

    shiftSel(1) <= slMR;
    shiftSel(0) <= lMR;
    reg18 : shiftRegN
    generic map(
        n => 18
    )
    port map(
        d => mult9Q,
        q => reg18Q,
        opSel => shiftSel,
        shiftL_Rbar => '1',
        ariShift_logShiftBar => '0',
        clk => gClock,
        reset => gReset
    );

    expOut : regNASR
    generic map(
        n => 8
    )
    port map(
        d => add0Out,
        clk => gClock,
        load => lEO,
        reset => gReset,
        q => lEOQ
    );

    manOut : regNASR
    generic map(
        n => 8
    )
    port map(
        d => mux1Q,
        clk => gClock,
        load => lMO,
        reset => gReset or clr,
        q => lMOQ
    );

    adder0 : adder8bit
    port map(
        x => mux5Q,
        y => mux0Q,
        addbar_sub => addbar_sub,
        s => add0Out,
        cOut => open
    );

    adder1 : adder8bit
    port map(
        x => lMOQ,
        y => "00000001",
        addbar_sub => '0',
        s => add1Out,
        cOut => overF
    );

    mux2_0 : m8x2to1
    port map(
        d0 => lEOQ,
        d1 => lAQ,
        s0 => m50,
        q => mux5Q
    );

    mux2_1 : m8x2to1
    port map(
        d0 => reg18Q(16 downto 9),
        d1 => add1Out,
        s0 => m1,
        q => mux1Q
    );

    mux4 : m8x4to1
    port map(
        d0 => lBQ,
        d1 => "00111111",
        d2 => "00000001",
        d3 => "00000000",
        s0 => m00,
        s1 => m01,
        q => mux0Q
    );

    comp0 : comp1bit
    port map(
        x => '1',
        y => reg18Q(17),
        equal => eq0,
        lesser => open,
        greater => open
    );

    comp1 : comp1bit
    port map(
        x => '0',
        y => reg18Q(8),
        equal => eq1,
        lesser => open,
        greater => open
    );

    comp2 : comp1bit
    port map(
        x => '1',
        y => reg18Q(8),
        equal => eq2,
        lesser => open,
        greater => open
    );

    rORs <= reg18Q(7) or reg18Q(6) or reg18Q(5) or reg18Q(4) or reg18Q(3) or reg18Q(2) or reg18Q(1) or reg18Q(0);

    v <= overF;
    -- overFlow <= overF;
    overFlow <= '0';
    exponentOut <= lEOQ(6 downto 0);
    mantissaOut <= lMOQ;

end architecture rtl;
