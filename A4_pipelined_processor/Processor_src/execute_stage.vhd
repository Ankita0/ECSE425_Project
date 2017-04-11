--EXECUTE PIPELINE STAGE FOR ECSE 425 PROJECT WINTER 2017
--GROUP 8
--Author: Alina Mambo

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--TO IMEPLENT FORWARIND I NEED a WAY to PRESENT MY ANSWER AS SOON AS IT IS READY IF ITS NEEDED!!!
--HAZARD DETECTON INSERT STALL FOR BRANCHING

--MAY NEED TO MOVE JUMP AND BRANCH TO THE PIPELINE PROCESS.
--PROBLEM : JAL NEEDS TO POINT TO ADDI IN DECODER
entity execute_stage is

	Port(	

			clock: in std_logic;
			PC_IN: in integer; -- PC from IF and Decode

			--Passing through IN
			IN_mem_write: in std_logic; --MEM write
			IN_mem_read: in std_logic;  --- MEM READ
			IN_mem_data_wr: in std_logic_vector(31 downto 0); --WRITE DATA TO MEM
			IN_wb_write: in std_logic; -- WB WRITE
			IN_wb_addr:in std_logic_vector(4 downto 0);

			-- ALU INPUT
			Input_A	: in std_logic_vector(31 downto 0);
			Input_B: in std_logic_vector(31 downto 0);
			alu_op_code: in std_logic_vector(5 downto 0);
			Jump: in std_logic;
			Branch: in std_logic;
			jump_addr: in std_logic_vector(25 downto 0);
			branch_offset: in integer;
			
			--ALU OUT
			result: out std_logic_vector(31 downto 0);
			PC_OUT: out integer;
			IF_MUX_CTRL: out std_logic;

			--Passing through OUT to MEM/WB
			OUT_mem_write: out std_logic;
			OUT_mem_read: out std_logic; 
			OUT_mem_data_wr: out std_logic_vector(31 downto 0);
			OUT_wb_write:out std_logic;
			OUT_wb_addr: out std_logic_vector(4 downto 0));
	


end execute_stage;


architecture arch of execute_stage is

Component alu is

	Generic( W : natural := 32; 
	         F : natural :=6;
	         clock_period : time := 1 ns);
	
	port( 		Mux_A		: in  std_logic_vector(W-1 downto 0); --RS
			   	Mux_B		: in  std_logic_vector(W-1 downto 0); --RT
          		Alu_Ctrl	: in  std_logic_vector(F-1 downto 0);
			   	clock 		: in std_logic;
			   	shamt		: in std_logic_vector (F-2 downto 0);
			   	Hi 			: out std_logic_vector(W-1 downto 0);
	       		Lo 			: out std_logic_vector(W-1 downto 0);
			   	Alu_Rslt	: out std_logic_vector(W-1 downto 0));
	end Component;


	--SIGNALS FOR ALU
	signal Mux_A, Mux_B 	: std_logic_vector(31 downto 0) :=(others=>'0');--done
	signal Alu_Ctrl 		: std_logic_vector(5 downto 0):=(others=>'0');--done
	signal shamt 			: std_logic_vector(4 downto 0):=(others=>'0');--missing
	signal clk 				: std_logic := '0'; -- dont need to port over
	signal Hi 				: std_logic_vector(31 downto 0):=(others=>'0'); --done
	signal Lo 				: std_logic_vector(31 downto 0):=(others=>'0'); -- done
	signal Alu_Rslt 		: std_logic_vector(31 downto 0):=(others=>'0');
	signal branch_taken:std_logic := '0';
	signal jal : std_logic := '0';

	begin
		alu_1: alu
		PORT MAP(Input_A,
			Input_B,
			alu_op_code,
			clock,
			shamt,
			Hi,
			Lo,
			Alu_Rslt);

	pipeline : process (Input_A,Input_B,Alu_Rslt,alu_op_code,clock,branch,jump)
	begin
		IF_MUX_CTRL<='0';
     	 
    if(rising_edge(clock)) then     
		------------------------------------------------
		--Move Values & Load
		------------------------------------------------
			--MFHI needs rd as dst
		if(alu_op_code= "010000") then
			result<=Hi;				--MFLO needs rd as dst
		elsif(alu_op_code=  "010010") then
			result<=Lo;				--LUI NEEDS rt
		elsif(alu_op_code= "001111") then
			--lui_shift:= std_logic_vector(unsigned(Mux_A)sll 16) ;
			result<=std_logic_vector(unsigned(Input_B)sll 16) ;
		elsif(alu_op_code= "111110") then
		  	jal<='1';
		else	
			result<=Alu_Rslt;
			if (branch = '1') then
				IF(Input_A /= Input_B) then
					PC_OUT<=PC_IN+branch_offset;
					IF_MUX_CTRL<='1';
				elsif (Input_A = Input_B) then
					--SET MUX AND NEW PC VALUE
					PC_OUT<=PC_IN+branch_offset;
					IF_MUX_CTRL<='1';
				end if;
			end if;
	          	if(jump='1') then
				if(jal='1') then -- change to if 100000 if the jal op_code is changed to addi
					 --SET MUX AND NEW PC VALUE
					PC_OUT<=to_integer(unsigned(jump_addr));
					IF_MUX_CTRL<='1';
				else
					PC_OUT<=to_integer(unsigned(Input_A));
					IF_MUX_CTRL<='1';
				end if;
			end if;
	
		end if;
    end if;
			
end process;

	--PASS VALUES TO NEXT STAGE
		OUT_mem_write <=IN_mem_write;
		OUT_mem_read <= IN_mem_read;
		OUT_mem_data_wr<= IN_mem_data_wr;
		OUT_wb_write<= IN_wb_write;
		OUT_wb_addr<= IN_wb_addr;
	
end arch;
