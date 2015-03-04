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
			flags : in STD_LOGIC_VECTOR(3 downto 0);			
			flags1 : out std_logic_vector(3 downto 0);
			AOut : OUT std_logic_vector(15 downto 0)
		);

end ArithU;
	
architecture Behavioral of ArithU is

	signal aux1,aux2,aux3,aux4,aux5,aux6, bufferaout: std_logic_vector(15 downto 0);
	signal bufferflags: std_logic_vector(3 downto 0);
	signal flag1,flag2,flag3,flag0: std_logic;


begin

	aux1 <= A1+B1;
	aux2 <= A1+B1+1;
	aux3 <= A1+1;
	aux4 <= A1-B1-1;
	aux5 <= A1-B1;
	aux6 <= A1-1;


	with sel(2 downto 0) select bufferaout <=
		aux1 when "000",
		aux2 when "001",
		aux3 when "011",		
		aux4 when "100",
		aux5 when "101",
		aux6 when "110";
	
	flag1 <= not( bufferaout(15) or bufferaout(14) or bufferaout(13) or bufferaout(12) or bufferaout(11) or bufferaout(10) or bufferaout(9) or bufferaout(8) or bufferaout(7) or bufferaout(6) or bufferaout(5) or bufferaout(4) or bufferaout(3) or bufferaout(2) or bufferaout(1) or bufferaout(0) );
	flag3 <= bufferaout(15);



	--faltam flags carry e overflow......................................................................................
	
	
	bufferflags <= flag3 & flag2 & flag1 & flag0;

	AOut <= bufferaout;
	flags1 <= bufferflags;

end Behavioral;

