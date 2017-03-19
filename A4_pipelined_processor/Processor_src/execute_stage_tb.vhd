--EXECUTE PIPELINE STAGE FOR ECSE 425 PROJECT WINTER 2017
--GROUP 8
--Author: Alina Mambo
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity execute_stage_tb is
end execute_stage_tb;

architecture arch of execute_stage_tb is

Component execute_stage is
	Port(	

			clock: in std_logic;
			PC_IN: in integer; -- PC from IF and Decode

			--Passing through IN
			IN_mem_write: in std_logic; --MEM write
			IN_mem_read: in std_logic;  --- MEM READ
			IN_mem_data_wr: in std_logic_vector(31 downto 0); --WRITE DATA TO MEM
			IN_wb_write: in std_logic; -- WB WRITE
			IN_wb_addr:in std_logic_vector(4 downto 0);

			-- ALU INPUT
			Input_A	: in std_logic_vector(31 downto 0);
			Input_B: in std_logic_vector(31 downto 0);
			alu_op_code: in std_logic_vector(5 downto 0);
			Jump: in std_logic;
			Branch: in std_logic;
			jump_addr: in std_logic_vector(25 downto 0);
			
			--ALU OUT
			result: out std_logic_vector(31 downto 0);
			PC_OUT: out integer;
			IF_MUX_CTRL: out std_logic;

			--Passing through OUT to MEM/WB
			OUT_mem_write: out std_logic;
			OUT_mem_read: out std_logic; 
			OUT_mem_data_wr: out std_logic_vector(31 downto 0);
			OUT_wb_write:out std_logic;
			OUT_wb_addr: out std_logic_vector(4 downto 0));
	
	end Component;

	constant clk_period: time := 1 ns;
	signal  clk: std_logic :='0';
	signal  PC_IN : integer := 0;
	signal  IN_mem_write : std_logic :='0';
	signal	IN_mem_read: std_logic :='0';
	signal IN_mem_data_wr: std_logic_vector(31 downto 0):= (others => '0');
	signal	IN_wb_write: std_logic :='0';
	signal	IN_wb_addr: std_logic_vector(4 downto 0) := (others => '0');
	signal  Input_A	: std_logic_vector(31 downto 0):= (others => '0');
	signal	Input_B: std_logic_vector(31 downto 0):= (others => '0');
	signal	alu_op_code: std_logic_vector(5 downto 0):= (others => '0');
	signal	Jump: std_logic :='0';
	signal	Branch: std_logic :='0';
	signal  jump_addr: std_logic_vector(25 downto 0) := (others =>'0');
	signal	result: std_logic_vector(31 downto 0):= (others => '0');
	signal	PC_OUT: integer := 0;
	signal	IF_MUX_CTRL: std_logic :='0';
	signal 	OUT_mem_write: std_logic :='0';
	signal	OUT_mem_read: std_logic :='0'; 
	signal OUT_mem_data_wr: std_logic_vector(31 downto 0):= (others =>'0');
	signal	OUT_wb_write: std_logic :='0';
	signal	OUT_wb_addr: std_logic_vector(4 downto 0):= (others => '0');

	begin

		dut : execute_stage
		PORT MAP(clk,
				PC_IN,
				IN_mem_write,
				IN_mem_read,
				IN_mem_data_wr,
				IN_wb_write,
				IN_wb_addr,
				Input_A,
				Input_B,
				alu_op_code,
				Jump,
				Branch,
				jump_addr,
				result,
				PC_OUT,
				IF_MUX_CTRL,
				OUT_mem_write,
				OUT_mem_read,
				OUT_mem_data_wr,
				OUT_wb_write,
				OUT_wb_addr);

		clk_process : process
		    BEGIN
		        CLK <= '0';
		        wait for clk_period/2;
		        CLK <= '1';
		        wait for clk_period/2;
		    END process;

	    test: process
	    Variable var_result : std_logic_vector(31 downto 0);
	    Variable pc_int : integer;
	    begin
	    	var_result:= (others=>'0');
	    	pc_int := 0;
	    	
	     IF_MUX_CTRL<= '0';
	    	
	    	
	    	--wait for clk_period;

	    	---TEST ALU OPERATION: ADD
	    	Input_A<=x"00000001";
	    	Input_B<=x"00000002";
	    	alu_op_code<="100000";
	    	wait for clk_period;
	    	
	    	
	    	 	--TEST MULT
			Input_A <= x"FF00FF24";
			Input_B<= x"00028800";
			alu_op_code<="011000";
			wait for clk_period;
      ASSERT(result=x"00000003") REPORT "ALU OPERATIONS NOT WORKING" SEVERITY ERROR;
      
	    	--TEST PASSING
	    	Input_A<=x"00000000";
	    	Input_B<=x"00000000";
	    IN_mem_write<='1';
			IN_mem_read<='0';
			IN_wb_write<='1';
			IN_wb_addr<="00010";
			wait for clk_period;
			ASSERT 	(OUT_mem_write = '1') REPORT "MEM_WRITE PASS NOT WORKING" SEVERITY ERROR;
			ASSERT	(OUT_mem_read ='0') REPORT "MEM READ PASS OPERATIONS NOT WORKING" SEVERITY ERROR;
			ASSERT	(OUT_wb_write='1') REPORT "REG WRITE PASS NOT WORKING" SEVERITY ERROR;
			ASSERT	(OUT_wb_addr="00010") REPORT "REG DEST ADDR PASS NOT WORKING" SEVERITY ERROR;

	   --TEST MOVE HI
			alu_op_code<="010000"; 
			wait for clk_period;
			
		  ASSERT (result = x"FFFFFD7A") REPORT "Hi is incorret should be FFFFFD7A !!" SEVERITY ERROR;

      	
			alu_op_code<="010010"; --MOVE LO
			wait for clk_period;
			ASSERT (result = x"85D32000") REPORT "Lo is incorret should be 85D32000 !!" SEVERITY ERROR;
			

