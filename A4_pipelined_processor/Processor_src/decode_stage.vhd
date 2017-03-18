--DECODE PIPELINE STAGE FOR ECSE 425 PROJECT WINTER 2017
--Author: Nicole Tang
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity decode_stage is

	Port(	clock			: in std_logic;	
			instruction		: in std_logic_vector(31 downto 0); --instruction from IF stage
			PC_counter_in	: in integer;	--to propagate to EX stage
			WB_data 		: in std_logic_vector (31 downto 0);
			WB_data_addr	: in std_logic_vector (4 downto 0);
			WB_data_write	: in std_logic; 	--signal to check if WB_data needs to be written in WB_data_addr
												--it's the reg_write propogated to WB stage and coming back
			PC_counter_out	: out integer;	--to propagate to EX stage
			reg_value1	: out std_logic_vector(31 downto 0); --MuxA
			reg_value2	: out std_logic_vector(31 downto 0); --MuxB
			reg_dest_addr	: out std_logic_vector(4 downto 0);	--$rd (r-type) or $rt (i-type)
			shamt		: out std_logic_vector(4 downto 0);	--shift amount
			j_address	: out integer;	--to_integer(unsign(std_logic_vector(25 downto 0)))
			alu_op_code	: out std_logic_vector(5 downto 0);

			--control signals
			reg_write		: out std_logic;	--to be propagated to WB and back to DE
			mem_read		: out std_logic;	--for MEM stage
			mem_write		: out std_logic;	--for MEM stage
			branch			: out std_logic;
			jump			: out std_logic
			);
end decode_stage;


architecture arch of decode_stage is

Component decoder is

	port(	instruction	: in std_logic_vector(31 downto 0);
			clock		: in std_logic;
			alu_op_code	: out std_logic_vector(5 downto 0);
			reg_dst		: out std_logic;
			reg_write	: out std_logic;
			alu_src		: out std_logic;
			mem_write	: out std_logic;
			mem_read	: out std_logic;
			jump		: out std_logic;
			branch		: out std_logic);
	end Component;

	Component register_file is
	Generic(W : natural := 32);
	port(
	clock: in std_logic;
	rs: in std_logic_vector(4 downto 0);
	rt: in std_logic_vector(4 downto 0);
	rd: in std_logic_vector(4 downto 0);
	reg_write: in std_logic;
	result: in std_logic_vector(W-1 downto 0);
	reg_value1: out std_logic_vector(W-1 downto 0);
	reg_value2: out std_logic_vector(W-1 downto 0)
	);
	end Component;

	Component signextension is
	port(	bit16 : in std_logic_vector(15 downto 0);
			bit32 : out std_logic_vector(31 downto 0)
	);
	end Component;

	--SIGNALS FOR DECODER
	signal instruction_s: std_logic_vector(31 downto 0);
--	signal clock: std_logic;
	signal alu_op_code : std_logic_vector(5 downto 0);
    signal reg_dst : std_logic;
    signal reg_write : std_logic;
    signal alu_src : std_logic;
    signal mem_write : std_logic;
    signal mem_read : std_logic;
    signal jump : std_logic;
    signal branch : std_logic;

    signal WB_data_addr: std_logic_vector(4 downto 0);
    signal WB_data_write: std_logic;
    signal WB_data: std_logic_vector(31 downto 0);

    signal signextended: std_logic_vector(31 downto 0);  



