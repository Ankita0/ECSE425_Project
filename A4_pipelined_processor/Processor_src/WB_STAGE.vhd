LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY WB_STAGE is
  PORT(
      clock: IN STD_LOGIC;
      reg_write: IN STD_LOGIC;
      mux_control: IN STD_LOGIC;
      alu_data: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
      mem_data: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
      reg_dst: IN STD_LOGIC_VECTOR (4 DOWNTO 0);
      
      reg_write_out: OUT STD_LOGIC;
      reg_dst_out: OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
      writedata: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)    
      );
END WB_STAGE;

ARCHITECTURE behaviour of WB_STAGE is

  SIGNAL readdata: STD_LOGIC_VECTOR (31 DOWNTO 0);
  SIGNAL alu_data: STD_LOGIC_VECTOR (31 DOWNTO 0);
  SIGNAL mux_control: STD_LOGIC;
  SIGNAL mux_data: STD_LOGIC_VECTOR (31 DOWNTO 0);
  SIGNAL clock: STD_LOGIC;
  
  component EX_MUX 
    PORT(ID_instr_1, ID_instr_2 : in std_logic_vector(31 downto 0);
		  mux_control,CLK: in std_logic;
		  instr_to_Ex: out std_logic_vector(31 downto 0));
    end component;
    
  BEGIN
    MUX: EX_MUX PORT MAP(readdata, alu_data, mux_control, clock, mux_data);
      
    write_back : process(clock)
    BEGIN
      if rising_edge(clock) then
        readdata <= mem_data;
        alu_data <= alu_data;
        mux_control <= mux_input;
        writedata <= mux_data;
        reg_dst_out <= reg_dst;
        reg_write_out <= reg_write;
    end if;
  end process;
end behaviour;
        