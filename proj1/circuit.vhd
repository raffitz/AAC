----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:49:44 03/11/2015 
-- Design Name: 
-- Module Name:    circuit - Behavioral 
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

entity circuit is
	Port (
		clk : in STD_LOGIC;
		rst : in STD_LOGIC;
		output : out STD_LOGIC_VECTOR(15 downto 0);
		flag : out STD_LOGIC
	);
end circuit;

architecture Behavioral of circuit is

	COMPONENT TGC
		PORT(
				clk : IN std_logic;
				rst : IN std_logic;          
				IF_e : OUT std_logic;
				IDRF_e : OUT std_logic;
				EXM_e : OUT std_logic;
				WB_e : OUT std_logic
			);
	END COMPONENT;

	COMPONENT IFetch
		PORT(
			clk : IN std_logic;
			rst : IN std_logic;
			jaddr : IN std_logic_vector(15 downto 0);
			jsel : IN std_logic;
			pc_en : IN std_logic;        
			addr : OUT std_logic_vector(15 downto 0);
			irout : OUT std_logic_vector(15 downto 0)
		);
	END COMPONENT;

	COMPONENT IDRF
		PORT(
			rst : IN std_logic;
			clk : IN std_logic;
			PC_in : IN std_logic_vector(15 downto 0);
			inst : IN std_logic_vector(15 downto 0);
			wb_data : IN std_logic_vector(15 downto 0);
			wb_addr : IN std_logic_vector(2 downto 0);
			wb_we : IN std_logic;          
			PC_out : OUT std_logic_vector(15 downto 0);
			RA : OUT std_logic_vector(15 downto 0);
			RB : OUT std_logic_vector(15 downto 0);
			const : OUT std_logic_vector(15 downto 0);
			ALU_op : OUT std_logic_vector(4 downto 0);
			inst_out : OUT std_logic_vector(15 downto 0);
			mux_a : OUT std_logic;
			mux_b : OUT std_logic
		);
	END COMPONENT;

	COMPONENT ExMem
		PORT(
			clk : IN std_logic;
			mem_en : IN std_logic;
			A : IN std_logic_vector(15 downto 0);
			B : IN std_logic_vector(15 downto 0);
			PC : IN std_logic_vector(15 downto 0);
			imm : IN std_logic_vector(15 downto 0);
			jump_cond : IN std_logic_vector(3 downto 0);
			jump_op : IN std_logic_vector(5 downto 4);
			flags_reg_we : IN std_logic;
			wb_addr_in : IN std_logic_vector(2 downto 0);
			wb_mux_in : IN std_logic;
			wb_we_in : IN std_logic;
			mux_C : IN std_logic;
			mux_const : IN std_logic;
			mux_lcx : IN std_logic;
			mux_A : IN std_logic;
			mux_B : IN std_logic;
			ALU_op : IN std_logic_vector(4 downto 0);          
			wb_addr_out : OUT std_logic_vector(2 downto 0);
			wb_mux_out : OUT std_logic;
			wb_we_out : OUT std_logic;
			flag_status : OUT std_logic;
			mem_out : OUT std_logic_vector(15 downto 0);
			ALU_out : OUT std_logic_vector(15 downto 0)
			PC_out : OUT std_logic_vector(15 downto 0)
		);
	END COMPONENT;

	COMPONENT WB
		PORT(
			mem_data : IN std_logic_vector(15 downto 0);
			alu_data : IN std_logic_vector(15 downto 0);
			curr_PC : IN std_logic_vector(15 downto 0);
			src_sel : IN std_logic_vector(15 downto 0);          
			output : OUT std_logic_vector(15 downto 0)
		);
	END COMPONENT;

	-- registers in and out

	signal if_pc_out : std_logic_vector(15 downto 0);
	signal if_instr_out : std_logic_vector(15 downto 0);

	signal idrf_pc_in : std_logic_vector(15 downto 0);
	signal idrf_instr_in : std_logic_vector(15 downto 0);

	signal idrf_a_out : std_logic_vector(15 downto 0);
	signal idrf_b_out : std_logic_vector(15 downto 0);
	signal idrf_pc_out : std_logic_vector(15 downto 0);
	signal idrf_instr_out : std_logic_vector(15 downto 0);
	signal idrf_mux_a_out : std_logic;
	signal idrf_mux_b_out : std_logic;
	signal idrf_wc_we_out : std_logic;
	signal idrf_wc_addr_out : std_logic_vector(2 downto 0);
	signal idrf_outsel_out : std_logic;
	signal idrf_alu_op_out : std_logic_vector(4 downto 0);

	signal idrf_wb_we_out : std_logic;
	signal idrf_const_out : std_logic_vector(15 downto 0);
	signal idrf_inst_out_aux : std_logic_vector(15 downto 0);

	signal idrf_wb_data_in : std_logic_vector(15 downto 0);
	signal idrf_wb_addr_in : std_logic_vector(2 downto 0);
	signal idrf_wb_we_in : std_logic;

	signal exmem_a_in : std_logic_vector(15 downto 0);
	signal exmem_b_in : std_logic_vector(15 downto 0);
	signal exmem_pc_in : std_logic_vector(15 downto 0);
	signal exmem_imm_in : std_logic_vector(15 downto 0);
	signal exmem_instr_in : std_logic_vector(14 downto 0);
	signal exmem_mux_a_in : std_logic;
	signal exmem_mux_b_in : std_logic;
	signal exmem_wc_we_in : std_logic;
	signal exmem_wc_addr_in : std_logic_vector(2 downto 0);
	signal exmem_outsel_in : std_logic;
	signal exmem_alu_op_in : std_logic_vector(4 downto 0);

	signal exmem_wb_we_in : std_logic;
	signal exmem_const_in : std_logic_vector(15 downto 0);
	signal exmem_data_in : std_logic_vector(15 downto 0);
	signal exmem_addr_in : std_logic_vector(15 downto 0);
	signal exmem_mem_en_in : std_logic;
	signal exmem_jump_cond_in : std_logic_vector(3 downto 0);

	signal exmem_jump_op_in : std_logic_vector(1 downto 0);
	signal exmem_flags_reg_we_in : std_logic;
	signal exmem_wb_addr_in : std_logic_vector(2 downto 0);
	signal exmem_wb_mux_in : std_logic_vector(1 downto 0);
	signal exmem_mux_c_in : std_logic;
	signal exmem_mux_const_in : std_logic;
	signal exmem_mux_lcx_in : std_logic;
	signal exmem_flag_status_out : std_logic;

	signal exmem_wb_addr_out : std_logic_vector(2 downto 0);
	signal exmem_wb_mux_out : std_logic_vector(1 downto 0);
	signal exmem_wb_we_out : std_logic;

	signal exmem_mem_out : std_logic_vector(15 downto 0);
	signal exmem_alu_out : std_logic_vector(15 downto 0);
	signal exmem_pc_out : std_logic_vector(15 downto 0);
	signal exmem_instr_out : std_logic_vector(4 downto 0);

	signal wb_mem_data_in : std_logic_vector(15 downto 0);
	signal wb_alu_data_in : std_logic_vector(15 downto 0);
	signal wb_src_sel_in : std_logic_vector(1 downto 0);
	signal wb_output : std_logic_vector(15 downto 0);
	
	-- Other non-reg signals:
	
	signal pc_en : std_logic;
	
	signal IF_e : std_logic;
	signal IDRF_e : std_logic;
	signal EXM_e : std_logic;
	signal WB_e : std_logic;

