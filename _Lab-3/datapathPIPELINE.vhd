library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity datapathPIPELINE is
    Port (
        valueSelect, instrSelect : in std_logic_vector(2 downto 0);
        clk   : in  std_logic;
        reset : in  std_logic;
        muxOut : out std_logic_vector(7 downto 0);
        instructionOut : out std_logic_vector(31 downto 0);
        branchOut, zeroOut, memWriteOut, regWriteOut : out std_logic
    );
end datapathPIPELINE;

architecture Structural of datapathPIPELINE is

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
    signal alu_input1, alu_input2    : std_logic_vector(7 downto 0);
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

    -- Pipelines
    signal ifIDin, ifIDout : std_logic_vector(39 downto 0);
    signal idExin, idExout : std_logic_vector(45 downto 0);
    signal exMemin, exMemout : std_logic_vector(22 downto 0);
    signal memWbin, memWbout : std_logic_vector(20 downto 0);

    signal ifIdWrite, pcWrite, controlMux : std_logic;
    signal controlMuxIn, controlMuxOut : std_logic_vector(7 downto 0);
    signal r_dest_mux_out : std_logic_vector(7 downto 0);

    signal fA, fB : std_logic_vector(1 downto 0);

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

    component m8x4to1 is
        port (
            d0, d1, d2, d3 : in std_logic_vector(7 downto 0);   -- d0, d1, d2, d3 are 8 bit data inputs
            s0, s1 : in std_logic;                              -- s0, s1 are select inputs
            q : out std_logic_vector(7 downto 0)                -- q0 is 8 bit data output         
        );
    end component;
    

    component m8x8to1 is
        port (
            d0, d1, d2, d3 , d4, d5, d6, d7: in std_logic_vector(7 downto 0);   -- 8x8b data inputs
            s0, s1, s2 : in std_logic;                              -- 3b select input
            q : out std_logic_vector(7 downto 0)                -- 8 bit data output         
        );
    end component;

    component m2to1 is
        port(
                d0, d1, s0 : in std_logic;  -- d0, d1 are data inputs, s0 is select input
                q0 : out std_logic          -- q0 is data output
        );
    end component;

    component forwardUnit is
        port(
            exMemRegWrite : in std_logic;
            exMemRegRd, memWbRedRd, idExRegRs, idExRegRt : in std_logic_vector(2 downto 0);
            fA, fB : out std_logic_vector(1 downto 0)
        );
    end component;

    component hazDetecUnit is
        port(
            idExMemRead : in std_logic;
            idExRegRt, ifIdRegRs, ifIdRegRt : in std_logic_vector(2 downto 0);
            pcWrite, ifIdWrite, controlMux : out std_logic
        );
    end component;

    component compNbit is
        generic(
            n : integer -- must be >= 3
        );
        port(
            a, b : in std_logic_vector((n-1) downto 0);
            altb, aeqb, agtb : out std_logic
        );
    end component compNbit;


