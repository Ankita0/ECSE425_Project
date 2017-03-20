LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_textio.all;
USE STD.textio.all; 


entity Pipelined_Processor is
PORT(
	PP_Init: IN STD_LOGIC;
	PP_CLK: IN STD_LOGIC;
	POOP: IN STD_LOGIC;
	PP_reg_data: OUT STD_LOGIC_VECTOR(31 downto 0);
	PP_reg_number: std_logic_vector(4 downto 0);-- data type can be changed
	PP_mm_data: OUT STD_LOGIC_VECTOR(31 downto 0);
	PP_mm_addr: OUT INTEGER-- data type can be changed
);
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
Port(		
			clock			: in std_logic;	
			instruction		: in std_logic_vector(31 downto 0); --instruction from IF stage
			PC_counter_in	: in integer;	--to propagate to EX stage
			WB_data 		: in std_logic_vector (31 downto 0);	--signals propagated from WB
			WB_data_addr	: in std_logic_vector (4 downto 0);--signals propagated from WB
			WB_data_write	: in std_logic; 	--signal to check if WB_data needs to be written in WB_data_addr
												--it's the reg_write propogated to WB stage and coming back
			EX_reg_dest_addr: in std_logic_vector(4 downto 0);	--for hazard detection
			MEM_reg_dest_addr: in std_logic_vector(4 downto 0); --for hazard detection
			WB_reg_dest_addr: in std_logic_vector(4 downto 0); --for hazard detection

			PC_counter_out	: out integer;	--to propagate to EX stage
			reg_value1	 	: out std_logic_vector(31 downto 0); --MuxA
			reg_value2	 	: out std_logic_vector(31 downto 0); --MuxB
			reg_dest_addr	: out std_logic_vector(4 downto 0);	--$rd (r-type) or $rt (i-type), equivalent to the WB_X signals
			shamt			: out std_logic_vector(4 downto 0);	--shift amount
			j_address		: out std_logic_vector(25 downto 0);
			alu_op_code		: out std_logic_vector(5 downto 0);
			branch_offset	: out integer;

			--control signals
			reg_write		: out std_logic;	--to be propagated to WB and back to DE
			mem_read		: out std_logic;	--for MEM stage
			mem_write		: out std_logic;	--for MEM stage
			branch			: out std_logic;
			jump			: out std_logic;
			IF_stall		: out std_logic;
			mem_data_sw		: out std_logic_vector(31 downto 0)
			);
END COMPONENT;

COMPONENT execute_stage is
PORT(	
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
			branch_offset: in integer;
			
			--ALU OUT
			result: out std_logic_vector(31 downto 0);
			PC_OUT: out integer;
			IF_MUX_CTRL: out std_logic;

			--Passing through OUT to MEM/WB
			OUT_mem_write: out std_logic;
			OUT_mem_read: out std_logic; 
			OUT_mem_data_wr: out std_logic_vector(31 downto 0);
			OUT_wb_write:out std_logic;
			OUT_wb_addr: out std_logic_vector(4 downto 0)
			);
	
END COMPONENT;

