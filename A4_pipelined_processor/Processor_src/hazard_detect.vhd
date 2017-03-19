library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hazard_detect is
	port(
	clock: in std_logic;
	instruction_in: in std_logic_vector(31 downto 0);
	rs: in std_logic_vector(4 downto 0);
	rt: in std_logic_vector(4 downto 0);
	rd: in std_logic_vector(4 downto 0);

	instruction_out: out std_logic_vector(31 downto 0)
	);
end hazard_detect;

architecture arch of hazard_detect is
begin
	process(clock,instruction_in)
	begin
		-- if stall
			if  then	
				instruction_out<=x"00000000";
			else
				instruction_out<=instruction_in;
			end if;

	end process;
end arch; 