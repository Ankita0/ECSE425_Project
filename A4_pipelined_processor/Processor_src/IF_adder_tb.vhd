LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY IF_adder_tb is
end IF_adder_tb;

ARCHITECTURE behav of IF_adder_tb is
	COMPONENT IF_adder IS
	PORT(
		PC_instr_in: IN INTEGER;
		stall: in std_logic;
		PC_instr_plus4_out: OUT INTEGER
	);
	END COMPONENT;

	SIGNAL PC_instr_in, PC_instr_plus4_out: INTEGER:=0;
	SIGNAL stall: std_logic:= '0';
	CONSTANT clk_period: time := 1 ns;

BEGIN

DUT:
    IF_adder 
        PORT MAP(
	        PC_instr_in,
		stall,
		PC_instr_plus4_out
        );

test_process : process
    BEGIN
        PC_instr_in<=0;
	WAIT for 0.5*clk_period;
        ASSERT PC_instr_plus4_out = 1 REPORT "add unsuccessful" SEVERITY error;
	WAIT for 0.5*clk_period;
        PC_instr_in<= 116;
        WAIT for 0.5*clk_period;
        ASSERT PC_instr_plus4_out = 117 REPORT "add unsuccessful" SEVERITY error;
	stall<= '1';
	PC_instr_in<= 126;
        WAIT for 0.5*clk_period;
        ASSERT PC_instr_plus4_out = 126 REPORT "add unsuccessful" SEVERITY error;
        WAIT;
    END process;

END ARCHITECTURE;