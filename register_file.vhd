library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity register_file is
	Generic(W : natural := 32);
	port(
	clock: in std_logic;
	rs: in std_logic_vector(4 downto 0);
	rt: in std_logic_vector(4 downto 0);
	rd: in std_logic_vector(4 downto 0);
	reg_write: in std_logic;
	result: in std_logic_vector(W-1 downto 0);
	reg_value1: out std_logic_vector(W-1 downto 0);
	reg_value2: out std_logic_vector(W-1 downto 0)	
	);
end register_file;

architecture arch of register_file is
	type register_file_vector is array(W-1 downto 0) of std_logic_vector(W-1 downto 0);
	signal register_file_array: register_file_vector;
begin
	process(clock,rs,rt,rd)
	begin
		-- if there is a change in rs
		IF(now < 1 ps)THEN
		For i in 0 to 31 LOOP
				register_file_array(i) <= std_logic_vector(to_unsigned(0,32));
			END LOOP;
		end if;
		
			if (unsigned(rs))="00000" then	--register $0 is wired to 0x0000
				reg_value1<=x"00000000";
			else
				reg_value1<=register_file_array(to_integer(unsigned(rs))); --value of the register
			end if;
	--	end if;	
		-- if there is a change in rt
			if (unsigned(rt))="00000" then	--register $0 is wired to 0x0000
				reg_value2<=x"00000000";
			else
				reg_value2<=register_file_array(to_integer(unsigned(rt))); --value of the register
			end if;
		--end if;
			--write to register file
		if (rising_edge(clock) AND reg_write='1') then
			register_file_array(to_integer(unsigned(rd)))<=result;
		end if;
	end process;
end arch; 