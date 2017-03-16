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
	SIGNAL PC_IN : INTEGER;
	SIGNAL INIT : STD_LOGIC:='1';
	SIGNAL PC_OUT : INTEGER;
	-- mux
	--SIGNAL PC_instr_from_EX: INTEGER;
	SIGNAL PC_instr_plus4: INTEGER;
	--SIGNAL mux_control: STD_LOGIC; 
	SIGNAL PC_instr_to_fetch: INTEGER :=0;
	--instruction mem
	SIGNAL writedata:  STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL address: INTEGER RANGE 0 TO instr_mem_ram_size-1;
	SIGNAL memwrite: STD_LOGIC;
	SIGNAL memread: STD_LOGIC;
	SIGNAL readdata: STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL waitrequest: STD_LOGIC;
	-- adder
	SIGNAL PC_instr_in: INTEGER;
	--SIGNAL PC_instr_plus4_out: INTEGER;
	
BEGIN
ADDER:
IF_adder PORT MAP(
	PC_instr_in,
	PC_instr_plus4
);

COUNTER:
PC_instruction_counter PORT MAP(
	PC_IN,
	INIT,
	PC_OUT
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

INIT<=PC_counter_init;
--mux_control<= mux_control;
--PC_instr_from_EX<= PC_instr_from_EX;
--clk<= CLK;
--control_vector<= control_vector;
PC_IN<=PC_instr_to_fetch;


controller_process: PROCESS(PC_counter_init, mux_control, PC_instr_from_EX, CLK, control_vector)
BEGIN
	IF (rising_edge(CLK))THEN
		if (control_vector(0)= '0') then
		--normal operation depending on inputs
			memread<='1';
			memwrite<='0';
			PC_instr_in<=PC_OUT;
			Instruction_out<=readdata;
		elsif (control_vector(0)= '1') then
		--stalls
			memread<='1';
			Instruction_out<=x"00000000";
		end if;
	END IF;
	
END PROCESS;
	
END ARCHITECTURE;