LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- Full adder
entity fpMultCP is
    port(
        clock, reset : in std_logic;
        eq0, eq1, eq2, rORs, v : in std_logic;
        lA, lB, lEA, lEB, lMA, lMB, m50, m00, lMR, slMR, m1, clr, lSO, lEO, addbar_sub, lMO, m01 : out std_logic;
    );
end fpMultCP;

architecture rtl of fpMultCP is
    signal state : std_logic_vector(8 downto 0);
    signal int_d : std_logic_vector(8 downto 0);


    component d_FF_ASR IS
        port(
                i_set, i_reset : IN STD_LOGIC;
                i_d : IN STD_LOGIC;
                i_clock : IN STD_LOGIC;
                o_q, o_qBar : OUT STD_LOGIC
            );
    end component;

begin

    int_d(0) <= not(reset);
    int_d(1) <= state(0) and reset;
    int_d(2) <= state(1) and reset;
    int_d(3) <= state(2) and reset;
    int_d(4) <= (state(3) or state(4)) and not(eq0) and reset;
    int_d(5) <= (state(3) or state(4)) and eq0 and reset;
    int_d(6) <= state(5) and (( not(eq1) and rORs) or (not(eq1) and eq2)) and reset;
    int_d(7) <= state(6) and v and reset;
    int_d(8) <= ((state(5) and ((eq1) or (not(rORs) and not(eq2)))) or (state(6) and not(v)) or (state(7))) and reset;

    genDFF : for i in 8 downto 0 generate
        dff1 : d_FF_ASR
        port map(
            i_set => '1', 
            i_reset => '1',
            i_d => int_d(i),
            i_clock => clock,
            o_q => state(i),
            o_qBar => open
        );
    end generate;

    lA <= state(0); 
    lB <= state(0);
    lEA <= state(0);
    lEB <= state(0);
    lMA <= state(0);
    lMB <= state(0);
    m50 <= state(1);
    m00 <= state(2);
    lMR <= state(2);
    slMR <= state(4);
    m1 <= state(6);
    clr <= state(7);
    lSO <= state(8);
    lEO <= state(1) or state(2) or state(3) or state(4) or state(7);
    addbar_sub <= state(2) or state(3) or state(4) or state(7); 
    lMO <= state(5) or state(6);
    m01 <= state(3) or state(4) or state(7);

end architecture rtl;
