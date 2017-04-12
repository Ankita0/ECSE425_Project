library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hazard_detect is
	port(
	clock: in std_logic;
	instruction_in: in std_logic_vector(31 downto 0);
	EX_reg_dest_addr: in std_logic_vector(4 downto 0);
	MEM_reg_dest_addr: in std_logic_vector(4 downto 0);
	WB_reg_dest_addr: in std_logic_vector(4 downto 0);

	instruction_out: out std_logic_vector(31 downto 0);
	stall: out std_logic
	);
end hazard_detect;

architecture arch of hazard_detect is
  signal previous_instruction: std_logic_vector(31 downto 0);
  signal previous_stall: std_logic;
  signal stall_s: std_logic;
begin
  --process to store the previous instruction
  process(clock)
    begin
    if(rising_edge(clock))then
    		previous_instruction<=instruction_in;
    		previous_stall<=stall_s;
  		end if;
	end process;
  
	process(instruction_in,previous_instruction,previous_stall)
		Variable op_code: std_logic_vector(5 downto 0);
		Variable ra: std_logic_vector(4 downto 0);
		Variable rb: std_logic_vector(4 downto 0);
	begin

		-- if stall
		-- stall = (IF/ID.rA != 0 && 
		-- (IF/ID.rA == ID/EX.reg_dest_addr 
		-- || IF/ID.rA == EX/M.reg_dest_addr 
		-- || IF/ID.rA == M/WB.reg_dest_addr))
		-- || (same for rB)
		op_code := instruction_in(31 downto 26);
		ra := instruction_in(25 downto 21);
		rb := instruction_in(20 downto 16);
		--check for both ra and rb
		if (op_code="000000") then
			if ((NOT(ra = "00000") AND 
				((ra = EX_reg_dest_addr) OR
			 	(ra = MEM_reg_dest_addr) OR 
			 	(ra = WB_reg_dest_addr))) OR 
			 	(NOT(rb = "00000") AND 
			 	((rb = EX_reg_dest_addr) OR
			 	(rb = MEM_reg_dest_addr) OR 
			 	(rb = WB_reg_dest_addr)))) then 
			--insert an add $r0, $r0, $r0
			instruction_out<=x"00000020";
			stall_s<='1';
			stall<='1';
			elsif(previous_stall='1') then
			instruction_out<=previous_instruction;
			stall_s<='0';
			stall<='0';			
			else
			instruction_out<=instruction_in;
			stall_s<='0';
			stall<='0';
			end if;

		--only check for ra
		else
			if (NOT(ra = "00000" OR ra = "UUUUU" OR ra="XXXXX") AND 
				((ra = EX_reg_dest_addr) OR
			 	(ra = MEM_reg_dest_addr) OR 
			 	(ra = WB_reg_dest_addr))) then 
			--insert an add $r0, $r0, $r0
			instruction_out<=x"00000020";
			stall_s<='1';
			stall<='1';
			elsif(previous_stall='1') then
			instruction_out<=previous_instruction;
			stall_s<='0';
			stall<='0';			
			else
			instruction_out<=instruction_in;
			stall_s<='0';
			stall<='0';
			end if;

		end if;
		
	end process;
end arch; 
