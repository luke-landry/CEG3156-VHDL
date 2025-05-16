LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- Full adder-based 9-bit multiplier
ENTITY u_mult_9b IS
    PORT(
        opA, opB : IN std_logic_vector(8 DOWNTO 0);
        res      : OUT std_logic_vector(17 DOWNTO 0)
    );
END u_mult_9b;

ARCHITECTURE rtl OF u_mult_9b IS
    SIGNAL s : ARRAY(0 TO 7) OF std_logic_vector(8 DOWNTO 1);
    SIGNAL c : ARRAY(0 TO 7) OF std_logic_vector(8 DOWNTO 0);

    COMPONENT adder1bit
        PORT(
            a, b, cIn : IN std_logic;
            sum, cOut : OUT std_logic
        );
    END COMPONENT;

    COMPONENT half_adder
        PORT(
            a, b : IN std_logic;
            sum, cOut : OUT std_logic
        );
    END COMPONENT;

BEGIN
    -- First bit of result
    res(0) <= opA(0) AND opB(0);

    -- Generate all partial products and sums
    GEN_MULT: FOR row IN 0 TO 7 GENERATE
        GEN_COL: FOR col IN 1 TO 8 GENERATE
            SIGNAL a_bit, b_bit : std_logic;
            SIGNAL pp1, pp2 : std_logic;
        BEGIN
            a_bit <= opA(col);
            b_bit <= opB(row);
            pp1 <= a_bit AND opB(row);
            IF row = 0 THEN
                pp2 <= opA(col-1) AND opB(row+1);
                adder: adder1bit PORT MAP(
                    a => pp1,
                    b => pp2,
                    cIn => c(row)(col-1),
                    sum => s(row)(col),
                    cOut => c(row)(col)
                );
            ELSIF row = 7 AND col = 8 THEN
                adder: adder1bit PORT MAP(
                    a => opA(col) AND opB(row),
                    b => c(row-1)(col),
                    cIn => c(row)(col-1),
                    sum => res(row + col),
                    cOut => res(17)
                );
            ELSE
                adder: adder1bit PORT MAP(
                    a => opA(col) AND opB(row),
                    b => s(row-1)(col),
                    cIn => c(row)(col-1),
                    sum => s(row)(col),
                    cOut => c(row)(col)
                );
            END IF;
        END GENERATE;

        -- First column of each row
        PROCESS(row)
        BEGIN
            IF row = 0 THEN
                adder: adder1bit PORT MAP(
                    a => opA(1) AND opB(0),
                    b => opA(0) AND opB(1),
                    cIn => '0',
                    sum => res(1),
                    cOut => c(0)(0)
                );
            ELSE
                adder: adder1bit PORT MAP(
                    a => opA(0) AND opB(row+1),
                    b => s(row-1)(1),
                    cIn => '0',
                    sum => res(row + 1),
                    cOut => c(row)(0)
                );
            END IF;
        END PROCESS;
    END GENERATE;

    -- Final sum outputs from last stage
    FINAL_SUMS: FOR i IN 1 TO 8 GENERATE
        res(i + 8) <= s(7)(i);
    END GENERATE;

    -- Final carry out
    res(17) <= c(7)(8);

END ARCHITECTURE rtl;
