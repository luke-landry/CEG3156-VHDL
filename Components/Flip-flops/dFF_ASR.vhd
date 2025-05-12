LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- D flip flop with asynchronous set and reset based on official course textbook:
-- "Fundamentals of Digital Logic with VHDL Design, 4th edition" by Stephen Brown and Zvonko Vranesic
-- Based on figure 5.13 flip flop with asynchronous preset and clear

-- Asynchronous set and reset are both active low
ENTITY d_FF_ASR IS
    PORT(
                i_set, i_reset : IN STD_LOGIC;
                i_d : IN STD_LOGIC;
                i_clock : IN STD_LOGIC;
                o_q, o_qBar : OUT STD_LOGIC
        );
END d_FF_ASR;

ARCHITECTURE rtl OF d_FF_ASR IS
   
-- internal signals between gates of master and slave latch (int_dx) 
-- and the output signals from the gates of slave latch (int_qx)
-- are based on the numbers assigned to gates in the basic dFF flip flop of figure 5.11

SIGNAL int_d1, int_d2, int_d3, int_d4 : STD_LOGIC;
SIGNAL int_q5, int_q6 : STD_LOGIC;

BEGIN

int_d1 <= not(i_set and int_d4 and int_d2);
int_d2 <= not(int_d1 and i_clock and i_reset);
int_d3 <= not(int_d2 and i_clock and int_d4);
int_d4 <= not(int_d3 and i_d and i_reset);

int_q5 <= not(i_set and int_d2 and int_q6);
int_q6 <= not(int_q5 and int_d3 and i_reset);

o_q <= int_q5;
o_qBar <= int_q6;
    
END rtl;