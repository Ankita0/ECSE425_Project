LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY memory_controller is
  PORT(
      clock, reset: IN STD_LOGIC;
      
		  data: INOUT STD_LOGIC_VECTOR (31 DOWNTO 0); --value of register
  		  address: IN INTEGER RANGE 0 TO ram_size-1; --value of read/write address
  		  
  		  mem_ctrl: IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		  memwrite: OUT STD_LOGIC;
		  memread: OUT STD_LOGIC;
		  regwrite: OUT STD_LOGIC;
		  regread:  OUT STD_LOGIC;

		);
END memory_controller;

ARCHITECTURE behavioural of memory_controller is

  SIGNAL data_to_WB       : STD_LOGIC_VECTOR (31 DOWNTO 0) := (others => 'Z');  
 	SIGNAL mm_address       : NATURAL                                       := 0;
	SIGNAL mm_we            : STD_LOGIC                                     := '0';
	SIGNAL mm_wr_done       : STD_LOGIC                                     := '0';
	SIGNAL mm_re            : STD_LOGIC                                     := '0';
	SIGNAL mm_rd_ready      : STD_LOGIC                                     := '0';
	SIGNAL mm_initialize    : STD_LOGIC                                     := '0';
	SIGNAL mem_ctrl         : STD_LOGIC_VECTOR (3 DOWNTO 0);
	SIGNAL busymem          : STD_LOGIC                                     := '0';
	SIGNAL busyreg          : STD_LOGIC := '0';
	
  PROCESS (clock, reset)
  BEGIN
    		
    	-- reset high
	if (reset = '1') then
		data <= (others => 'Z');

	elsif rising_edge(clock) then
		
		-- assume the user will not read and write at the same time
		case mem_ctrl is
			-- writing to memory
			when "0001" =>
				mm_re	<= 	'0';
				mm_we	<= 	'1';
				data_to_WB	<= 	data;
				mm_address	<= address;
				busyreg 	<=	busyreg;
				busymem	<=	'1';
				
				if mm_wr_done = '1' then
					busymem <= '0';
					mm_we <= '0';
				end if;
				
			-- writing to register
			when "0010" =>
				mm_re	<= 	'0';
				mm_we	<= 	'1';
				data_to_WB	<= 	data;
				mm_address	<= address;	
				busyreg <=	'1';
				busymem	<=	busymem;
				
				if mm_wr_done = '1' then
					busyreg <= '0';
					mm_we <= '0';
				end if;
				
	
			-- reading to memory
			when "0100" =>
				mm_re	<= 	'1';
				mm_we	<= 	'0';
				data_to_WB	<= 	(others => 'Z');
				mm_address	<= address;	
				busyreg <= busyreg;
				busymem	<=	'1';
				
  			 if mm_rd_ready = '1' then
					busyreg <= '0';
					mm_re <= '0';
				end if;
				
			-- reading to register
			when "1000" =>
				mm_re	<= 	'1';
				mm_we	<= 	'0';
				data_to_WB	<= 	(others => 'Z');
				mm_address	<= address;	
				busyreg	<=	'1';
				busymem	<=	busymem;
				
				if mm_rd_ready = '1' then
					busyreg <= '0';
					mm_re <= '0';
				end if;
				
			-- no priority or invalid input
			when others =>	
				mm_re	<= 	'0';
				mm_we	<= 	'0';
				data_to_WB	<= 	(others => 'Z');
				mm_address	<= address;	
				busyreg <=	busyreg;
				busymem	<=	busymem;
				
		end case;
	end if;
	
END PROCESS;	

      