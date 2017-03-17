--EXECUTE PIPELINE STAGE FOR ECSE 425 PROJECT WINTER 2017
--GROUP 
--Author: Alina Mambo
--TO IMEPLENT FORWARIND I NEED a WAY to PRESENT MY ANSWER AS SOON AS IT IS READY IF ITS NEEDED!!!
--HAZARD DETECTON INSERT STALL FOR BRANCHING
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity execute_stage is

	Port(	

			clock: in std_logic;

			--Passing through IN
			IN_mem_write
			IN_mem_read
			IN_reg_write
			IN_reg_dst

			-- ALU INPUT
			Input_A	: in std_logic_vector(31 downto 0);
			Input_B: in std_logic_vector(31 downto 0);
			alu_op_code: in std_logic_vector(4 downto 0);
			Jump: in std_logic;
			Branch: in std_logic;
			
			--ALU OUT
			branch_taken: out std_logic;
			result: out std_logic_vector(31 downto 0);

			--Passing through OUT to MEM/WB
			OUT_mem_write: in std_logic ;
			OUT_mem_read: in std_logic; 
			OUT_reg_write: in std_logic;
			OUT_reg_dst:in std_logic_vector(4 downto 0);
	


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
	signal Mux_A, Mux_B 	: std_logic_vector(31 downto 0) :=(others=>'0');
	signal Alu_Ctrl 		: std_logic_vector(5 downto 0):=(others=>'0');
	signal shamt 			: std_logic_vector(4 downto 0):=(others=>'0');
	signal clk 				: std_logic := '0';
	signal Hi 				: std_logic_vector(31 downto 0):=(others=>'0');
	signal Lo 				: std_logic_vector(31 downto 0):=(others=>'0');
	signal Alu_Rslt 		: std_logic_vector(31 downto 0):=(others=>'0');
	signal Zero 			: std_logic := '0';
	signal Overflow 		: std_logic := '0';
	signal Carryout 		: std_logic := '0';


	--SIGNALS FOR HI-LO REGISTERS NEED TO DO MFHI OR MFLO IN THE STAGE
	signal Hi_Reg: std_logic_vector (31 downto 0) :=(others=>'0');
	signal Lo_Reg: std_logic_vector (31 downto 0) :=(others=>'0');

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

	pipeliine : process

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

					lui_shift:= Mux_B sll 16 ;
					result<=Mux_B(31 downto 16) & others => '0';

				------------------------------------------------
				--BRANCHING & JUMPING
				------------------------------------------------

				--bne
				when "000101"=>

				IF(Mux_A /= Mux_B) then 
					--YES BRANCH TAKEN
					branch_taken <='1';

					-- Calculate address for branch
					Alu_Ctrl<="100000";
				end if;

				--beq
				when "000100"=>
					IF(Mux_A = Mux_B) then

					--YES BRANCH TAKEN
					branch_taken <='1';

					-- Calculate address for branch
					Alu_Ctrl<="100000";

				end if;


				--JAL  --JUMP & STORE
				when "000011"=>


				-- J  JUMP TO TARGET
				when "000010"=>


				--JR NEEDS RS AS SOURCE and JUMP TO address inside
				when "001000" =>
				

				when others => NULL;

			end case;

		--FINISH pipelining	


		Alu_Ctrl<=alu_op_code;
		end process;

	--PASS VALUES TO NEXT STAGE
		OUT_mem_write <=IN_mem_write;
		OUT_mem_read <= IN_mem_read;
		OUT_reg_write <= IN_reg_write;
		OUT_reg_dst <=IN_reg_dst;


end arch;
