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
	control_EX: IN STD_LOGIC; --stalling signal
	control_DE: IN STD_LOGIC;
	PC_count_out: OUT INTEGER;
	Instruction_out: OUT STD_LOGIC_VECTOR(31 downto 0)
);
END COMPONENT;

	CONSTANT instr_mem_ram_size : integer := 1024;
	CONSTANT clk_period: time := 1 ns;
	SIGNAL control_DE: STD_LOGIC:='0';
	SIGNAL control_EX: STD_LOGIC:='0';
	SIGNAL PC_counter_init: STD_LOGIC:='0';
	SIGNAL mux_control: STD_LOGIC:='0';
	SIGNAL PC_instr_from_EX: INTEGER:=18;
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
	control_EX, --stalling signal
	control_DE,
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
	PC_counter_init<= '0';
	control_EX<= '0';
	control_DE<= '0';
	PC_counter_init<= '1' after 1024 ns;
	PC_counter_init<= '0' after 1025 ns;
	WAIT FOR 1*clk_period;
END process;

END ARCHITECTURE;