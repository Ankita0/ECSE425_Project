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

	Variable Y := std_logic_vector(W-1 downto 0);
	Variable alu_op := std_logic_vector(5 downto 0);

	begin

		alu_op:=Alu_Ctrl;

		case alu_op is

			when "100000"=> Y 	:= Mux_A+Mux_B; --ADD
			when "100010"=>	Y	:= Mux_A-Mux_B; --SUB
			when "100100"=> Y 	:= Mux_A AND Mux_B; --AND
			when "100101"=> Y	:= Mux_A OR Mux_B;-- OR
			when "100111"=>	Y	:= Mux_A OR NOT Mux_B; --NOR
			when "100110"=> Y 	:= (Mux_A AND (NOT Mux_B)) OR ((NOT Mux_A) AND Mux_B); --XOR
			when "011000"=>	Y	:=;--Mult
			when "011010"=>	Y	:=;--Div
			when "101010"=>Y	:=;--slt
			when "000000"=>Y	:=;--sll
			when "000010"=>Y	:=;--srl
			when "000011"=>Y	:=;--sra
			when "010000"=>Y	:=;--mfhi
			when "100101"=>Y	:=;--mflo
			when "001011"=>Y	:=;--slti
			when "001000"=>Y	:=;--addi
			when "001100"=>Y	:=;--andi
			when "001101"=>Y	:=;--ori
			when "001110"=>Y	:=;--xori
			when "000100"=>Y	:=;--beq
			when "000101"=>Y	:=;--bne
			when "000011"=>Y	:=;--jal

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

		--Check Overflow, if it is implmented then we need to change Y to 33 bits




		--Output result

		Alu_Rslt<= Y;

	end process;


	end arch;
}