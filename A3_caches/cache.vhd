-- Group 
-- Alina Mambo
-- Ankita Sharma
-- Maana Javadi
-- Nicole Tang

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cache is
generic(
	ram_size : INTEGER := 32768
);
port(
	clock : in std_logic;
	reset : in std_logic;
	
	-- Avalon interface --
	s_addr : in std_logic_vector (31 downto 0);
	s_read : in std_logic;
	s_readdata : out std_logic_vector (31 downto 0);
	s_write : in std_logic;
	s_writedata : in std_logic_vector (31 downto 0);
	s_waitrequest : out std_logic; 
    
	m_addr : out integer range 0 to ram_size-1;
	m_read : out std_logic;
	m_readdata : in std_logic_vector (7 downto 0);
	m_write : out std_logic;
	m_writedata : out std_logic_vector (7 downto 0);
	m_waitrequest : in std_logic
);
end cache;

architecture arch of cache is

COMPONENT memory IS
        GENERIC(
            ram_size : INTEGER := 32768;
            mem_delay : time := 10 ns;
            clock_period : time := 1 ns
        );
        PORT (
            clock: IN STD_LOGIC;
            writedata: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
            address: IN INTEGER RANGE 0 TO ram_size-1;
            memwrite: IN STD_LOGIC := '0';
            memread: IN STD_LOGIC := '0';
            readdata: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
            waitrequest: OUT STD_LOGIC
        );
END COMPONENT;


-- declare constants here 
constant c_bits_per_word: integer:= 32;
constant c_word_per_block: integer:= 4;
constant c_bits_per_block: integer:= 128;
constant c_total_blocks: integer:= 32;
constant ram_size_c: INTEGER := 32768;


type cache_state is (INIT, IDLE, CHECK_TAG, CHECK_DIRTY_BIT, READ_MAIN_MEM, write_to_main_mem, WRITE_CACHE, READ_CACHE);

-- sets up data in a cache block as an array of 4*32 bit vectors.
type data_array is array(3 downto 0) of STD_LOGIC_VECTOR (31 downto 0);

type tag_array is array (31 downto 0) of STD_LOGIC_VECTOR (22 downto 0);

-- sets cache block as a record with 1 dirty bit, 1 valid bit, and 4*32 data bits
type cache_block is record
	dirtyBit: std_logic;
	validBit: std_logic;
	data: data_array;
end record;

-- sets entire cache as an array of 32 cache blocks
type cache_mem is array(31 downto 0) of cache_block;

-- declare signals
signal state: cache_state;
signal READ_HIT, READ_MISS, WRITE_HIT, WRITE_MISS, DIRTY_BIT, VALID_BIT, HIT_MISS : STD_LOGIC := '0';
signal initialize: std_logic:= '1';
signal cache_memory : cache_mem;
signal tag_arr: tag_array;
signal writedata:  STD_LOGIC_VECTOR (7 DOWNTO 0);
signal	address: INTEGER RANGE 0 TO ram_size_c-1;
signal	memwrite:  STD_LOGIC;
signal	memread:  STD_LOGIC;
signal	readdata:  STD_LOGIC_VECTOR (7 DOWNTO 0);
signal	waitrequest:  STD_LOGIC;


-- HIT_MISS is '1' when HIT, '0' when MISS
procedure compare_tags 
(Signal addr : in std_logic_vector(31 downto 0);
Signal tag_arr: in tag_array;
  Signal HIT_MISS : out STD_LOGIC) is
begin
  for i in 0 to 31 loop
    if (addr(31 downto 9) = tag_arr(i)(22 downto 0)) then
    	HIT_MISS<='1';
    else
    	HIT_MISS<='0';
   	end if;
  end loop;
end compare_tags;

--INPUT TO check_dirty_bits in state_action is:
-- check_dirty_bits(addr<=s_addr, DIRTY_BIT=>DIRTY_BIT);

procedure check_dirty_bits 
(Signal addr : in  std_logic_vector (31 downto 0);
  Signal DIRTY_BIT : out STD_LOGIC) is
begin	
	--convert index to integer
 	DIRTY_BIT<= cache_memory(to_integer(unsigned(addr(8 downto 4)))).dirtyBit;
end check_dirty_bits;



-- funtion takes in s_addr converts to int addr for main mem
function cache_addr_to_mem_map(addr : std_logic_vector (31 downto 0))
              return integer is
begin
  if (to_integer(unsigned(addr(8 downto 4))) > 0) then
    return to_integer(unsigned(addr(8 downto 4)));
  end if;
end cache_addr_to_mem_map;

--input integer from cache_addr_to_mem_map(s_addr) and attach m_readdata to second element
-- ex: read_from_main_mem(chache_addr_to_mem_map(s_addr), m_readdata);
procedure read_from_main_mem 
(Signal addr : in  INTEGER ;
  Signal readData : out std_logic_vector (7 downto 0)) is
