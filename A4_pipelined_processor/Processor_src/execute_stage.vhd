--EXECUTE PIPELINE STAGE FOR ECSE 425 PROJECT WINTER 2017
--GROUP 8
--Author: Alina Mambo

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--TO IMEPLENT FORWARIND I NEED a WAY to PRESENT MY ANSWER AS SOON AS IT IS READY IF ITS NEEDED!!!
--HAZARD DETECTON INSERT STALL FOR BRANCHING

--MAY NEED TO MOVE JUMP AND BRANCH TO THE PIPELINE PROCESS.
--PROBLEM : BNE AND BEQ NEED TO ADD ADDR-> IN DECODER MAKE OP CODE ADDI
entity execute_stage is

	Port(	

			clock: in std_logic;
			PC_IN: in integer;

			--Passing through IN
			IN_mem_write: in std_logic ;
			IN_mem_read: in std_logic ;
			IN_reg_write: in std_logic ;
			IN_reg_dst:in std_logic_vector(4 downto 0);

			-- ALU INPUT
			Input_A	: in std_logic_vector(31 downto 0);
			Input_B: in std_logic_vector(31 downto 0);
			alu_op_code: in std_logic_vector(4 downto 0);
			Jump: in std_logic;
			Branch: in std_logic;
			jump_addr: in std_logic_vector(25 downto 0);
			
			--ALU OUT
			result: out std_logic_vector(31 downto 0);
			PC_OUT: out integer;
			IF_MUX_CTRL: out std_logic;

			--Passing through OUT to MEM/WB
			OUT_mem_write: out std_logic ;
			OUT_mem_read: out std_logic; 
			OUT_reg_write: out std_logic;
			OUT_reg_dst:out std_logic_vector(4 downto 0) );
	


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
			   	Alu_Rslt	: out std_logic_vector(W-1 downto 0);
			   	Zero 		: out std_logic;
			   	Overflow	: out std_logic;
			   	Carryout	: out std_logic);
	end Component;


	--SIGNALS FOR ALU
	signal Mux_A, Mux_B 	: std_logic_vector(31 downto 0) :=(others=>'0');--done
	signal Alu_Ctrl 		: std_logic_vector(5 downto 0):=(others=>'0');--done
	signal shamt 			: std_logic_vector(4 downto 0):=(others=>'0');--missing
	signal clk 				: std_logic := '0'; -- dont need to port over
	signal Hi 				: std_logic_vector(31 downto 0):=(others=>'0'); --done
	signal Lo 				: std_logic_vector(31 downto 0):=(others=>'0'); -- done
	signal Alu_Rslt 		: std_logic_vector(31 downto 0):=(others=>'0');
	signal Zero 			: std_logic := '0'; -- dont need to port over
	signal Overflow 		: std_logic := '0'; -- dont need to port over
	signal Carryout 		: std_logic := '0'; -- dont need to port over


	--SIGNALS FOR HI-LO REGISTERS NEED TO DO MFHI OR MFLO IN THE STAGE
	signal Hi_Reg: std_logic_vector (31 downto 0) :=(others=>'0');
	signal Lo_Reg: std_logic_vector (31 downto 0) :=(others=>'0');

	signal inter_rslt: std_logic_vector(31 downto 0):=(others=>'0'); --might need to change it for a variable
	signal branch_taken := '0';
	signal jal : std_logic := '0';

	begin

		ALU: alu
		PORT MAP(
					Mux_A,
					Mux_B,
					Alu_Ctrl,
					clk,
					shamt,
					Hi,
					Lo,
					Alu_Rslt,
					Zero,	
					Overflow,
					Carryout);

	jump_and_branch : process (jump,branch)

		------------------------------------------------
		--BRANCHING & JUMPING CHECK
		------------------------------------------------

			if(jump='1') then
				PC_OUT<=to_integer(unsigned(Input_A)); --TARGET AND rS come from INPUT A
			elsif(alu_opcode="111110") then --- set jal high so we can get the addr fro alu
				jal<='1';
			end if;

			if(branch ='1') then
					--bne
					IF(Input_A /= Input_B) then 

						--YES BRANCH TAKEN
						branch_taken <='1';					
					end if;

					--beq
					IF(Input_A = Input_B) then

						--YES BRANCH TAKEN
						branch_taken <='1';					
					end if;			
			end if;
		end process;

	pipeline : process

		Variable alu_opcode : std_logic_vector(4 downto 0);
		Variable lui_shift : std_logic_vector(31 downto 0);

		begin

			alu_opcode:= alu_op_code;


			case alu_opcode is
				------------------------------------------------
				--Move Values & Load
				------------------------------------------------

				--MFHI needs rd as dst
				when "010000" =>
					Hi_Reg<=Hi;
					result<=Hi_Reg


				--MFLO needs rd as dst
				when "010010"=>
					Lo_Reg<=Lo;
					result<=Lo_Reg

				--LUI NEEDS rt
				when "001111" =>

					lui_shift:= Mux_A sll 16 ;
					result<=Mux_A(31 downto 16) & others => '0';
				
				when others => NULL;

			end case;

			------------------------------------------------
			--EXECUTE
			------------------------------------------------
			if(rising_edge(clock)) then
					Mux_A<= Input_A;
					Mux_B<=Input_B;
					Alu_Ctrl<=alu_op_code;
					inter_result<=Alu_Rslt;
					if (branch_taken = '1') then
						--SET MUX AND NEW PC VALUE
						PC_OUT<=to_integer(unsigned(inter_result));
						IF_MUX_CTRL<='1';
					end if;

					if(jal='1') then
						--SET MUX AND NEW PC VALUE
						PC_OUT<=to_integer(unsigned(jump_addr));
						IF_MUX_CTRL<='1';
					end if;
			end if;
<<<<<<< HEAD


=======


>>>>>>> 873a9dd111f34f0dd36a080c6d51db1a19037276
			--RESULT OUT
			result<=inter_result;

		end process;

	--PASS VALUES TO NEXT STAGE
		OUT_mem_write <=IN_mem_write;
		OUT_mem_read <= IN_mem_read;
		OUT_reg_write <= IN_reg_write;
		OUT_reg_dst <=IN_reg_dst;


end arch;