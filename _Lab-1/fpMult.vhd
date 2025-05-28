library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity fpMultTop is
    Port (
        gClock, reset : in  std_logic;
        signA, signB : in  std_logic;
        manA, manB : in  std_logic_vector(7 downto 0);
        expA, expB : in std_logic_vector(6 downto 0);
        expOut : out std_logic_vector(6 downto 0);
        manOut : out std_logic_vector(7 downto 0);
        signOut, overFlow : out std_logic
    );
end fpMultTop;

architecture Structural of fpMultTop is

    signal lA, lB, lEA, lEB, lMA, lMB, m50, m00, lMR, slMR, m1, clr, lSO, lEO, addbar_sub, lMO, m01 : std_logic;
    signal eq0, eq1, eq2, rORs, v : std_logic;


    component fpMultDP is
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
    end component;

    component fpMultCP is
    port(
        clock, reset : in std_logic;
        eq0, eq1, eq2, rORs, v : in std_logic;
        lA, lB, lEA, lEB, lMA, lMB, m50, m00, lMR, slMR, m1, clr, lSO, lEO, addbar_sub, lMO, m01 : out std_logic
    );
    end component;

begin
    controlP: fpMultCP
        port map (
            clock        => clock,
            reset        => reset,
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
            m01          => m01
        );

    dataP: fpMultDP
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
            v             => v
        );


end Structural;
