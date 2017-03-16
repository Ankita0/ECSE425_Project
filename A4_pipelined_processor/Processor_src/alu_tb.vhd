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

	constant clk_period : time := 1 ns;
	signal Mux_A, Mux_B : std_logic_vector(31 downto 0) :=(others=>'0');
	signal Alu_Ctrl : std_logic_vector(5 downto 0):=(others=>'0');
	signal shamt : std_logic_vector(4 downto 0):=(others=>'0');
	signal clk : std_logic := '0';
	signal  Hi 	: std_logic_vector(31 downto 0):=(others=>'0');
	signal Lo 	: std_logic_vector(31 downto 0):=(others=>'0');
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
				clk,
				shamt,
				Hi,
				Lo,
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
    			
    			--TEST SUB
    			Alu_Ctrl<="100010";
    			Mux_A <= x"FF22000F";
    			Mux_B<= x"0542C0F8";
    			wait for clk_period;
    			ASSERT (Alu_Rslt = x"F9DF3F17") REPORT "SUB FAILS!!" SEVERITY ERROR;
    			
    			--TEST ADD
 			 Alu_Ctrl<="100000";
    			Mux_A <= x"0000000F";
    			Mux_B<= x"FFFFFFF0";
    			wait for clk_period;
    			ASSERT (Alu_Rslt = x"FFFFFFFF") REPORT "ADD FAILS!!" SEVERITY ERROR;
   					
			 --TEST AND
			 Alu_Ctrl<="100100";
    			Mux_A <= x"FF22000F";
    			Mux_B<= x"0542C0F8";
    			wait for clk_period;
    			ASSERT (Alu_Rslt = x"05020008") REPORT "AND-ING FAILS!!" SEVERITY ERROR;
    			
    			--TEST OR
 			 Alu_Ctrl<="100101";
    			Mux_A <= x"FF22000F";
    			Mux_B<= x"0542C0F8";
    			wait for clk_period;
    			ASSERT (Alu_Rslt = x"FF62C0FF") REPORT "OR-ING FAILS!!" SEVERITY ERROR;
    			
    			--TEST XOR
  			 Alu_Ctrl<="100110";
    			Mux_A <= x"FF22000F";
    			Mux_B<= x"0542C0F8";
    			wait for clk_period;
    			ASSERT (Alu_Rslt = x"FA60C0F7") REPORT "XOR-ING FAILS!!" SEVERITY ERROR;
    			
    			--TEST NOR
  			 Alu_Ctrl<="100111";
    			Mux_A <= x"FF00FF24";
    			Mux_B<= x"00028800";
    			wait for clk_period;
    			ASSERT (Alu_Rslt = x"00FD00DB") REPORT "NOR-ING FAILS!!" SEVERITY ERROR;
    			
    			--TEST MULT
    			Alu_Ctrl<="011000";
    			Mux_A <= x"FF00FF24";
    			Mux_B<= x"00028800";
    			wait for clk_period;
    			ASSERT (Hi = x"FFFFFF7A") REPORT "Hi is incorret should be FFFFFF7A !!" SEVERITY ERROR;
    			ASSERT (Lo = x"85D32000") REPORT "Lo is incorret should be 85D32000 !!" SEVERITY ERROR;
    			
    			--TEST DIV
    			Alu_Ctrl<="011010";
    			Mux_A <= x"FF00FF24";
    			Mux_B<= x"00028800";
    			wait for clk_period;
		   		ASSERT (Hi = x"FFFE1F24") REPORT "Hi is incorret should be FFFE1F24 !!" SEVERITY ERROR;
    			ASSERT (Lo = x"FFFFFF9C") REPORT "Lo is incorret should be FFFFFF9C !!" SEVERITY ERROR;
    			
    			--TEST SLT
 			
    			
    			--TEST SLL
    			
    			--TEST SRL
    			
    			--TEST SRA
    			
    			--TEST MFHI
    			
    			--TEST MFLO
    			
    			--TEST of I Types

    			


  end process;

end arch;