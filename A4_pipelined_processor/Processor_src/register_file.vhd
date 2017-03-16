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
		if rs'event then
			if rs="00000" then	--register $0 is wired to 0x0000
				reg_value1=x"00000000";
			else
				reg_value1<=register_file_array(to_integer(unsigned(rs))); --value of the register
			end if;
		end if;	
		-- if there is a change in rt
		if rt'event then
			if rt="00000" then	--register $0 is wired to 0x0000
				reg_value2=x"00000000";
			else
				reg_value2<=register_file_array(to_integer(unsigned(rt))); --value of the register
			end if;
		end if;
			--write to register file
		if (rising_edge(clk) AND reg_write='1') then
			register_file_array(to_integer(unsigned(rd)))<=result;
		end if;
	end process;
end arch; 