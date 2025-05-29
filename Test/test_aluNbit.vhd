library ieee;
use ieee.std_logic_1164.all;

-- A concrete width aluNbit wrapper for testing
-- to change width, update a, b, result widths in the aluTest4bit port declarations
-- and then update the generic-n in the aluNbit instantiation
entity test_aluNbit is
    port (
        a, b : in std_logic_vector(7 downto 0);
        addbar_sub : in std_logic;
        result : out std_logic_vector(7 downto 0);
        cOut, zero : out std_logic
    );
end entity test_aluNbit;

architecture structural of test_aluNbit is

    component aluNbit
        generic (
            n : integer
        );
        port (
            a, b : in std_logic_vector((n-1) downto 0);
            addbar_sub : in std_logic;
            result : out std_logic_vector((n-1) downto 0);
            cOut, zero : out std_logic
        );
    end component;

begin

    alu : aluNbit
        generic map (
            n => 8
        )
        port map (
            a => a,
            b => b,
            addbar_sub => addbar_sub,
            result => result,
            cOut => cOut,
            zero => zero
        );

end architecture structural;
