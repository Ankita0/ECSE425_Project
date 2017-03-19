LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_textio.all;
USE STD.textio.all; 


entity Pipelined_Processor_tb is
end Pipelined_Processor_tb;

ARCHITECTURE arch of Pipelined_Processor_tb is
COMPONENT Pipelined_Processor is
PORT(
	PP_Init: IN STD_LOGIC;
	PP_CLK: IN STD_LOGIC;
	POOP: IN STD_LOGIC;
	PP_reg_data: OUT STD_LOGIC_VECTOR(31 downto 0);
	PP_mm_data: OUT STD_LOGIC_VECTOR(31 downto 0)
);
END COMPONENT;
      
	SIGNAL 

BEGIN

DUT: 
Pipelined_Processor PORT MAP(

);
	clk_process: process
	 begin
		    clk <='0';
		    wait for clk_period/2;
		    clk<='1';
		    wait for clk_period/2;

	end process;

test_process: PROCESS (clk)

BEGIN

END PROCESS;

END ARCHITECTURE;