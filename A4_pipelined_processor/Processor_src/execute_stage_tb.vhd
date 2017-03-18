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

	    begin

	    	---TEST ALU OPERATION: ADD

	    	--TEST ALU OPERATION: AND

	    	--TEST MFHI

	    	--TEST MFLO

	    	--TEST LUI

	    	--TEST BNE 

	    	--TEST BEQ

	    	--TEST JR

	    	--TEST J

	    	--TEST JAL




	    end process;



end arch;