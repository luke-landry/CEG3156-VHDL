library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library altera_mf;
use altera_mf.all;

entity instr_mem is
    port (
        address : in std_logic_vector(7 downto 0);
        clock   : in std_logic;
        q       : out std_logic_vector(31 downto 0)
    );
end entity;

architecture rtl of instr_mem is
    component altsyncram
        generic (
            operation_mode => string := "ROM",
            width_a        => integer := 32,
            numwords_a     => 256,
            widthad_a      => 8,
            outdata_reg_a  => string := "UNREGISTERED",
            init_file      => string := "instr_mem.mif"
        );
        port (
            address_a : in std_logic_vector(7 downto 0);
            clock0    : in std_logic;
            q_a       : out std_logic_vector(31 downto 0);
            wren_a    : in std_logic := '0';
            data_a    : in std_logic_vector(31 downto 0) := (others => '0')
        );
    end component;
begin
    rom_inst: altsyncram
        generic map (
            operation_mode => "ROM",
            width_a        => 32,
            numwords_a     => 256,
            widthad_a      => 8,
            outdata_reg_a  => "UNREGISTERED",
            init_file      => "instr_mem.mif"
        )
        port map (
            address_a => address,
            clock0    => clock,
            q_a       => q
        );
end architecture;
