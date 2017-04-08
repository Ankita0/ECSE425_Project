--1bit branch predictor

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity branch_predictor_1bit is

	port (clk : in std_logic;
			  init : in std_logic;
   		   branch_taken : in std_logic; --INPUT from IF stage
      		b_predict : out std_logic
  );
end branch_predictor_1bit;

architecture behaviour of branch_predictor_1bit is

	  Type state_type is (T, NT); --taken or not taken
	  Type branch_history_table is array (31 downto 0) of std_logic;
	  signal next_state : state_type;
	  signal bht: branch_history_table;
	  

	begin

	FSM:process(clk,branch_taken,next_state)

		begin

		if (init = '1') then
			next_state<=T;

		elsif(rising_edge(clk) and init ='0') then

			Case next_state is

				When T =>
					if(branch_taken='0') then
						next_state<=NT;
					elsif(branch_taken ='1') then
						next_state<=T;
					end if;
						
				When NT=>
					if(branch_taken='0') then
						next_state<=NT;
					elsif(branch_taken='1') then
						next_state<=T;
					end if;

			end case;

		end if;
	end process;

	Update_BHT : process (next_state, branch_taken)
		begin

			case next_state is

        --not sure if this is right
				When T=>
					if(branch_taken='1') then
            bht <= '1';
          elsif(branch_taken='0') then
            bht <= '0';
          end if;  
				
				When NT=>
				  if(branch_taken='1') then
				    bht <= '1';
				  elsif(branch_taken='0') then
				    bht <= '0';
			    end if;

			end case;

	end process;


end arch;
