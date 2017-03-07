--Modified code from memory example given for cache assignment 3 to fit requirements
--Adapted from Example 12-15 of Quartus Design and Synthesis handbook
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_textio.all;
USE STD.textio.all; 

-------------------------------------------------------------------------------------
--The instruction memory has 32 bit slots for one instruction
--As per the requirements, we have 32768 bits of data in the memory block
--This evenly divides into (32768/32)= 1024 32-bits slots. Thus a program with
--maximum 1024 insructions can be executed (unless broken otherwise).
--The collection of such 32-bit instructions are fed through an ASCII text file
--Assuming that the file has to be written into memory at initilization for use, we: 
--FIRST populate the memory bank
--THEN read from it as needed
--WRITING TO INSTURCTION MEMORY FUNCTIONALITY IS NOT AVAILABLE for our sanity :D
-------------------------------------------------------------------------------------
ENTITY instruction_memory IS
	GENERIC(
		ram_size : INTEGER := 1024;
		mem_delay : time := 10 ns;
		clock_period : time := 1 ns
	);
	PORT (
		clock: IN STD_LOGIC;
		address: IN INTEGER RANGE 0 TO ram_size-1;
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
	SIGNAL char_vector_to_store: std_logic_vector(31 downto 0) ;
BEGIN
	--This is the main section of the SRAM model
	mem_process: PROCESS (clock)
		file file_name:			text;
		variable line_num:      	line;
		variable char_vector_to_store:  std_logic_vector(31 downto 0);
	BEGIN
		--This is a cheap trick to initialize the SRAM in simulation
		IF(now < 1 ps)THEN
			--open file: path specified in the second argument
			file_open (file_name, "C:\Users\Ankita\Documents\McGill\Winter2017\ECSE425_Project\A4_pipelined_processor\read.txt", READ_MODE);
			--Read through 1024 lines of text file and save to memory			
			For i in 0 to ram_size-1 LOOP
				readline (file_name, line_num); 
				read (line_num, char_vector_to_store);
				ram_block(i) <= char_vector_to_store;
			END LOOP;
		END IF;

		--This is the actual synthesizable SRAM block
		--Writing functionality taken away from instruction memory
		IF (clock'event AND clock = '1') THEN
		read_address_reg <= address;
		END IF;
	END PROCESS;
	readdata <= ram_block(read_address_reg);


	waitreq_r_proc: PROCESS (memread)
	BEGIN
		IF(memread'event AND memread = '1')THEN
			read_waitreq_reg <= '0' after mem_delay, '1' after mem_delay + clock_period;
		END IF;
	END PROCESS;
	waitrequest <= write_waitreq_reg and read_waitreq_reg;


END rtl;