library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity execute_stage is

	Port(	A,B,C,D,E: in std_logic_vector (31 downto 0)
			W,X,Y.Z: out std_logic_vector(31 downto 0));


end execute_stage;


architecture testbed of execute_stage is

Component alu is

	Generic( W : natural := 32; 
	         F : natural :=6;
	         clock_period : time := 1 ns);
	
	port( 		Mux_A	: in  std_logic_vector(W-1 downto 0);
			   Mux_B	: in  std_logic_vector(W-1 downto 0);
			   Alu_Ctrl	: in  std_logic_vector(F-1 downto 0);
			   clock 	: in std_logic;
			   shamt	: in std_logic_vector (F-2 downto 0);
			   Hi 		: out std_logic_vector(W-1 downto 0);
	       	   Lo 		: out std_logic_vector(W-1 downto 0);
			   Alu_Rslt	: out std_logic_vector(W-1 downto 0);
			   Zero 	: out std_logic;
			   Overflow	: out std_logic;
			   Carryout	: out std_logic);
	end Component;

Component Mux_1 is

PORT(ID_instr_1, ID_instr_2 : in std_logic_vector(31 downto 0);
		mux_control,CLK: in std_logic;
		instr_to_Ex: out std_logic_vector(31 downto 0));
end Component;

Component Mux_2 is
PORT(ID_instr_1, ID_instr_2 : in std_logic_vector(31 downto 0);
		mux_control,CLK: in std_logic;
		instr_to_Ex: out std_logic_vector(31 downto 0));
end Component;



signal Hi: std_logic_vector (31 downto 0) :=(others=>'0');
signal Lo: std_logic_vector (31 downto 0) :=(others=>'0');

begin
	




end testbed;
