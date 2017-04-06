--2Bit Branch Prediction FOR ECSE 425 PROJECT WINTER 2017
--GROUP 8
--Author: Alina Mambo

--Taken is branch_taken='1'
--Not taken is branch_taken='0'

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity Branch_Predictor_2Bit is

	port (	clk : in std_logic;
			init : in std_logic;
      		branch_taken : in std_logic; --INPUT from Execute
      		b_predict : out std_logic
  );
end Branch_Predictor_2Bit;

architecture arch of Branch_Predictor_2Bit is

	  TYPE State_type IS (T, NT, WT, WNT); -- States of the 2bit BP FSM
	  Type branch_history_table is array (31 downto 0) of std_logic_vector(1 downto 0);
	  signal next_state : State_type;

	  --signal current_state: State_type;
	  signal bht: branch_history_table;
	  

	begin

	FSM:process(clk,input,next_state)

		begin

		if (init = '1') then
			next_state<=WT;

		elsif(rising_edge(clk) and init ='0') then

			Case next_state is

				When T =>
					if(branch_taken='0') then
						next_state<=WT;
					elsif(branch_taken ='1') then
						next_state<=T;
					end if;
						
				When WT=>
					if(branch_taken='0') then
						next_state<=WNT;
					elsif(branch_taken='1') then
						next_state<=T;
					end if;
						

				When WNT=>
					if(branch_taken='0') then
						next_state<=NT;
					elsif(branch_taken='1') then
						next_state<=WT;
					end if;

				When NT=>
					if(branch_taken='0') then
						next_state<=NT;
					elsif(branch_taken='1') then
						next_state<=WNT;
					end if;
			end case;

		end if;
	end process;

	Update_BHT : process (next_state, branch_taken)
		begin

			case next_state is

				When T=>
					if(branch_taken='1') then




				When WT=>

				When WNT=>

				When NT=>

			end case;

	end process;


end arch;