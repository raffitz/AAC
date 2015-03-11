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
		pc_en : in  STD_LOGIC;
		pc_rst : in  STD_LOGIC;
		regfile_rst : in  STD_LOGIC;
		flag : out  STD_LOGIC
	);
end circuit;

architecture Behavioral of circuit is

	COMPONENT IFetch
		PORT(
			clk : IN std_logic;
			jaddr : IN std_logic_vector(15 downto 0);
			jsel : IN std_logic;
			pc_en : IN std_logic;
			pc_rst : IN std_logic;
			addr_sel : IN std_logic;          
			addr : OUT std_logic_vector(15 downto 0);
			irout : OUT std_logic_vector(15 downto 0)
		);
	END COMPONENT;

	COMPONENT WB
		PORT(
			mem_data : IN std_logic_vector(15 downto 0);
			alu_data : IN std_logic_vector(15 downto 0);
			src_sel : IN std_logic;
			wb_addr_in : IN std_logic_vector(2 downto 0);          
			wb_addr_out : OUT std_logic_vector(2 downto 0);
			output : OUT std_logic_vector(15 downto 0)
		);
	END COMPONENT;

begin

	Inst_IFetch: IFetch PORT MAP(
		clk => ,
		jaddr => ,
		jsel => ,
		pc_en => ,
		pc_rst => ,
		addr_sel => ,
		addr => ,
		irout => 
		);

	Inst_WB: WB PORT MAP(
		mem_data => ,
		alu_data => ,
		src_sel => ,
		wb_addr_in => ,
		wb_addr_out => ,
		output => 
		);

end Behavioral;
