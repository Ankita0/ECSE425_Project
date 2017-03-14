library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu_testbed is
end alu_testbed;

architecture arch of alu_testbed is

	Component alu is

	Generic( W : natural := 32; 
	         F : natural :=6;
	         clock_period : time := 1 ns);
	
	port( 	Mux_A	: in  std_logic_vector(W-1 downto 0);
			Mux_B	: in  std_logic_vector(W-1 downto 0);
			Alu_Ctrl: in  std_logic_vector(F-1 downto 0);
			shamt	: in std_logic_vector (F-2 downto 0);
			clock : in std_logic;
			Alu_Rslt: out std_logic_vector(W-1 downto 0);
			Zero 	: out std_logic;
			Overflow: out std_logic;
			Carryout: out std_logic);
	end Component;

	constant clk_period : time := 1 ns;
	signal Mux_A, Mux_B : std_logic_vector(31 downto 0) :=(others=>'0');
	signal Alu_Ctrl : std_logic_vector(5 downto 0):=(others=>'0');
	signal shamt : std_logic_vector(4 downto 0):=(others=>'0');
	signal clk : std_logic := '0';
	signal Alu_Rslt : std_logic_vector(31 downto 0):=(others=>'0');
	signal Zero : std_logic := '0';
	signal Overflow : std_logic := '0';
	signal Carryout : std_logic := '0';

	BEGIN

		dut: alu 
			PORT MAP(
				Mux_A,
				Mux_B,
				Alu_Ctrl,
				shamt,
				clk,
				Alu_Rslt,
				Zero,	
				Overflow,
				Carryout);
				
		clk_process: process
		  begin
		    clk <='0';
		    wait for clk_period/2;
		    clk<='1';
		    wait for clk_period/2;
		   end process;
		   

		test_process: process

			BEGIN

    			--wait for 10 ns;
    			
    			--TEST and
    			Alu_Ctrl<="100010";
    			Mux_A <= x"FF22000F";
    			Mux_B<= x"0542C0F8";
    			wait for clk_period;
    			ASSERT (Alu_Rslt = x"F9DF3F17") REPORT "SUB works!!" SEVERITY ERROR;
    			
    			
			 Alu_Ctrl<="100100";
    			Mux_A <= x"FF22000F";
    			Mux_B<= x"0542C0F8";
    			wait for clk_period;
    			ASSERT (Alu_Rslt = x"05020008") REPORT "ANDING works!!" SEVERITY ERROR;


  end process;

end arch;