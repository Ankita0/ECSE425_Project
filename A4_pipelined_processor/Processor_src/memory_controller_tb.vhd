LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY memory_controller_tb IS
END memory_controller_tb;

ARCHITECTURE behaviour OF memory_controller_tb IS

--Declare the component that you are testing:
    COMPONENT memory_controller IS
      GENERIC(
      	ram_size : INTEGER := 8192
      );
      PORT(
      clock, reset: IN STD_LOGIC;
      
      --control signals
  		  do_memread: IN STD_LOGIC;
  		  do_memwrite: IN STD_LOGIC;
      
      --coming from EX stage
		  alu_result: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		  writedata: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		  reg_dst: IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		  reg_write: IN STD_LOGIC;
  		  --address: IN INTEGER RANGE 0 TO ram_size-1; --value of read/write address

      --going to WB stage
  		  data_to_WB: OUT STD_LOGIC_VECTOR (31 DOWNTO 0); --from ALU/memory
  		  reg_dst_out: OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
  		  reg_write_out: OUT STD_LOGIC
  		  --address_out: OUT INTEGER RANGE 0 TO ram_size-1
		);
    END COMPONENT;

    --all the input signals with initial values
    signal clock : std_logic := '0';
    signal reset : std_logic := '0';
    constant clk_period : time := 1 ns;
    --signal address: INTEGER RANGE 0 TO 8192-1;
    signal memwrite: STD_LOGIC := '0';
    signal memread: STD_LOGIC := '0';
    signal alu_result: STD_LOGIC_VECTOR (31 DOWNTO 0);
    signal reg_dst: STD_LOGIC_VECTOR (4 DOWNTO 0);
    signal reg_write: STD_LOGIC;
    signal data_to_WB: STD_LOGIC_VECTOR (31 DOWNTO 0);
    signal writedata: STD_LOGIC_VECTOR (31 DOWNTO 0);
    signal reg_dst_out: STD_LOGIC_VECTOR (4 DOWNTO 0);
    signal reg_write_out: STD_LOGIC ;
    --signal address_out: INTEGER RANGE 0 TO 8192-1;

BEGIN

    --dut => Device Under Test
    dut: memory_controller 
                PORT MAP(
                    clock => clock,
                    reset => reset,
                    do_memread => memread,
                    do_memwrite => memwrite,
                    alu_result => alu_result,
                    reg_dst => reg_dst,
                    reg_write => reg_write,
                    --address => address,
                    data_to_WB => data_to_WB,
                    writedata => writedata,
                    reg_dst_out => reg_dst_out,
                    reg_write_out => reg_write_out
                    --address_out => address_out
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

        wait for clk_period;      
 
        alu_result <= x"00000001";
        writedata <= x"00000002";

        --wait until rising_edge(waitrequest);
        memread <= '0';
        memwrite <= '1';
        --wait until rising_edge(waitrequest);
        ASSERT data_to_WB = x"00000001" REPORT "alu_result unsuccessful pass" SEVERITY ERROR;
        memwrite <= '0';
        wait for clk_period;
        memread <= '1';
        --wait until rising_edge(waitrequest);
        assert data_to_WB = x"00000002" report "unsuccessful read from memory" severity error;
        memread <= '0';
        wait;
        --wait for clk_period;
        --memread <= '1';
        --wait until rising_edge(waitrequest);
        --ASSERT data_to_WB = x"00000000000000000000000000000011") REPORT "NOT READ!" SEVERITY ERROR;

    END PROCESS;

 
END;