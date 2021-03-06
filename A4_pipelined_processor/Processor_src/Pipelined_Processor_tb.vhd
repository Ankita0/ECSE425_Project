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
	PP_reg_number:out std_logic_vector(4 downto 0);-- data type can be changed
	PP_mm_data: OUT STD_LOGIC_VECTOR(31 downto 0);
	PP_mm_addr: OUT INTEGER-- data type can be changed
);
END COMPONENT;
    
  	constant clk_period: time := 1 ns;  
	SIGNAL PP_Init: STD_LOGIC:='0';
	SIGNAL PP_CLK: STD_LOGIC:='0';
	SIGNAL POOP: STD_LOGIC:='0';
	SIGNAL PP_reg_data: STD_LOGIC_VECTOR(31 downto 0):= (others => '0');
	SIGNAL PP_mm_data: STD_LOGIC_VECTOR(31 downto 0):= (others => '0');
	Signal PP_reg_number : std_logic_vector(4 downto 0):= (others => '0');
	signal PP_mm_addr: integer := 0;

BEGIN

DUT: 
Pipelined_Processor PORT MAP(
	PP_Init,
	PP_CLK,
	POOP,
	PP_reg_data,
	PP_reg_number,
	PP_mm_data,
	PP_mm_addr

);
	clk_process: process
	 begin
		    PP_clk <='0';
		    wait for clk_period/2;
		    PP_clk<='1';
		    wait for clk_period/2;

	end process;

test_process: PROCESS 

BEGIN
  
  PP_INIT<='0';
  
  wait for clk_period;

END PROCESS;

END ARCHITECTURE;