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
      		PC : in integer;
      		b_predict : out std_logic
  );
end Branch_Predictor_2Bit;

architecture arch of Branch_Predictor_2Bit is

	  TYPE State_type IS (T, NT, WT, WNT); -- States of the 2bit BP FSM
	  Type branch_history_row is
	  	record
	  		bhr: std_logic_vector(1 downto 0);
	  		NT: std_logic;
	  		WNT:std_logic;
	  		WT:std_logic;
	  		T:std_logic;
	  	end record;

	  Type branch_history_table is array (1023 downto 0) of branch_history_row;
	  signal next_state : State_type;
	  signal bht: branch_history_table;
	  

	begin

	FSM:process(clk,init,next_state,branch_taken)

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

	Update_BHT : process (clk,PC,init,next_state,branch_taken)
		begin
				---Init to all true
				if(init ='1') then
					bht.bhr<="11";
				else
					std_logic_vector(unsigned(bht.bhr) srl 1);
					bht(PC).bhr(1 downto 1)<=branch_taken;
					if(next_state = NT) then
						bht(PC).NT<='1';
					elsif(next_state = WNT) then
						bht(PC).WNT<='1';
					elsif(next_state=WT) then
						bht(PC).WT<='1'
					else
						bht(PC).T<='1';
					end if;
				end if;

	end process;

	Predict: process (clk,next_state)
		begin
			if(bht.bhr="00") then
				b_predict<= branch_history_table.NT;
			elsif (bhtbhr="01") then
				b_predict<=branch_history_table.WNT;
			elsif(bht.bhr="10") then
				b_predict<=branch_history_table.WT;
			elsif (bht.bhr="11") then
				b_predict<=branch_history_table.T;
			end if;
	end process;


end arch;