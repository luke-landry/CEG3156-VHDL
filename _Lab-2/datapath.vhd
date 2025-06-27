library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity datapath is
    Port (
        valueSelect : in std_logic_vector(2 downto 0);
        clk   : in  std_logic;
        reset : in  std_logic;
        muxOut : out std_logic_vector(7 downto 0);
        instructionOut : out std_logic_vector(31 downto 0);
        branchOut, zeroOut, memWriteOut, regWriteOut : out std_logic
    );
end datapath;

architecture Structural of datapath is

    -- Signals for PC and instruction memory
    signal pc            : std_logic_vector(7 downto 0);  -- 256 instructions
    signal next_pc       : std_logic_vector(7 downto 0);
    signal instruction   : std_logic_vector(31 downto 0);

    -- Register file
    signal reg_data1     : std_logic_vector(7 downto 0);
    signal reg_data2     : std_logic_vector(7 downto 0);
    signal write_data    : std_logic_vector(7 downto 0);
    signal reg_write     : std_logic;
    signal write_reg_mux : std_logic_vector(7 downto 0);
    signal write_reg_a : std_logic_vector(7 downto 0);
    signal write_reg_b : std_logic_vector(7 downto 0);


    -- ALU
    signal alu_input2    : std_logic_vector(7 downto 0);
    signal alu_result    : std_logic_vector(7 downto 0);
    signal alu_zero      : std_logic;
    signal alu_op        : std_logic_vector(1 downto 0);
    signal alu_control   : std_logic_vector(2 downto 0);

    -- Sign extension
    signal sign_ext_imm  : std_logic_vector(31 downto 0);  -- Still 8-bit result
    signal sign_ext_shift: std_logic_vector(7 downto 0);  -- Still 8-bit result
    signal branch_control : std_logic;

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
    signal pc_plus_4       : std_logic_vector(7 downto 0);
    signal branch_target   : std_logic_vector(7 downto 0);
    signal jump_target     : std_logic_vector(7 downto 0);
    signal branch_alu      : std_logic_vector(7 downto 0);
    
    signal output_mux_vect : std_logic_vector(7 downto 0);


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
    

    component m8x8to1 is
        port (
            d0, d1, d2, d3 , d4, d5, d6, d7: in std_logic_vector(7 downto 0);   -- 8x8b data inputs
            s0, s1, s2 : in std_logic;                              -- 3b select input
            q : out std_logic_vector(7 downto 0)                -- 8 bit data output         
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
            load => '1', 
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
    U_RegFile : registerFile
        port map (
            clk => clk,
            reset => reset,
            readReg1 => instruction(23 downto 21),
            readReg2 => instruction(18 downto 16),
            writeRegister => write_reg_mux(2 downto 0),
            writeData => write_data,
            regWrite => reg_write,
            readData1 => reg_data1,
            readData2 => reg_data2
        );


    -- Sign Extend (8-bit immediate)
    U_SignExt : signExt
        port map (
            inp => instruction(15 downto 0),
            res => sign_ext_imm
        );

    sign_ext_shift(7) <= sign_ext_imm(5);
    sign_ext_shift(6) <= sign_ext_imm(4);
    sign_ext_shift(5) <= sign_ext_imm(3);
    sign_ext_shift(4) <= sign_ext_imm(2);
    sign_ext_shift(3) <= sign_ext_imm(1);
    sign_ext_shift(2) <= sign_ext_imm(0);
    sign_ext_shift(1) <= '0';
    sign_ext_shift(0) <= '0';

    -- ALU Control 
    U_ALUCtrl : aluControlUnit
        port map (
            ALUOp => alu_op,
            F => instruction(4 downto 0),
            Operation => alu_control
        );

    -- ALU Input MUX
    alu_mux : m8x2to1
        port map (
            d0 => reg_data2,
            d1 => sign_ext_imm(7 downto 0),
            s0 => alu_src,
            q  => alu_input2
        );


    -- ALU
    U_ALU : alu8b
        port map (
            a => reg_data1,
            b => alu_input2,
            op => alu_control,
            zero => alu_zero,
            result => alu_result
        );


    -- Data Memory (LPM RAM_DQ 256 x 8)
    -- data_mem: entity work.data_memory_256x8
    --     port map (
    --         clk         => clk,
    --         address     => alu_result,
    --         write_data  => reg_data2,
    --         read_data   => data_read,
    --         mem_read    => mem_read,
    --         mem_write   => mem_write
    --     );

    DMEM : data_mem
        port map (
            address => alu_result,
            clock   => clk,
            data    => reg_data2,
            wren    => mem_write,
            q       => data_read
        );

    -- Write Back MUX
    write_back_mux : m8x2to1
        port map (
            d0 => alu_result,
            d1 => data_read,
            s0 => mem_to_reg,
            q  => write_data
        );

    write_reg_a <= "00000" &instruction(18 downto 16);
    write_reg_b <= "00000" &instruction(13 downto 11);

    -- Write Register MUX (reg_dst)
    reg_dst_mux : m8x2to1
        port map (
            d0 => write_reg_a,
            d1 => write_reg_b,
            s0 => reg_dst,
            q  => write_reg_mux
        );

    -- PC + 4
    pc_adder : aluNbit
        generic map (n => 8)
        port map (
            a => pc,
            b => "00000100",
            addbar_sub => '0',
            result => pc_plus_4,
            cOut => open,
            zero => open
        );

    -- Branch target address
    branch_adder : aluNbit
        generic map (n => 8)
        port map (
            a => pc_plus_4,
            b => sign_ext_shift,
            addbar_sub => '0',
            result => branch_target,
            cOut => open,
            zero => open
        );


    branch_control <= alu_zero and branch;

    branch_mux : m8x2to1
        port map (
            d0 => pc_plus_4,
            d1 => branch_target,
            s0 => branch_control,
            q  => branch_alu
        );

    jump_target(7) <= instruction(5);
    jump_target(6) <= instruction(4);
    jump_target(5) <= instruction(3);
    jump_target(4) <= instruction(2);
    jump_target(3) <= instruction(1);
    jump_target(2) <= instruction(0);
    jump_target(1) <= '0';
    jump_target(0) <= '0';

    jump_mux : m8x2to1
        port map (
            d0 => branch_alu,
            d1 => jump_target,
            s0 => jump,
            q  => next_pc
        );



    output_mux_vect(7) <= alu_src;
    output_mux_vect(6) <= alu_op(1);
    output_mux_vect(5) <= alu_op(0);
    output_mux_vect(4) <= mem_to_reg;
    output_mux_vect(3) <= mem_read;
    output_mux_vect(2) <= jump;
    output_mux_vect(1) <= reg_dst;
    output_mux_vect(0) <= '0';
    
    output_mux : m8x8to1
    port map (
        d0 => pc,
        d1 => alu_result,
        d2 => reg_data1,
        d3 => reg_data2,
        d4 => write_data,
        d5 => output_mux_vect,
        d6 => output_mux_vect,
        d7 => output_mux_vect,
        s0 => valueSelect(0),
        s1 => valueSelect(1),
        s2 => valueSelect(2),
        q  => muxOut
    );

    instructionOut <= instruction;
    branchOut <= branch;
    zeroOut <= alu_zero;
    memWriteOut <= mem_write;
    regWriteOut <= reg_write;


end Structural;
