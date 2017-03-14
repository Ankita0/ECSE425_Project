library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu_testbed is


end alu_testbed;

architecture arch of alu_testbed is

	Component alu is

	Generic(W : natural := 32; F : natural :=6;clock_period : time := 1 ns);
	
	port( 	Mux_A	: in  std_logic_vector(W-1 downto 0);
			Mux_B	: in  std_logic_vector(W-1 downto 0);
			Alu_Ctrl: in  std_logic_vector(F-1 downto 0);
			Shift	: in std_logic_vector (F-2 downto 0);
			clock 	: in std_logic;
			Alu_Rslt: out std_logic_vector(W-1 downto 0);
			Zero 	: out std_logic;
			Overflow: out std_logic;
			Carryout: out std_logic);
	end Component;

	constant clk_period : time := 1 ns;
	signal clock : std_logic := '0';
	signal Mux_A, Mux_B : std_logic_vector(W-1 downto 0);
	signal Alu_Ctrl : std_logic_vector(W-1 downto 0);
	signal Shift : std_logic_vector(F-1 downto 0);
	signal Alu_Rslt : std_logic_vector(W-1 downto 0);
	signal Zero : out std_logic;
	signal Overflow : out std_logic;
	signal Carryout : out std_logic;

	BEGIN

		dut: alu
			PORT_MAP(
				Mux_A,
				Mux_B,
				Alu_Ctrl,
				Shift,
				clock,
				Alu_Rslt,
				Zero,	
				Overflow,
				Carryout);

		process

			BEGIN

    			wait for clk_period;




end arch;