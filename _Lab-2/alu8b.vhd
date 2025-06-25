LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- 8 bit ALU from textbook "Computer Organnization and Design: MIPS Edition - D. Patterson & J. Hennessy" page B-724
entity alu8b is
    port(
        a, b : in std_logic_vector(7 downto 0);
        op : in std_logic_vector(2 downto 0); 
        zero : out std_logic;
        result : out std_logic_vector(7 downto 0)
    );
end alu8b;

architecture rtl of alu8b is
    signal carrys : std_logic_vector(7 downto 1);
    signal setOut : std_logic;

component aluBlockGen is
    port(
        a, b, cIn, less, aInv, bInv : in std_logic;
        op : in std_logic_vector(1 downto 0); 
        result, cOut : out std_logic
    );
end component;

component aluBlockMSB is
    port(
        a, b, cIn, less, aInv, bInv : in std_logic;
        op : in std_logic_vector(1 downto 0); 
        result, cOut, set : out std_logic
    );
end component;

begin

    alu1 : aluBlockGen
        port map (
            a => a(0), 
            b => b(0), 
            cIn => op(2), 
            less => setOut,
            aInv => '0', 
            bInv => op(2),
            op => op(1 downto 0),
            result => result(0), 
            cOut => carrys(1)
        );


    gen_ALU : for i in 6 downto 1 generate
        aluGeneric : aluBlockGen
        port map (
            a => a(i), 
            b => b(i), 
            cIn => carrys(i), 
            less => '0',
            aInv => '0', 
            bInv => op(2),
            op => op(1 downto 0),
            result => result(i), 
            cOut => carrys(i+1)
        );
    end generate;

        alu7 : aluBlockMSB
        port map (
            a => a(7), 
            b => b(7), 
            cIn => carrys(7), 
            less => setOut,
            aInv => '0', 
            bInv => op(2),
            op => op(1 downto 0),
            result => result(7), 
            cOut => open,
            set => setOut
        );

end architecture rtl;