--	    	--TEST LUI
	    	Input_B<=x"00001000";
	    	alu_op_code<="001111";
	    	wait for clk_period;
	    	ASSERT(result=x"10000000") REPORT "Lui incorret should be 10000000 !!" SEVERITY ERROR;
	  

	    	
	    	--TEST BNE 
	    	Input_A<=x"00001000";
	    	Input_B<=x"01000000";
	    	Branch<='1';
	    	alu_op_code<="100000";
	    	wait for clk_period;
	    	var_result:=result;
	    	pc_int= to_integer(unsigned(var_result));
	    	ASSERT(PC_OUT=pc_int) REPORT "BNE-INCORRECT PC VALUE" SEVERITY ERROR;
	    	

	    	--TEST BEQ
	    	Input_A<=x"00001000";
	    	Input_B<=x"00001000";
	    	Branch<='1';
	    	alu_op_code<="100000";
	    	wait for clk_period;
	    	var_result:=result;
	    	ASSERT(PC_OUT=to_integer(unsigned(var_result))) REPORT "BEQ-INCORRECT PC VALUE" SEVERITY ERROR;
	    

	    	--TEST JR
	    	Input_A<=x"00000002";
	    	Branch <= '0';
	    	Jump<='1';
	    	wait for clk_period;
	    	ASSERT(PC_OUT=2) REPORT "JR PC OUT IS SUPPOSED TO BE 2" SEVERITY ERROR;
	    	

	    	--TEST J
	    	Input_A<=x"00000006";
	    	Jump<='1';
	    	wait for clk_period;
	    	ASSERT(PC_OUT=6) REPORT "J PC OUT IS SUPPOSED TO BE 6" SEVERITY ERROR;
	    


	    	--TEST JAL
	    	jump_addr<="00000000000000000000011111"; 
	    	Input_A<=std_logic_vector(to_unsigned(5,32)); --PC COUNT
	    	Input_B<=std_logic_vector(to_unsigned(2,32)); --PC + 8
	    	wait for clk_period;
	    
	    	
	    	wait for clk_period;
	    	ASSERT(result=x"00000007") REPORT "JAL- ADDI DID NOT CALC THE CORRECT PC ADDRESS" SEVERITY ERROR;
	    	ASSERT(PC_OUT=31) REPORT "JAL- DID NOT GET THE CORRECT JUMP ADDRESS" SEVERITY ERROR;


	    end process;


end arch;