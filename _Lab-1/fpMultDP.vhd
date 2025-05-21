LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- Full adder
entity fpMultDP is
    port(
        gClock, gResest : in std_logic;
        signA, signB : in std_logic;
        mantissaA, mantissaB : in std_logic_vector(7 downto 0);
        exponentA, exponentB : in std_logic_vector(6 downto 0);

        signOut, overFlow : out std_logic;
        mantissaOut : out std_logic_vector(7 downto 0);
        exponentOut : out std_logic_vector(6 downto 0);
    );
end fpMultDP;

architecture rtl of fpMultDP is
    
    component  
        port (

        );
    end component;


begin

end architecture rtl;
