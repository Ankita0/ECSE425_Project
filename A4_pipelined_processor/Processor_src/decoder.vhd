library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity decoder is
port(
	instruction: in std_logic_vector(31 downto 0);
	alu_op_code: out std_logic_vector(5 downto 0);
	control: out std_logic_vector(7 downto 0)
);
end decoder;

architecture arch of decoder is
	signal op_code: std_logic_vector(5 downto 0);
	signal funct: std_logic_vector(5 downto 0);
begin
	process(instruction)
	begin
		op_code <= instruction(31 downto 26);
		
		case op_code is
			--R-Type
			when "000000" =>
				funct <= instruction(5 downto 0);
				case funct is
					--Arithmetic
					when "100000" =>		--add
						alu_op_code<=funct;
					when "100010" =>		--sub
						alu_op_code<=funct;						
					when "011000" =>		--mult
						alu_op_code<=funct;
					when "011010" =>		--div
						alu_op_code<=funct;
					when "101010" =>		--slt
						alu_op_code<=funct;
					--Logical
					when "100100" =>		--and
						alu_op_code<=funct;
					when "100101" =>		--or
						alu_op_code<=funct;
					when "100111" =>		--nor
						alu_op_code<=funct;
					when "100110" =>		--xor
						alu_op_code<=funct;
					--Transfer
					when "010000" =>		--mfhi
						alu_op_code<=funct;						
					when "010010" =>		--mflo
						alu_op_code<=funct;						
					--Shift
					when "000000" =>		--sll
						alu_op_code<=funct;						
					when "000010" =>		--srl
						alu_op_code<=funct;						
					when "000011" =>		--sra
						alu_op_code<=funct;
					--control-flow
					when "001000" =>		--jr
						alu_op_code<="UUUUUU";				
					when others =>
						alu_op_code<="UUUUUU";
				end case;
			
			--I-Type
			--Arithmetic
			when "001000" =>		--addi
				alu_op_code<=op_code;				
			when "001010" =>		--slti
				alu_op_code<=op_code;	
			--Logical
			when "001100" =>		--andi
				alu_op_code<=op_code;	
			when "001101" =>		--ori
				alu_op_code<=op_code;	
			when "001110" =>		--xori
				alu_op_code<=op_code;	
			--Transfer
			when "001111" =>		--lui
				alu_op_code<="UUUUUU";	
			--Memory
			when "100011" =>		--lw
				alu_op_code<="UUUUUU";					
			when "101011" =>		--sw
				alu_op_code<="UUUUUU";					
			--Control-flow
			when "000100" =>		--beq
				alu_op_code<=op_code;					
			when "000101" =>		--bne
				alu_op_code<=op_code;	
			--J-type
			when "000010" =>		--j
				alu_op_code<="UUUUUU";					
			when "000011" =>		--jal
				alu_op_code<=op_code;				
			when others =>
				alu_op_code<="UUUUUU";
		end case;
	end process;
end arch; 