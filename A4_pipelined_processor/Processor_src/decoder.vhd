library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity decoder is
port(
	instruction: in std_logic_vector(31 downto 0);
	control: out std_logic_vector(8 downto 0)
);
end decoder;

architecture arch of decoder is
begin
	process(op_code)
	begin
		case op_code is
			--Arithmetic
			when "100000" =>		--add

			when "100010" =>		--sub
				
			when "001000" =>		--addi
				
			when "011000" =>		--mult

			when "011010" =>		--div

			when "101010" =>		--slt

			when "001010" =>		--slti
			
			--Logical
			when "100100" =>		--and

			when "100101" =>		--or

			when "100111" =>		--nor

			when "100110" =>		--xor

			when "001100" =>		--andi

			when "001101" =>		--ori

			when "001110" =>		--xori

			--Transfer
			when "010000" =>		--mfhi
				
			when "010010" =>		--mflo
				
			when "001111" =>		--lui
				
			--Shift
			when "000000" =>		--sll
				
			when "000010" =>		--srl
				
			when "000011" =>		--sra
				
			--Memory
			when "100011" =>		--lw
				
			when "101011" =>		--sw
				
			--Control-flow
			when "000100" =>		--beq
				
			when "000101" =>		--bne
				
			when "000010" =>		--j
				
			when "001000" =>		--jr
				
			when "000011" =>		--jal
				
			when others =>

		end case;
	end process;
end arch; 