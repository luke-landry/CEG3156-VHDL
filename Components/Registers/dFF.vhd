LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- D flip flop taken from CEG 3155 class notes (lecture note "ceg3155BML5")
-- Changed architecture to use d latch instead of SR latch, previously used
ENTITY d_FF IS
    PORT(
                i_d : IN STD_LOGIC;
                i_clock : IN STD_LOGIC;
                o_q, o_qBar : OUT STD_LOGIC
        );
END d_FF;

ARCHITECTURE rtl OF d_FF IS
    SIGNAL int_q, int_qBar : STD_LOGIC;
    SIGNAL int_d, int_dBar : STD_LOGIC;
    SIGNAL int_notD, int_notClock : STD_LOGIC;

    COMPONENT d_Latch
	PORT(
          i_d : IN STD_LOGIC;
          i_enable : IN STD_LOGIC;
          o_q, o_qBar : OUT STD_LOGIC);
    END COMPONENT;

BEGIN
    -- Component Instantiation
    masterLatch: d_Latch
        PORT MAP (  i_d => i_d,
                    i_enable => int_notClock,
                    o_q => int_q,
                    o_qBar => int_qBar);
    slaveLatch: d_Latch
    PORT MAP (  i_d => int_q,
                i_enable => i_clock,
                o_q => o_q,
                o_qBar => o_qBar);

    -- Concurrent Signal Assignment
    int_notClock <= not(i_clock);
END rtl;