--DECODE PIPELINE STAGE FOR ECSE 425 PROJECT WINTER 2017
--Author: Nicole Tang
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity decode_stage is

	Port(	clock			: in std_logic;	
			instruction	: in std_logic_vector(31 downto 0); --instruction from IF stage
			PC_counter_in	: in integer;	--to propagate to EX stage
			WB_data 	: in std_logic_vector (31 downto 0);
			WB_data_addr	: in std_logic_vector (31 downto 0);
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
		instruction_s(15 downto 11),
		reg_write,
		result,
		reg_value1,
		reg_value2);

	signextension: signextension
	PORT MAP(instruction_s(15 downto 0),
			signextended);


	instruction_s<=result;
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
				reg_dest_addr<= reg_dst;
				shamt <= instruction(10 downto 6);
				
			--I-Type
			when "001000" =>		--addi
				reg_value1<=reg_value1;
				reg_value2<=reg_value2;
				
			when "001010" =>		--slti
				reg_value1<=signextended;
				reg_value2<=reg_value2;
				reg_dest_addr<= regdst;
				

			--Logical
			when "001100" =>		--andi
				reg_value1<=signextended;
				reg_value2<=reg_value2;
				reg_dest_addr<= regdst;
				

			when "001101" =>		--ori
				reg_value1<=signextended;
				reg_value2<=reg_value2;
				reg_dest_addr<= regdst;
				

			when "001110" =>		--xori
				reg_value1<=signextended;
				reg_value2<=reg_value2;
				reg_dest_addr<= regdst;

			--Transfer
			when "001111" =>		--lui
				reg_value1<=signextended;
				reg_dest_addr<= regdst;
				
			--Memory
			when "100011" =>		--lw
				
			when "101011" =>		--sw
				
			--Control-flow
			when "000100" =>		--beq
				
			when "000101" =>		--bne
				
			--J-type
			when "000010" =>		--j
				
			when "000011" =>		--jal
				
			when others =>
							
		end case;
		end if;
		end process;
end arch;
