library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity signextension_tb is
end signextension_tb;

architecture arch of signextension_tb is

	Component signextension is
    port(
    bit16 : in std_logic_vector(15 downto 0);
    bit32 : out std_logic_vector(31 downto 0)
    );
	end Component;

	constant clk_period : time := 1 ns;
    signal bit16 : std_logic_vector(15 downto 0);
    signal bit32 : std_logic_vector(31 downto 0);

	BEGIN

		dut: signextension 
			PORT MAP(bit16,bit32);
				
		clk_process: process
		  begin
		    clk <='0';
		    wait for clk_period/2;
		    clk<='1';
		    wait for clk_period/2;
		   end process;
		   

		test_process: process

			BEGIN
                bit16<=x"07C0";
                wait for clk_period;
                ASSERT (bit32 = x"000007C0") REPORT "sign extend fail" SEVERITY ERROR;

                bit16<=x"87C0";
                wait for clk_period;
                ASSERT (bit32 = x"FFFF87C0") REPORT "sign extend fail" SEVERITY ERROR;
   					

  end process;

end arch;