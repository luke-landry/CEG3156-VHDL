library IEEE;
USE IEEE.std_logic_1164.all;

-- 8 bit register
entity registerFile is 
    port ( 
            clk, reset : in std_logic;
            readReg1 : in std_logic_vector(2 downto 0);
            readReg2 : in std_logic_vector(2 downto 0);
            writeRegister : in std_logic_vector(2 downto 0);  
            writeData : in std_logic_vector(7 downto 0); 
            regWrite : in std_logic;
            readData1 : out std_logic_vector(7 downto 0);
            readData2 : out std_logic_vector(7 downto 0)
        );
end registerFile;

architecture rtl of registerFile is
type byte_array is array (0 to 7) of std_logic_vector(7 downto 0);

signal int_q : byte_array;
signal writeRegDecode : std_logic_vector (7 downto 0);
signal writeRegFinal : std_logic_vector (7 downto 0);


component regNASR is
    generic(
        n : integer := 8
    );
    port ( 
            d : in std_logic_vector(n-1 downto 0); -- n bit input vector
            clk, load, reset : in std_logic;
            q : out std_logic_vector(n-1 downto 0) -- n bit output vector
        );
end component;

component m8x8to1 is
    port (
        d0, d1, d2, d3 , d4, d5, d6, d7: in std_logic_vector(7 downto 0);   -- 8x8b data inputs
        s0, s1, s2 : in std_logic;                              -- 3b select input
        q : out std_logic_vector(7 downto 0)                -- 8 bit data output         
    );
end component;

component d3to8 is
    port(
            d : in std_logic_vector(2 downto 0);
            q : out std_logic_vector(7 downto 0)
    );
end component;

begin
    gen_reg : for i in 7 downto 0 generate
        regN : regNASR
        generic map(
            n => 8
        )
        port map (
            d => writeData,
            clk => clk,
            load => writeRegFinal(i),
            reset => reset,
            q => int_q(i)
        );
    end generate;

    decoder : d3to8
    port map(
        d => writeRegister,
        q => writeRegDecode
    );

    writeRegFinal(0) <= writeRegDecode(0) and regWrite;
    writeRegFinal(1) <= writeRegDecode(1) and regWrite;
    writeRegFinal(2) <= writeRegDecode(2) and regWrite;
    writeRegFinal(3) <= writeRegDecode(3) and regWrite;
    writeRegFinal(4) <= writeRegDecode(4) and regWrite;
    writeRegFinal(5) <= writeRegDecode(5) and regWrite;
    writeRegFinal(6) <= writeRegDecode(6) and regWrite;
    writeRegFinal(7) <= writeRegDecode(7) and regWrite;

    mux0 : m8x8to1
    port map(
        d0 => int_q(0), 
        d1 => int_q(1),
        d2 => int_q(2), 
        d3 => int_q(3), 
        d4 => int_q(4),
        d5 => int_q(5), 
        d6 => int_q(6), 
        d7 => int_q(7),
        s0 => readReg1(0), 
        s1 => readReg1(1), 
        s2 => readReg1(2),
        q => readData1
    );

    mux1 : m8x8to1
    port map(
        d0 => int_q(0), 
        d1 => int_q(1),
        d2 => int_q(2), 
        d3 => int_q(3), 
        d4 => int_q(4),
        d5 => int_q(5), 
        d6 => int_q(6), 
        d7 => int_q(7),
        s0 => readReg2(0), 
        s1 => readReg2(1), 
        s2 => readReg2(2),
        q => readData2
    );


end architecture rtl;