--DECODE PIPELINE STAGE FOR ECSE 425 PROJECT WINTER 2017
--Author: Nicole Tang
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity decode_stage is

	Port(	clock:in std_logic;	
			result: in std_logic_vector (31 downto 0);
			reg_value1,reg_value2,X,Y,Z: out std_logic_vector(31 downto 0));

end decode_stage;

architecture arch of decode_stage is

Component decoder is

	port(	instruction	: in std_logic_vector(31 downto 0);
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
	signal instruction : std_logic_vector(31 downto 0):= x"00000000";
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
	PORT MAP(instruction,alu_op_code,reg_dst,reg_write,alu_src,mem_write,mem_read,jump,branch);

	register_file: register_file
	PORT MAP(clock,
		instruction(25 downto 21),
		instruction(20 downto 16),
		instruction(15 downto 11),
		reg_write,
		result,
		reg_value1,
		reg_value2);

	signextension: signextension
	PORT MAP(instruction(15 downto 0),signextended);
	
	instruction<=result;
	pipeline: process (result, clock)
		begin
		if (rising_edge(clock)) then
			
			case op_code is
			--R-Type
			when "000000" =>
				reg_value1<=reg_value1;
				reg_value2<=reg_value2;
				
			--I-Type
			when "001000" =>		--addi
							
			when "001010" =>		--slti

			--Logical
			when "001100" =>		--andi
				
			when "001101" =>		--ori
				
			when "001110" =>		--xori
				
			--Transfer
			when "001111" =>		--lui
				
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
