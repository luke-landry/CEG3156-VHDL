library ieee;
use ieee.std_logic_1164.all;

-- Test wrapper for the fpAdd floating point adder

entity fpAdd_demo is
    port (
        clk, reset : in std_logic;

        signResult : out std_logic;
        exponentResult : out std_logic_vector(6 downto 0);
        mantissaResult : out std_logic_vector(7 downto 0);
        overflow : out std_logic
    );
end entity fpAdd_demo;

architecture structural of fpAdd_demo is

    component fpAdd
        port (
            clk, reset : in std_logic;

            signA, signB : in std_logic;
            exponentA, exponentB : in std_logic_vector(6 downto 0);
            mantissaA, mantissaB : in std_logic_vector(7 downto 0);

            signResult : out std_logic;
            exponentResult : out std_logic_vector(6 downto 0);
            mantissaResult : out std_logic_vector(7 downto 0);
            overflow : out std_logic
        );
    end component;

    signal signA, signB : std_logic;
    signal exponentA, exponentB : std_logic_vector(6 downto 0);
    signal mantissaA, mantissaB : std_logic_vector(7 downto 0);

begin

    -- DEMO INPUTS
    -- A = 10.1 = 0 1000010 01000011
    -- B = 6.5  = 0 1000001 10100000

    signA <= '0';
    signB <= '0';

    exponentA <= "1000010";
    exponentB <= "1000001";

    mantissaA <= "01000011";
    mantissaB <= "10100000";

    fpAdder: fpAdd
        port map (
            clk => clk,
            reset => reset,
            signA => signA,
            signB => signB,
            exponentA => exponentA,
            exponentB => exponentB,
            mantissaA => mantissaA,
            mantissaB => mantissaB,
            signResult => signResult,
            exponentResult => exponentResult,
            mantissaResult => mantissaResult,
            overflow => overflow
        );

end architecture structural;