COMPONENT memory_controller is
GENERIC(
	ram_size : INTEGER := 8192
);
PORT(
     	clock: IN STD_LOGIC;
 		reset: IN STD_LOGIC;
      
      --control signals
  		  do_memread: IN STD_LOGIC;
  		  do_memwrite: IN STD_LOGIC;
		  reg_write: IN STD_LOGIC;
      
      --coming from EX stage
		  alu_result: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		  writedata: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		  reg_dst: IN STD_LOGIC_VECTOR (4 DOWNTO 0);

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
	--SIGNAL CLK		:std_logic;
	
	--IF stage mapping
	--map init directly--PC_counter_init: STD_LOGIC;
	--SIGNAL IF_mux_control		: STD_LOGIC;
	--SIGNAL IF_PC_instr_from_EX	: INTEGER;
	SIGNAL IF_control_vector	: STD_LOGIC_VECTOR(1 downto 0); --stalling signal
	SIGNAL IF_PC_count_out		: INTEGER;
	SIGNAL IF_Instruction_out	: STD_LOGIC_VECTOR(31 downto 0);
	
	--DE stage mapping	
	--SIGNAL DE_instruction	: std_logic_vector(31 downto 0); --instruction from IF stage
	--SIGNAL DE_PC_counter_in	: integer;	--to propagate to EX stage
	--SIGNAL DE_WB_data 		: std_logic_vector (31 downto 0);	--signals propagated from WB
	--SIGNAL DE_WB_data_addr	: std_logic_vector (4 downto 0);--signals propagated from WB
	--SIGNAL DE_WB_data_write	: std_logic; 	--signal to check if WB_data needs to be written in WB_data_addr
	--SIGNAL DE_EX_reg_dest_addr: std_logic_vector(4 downto 0);
	--SIGNAL DE_MEM_reg_dest_addr: std_logic_vector(4 downto 0);
	--SIGNAL DE_WB_reg_dest_addr: std_logic_vector(4 downto 0);

											--it's the reg_write propogated to WB stage and coming back
	SIGNAL DE_PC_counter_out: integer;	--to propagate to EX stage
	SIGNAL DE_reg_value1	: std_logic_vector(31 downto 0); --MuxA
	SIGNAL DE_reg_value2	: std_logic_vector(31 downto 0); --MuxB
	SIGNAL DE_reg_dest_addr	: std_logic_vector(4 downto 0);	--$rd (r-type) or $rt (i-type), equivalent to the WB_X signals
	SIGNAL DE_shamt			: std_logic_vector(4 downto 0);	--shift amount
	SIGNAL DE_j_address		: std_logic_vector(25 downto 0);
	SIGNAL DE_alu_op_code	: std_logic_vector(5 downto 0);

	--control signals
	SIGNAL DE_reg_write		: std_logic;	--to be propagated to WB and back to DE
	SIGNAL DE_mem_read		: std_logic;	--for MEM stage
	SIGNAL DE_mem_write		: std_logic;	--for MEM stage
	SIGNAL DE_branch		: std_logic;
	SIGNAL DE_jump			: std_logic;
	SIGNAL DE_IF_stall		: std_logic:='0';
	SIGNAL DE_branch_offset	: integer;
	SIGNAL DE_mem_data		: std_logic_vector(31 downto 0);
	--EX stage mapping
	--SIGNAL EX_PC_IN		: integer; -- PC from IF and Decode

	--Passing through IN
	--SIGNAL EX_IN_mem_write		: std_logic; --MEM write
	--SIGNAL EX_IN_mem_read		: std_logic;  --- MEM READ
	--SIGNAL EX_IN_mem_data_wr	: std_logic_vector(31 downto 0); --WRITE DATA TO MEM
	--SIGNAL EX_IN_wb_write		: std_logic; -- WB WRITE
	--SIGNAL EX_IN_wb_addr		: std_logic_vector(4 downto 0);
	
	-- ALU INPUT
	--SIGNAL EX_Input_A		: std_logic_vector(31 downto 0);
	--SIGNAL EX_Input_B		: std_logic_vector(31 downto 0);
	--SIGNAL EX_alu_op_code		: std_logic_vector(5 downto 0);
	--SIGNAL EX_Jump			: std_logic;
	--SIGNAL EX_Branch		: std_logic;
	--SIGNAL EX_jump_addr		: std_logic_vector(25 downto 0);
	
	--ALU OUT
	SIGNAL EX_result		: std_logic_vector(31 downto 0);
	SIGNAL EX_PC_OUT		: integer;
	SIGNAL EX_IF_MUX_CTRL		: std_logic;

	--Passing through OUT to MEM/WB
	SIGNAL EX_OUT_mem_write	: std_logic;
	SIGNAL EX_OUT_mem_read		: std_logic; 
	SIGNAL EX_OUT_mem_data_wr	: std_logic_vector(31 downto 0);
	SIGNAL EX_OUT_wb_write		: std_logic;
	SIGNAL EX_OUT_wb_addr		: std_logic_vector(4 downto 0);
	
	--MEM stage mapping
	--SIGNAL MEM_reset		: STD_LOGIC;
      
      --control signals
	--SIGNAL MEM_do_memread		: STD_LOGIC;
	--SIGNAL MEM_do_memwrite		: STD_LOGIC;
	--SIGNAL MEM_reg_write		: STD_LOGIC;
      
      --coming from EX stage
	--SIGNAL MEM_alu_result		: STD_LOGIC_VECTOR (31 DOWNTO 0);
	--SIGNAL MEM_writedata		: STD_LOGIC_VECTOR (31 DOWNTO 0);
	--SIGNAL MEM_reg_dst		: STD_LOGIC_VECTOR (4 DOWNTO 0);

      --going to WB stage
	SIGNAL MEM_alu_result_out	: STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL MEM_data_to_WB		: STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL MEM_reg_dst_out		: STD_LOGIC_VECTOR (4 DOWNTO 0);
	SIGNAL MEM_reg_write_out	: STD_LOGIC;

	--WB stage mapping
	--SIGNAL WB_reg_write		: STD_LOGIC;
	--SIGNAL WB_alu_data		: STD_LOGIC_VECTOR (31 DOWNTO 0);
	--SIGNAL WB_mem_data		: STD_LOGIC_VECTOR (31 DOWNTO 0);
	--SIGNAL WB_reg_dst		: STD_LOGIC_VECTOR (4 DOWNTO 0);
      
	SIGNAL WB_reg_write_out		: STD_LOGIC;
	SIGNAL WB_reg_dst_out		: STD_LOGIC_VECTOR (4 DOWNTO 0);
	SIGNAL WB_writedata		: STD_LOGIC_VECTOR (31 DOWNTO 0);

	SIGNAL rf_clock		: std_logic;
	SIGNAL rf_rs 		: std_logic_vector(4 downto 0);
	SIGNAL rf_rt 		: std_logic_vector(4 downto 0);
	SIGNAL rf_rd 		: std_logic_vector(4 downto 0);
	SIGNAL rf_reg_write	: std_logic;
	SIGNAL rf_result 	: std_logic_vector(31 downto 0);
	SIGNAL rf_reg_value1: std_logic_vector(31 downto 0);
	SIGNAL rf_reg_value2: std_logic_vector(31 downto 0);

BEGIN

DUT_IF_stage: 
IF_stage PORT MAP(
	PP_Init,
	EX_IF_MUX_CTRL,
	EX_PC_OUT,
	PP_CLK,
	IF_control_vector, --stalling signal
	IF_PC_count_out,
	IF_Instruction_out
);

DUT_DE_stage:
decode_stage PORT MAP(	
	PP_CLK,	
	IF_Instruction_out,		--instruction from IF stage
	IF_PC_count_out, 	--to propagate to EX stage
    WB_writedata,	--  	DE_WB_data,		--signals propagated from WB
	WB_reg_dst_out,	--signals propagated from WB	
	WB_reg_write_out,	--signal to check if WB_data needs to be written in WB_data_addr
	EX_OUT_wb_addr,
	MEM_reg_dst_out,
	WB_reg_dst_out,
			--it's the reg_write propogated to WB stage and coming back
	DE_PC_counter_out,	--to propagate to EX stage
	DE_reg_value1,		--MuxA	
	DE_reg_value2,		--MuxB	
	DE_reg_dest_addr,	--$rd (r-type) or $rt (i-type), equivalent to the WB_X signals
	DE_shamt,		--shift amount	
	DE_j_address,
	DE_alu_op_code,
	DE_branch_offset,

			--control signals
	DE_reg_write,		--to be propagated to WB and back to DE
	DE_mem_read,		--for MEM stage
	DE_mem_write,		--for MEM stage
	DE_branch,
	DE_jump,
	DE_IF_stall,
	DE_mem_data
);

DUT_EX_stage: 
execute_stage PORT MAP(	
	PP_CLK,
	DE_PC_counter_out,-- PC from IF and Decode

	--Passing through IN
	DE_mem_write, --MEM write
	DE_mem_read,  --- MEM READ
	DE_mem_data, --WRITE DATA TO MEM, value of rt from i-type instruction
	DE_mem_write, -- WB WRITE
	DE_reg_dest_addr, --to propagate to WB and back to DE

	-- ALU INPUT
	DE_reg_value1,
	DE_reg_value2,
	DE_alu_op_code,
	DE_jump,
	DE_branch,
	DE_j_address,
	DE_branch_offset,
			
	--ALU OUT
	EX_result,
	EX_PC_OUT,
	EX_IF_MUX_CTRL,

	--Passing through OUT to MEM/WB
	EX_OUT_mem_write,
	EX_OUT_mem_read,
	EX_OUT_mem_data_wr,
	EX_OUT_wb_write,
	EX_OUT_wb_addr
);


DUT_MEM_stage:
memory_controller PORT MAP(
	PP_CLK,
	PP_Init,
      
      --control signals
	EX_OUT_mem_read,
	EX_OUT_mem_write,
	EX_OUT_wb_write,
      
      --coming from EX stage
	EX_result,
	EX_OUT_mem_data_wr,
	EX_OUT_wb_addr,

      --going to WB stage
	MEM_alu_result_out,
	MEM_data_to_WB,
	MEM_reg_dst_out,
	MEM_reg_write_out
);


DUT_WB_stage:
WB_STAGE PORT MAP(
      PP_CLK,
      MEM_reg_write_out,
      MEM_alu_result_out,
      MEM_data_to_WB,
      MEM_reg_dst_out,

      WB_reg_write_out,
      WB_reg_dst_out,
      WB_writedata 
);

PP_process: PROCESS (PP_CLK)

BEGIN
--PP_Init: IN STD_LOGIC;
	--PP_CLK: IN STD_LOGIC;
--	POOP: IN STD_LOGIC;
--	PP_reg_data: OUT STD_LOGIC_VECTOR(31 downto 0);
--	PP_mm_data: OUT STD_LOGIC_VECTOR(31 downto 0)
IF ((PP_CLK'event and PP_CLK='1') and (PP_Init = '0')) THEN
	if POOP= '0' then
	
	elsif(POOP'event and POOP='1') then
		PP_mm_data<=MEM_Data_to_WB;
		PP_reg_data<= WB_writedata;
	end if;
END IF;

END PROCESS;

END ARCHITECTURE;