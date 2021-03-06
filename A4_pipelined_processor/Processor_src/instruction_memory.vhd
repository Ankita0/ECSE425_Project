--Adapted from Example 12-15 of Quartus Design and Synthesis handbook
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_textio.all;
USE STD.textio.all;

ENTITY instruction_memory IS
	GENERIC(
		ram_size : INTEGER := 1024;
		mem_delay : time := 10 ns;
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
END instruction_memory;

ARCHITECTURE rtl OF instruction_memory IS
	TYPE MEM IS ARRAY(ram_size-1 downto 0) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ram_block: MEM;
	SIGNAL read_address_reg: INTEGER RANGE 0 to ram_size-1;
	SIGNAL write_waitreq_reg: STD_LOGIC := '1';
	SIGNAL read_waitreq_reg: STD_LOGIC := '1';
BEGIN
	--This is the main section of the SRAM model
	mem_process: PROCESS (clock, memwrite)
	FILE file_name:         	text;
        VARIABLE line_num:      	line;
        VARIABLE i:      	integer:=0;
	VARIABLE char_vector_to_store: 	std_logic_vector(31 downto 0);
	BEGIN
		--This is a cheap trick to initialize the SRAM in simulation
		--Left in just in case. All 0s should correspond to zero instruction????
		--file_open (file_name, "C:\Users\Ankita\Documents\McGill\Winter2017\ECSE425_Project\A4_pipelined_processor\read.txt", READ_MODE);
	
		IF(now < 1 ps)THEN
		file_open(file_name, "C:\Users\ytang55\Documents\ECSE425_Project-master\ECSE425_Project-master\A4_pipelined_processor\bitwise.txt",READ_MODE);
		while (not (endfile(file_name))) loop
					readline (file_name, line_num); 
				read (line_num, char_vector_to_store);
				ram_block(i)<=char_vector_to_store;
				  i:=i+1;
		END LOOP;
		file_close(file_name);
		end if;
		
		--This is the actual synthesizable SRAM block
		IF (memwrite = '1') THEN
			ram_block(address) <= writedata;
		END IF;
	END PROCESS;
	read_address_reg <= address;
	readdata <= ram_block(read_address_reg);

	--The waitrequest signal is used to vary response time in simulation
	--Read and write should never happen at the same time.
	waitreq_w_proc: PROCESS (memwrite)
	BEGIN
		IF(memwrite'event AND memwrite = '1')THEN
			write_waitreq_reg <= '0';
		END IF;
		IF(memwrite'event AND memwrite = '0')THEN
			write_waitreq_reg <= '1';
		END IF;
	END PROCESS;

	waitreq_r_proc: PROCESS (memread)
	BEGIN
		IF(memread'event AND memread = '1')THEN
			read_waitreq_reg <= '0';
		END IF;
		IF(memread'event AND memread = '0')THEN
			read_waitreq_reg <= '1';
		END IF;
	END PROCESS;
	waitrequest <= not(write_waitreq_reg and read_waitreq_reg);

END rtl;