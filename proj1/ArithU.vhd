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
		sel : in std_logic_vector(4 downto 0);		
		flag_s : OUT std_logic;	-- negative
		flag_c : OUT std_logic;
		flag_z : OUT std_logic;
		flag_v : OUT std_logic;
		AOut : OUT std_logic_vector(15 downto 0)
	);

end ArithU;

architecture Behavioral of ArithU is

	signal bufferout: std_logic_vector(16 downto 0);

begin

	with sel(2 downto 0) select bufferout <=
	A1+B1 when "000",
	A1+B1+1 when "001",
	A1+1 when "011",
	A1-B1-1 when "100",
	A1-B1 when "101",
	A1-1 when others;

	with sel(2) select flag_v <=	-- /!\ check this
	(((A1(15) nor B1(15)) and bufferout(15)) or ((A1(15) and B1(15)) and (not bufferout(15)) )) when '0',
	((((not A1(15)) and B1(15)) and bufferout(15)  ) or ( ((not B1(15)) and A1(15)) and (not bufferout(15)))  ) when others;

	flag_z <= '1' when bufferout(15 downto 0) = X"0000" else '0';
	flag_c <= bufferout(16);
	flag_s <= bufferout(15);

	AOut <= bufferout(15 downto 0);

end Behavioral;

