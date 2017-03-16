LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY PC_instruction_counter_tb is
end PC_instruction_counter_tb;

ARCHITECTURE foo of pc_instruction_counter_tb is
COMPONENT PC_instruction_counter IS
PORT(
	PC_IN : IN INTEGER;
	INIT : IN STD_LOGIC;
	PC_OUT : OUT INTEGER
);
END COMPONENT;

SIGNAL PC_IN: INTEGER := 0;
SIGNAL PC_OUT: INTEGER := 0;
SIGNAL INIT: STD_LOGIC:= '1';

BEGIN

DUT:
PC_instruction_counter PORT MAP(
	PC_IN,
	INIT,
	PC_OUT
);

simulation: process
BEGIN
	WAIT FOR 0.5 ns;
	INIT<='0';
	WAIT FOR 0.5 ns; -- value changes between falloing and rising edge of clock
	ASSERT PC_OUT = 0 REPORT "init unsuccessful" SEVERITY error;
	PC_IN<= 4;
	WAIT FOR 0.5 ns;
	ASSERT PC_OUT = 4 REPORT "update unsuccessful" SEVERITY error;
	PC_IN<= 2;
	WAIT FOR 0.5 ns;
	ASSERT PC_OUT = 6 REPORT "update unsuccessful" SEVERITY error;
	INIT<='1';
	WAIT FOR 0.5 ns;
	INIT<='0';
	WAIT;
END process;

END ARCHITECTURE;