library ieee;
use ieee.std_logic_1164.all;

entity instruction_memory_tb is
end instruction_memory_tb;

architecture foo of instruction_memory_tb is
    COMPONENT instruction_memory IS
        GENERIC(
            ram_size : INTEGER := 1024;
            mem_delay : time := 10 ns;
            clock_period : time := 1 ns
        );
        PORT (
            clock: IN STD_LOGIC;
            address: IN INTEGER RANGE 0 TO ram_size-1;
            memread: IN STD_LOGIC := '0';
            readdata: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
            waitrequest: OUT STD_LOGIC
        );
    END COMPONENT;
	
    constant clk_period : time := 1 ns;
    constant ram_size : integer := 1024;
    signal clk : std_logic := '0';
    signal address: INTEGER RANGE 0 TO ram_size-1;
    signal memread: STD_LOGIC := '0';
    signal readdata: STD_LOGIC_VECTOR (31 DOWNTO 0);
    signal waitrequest: STD_LOGIC;

begin

DUT:
    instruction_memory GENERIC MAP(
            ram_size => 15
                )
                PORT MAP(
                    clk,
                    address,
                    memread,
                    readdata,
                    waitrequest
                );
clk_process : process
    BEGIN
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    test_process : process
    BEGIN
	--initial wait
        wait for 10 ns;

	--read data on add 14 in intruction block
        address <= 14;  
        --waits are NOT synthesizable and should not be used in a hardware design
        memread <= '1';
	wait for clk_period;
       	wait until rising_edge(waitrequest);
        assert readdata = x"0000000e" report "write unsuccessful" severity error;

	--don't read anything
        memread <= '0';
        wait for clk_period;

	--read data on add 14 in intruction block
        address <= 12;
	memread <= '1';
        wait for clk_period;
	wait until rising_edge(waitrequest);
        assert readdata = x"0000000c" report "write unsuccessful" severity error;

	--don't read anything
        memread <= '0';
        wait;

    END PROCESS;
end architecture;