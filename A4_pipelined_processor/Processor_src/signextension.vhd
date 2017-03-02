library ieee;
use ieee.std_logic_1164.all;

entity signextension is
port(
	16b_instruction : in std_logic_vector(15 downto 0);
	32b_instruction : out std_logic_vector(31 downto 0)
);
end signextension;

architecture arch of signextension is
begin
	32b_instruction <=	"0000000000000000" & 16b_instruction when 16b_instruction(15) ='0' else 
						"1111111111111111" & 16b_instruction;
end arch;