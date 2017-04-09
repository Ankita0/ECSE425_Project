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
    signal alu_result: STD_LOGIC_VECTOR (31 DOWNTO 0) := (others => '0');
    signal reg_dst: STD_LOGIC_VECTOR (4 DOWNTO 0) := (others => '0');
    signal reg_write: STD_LOGIC := '0';
    signal data_to_WB: STD_LOGIC_VECTOR (31 DOWNTO 0) := (others => '0');
    signal writedata: STD_LOGIC_VECTOR (31 DOWNTO 0) := (others => '0');
    signal reg_dst_out: STD_LOGIC_VECTOR (4 DOWNTO 0) := (others => '0');
    signal reg_write_out: STD_LOGIC := '0';
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
	reset<='1';
	wait for 0.5*clk_period;
	memread <='0';
	memwrite <='0';
	reg_write <='0';
	reset<='0';
	wait for 0.5*clk_period;
        --TEST WRITE
        alu_result <= x"00000001"; --addr in mem
        writedata <= x"00000002"; --value inside rt
        memwrite <= '1';
        wait for clk_period;  
        memwrite <= '0';
        memread <= '1';
        wait for clk_period;

        ASSERT data_to_WB = x"00000002" REPORT "unsuccessful write" SEVERITY ERROR;

        alu_result <= x"00000003";
        memread <= '0';
        wait for clk_period;        
        --TEST READ     
        memread <= '1';
	wait for clk_period;  
        assert data_to_WB = x"00000000" report "unsuccessful read" severity error;

        writedata <= x"00000004";
        memread <= '0';
        memwrite <= '1';
        wait for clk_period;
        
        assert data_to_WB = x"00000000" report "unsuccessful write" severity error;
        wait for clk_period;
        
	-- Register write back
        memread <= '0';
	memwrite <= '0';
	reg_dst <= "00010";
	reg_write <='1';
	wait for clk_period;
	assert reg_write_out = '1' report "reg_write does not propogate" severity error;
	assert data_to_WB =  x"00000004" report "reg write data does not propogate" severity error;
	reg_write <='0';
	wait for clk_period;
	reg_write <='1';
	reset<='1';
	wait for clk_period;
	assert reg_write_out = '1' report "reg_write does not change at reset" severity error;
	assert data_to_WB =  x"00000000" report "reg write data does not change at reset" severity error;
	assert reg_dst_out = "00000" report "reg dest does not change at reset" severity error;
        wait;

    END PROCESS;

 
END;