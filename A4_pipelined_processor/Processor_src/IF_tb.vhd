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
	PC_count_out: OUT INTEGER;
	Instruction_out: OUT STD_LOGIC_VECTOR(31 downto 0)
);
END COMPONENT;

	CONSTANT instr_mem_ram_size : integer := 1024;
	CONSTANT clk_period: time := 1 ns;
	SIGNAL control_vector: STD_LOGIC_VECTOR(1 downto 0):="00";
	SIGNAL PC_counter_init: STD_LOGIC;
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
        CLK <= '0';
        wait for clk_period/2;
        CLK <= '1';
        wait for clk_period/2;
    END process;


test_process : process

BEGIN
	if (now <1 ps) then
		PC_counter_init<= '0';
	end if;
	control_vector<= "00";
	WAIT FOR 1024*clk_period;
	PC_counter_init<= '1';
	WAIT FOR 1*clk_period;
	PC_counter_init<= '0';
	WAIT FOR 1*clk_period;
END process;

END ARCHITECTURE;