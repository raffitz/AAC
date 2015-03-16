----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:59:43 03/08/2015 
-- Design Name: 
-- Module Name:    OperF - Behavioral 
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

entity OperF is
	PORT(
		EXTSIGNAL: in std_logic_vector(15 downto 0);
		PCounter: in std_logic_vector(15 downto 0);
		RFA: in std_logic_vector(15 downto 0);
		RFB: in std_logic_vector(15 downto 0);
		selA: in std_logic;
		selB: in std_logic;
		operA: out std_logic_vector(15 downto 0);
		operB: out std_logic_vector(15 downto 0)
	);
	
end OperF;

architecture Behavioral of OperF is

begin
	with selA select operA <=
		RFA when '0',
		PCounter when others;
	with selB select operB <=
		RFB when '0',
		EXTSIGNAL when others;

end Behavioral;

