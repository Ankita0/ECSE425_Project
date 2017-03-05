library ieee;
use ieee.std_logic_1164.all;

entity signextension is
port(
	bit16_instruction : in std_logic_vector(15 downto 0);
	bit32_instruction : out std_logic_vector(31 downto 0)
);
end signextension;

architecture arch of signextension is
begin
	bit32_instruction <=	"0000000000000000" & bit16_instruction when bit16_instruction(15) ='0' else 
						"1111111111111111" & bit16_instruction;
end arch;