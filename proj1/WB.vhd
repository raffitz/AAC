----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:38:29 03/11/2015 
-- Design Name: 
-- Module Name:    WB - Behavioral 
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

entity WB is
	Port (
		mem_data : in  STD_LOGIC_VECTOR (15 downto 0);
		alu_data : in  STD_LOGIC_VECTOR (15 downto 0);
		curr_PC : in  STD_LOGIC_VECTOR (15 downto 0);
		src_sel : in  STD_LOGIC_VECTOR (1 downto 0);
		reg_addr : in STD_LOGIC_VECTOR (2 downto 0);
		reg_we : in STD_LOGIC;
		output : out  STD_LOGIC_VECTOR (15 downto 0);
		o_addr : out STD_LOGIC_VECTOR (2 downto 0);
		o_we : out STD_LOGIC
	);
end WB;

architecture Behavioral of WB is

begin
	o_addr <= reg_addr;
	
	o_we <= reg_we;
	
	output <= mem_data when src_sel = "01" else
			  alu_data when src_sel = "00" else
			  curr_PC;

end Behavioral;

