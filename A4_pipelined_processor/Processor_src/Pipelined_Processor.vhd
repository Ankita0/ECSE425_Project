LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_textio.all;
USE STD.textio.all; 


entity Pipelined_Processor is
PP_Init: IN STD_LOGIC;
PP_CLK: IN STD_LOGIC;
POOP: IN STD_LOGIC;
PP_reg_data: OUT STD_LOGIC_VECTOR(31 downto 0);
PP_mm_data: OUT STD_LOGIC_VECTOR(31 downto 0);
end Pipelined_Processor;

ARCHITECTURE foo of Pipelined_Processor is

END ARCHITECTURE;