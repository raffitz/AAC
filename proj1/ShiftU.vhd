----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:38:58 03/04/2015 
-- Design Name: 
-- Module Name:    ShiftU - Behavioral 
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

entity ShiftU is
	PORT(
			A2 : IN std_logic_vector(15 downto 0);
			B2 : IN std_logic_vector(15 downto 0);  
			sel : in STD_LOGIC_VECTOR(5 downto 0);
			flags2 : out std_logic_vector(3 downto 0);			
			SOut : OUT std_logic_vector(15 downto 0)
		);

end ShiftU;

architecture Behavioral of ShiftU is

	signal aux1,aux2, buffersout:std_logic_vector(15 downto 0);
	signal flag1,flag2,flag3,flag0: std_logic;
	
begin

	aux1 <= A2(14 downto 0) & '0';
	aux2 <= A2(15) & A2(15 downto 1);

	
	with sel(0) select buffersout <=
		aux1 when '0',
		aux2 when '1';

	with buffersout(15) select flag3 <=
		'0' when '0',
		'1' when others;
	with sel(0) select flag2 <=	
		A2(15) when '0',
		A2(0) when others;
	with buffersout(15) or buffersout(14) or buffersout(13) or buffersout(12) or buffersout(11) or buffersout(10) or buffersout(9) or buffersout(8) or buffersout(7) or buffersout(6) or buffersout(5) or buffersout(4) or buffersout(3) or buffersout(2) or buffersout(1) or buffersout(0) select flag1 <=
		'0' when '1',
		'1' when others;

	SOut <= buffersout;
	flags2 <= flag3 & flag2 & flag1 & 0;
	

end Behavioral;

