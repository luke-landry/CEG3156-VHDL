LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- 8 bit adder/subtractor that uses the subtraction method taught in class
entity adder8bit is
    port(
        x, y : in std_logic_vector(7 downto 0);
        addbar_sub : in std_logic;
        s : out std_logic_vector(7 downto 0); 
        cOut : out std_logic

    );
end adder8bit;

architecture rtl of adder8bit is
    signal int_cOut : std_logic_vector(6 downto 0);

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
    cIn =>int_cOut(2), -- ...
    addbar_sub => addbar_sub,
    result => s(3), 
    cOut => int_cOut(3)
);

aluBlock4: aluBlock   
port map(
    a => x(4),
    b => y(4),
    cIn =>int_cOut(3),
    addbar_sub => addbar_sub,
    result => s(4), 
    cOut => int_cOut(4)
);

aluBlock5: aluBlock   
port map(
    a => x(5),
    b => y(5),
    cIn =>int_cOut(4),
    addbar_sub => addbar_sub,
    result => s(5), 
    cOut => int_cOut(5)
);

aluBlock6: aluBlock   
port map(
    a => x(6),
    b => y(6),
    cIn =>int_cOut(5),
    addbar_sub => addbar_sub,
    result => s(6), 
    cOut => int_cOut(6)
);

aluBlock7: aluBlock   
port map(
    a => x(7),
    b => y(7),
    cIn =>int_cOut(6),
    addbar_sub => addbar_sub,
    result => s(7), 
    cOut => cOut -- Carry out of 8 bit adder is carry out of bit 7
);
    
end architecture rtl;