begin

    -- Program Counter (PC)
    pc_reg: regNASR
        generic map(
            n => 8
        )
        port map( 
            d => next_pc,
            clk => clk, 
            load => pcWrite,
            reset => reset,
            q => pc
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

    -- Instruction Memory (LPM ROM 256 x 32)
    IMEM : instr_mem
        port map (
            address => pc,  -- word address (ignore last 2 bits)
            clock   => clk,
            q       => instruction
        );

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

        -- PC-plus-4 8 bits, instruction 32 bits
        ifIDin <= pc_plus_4 & instruction;
    -- Pipeline IF/ID ########################
        ifID: regNASR
            generic map(
                n => 40
            )
            port map( 
                d => ifIDin,
                clk => clk, 
                load => ifIdWrite, 
                reset => Jump or alu_zero,
                q => ifIDout
            );
    -- #######################################

        -- Control Unit
        U_Control : controlLogicUnit
            port map (
                op => ifIDout(31 downto 26),
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

        controlMuxIn <= reg_write & mem_to_reg & mem_read & mem_write & reg_dst & alu_op & alu_src;
        -- Control mux
        cntrl_mux : m8x2to1
            port map (
                d0 => "00000000",
                d1 => controlMuxIn,
                s0 => controlMux,
                q  => controlMuxOut(7 downto 0)
            );


        -- Register File (8 registers x 8-bit)
        U_RegFile : registerFile
            port map (
                clk => clk,
                reset => reset,
                readReg1 => ifIDout(23 downto 21),
                readReg2 => ifIDout(18 downto 16),
                writeRegister => memWbout(2 downto 0),
                writeData => write_data,
                regWrite =>  memWbout(20),
                readData1 => reg_data1,
                readData2 => reg_data2
            );
    
    
        -- Sign Extend (8-bit immediate)
        U_SignExt : signExt
            port map (
                inp => ifIDout(15 downto 0),
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

        -- Branch target address
        branch_adder : aluNbit
            generic map (n => 8)
            port map (
                a => ifIDout(39 downto 32),
                b => sign_ext_shift,
                addbar_sub => '0',
                result => branch_target,
                cOut => open,
                zero => open
            );

        -- Checks if rs = rt
        rs_rt: compNbit
        generic map(
            n => 8
        )
        port map(
            a => reg_data1, 
            b  => reg_data2,
            altb => open, 
            aeqb => alu_zero, 
            agtb => open
        );
 
        branch_control <= alu_zero and branch;
        
        -- Hazard Detection Unit
        U_HazDetec : hazDetecUnit
            port map (
                idExMemRead => idExout(38),
                idExRegRt   => idExout(5 downto 3),
                ifIdRegRs   => ifIDout(23 downto 21),
                ifIdRegRt   => ifIDout(18 downto 16),
                pcWrite     => pcWrite,
                ifIdWrite   => ifIdWrite,
                controlMux  => controlMux
            );
        --  R-type code 5 bits, Control 8 bits, Rs 8 bits, address 8 bits,  Rt 8 bits , Rs 3 bits, Rt 3 bits, Rd 3 bits.
        idExin <= ifIDout(4 downto 0) & controlMuxOut & reg_data1 & reg_data2 & sign_ext_shift & ifIDout(23 downto 21) & ifIDout(18 downto 16) & ifIDout(13 downto 11);
    -- Pipeline ID/EX ########################
        idEx: regNASR
            generic map(
                n => 46
            )
            port map( 
                d => idExin,
                clk => clk, 
                load => '1', 
                reset => reset,
                q => idExout
            );
    -- #######################################

    
        -- ALU Control 
        U_ALUCtrl : aluControlUnit
            port map (
                ALUOp => idExout(35 downto 34),
                F => idExout(45 downto 41),
                Operation => alu_control
            );
    
        -- ALU Input A MUX
        alu_mux_A : m8x4to1
            port map (
                d0 => idExout(32 downto 25),
                d1 => write_data,
                d2 => exMemout(10 downto 3),
                d3 => "00000000",
                s0 => fA(0),
                s1 => fA(1),
                q  => alu_input1
            );

        -- ALU Input B MUX
        alu_mux_B : m8x4to1
            port map (
                d0 => idExout(16 downto 9),
                d1 => write_data,
                d2 => exMemout(10 downto 3),
                d3 => idExout(24 downto 17),
                s0 => fB(0) or idExout(33), -- Might cause issues with finding effective address for load or stores
                s1 => fB(1) or idExout(33), -- "                                               "
                q  => alu_input2
            );
    
    
        -- ALU
        U_ALU : alu8b
            port map (
                a => alu_input1,
                b => alu_input2,
                op => alu_control,
                zero => open,
                result => alu_result
            );

        -- R destination mux
        r_dest_mux : m8x2to1
            port map (
                d0 => "00000" & idExout(5 downto 3), -- Rt
                d1 => "00000" & idExout(2 downto 0), -- Rd
                s0 => idExout(36),
                q  => r_dest_mux_out
            );

        -- Forwarding Unit
        U_ForwardUnit : forwardUnit
            port map (
                exMemRegWrite => exMemout(11),
                exMemRegRd    => exMemout(2 downto 0),
                memWbRedRd    => memWbout(2 downto 0),
                idExRegRs     => idExout(8 downto 6),
                idExRegRt     => idExout(5 downto 3),
                fA            => fA,
                fB            => fB
            );
    -- Rt 8 bits, Control signals 4 bits, alu out 8 bits, R destination 3 bits
    exMemin <= idExout(16 downto 9) & idExout(40 downto 37) & alu_result & r_dest_mux_out(2 downto 0);
    -- Pipeline EX/MEM ########################
        exMem: regNASR
            generic map(
                n => 23
            )
            port map( 
                d => exMemin,
                clk => clk, 
                load => ifIdWrite, 
                reset => reset,
                q => exMemout
            );
    -- #######################################

    DMEM : data_mem
        port map (
            address => exMemout(10 downto 3),
            clock   => clk,
            data    => exMemout(22 downto 15),
            wren    => exMemout(11),
            q       => data_read
        );
    -- Control signals 2 bits, data 8 bits, alu out 8 bits, R destination 3 bits
    memWbin <= exMemout(14 downto 13) & data_read & exMemout(10 downto 3) & exMemout(2 downto 0);
    -- Pipeline MEM/WB ########################
        memWb: regNASR
            generic map(
                n => 21
            )
            port map( 
                d => memWbin,
                clk => clk, 
                load => ifIdWrite, 
                reset => reset,
                q => memWbout
            );
    -- #######################################
    
    -- Write Back MUX
    write_back_mux : m8x2to1
        port map (
            d0 => memWbout(18 downto 11), -- Data from mem
            d1 => memWbout(10 downto 3),  -- Alu output
            s0 => memWbout(19),
            q  => write_data
        );



    -- Lab specific outputs 


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
