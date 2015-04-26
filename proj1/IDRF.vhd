----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:07:32 03/12/2015 
-- Design Name: 
-- Module Name:    IDRF - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity IDRF is
	Port (
		rst : in STD_LOGIC;
		clk : in STD_LOGIC;
		PC_in : in  STD_LOGIC_VECTOR (15 downto 0);
		PCnext_in : in  STD_LOGIC_VECTOR (15 downto 0);
		inst : in  STD_LOGIC_VECTOR (15 downto 0);
		wb_data : in  STD_LOGIC_VECTOR (15 downto 0);
		wb_addr : in  STD_LOGIC_VECTOR (2 downto 0);
		wb_we : in  STD_LOGIC;
		exmem_wb_addr : in STD_LOGIC_VECTOR(2 downto 0);
		exmem_wb_we : in STD_LOGIC;
		exmem_alu_out : in STD_LOGIC_VECTOR(15 downto 0);
		exmem_mem_out :in STD_LOGIC_VECTOR(15 downto 0);
		exmem_PC_out : in STD_LOGIC_VECTOR(15 downto 0);
		exmem_wb_mux_in : in STD_LOGIC_VECTOR(1 downto 0);
		flag_s: in STD_LOGIC;
		flag_v: in STD_LOGIC;
		flag_c: in STD_LOGIC;
		flag_z: in STD_LOGIC;
		
		
		PC_out : out  STD_LOGIC_VECTOR (15 downto 0);
		RA : out  STD_LOGIC_VECTOR (15 downto 0);
		RB : out  STD_LOGIC_VECTOR (15 downto 0);
		const : out  STD_LOGIC_VECTOR (15 downto 0);
		ALU_op : OUT std_logic_vector(4 downto 0);
		wb_wc_addr : out std_logic_vector(2 downto 0);
		wb_wc_we : OUT std_logic;
		wb_mux : out std_logic_vector(1 downto 0);
		flags_enable : OUT std_logic;
		is_jump : out std_logic;
		jump_cond : out std_logic_vector(3 downto 0);
		jump_op : out std_logic_vector(1 downto 0);
		mem_we : OUT std_logic;
		mux_lcx : OUT std_logic;
		mux_C : OUT std_logic;
		mux_const : OUT std_logic;
		mux_a : OUT std_logic;
		mux_b : OUT std_logic;
		halt : OUT std_logic;
		crush : out std_logic;
		override_addr : out std_logic_vector(15 downto 0)
	);
end IDRF;

architecture Behavioral of IDRF is

	COMPONENT RF
	PORT(
		Aaddr : IN std_logic_vector(2 downto 0);
		Baddr : IN std_logic_vector(2 downto 0);
		Daddr : IN std_logic_vector(2 downto 0);
		DATA : IN std_logic_vector(15 downto 0);
		WE : IN std_logic;
		clk : IN std_logic;
		rst : IN std_logic;
		A : OUT std_logic_vector(15 downto 0);
		B : OUT std_logic_vector(15 downto 0)
		);
	END COMPONENT;
	
	COMPONENT SExt
	PORT(
		const8 : IN std_logic_vector(7 downto 0);
		const11 : IN std_logic_vector(10 downto 0);
		const12 : IN std_logic_vector(11 downto 0);
		inselect : IN std_logic_vector(2 downto 0);          
		extended : OUT std_logic_vector(15 downto 0)
		);
	END COMPONENT;

	signal a_addr : std_logic_vector(2 downto 0);
	signal b_addr : std_logic_vector(2 downto 0);
	
	signal depends_a : std_logic;
	signal depends_b : std_logic;
	
	signal op : std_logic_vector(4 downto 0);
	
	signal A_RF : std_logic_vector(15 downto 0);
	signal B_RF : std_logic_vector(15 downto 0);
	
	signal forwarded : std_logic_vector(15 downto 0);
	
	signal taken : std_logic;
	signal flagtest : std_logic;
	
	signal actualNextPC : std_logic_vector(15 downto 0);
	signal jump_addr : std_logic_vector(15 downto 0);
	
	signal const_s : std_logic_vector(15 downto 0);
	
	signal crush_s : std_logic;
	signal crush_r : std_logic;
