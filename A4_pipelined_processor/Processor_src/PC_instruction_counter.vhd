LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_signed.all;

ENTITY PC_instruction_counter IS
PORT(
	PC_IN : IN INTEGER;
	INIT : IN STD_LOGIC;
	CLK : IN STD_LOGIC;
	PC : OUT INTEGER
);
END PC_instruction_counter;

ARCHITECTURE arch OF PC_instruction_counter IS
BEGIN

--Clock synchronized process for updating program counter component. With reset
update_PC: PROCESS(CLK, INIT)
BEGIN
	--Reset to initialize PC
	IF (rising_edge(INIT)) THEN
		PC<= 0;
	--Update PC instruction on clock rising edge
	ELSIF (rising_edge(CLK)) THEN
		PC<= PC_IN;
	END IF;
END PROCESS update_PC;
END arch;