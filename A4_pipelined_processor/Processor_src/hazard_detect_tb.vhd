library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hazard_detect_tb is
end hazard_detect_tb;

architecture arch of hazard_detect_tb is

	Component hazard_detect is
    port(
    clock: in std_logic;
    instruction_in: in std_logic_vector(31 downto 0);
    EX_reg_dest_addr: in std_logic_vector(4 downto 0);
    MEM_reg_dest_addr: in std_logic_vector(4 downto 0);
    WB_reg_dest_addr: in std_logic_vector(4 downto 0);

    instruction_out: out std_logic_vector(31 downto 0);
    stall: out std_logic
    );
	end Component;

    constant clock_period : time := 1 ns;
    signal clock: std_logic :='0';
    signal instruction_in: std_logic_vector(31 downto 0):=(others=>'0');
    signal EX_reg_dest_addr: std_logic_vector(4 downto 0):=(others=>'0');
    signal MEM_reg_dest_addr: std_logic_vector(4 downto 0):=(others=>'0');
    signal WB_reg_dest_addr: std_logic_vector(4 downto 0):=(others=>'0');
    signal instruction_out: std_logic_vector(31 downto 0):=(others=>'0');
    signal stall: std_logic:='0';

	BEGIN

		dut: hazard_detect 
			PORT MAP(
                        instruction_in,
                        EX_reg_dest_addr,
                        MEM_reg_dest_addr,
                        WB_reg_dest_addr,
                        instruction_out,
                        stall
                        );

		test_process: process

			BEGIN
                instruction_in<=x"07C0";
                wait for 1ns;
                ASSERT (instruction_out = x"000007C0") REPORT "instruction_out mismatch" SEVERITY ERROR;
                ASSERT (stall = '0') REPORT "stall mismatch" SEVERITY ERROR;

                instruction_in<=x"07C0";
                wait for 1ns;
                ASSERT (instruction_out = x"000007C0") REPORT "instruction_out mismatch" SEVERITY ERROR;
                ASSERT (stall = '0') REPORT "stall mismatch" SEVERITY ERROR;
  					

  end process;

end arch;