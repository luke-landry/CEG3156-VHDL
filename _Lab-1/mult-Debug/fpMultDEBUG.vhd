library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity fpMultDEBUG is
    Port (
        gClock, gReset : in  std_logic;
        signA, signB : in  std_logic;
        manA, manB : in  std_logic_vector(7 downto 0);
        expA, expB : in std_logic_vector(6 downto 0);
        expOut : out std_logic_vector(6 downto 0);
        manOut : out std_logic_vector(7 downto 0);
        signOut, overFlow : out std_logic;

        stateOut, int_Out : out std_logic_vector(8 downto 0);
        reg18Out : out std_logic_vector(17 downto 0)
    );
end fpMultDEBUG;

architecture Structural of fpMultDEBUG is

    signal lA, lB, lEA, lEB, lMA, lMB, m50, m00, lMR, slMR, m1, clr, lSO, lEO, addbar_sub, lMO, m01 : std_logic;
    signal eq0, eq1, eq2, rORs, v : std_logic;


    component fpMultDPDEBUG is
    port(
        gClock, gReset : in std_logic;
        signA, signB : in std_logic;
        mantissaA, mantissaB : in std_logic_vector(7 downto 0);
        exponentA, exponentB : in std_logic_vector(6 downto 0);

        signOut, overFlow : out std_logic;
        mantissaOut : out std_logic_vector(7 downto 0);
        exponentOut : out std_logic_vector(6 downto 0);

        lA, lB, lEA, lEB, lMA, lMB, m50, m00, lMR, slMR, m1, clr, lSO, lEO, addbar_sub, lMO, m01 : in std_logic;
        eq0, eq1, eq2, rORs, v : out std_logic;


        reg18Out : out std_logic_vector(17 downto 0)
    );
    end component;

    component fpMultCPDEBUG is
    port(
        clock, reset : in std_logic;
        eq0, eq1, eq2, rORs, v : in std_logic;
        lA, lB, lEA, lEB, lMA, lMB, m50, m00, lMR, slMR, m1, clr, lSO, lEO, addbar_sub, lMO, m01 : out std_logic;
        stateOut, int_Out : out std_logic_vector(8 downto 0)
    );
    end component;

begin
    controlP: fpMultCPDEBUG
        port map (
            clock        => gClock,
            reset        => gReset,
            eq0          => eq0,
            eq1          => eq1,
            eq2          => eq2,
            rORs         => rORs,
            v            => v,

            lA           => lA,
            lB           => lB,
            lEA          => lEA,
            lEB          => lEB,
            lMA          => lMA,
            lMB          => lMB,
            m50          => m50,
            m00          => m00,
            lMR          => lMR,
            slMR         => slMR,
            m1           => m1,
            clr          => clr,
            lSO          => lSO,
            lEO          => lEO,
            addbar_sub   => addbar_sub,
            lMO          => lMO,
            m01          => m01,
            stateOut => stateOut, 
            int_Out => int_Out
        );

    dataP: fpMultDPDEBUG
        port map (
            gClock        => gClock,
            gReset        => gReset,
            signA         => signA,
            signB         => signB,
            mantissaA     => manA,
            mantissaB     => manB,
            exponentA     => expA,
            exponentB     => expB,

            signOut       => signOut,
            overFlow      => overFlow  ,
            mantissaOut   => manOut,
            exponentOut   => expOut,

            lA            => lA,
            lB            => lB,
            lEA           => lEA,
            lEB           => lEB,
            lMA           => lMA,
            lMB           => lMB,
            m50           => m50,
            m00           => m00,
            lMR           => lMR,
            slMR          => slMR,
            m1            => m1,
            clr           => clr,
            lSO           => lSO,
            lEO           => lEO,
            addbar_sub    => addbar_sub,
            lMO           => lMO,
            m01           => m01,

            eq0           => eq0,
            eq1           => eq1,
            eq2           => eq2,
            rORs          => rORs,
            v             => v,
            reg18Out => reg18Out
        );


end Structural;
