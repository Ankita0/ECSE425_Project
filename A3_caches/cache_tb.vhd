library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cache_tb is
end cache_tb;

architecture behavior of cache_tb is

component cache is
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
end component;

component memory is 
GENERIC(
    ram_size : INTEGER := 32768;
    mem_delay : time := 10 ns;
    clock_period : time := 1 ns
);
PORT (
    clock: IN STD_LOGIC;
    writedata: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
    address: IN INTEGER RANGE 0 TO ram_size-1;
    memwrite: IN STD_LOGIC;
    memread: IN STD_LOGIC;
    readdata: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
    waitrequest: OUT STD_LOGIC
);
end component;
	
-- test signals 
signal reset : std_logic := '0';
signal clk : std_logic := '0';
constant clk_period : time := 1 ns;

signal s_addr : std_logic_vector (31 downto 0);
signal s_read : std_logic;
signal s_readdata : std_logic_vector (31 downto 0);
signal s_write : std_logic;
signal s_writedata : std_logic_vector (31 downto 0);
signal s_waitrequest : std_logic;

signal m_addr : integer range 0 to 2147483647;
signal m_read : std_logic;
signal m_readdata : std_logic_vector (7 downto 0);
signal m_write : std_logic;
signal m_writedata : std_logic_vector (7 downto 0);
signal m_waitrequest : std_logic; 

begin

-- Connect the components which we instantiated above to their
-- respective signals.
dut: cache 
port map(
    clock => clk,
    reset => reset,

    s_addr => s_addr,
    s_read => s_read,
    s_readdata => s_readdata,
    s_write => s_write,
    s_writedata => s_writedata,
    s_waitrequest => s_waitrequest,

    m_addr => m_addr,
    m_read => m_read,
    m_readdata => m_readdata,
    m_write => m_write,
    m_writedata => m_writedata,
    m_waitrequest => m_waitrequest
);

MEM : memory
port map (
    clock => clk,
    writedata => m_writedata,
    address => m_addr,
    memwrite => m_write,
    memread => m_read,
    readdata => m_readdata,
    waitrequest => m_waitrequest
);
				

clk_process : process
begin
  clk <= '0';
  wait for clk_period/2;
  clk <= '1';
  wait for clk_period/2;
end process;

test_process : process
begin

