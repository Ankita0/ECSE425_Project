LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_textio.all;
USE STD.textio.all; 


entity Pipelined_Processor is
PP_Init: IN STD_LOGIC;
PP_CLK: IN STD_LOGIC;
POOP: IN STD_LOGIC;
PP_reg_data: OUT STD_LOGIC_VECTOR(31 downto 0);
PP_mm_data: OUT STD_LOGIC_VECTOR(31 downto 0);
end Pipelined_Processor;

ARCHITECTURE foo of Pipelined_Processor is
COMPONENT IF_stage is
PORT(
	PC_counter_init: IN STD_LOGIC;
	mux_control: IN STD_LOGIC;
	PC_instr_from_EX: IN INTEGER;
	CLK: IN STD_LOGIC;
	control_vector: IN STD_LOGIC_VECTOR(1 downto 0); --stalling signal
	PC_count_out: OUT INTEGER;
	Instruction_out: OUT STD_LOGIC_VECTOR(31 downto 0)
);
END COMPONENT;

COMPONENT decode_stage is

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
			jump			: out std_logic
			);
END COMPONENT;

COMPONENT execute_stage is

	Port(	

			clock: in std_logic;
			PC_IN: in integer; -- PC from IF and Decode

			--Passing through IN
			IN_mem_write: in std_logic; --MEM write
			IN_mem_read: in std_logic;  --- MEM READ
			IN_mem_data_wr: in std_logic_vector(31 downto 0); --WRITE DATA TO MEM
			IN_wb_write: in std_logic; -- WB WRITE
			IN_wb_addr:in std_logic_vector(4 downto 0);

			-- ALU INPUT
			Input_A	: in std_logic_vector(31 downto 0);
			Input_B: in std_logic_vector(31 downto 0);
			alu_op_code: in std_logic_vector(5 downto 0);
			Jump: in std_logic;
			Branch: in std_logic;
			jump_addr: in std_logic_vector(25 downto 0);
			
			--ALU OUT
			result: out std_logic_vector(31 downto 0);
			PC_OUT: out integer;
			IF_MUX_CTRL: out std_logic;

			--Passing through OUT to MEM/WB
			OUT_mem_write: out std_logic;
			OUT_mem_read: out std_logic; 
			OUT_mem_data_wr: out std_logic_vector(31 downto 0);
			OUT_wb_write:out std_logic;
			OUT_wb_addr: out std_logic_vector(4 downto 0));
	


END COMPONENT;

COMPONENT memory_controller is
GENERIC(
	ram_size : INTEGER := 8192
);
PORT(
      clock, reset: IN STD_LOGIC;
      
      --control signals
  		  do_memread: IN STD_LOGIC;
  		  do_memwrite: IN STD_LOGIC;
      
      --coming from EX stage
		  alu_result: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		  writedata: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		  reg_dst: IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		  reg_write: IN STD_LOGIC;

      --going to WB stage
  		  alu_result_out: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
  		  data_to_WB: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
  		  reg_dst_out: OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
  		  reg_write_out: OUT STD_LOGIC
		);
END COMPONENT;

COMPONENT WB_STAGE is
  PORT(
      clock: IN STD_LOGIC;
      reg_write: IN STD_LOGIC;
      alu_data: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
      mem_data: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
      reg_dst: IN STD_LOGIC_VECTOR (4 DOWNTO 0);
      
      reg_write_out: OUT STD_LOGIC;
      reg_dst_out: OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
      writedata: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)    
      );
END COMPONENT;

COMPONENT hazard_detect is
	port(
	clock: in std_logic;
	instruction_in: in std_logic_vector(31 downto 0);
	EX_reg_dest_addr: in std_logic_vector(4 downto 0);
	MEM_reg_dest_addr: in std_logic_vector(4 downto 0);
	WB_reg_dest_addr: in std_logic_vector(4 downto 0);

	instruction_out: out std_logic_vector(31 downto 0);
	stall: out std_logic
	);
end COMPONENT;

BEGIN

END ARCHITECTURE;