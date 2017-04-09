--MEMORY STAGE
--Author: Maana Javadi
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY memory_controller is
GENERIC(
	ram_size : INTEGER := 8192
);
PORT(
      clock, reset: IN STD_LOGIC;
      
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
END memory_controller;

ARCHITECTURE behaviour of memory_controller is

COMPONENT data_memory is
  	GENERIC(
		ram_size : INTEGER := 8192;
		mem_delay : time := 10 ns;
		clock_period : time := 1 ns
	);
	PORT(
		clock: IN STD_LOGIC;
		writedata: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		address: IN INTEGER RANGE 0 TO ram_size-1;
		memwrite: IN STD_LOGIC;
		memread: IN STD_LOGIC;
		readdata: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		waitrequest: OUT STD_LOGIC
	);
END COMPONENT;

 	SIGNAL data_memwrite: STD_LOGIC_VECTOR (31 DOWNTO 0);
 	SIGNAL mm_address: INTEGER RANGE 0 to ram_size-1;
 	SIGNAL mm_write: STD_LOGIC:='0';
 	SIGNAL mm_read: STD_LOGIC:='0';
 	SIGNAL data_memread: STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL waitrequest: STD_LOGIC; 
  
BEGIN
  
  DUT: data_memory
      port map(
	clock,
      	data_memwrite,
      	mm_address,
      	mm_write,
      	mm_read,
	data_memread,
      	waitrequest
      );


mm_address <= to_integer(unsigned(alu_result));
mm_write <= do_memwrite;
mm_read <= do_memread;
data_memwrite<=writedata;
  MEM_PROCESS : PROCESS  (clock, do_memread, do_memwrite, reg_dst, alu_result)
  BEGIN
	--reset /initialize
    	 if reset = '1' then
	    alu_result_out <= (others => '0');
	    data_to_WB <= (others => '0');
	    reg_dst_out <= (others => '0');
	
		--when running
	elsif rising_edge(clock) and reset= '0' then
		if do_memread = '1' then
			data_to_WB <= data_memread;

		elsif do_memwrite = '1' then
			data_to_WB <= (others => '0');
		--register data appears on writedata line, to be propogated 
		-- else result to be written to register should be on alu result line
		elsif reg_write = '1' then
			data_to_WB<= writedata;
		end if;
			reg_write_out<=reg_write;
			reg_dst_out<= reg_dst;
			alu_result_out <= alu_result; 
	end if;
  end process;

END behaviour;
      