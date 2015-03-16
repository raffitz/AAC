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
		PC_out : out  STD_LOGIC_VECTOR (15 downto 0);
		RA : out  STD_LOGIC_VECTOR (15 downto 0);
		RB : out  STD_LOGIC_VECTOR (15 downto 0);
		const : out  STD_LOGIC_VECTOR (15 downto 0);
		ALU_op : OUT std_logic_vector(4 downto 0);
		inst_out : OUT std_logic_vector(15 downto 0);
		mux_a : OUT std_logic;
		mux_b : OUT std_logic
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


begin
	
	PC_out <= PC_in;
	
	Inst_RF: RF PORT MAP(
		Aaddr => inst(5 downto 3),
		Baddr => inst(2 downto 0),
		A => RA,
		B => RB,
		Daddr => wb_addr,
		DATA => wb_data,
		WE => wb_we,
		clk => clk
	);
	
	Inst_SExt: SExt PORT MAP(
		const8 => inst(7 downto 0),
		const11 => inst(10 downto 0),
		const12 => inst(11 downto 0),
		inselect => inst(15 downto 13),
		extended => const
	);
	
	

	ALU_op <= inst(10 downto 6);
	mux_a <= '1' when inst(15 downto 14) = "00" else	-- control transfer
		'0'; -- Possibly overly simplistic
	
	mux_b <= '0' when inst(15 downto 12) = "0011" else	-- JAL and JR
		'0' when inst(15 downto 14) = "10" else	-- ALU ops
		'1';
	
	inst_out(3 downto 0) <= inst(11 downto 8); -- jump cond
	inst_out(5 downto 4) <= inst(13 downto 12); -- jump op
	inst_out(6) <= '0' when inst(15 downto 14) = "10" and inst(10 downto 7) = "0101" else
		'0'  when inst(15 downto 14) = "00" else '1'; -- Flag WE
	
	inst_out(11 downto 9) <= inst(13 downto 11);	-- WC addr
	-- WC we
	inst_out(8) <= '0' when inst(15 downto 14) = "00" else	-- control transfer
		'0' when inst(15 downto 14) = "10"and inst(10 downto 6)="01011" else	-- store in Mem
		'1';
	-- WB mux control
	inst_out(7) <= '1' when inst(15 downto 14) = "10"and inst(10 downto 6)="01010" else	-- load from Mem
		'0'; -- 1 means Memory, 0 means ALU
	
	inst_out(12) <= inst(14); -- Whether output is immediate or ALU
	-- Possi
	inst_out(13) <= inst(15); -- Complete constant load or high/low part;
	-- Possibly overly simplistic
	inst_out(14) <= inst(10); -- Low or High lc
	
	inst_out(15) <= '1' when inst(15 downto 14) = "10"and inst(10 downto 6)="01011" else
		'0'; --mem_en

end Behavioral;

