LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- Full adder
entity u_mult_9b is
    port(
        opA, opB : in std_logic_vector(8 downto 0); 
        res : out std_logic_vector(17 downto 0)
    );
end u_mult_9b;

architecture rtl of u_mult_9b is
    signal s7, s6, s5, s4, s3, s2, s1, s0 : std_logic_vector(8 downto 1);
    signal c7, c6, c5, c4, c3, c2, c1, c0 : std_logic_vector(8 downto 0);

    component adder1bit
        port(
            a, b, cIn : in std_logic; 
            sum, cOut : out std_logic
        );
    end component;

    component half_adder
        port(
            a, b : in std_logic; 
            sum, cOut : out std_logic
        );
    end component;

begin
    res(0) <= opA(0) and opB(0)
    
    a00: adder1bit
        a => opA(1) and opB(0),
        b => opA(0) and opB(1),
        cIn => 0, 
        sum => res(1),
        cOut => c0(0)
    );

    a01: adder1bit
        a => opA(2) and opB(0),
        b => opA(1) and opB(1),
        cIn => c0(0), 
        sum => s0(1),
        cOut => c0(1)
    );

    a02: adder1bit
        a => opA(3) and opB(0),
        b => opA(2) and opB(1),
        cIn => c0(1), 
        sum => s0(2),
        cOut => c0(2)
    );

    a03: adder1bit
        a => opA(4) and opB(0),
        b => opA(3) and opB(1),
        cIn => c0(2), 
        sum => s0(2),
        cOut => c0(3)
    );

    a04: adder1bit
        a => opA(5) and opB(0),
        b => opA(4) and opB(1),
        cIn => c0(3), 
        sum => s0(3),
        cOut => c0(4)
    );

    a05: adder1bit
        a => opA(6) and opB(0),
        b => opA(5) and opB(1),
        cIn => c0(4), 
        sum => s0(4),
        cOut => c0(5)
    );

    a06: adder1bit
        a => opA(7) and opB(0),
        b => opA(6) and opB(1),
        cIn => c0(5), 
        sum => s0(5),
        cOut => c0(6)
    );

    a07: adder1bit
        a => opA(8) and opB(0),
        b => opA(7) and opB(1),
        cIn => c0(6), 
        sum => s0(6),
        cOut => c0(7)
    );

    a08: adder1bit
        a => 1,
        b => opA(8) and opB(1),
        cIn => c0(7), 
        sum => s0(8),
        cOut => c0(8)
    );







    a10: adder1bit
        a => opA(0) and opB(2),
        b => s0(1),
        cIn => 0, 
        sum => res(2),
        cOut => c1(0)
    );

    a11: adder1bit
        a => opA(1) and opB(2),
        b => s0(2),
        cIn => c1(0), 
        sum => s1(1),
        cOut => c1(1)
    );

    a12: adder1bit
        a => opA(2) and opB(2),
        b => s0(3),
        cIn => c1(1), 
        sum => s1(2),
        cOut => c1(2)
    );

    a13: adder1bit
        a => opA(3) and opB(2),
        b => s0(4),
        cIn => c1(2), 
        sum => s1(3),
        cOut => c1(3)
    );

    a14: adder1bit
        a => opA(4) and opB(2),
        b => s0(5),
        cIn => c1(3), 
        sum => s1(4),
        cOut => c1(4)
    );

    a15: adder1bit
        a => opA(5) and opB(2),
        b => s0(6),
        cIn => c1(4), 
        sum => s1(5),
        cOut => c1(5)
    );

    a16: adder1bit
        a => opA(6) and opB(2),
        b => s0(7),
        cIn => c1(5), 
        sum => s1(6),
        cOut => c1(6)
    );

    a17: adder1bit
        a => opA(7) and opB(2),
        b => s0(8),
        cIn => c1(6), 
        sum => s1(7),
        cOut => c1(7)
    );

    a18: adder1bit
        a => opA(8) and opB(2),
        b => c0(8),
        cIn => c1(7), 
        sum => s1(8),
        cOut => c1(8)
    );

end architecture rtl;
