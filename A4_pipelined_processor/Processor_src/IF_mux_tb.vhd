LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY IF_mux_tb is
end IF_mux_tb;

ARCHITECTURE behav of IF_mux_tb is
	COMPONENT IF_mux IS
	PORT(
		PC_instr_from_EX: IN INTEGER;
		PC_instr_plus4: IN INTEGER;
		mux_control: IN STD_LOGIC; 
		PC_instr_to_fetch: OUT INTEGER
	);
	END COMPONENT;

	CONSTANT clk_period: time := 1 ns;
	SIGNAL PC_instr_from_EX: INTEGER:= 0;
	SIGNAL PC_instr_plus4: INTEGER := 0;
	SIGNAL mux_control: STD_LOGIC; 
	SIGNAL PC_instr_to_fetch: INTEGER;

BEGIN

DUT:
    IF_mux
        PORT MAP(
	        PC_instr_from_EX,
		PC_instr_plus4,
		mux_control,
		PC_instr_to_fetch
	);

test_process : process
    BEGIN
        PC_instr_from_EX<=0;
	PC_instr_plus4<=4;
	mux_control <= '0';
        WAIT for 0.5*clk_period;
        ASSERT PC_instr_to_fetch = 4 REPORT "muxing unsuccessful" SEVERITY error;
        WAIT for 0.5*clk_period;
	mux_control <= '1';
	WAIT for 0.5*clk_period;
	ASSERT PC_instr_to_fetch = 0 REPORT "muxing unsuccessful" SEVERITY error;
	WAIT for 0.5*clk_period;
	PC_instr_from_EX<=2;
	PC_instr_plus4<=3;
	WAIT for 0.5*clk_period;
	ASSERT PC_instr_to_fetch = 2 REPORT "muxing unsuccessful" SEVERITY error;
        WAIT;
    END process;

END ARCHITECTURE;
