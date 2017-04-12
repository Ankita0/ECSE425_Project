--1bit branch predictor
--Group 8

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity branch_predictor_1bit is

	port (clk : in std_logic;
			  init : in std_logic;
   		   branch_taken : in std_logic; --INPUT from IF stage
   		   PC : in integer;
      		b_predict : out std_logic
  );
end branch_predictor_1bit;

architecture behaviour of branch_predictor_1bit is

	  Type state_type is (T, NT); --taken or not taken
	  Type branch_history_row is 
	     record 
	       bhr: std_logic;
	       NT: std_logic;
	       T: std_logic;
	     end record;
	  
	  Type branch_history_table is array (integer range 0 to 1023) of branch_history_row;
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

	Update_BHT : process (clk, PC, next_state, branch_taken)
		begin

      if(init = '1') then
         for i in 0 to 1023 loop
  					 bht(i).bhr<='1';
  					 bht(i).NT<='1';
					 bht(i).T<='1';
				  end loop;
      else 
					if(next_state = NT) then
            bht(PC).NT <= '1';
          else
            bht(PC).T <= '1';
          end if;
      end if;
				
	end process;

  Predict : process (clk, next_state)
    
    begin
    
      if(bht(PC).bhr = '0') then
        b_predict <= bht(PC).NT;
      elsif(bht(PC).bhr = '1') then
        b_predict <= bht(PC).T;
      end if;
    
    end process;

end behaviour;

