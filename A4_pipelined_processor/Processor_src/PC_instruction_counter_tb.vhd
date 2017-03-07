LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY PC_instruction_counter_tb is
end PC_instruction_counter_tb;

ARCHITECTURE foo of pc_instruction_counter_tb is
COMPONENT PC_instruction_counter IS
PORT(
	PC_IN : IN STD_LOGIC_VECTOR(31 downto 0);
	INIT : IN STD_LOGIC;
	CLK : IN STD_LOGIC;
	PC : OUT STD_LOGIC_VECTOR(31 downto 0)
);
END COMPONENT;
CONSTANT clk_period : time := 1 ns;
SIGNAL PC_IN, PC_OUT: STD_LOGIC_VECTOR(31 downto 0);
SIGNAL INIT, CLK: STD_LOGIC:= '0';

BEGIN

DUT:
PC_instruction_counter PORT MAP(
	PC_IN,
	INIT,
	CLK,
	PC_OUT
);
clk_process : process
    BEGIN
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    END process;

simulation: process
BEGIN
	WAIT FOR 1*clk_period;
	INIT<='1';
	WAIT FOR 0.5*clk_period; -- value changes between falloing and rising edge of clock
	ASSERT PC_OUT = x"00000000" REPORT "init unsuccessful" SEVERITY error;
	PC_IN<= "00000000000000000000000000000100";
	WAIT FOR 1*clk_period;
	ASSERT PC_OUT = x"00000004" REPORT "update unsuccessful" SEVERITY error;
	WAIT;
END process;

END ARCHITECTURE;