
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
		jump_cond : in STD_LOGIC_VECTOR(3 downto 0);
		jump_op : in STD_LOGIC_VECTOR(1 downto 0);
		flags_reg_we : in STD_LOGIC;
		is_jump : in STD_LOGIC;
		wb_addr_in : in STD_LOGIC_VECTOR(2 downto 0);
		wb_mux_in : in STD_LOGIC_VECTOR (1 downto 0);
		wb_we_in : in STD_LOGIC;
		mux_C : in STD_LOGIC;
		mux_const : in STD_LOGIC;
		mux_lcx : in STD_LOGIC;
		mux_A : in  STD_LOGIC;
		mux_B : in  STD_LOGIC;
		ALU_op : in  STD_LOGIC_VECTOR (4 downto 0);
		wb_addr_out : out STD_LOGIC_VECTOR(2 downto 0);
		wb_mux_out : out STD_LOGIC_VECTOR (1 downto 0);
		wb_we_out : out STD_LOGIC;
		flag_status : out  STD_LOGIC;
		flags_out: out STD_LOGIC_VECTOR(3 downto 0);
		mem_out : out  STD_LOGIC_VECTOR (15 downto 0);
		ALU_out : out  STD_LOGIC_VECTOR (15 downto 0);
		PC_out : out STD_LOGIC_VECTOR (15 downto 0)
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

	signal const : std_logic_vector(15 downto 0);
	signal lcx : std_logic_vector(15 downto 0);

	signal FT_result : std_logic;
	signal jump : std_logic;

begin
	wb_addr_out <= wb_addr_in;
	wb_mux_out <= wb_mux_in;
	wb_we_out <= wb_we_in;

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
		s => FT_result
	);

	ALU_A_in <= A when mux_A = '0' else PC;
	ALU_B_in <= B when mux_B = '0' else imm;

	lcx <= A(15 downto 8) & imm(7 downto 0) when mux_lcx = '0' else imm(7 downto 0) & A(7 downto 0);
	const <= imm when mux_const = '0' else lcx;
	ALU_out <= ALU_C_out when mux_C = '0' else const;
	PC_out <= PC;

	jump <= '0' when is_jump = '0' else
		FT_result when jump_op(1) = '0' else '1';

	flag_status <= jump;

	flags_out <= ALU_flagsout;
	
end Behavioral;

