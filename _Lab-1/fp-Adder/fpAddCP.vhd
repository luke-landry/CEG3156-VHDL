library ieee;
use ieee.std_logic_1164.all;

entity fpAddCP is
    port(
        clock, reset : in std_logic;

        -- control signals
        loadSignA, loadExpA, loadSgfdA, loadSignB, loadExpB, loadSgfdB : out std_logic;
        selLdSgfdAShR, selLdSgfdBShR, selLdManResClr : out std_logic;
        selAlu8bX, selAlu8bY, selAlu32bX, selAlu32bY, selLdShR, selLdExpRes : out std_logic_vector(1 downto 0);
        LSShR, RSShR, loadShR : out std_logic;
        loadExpDif, loadShiftCount, loadSignRes, loadExpRes, loadManRes : out std_logic;
        clrSignRes, setSignRes, setOverflow : out std_logic;
        alu8bAddBarSub, alu32bAddBarSub : out std_logic;

        -- status signals
        signAStored : in std_logic;
        signAeqB : in std_logic;
        expAeqB, expAltB : in std_logic;
        sgfdAeqB, sgfdAltB : in std_logic;
        shiftCountltExpDif : in std_logic;
        alu32bCout, roundUp : in std_logic;
        shiftRegMSB, shiftReg2ndMSB : in std_logic;
        
        -- debug outputs
        db_state : out std_logic_vector(20 downto 0);
        db_dFFin : out std_logic_vector(20 downto 0);
        db_aState : out std_logic_vector(5 downto 0);
        db_aDFFin : out std_logic_vector(5 downto 0);

        -- debug outputs for intermediate signals
        db_is_alignShifted : out std_logic;
        db_is_bAligned     : out std_logic;
        db_is_aAligned     : out std_logic;
        db_is_alignDone    : out std_logic;
        db_is_sameValSub   : out std_logic;
        db_is_nmrlRSCheck  : out std_logic;
        db_is_sgfdSub      : out std_logic;
        db_is_BsubANRes    : out std_logic;
        db_is_AsubBPRes    : out std_logic;
        db_is_BsubAPres    : out std_logic;
        db_is_AsubBNres    : out std_logic;
        db_is_nmrlLSCheck  : out std_logic;
        db_is_roundCheck   : out std_logic

    );
end fpAddCP;

architecture rtl of fpAddCP is

    component d_FF_ASR IS
        port(
                i_set, i_reset : IN STD_LOGIC;
                i_d : IN STD_LOGIC;
                i_clock : IN STD_LOGIC;
                o_q, o_qBar : OUT STD_LOGIC
            );
    end component;

    constant num_states : integer := 21;
    constant num_additional_states : integer := 6;

    -- flip flop input (d) and state (s) signals
    signal d : std_logic_vector((num_states-1) downto 0);
    signal s : std_logic_vector((num_states-1) downto 0);

    -- additional states (added after initial design)
    signal ad : std_logic_vector((num_additional_states-1) downto 0);
    signal as : std_logic_vector((num_additional_states-1) downto 0);

    -- intermediate signals
    signal s_alignShifted, s_bAligned, s_aAligned, s_alignDone : std_logic;
    signal s_sameValSub, s_nmrlRSCheck, s_sgfdSub : std_logic;
    signal s_BsubANRes, s_AsubBPRes, s_BsubAPres, s_AsubBNres : std_logic;
    signal s_nmrlLSCheck, s_roundCheck : std_logic;

