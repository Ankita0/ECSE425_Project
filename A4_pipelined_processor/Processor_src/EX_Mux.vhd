LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;


--This mux is to be instantiated twice in the execute stage of the pipeline.
--ID_instr_1 corresponds to a 0 on the mux and ID_instr_2 corresponds to a 1 on the mux.

ENTITY Ex_mux is

PORT(ID_instr_1, ID_instr_2 : in std_logic_vector(31 downto 0);
		mux_control,CLK: in std_logic;
		instr_to_Ex: out std_logic_vector(31 downto 0));

end Ex_mux;

Architecture arch of Ex_mux is

BEGIN

	process(CLK,mux_control,ID_instr_1,ID_instr_1)

	BEGIN

		if(rising_edge(clk) AND mux_control="1") then
			instr_to_Ex<=ID_instr_2;
		elsif (rising_edge(clk) AND mux_control="0") then
			instr_to_Ex<=ID_instr_1;
		end if;			

	end process;
END arch;