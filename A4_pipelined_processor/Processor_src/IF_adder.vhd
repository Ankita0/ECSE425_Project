LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_signed.all;

ENTITY IF_adder IS
PORT(
PC_instr_in: IN INTEGER;
stall: in std_logic;
PC_instr_plus4_out: OUT INTEGER
);
END IF_adder;


ARCHITECTURE arch OF IF_adder IS
--Declare signal with integer value 4
BEGIN

--Add 1 to program instruction count
PC_count_up: PROCESS(PC_instr_in)
BEGIN
	if stall='0' then
		PC_instr_plus4_out <= PC_instr_in+ 1;
	else
		PC_instr_plus4_out <= PC_instr_in;
	end if;
END PROCESS PC_count_up;
END arch;
