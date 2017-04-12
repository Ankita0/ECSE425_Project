library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Branch_Predictor_1Bit_tb is
end Branch_Predictor_1Bit_tb;

architecture arch of Branch_Predictor_1Bit_tb is
  
  component branch_predictor_1bit is
    
		port (clk : in std_logic;
			  init : in std_logic;
   		   branch_taken : in std_logic; --INPUT from IF stage
   		   PC : in integer;
      		b_predict : out std_logic
  );
  end component;
  
  signal clk : std_logic;
  signal init : std_logic;
  signal branch_taken : std_logic;
  signal PC : integer :=1;
  signal branch_predict: std_logic;
  constant clk_period: time := 1 ns;
    
begin
  
  dut: branch_predictor_1bit
  PORT MAP(clk ,
			     init ,
      		   branch_taken ,
      		   PC ,
      		   branch_predict );
      		   
clk_process : process
    BEGIN
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;
    
  test_process: PROCESS
    begin
      
      init<='1';
      wait for clk_period;
      init<='0';
      --Test FSM
      PC<=1;
      branch_taken<='1'; --should be in taken
      wait for clk_period;
      branch_taken<='1';  --should stay in taken
      wait for clk_period;
      branch_taken<='0'; -- move to WT
      wait for clk_period;
      branch_taken<='0'; --move to WNT
      wait for clk_period;
      branch_taken<='0'; --move to NT
      wait for clk_period;
      branch_taken<='0'; --stay NT
      wait for clk_period;     
  END PROCESS;

end arch;