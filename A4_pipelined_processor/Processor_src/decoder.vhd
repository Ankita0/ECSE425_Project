library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity decoder is
port(
	instruction: in std_logic_vector(31 downto 0);
	clock: in std_logic;
	alu_op_code: out std_logic_vector(5 downto 0);
	--register write
	reg_dst: out std_logic; --Determines how the destination register is specified (rt or rd)
	reg_write: out std_logic; --write to register file
--	mem_to_reg: out std_logic; --Determines where the value to be written comes from (ALU result or memory)
	--Source operand fetch
	alu_src: out std_logic;	--source for second ALU input(rt or sign-extended immediate field)
	--memory access
	mem_write: out std_logic; --write input address/data to memory
	mem_read: out std_logic; --read input address from memory
	--PC Update
	jump: out std_logic; --Enables loading the jump target address into the PC
	branch: out std_logic --Combined with a condition test boolean to enable loading the branch target address into the PC
);
end decoder;

architecture arch of decoder is
begin
	process(instruction)
	  Variable op_code: std_logic_vector(5 downto 0);
	  Variable funct: std_logic_vector(5 downto 0);
	begin
		op_code := instruction(31 downto 26);
		
		case op_code is
			--R-Type
			when "000000" =>
				funct := instruction(5 downto 0);
				case funct is

					--Arithmetic
					when "100000" =>		--add
						alu_op_code<=funct;
						reg_dst<='1';
						reg_write<='1';
						alu_src<='0';
						mem_write<='0';
						mem_read<='0';
						jump<='0';
						branch<='0';

					when "100010" =>		--sub
						alu_op_code<=funct;
						reg_dst<='1';
						reg_write<='1';
						alu_src<='0';
						mem_write<='0';
						mem_read<='0';
						jump<='0';
						branch<='0';

					when "011000" =>		--mult
						alu_op_code<=funct;
						reg_dst<='1';
						reg_write<='1';
						alu_src<='0';
						mem_write<='0';
						mem_read<='0';
						jump<='0';
						branch<='0';

					when "011010" =>		--div
						alu_op_code<=funct;
						reg_dst<='1';
						reg_write<='1';
						alu_src<='0';
						mem_write<='0';
						mem_read<='0';
						jump<='0';
						branch<='0';

					when "101010" =>		--slt
						alu_op_code<=funct;
						reg_dst<='1';
						reg_write<='1';
						alu_src<='0';
						mem_write<='0';
						mem_read<='0';
						jump<='0';
						branch<='0';


					--Logical
					when "100100" =>		--and
						alu_op_code<=funct;
						reg_dst<='1';
						reg_write<='1';
						alu_src<='0';
						mem_write<='0';
						mem_read<='0';
						jump<='0';
						branch<='0';

					when "100101" =>		--or
						alu_op_code<=funct;
						reg_dst<='1';
						reg_write<='1';
						alu_src<='0';
						mem_write<='0';
						mem_read<='0';
						jump<='0';
						branch<='0';

					when "100111" =>		--nor
						alu_op_code<=funct;
						reg_dst<='1';
						reg_write<='1';
						alu_src<='0';
						mem_write<='0';
						mem_read<='0';
						jump<='0';
						branch<='0';

					when "100110" =>		--xor
						alu_op_code<=funct;
						reg_dst<='1';
						reg_write<='1';
						alu_src<='0';
						mem_write<='0';
						mem_read<='0';
						jump<='0';
						branch<='0';


					--Transfer
					when "010000" =>		--mfhi
						alu_op_code<=funct;
						reg_dst<='1';
						reg_write<='1';
						alu_src<='0';
						mem_write<='0';
						mem_read<='0';
						jump<='0';
						branch<='0';						

					when "010010" =>		--mflo
						alu_op_code<=funct;
						reg_dst<='1';
						reg_write<='1';
						alu_src<='0';
						mem_write<='0';
						mem_read<='0';
						jump<='0';
						branch<='0';						


					--Shift
					when "000000" =>		--sll
						alu_op_code<=funct;
						reg_dst<='1';
						reg_write<='1';
						alu_src<='0';
						mem_write<='0';
						mem_read<='0';
						jump<='0';
						branch<='0';						

					when "000010" =>		--srl
						alu_op_code<=funct;
						reg_dst<='1';
						reg_write<='1';
						alu_src<='0';
						mem_write<='0';
						mem_read<='0';
						jump<='0';
						branch<='0';						

					when "000011" =>		--sra
						alu_op_code<=funct;
						reg_dst<='1';
						reg_write<='1';
						alu_src<='0';
						mem_write<='0';
						mem_read<='0';
						jump<='0';
						branch<='0';


					--control-flow
					when "001000" =>		--jr
						alu_op_code<="111100";	
						reg_dst<='1';	--not writing back to register 
						reg_write<='0'; --if reg_write is not 0, will overwrite a register *BAD*
						alu_src<='0';
						mem_write<='0';
						mem_read<='0';
						jump<='1';
						branch<='0';			

					when others =>
						alu_op_code<="UUUUUU";
						reg_dst<='X';	
						reg_write<='X'; 
						alu_src<='X';
						mem_write<='X';
						mem_read<='X';
						jump<='X';
						branch<='X';
				end case;
			

			--I-Type
			--Arithmetic
			when "001000" =>		--addi
				alu_op_code<="100000"; 	--funct of add (r-type)
				reg_dst<='0';
				reg_write<='1';
				alu_src<='1';
				mem_write<='0';
				mem_read<='0';
				jump<='0';
				branch<='0';				

			when "001010" =>		--slti
				alu_op_code<="101010";--funct of slt (r-type)
				reg_dst<='0';
				reg_write<='1';
				alu_src<='1';
				mem_write<='0';
				mem_read<='0';
				jump<='0';
				branch<='0';	


			--Logical
			when "001100" =>		--andi
				alu_op_code<="100100";	--funct of and (r-type)
				reg_dst<='0';
				reg_write<='1';
				alu_src<='1';
				mem_write<='0';
				mem_read<='0';
				jump<='0';
				branch<='0';

			when "001101" =>		--ori
				alu_op_code<="100101"; --funct of or (r-type)
				reg_dst<='0';
				reg_write<='1';
				alu_src<='1';
				mem_write<='0';
				mem_read<='0';
				jump<='0';
				branch<='0';

			when "001110" =>		--xori
				alu_op_code<="100110"; --funct of xor (r-type)
				reg_dst<='0';
				reg_write<='1';
				alu_src<='1';
				mem_write<='0';
				mem_read<='0';
				jump<='0';
				branch<='0';


			--Transfer
			when "001111" =>		--lui
				alu_op_code<="001111";	
				reg_dst<='0';
				reg_write<='1';
				alu_src<='1';
				mem_write<='0';
				mem_read<='1';
				jump<='0';
				branch<='0';


			--Memory
			when "100011" =>		--lw
				alu_op_code<="100000";					
				reg_dst<='0';
				reg_write<='1';
				alu_src<='1';
				mem_write<='0';
				mem_read<='1';
				jump<='0';
				branch<='0';

			when "101011" =>		--sw
				alu_op_code<="100000";		-- M[R[rs]+SignExtImm] = R[rt] 
											-- write to memory data = value of rt	
				reg_dst<='0';
				reg_write<='0';
				alu_src<='1';
				mem_write<='1';
				mem_read<='0';
				jump<='0';
				branch<='0';


			--Control-flow
			when "000100" =>		--beq
				alu_op_code<="100000";					
				reg_dst<='0';
				reg_write<='0';
				alu_src<='0';
				mem_write<='0';
				mem_read<='0';
				jump<='0';
				branch<='1';

			when "000101" =>		--bne
				alu_op_code<="100000";
				reg_dst<='0';
				reg_write<='0';
				alu_src<='0';
				mem_write<='0';
				mem_read<='0';
				jump<='0';
				branch<='1';



			--J-type
			when "000010" =>		--j
				alu_op_code<="111111";					
				reg_dst<='0';
				reg_write<='0';
				alu_src<='0';
				mem_write<='0';
				mem_read<='0';
				jump<='1';
				branch<='0';

			when "000011" =>		--jal
				alu_op_code<="111110"; --same op code as addition
				--R[31]=PC+8
				--addi PC $r31 signExtend(8)
				--j address				
				reg_dst<='0';
				reg_write<='1'; --need to write PC+4 into $ra ($31)
				alu_src<='0';
				mem_write<='0';
				mem_read<='0';
				jump<='1';
				branch<='0';

			when others =>
				alu_op_code<="UUUUUU";
				reg_dst<='X';	
				reg_write<='X';
				alu_src<='X';
				mem_write<='X';
				mem_read<='X';
				jump<='X';
				branch<='X';				

		end case;
	end process;
end arch; 