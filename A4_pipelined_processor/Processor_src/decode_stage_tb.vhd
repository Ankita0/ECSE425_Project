LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY decode_stage_tb IS
END decode_stage_tb;

ARCHITECTURE behaviour OF decode_stage_tb IS
COMPONENT decode_stage is

	Port(	clock			: in std_logic;	
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

			--control signals
			reg_write		: out std_logic;	--to be propagated to WB and back to DE
			mem_read		: out std_logic;	--for MEM stage
			mem_write		: out std_logic;	--for MEM stage
			branch			: out std_logic;
			jump			: out std_logic;
			IF_stall		: out std_logic
			);
END COMPONENT;

	constant clock_period: time := 1 ns;
	SIGNAL clock			: std_logic:= '0';	
	SIGNAL instruction		: std_logic_vector(31 downto 0):= (others => '0'); --instruction from IF stage
	SIGNAL PC_counter_in	: integer:=0;	--to propagate to EX stage

	SIGNAL WB_data 			: std_logic_vector (31 downto 0):= (others => '0');
	SIGNAL WB_data_addr		: std_logic_vector (4 downto 0) := (others => '0');
	SIGNAL WB_data_write	: std_logic:= '0'; 	--signal to check if WB_data needs to be written in WB_data_addr
	SIGNAL PC_counter_out	: integer:= 0;	--to propagate to EX stage

	SIGNAL EX_reg_dest_addr	: std_logic_vector(4 downto 0);	--for hazard detection
	SIGNAL MEM_reg_dest_addr: std_logic_vector(4 downto 0); --for hazard detection
	SIGNAL WB_reg_dest_addr	: std_logic_vector(4 downto 0); --for hazard detection


	SIGNAL reg_value1		: std_logic_vector(31 downto 0):=x"00000000"; --MuxA
	SIGNAL reg_value2		: std_logic_vector(31 downto 0):=x"00000000"; --MuxB
	SIGNAL reg_dest_addr	: std_logic_vector(4 downto 0):= (others => '0');	--$rd (r-type) or $rt (i-type)
	SIGNAL shamt			: std_logic_vector(4 downto 0):= (others => '0');	--shift amount
	SIGNAL j_address		: std_logic_vector(25 downto 0):= (others => '0');

	SIGNAL alu_op_code		: std_logic_vector(5 downto 0):= (others => '0');

	--control signals
	SIGNAL reg_write		: std_logic:= '0';	--to be propagated to WB and back to DE
	SIGNAL mem_read			: std_logic:= '0';	--for MEM stage
	SIGNAL mem_write		: std_logic:= '0';	--for MEM stage
	SIGNAL branch			: std_logic:= '0';
	SIGNAL jump				: std_logic:= '0';
	SIGNAL IF_stall			: std_logic:= '0';


BEGIN
DUT: decode_stage
	PORT MAP(	clock,
				instruction,
				PC_counter_in,
				WB_data,
				WB_data_addr,
				WB_data_write,
				EX_reg_dest_addr,
				MEM_reg_dest_addr,
				WB_reg_dest_addr,	
				PC_counter_out,
				reg_value1,
				reg_value2,
				reg_dest_addr,
				shamt,
				j_address,
				alu_op_code,
				reg_write,
				mem_read,
				mem_write,
				branch,
				jump,
				IF_stall
			);


	clock_process : PROCESS
	BEGIN
		clock <= '0';
		wait for clock_period/2;
		clock <= '1';
		wait for clock_period/2;
	END PROCESS;


	test_process: PROCESS
	BEGIN
        --001000 00000 01011 0000011111010000
        --addi $rs $rt 2000
		instruction<=x"200B07D0";
		PC_counter_in<=1;
		--from previous instructions
		WB_data<=x"00000003";		--e.g. 3	
		--from previous instructions
		WB_data_addr<="00010";	--e.g r2
		--from previous instructions
		WB_data_write<='1';	
		--from EX stage
		EX_reg_dest_addr<="00000";
		--from MEM stage
		MEM_reg_dest_addr<="00010";
		--from WB stage
		WB_reg_dest_addr<="00011";

		wait for clock_period;
		
		ASSERT	(PC_counter_out=1) REPORT "PC_counter_out mismatch" SEVERITY ERROR;
		ASSERT	(reg_value1=x"00000000") REPORT "reg_value1 mismatch" SEVERITY ERROR;
		-- reg_value2 = sign extended imm = 2000
		ASSERT	(reg_value2=x"000007D0") REPORT "reg_value2 mismatch" SEVERITY ERROR;
		ASSERT	(reg_dest_addr="01011") REPORT "reg_dest_addr mismatch" SEVERITY ERROR;
		ASSERT	(shamt="10000") REPORT "shamt mismatch" SEVERITY ERROR;
		ASSERT	(j_address="00000010110000011111010000") REPORT "j_address mismatch" SEVERITY ERROR;
		ASSERT	(alu_op_code="100000") REPORT "alu_op_code mismatch" SEVERITY ERROR;
		ASSERT	(reg_write='1') REPORT "reg_write mismatch" SEVERITY ERROR;
		ASSERT	(mem_read='0') REPORT "mem_read mismatch" SEVERITY ERROR;
		ASSERT	(mem_write='0') REPORT "mem_write mismatch" SEVERITY ERROR;
		ASSERT	(branch='0') REPORT "branch mismatch" SEVERITY ERROR;
		ASSERT	(jump='0') REPORT "jump mismatch" SEVERITY ERROR;
		ASSERT	(IF_stall='0') REPORT "IF_stall mismatch" SEVERITY ERROR;
		
	END PROCESS;

END ARCHITECTURE;