begin

	decoder: decoder
	PORT MAP(instruction_s,
			clock,
			alu_op_code,
			reg_dst,
			reg_write,
			alu_src,
			mem_write,
			mem_read,
			jump,
			branch);

	register_file: register_file
	PORT MAP(clock,
		instruction_s(25 downto 21),
		instruction_s(20 downto 16),
		WB_data_addr,
		WB_data_write,
		WB_data,
		reg_value1,
		reg_value2);

	signextension: signextension
	PORT MAP(instruction_s(15 downto 0),
			signextended);


	--instruction_s<=result;	
	instruction_s<= instruction;
	mem_write<= mem_write;
	mem_read<= mem_read;
	reg_write<= reg_write;
	--writing to register needs to happen at clock edges
	pipeline: process (result, clock)
		begin
		if (rising_edge(clock)) then
			
			case op_code is
			--R-Type
			when "000000" =>
				reg_value1<=reg_value1;
				reg_value2<=reg_value2;
				reg_dest_addr<= instruction_s(15 downto 11);
				shamt <= instruction_s(10 downto 6);
				
			--I-Type
			when "001000" =>		--addi
				reg_value1<=reg_value1;
				reg_value2<=signextended;
				reg_dest_addr<= instruction_s(20 downto 16);
				
			when "001010" =>		--slti
				reg_value1<=reg_value1;
				reg_value2<=signextended;
				reg_dest_addr<= instruction_s(20 downto 16);

			--Logical
			when "001100" =>		--andi
				reg_value1<=reg_value1;
				reg_value2<=signextended;
				reg_dest_addr<= instruction_s(20 downto 16);
				

			when "001101" =>		--ori
				reg_value1<=reg_value1;
				reg_value2<=signextended;
				reg_dest_addr<= instruction_s(20 downto 16);
				

			when "001110" =>		--xori
				reg_value1<=reg_value1;
				reg_value2<=signextended;
				reg_dest_addr<= instruction_s(20 downto 16);

			--Transfer
			when "001111" =>		--lui
				reg_value1<=reg_value1;
				reg_value2<=signextended;
				reg_dest_addr<= instruction_s(20 downto 16);

			--Memory
			when "100011" =>		--lw
				reg_value1<=reg_value1;
				reg_value2<=signextended;
				reg_dest_addr<= instruction_s(20 downto 16);

				
			when "101011" =>		--sw
				reg_value1<=reg_value1;
				reg_value2<=signextended;
				reg_dest_addr<= instruction_s(20 downto 16);

				
			--Control-flow
			when "000100" =>		--beq
				reg_value1<=reg_value1;
				reg_value2<=signextended;
				reg_dest_addr<= instruction_s(20 downto 16);


				
			when "000101" =>		--bne
				reg_value1<=reg_value1;
				reg_value2<=signextended;
				reg_dest_addr<= instruction_s(20 downto 16);


				
			--J-type
			when "000010" =>		--j
				j_address<= to_integer(unsign(instruction_s(25 downto 0)));



			when "000011" =>		--jal
				j_address<= to_integer(unsign(instruction_s(25 downto 0)));


				
			when others =>



							
		end case;
		end if;
	end process;


	dataflow: process(clock)
	begin
	if(rising_edge(clock)) then




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
						reg_dst<='0';	--not writing back to register 
						reg_write<='0'; --if reg_write is not 0, will overwrite a register *BAD*
						alu_src<='X';
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
				reg_dst<='1';
				reg_write<='1';
				alu_src<='1';
				mem_write<='0';
				mem_read<='0';
				jump<='0';
				branch<='0';				
			when "001010" =>		--slti
				alu_op_code<="101010";--funct of slt (r-type)
				reg_dst<='1';
				reg_write<='1';
				alu_src<='1';
				mem_write<='0';
				mem_read<='0';
				jump<='0';
				branch<='0';	
			--Logical
			when "001100" =>		--andi
				alu_op_code<="100100";	--funct of and (r-type)
				reg_dst<='1';
				reg_write<='1';
				alu_src<='1';
				mem_write<='0';
				mem_read<='0';
				jump<='0';
				branch<='0';
			when "001101" =>		--ori
				alu_op_code<="100101"; --funct of or (r-type)
				reg_dst<='1';
				reg_write<='1';
				alu_src<='1';
				mem_write<='0';
				mem_read<='0';
				jump<='0';
				branch<='0';
			when "001110" =>		--xori
				alu_op_code<="100110"; --funct of xor (r-type)
				reg_dst<='1';
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
				alu_op_code<="100000";	
				-- M[R[rs]+SignExtImm] = R[rt] 
				-- write to memory data = value of rt	


				reg_dst<='X';
				reg_write<='0';
				alu_src<='1';
				mem_write<='1';
				mem_read<='0';
				jump<='0';
				branch<='0';
			--Control-flow
			when "000100" =>		--beq
				alu_op_code<="100000";					
				reg_dst<='X';
				reg_write<='0';
				alu_src<='0';
				mem_write<='0';
				mem_read<='0';
				jump<='0';
				branch<='1';
			when "000101" =>		--bne
				alu_op_code<="100000";
				reg_dst<='X';
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

		

		end if;
	end process;
end arch;
