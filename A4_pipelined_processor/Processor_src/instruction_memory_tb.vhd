LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_textio.all;
USE STD.textio.all; 

entity instruction_memory_tb is
end instruction_memory_tb;

architecture foo of instruction_memory_tb is
    COMPONENT instruction_memory IS
        GENERIC(
		ram_size : INTEGER := 1024;
		mem_delay : time := 1 ps;
		clock_period : time := 1 ns
	);
	PORT (
		clock: IN STD_LOGIC;
		writedata: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		address: IN INTEGER RANGE 0 TO ram_size-1;
		memwrite: IN STD_LOGIC;
		memread: IN STD_LOGIC;
		readdata: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		waitrequest: OUT STD_LOGIC
	);
END COMPONENT;
	
    CONSTANT clk_period : time := 1 ns;
    CONSTANT ram_size : integer := 1024;
    SIGNAL clk : std_logic := '0';
    SIGNAL address: INTEGER RANGE 0 TO ram_size-1;
    SIGNAL memwrite: STD_LOGIC := '0';
    SIGNAL memread: STD_LOGIC := '0';
    SIGNAL readdata: STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL writedata: STD_LOGIC_VECTOR (31 DOWNTO 0);
    signal waitrequest: STD_LOGIC;

BEGIN

DUT:
    instruction_memory GENERIC MAP(
            ram_size => 1024
                )
                PORT MAP(
		    clk,
		    writedata,
                    address,
		    memwrite,
                    memread,
                    readdata,
                    waitrequest
                );

test_process : process
	FILE file_name:         text;
        VARIABLE line_num:      line;
	VARIABLE char_vector_to_store: std_logic_vector(31 downto 0);
BEGIN
	--open file: path specified in the second argument
	file_open (file_name, "C:\Users\Ankita\Documents\McGill\Winter2017\ECSE425_Project\A4_pipelined_processor\read.txt", READ_MODE);
	--Read through 1024 lines of text file and save to memory	
	For i in 0 to ram_size-1 LOOP
		address<=i;
		readline (file_name, line_num); 
		read (line_num, char_vector_to_store);
		writedata <= char_vector_to_store;
		memwrite<='1';
		WAIT FOR 0.25 ns;	
		memwrite<='0';
		-- check if written in previous cycle
		if (i>1) then
			address<=(i-1);
		end if;
		memread<='1';
		WAIT FOR 0.25 ns;	
		memread<='0';
	END LOOP;
	
	memread <= '1';
	WAIT FOR 0.25 ns;	
	memread <= '0';
	WAIT FOR 0.25 ns;

	address <= 5; 
	memread <= '1';
	WAIT FOR 0.25 ns;	
	memread <= '0';	
	WAIT FOR 0.25 ns;
	address <= 14; 
        writedata <= X"00000012";
        memwrite <= '1';
	WAIT FOR 0.25 ns;
        memwrite <= '0';
	memread <= '1';
	WAIT FOR 0.25 ns;	
	assert readdata = x"00000012" report "write of 18 to addr 14 unsuccessful" severity error;
	memread <= '0';

	address <= 15;
        memread <= '1';
	WAIT FOR 0.25 ns;
	assert readdata = x"0000000f" report "read from addr 15 unsuccessful" severity error;
	memread <= '0';

	address <= 12;
        memread <= '1';
	WAIT FOR 0.25 ns;
	assert readdata = x"0000000c" report "read from addr 12 unsuccessful" severity error;
	memread <= '0';

        wait;
    END PROCESS;
end architecture;