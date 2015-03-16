----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:36:20 03/12/2015 
-- Design Name: 
-- Module Name:    SExt - Behavioral 
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


-- Os bits de selecção são os bits 15 downto 13 da instrução.

entity SExt is
	Port (
		const8 : in  STD_LOGIC_VECTOR (7 downto 0);
		const11 : in  STD_LOGIC_VECTOR (10 downto 0);
		const12 : in  STD_LOGIC_VECTOR (11 downto 0);
		inselect : in  STD_LOGIC_VECTOR (2 downto 0);
		extended : out  STD_LOGIC_VECTOR (15 downto 0)
	);
end SExt;

architecture Behavioral of SExt is

begin
	extended <= "11111" & const11 when
			(const11(10) = '1' and inselect(2 downto 1) = "01") else
		"00000" & const11 when
			(const11(10) = '0' and inselect(2 downto 1) = "01") else
		"1111" & const12 when
			(const12(11) = '1' and inselect = "001") else
		"0000" & const12 when
			(const12(11) = '0' and inselect = "001") else
		X"FF" & const8 when
			const8(7) = '1' else
		X"00" & const8;
		
end Behavioral;

