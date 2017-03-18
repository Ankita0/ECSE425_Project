library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity execute_stage_tb is
end execute_stage_tb;

architecture arch of execute_stage_tb is

Component execute_stage is
	Port(	

			clock: in std_logic;
			PC_IN: in integer;

			--Passing through IN
			IN_mem_write: in std_logic ;
			IN_mem_read: in std_logic ;
			IN_reg_write: in std_logic ;
			IN_r_dst_addr:in std_logic_vector(4 downto 0);

			-- ALU INPUT
			Input_A	: in std_logic_vector(31 downto 0);
			Input_B: in std_logic_vector(31 downto 0);
			alu_op_code: in std_logic_vector(4 downto 0);
			Jump: in std_logic;
			Branch: in std_logic;
			jump_addr: in std_logic_vector(25 downto 0);
			
			--ALU OUT
			result: out std_logic_vector(31 downto 0);
			PC_OUT: out integer;
			IF_MUX_CTRL: out std_logic;

			--Passing through OUT to MEM/WB
			OUT_mem_write: out std_logic ;
			OUT_mem_read: out std_logic; 
			OUT_reg_write: out std_logic;
			OUT_r_dst_addr:out std_logic_vector(4 downto 0));

	end Component;

	signal  clk: std_logic :='0';
	signal  PC_IN : integer := 0;
	signal  IN_mem_write : std_logic :='0';
	signal	IN_mem_read: std_logic :='0';
	signal	IN_reg_write: std_logic :='0';
	signal	IN_r_dst_addr: std_logic_vector(4 downto 0) := (others => '0');
	signal  Input_A	: std_logic_vector(31 downto 0):= (others => '0');
	signal	Input_B: std_logic_vector(31 downto 0):= (others => '0');
	signal	alu_op_code: std_logic_vector(4 downto 0):= (others => '0');
	signal	Jump: std_logic :='0';
	signal	Branch: std_logic :='0';
	signal  jump_addr: std_logic_vector(25 downto 0) := (others =>'0');
	signal	result: std_logic_vector(31 downto 0):= (others => '0');
	signal	PC_OUT: integer := 0;
	signal	IF_MUX_CTRL: std_logic :='0';
	signal 	OUT_mem_write: std_logic :='0';
	signal	OUT_mem_read: std_logic :='0'; 
	signal	OUT_reg_write: std_logic :='0';
	signal	OUT_r_dst_addr: std_logic_vector(4 downto 0):= (others => '0');

	begin

		dut : execute_stage
		PORT MAP(clk,
				PC_IN,
				IN_mem_write,
				IN_mem_read,
				IN_reg_write,
				IN_r_dst_addr,
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
				OUT_reg_write,
				OUT_r_dst_addr);

		clk_process : process
		    BEGIN
		        CLK <= '0';
		        wait for clk_period/2;
		        CLK <= '1';
		        wait for clk_period/2;
		    END process;

	    test: process
	    Variable var_result : std_logic_vector(31 downto 0);
	    begin
	    	var_result:=others=>'0';

	    	---TEST ALU OPERATION: ADD
	    	Input_A<=x"00000001";
	    	Input_B<=x"00000002";
	    	alu_op_code<="100000";
	    	wait for clk_period;
	    	ASSERT(result=x"00000003") REPORT "ALU OPERATIONS NOT WORKING" SEVERITY ERROR;

	    	--TEST PASSING
	    	PC_IN<=2;
	    	IN_mem_write<='1';
			IN_mem_read<='0';
			IN_reg_write<='1'
			IN_r_dst_addr<="00010";
			wait for clk_period;
			ASSERT(PC_OUT=2) REPORT "PC_OUT PASS NOT WORKING" SEVERITY ERROR;
			ASSERT 	(OUT_mem_write = '1') REPORT "MEM_WRITE PASS NOT WORKING" SEVERITY ERROR;
			ASSERT	(OUT_mem_read ='0') REPORT "MEM READ PASS OPERATIONS NOT WORKING" SEVERITY ERROR;
			ASSERT	(OUT_reg_write='1') REPORT "REG WRITE PASS NOT WORKING" SEVERITY ERROR;
			ASSERT	(OUT_r_dst_addr="00010") REPORT "REG DEST ADDR PASS NOT WORKING" SEVERITY ERROR;


	    	--TEST MFHI /MFLO
			Input_A <= x"FF00FF24";
			Input_B<= x"00028800";
			alu_op_code<="011000";
			wait for clk_period;

			alu_op_code<="010000"; --MOVE HI
			ASSERT (result = x"FFFFFD7A") REPORT "Hi is incorret should be FFFFFD7A !!" SEVERITY ERROR;
			wait for clk_period;


			alu_op_code<="010010"; --MOVE LO
			ASSERT (result = x"85D32000") REPORT "Lo is incorret should be 85D32000 !!" SEVERITY ERROR;

	    	--TEST LUI
	    	Input_B<=x"00001000";
	    	alu_op_code<="001111";
	    	wait for clk_period;
	    	ASSERT(result="10000000") REPORT "Lui incorret should be 10000000 !!" SEVERITY ERROR;

	    	--TEST SW

	    	--TEST LW

	    	--TEST BNE 
	    	Input_A<=x"00001000";
	    	Input_B<=x"01000000";
	    	Branch<='1';
	    	alu_op_code<="000101";
	    	wait for clk_period;
	    	var_result:=result;
	    	ASSERT(branch_taken = '1') REPORT "BNE-BRANCH TAKEN NOT SET!" SEVERITY ERROR;
	    	ASSERT(PC_OUT=var_result) REPORT "BNE-INCORRECT PC VALUE" SEVERITY ERROR;

	    	--TEST BEQ
	    	Input_A<=x"00001000";
	    	Input_B<=x"00001000";
	    	Branch<='1';
	    	alu_op_code<="000100";
	    	wait for clk_period;
	    	var_result:=result;
	    	ASSERT(branch_taken = '1') REPORT "BEQ-BRANCH TAKEN NOT SET!" SEVERITY ERROR;
	    	ASSERT(PC_OUT=var_result) REPORT "BEQ-INCORRECT PC VALUE" SEVERITY ERROR;

	    	--TEST JR
	    	Input_A<=x"00000002";
	    	Jump<='1';
	    	ASSERT(PC_OUT=2) REPORT "JR PC OUT IS SUPPOSED TO BE 2" SEVERITY ERROR;

	    	--TEST J
	    	Input_A<=x"00000006";
	    	Jump<='1';
	    	ASSERT(PC_OUT=6) REPORT "J PC OUT IS SUPPOSED TO BE 6" SEVERITY ERROR;


	    	--TEST JAL
	    	




	    end process;



end arch;