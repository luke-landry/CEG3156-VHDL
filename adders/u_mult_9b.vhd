LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY u_mult_test IS
    PORT(
        opA, opB : IN std_logic_vector(8 DOWNTO 0);
        res      : OUT std_logic_vector(17 DOWNTO 0)
    );
END u_mult_test;

ARCHITECTURE rtl OF u_mult_test IS
    COMPONENT adder1bit
        PORT(
            a, b, cIn : IN std_logic;
            sum, cOut : OUT std_logic
        );
    END COMPONENT;

    -- Use array of std_logic_vector instead of 2D array
    TYPE slv_8 IS ARRAY(1 TO 8) OF std_logic_vector(1 TO 8);
    TYPE slv_9 IS ARRAY(1 TO 8) OF std_logic_vector(0 TO 8);

    SIGNAL s : slv_8 := (OTHERS => (OTHERS => '0'));
    SIGNAL c : slv_9 := (OTHERS => (OTHERS => '0'));

BEGIN
    -- LSB of result is the first partial product
    res(0) <= opA(0) AND opB(0);

    FIRST_COLUMN_GEN: FOR col IN 0 TO 8 GENERATE
        FIRST_COL0_GEN: IF col = 0 GENERATE
            adder0: adder1bit PORT MAP(
                a    => opA(1) AND opB(0),
                b    => opA(0) AND opB(1),
                cIn  => '0',
                sum  => res(1),
                cOut => c(1)(0)
            );
        END GENERATE;

        FIRST_COLN_GEN: IF col > 0 AND col < 8 GENERATE
            addern: adder1bit PORT MAP(
                a    => opA(col+1) AND opB(0),
                b    => opA(col) and opB(1),
                cIn  => c(1)(col-1),
                sum  => s(1)(col),
                cOut => c(1)(col)
            );
        END GENERATE;

        LAST_COLN_GEN: IF col = 8 GENERATE
        addern: adder1bit PORT MAP(
            a    => '0',
            b    => opA(col) and opB(1),
            cIn  => c(1)(col-1),
            sum  => s(1)(col),
            cOut => c(1)(col)
        );
        END GENERATE;
    END GENERATE;

    -- Main adder grid
    GRID_GEN: FOR row IN 2 TO 8 GENERATE
        COL_GEN: FOR col IN 0 TO 8 GENERATE
            
            GRID0: IF col = 0 GENERATE
                adder0: adder1bit PORT MAP(
                    a    => opA(0) AND opB(row),
                    b    => s(row-1)(1),
                    cIn  => '0',
                    sum  => res(row),
                    cOut => c(row)(0)
                );
            END GENERATE;

            GRIDN: IF col > 0 AND col /= 8 GENERATE
                addern: adder1bit PORT MAP(
                    a    => opA(col) AND opB(row),
                    b    => s(row - 1)(col+1),
                    cIn  => c(row)(col - 1),
                    sum  => s(row)(col),
                    cOut => c(row)(col)
                );
            END GENERATE;
   
            END_CELL: IF col > 0 AND col = 8 GENERATE
                addern: adder1bit PORT MAP(
                    a    => opA(col) AND opB(row),
                    b    => c(row-1)(8),
                    cIn  => c(row)(col - 1),
                    sum  => s(row)(col),
                    cOut => c(row)(col)
                );
            END GENERATE;

        END GENERATE;
    END GENERATE;

    adder_half: adder1bit PORT MAP(
        a    => '0',
        b    => '0',
        cIn  => c(8)(8),
        sum  => res(17),
        cOut => OPEN
    );

    -- Final sums from s(7)(1 to 8)
    FINAL_SUMS: FOR i IN 0 TO 7 GENERATE
        res(9+i) <= s(8)(1+i);
    END GENERATE;

END ARCHITECTURE;
