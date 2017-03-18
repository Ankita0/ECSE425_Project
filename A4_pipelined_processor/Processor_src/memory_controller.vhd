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
      
      --coming from EX stage
		  alu_data: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		  reg_dst: IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		  reg_write: IN STD_LOGIC;
  		  address: IN INTEGER RANGE 0 TO ram_size-1; --value of read/write address

      --going to WB stage
  		  data_WB: OUT STD_LOGIC_VECTOR (31 DOWNTO 0); --from ALU/memory
  		  reg_dst_out: OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
  		  reg_write_out: OUT STD_LOGIC;
  		  address_out: OUT INTEGER RANGE 0 TO ram_size-1
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

	SIGNAL data_out: STD_LOGIC_VECTOR (31 DOWNTO 0);
	--SIGNAL clk: STD_LOGIC;  
 	SIGNAL mm_address: INTEGER RANGE 0 to ram_size-1;
 	SIGNAL data_memread: STD_LOGIC_VECTOR (31 DOWNTO 0);
 	SIGNAL data_memwrite: STD_LOGIC_VECTOR (31 DOWNTO 0);
 	SIGNAL mm_read: STD_LOGIC;
 	SIGNAL mm_write: STD_LOGIC;
 	SIGNAL waitrequest: STD_LOGIC; 
  
BEGIN
data_out <= data_memread when do_memread = '1' else alu_data;

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

mm_address<=address;
MEM_PROCESS : PROCESS  
BEGIN
	if rising_edge(clock) then
		if do_memread = '1' then
			mm_read <= '1';
		elsif do_memwrite = '1' then
			mm_write <= '1';
		end if;
		--wait until rising_edge(waitrequest);
	end if; 
end process;
	
MEMSTAGE_PROCESS : PROCESS (clock, reset)	
	BEGIN
	  
	  if reset = '1' then
	    
	    data_WB <= (others => '0');
	    reg_dst_out <= (others => '0');
	    
	  elsif rising_edge(clock) then
	    
	    data_WB <= data_out;
	    address_out <= address;
	    reg_dst_out <= reg_dst;
	    reg_write_out <= reg_write;

	  end if;
	
  END PROCESS;	

END behaviour;
      