library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mips8_top is
    Port (
        valueSelect : in std_logic_vector(2 downto 0);
        clk   : in  std_logic;
        reset : in  std_logic;
        muxOut : out std_logic_vector(7 downto 0);
        instructionOut : out std_logic_vector(31 downto 0);
        branchOut, zeroOut, memWriteOut, regWriteOut : out std_logic
    );
end mips8_top;

architecture Structural of mips8_top is

    -- Signals for PC and instruction memory
    signal pc            : std_logic_vector(7 downto 0);  -- 256 instructions
    signal next_pc       : std_logic_vector(7 downto 0);
    signal instruction   : std_logic_vector(31 downto 0);

    -- Register file
    signal reg_data1     : std_logic_vector(7 downto 0);
    signal reg_data2     : std_logic_vector(7 downto 0);
    signal write_data    : std_logic_vector(7 downto 0);
    signal write_reg     : std_logic_vector(2 downto 0);  -- 3-bit reg address
    signal reg_write     : std_logic;

    -- ALU
    signal alu_input2    : std_logic_vector(7 downto 0);
    signal alu_result    : std_logic_vector(7 downto 0);
    signal alu_zero      : std_logic;
    signal alu_op        : std_logic_vector(1 downto 0);
    signal alu_control   : std_logic_vector(2 downto 0);

    -- Sign extension
    signal sign_ext_imm  : std_logic_vector(7 downto 0);  -- Still 8-bit result

    -- Control signals
    signal mem_read      : std_logic;
    signal mem_write     : std_logic;
    signal mem_to_reg    : std_logic;
    signal alu_src       : std_logic;
    signal reg_dst       : std_logic;
    signal jump          : std_logic;
    signal branch        : std_logic;

    -- Data memory
    signal data_read     : std_logic_vector(7 downto 0);

    -- Internal wires
    signal branch_addr   : std_logic_vector(7 downto 0);
    signal jump_addr     : std_logic_vector(7 downto 0);
    signal pc_src        : std_logic;
    signal write_reg_mux : std_logic_vector(2 downto 0);

-- COMPONENTS``

    component instr_mem
        port (
            address    : in std_logic_vector(7 downto 0);
            clock      : in std_logic;
            q          : out std_logic_vector(31 downto 0)
        );
    end component;

    component data_mem
        port (
            address    : in std_logic_vector(7 downto 0);
            clock      : in std_logic;
            data       : in std_logic_vector(7 downto 0);
            wren       : in std_logic;
            q          : out std_logic_vector(7 downto 0)
        );
    end component;

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

    component aluNbit is
        generic(
            n : integer -- must be >= 3
        );
        port(
            a, b : in std_logic_vector((n-1) downto 0);
            addbar_sub : in std_logic;

            result : out std_logic_vector((n-1) downto 0);
            cOut, zero : out std_logic
            );
    end component aluNbit;

    component alu8b is
        port(
            a, b : in std_logic_vector(7 downto 0);
            op : in std_logic_vector(2 downto 0); 
            zero : out std_logic;
            result : out std_logic_vector(7 downto 0)
        );
    end component;

    component aluControlUnit is
        port(
            ALUOp : in std_logic_vector(1 downto 0);
            F : in std_logic_vector(4 downto 0);
            Operation : out std_logic_vector(2 downto 0)
        );
    end component;

    component controlLogicUnit is
        port(
            op : in std_logic_vector(5 downto 0);
            RegDst, Jump, Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite : out std_logic;
            ALUOp : out std_logic_vector(1 downto 0)
        );
    end component;

    component registerFile is 
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
    end component;

    component signExt is
        port(
            inp : in std_logic_vector(15 downto 0); 
            res : out std_logic_vector(31 downto 0)
        );
    end component;

    component m8x2to1 is
        port (
            d0, d1 : in std_logic_vector(7 downto 0);   -- d0, d1 are 8 bit data inputs
            s0 : in std_logic;                          -- s0 is the select input
            q : out std_logic_vector(7 downto 0)        -- q0 is 8 bit data output         
        );
    end component;



begin

    -- Program Counter (PC)
    pc_reg: regNASR
        generic map(
            n => 8
        )
        port map( 
            d => next_pc,
            clk => clk, 
            load => "1", 
            reset => reset,
            q => pc
        );

    -- Instruction Memory (LPM ROM 256 x 32)
    IMEM : instr_mem
        port map (
            address => pc,  -- word address (ignore last 2 bits)
            clock   => clk,
            q       => instruction
        );

    -- Control Unit
    U_Control : controlLogicUnit
        port map (
            op => instruction(31 downto 26),
            RegDst => reg_dst,
            Jump => jump,
            Branch => branch,
            MemRead => mem_read,
            MemtoReg => mem_to_reg,
            MemWrite => mem_write,
            ALUSrc => alu_src,
            RegWrite => reg_write,
            ALUOp => alu_op
        );

    -- Register File (8 registers x 8-bit)
    reg_file: entity work.register_file_8x8
        port map (
            clk         => clk,
            reg_write   => reg_write,
            read_reg1   => instruction(25 downto 23),
            read_reg2   => instruction(22 downto 20),
            write_reg   => write_reg_mux,
            write_data  => write_data,
            read_data1  => reg_data1,
            read_data2  => reg_data2
        );

    -- Sign Extend (8-bit immediate)
    sign_ext: entity work.sign_extender_8
        port map (
            input_5     => instruction(4 downto 0), -- if needed
            input_8     => instruction(7 downto 0), -- actual use
            output      => sign_ext_imm
        );

    -- ALU Control
    alu_ctrl: entity work.alu_control_8
        port map (
            alu_op      => alu_op,
            funct       => instruction(2 downto 0),
            alu_control => alu_control
        );

    -- ALU Input MUX
    alu_src_mux: entity work.mux2to1_8
        port map (
            sel     => alu_src,
            input0  => reg_data2,
            input1  => sign_ext_imm,
            output  => alu_input2
        );

    -- ALU
    alu: entity work.alu_8
        port map (
            input1      => reg_data1,
            input2      => alu_input2,
            alu_control => alu_control,
            result      => alu_result,
            zero        => alu_zero
        );

    -- Data Memory (LPM RAM_DQ 256 x 8)
    data_mem: entity work.data_memory_256x8
        port map (
            clk         => clk,
            address     => alu_result,
            write_data  => reg_data2,
            read_data   => data_read,
            mem_read    => mem_read,
            mem_write   => mem_write
        );

    -- Write Back MUX
    write_back_mux: entity work.mux2to1_8
        port map (
            sel     => mem_to_reg,
            input0  => alu_result,
            input1  => data_read,
            output  => write_data
        );

    -- Write Register MUX (reg_dst)
    reg_dst_mux: entity work.mux2to1_3
        port map (
            sel     => reg_dst,
            input0  => instruction(22 downto 20),  -- rt
            input1  => instruction(18 downto 16),  -- rd
            output  => write_reg_mux
        );

    -- PC Calculation Logic (Branch, Jump, etc.) - to be added by you
    -- You will need:
    --   - PC + 1 adder
    --   - Shift left (branch/jump)
    --   - MUXes for branch/jump decisions

end Structural;
