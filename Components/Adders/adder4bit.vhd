LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- 4 bit adder/subtractor that uses the subtraction method taught in class
entity adder4bit is
    port(
        x, y : in std_logic_vector(3 downto 0);
        addbar_sub : in std_logic;
        s : out std_logic_vector(3 downto 0); 
        cOut : out std_logic
    );
end adder4bit;

architecture rtl of adder4bit is
    signal int_cOut : std_logic_vector(2 downto 0);

    component aluBlock 
        port(
            a, b, cIn, addbar_sub : in std_logic;
            result, cOut : out std_logic
        );
    end component;

    begin

    aluBlock0: aluBlock   
    port map(
        a => x(0),
        b => y(0),
        cIn =>addbar_sub, -- Carry in of bit 0 is subtraction command so that y input is 2's complemented (flip all bits and add 1)
        addbar_sub => addbar_sub,
        result => s(0), 
        cOut => int_cOut(0)
    );

    aluBlock1: aluBlock   
    port map(
        a => x(1),
        b => y(1),
        cIn =>int_cOut(0), -- Carry in of bit 1 is the carry out of bit 0
        addbar_sub => addbar_sub,
        result => s(1), 
        cOut => int_cOut(1)
    );

    aluBlock2: aluBlock   
    port map(
        a => x(2),
        b => y(2),
        cIn =>int_cOut(1), -- Carry in of bit 2 is the carry out of bit 1
        addbar_sub => addbar_sub,
        result => s(2), 
        cOut => int_cOut(2)
    );

    aluBlock3: aluBlock   
    port map(
        a => x(3),
        b => y(3),
        cIn =>int_cOut(2), -- Carry in of bit 3 is the carry out of bit 2
        addbar_sub => addbar_sub,
        result => s(3), 
        cOut => cOut -- Carry out of 4 bit adder is carry out of bit 3
    );
        
end architecture rtl;