--put test here
-- need to verify 'X' signals
-- filling in values for 
	wait for clk_period;

	REPORT "start check for initialization of cache";
	s_read <= '0';
	s_write <= '0';
	s_addr <= "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
	s_writedata <= "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
	wait for clk_period;
	ASSERT ((s_waitrequest= '0') and 
		(s_readdata = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"))
	REPORT "INITIALIZATION unsuccessful" 
	SEVERITY ERROR;

	REPORT "cache initialized";

	----------------------------------------------------------------------------------

	REPORT "start check for read from cache once== IDLE read miss";
	s_read <= '1';
	s_write <= '0';
	s_addr <= "00000000000000000000000000000000";
	s_writedata <= "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
	-- transition compare tag state
	wait for clk_period/2;
	ASSERT (s_waitrequest= '1') 
	REPORT "(IDLE read miss) Busy state waitrequest not working" & std_logic'image(s_waitrequest) 
	SEVERITY ERROR;
	wait for clk_period/2;
	-- state check dirty bits
	wait for clk_period/2;
	ASSERT (s_waitrequest= '1') 
	REPORT "(IDLE read miss) check dirty bits state not working"
	SEVERITY ERROR;
	wait for clk_period/2;
	-- checking dirty bit (should be zero)
	wait for clk_period/2;
	ASSERT (s_waitrequest= '1')
	REPORT "(IDLE read miss) dirty bit check state not working"
	SEVERITY ERROR;
	wait for clk_period/2;
	-- checking read main mem
	wait for clk_period/2;
	ASSERT (s_waitrequest= '1' and m_addr = 0 and m_read = '1' and m_write = '0' and m_waitrequest = '1')
	REPORT "(IDLE read miss) read main memory state not working"
	SEVERITY ERROR;
	wait for clk_period/2;

	-- checking write to cache
	wait for 9*clk_period/2; --4.5 clk
	ASSERT (s_waitrequest= '1' and s_writedata = "00000000001000000100000001100000" and m_addr = 0 and m_read = '1' and m_write = '0' and m_waitrequest = '1')
	REPORT "(IDLE read miss) burst read from main memory (0<32<64<96) state not working"
	SEVERITY ERROR;
	wait for clk_period/2;

	wait for clk_period/2; 
	ASSERT (s_waitrequest= '1' and s_writedata = "00000000001000000100000001100000" and m_addr = 0 and m_read = '0' and m_write = '0' and m_waitrequest = '0')
	REPORT "(IDLE read miss) burst write to cache (0<32<64<96) state not working"
	SEVERITY ERROR;
	wait for clk_period/2;
	
	s_read <= '0';
	s_write <= '0';
	s_addr <= "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
	s_writedata <= "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
	wait for clk_period/2; 
	ASSERT (s_waitrequest= '0')
	REPORT "(IDLE read miss) reset to idle state not working"
	SEVERITY ERROR;
	wait for clk_period/2;
	--------------------------------------------------------------------------------------
	
	REPORT "start check for read from cache once== IDLE read hit";
	s_read <= '1';
	s_write <= '0';
	s_addr <= "00000000000000000000000000000000";
	s_writedata <= "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
	-- transition compare tag state
	wait for clk_period/2;
	ASSERT (s_waitrequest= '1') 
	REPORT "(IDLE read hit) Busy state waitrequest not working" & std_logic'image(s_waitrequest) 
	SEVERITY ERROR;
	wait for clk_period/2;
	-- state read from cache
	wait for clk_period/2;
	ASSERT (s_waitrequest= '1') 
	REPORT "(IDLE read hit) read from cache state not working"
	SEVERITY ERROR;
	wait for clk_period/2;

	-- checking read data from cache
	wait for clk_period/2;
	ASSERT (s_waitrequest= '0')
	REPORT "(IDLE read hit) read wait req set to zerostate not working"
	SEVERITY ERROR;
	wait for clk_period/2;

	wait for clk_period/2; 
	ASSERT (s_waitrequest= '0' and s_readdata = "00000000001000000100000001100000")
	REPORT "(IDLE read hit) did not read (0<32<64<96)not working"
	SEVERITY ERROR;
	wait for clk_period/2;
	
	s_read <= '0';
	s_write <= '0';
	s_addr <= "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
	s_writedata <= "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
	wait for clk_period/2; 
	ASSERT (s_waitrequest= '0')
	REPORT "(IDLE read hit) reset to idle state not working"
	SEVERITY ERROR;
	wait for clk_period/2;

	-----------------------------------------------------------------------------------------
--TODO
	REPORT "start check for read from cache once== IDLE write with DB";
	s_read <= '0';
	s_write <= '1';
	s_addr <= "00000000000000000000000000000000";
	s_writedata <= "00000001000000100000001100000100";
	-- transition compare tag state
	wait for clk_period/2;
	ASSERT (s_waitrequest= '1') 
	REPORT "(IDLE write with dirty) Busy state waitrequest not working" & std_logic'image(s_waitrequest) 
	SEVERITY ERROR;
	wait for clk_period/2;
	-- state read from cache
	wait for clk_period/2;
	ASSERT (s_waitrequest= '1') 
	REPORT "(IDLE write with dirty) read from cache state not working"
	SEVERITY ERROR;
	wait for clk_period/2;

	-- checking read data from cache
	wait for clk_period/2;
	ASSERT (s_waitrequest= '0')
	REPORT "(IDLE write with dirty) read wait req set to zerostate not working"
	SEVERITY ERROR;
	wait for clk_period/2;

	wait for clk_period/2; 
	ASSERT (s_waitrequest= '0' and s_readdata = "00000000000000010000001000000011")
	REPORT "(IDLE write with dirty) did not read (0<1<2<3) not working"
	SEVERITY ERROR;
	wait for clk_period/2;
	
	s_read <= '0';
	s_write <= '0';
	s_addr <= "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
	s_writedata <= "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
	wait for clk_period/2; 
	ASSERT (s_waitrequest= '0')
	REPORT "(IDLE read hit) reset to idle state not working"
	SEVERITY ERROR;
	wait for clk_period/2;

	-----------------------------------------------------------------------------------------

end process;
	
end;