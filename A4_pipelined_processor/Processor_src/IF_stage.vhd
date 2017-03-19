LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_textio.all;
USE STD.textio.all;

ENTITY IF_stage is
PORT(
	PC_counter_init: IN STD_LOGIC;
	mux_control: IN STD_LOGIC;
	PC_instr_from_EX: IN INTEGER;
	CLK: IN STD_LOGIC;
	control_vector: IN STD_LOGIC_VECTOR(1 downto 0); --stalling signal
	PC_count_out: OUT INTEGER;
	Instruction_out: OUT STD_LOGIC_VECTOR(31 downto 0)
);
END IF_stage;

ARCHITECTURE IF_controller of IF_stage IS

COMPONENT PC_instruction_counter IS
PORT(
	PC_IN : IN INTEGER;
	INIT : IN STD_LOGIC;
	PC_OUT : OUT INTEGER
);
END COMPONENT;

COMPONENT IF_mux IS
PORT(
	PC_instr_from_EX: IN INTEGER;
	PC_instr_plus4: IN INTEGER;
	mux_control: IN STD_LOGIC; 
	PC_instr_to_fetch: OUT INTEGER
);
END COMPONENT;

COMPONENT instruction_memory IS
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
END COMPONENT;

COMPONENT IF_adder IS
PORT(
	PC_instr_in: IN INTEGER;
	PC_instr_plus4_out: OUT INTEGER
);
END COMPONENT;

	--CONSTANTS
	CONSTANT instr_mem_ram_size : integer := 1024;
	CONSTANT clk_period: time := 1 ns;

	--PC_counter
	SIGNAL PC_IN :  INTEGER:=0;
	SIGNAL PC_OUT :  INTEGER:=0;
	-- mux
	SIGNAL PC_instr_plus4: INTEGER:=0;
	SIGNAL PC_instr_to_fetch: INTEGER:=0;
	--instruction mem
	SIGNAL writedata:  STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL address: INTEGER RANGE 0 TO instr_mem_ram_size-1 :=0;
	SIGNAL memwrite: STD_LOGIC:= '0';
	SIGNAL memread: STD_LOGIC:= '0';
	SIGNAL readdata: STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL waitrequest: STD_LOGIC;
	-- adder
	SIGNAL PC_instr_in: INTEGER:= 0;
	SIGNAL PC_inst_plus4_out: INTEGER:=0;
	
	--mapping signals
	SIGNAL counter_out: INTEGER:=0;
	SIGNAL final_count: INTEGER :=0;
	--SIGNAL init_done: INTEGER:=0;
	
BEGIN

COUNTER:
PC_instruction_counter PORT MAP(
	PC_IN,
	PC_counter_init,
	PC_OUT
);
ADDER:
IF_adder PORT MAP(
	PC_instr_in,
	PC_inst_plus4_out
);

MUX:
IF_mux PORT MAP(
	PC_instr_from_EX,
	PC_instr_plus4,
	mux_control,
	PC_instr_to_fetch
);

PC:
instruction_memory GENERIC MAP(
		ram_size => 1024
	)
	PORT MAP(
	CLK,
	writedata,
	address,
	memwrite,
	memread,
	readdata,
	waitrequest
);

PC_instr_in<=counter_out;
address<=counter_out;
PC_instr_plus4<= PC_inst_plus4_out;

init_process: PROCESS
	FILE file_name:         	text;
        VARIABLE line_num:      	line;
	VARIABLE char_vector_to_store: 	std_logic_vector(31 downto 0);
BEGIN

IF (now < 1024 ns) THEN
	file_open (file_name, "C:\Users\Ankita\Documents\McGill\Winter2017\ECSE425_Project\A4_pipelined_processor\read.txt", READ_MODE);
	--Read through 1024 lines of text file and save to memory	
	For i in 0 to instr_mem_ram_size-1 LOOP
		counter_out<= i;
		readline (file_name, line_num); 
		read (line_num, char_vector_to_store);
		writedata <= char_vector_to_store;
		memwrite<='1';
		WAIT FOR 0.5 ns;
		Instruction_out<=readdata;
		final_count<= PC_instr_to_fetch;
		PC_count_out <= PC_instr_to_fetch;
		memwrite<='0';
	END LOOP;

	FOR j in 0 to instr_mem_ram_size-1 LOOP
		-- check if written in previous cycle
		counter_out<=j;
		memread<='1';
		WAIT FOR 0.5 ns;
		Instruction_out<=readdata;
		final_count<= PC_instr_to_fetch;
		PC_count_out <= PC_instr_to_fetch;
		memread<='0';
	END LOOP;
end if;
counter_out<=PC_OUT;

if (now>=1024 ns) then
	IF (rising_edge(CLK)and PC_counter_init = '0')THEN
			--with stalls
			case control_vector is 
				when "00" =>
					--normal operation depending on inputs
					memread<='1';
					memwrite<='0';
					PC_count_out <= PC_instr_to_fetch;
					PC_IN<=final_count;
					Instruction_out<=readdata;
					memread<='0';
				when "01" =>
					memread<='0';
					memwrite<='0';
					Instruction_out<=x"00000020";

				when "10"=>

				when "11"=>

			
		
	ELSIF (rising_edge(CLK)and PC_counter_init = '1')THEN
		PC_count_out<= 0;
		PC_IN<= 0;
		Instruction_out<=x"00000020";
	END IF;
end if;
END PROCESS;
	
END ARCHITECTURE;