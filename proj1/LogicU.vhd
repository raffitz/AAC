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
		sel : IN std_logic_vector(4 downto 0);	
		flag_z : OUT std_logic;
		flag_s : OUT std_logic;	-- negative
		LOut : OUT std_logic_vector(15 downto 0)
	);

end LogicU;

architecture Behavioral of LogicU is

	signal notA, notB, bufferlout: std_logic_vector(15 downto 0);
	signal bufferflags: std_logic_vector(3 downto 0);
	signal flag1,flag2,flag3,flag0: std_logic;

begin

	notA <= not A3;
	notB <= not B3;

	with sel(3 downto 0) select bufferlout <=
	X"0000" when "0000",
	A3 and B3 when "0001",
	notA and B3 when "0010",		
	B3 when "0011",
	A3 and notB when "0100",
	A3 when "0101",
	A3 xor B3 when "0110",
	A3 or B3 when "0111",
	A3 nor B3 when "1000",
	A3 xnor B3 when "1001",
	notA when "1010",
	notA or B3 when "1011",
	notB when "1100",
	A3 or notB when "1101",
	A3 nand B3 when "1110",
	X"0001" when "1111";

	flag_z <= '1' when bufferlout = X"0000" else '0';
	flag_s <= bufferlout(15);

	LOut <= bufferlout;

end Behavioral;

