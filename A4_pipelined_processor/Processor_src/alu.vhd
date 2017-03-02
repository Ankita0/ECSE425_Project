library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is{

	Generic(W : natural := 32; F : natural :=6);
	
	port( 	Mux_A	: in  std_logic_vector(W-1 downto 0)
			Mux_B	: in  std_logic_vector(W-1 downto 0)
			Alu_Ctrl: in  std_logic_vector(F-1 downto 0)
			Alu_Rslt: out std_logic_vector(W-1 downto 0)
			Zero 	: out std_logic;
			Overflow: out std_logic;
			Carryout: out std_logic);

end alu;

architecture arch of alu is {

	process(Alu_Ctrl)

	Variable Y := std_logic_vector(W downto 0);
	Variable funct := std_logic_vector(5 downto 0);

	begin

		case funct is

			when "000000"=> Y :=;
			when "000001"=>Y:=;





			when others => NULL;
			
		end case;


		--Check Zero

		if Y ='0' then
			Zero<='1';
		else
			Zero <='0';
		end if;


		--Check Carryout

		if Y(32)='1' then
			Carryout<='1';
		else
			Carryout <='0';
		end if;

		--Check Overflow




		--Output result

		Alu_Rslt<= Y(31 downto 0);

	end process;


	end arch;
}