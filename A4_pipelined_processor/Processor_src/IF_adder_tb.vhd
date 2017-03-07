LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY IF_adder_tb is
end IF_adder_tb;

ARCHITECTURE behav of IF_adder_tb is
	COMPONENT IF_adder IS
	PORT(
		PC_instr_in: IN INTEGER;
		CLK: IN STD_LOGIC;
		PC_instr_plus4_out: OUT INTEGER
	);
	END COMPONENT;

	SIGNAL PC_instr_in, PC_instr_plus4_out: INTEGER:=0;
	SIGNAL CLK: STD_LOGIC:= '0';
	CONSTANT clk_period: time := 1 ns;

BEGIN

DUT:
    IF_adder 
        PORT MAP(
	        PC_instr_in,
		CLK,
		PC_instr_plus4_out
        );
clk_process : process
    BEGIN
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    END process;

test_process : process
    BEGIN
        PC_instr_in<=0;
        WAIT for 1*clk_period;
        ASSERT PC_instr_plus4_out = 4 REPORT "add unsuccessful" SEVERITY error;
        WAIT for 1*clk_period;
        PC_instr_in<= 116;
        WAIT for 1*clk_period;
        ASSERT PC_instr_plus4_out = 120 REPORT "add unsuccessful" SEVERITY error;
        WAIT;
    END process;

END ARCHITECTURE;