begin
	m_addr <= addr;
	IF(m_waitrequest'event and m_waitrequest='1') then
		readData<=m_readdata;	
	end if;

end read_from_main_mem;

procedure write_to_main_mem 
(Signal addr : in  integer;
Signal inData : in std_logic_vector (31 downto 0);
Signal outData : out std_logic_vector (7 downto 0)) is
begin

	m_write<='1';
	m_addr<=addr;

	IF(m_waitrequest'event and m_waitrequest='1') then
		outData<=inData;
	end if;

end write_to_main_mem;


procedure write_to_cache_from_mm (signal mem_read_data_1 :in std_logic_vector(7 downto 0);
			signal mem_read_data_2 :in std_logic_vector(7 downto 0);
			signal mem_read_data_3 :in std_logic_vector(7 downto 0);
			signal mem_read_data_4 :in std_logic_vector(7 downto 0))is
	variable burst_write_to_cache_32: std_logic_vector(31 downto 0);
begin
--TODO
	burst_write_to_cache_32 <= (7 downto 0 => '1') & mem_read_data_4;
	burst_write_to_cache_32 <= (15 downto 8 => '1') & mem_read_data_3;
	burst_write_to_cache_32 <= (23 downto 16 => '1') & mem_read_data_2;
	burst_write_to_cache_32 <= (31 downto 24 => '1') & mem_read_data_1;
	s_write <= burst_write_to_cache_32;
end write_to_cache_from_mm;

-- added another procedure for straight up write form cpu
procedure write_to_cache_cpu (signal write_to_cache_32: std_logic_vector(31 downto 0))is
begin
	s_write <= write_to_cache_32;
end write_to_cache_cpu;

begin

MainMem: memory 
Generic map(
		ram_size => 32768,
		mem_delay => 10 ns,
		clock_period =>  1 ns
	)
Port Map ( 
	clock => clock,
	writedata=>writedata,
	address=>address,
	memwrite=>memwrite,
	memread=>memread,
	readdata=>readdata,
	waitrequest=>waitrequest); 


cache_state_change: process (clock,s_read,s_write)
begin
	if (initialize = '1') then 
		state<=INIT;
		initialize<= '0';
	elsif(rising_edge(clock) and initialize ='0') then
		case state is
			when INIT=>
				state<=IDLE;
			when IDLE=>
				if((s_read xor s_write)='1') then
					state<=CHECK_TAG;
				end if;
			when CHECK_TAG=>
				if((READ_HIT and s_read)='1') then
					state<=READ_CACHE;
				elsif ((WRITE_HIT and s_write)='1') then
					state<=WRITE_CACHE;
				elsif ((READ_MISS or WRITE_MISS)='1') then
					state<=CHECK_DIRTY_BIT;															
				end if;
			when CHECK_DIRTY_BIT=>
				if(((not DIRTY_BIT) and s_read and s_write)='1') then
					state<=READ_MAIN_MEM;
				elsif ((DIRTY_BIT and s_read and s_write)='1') then
					state<=write_to_main_mem;
				end if;
			when write_to_main_mem=>
				state<=READ_MAIN_MEM;
			when READ_MAIN_MEM=>
				if(((not DIRTY_BIT) and s_read)='1') then
					state<=IDLE;
				elsif (((not DIRTY_BIT) and s_write)='1') then
					state<=WRITE_CACHE;
				end if;
			when WRITE_CACHE=>
				state<=IDLE;
			when READ_CACHE=>
				state<=IDLE;
		end case;
	end if;
end process;

state_action: process (state,s_addr,m_readdata,s_writedata)
begin
	case state is
		when INIT=>
			-- set all valid bit to 0 in INIT state
			for i in 0 to 31 loop
				cache_memory(i).validBit <= '0';
				cache_memory(i).dirtyBit <= '0';
			end loop;
		when IDLE=>
		when CHECK_TAG=>
			compare_tags (s_addr,tag_arr,HIT_MISS);
			s_waitrequest<='1';
		when CHECK_DIRTY_BIT=>
			check_dirty_bits(s_addr, DIRTY_BIT);
			s_waitrequest<='1';
		when write_to_main_mem=>
			write_to_main_mem(s_addr,s_writedata,m_writedata);
			m_write<='1';
--			if m_writedata exists
			s_waitrequest<='1';
		when READ_MAIN_MEM=>
			read_from_main_mem(cache_addr_to_mem_map(s_addr), m_readdata);
			m_read<='1';
			s_waitrequest<='1';
--			if m_readdata exists;
			DIRTY_BIT<='0';
		when WRITE_CACHE=>
--			write_to_cache();
			DIRTY_BIT<='1';
			s_waitrequest<='1';
		when READ_CACHE=>
			s_readdata<=cache_memory(to_integer(unsigned(s_addr(8 downto 4)))).data(to_integer(unsigned(s_addr(3 downto 0))));
			s_waitrequest<='1';
	end case;
end process;

end arch;