begin
	
	PC_out <= PC_in;
	
	b_addr <= inst(2 downto 0);
	
	Inst_RF: RF PORT MAP(
		Aaddr => a_addr,
		Baddr => b_addr,
		A => A_RF,
		B => B_RF,
		Daddr => wb_addr,
		DATA => wb_data,
		WE => wb_we,
		clk => clk,
		rst => rst
	);
	
	Inst_SExt: SExt PORT MAP(
		const8 => inst(7 downto 0),
		const11 => inst(10 downto 0),
		const12 => inst(11 downto 0),
		inselect => inst(15 downto 13),
		extended => const_s
	);
	
	a_addr <= inst(13 downto 11) when inst(15 downto 14)="11" else -- Quando é lcl ou lch
		inst(5 downto 3);

	ALU_op <= "10011" when inst(15 downto 12) = "0011" else -- absolute jumps
		--"00000" when inst(15 downto 14) = "00" else -- relative jumps
		"00000" when inst(15 downto 14) = "11" else -- lcl e lch
		inst(10 downto 6);

	mux_a <= '1' when inst(15 downto 14) = "00" else	-- control transfer
		'0'; -- Possibly overly simplistic
	
	mux_b <= '0' when inst(15 downto 12) = "0011" else	-- JAL and JR
		'0' when inst(15 downto 14) = "10" else	-- ALU ops
		'1';
	
	jump_cond <= inst(11 downto 8); -- jump cond
	jump_op <= inst(13 downto 12); -- jump op

	-- enable flags when this is an ALU op (and not a RAM one)
	flags_enable <= '1' when inst(15 downto 14) = "10"
		and inst(10 downto 7) /= "0101" else
		'0';
	
	wb_wc_addr <= "111" when inst(15 downto 11) = "00110" else
		inst(13 downto 11);	-- WC addr
	-- WC we
	wb_wc_we <= '1' when inst(15 downto 11) = "00110" else -- jal
		'0' when inst(15 downto 14) = "00" else	-- control transfer
		'0' when inst(15 downto 14) = "10" and inst(10 downto 6)="01011" else	-- store in Mem
		'1';
  
	-- WB mux control
	wb_mux <= "1X" when inst(15 downto 11) = "00110" else --jal
		"01" when inst(15 downto 14) = "10" and inst(10 downto 6)="01010" else	-- load from Mem
		"00"; -- load from ALU
	
	mux_C <= '1' when inst(15 downto 14) = "11" else -- Quando é lcl ou lch
		'1' when inst(14) = '1' else
		'0'; -- Whether output is immediate or ALU
	-- Possi
	mux_const <= inst(15); -- Complete constant load or high/low part;
	-- Possibly overly simplistic
	mux_lcx <= inst(10); -- Low or High lc
	
	mem_we <= '1' when inst(15 downto 14) = "10" and inst(10 downto 6)="01011" else
		'0'; --mem_en
		
	is_jump <= '1' when inst(15 downto 14) = "00" else '0';
	
	
	-- conflict detectedion data

	-- /!\

	op <= "10000" when inst(15 downto 14) /= "10" else inst(10 downto 6);
	with op select depends_a <= '0' when "10000",
		'0' when "10011",
		'0' when "11100",
		'0' when "11111",
		'1' when others;
		
	with op select depends_b <= '0' when "00011",
		'0' when "00110",
		'0' when "01000",
		'0' when "01001",
		'0' when "10000",
		'0' when "10101",
		'0' when "11010",
		'0' when "11111",
		'1' when others;

	halt <= '1' when exmem_wb_we = '1' and (exmem_wb_addr = a_addr or exmem_wb_addr = inst(2 downto 0)) else '0';
	
	
	RA <= forwarded when (a_addr = exmem_wb_addr and exmem_wb_we = '1') else A_RF;
	RB <= forwarded when (b_addr = exmem_wb_addr and exmem_wb_we = '1') else B_RF;
	
	
	
	forwarded <= exmem_mem_out when exmem_wb_mux_in = "01" else
		exmem_alu_out when exmem_wb_mux_in = "00" else
		exmem_PC_out;
		
		
		
		
	--Conflitos de controlo:
	
	with inst(11 downto 8) select flagtest <= flag_s when "0100",
		flag_z when "0101",
		flag_c when "0110",
		flag_z or flag_s when "0111",
		'1' when "0000",
		flag_v when "0011",
		'0' when others;
	
	taken <= inst(13) or (inst(12) xnor flagtest);
	
	jump_addr <= B_RF when inst(13 downto 12) = "11" else
		PC_in + const_s;
	
	const <= const_s;
	
	actualNextPC <= PC_in when taken = '0' else
		jump_addr;
	
	crush_s <= '0' when crush_r = '1' or inst(15 downto 14) /= "00" or PCnext_in = actualNextPC else '1';
	crush <= crush_s;
	
	override_addr <= actualNextPC;
	
	process (clk,rst)
	begin
		if (rst='1') then
			crush_r <= '0';
		end if;
		if (clk'event and clk = '1') then
			crush_r <= crush_s;
		end if;
	end process;

end Behavioral;

