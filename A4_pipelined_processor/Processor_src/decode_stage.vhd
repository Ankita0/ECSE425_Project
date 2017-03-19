--DECODE PIPELINE STAGE FOR ECSE 425 PROJECT WINTER 2017
--Author: Nicole Tang
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity decode_stage is

	Port(	clock			: in std_logic;	
			instruction		: in std_logic_vector(31 downto 0); --instruction from IF stage
			PC_counter_in	: in integer;	--to propagate to EX stage
			WB_data 		: in std_logic_vector (31 downto 0);	--signals propagated from WB
			WB_data_addr	: in std_logic_vector (4 downto 0);--signals propagated from WB
			WB_data_write	: in std_logic; 	--signal to check if WB_data needs to be written in WB_data_addr
												--it's the reg_write propogated to WB stage and coming back
			PC_counter_out	: out integer;	--to propagate to EX stage
			reg_value1	 	: out std_logic_vector(31 downto 0); --MuxA
			reg_value2	 	: out std_logic_vector(31 downto 0); --MuxB
			reg_dest_addr	: out std_logic_vector(4 downto 0);	--$rd (r-type) or $rt (i-type), equivalent to the WB_X signals
			shamt			: out std_logic_vector(4 downto 0);	--shift amount
			j_address		: out std_logic_vector(25 downto 0);
			alu_op_code		: out std_logic_vector(5 downto 0);

			--control signals
			reg_write		: out std_logic;	--to be propagated to WB and back to DE
			mem_read		: out std_logic;	--for MEM stage
			mem_write		: out std_logic;	--for MEM stage
			branch			: out std_logic;
			jump			: out std_logic;
			IF_stall		: out std_logic
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
			branch		: out std_logic
		);
end Component;

Component register_file is
	Generic(W 			: natural := 32);
	port(	clock		: in std_logic;
			rs 			: in std_logic_vector(4 downto 0);
			rt 			: in std_logic_vector(4 downto 0);
			rd 			: in std_logic_vector(4 downto 0);
			reg_write	: in std_logic;
			result 		: in std_logic_vector(W-1 downto 0);
			reg_value1	: out std_logic_vector(W-1 downto 0);
			reg_value2	: out std_logic_vector(W-1 downto 0)
		);
end Component;

Component signextension is
	port(	bit16 		: in std_logic_vector(15 downto 0);
			bit32		: out std_logic_vector(31 downto 0)
		);
end Component;

	--SIGNALS FOR DECODER
    signal reg_dst_s 			: std_logic;
    signal alu_src_s 			: std_logic;

    signal sign_extended_imm: std_logic_vector(31 downto 0);  

    --SIGNALS FOR REGISTER FILE
    signal reg_value1_s		: std_logic_vector(31 downto 0);
    signal reg_value2_s 	: std_logic_vector(31 downto 0);

	signal alu_op_code_s	: std_logic_vector(5 downto 0);
	signal reg_write_s		: std_logic;
	signal mem_read_s		: std_logic;
	signal mem_write_s		: std_logic;
	signal branch_s			: std_logic;
	signal jump_s			: std_logic;

begin

	decoder1: decoder
	PORT MAP(	instruction,
				clock,
				alu_op_code_s,
				reg_dst_s,
				reg_write_s,
				alu_src_s,
				mem_write_s,
				mem_read_s,
				jump_s,
				branch_s
			);

	register_file1: register_file
	PORT MAP(	clock,
				instruction(25 downto 21),
				instruction(20 downto 16),
				WB_data_addr,
				WB_data_write,
				WB_data,
				reg_value1_s,
				reg_value2_s
			);

	signextension1: signextension
	PORT MAP(	instruction(15 downto 0),
				sign_extended_imm
			);


	pipeline: process (clock)
		begin
		--all outputs should be clock synchronized 
		if (rising_edge(clock)) then
			PC_counter_out <= PC_counter_in;
			reg_value1 <= reg_value1_s; 
			shamt <= instruction(4 downto 0);	--shift amount
			j_address <= instruction(25 downto 0);
			alu_op_code <= alu_op_code_s;
			reg_write <= reg_write_s;
			mem_read <= mem_read_s;
			mem_write <= mem_write_s;
			branch <= branch_s;
			jump <= jump_s;

			if(alu_src_s = '1') then 
			-- use sign extended value
				reg_value2 <= sign_extended_imm; 
			else --alu_src_s='1' 
			--use reg_value2_s from register file
				reg_value2 <= reg_value2_s; 
			end if;

			--if reg_dst_s='1' (r-type), '0' (i-type)
			if (reg_dst_s = '1') then
				reg_dest_addr <= instruction(15 downto 11);	--$rd (r-type)
			else -- reg_dst_s='0'
				reg_dest_addr <= instruction(20 downto 16);	--$rt (i-type)
			end if;

		end if;
	end process;

end arch;
