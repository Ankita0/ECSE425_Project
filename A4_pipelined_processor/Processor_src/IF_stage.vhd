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
	control_DE: IN STD_LOGIC;
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
	control_DE: in std_logic;
	PC_instr_plus4_out: OUT INTEGER
);
END COMPONENT;

	--CONSTANTS
	CONSTANT instr_mem_ram_size : integer := 1024;
	CONSTANT clk_period: time := 1 ns;

	--PC_counter
	SIGNAL PC_IN :  INTEGER:=0;
	--SIGNAL PC_counter_init_s: STD_LOGIC := '0';
	SIGNAL PC_OUT_2 :  INTEGER:=0;
	SIGNAL PC_OUT :  INTEGER:=0;
	-- mux
	--SIGNAL PC_instr_plus4: INTEGER:=0;
	SIGNAL PC_instr_to_fetch: INTEGER:=0;
	--instruction mem
	SIGNAL writedata:  STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL address: INTEGER :=0;
	SIGNAL memwrite: STD_LOGIC:= '0';
	SIGNAL memread: STD_LOGIC:= '0';
	SIGNAL readdata: STD_LOGIC_VECTOR (31 DOWNTO 0):= x"00000000";
	SIGNAL waitrequest: STD_LOGIC;
	-- adder
	--SIGNAL PC_instr_in: INTEGER:= 0;
	SIGNAL PC_inst_plus4: INTEGER:=0;
	
	--mapping signals
	SIGNAL counter_out: INTEGER:=0;
	SIGNAL final_count: INTEGER :=0;
	SIGNAL stall: std_logic:='0';
	
BEGIN

COUNTER:
PC_instruction_counter PORT MAP(
	PC_IN,
	PC_counter_init,
	PC_OUT_2
);

ADDER:
IF_adder PORT MAP(
	PC_OUT,
	stall,
	PC_inst_plus4
);

MUX:
IF_mux PORT MAP(
	PC_instr_from_EX,
	PC_inst_plus4,
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
	PC_OUT,
	memwrite,
	memread,
	readdata,
	waitrequest
);



init_process: PROCESS (CLK, PC_counter_init, mux_control,PC_instr_from_EX, control_DE)
BEGIN
if (rising_edge(CLK)) then
	PC_OUT<=PC_OUT_2;
	PC_count_out<=PC_instr_to_fetch;
  Instruction_out<=readdata;
	IF (PC_counter_init = '0')THEN
			--with stalls
			IF (control_DE= '0') THEN
				memread<='1';
				PC_IN<=PC_instr_to_fetch;

			ELSIF (control_DE= '1') THEN
					memread<='0';
					memwrite<='0';
					Instruction_out<=x"00000020";
					
			END IF;

	ELSIF (PC_counter_init = '1')THEN
		PC_IN<= 0;
		Instruction_out<=x"00000020";
	END IF;
end if;
END PROCESS;
	
END ARCHITECTURE;
