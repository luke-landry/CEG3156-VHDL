LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- 1 bit ALU block that allows for adding or subtracting using method taught in class
entity aluBlock is
    port(
        a, b, cIn, addbar_sub : in std_logic;
        result, cOut : out std_logic
    );
end aluBlock;

architecture rtl of aluBlock is
    signal int_b : std_logic;

    component adder1bit
    port (
            a, b, cIn : in std_logic;
            sum, cOut : out std_logic
        );
    end component;

    begin
    int_b <= b xor addbar_sub; -- Xor the b input with the subtraction input, to complement the b input

    adder: adder1bit  
    port map(
        a => a,
        b =>int_b,
        cIn =>cIn,
        sum => result, 
        cOut => cOut
    );
        
end architecture rtl;
