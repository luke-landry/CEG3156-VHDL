library IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all; -- For to_unsigned/to_integer conversions (optional but useful for easy data assignment)

entity tb_regNASR is
end tb_regNASR;

architecture behavior of tb_regNASR is

    -- Component declaration for the Unit Under Test (UUT)
    component regNASR is
        generic(
            n : integer
        );
        port (
                d : in std_logic_vector(n-1 downto 0);
                clk, load, reset : in std_logic;
                q : out std_logic_vector(n-1 downto 0)
            );
    end component;

    -- Constants for the testbench
    constant N_BITS : integer := 8; -- Define the bit width for the register
    constant CLK_PERIOD : time := 10 ns;

    -- Signals for the UUT ports
    signal s_d : std_logic_vector(N_BITS-1 downto 0);
    signal s_clk : std_logic;
    signal s_load : std_logic;
    signal s_reset : std_logic;
    signal s_q : std_logic_vector(N_BITS-1 downto 0);

begin

    -- Instantiate the Unit Under Test (UUT)
    uut_regNASR : regNASR
    generic map (
        n => N_BITS
    )
    port map (
        d => s_d,
        clk => s_clk,
        load => s_load,
        reset => s_reset,
        q => s_q
    );

    -- Clock generation process
    clk_gen_proc : process
    begin
        s_clk <= '0';
        wait for CLK_PERIOD / 2;
        s_clk <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    -- Stimulus generation process
    stim_proc : process
    begin
        -- Initialize inputs
        s_reset <= '1'; -- Assert reset
        s_load <= '0';
        s_d <= (others => '0');
        wait for CLK_PERIOD * 2; -- Hold reset for a few clock cycles

        s_reset <= '0'; -- De-assert reset
        wait for CLK_PERIOD;

        -- Test 1: Load data
        s_load <= '1';
        s_d <= X"AA"; -- Load hexadecimal AA (10101010)
        wait for CLK_PERIOD; -- Wait for one clock cycle for data to be loaded

        s_load <= '0'; -- Stop loading
        s_d <= X"FF"; -- Change input data, but it shouldn't load

        wait for CLK_PERIOD * 2; -- Observe the output

        -- Test 2: Load different data
        s_load <= '1';
        s_d <= X"55"; -- Load hexadecimal 55 (01010101)
        wait for CLK_PERIOD;

        s_load <= '0';
        wait for CLK_PERIOD * 2;

        -- Test 3: Assert reset while data is loaded
        s_reset <= '1';
        wait for CLK_PERIOD * 2;
        s_reset <= '0';
        wait for CLK_PERIOD;

        -- Test 4: Load another value after reset
        s_load <= '1';
        s_d <= X"3C"; -- Load 00111100
        wait for CLK_PERIOD;

        s_load <= '0';
        wait for CLK_PERIOD * 2;

        -- Add more test cases as needed
        -- Example: try to load without assert load
        s_d <= X"12";
        s_load <= '0';
        wait for CLK_PERIOD * 2; -- Q should remain 3C

        -- Example: repeated loads
        s_load <= '1';
        s_d <= X"F0";
        wait for CLK_PERIOD;
        s_d <= X"0F"; -- This should overwrite F0
        wait for CLK_PERIOD;
        s_load <= '0';
        wait for CLK_PERIOD * 2;

        -- End simulation
        wait; -- Will hold the simulation indefinitely

    end process;

end architecture behavior;