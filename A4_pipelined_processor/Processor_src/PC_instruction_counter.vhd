LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_signed.all;

ENTITY PC_instruction_counter IS

PORT(
PC_IN : IN std_logic_vector(31 downto 0);
INIT, CLK: IN std_logic;
PC : OUT std_logic_vector(31 downto 0));

END PC_instruction_counter;

ARCHITECTURE PC_instruction_counter_behaviour IS
SIGNAL ;
BEGIN
sync_PC: PROCESS(CLK, INIT)
BEGIN
	IF (rising_edge(INIT) and rising_edge(CLK)) THEN
		PC<= "00000000000000000000000000000000";
	ELSIF (rising_edge(CLK)) THEN
		PC<= PC_IN;
	END IF;
END PROCESS sync_PC;
END PC_instruction_counter_behaviour;