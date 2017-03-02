LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_signed.all;

ENTITY PC_instruction_counter IS

PORT(
PC_IN : IN std_logic_vector(31 downto 0);
PC_OUT : OUT std_logic_vector(31 downto 0));

END PC_instruction_counter;


ARCHITECTURE PC_instruction_counter_behaviour IS

END PC_instruction_counter_behaviour;