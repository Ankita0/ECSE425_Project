library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.


--MISING: SW,LW,LUI,J,JR address calculations!!!

--ALU for the execute stage
--MUX_A should be the 1st operand in the instruction
--MUX_B should be the second operand in the instruction

entity alu is

	Generic(W : natural := 32; F : natural :=6);
	
	port( 	Mux_A	: in  std_logic_vector(W-1 downto 0)
			Mux_B	: in  std_logic_vector(W-1 downto 0)
			Alu_Ctrl: in  std_logic_vector(F-1 downto 0)
			Shift	: in std_logic_vector (F-2 downto 0)
			Alu_Rslt: out std_logic_vector(W-1 downto 0)
			Zero 	: out std_logic;
			Overflow: out std_logic;
			Carryout: out std_logic);

end alu;


architecture arch of alu is 

	signal Hi 	: std_logic_vector(W-1 downto 0);
	signal Lo 	: std_logic_vector(W-1 downto 0);

	process(Alu_Ctrl)

	Variable Y := std_logic_vector(W-1 downto 0);
	Variable sign_A,sign_B := signed(W-1 downto 0);
	variable MD_rslt := std_logic_vector (63 downto 0);
	variable shift_zeroes:= (others => '0');
	variable shamt := to_integer(signed(shamt));

	begin

		case Alu_Ctrl is

			--R-Type
			when "100000"=> Y 	:= 	signed(Mux_A) + signed(Mux_B); --ADD
			when "100010"=>	Y	:= 	signed(Mux_A) - signed(Mux_B); --SUB
			when "100100"=> Y 	:= 	Mux_A AND Mux_B; --AND
			when "100101"=> Y	:= 	Mux_A OR Mux_B;-- OR
			when "100111"=>	Y	:= 	Mux_A OR NOT Mux_B; --NOR
			when "100110"=> Y 	:=	(Mux_A AND (NOT Mux_B)) OR ((NOT Mux_A) AND Mux_B); --XOR

			when "011000"=>	
				MD_rslt:= signed(Mux_A)*signed(Mux_B);--Mult
				Lo<=MD_rslt(31 downto 0);
				Hi<= MD_rslt(63 downto 32);
			
			when "011010"=>		--Div
				Lo<= signed(Mux_A)/signed(Mux_B);
				Hi<= signed(Mux_A)rem signed(Mux_B);

			when "101010"=>
				IF(Mux_A<Mux_B) then --set on less than (slt)
					Y:="00000000000000000000000000000001";
				else
					Y:="00000000000000000000000000000000";
				END IF;


			-- IF this does not work we need to save the part of the input we cant and & zeroes to it

			when "000000"=> Y:= Mux_A shift_left shamt;	--shift left logical (sll), shift zeroes into LSB
			when "000010"=>	Y:= Mux_A shift_right shamt;--shift right logical (srl), shift zeroes into MSB
			when "000011"=>	--shift right arithmetic (sra)
				IF(Mux_A(31)='1')then
					Y:= Mux_A(shamt downto 0) & others => '1';
				else
					Y:= Mux_A(shamt downto 0) & others => '0';
				END IF;



			when "010000"=>	Y	:=Hi;--mfhi
			when "100101"=>	Y	:=Lo;--mflo

			-- I type 
			-- Note: andi/addi/ori/xori are the same logic as add/and/or/xor R type
			-- because the control vector tells the mux which value to send to the alu (register or sign extended value)

			when "001011"=> --set on less than immediate (slti)
				IF(Mux_A<Mux_B);--set on less than (slt)
					Y:="00000000000000000000000000000001";
				else
					Y:="00000000000000000000000000000000";
				END IF;

			when "001000"=>	Y	:= signed(Mux_A)+ signed(Mux_B); --addi
			when "001100"=>	Y	:= Mux_A AND Mux_B;--andi
			when "001101"=>	Y	:= Mux_A OR Mux_B;--ori
			when "001110"=>	Y	:= (Mux_A AND (NOT Mux_B)) OR ((NOT Mux_A) AND Mux_B);--xori

			when "000100"=>	Y	:=;--beq
			when "000101"=>	Y	:=;--bne

			--J-type
			when "000011"=>	Y	:=;--jal



			when others => Y (others => 'X');

		end case;


		--Check Zero

		if Y ='0' then
			Zero<='1';
		else
			Zero <='0';
		end if;


		--Check Carryout
		if Mux_A(31)='1' AND Mux_B(31)='1' then
			Carryout<='1';
		else
			Carryout <='0';
		end if;

		--Check Overflow, if it is implmented then we need to change Y to 33 bits 




		--Output result

		Alu_Rslt<= Y;

	end process;


end arch;
