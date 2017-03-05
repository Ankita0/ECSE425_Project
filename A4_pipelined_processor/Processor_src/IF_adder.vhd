LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_signed.all;

ENTITY IF_adder IS
PORT(
PC_instr_in: IN STD_LOGIC_VECTOR(31 downto 0);
CLK: IN STD_LOGIC;
PC_instr_plus4_out: OUT STD_LOGIC_VECTOR(31 downto 0)
);
END IF_adder;


ARCHITECTURE behaviour OF IF_adder IS
--Declare signal with integer value 4
SIGNAL signal_four: STD_LOGIC_VECTOR(31 downto 0) := "00000000000000000000000000000100";
BEGIN

--Clock synchronized add 4 to program instruction count
PC_count_up: PROCESS(PC_instr_in, CLK)
BEGIN
	IF (rising_edge(CLK)) THEN
		PC_instr_plus4_out <= PC_instr_in AND signal_four;
	END IF;
END PROCESS PC_count_up;
END behaviour;
