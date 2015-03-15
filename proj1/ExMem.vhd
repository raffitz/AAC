----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:50:45 03/12/2015 
-- Design Name: 
-- Module Name:    ExMem - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ExMem is
	Port (
		clk : in  STD_LOGIC;
		mem_en : in  STD_LOGIC;
		A : in  STD_LOGIC_VECTOR (15 downto 0);
		B : in  STD_LOGIC_VECTOR (15 downto 0);
		PC : in  STD_LOGIC_VECTOR (15 downto 0);
		imm : in  STD_LOGIC_VECTOR (15 downto 0);
		instr_in : in  STD_LOGIC_VECTOR (14 downto 0);	-- see decomposition below
		instr_out : out  STD_LOGIC_VECTOR (4 downto 0);
		mux_A : in  STD_LOGIC;
		mux_B : in  STD_LOGIC;
		ALU_op : in  STD_LOGIC_VECTOR (4 downto 0);
		flag_status : out  STD_LOGIC;
		mem_out : out  STD_LOGIC_VECTOR (15 downto 0);
		ALU_out : out  STD_LOGIC_VECTOR (15 downto 0)
	);
end ExMem;

architecture Behavioral of ExMem is

	COMPONENT ALU
		PORT(
			A : IN std_logic_vector(15 downto 0);
			B : IN std_logic_vector(15 downto 0);
			sel : IN std_logic_vector(4 downto 0);
			flagsin : IN std_logic_vector(3 downto 0);          
			flagsout : OUT std_logic_vector(3 downto 0);
			C : OUT std_logic_vector(15 downto 0)
		);
	END COMPONENT;

	COMPONENT RAM
		PORT(
			clk : IN std_logic;
			data_in : IN std_logic_vector(15 downto 0);
			addr : IN std_logic_vector(15 downto 0);
			we : IN std_logic;          
			data_out : OUT std_logic_vector(15 downto 0)
		);
	END COMPONENT;

	COMPONENT FT
		PORT(
			clk : IN std_logic;
			flags : IN std_logic_vector(3 downto 0);
			cond : IN std_logic_vector(3 downto 0);
			op : IN std_logic_vector(1 downto 0);          
			en : IN std_logic;
			flags_out : OUT std_logic_vector(3 downto 0);
			s : OUT std_logic
		);
	END COMPONENT;

	signal ALU_A_in : std_logic_vector(15 downto 0);
	signal ALU_B_in : std_logic_vector(15 downto 0);
	signal ALU_C_out : std_logic_vector(15 downto 0);
	signal ALU_flagsout : std_logic_vector(3 downto 0);
	signal ALU_flagsin : std_logic_vector(3 downto 0);

	signal jump_cond : std_logic_vector(3 downto 0);
	signal jump_op : std_logic_vector(1 downto 0);
	signal flags_reg_we : std_logic;

	signal const : std_logic_vector(15 downto 0);
	signal lcx : std_logic_vector(15 downto 0);
	signal mux_C : std_logic;
	signal mux_const : std_logic;
	signal mux_lcx : std_logic;

begin

	jump_cond <= instr_in(3 downto 0);
	jump_op <= instr_in(5 downto 4);
	flags_reg_we <= instr_in(6);
	instr_out <= instr_in(11 downto 7);	-- register to WB and WB mux control signal and WriteEnable
	mux_C <= instr_in(12);
	mux_const <= instr_in(13);
	mux_lcx <= instr_in(14);

	Inst_ALU: ALU PORT MAP(
		A => ALU_A_in,
		B => ALU_B_in,
		sel => ALU_op,
		flagsin => ALU_flagsin,
		flagsout => ALU_flagsout,
		C => ALU_C_out
	);

	Inst_RAM: RAM PORT MAP(
		clk => clk,
		data_in => B,
		addr => A,
		we => mem_en,
		data_out => mem_out
	);

	Inst_FT: FT PORT MAP(
		clk => clk,
		flags => ALU_flagsout,
		cond => jump_cond,
		op => jump_op,
		en => flags_reg_we,
		flags_out => ALU_flagsin,
		s => flag_status
	);

	ALU_A_in <= A when mux_A = '0' else PC;
	ALU_B_in <= B when mux_B = '0' else imm;

	lcx <= A(15 downto 8) & imm(7 downto 0) when mux_lcx = '0' else imm(15 downto 8) & A(7 downto 0);
	const <= imm when mux_const = '0' else lcx;
	ALU_out <= ALU_C_out when mux_C = '0' else const;

end Behavioral;

