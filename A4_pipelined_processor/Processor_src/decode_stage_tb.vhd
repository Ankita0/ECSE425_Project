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

	constant clock_period: time := 1 ns;
	SIGNAL clock			: std_logic:= '0';	
	SIGNAL instruction		: std_logic_vector(31 downto 0):= (others => '0'); --instruction from IF stage
	SIGNAL PC_counter_in	: integer:=0;	--to propagate to EX stage

	SIGNAL WB_data 			: std_logic_vector (31 downto 0):= (others => '0');
	SIGNAL WB_data_addr		: std_logic_vector (4 downto 0) := (others => '0');
	SIGNAL WB_data_write	: std_logic:= '0'; 	--signal to check if WB_data needs to be written in WB_data_addr
	SIGNAL PC_counter_out	: integer:= 0;	--to propagate to EX stage

	SIGNAL reg_value1		: std_logic_vector(31 downto 0):=x"00000000"; --MuxA
	SIGNAL reg_value2		: std_logic_vector(31 downto 0):=x"00000000"; --MuxB
	SIGNAL reg_dest_addr	: std_logic_vector(4 downto 0):= (others => '0');	--$rd (r-type) or $rt (i-type)
	SIGNAL shamt			: std_logic_vector(4 downto 0):= (others => '0');	--shift amount
	SIGNAL j_address		: integer:=0;	--to_integer(unsign(std_logic_vector(25 downto 0)))

	SIGNAL alu_op_code		: std_logic_vector(5 downto 0):= (others => '0');

	--control signals
	SIGNAL reg_write		: std_logic:= '0';	--to be propagated to WB and back to DE
	SIGNAL mem_read			: std_logic:= '0';	--for MEM stage
	SIGNAL mem_write		: std_logic:= '0';	--for MEM stage
	SIGNAL branch			: std_logic:= '0';
	SIGNAL jump				: std_logic:= '0';

BEGIN
DUT: decode_stage
	PORT MAP(	clock,
				instruction,
				PC_counter_in,
				WB_data,
				WB_data_addr,
				WB_data_write,
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
				jump
			);

clock_process : process
BEGIN
	clock <= '0';
        wait for clock_period/2;
        clock <= '1';
        wait for clock_period/2;
end process;

test_process: PROCESS

END PROCESS; 

END ARCHITECTURE;