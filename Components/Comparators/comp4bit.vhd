LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- 4 bit comparator
-- Circuit diagram taken from https://circuitverse.org/users/45488/projects/4-bit-comparator-98afe9f2-b0b3-4e26-b072-a4d18d2adcfe
entity comp4bit is
    port(
        x, y : in std_logic_vector(3 downto 0);
        equal, lesser, greater : out std_logic
    );
end comp4bit;

architecture rtl of comp4bit is
signal int_m : std_logic_vector(3 downto 0);
signal int_and : std_logic_vector(3 downto 0);
signal int_greater, int_equal : std_logic;

begin
    int_m(0) <= x(3) xnor y(3);
    int_m(1) <= x(2) xnor y(2);
    int_m(2) <= x(1) xnor y(1);
    int_m(3) <= x(0) xnor y(0);

    int_and(0) <= x(3) and not(y(3));
    int_and(1) <= int_m(0) and x(2) and not(y(2));
    int_and(2) <= int_m(1) and int_m(0) and x(1) and not(y(1));
    int_and(3) <= int_m(2) and int_m(1) and int_m(0) and x(0) and not(y(0));

    int_greater <= int_and(0) or int_and(1) or int_and(2) or int_and(3);
    int_equal <= int_m(0) and  int_m(1) and  int_m(2) and int_m(3);

    lesser <= not(int_greater or int_equal);
    greater <= int_greater;
    equal <= int_equal;
    
end architecture rtl;
