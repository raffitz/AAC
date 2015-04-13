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
		inst : in  STD_LOGIC_VECTOR (15 downto 0);
		wb_data : in  STD_LOGIC_VECTOR (15 downto 0);
		wb_addr : in  STD_LOGIC_VECTOR (2 downto 0);
		wb_we : in  STD_LOGIC;
		exmem_wb_addr : in STD_LOGIC_VECTOR(2 downto 0);
		exmem_wb_we : in STD_LOGIC;
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
	
	signal depends_a : std_logic;
	signal depends_b : std_logic;
	
	signal op : inst(10 downto 0);
begin
	
	PC_out <= PC_in;
	
	Inst_RF: RF PORT MAP(
		Aaddr => a_addr,
		Baddr => inst(2 downto 0),
		A => RA,
		B => RB,
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
		extended => const
	);
	
	a_addr <= inst(13 downto 11) when inst(15 downto 14)="11" else -- Quando é lcl ou lch
		inst(5 downto 3);

	ALU_op <= "10011" when inst(15 downto 12) = "0011" else -- absolute jumps
		"00000" when inst(15 downto 14) = "00" else -- relative jumps
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
	wb_wc_we <= '1' when inst(15 downto 11) = "00110" else
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
	
	
	-- conflict detectedion

	-- /!\

	op <= "10000" when inst(15 downto 14) =/ "10" else inst(10 downto 6);
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

end Behavioral;

