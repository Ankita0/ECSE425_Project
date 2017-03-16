library ieee;
use ieee.std_logic_1164.all;

entity signextension is
port(
	bit16 : in std_logic_vector(15 downto 0);
	bit32 : out std_logic_vector(31 downto 0)
);
end signextension;

architecture arch of signextension is
begin
	bit32 <=	"0000000000000000" & bit16 when bit16(15) ='0' else 
				"1111111111111111" & bit16;
end arch;