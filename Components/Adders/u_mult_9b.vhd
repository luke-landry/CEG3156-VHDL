library ieee;
use ieee.std_logic_1164.all;

entity u_mult_test is
    port(
        opA, opB : in std_logic_vector(8 downto 0);
        res      : out std_logic_vector(17 downto 0)
    );
end u_mult_test;

architecture rtl of u_mult_test is
    component adder1bit
        port(
            a, b, cIn : in std_logic;
            sum, cOut : out std_logic
        );
    end component;

    type sum_arr is array(1 to 8) of std_logic_vector(1 to 8);
    type cry_arr is array(1 to 8) of std_logic_vector(0 to 8);

    signal s : sum_arr := (others => (others => '0'));
    signal c : cry_arr := (others => (others => '0'));

begin
    -- LSB of result is the first partial product
    res(0) <= opA(0) and opB(0);

    -- First row of adders
    first_row: for col in 0 to 8 generate
        first_row_col0: if col = 0 generate
            adder0: adder1bit port map(
                a    => opA(1) and opB(0),
                b    => opA(0) and opB(1),
                cIn  => '0',
                sum  => res(1),
                cOut => c(1)(0)
            );
        end generate;

        first_row_colx: if col > 0 and col < 8 generate
            addern: adder1bit port map(
                a    => opA(col+1) and opB(0),
                b    => opA(col) and opB(1),
                cIn  => c(1)(col-1),
                sum  => s(1)(col),
                cOut => c(1)(col)
            );
        end generate;

        first_row_col8: if col = 8 generate
            addern: adder1bit port map(
                a    => '0',
                b    => opA(col) and opB(1),
                cIn  => c(1)(col-1),
                sum  => s(1)(col),
                cOut => c(1)(col)
            );
        end generate;
    end generate;

    -- Main adder grid
    grid_row: for row in 2 to 8 generate
        grid_col: for col in 0 to 8 generate

            col0: if col = 0 generate
                adder0: adder1bit port map(
                    a    => opA(0) and opB(row),
                    b    => s(row-1)(1),
                    cIn  => '0',
                    sum  => res(row),
                    cOut => c(row)(0)
                );
            end generate;

            gridx: if col > 0 and col /= 8 generate
                addern: adder1bit port map(
                    a    => opA(col) and opB(row),
                    b    => s(row - 1)(col+1),
                    cIn  => c(row)(col - 1),
                    sum  => s(row)(col),
                    cOut => c(row)(col)
                );
            end generate;

            -- Uses MSB carry from previous row
            gridx_col8: if col > 0 and col = 8 generate
                addern: adder1bit port map(
                    a    => opA(col) and opB(row),
                    b    => c(row-1)(8),
                    cIn  => c(row)(col - 1),
                    sum  => s(row)(col),
                    cOut => c(row)(col)
                );
            end generate;

        end generate;
    end generate;

    -- Final half adder with MSB
    adder_half: adder1bit port map(
        a    => '0',
        b    => '0',
        cIn  => c(8)(8),
        sum  => res(17),
        cOut => open
    );

    -- Final sums from s(8)(1 to 8)
    final_sums: for i in 0 to 7 generate
        res(9+i) <= s(8)(1+i);
    end generate;

end architecture;
