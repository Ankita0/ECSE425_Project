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
			PORT MAP(   clock,
                        instruction_in,
                        EX_reg_dest_addr,
                        MEM_reg_dest_addr,
                        WB_reg_dest_addr,
                        instruction_out,
                        stall
                        );

		test_process: process

			BEGIN
        --001000 00000 01011 0000011111010000
        --addi $rs $rt 2000
        --rs 00000
        --rt 01011
        --I-type instruction
        --should go to the 2nd if loop and check for ra only
                instruction_in<=x"200B07D0";
                EX_reg_dest_addr<="00000";
                MEM_reg_dest_addr<="00010";
                WB_reg_dest_addr<="00011";
                wait for 1ns;
                ASSERT (instruction_out = x"200B07D0") REPORT "I-type instruction_out mismatch for NO STALL" SEVERITY ERROR;
               --no stalls needed
                ASSERT (stall = '0') REPORT "stall mismatch for NO STALL" SEVERITY ERROR;


        --000000 00001 00010 00011 00000 100100
        --AND $v1 $at $v0
        --rs 00001
        --rt 00010
        --rd 00011
        --R-type instruction
        --should go to the 1st if loop and check for ra and rb
                instruction_in<=x"00221824";
                EX_reg_dest_addr<="00000";
                MEM_reg_dest_addr<="00000";
                WB_reg_dest_addr<="00001";
                wait for 1ns;
                ASSERT (instruction_out = x"00000020") REPORT "I-type instruction_out mismatch for STALL" SEVERITY ERROR;
               --stall needed
                ASSERT (stall = '1') REPORT "stall mismatch for STALL" SEVERITY ERROR;

  end process;

end arch;



