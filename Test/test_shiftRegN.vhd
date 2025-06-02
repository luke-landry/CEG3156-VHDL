library ieee;
use ieee.std_logic_1164.all;

-- A concrete width shiftRegN wrapper for testing
-- To change width, update d and q widths in the test_shiftRegN port declarations
-- and then update the generic-n in the shiftRegN instantiation
entity test_shiftRegN is
    port (
        d : in std_logic_vector(7 downto 0);                -- parallel input
        q : out std_logic_vector(7 downto 0);               -- parallel output
        opSel : in std_logic_vector(1 downto 0);            -- operation select
        shiftL_Rbar : in std_logic;                         -- shift direction select
        ariShift_logShiftBar : in std_logic;                -- shift type select
        clk : in std_logic;
        reset : in std_logic
    );
end entity test_shiftRegN;

architecture structural of test_shiftRegN is

    component shiftRegN
        generic (
            n : integer
        );
        port (
            d : in std_logic_vector((n - 1) downto 0);
            q : out std_logic_vector((n - 1) downto 0);
            opSel : in std_logic_vector(1 downto 0);
            shiftL_Rbar : in std_logic;
            ariShift_logShiftBar : in std_logic;
            clk : in std_logic;
            reset : in std_logic
        );
    end component;

begin

    reg : shiftRegN
        generic map (
            n => 8
        )
        port map (
            d => d,
            q => q,
            opSel => opSel,
            shiftL_Rbar => shiftL_Rbar,
            ariShift_logShiftBar => ariShift_logShiftBar,
            clk => clk,
            reset => reset
        );

end architecture structural;
