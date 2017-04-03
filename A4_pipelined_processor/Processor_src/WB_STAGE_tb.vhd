LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY WB_STAGE_tb IS
END WB_STAGE_tb;

ARCHITECTURE behaviour OF WB_STAGE_tb IS

--Declare the component that you are testing:
    COMPONENT WB_STAGE IS
       PORT(
      clock: IN STD_LOGIC;
      reg_write: IN STD_LOGIC;
      alu_data: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
      mem_data: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
      reg_dst: IN STD_LOGIC_VECTOR (4 DOWNTO 0);
      
      reg_write_out: OUT STD_LOGIC;
      reg_dst_out: OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
      writedata: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)    
      );
    END COMPONENT;

    --all the input signals with initial values
        signal clock: STD_LOGIC;-- := '0';
        signal reg_write: STD_LOGIC := '0';
        signal alu_data: STD_LOGIC_VECTOR(31 downto 0):= (others => '0');
        signal mem_data: STD_LOGIC_VECTOR (31 downto 0):= (others => '0');
        signal reg_dst: STD_LOGIC_VECTOR (4 downto 0):= (others => '0');
        signal reg_write_out: STD_LOGIC := '0';
        signal reg_dst_out: STD_LOGIC_VECTOR (4 downto 0):= (others => '0');
        signal writedata: STD_LOGIC_VECTOR (31 downto 0):= (others => '0');
	constant clk_period : time := 1 ns;
        
BEGIN

    --dut => Device Under Test
    dut: WB_STAGE 
                PORT MAP(clock, reg_write, alu_data, mem_data, reg_dst, reg_write_out, reg_dst_out, writedata);

    clk_process : process
    BEGIN
        clock <= '0';
        wait for clk_period/2;
        clock <= '1';
        wait for clk_period/2;
    end process;

    test_process : process
    BEGIN
	       --wait for 0.5*clk_period;
        
        --TEST FROM MEMORY
        reg_write <= '1';
        reg_dst <= "00001";
        mem_data <= x"00000002";
        alu_data <= x"00000003";

        wait for 0.5*clk_period;
        ASSERT writedata = x"00000002" REPORT "unsuccessful write" SEVERITY ERROR;
        wait for 0.5*clk_period;
        
        reg_write <= '0';      
    
        --TEST READ 
	wait for 0.5*clk_period;    
        assert writedata = x"00000003" report "unsuccessful pass" severity error;
	wait for 0.5*clk_period;
        
        reg_write <= '1';
        reg_dst <= "00010";
        mem_data <= x"00000004";
        alu_data <= x"00000005";

	wait for 0.5*clk_period;
	ASSERT writedata = x"00000004" REPORT "unsuccessful write" SEVERITY ERROR;
	wait for 0.5*clk_period;

        reg_write <= '0';
        wait;

    END PROCESS;

 
END;