begin

	Inst_IFetch: IFetch PORT MAP(
		clk => clk,
		rst => rst,
		jaddr => exmem_alu_out,
		jsel => exmem_flag_status_out,
		pc_en => pc_en,
		addr => if_pc_out,
		irout => if_instr_out 
	);

	Inst_IDRF: IDRF PORT MAP(
		rst => rst,
		clk => clk,
		PC_in => idrf_pc_in,
		inst => idrf_instr_in,
		wb_data => idrf_wb_data_in,
		wb_addr => idrf_wb_addr_in,
		wb_we => idrf_wb_we_in,
		PC_out => idrf_pc_out,
		RA => idrf_a_out,
		RB => idrf_b_out,
		const => idrf_const_out,
		ALU_op => idrf_alu_op_out,
		inst_out => idrf_inst_out_aux,
		mux_a => idrf_mux_a_out,
		mux_b => idrf_mux_b_out
	);

	Inst_ExMem: ExMem PORT MAP(
		clk => clk,
		mem_en => exmem_mem_en_in,
		A => exmem_a_in,
		B => exmem_b_in,
		PC => exmem_pc_in,
		imm => exmem_const_in,
		jump_cond => exmem_jump_cond_in,
		jump_op => exmem_jump_op_in,
		flags_reg_we => exmem_flags_reg_we_in,
		wb_addr_in => exmem_wb_addr_in,
		wb_mux_in => exmem_wb_mux_in,
		wb_we_in => exmem_wb_we_in,
		mux_C => exmem_mux_c_in,
		mux_const => exmem_mux_const_in,
		mux_lcx => exmem_mux_lcx_in,
		mux_A => exmem_mux_a_in,
		mux_B => exmem_mux_b_in,
		ALU_op => exmem_alu_op_in,
		wb_addr_out => exmem_wb_addr_out,
		wb_mux_out => exmem_wb_mux_out,
		wb_we_out => exmem_wb_we_out,
		flag_status => exmem_flag_status_out,
		mem_out => exmem_mem_out,
		ALU_out => exmem_alu_out 
		PC_out => exmem_pc_out 
	);

	Inst_WB: WB PORT MAP(
		mem_data => wb_mem_data_in,
		alu_data => wb_alu_data_in,
		src_sel => wb_src_sel_in,
		output => wb_output
	);
	
	Inst_TGC: TGC PORT MAP(
		clk => clk,
		rst => rst,
		IF_e => IF_e,
		IDRF_e => IDRF_e,
		EXM_e => EXM_e,
		WB_e => WB_e
	);

	process(clk, IF_e, IDRF_e, EXM_e, WB_e)
	begin
		if rising_edge(clk) then
			
			if IF_e = '1' then
				idrf_pc_in <= if_pc_out; 
				idrf_instr_in <= if_instr_out;
			end if;
			if IDRF_e = '1' then
				exmem_pc_in <= idrf_pc_out;
				exmem_a_in <= idrf_a_out;
				exmem_b_in <= idrf_b_out;
				exmem_const_in <= idrf_const_out;
				exmem_jump_cond_in <= idrf_inst_out_aux(3 downto 0);
				exmem_jump_op_in <= idrf_inst_out_aux(5 downto 4);
				exmem_flags_reg_we_in <= idrf_inst_out_aux(6);
				exmem_wb_mux_in(0) <= idrf_inst_out_aux(7);	-- /!\ correct this (mux has two bits now)
				exmem_wb_we_in <= idrf_inst_out_aux(8);
				exmem_wb_addr_in <= idrf_inst_out_aux(11 downto 9);
				exmem_mux_c_in <= idrf_inst_out_aux(12);
				exmem_mux_const_in <= idrf_inst_out_aux(13);
				exmem_mux_lcx_in <= idrf_inst_out_aux(14);
				exmem_mem_en_in <= idrf_inst_out_aux(15);
				exmem_alu_op_in <= idrf_alu_op_out;
				exmem_mux_a_in <= idrf_mux_a_out;
				exmem_mux_b_in <= idrf_mux_b_out;
			end if;
			if EXM_e = '1' then
				wb_mem_data_in <= exmem_mem_out;
				wb_alu_data_in <= exmem_alu_out;
				wb_curr_pc_in <= exmem_pc_out;
				wb_src_sel_in <= exmem_wb_mux_in;
			end if;
			

		end if;
	end process;
	
	-- Write-back output does not go through registers:
	idrf_wb_data_in <= wb_output;
	idrf_wb_addr_in <= exmem_wb_addr_out;
	idrf_wb_we_in   <= WB_e and exmem_wb_we_out;
	
	-- Program Counter is updated in the EXM cycle
	-- (when the jump address is calculated)
	pc_en <= EXM_e;
	

	output <= wb_output;	-- for circuit to be syntesised
end Behavioral;
