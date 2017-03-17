LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY memory_controller_tb IS
END memory_controller_tb;

ARCHITECTURE behaviour OF memory_controller_tb IS

--Declare the component that you are testing:
    COMPONENT memory_controller IS
        GENERIC(
    ram_size : INTEGER := 8192;
  		mem_delay : time := 10 ns;
		clock_period : time := 1 ns
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
    END COMPONENT;

    --all the input signals with initial values
    signal clock : std_logic := '0';
    signal reset : std_logic := '0';
    constant clk_period : time := 1 ns;
    signal address: INTEGER RANGE 0 TO 8192-1;
    signal memwrite: STD_LOGIC := '0';
    signal memread: STD_LOGIC := '0';
    signal alu_data: STD_LOGIC_VECTOR (31 DOWNTO 0) := (others=> '0');
    signal reg_dst: STD_LOGIC_VECTOR (4 DOWNTO 0) := (others=> '0');
    signal reg_write: STD_LOGIC := '0';
    signal data_WB: STD_LOGIC_VECTOR (31 DOWNTO 0) := (others=> '0');
    signal reg_dst_out: STD_LOGIC_VECTOR (4 DOWNTO 0) := (others=> '0');
    signal reg_write_out: STD_LOGIC := '0';
    signal address_out: INTEGER RANGE 0 TO 8192-1;

BEGIN

    --dut => Device Under Test
    dut: memory_controller 
                PORT MAP(
                    clock => clock,
                    reset => reset,
                    do_memread => memread,
                    do_memwrite => memwrite,
                    alu_data => alu_data,
                    reg_dst => reg_dst,
                    reg_write => reg_write,
                    address => address,
                    data_WB => data_WB,
                    reg_dst_out => reg_dst_out,
                    reg_write_out => reg_write_out,
                    address_out => address_out
                );

    clk_process : process
    BEGIN
        clock <= '0';
        wait for clk_period/2;
        clock <= '1';
        wait for clk_period/2;
    end process;

    test_process : process
    BEGIN

        memread <= '0';
        memwrite <= '1'; 
        alu_data <= "00000000000000000000000000000011";
        wait for clk_period;
        ASSERT (data_WB = "00000000000000000000000000000011") REPORT "NOT WRITTEN!" SEVERITY ERROR;
        
        memread <= '1';
        memwrite <= '0';
        alu_data <= "00000000000000000000000000000010";
        wait for clk_period;
        ASSERT (data_WB = "00000000000000000000000000000011") REPORT "NOT READ!" SEVERITY ERROR;

    END PROCESS;

 
END;