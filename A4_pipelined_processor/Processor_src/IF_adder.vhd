LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_signed.all;

ENTITY IF_adder IS
PORT(
PC_instr_in: IN INTEGER;
CLK: IN STD_LOGIC;
PC_instr_plus4_out: OUT INTEGER
);
END IF_adder;


ARCHITECTURE arch OF IF_adder IS
--Declare signal with integer value 4
BEGIN

--Clock synchronized add 4 to program instruction count
PC_count_up: PROCESS(PC_instr_in, CLK)
BEGIN
	IF (rising_edge(CLK)) THEN
		PC_instr_plus4_out <= PC_instr_in+ 4;
	END IF;
END PROCESS PC_count_up;
END arch;
