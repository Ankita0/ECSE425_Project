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
			WB_data_addr	: in std_logic_vector (31 downto 0);
			WB_data_write	: in std_logic; 	--signal to check if WB_data needs to be written in WB_data_addr
												--it's the reg_write propogated to WB stage and coming back
			PC_counter_out	: out integer;	--to propagate to EX stage
			reg_value1		: out std_logic_vector(31 downto 0); --MuxA
			reg_value2		: out std_logic_vector(31 downto 0); --MuxB
			reg_dest_addr	: out std_logic_vector(4 downto 0);	--$rd (r-type) or $rt (i-type)
			shamt			: out std_logic_vector(4 downto 0);	--shift amount
			j_address		: out integer;	--to_integer(unsign(std_logic_vector(25 downto 0)))
			alu_op_code		: out std_logic_vector(5 downto 0);

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
	signal instruction : std_logic_vector(31 downto 0);
	signal clock: std_logic;
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
	PORT MAP(instruction,
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
		instruction(25 downto 21),
		instruction(20 downto 16),
		instruction(15 downto 11),
		reg_write,
		result,
		reg_value1,
		reg_value2);

	signextension: signextension
	PORT MAP(instruction(15 downto 0),
			signextended);


	pipeline: process
		begin

		end process;




end arch;
