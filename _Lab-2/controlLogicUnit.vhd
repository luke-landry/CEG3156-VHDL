library ieee;
use ieee.std_logic_1164.all;

entity controlLogicUnit is
    port(
        op : in std_logic_vector(5 downto 0);
        RegDst, Jump, Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite : out std_logic;
        ALUOp : out std_logic_vector(1 downto 0)
    );
end controlLogicUnit;

architecture structural of controlLogicUnit is
    signal s_rformat, s_lw, s_sw, s_beq, s_jump : std_logic;

    begin
    s_rformat <= (not op(5)) and (not op(4)) and (not op(3)) and (not op(2)) and (not op(1)) and (not op(0)); -- op = 0 = 000000
    s_lw <= op(5) and (not op(4)) and (not op(3)) and (not op(2)) and op(1) and op(0); -- op = 35 =100011
    s_sw <= op(5) and (not op(4)) and op(3) and (not op(2)) and op(1) and op(0); -- op = 43 = 101011
    s_beq <= (not op(5)) and (not op(4)) and (not op(3)) and op(2) and (not op(1)) and (not op(0)); -- op = 4 = 000100
    s_jump <= (not op(5)) and (not op(4)) and (not op(3)) and (not op(2)) and op(1) and (not op(0)); -- op = 2 = 000010

    RegDst <= s_rformat;
    Jump <= s_jump;
    Branch <= s_beq;
    ALUSrc <= s_lw or s_sw;
    MemtoReg <= s_lw;
    RegWrite <= s_rformat or s_lw;
    MemRead <= s_lw;
    MemWrite <= s_sw;
    ALUOp(1) <= s_rformat;
    ALUOp(0) <= s_beq;

end architecture structural;