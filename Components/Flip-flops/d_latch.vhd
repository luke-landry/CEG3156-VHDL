library IEEE;
USE IEEE.std_logic_1164.all;

-- D latch taken from CEG 3155 class notes (lecture note "ceg3155BML5")
ENTITY d_Latch IS
	PORT(
          i_d : IN STD_LOGIC;
          i_enable : IN STD_LOGIC;
          o_q, o_qBar : OUT STD_LOGIC);
END d_Latch;

ARCHITECTURE rtl OF d_Latch IS
      SIGNAL int_q, int_qBar : STD_LOGIC;
      SIGNAL int_d, int_dBar : STD_LOGIC;
      SIGNAL int_notD : STD_LOGIC;
BEGIN
      -- Concurrent Signal Assignment
      int_notD <= not(i_d);
      int_d <= i_d nand i_enable;
      int_dBar <= i_enable nand int_notD;
      int_q <= int_d nand int_qBar;
      int_qBar <= int_q nand int_dBar;
      -- Output Driver
      o_q <= int_q;
      o_qBar <= int_qBar;
END rtl;