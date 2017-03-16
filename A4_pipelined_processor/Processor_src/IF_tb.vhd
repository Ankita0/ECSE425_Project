LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_textio.all;
USE STD.textio.all; 


entity IF_tb is
end IF_tb;

ARCHITECTURE foo of IF_tb is
COMPONENT IF_stage is
PORT(
	PC_counter_init: IN STD_LOGIC;
	mux_control: IN STD_LOGIC;
	PC_instr_from_EX: IN INTEGER;
	CLK: IN STD_LOGIC;
	control_vector: IN STD_LOGIC_VECTOR(1 downto 0); --stalling signal
	PC_instr_plus4_out: OUT INTEGER;
	program_instruction: OUT STD_LOGIC_VECTOR(31 downto 0)
);
END COMPONENT;

	CONSTANT instr_mem_ram_size : integer := 1024;
	CONSTANT clk_period: time := 1 ns;
	SIGNAL control_vector: STD_LOGIC_VECTOR(1 downto 0):="00";
	SIGNAL PC_counter_init: STD_LOGIC:= '1';
	SIGNAL mux_control: STD_LOGIC:='0';
	SIGNAL PC_instr_from_EX: INTEGER:=0;
	SIGNAL CLK: STD_LOGIC:= '0';
	SIGNAL PC_instr_plus4_out: INTEGER:= 0;
	SIGNAL program_instruction: STD_LOGIC_VECTOR(31 downto 0):= x"00000000";
BEGIN

DUT:
IF_stage PORT MAP(
	PC_counter_init,
	mux_control,
	PC_instr_from_EX,
	CLK,
	control_vector, --stalling signal
	PC_instr_plus4_out,
	program_instruction
);

clk_process : process
    BEGIN
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    END process;

test_process : process
FILE file_name:         text;
        VARIABLE line_num:      line;
	VARIABLE char_vector_to_store: std_logic_vector(31 downto 0);
BEGIN
	IF (now < 1 ps) THEN
	file_open (file_name, "C:\Users\Ankita\Documents\McGill\Winter2017\ECSE425_Project\A4_pipelined_processor\read.txt", READ_MODE);
	--Read through 1024 lines of text file and save to memory	
	For i in 0 to instr_mem_ram_size-1 LOOP
		PC_OUT<=i;
		readline (file_name, line_num); 
		read (line_num, char_vector_to_store);
		writedata <= char_vector_to_store;
		memwrite<='1';
		--WAIT FOR 0.0009 ns;	
		memwrite<='0';
		-- check if written in previous cycle
		if (i>1) then
			PC_OUT<=(i-1);
		end if;
		memread<='1';
		--WAIT FOR 0.0009 ns;	
		memread<='0';
	END LOOP;
	END IF;

	WAIT FOR 0.25 ns;	
	memread <= '0';
	WAIT FOR 0.25 ns;

	address <= 5; 
	memread <= '1';
	WAIT FOR 0.25 ns;	
	memread <= '0';	
	WAIT FOR 0.25 ns;
	END LOOP;
END process;

END ARCHITECTURE;