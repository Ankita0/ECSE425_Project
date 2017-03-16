--EXECUTE PIPELINE STAGE FOR ECSE 425 PROJECT WINTER 2017
--GROUP 
--Author: Alina Mambo
--TO IMEPLENT FORWARIND I NEED a WAY to PRESENT MY ANSWER AS SOON AS IT IS READY IF ITS NEEDED!!!
--HAZARD DETECTON INSERT STALL FOR BRANCHING
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity execute_stage is

	Port(	Input_A	: in std_logic_vector(31 downto 0);
			Input_B: in std_logic_vector(31 downto 0);
			alu_opcode: in std_logic_vector(4 downto 0);
			Jump: in std_logic;
			Branch: in std_logic;
			Alu_Rslt: out std_logic_vector(31 downto 0);
			branch_taken: out std_logic;
			rs: out std_logic_vector(31 downto 0);
			data_to_mem: out std_logic_vector(31 downto 0));


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
	signal Mux_A, Mux_B : std_logic_vector(31 downto 0) :=(others=>'0');
	signal Alu_Ctrl : std_logic_vector(5 downto 0):=(others=>'0');
	signal shamt : std_logic_vector(4 downto 0):=(others=>'0');
	signal clk : std_logic := '0';
	signal Hi 	: std_logic_vector(31 downto 0):=(others=>'0');
	signal Lo 	: std_logic_vector(31 downto 0):=(others=>'0');
	signal Alu_Rslt : std_logic_vector(31 downto 0):=(others=>'0');
	signal Zero : std_logic := '0';
	signal Overflow : std_logic := '0';
	signal Carryout : std_logic := '0';


	--SIGNALS FOR HI-LO REGISTERS NEED TO DO MFHI OR MFLO IN THE STAGE
	signal Hi: std_logic_vector (31 downto 0) :=(others=>'0');
	signal Lo: std_logic_vector (31 downto 0) :=(others=>'0');

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


	--MFHI, MFLO


	--SW/LW


	--Beq


	--bne


	--JAL



	-- J


	--JR



	--LUI


	

	pipeline: process
		begin

		end process;




end arch;
