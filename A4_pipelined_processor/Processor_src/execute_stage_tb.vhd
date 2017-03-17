library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity execute_stage_tb is
end execute_stage_tb;

architecture arch of execute_stage_tb is

Component execute_stage is
	Port(	

			clock: in std_logic;

			--Passing through IN
			IN_mem_write: in std_logic ;
			IN_mem_read: in std_logic ;
			IN_reg_write: in std_logic ;
			IN_reg_dst:in std_logic_vector(4 downto 0);

			-- ALU INPUT
			Input_A	: in std_logic_vector(31 downto 0);
			Input_B: in std_logic_vector(31 downto 0);
			alu_op_code: in std_logic_vector(4 downto 0);
			Jump: in std_logic;
			Branch: in std_logic;
			
			--ALU OUT
			branch_taken: out std_logic;
			result: out std_logic_vector(31 downto 0);

			--Passing through OUT to MEM/WB
			OUT_mem_write: out std_logic ;
			OUT_mem_read: out std_logic; 
			OUT_reg_write: out std_logic;
			OUT_reg_dst:out std_logic_vector(4 downto 0) );

	end Component;


begin

	dut : execute_stage
	PORT MAP();

end arch;