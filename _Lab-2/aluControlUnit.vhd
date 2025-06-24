library ieee;
use ieee.std_logic_1164.all;

entity aluControlUnit is
    port(
        ALUOp : in std_logic_vector(1 downto 0);
        F : in std_logic_vector(4 downto 0);
        Operation : out std_logic_vector(2 downto 0)
    );
end aluControlUnit;

architecture structural of aluControlUnit is
    begin
    Operation(2) <= ALUOp(0) or (ALUOp(1) and F(1));
    Operation(1) <= (not ALUOp(1)) or (not F(2));
    Operation(0) <= ALUOp(1) and (F(3) or F(0));
end architecture structural;