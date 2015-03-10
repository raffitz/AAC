----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:12:48 03/04/2015 
-- Design Name: 
-- Module Name:    LogicU - Behavioral 
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

entity LogicU is
	PORT(
			A3 : IN std_logic_vector(15 downto 0);
			B3 : IN std_logic_vector(15 downto 0); 
			sel : in STD_LOGIC_VECTOR(5 downto 0);	
			flags3 : out std_logic_vector(3 downto 0);
			LOut : OUT std_logic_vector(15 downto 0)
		);

end LogicU;

architecture Behavioral of LogicU is


	signal notA, notB: std_logic_vector(15 downto 0);
	signal aux1,aux2,aux3,aux4,aux5,aux6,aux7,aux8,aux9,aux10, bufferlout: std_logic_vector(15 downto 0);
	signal bufferflags: std_logic_vector(3 downto 0);
	signal flag1,flag2,flag3,flag0: std_logic;

begin
	
	flags3 <= flags;
	
	notA <= not A3;
	notB <= not B3;
	
	aux1 <= A3 and B3;
	aux2 <= notA and B3;
	aux3 <= A3 and notB;
	aux4 <= A3 xor B3;
	aux5 <= A3 or B3;
	aux6 <= A3 nor B3;
	aux7 <= A3 xnor B3;
	aux8 <= notA or B3;
	aux9 <= A3 or notB;
	aux10 <= A3 nand B3;
	
	
	with sel(3 downto 0) select bufferlout <=
		X"0000" when "0000",
		aux2 when "0001",
		aux3 when "0010",		
		B3 when "0011",
		aux3 when "0100",
		A3 when "0101",
		aux4 when "0110",
		aux5 when "0111",
		aux6 when "1000",
		aux7 when "1001",
		notA when "1010",
		aux8 when "1011",
		notB when "1100",
		aux9 when "1101",
		aux10 when "1110",
		X"FFFF" when "1111";
	
	flag1 <= not( bufferlout(15) or bufferlout(14) or bufferlout(13) or bufferlout(12) or bufferlout(11) or bufferlout(10) or bufferlout(9) or bufferlout(8) or bufferlout(7) or bufferlout(6) or bufferlout(5) or bufferlout(4) or bufferlout(3) or bufferlout(2) or bufferlout(1) or bufferlout(0) );
	flag3 <= bufferlout(15);
	
	with sel(3 downto 0) select bufferflags <=
		0 when "0000",
		0 when "1111",	
		0 when "0011",
		flags3 & 0 & flags1 & 0 when others;
	
		
	
	LOut <= bufferlout;
	flags3 <= bufferflags;

end Behavioral;

