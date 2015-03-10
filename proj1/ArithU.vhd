----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:32:26 03/04/2015 
-- Design Name: 
-- Module Name:    ArithU - Behavioral 
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
use IEEE.STD_LOGIC_SIGNED.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ArithU is
	PORT(
			A1 : IN std_logic_vector(15 downto 0);
			B1 : IN std_logic_vector(15 downto 0);
			sel : in STD_LOGIC_VECTOR(5 downto 0);		
			flags1 : out std_logic_vector(3 downto 0);
			AOut : OUT std_logic_vector(15 downto 0)
		);

end ArithU;
	
architecture Behavioral of ArithU is

	signal auxA1, auxB1: std_logic_vector(16 downto 0);
	signal aux1,aux2,aux3,aux4,aux5,aux6, bufferout: std_logic_vector(16 downto 0);
	signal bufferflags: std_logic_vector(3 downto 0);
	signal flag1,flag2,flag3,flag0: std_logic;


begin



	aux1 <= A1+B1;
	aux2 <= A1+B1+1;
	aux3 <= A1+1;
	aux4 <= A1-B1-1;
	aux5 <= A1-B1;
	aux6 <= A1-1;


	with sel(2 downto 0) select bufferout <=
		aux1 when "000",
		aux2 when "001",
		aux3 when "011",		
		aux4 when "100",
		aux5 when "101",
		aux6 when "110";
	
	with sel(2) select flag0 <=
		(((A1(15) nor B1(15)) and bufferout(15)) or ((A1(15) and B1(15)) and (not bufferout(15)) )) when '0',
		((((not A1(15)) and B1(15)) and bufferout(15)  ) or ( ((not B1(15)) and A1(15)) and (not bufferout(15)))  ) when others;
	flag1 <= not( bufferout(15) or bufferout(14) or bufferout(13) or bufferout(12) or bufferout(11) or bufferout(10) or bufferout(9) or bufferout(8) or bufferout(7) or bufferout(6) or bufferout(5) or bufferout(4) or bufferout(3) or bufferout(2) or bufferout(1) or bufferout(0) );
	flag2 <= bufferout(16);
	flag3 <= bufferout(15);
	
	
	bufferflags <= flag3 & flag2 & flag1 & flag0;

	AOut <= bufferout;
	flags1 <= bufferflags;

end Behavioral;

