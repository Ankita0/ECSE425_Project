library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity register_file_tb is
end register_file_tb;

architecture arch of register_file_tb is

	Component register_file is
		Generic(W : natural := 32);
		port(
		clock: in std_logic;
		rs: in std_logic_vector(4 downto 0);
		rt: in std_logic_vector(4 downto 0);
		rd: in std_logic_vector(4 downto 0);
		reg_write: in std_logic;
		result: in std_logic_vector(W-1 downto 0);
		reg_value1: out std_logic_vector(W-1 downto 0);
		reg_value2: out std_logic_vector(W-1 downto 0));
	end Component;

	constant clk_period : time := 1 ns;
	signal clk: std_logic :='0';
	signal rs: std_logic_vector(4 downto 0) := (others => '0');
	signal rt: std_logic_vector(4 downto 0) := (others => '0');
	signal rd : std_logic_vector(4 downto 0) := (others => '0');
	signal reg_write: std_logic :='0';
	signal result: std_logic_vector (31 downto 0) := (others => '0');
	signal reg_value1: std_logic_vector (31 downto 0) := (others => '0');
	signal reg_value2: std_logic_vector (31 downto 0) := (others => '0');

	begin

	dut: register_file
	Port MAP(clk,
			rs,
			rt,
			rd,
			reg_write,
			result,
			reg_value1,
			reg_value2);

	clk_process: process
	 begin
		    clk <='0';
		    wait for clk_period/2;
		    clk<='1';
		    wait for clk_period/2;

	end process;


	test:process   





	end process;

end arch;