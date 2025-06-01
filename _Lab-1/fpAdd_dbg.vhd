library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity fpAdd_dbg is
    Port (
        -- global control
        clk, reset : in std_logic;

        -- data inputs
        signA, signB : in std_logic;
        exponentA, exponentB : in std_logic_vector(6 downto 0);
        mantissaA, mantissaB : in std_logic_vector(7 downto 0);

        -- data outputs
        signResult : out std_logic;
        exponentResult : out std_logic_vector(6 downto 0);
        mantissaResult : out std_logic_vector(7 downto 0);
        overflow : out std_logic;

        -- debug outputs
        db_state : out std_logic_vector(20 downto 0);
        db_dFFin : out std_logic_vector(20 downto 0);
        db_aState : out std_logic_vector(5 downto 0);
        db_aDFFin : out std_logic_vector(5 downto 0);
        db_expA  : out std_logic_vector(7 downto 0);
        db_expB  : out std_logic_vector(7 downto 0);
        db_expDif : out std_logic_vector(7 downto 0);
        db_sgfdA : out std_logic_vector(31 downto 0);
        db_sgfdB : out std_logic_vector(31 downto 0);
        db_shiftReg : out std_logic_vector(31 downto 0);

        -- debug status signals
        db_ss_signAStored        : out std_logic;
        db_ss_signAeqB           : out std_logic;
        db_ss_expAeqB, db_ss_expAltB : out std_logic;
        db_ss_sgfdAeqB, db_ss_sgfdAltB : out std_logic;
        db_ss_shiftCountltExpDif : out std_logic;
        db_ss_alu32bCout         : out std_logic;
        db_ss_roundUp            : out std_logic;
        db_ss_shiftRegMSB : out std_logic;
        db_ss_shiftReg2ndMSB : out std_logic;

        -- debug outputs for intermediate control path signals
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
end fpAdd_dbg;

architecture Structural of fpAdd_dbg is

    -- Control signals
    signal loadSignA, loadExpA, loadSgfdA : std_logic;
    signal loadSignB, loadExpB, loadSgfdB : std_logic;
    signal selLdSgfdAShR, selLdSgfdBShR, selLdManResClr : std_logic;
    signal selAlu8bX, selAlu8bY, selAlu32bX, selAlu32bY : std_logic_vector(1 downto 0);
    signal selLdShR, selLdExpRes : std_logic_vector(1 downto 0);
    signal LSShR, RSShR, loadShR : std_logic;
    signal loadExpDif, loadShiftCount, loadSignRes : std_logic;
    signal loadExpRes, loadManRes : std_logic;
    signal clrSignRes, setSignRes, setOverflow : std_logic;
    signal alu8bAddBarSub, alu32bAddBarSub : std_logic;

    -- Status signals
    signal signAStored, signAeqB : std_logic;
    signal expAeqB, expAltB : std_logic;
    signal sgfdAeqB, sgfdAltB : std_logic;
    signal shiftCountltExpDif : std_logic;
    signal alu32bCout, roundUp : std_logic;
    signal shiftRegMSB, shiftReg2ndMSB : std_logic;

    -- internal debug signals from control path
    signal is_alignShifted : std_logic;
    signal is_bAligned     : std_logic;
    signal is_aAligned     : std_logic;
    signal is_alignDone    : std_logic;
    signal is_sameValSub   : std_logic;
    signal is_nmrlRSCheck  : std_logic;
    signal is_sgfdSub      : std_logic;
    signal is_BsubANRes    : std_logic;
    signal is_AsubBPRes    : std_logic;
    signal is_BsubAPres    : std_logic;
    signal is_AsubBNres    : std_logic;
    signal is_nmrlLSCheck  : std_logic;
    signal is_roundCheck   : std_logic;


    component fpAddCP is
        port(
            clock, reset : in std_logic;

            loadSignA, loadExpA, loadSgfdA, loadSignB, loadExpB, loadSgfdB : out std_logic;
            selLdSgfdAShR, selLdSgfdBShR, selLdManResClr : out std_logic;
            selAlu8bX, selAlu8bY, selAlu32bX, selAlu32bY, selLdShR, selLdExpRes : out std_logic_vector(1 downto 0);
            LSShR, RSShR, loadShR : out std_logic;
            loadExpDif, loadShiftCount, loadSignRes, loadExpRes, loadManRes : out std_logic;
            clrSignRes, setSignRes, setOverflow : out std_logic;
            alu8bAddBarSub, alu32bAddBarSub : out std_logic;

            signAStored : in std_logic;
            signAeqB : in std_logic;
            expAeqB, expAltB : in std_logic;
            sgfdAeqB, sgfdAltB : in std_logic;
            shiftCountltExpDif : in std_logic;
            alu32bCout, roundUp : in std_logic;
            shiftRegMSB, shiftReg2ndMSB : in std_logic;

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
    end component;

    component fpAddDP is
        port(
            signA, signB : in std_logic;
            exponentA, exponentB : in std_logic_vector(6 downto 0);
            mantissaA, mantissaB : in std_logic_vector(7 downto 0);

            signResult : out std_logic;
            exponentResult : out std_logic_vector(6 downto 0);
            mantissaResult : out std_logic_vector(7 downto 0);
            overflow : out std_logic;

            loadSignA, loadExpA, loadSgfdA, loadSignB, loadExpB, loadSgfdB : in std_logic;
            selLdSgfdAShR, selLdSgfdBShR, selLdManResClr : in std_logic;
            selAlu8bX, selAlu8bY, selAlu32bX, selAlu32bY, selLdShR, selLdExpRes : in std_logic_vector(1 downto 0);
            LSShR, RSShR, loadShR : in std_logic;
            loadExpDif, loadShiftCount, loadSignRes, loadExpRes, loadManRes : in std_logic;
            clrSignRes, setSignRes, setOverflow : in std_logic;
            alu8bAddBarSub, alu32bAddBarSub : in std_logic;

            signAStored : out std_logic;
            signAeqB : out std_logic;
            expAeqB, expAltB : out std_logic;
            sgfdAeqB, sgfdAltB : out std_logic;
            shiftCountltExpDif : out std_logic;
            alu32bCout, roundUp : out std_logic;
            shiftRegMSB, shiftReg2ndMSB : out std_logic;

            db_expA, db_expB, db_expDif : out std_logic_vector(7 downto 0);
            db_sgfdA, db_sgfdB, db_shiftReg : out std_logic_vector(31 downto 0);

            clk, reset : in std_logic
        );
    end component;

begin

    -- debug status signals
    db_ss_signAStored        <= signAStored;
    db_ss_signAeqB           <= signAeqB;
    db_ss_expAeqB            <= expAeqB;
    db_ss_expAltB            <= expAltB;
    db_ss_sgfdAeqB           <= sgfdAeqB;
    db_ss_sgfdAltB           <= sgfdAltB;
    db_ss_shiftCountltExpDif <= shiftCountltExpDif;
    db_ss_alu32bCout         <= alu32bCout;
    db_ss_roundUp            <= roundUp;
    db_ss_shiftRegMSB <= shiftRegMSB;
    db_ss_shiftReg2ndMSB <= shiftReg2ndMSB;

    db_is_alignShifted <= is_alignShifted;
    db_is_bAligned     <= is_bAligned;
    db_is_aAligned     <= is_aAligned;
    db_is_alignDone    <= is_alignDone;
    db_is_sameValSub   <= is_sameValSub;
    db_is_nmrlRSCheck  <= is_nmrlRSCheck;
    db_is_sgfdSub      <= is_sgfdSub;
    db_is_BsubANRes    <= is_BsubANRes;
    db_is_AsubBPRes    <= is_AsubBPRes;
    db_is_BsubAPres    <= is_BsubAPres;
    db_is_AsubBNres    <= is_AsubBNres;
    db_is_nmrlLSCheck  <= is_nmrlLSCheck;
    db_is_roundCheck   <= is_roundCheck;

    controlP: fpAddCP
        port map (
            clock        => clk,
            reset        => reset,

            loadSignA    => loadSignA,
            loadExpA     => loadExpA,
            loadSgfdA    => loadSgfdA,
            loadSignB    => loadSignB,
            loadExpB     => loadExpB,
            loadSgfdB    => loadSgfdB,
            selLdSgfdAShR => selLdSgfdAShR,
            selLdSgfdBShR => selLdSgfdBShR,
            selLdManResClr => selLdManResClr,
            selAlu8bX    => selAlu8bX,
            selAlu8bY    => selAlu8bY,
            selAlu32bX   => selAlu32bX,
            selAlu32bY   => selAlu32bY,
            selLdShR     => selLdShR,
            selLdExpRes  => selLdExpRes,
            LSShR        => LSShR,
            RSShR        => RSShR,
            loadShR      => loadShR,
            loadExpDif   => loadExpDif,
            loadShiftCount => loadShiftCount,
            loadSignRes  => loadSignRes,
            loadExpRes   => loadExpRes,
            loadManRes   => loadManRes,
            clrSignRes   => clrSignRes,
            setSignRes   => setSignRes,
            setOverflow  => setOverflow,
            alu8bAddBarSub => alu8bAddBarSub,
            alu32bAddBarSub => alu32bAddBarSub,

            signAStored  => signAStored,
            signAeqB     => signAeqB,
            expAeqB      => expAeqB,
            expAltB      => expAltB,
            sgfdAeqB     => sgfdAeqB,
            sgfdAltB     => sgfdAltB,
            shiftCountltExpDif => shiftCountltExpDif,
            alu32bCout   => alu32bCout,
            roundUp      => roundUp,
            shiftRegMSB  => shiftRegMSB,
            shiftReg2ndMSB => shiftReg2ndMSB,

            db_state     => db_state,
            db_dFFin     => db_dFFin,
            db_aState    => db_aState,
            db_aDFFin    => db_aDFFin,

            -- intermediate signal debug outputs
            db_is_alignShifted => is_alignShifted,
            db_is_bAligned     => is_bAligned,
            db_is_aAligned     => is_aAligned,
            db_is_alignDone    => is_alignDone,
            db_is_sameValSub   => is_sameValSub,
            db_is_nmrlRSCheck  => is_nmrlRSCheck,
            db_is_sgfdSub      => is_sgfdSub,
            db_is_BsubANRes    => is_BsubANRes,
            db_is_AsubBPRes    => is_AsubBPRes,
            db_is_BsubAPres    => is_BsubAPres,
            db_is_AsubBNres    => is_AsubBNres,
            db_is_nmrlLSCheck  => is_nmrlLSCheck,
            db_is_roundCheck   => is_roundCheck
        );

    dataP: fpAddDP
        port map (
            signA        => signA,
            signB        => signB,
            exponentA    => exponentA,
            exponentB    => exponentB,
            mantissaA    => mantissaA,
            mantissaB    => mantissaB,
            signResult   => signResult,
            exponentResult => exponentResult,
            mantissaResult => mantissaResult,
            overflow     => overflow,

            loadSignA    => loadSignA,
            loadExpA     => loadExpA,
            loadSgfdA    => loadSgfdA,
            loadSignB    => loadSignB,
            loadExpB     => loadExpB,
            loadSgfdB    => loadSgfdB,
            selLdSgfdAShR => selLdSgfdAShR,
            selLdSgfdBShR => selLdSgfdBShR,
            selLdManResClr => selLdManResClr,
            selAlu8bX    => selAlu8bX,
            selAlu8bY    => selAlu8bY,
            selAlu32bX   => selAlu32bX,
            selAlu32bY   => selAlu32bY,
            selLdShR     => selLdShR,
            selLdExpRes  => selLdExpRes,
            LSShR        => LSShR,
            RSShR        => RSShR,
            loadShR      => loadShR,
            loadExpDif   => loadExpDif,
            loadShiftCount => loadShiftCount,
            loadSignRes  => loadSignRes,
            loadExpRes   => loadExpRes,
            loadManRes   => loadManRes,
            clrSignRes   => clrSignRes,
            setSignRes   => setSignRes,
            setOverflow  => setOverflow,
            alu8bAddBarSub => alu8bAddBarSub,
            alu32bAddBarSub => alu32bAddBarSub,

            signAStored  => signAStored,
            signAeqB     => signAeqB,
            expAeqB      => expAeqB,
            expAltB      => expAltB,
            sgfdAeqB     => sgfdAeqB,
            sgfdAltB     => sgfdAltB,
            shiftCountltExpDif => shiftCountltExpDif,
            alu32bCout   => alu32bCout,
            roundUp      => roundUp,
            shiftRegMSB  => shiftRegMSB,
            shiftReg2ndMSB => shiftReg2ndMSB,

            db_expA      => db_expA,
            db_expB      => db_expB,
            db_expDif    => db_expDif,
            db_sgfdA     => db_sgfdA,
            db_sgfdB     => db_sgfdB,
            db_shiftReg  => db_shiftReg,

            clk          => clk,
            reset        => reset
        );

end Structural;
