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
	ram_size : INTEGER := 32768;
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

-- declare constants here 
constant c_bits_per_word: integer:= 32;
constant c_word_per_block: integer:= 4;
constant c_bits_per_block: integer:= 128;
constant c_total_blocks: integer:= 32;


type cache_state is (INIT, IDLE, CHECK_TAG, CHECK_DIRTY_BIT, READ_MAIN_MEM, WRITE_MAIN_MEM, WRITE_CACHE, READ_CACHE);

-- sets up data in a cache block as an array of 4*32 bit vectors.
type data_array is array(15 downto 0) of STD_LOGIC_VECTOR (7 downto 0);

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
signal READ_HIT, READ_MISS, WRITE_HIT, WRITE_MISS, DIRTY_BIT, VALID_BIT : STD_LOGIC := '0';

begin

procedure compare_tags is
begin
--TODO


end compare_tags;

--INPUT TO check_dirty_bits in state_action is:
-- selected_Block : std_logic;
-- selected_Block<= cache_mem(index).dirtyBit;
-- check_dirty_bits(block_DirtyBit<=selected_Block, DIRTY_BIT=>DIRTY_BIT);

procedure check_dirty_bits (Signal block_DirtyBit : in std_logic;
							Signal DIRTY_BIT : out STD_LOGIC) is
begin
	if(block_DirtyBit='1')then
		DIRTY_BIT<='1';
	elsif(block_DirtyBit='0') then
		DIRTY_BIT<='0';
	end if;
		
end check_dirty_bits;



procedure read_main_mem is
begin
--TODO

end read_main_mem;

procedure write_main_mem is
begin
--TODO

end write_main_mem;


procedure write_to_cache is
begin
--TODO

end write_to_cache;

procedure read_from_cache is
begin
--TODO

end read_from_cache;

procedure load_from_mm_to_cache is 
begin
--TODO

end load_from_mm_to_cache;

cache_state_change: process (clock,s_read,s_write,READ_HIT,WRITE_HIT,DIRTY_BIT,READ_MISS,WRITE_MISS)
begin
	if(rising_edge(clock)) then
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
					state<=WRITE_MAIN_MEM;
				end if;
			when WRITE_MAIN_MEM=>
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

state_action: process (state)
begin
	case state is
		when IDLE=>
		when CHECK_TAG=>
--			compare_tags();
			s_waitrequest<='1';
		when CHECK_DIRTY_BIT=>
--			check_dirty_bits(s_addr<=s_addr, DIRTY_BIT=>DIRTY_BIT);
			m_waitrequest<='1';
			s_waitrequest<='1';
		when WRITE_MAIN_MEM=>
--			write_main_mem();
			m_write<='1';
--			m_writedata<='1';
			m_waitrequest<='1';
			s_waitrequest<='1';
		when READ_MAIN_MEM=>
--			read_main_mem();
			m_read<='1';
			m_waitrequest<='1';
			s_waitrequest<='1';
--			m_readdata<='1';
			DIRTY_BIT<='0';
			m_waitrequest<='1';
		when WRITE_CACHE=>
--			write_to_cache();
			DIRTY_BIT<='1';
			s_waitrequest<='1';
			m_waitrequest<='0';
		when READ_CACHE=>
--			read_from_cache();
			s_readdata<='1';
			s_waitrequest<='1';
	end case;
end process;

end arch;