begin

    -- initial state
    dff_s0 : d_FF_ASR
    port map(
        i_set => reset, -- set initial state on system reset
        i_reset => '1',
        i_d => d(0),
        i_clock => clock,
        o_q => s(0),
        o_qBar => open
    );

    genDFFs : for i in 1 to (num_states-1) generate
        dff_si : d_FF_ASR
        port map(
            i_set => '1', 
            i_reset => reset,
            i_d => d(i),
            i_clock => clock,
            o_q => s(i),
            o_qBar => open
        );
    end generate;

    genDFFas: for i in 0 to (num_additional_states-1) generate
        dff_ai : d_FF_ASR
        port map(
            i_set => '1', 
            i_reset => reset,
            i_d => ad(i),
            i_clock => clock,
            o_q => as(i),
            o_qBar => open
        );
    end generate;

    s_alignShifted <= (s(2) or s(4) or s(6)) and (not shiftCountltExpDif);
    s_bAligned <= s_alignShifted and (not expAltB);
    s_aAligned <= s_alignShifted and expAltB;
    s_alignDone <= as(0) or s(7) or s(8);
    s_sameValSub <= s_alignDone and (not signAeqB) and sgfdAeqB;
    s_nmrlRSCheck <= as(1);
    s_sgfdSub <= as(4) and (not sgfdAeqB);
    s_BsubANRes <= s_sgfdSub and (not signAStored) and sgfdAltB;
    s_AsubBPRes <= s_sgfdSub and (not signAStored) and (not sgfdAltB);
    s_BsubAPres <= s_sgfdSub and signAStored and sgfdAltB;
    s_AsubBNres <= s_sgfdSub and signAStored and (not sgfdAltB);
    s_nmrlLSCheck <= as(5) or s(18);
    s_roundCheck <= as(2);

    d(0) <= '0';
    d(1) <= as(3) and (not expAeqB);
    d(2) <= s(1) and (not expAltB);
    d(3) <= s(1) and expAltB;
    d(4) <= s(3);
    d(5) <= (s(2) or s(4) or s(6)) and shiftCountltExpDif; 
    d(6) <= s(5);
    d(7) <= s_bAligned; 
    d(8) <= s_aAligned;
    d(9) <= s_sameValSub;
    d(10) <= s_alignDone and signAeqB;
    d(11) <= s(10) and alu32bCout;
    d(12) <= s_nmrlRSCheck and shiftRegMSB;
    d(13) <= s_BsubANRes;
    d(14) <= s_AsubBPRes;
    d(15) <= s_BsubAPres;
    d(16) <= s_AsubBNres;
    d(17) <= s_nmrlLSCheck and (not shiftReg2ndMSB);
    d(18) <= s(17);
    d(19) <= s_roundCheck and roundUp;
    d(20) <= s_roundCheck and (not roundUp);

    ad(0) <= as(3) and expAeqB;
    ad(1) <= (s(10) and (not alu32bCout)) or s(19);
    ad(2) <= (s_nmrlRSCheck and (not shiftRegMSB)) or s(12) or (s_nmrlLSCheck and shiftReg2ndMSB);
    ad(3) <= s(0);
    ad(4) <= s_alignDone and (not signAeqB);
    ad(5) <= s(13) or s(14) or s(15) or s(16);

    loadSignA <= s(0);
    loadExpA <=  s(0);
    loadSgfdA <= s(0) or s(8);
    loadSignB <= s(0);
    loadExpB <=  s(0);
    loadSgfdB <= s(0) or s(7);
    selLdSgfdAShR <= s(8);
    selLdSgfdBShR <= s(7)  ;
    selLdManResClr <= s(9);
    selAlu8bX(0) <= s(3) or s(12) or s(18);
    selAlu8bX(1) <= s(3) or s(5);
    selAlu8bY(0) <= s(5) or s(12) or s(18);
    selAlu8bY(1) <= s(3) or s(5) or s(12) or s(18);
    selAlu32bX(0) <= s(13) or s(15);
    selAlu32bX(1) <= s(19);
    selAlu32bY(0) <= s(10) or s(14) or s(16);
    selAlu32bY(1) <= s(19); 
    selLdShR(0) <= s(2);
    selLdShR(1) <= s(10) or s(13) or s(14) or s(15) or s(16) or s(19);
    selLdExpRes(0) <= s(4) or s(9);
    selLdExpRes(1) <= s(9) or s(12) or s(18);
    LSShR <= s(17);
    RSShR <= s(6) or s(12);
    loadShR <= s(2) or s(4) or s(10) or s(13) or s(14) or s(15) or s(16) or s(19);
    loadExpDif <= s(1) or s(3);
    loadShiftCount <= s(5);
    loadSignRes <= s(10);
    loadExpRes <= as(0) or s(2) or s(4) or s(9) or s(12) or s(18);
    loadManRes <= s(9) or s(20);
    clrSignRes <= s(9) or s(14) or s(15);
    setSignRes <= s(13) or s(16);
    setOverflow <= s(11);
    alu8bAddBarSub <= s(1) or s(3) or s(18);
    alu32bAddBarSub <= s(13) or s(14) or s(15) or s(16);

    -- debug outputs
    db_state <= s;
    db_dFFin <= d;
    db_aState <= as;
    db_aDFFin <= ad;

    db_is_alignShifted <= s_alignShifted;
    db_is_bAligned     <= s_bAligned;
    db_is_aAligned     <= s_aAligned;
    db_is_alignDone    <= s_alignDone;
    db_is_sameValSub   <= s_sameValSub;
    db_is_nmrlRSCheck  <= s_nmrlRSCheck;
    db_is_sgfdSub      <= s_sgfdSub;
    db_is_BsubANRes    <= s_BsubANRes;
    db_is_AsubBPRes    <= s_AsubBPRes;
    db_is_BsubAPres    <= s_BsubAPres;
    db_is_AsubBNres    <= s_AsubBNres;
    db_is_nmrlLSCheck  <= s_nmrlLSCheck;
    db_is_roundCheck   <= s_roundCheck;

end architecture rtl;
