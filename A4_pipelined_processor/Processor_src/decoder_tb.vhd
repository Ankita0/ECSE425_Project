library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity decoder_tb is
end decoder_tb;

architecture arch of decoder_tb is

    Component decoder is
    port(       instruction : in std_logic_vector(31 downto 0);
                clock       : in  std_logic;
                alu_op_code : out std_logic_vector(5 downto 0);
                reg_dst     : out std_logic; --Determines how the destination register is specified (rt or rd)
                reg_write   : out std_logic; --write to register file
                alu_src     : out std_logic; --source for second ALU input(rt or sign-extended immediate field)
                mem_write   : out std_logic; --write input address/data to memory
                mem_read    : out std_logic; --read input address from memory
                jump        : out std_logic; --Enables loading the jump target address into the PC
                branch      : out std_logic --Combined with a condition test boolean to enable loading the branch target address into the PC
    );  
    end Component;

    constant clk_period : time := 1 ns;
    signal instruction : std_logic_vector(31 downto 0):=(others=>'0');
    signal clk       : std_logic := '0';
    signal alu_op_code : std_logic_vector(5 downto 0):=(others=>'0');
    signal reg_dst : std_logic := '0';
    signal reg_write : std_logic := '0';
    signal alu_src : std_logic := '0';
    signal mem_write : std_logic := '0';
    signal mem_read : std_logic := '0';
    signal jump : std_logic := '0';
    signal branch : std_logic := '0';    

    BEGIN

        dut: decoder 
            PORT MAP(instruction,
                       clk,
                alu_op_code,
                reg_dst,
                reg_write,
                alu_src,
                mem_write,
                mem_read,
                jump,
                branch);           
    
    clk_process: process
      begin
        clk<='0';
        wait for clk_period/2;
        clk<='1';
        wait for clk_period/2;
      end process;
      
        test_process: process

            BEGIN
                --001000 00000 01011 0000011111010000
                --addi $rs $rt 2000
                instruction<=x"200B07D0";
                wait for clk_period;
                ASSERT (alu_op_code = "100000") REPORT "alu_op_code mismatch" SEVERITY ERROR;
                    

  end process;

end arch;