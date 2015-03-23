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

	signal bufferout : std_logic_vector(16 downto 0);
	signal A_ext : std_logic_vector(16 downto 0);
	signal B_ext : std_logic_vector(16 downto 0);

	signal operand2 : std_logic_vector(16 downto 0);

begin

	A_ext <= '0' & A1;
	B_ext <= '0' & B1;

	with sel(2 downto 0) select operand2 <=
	B_ext when "000",
	B_ext+1 when "001",
	'0' & X"0001" when "011",
	0-B_ext-1 when "100",
	0-B_ext when "101",
	'1' & X"FFFF" when others;


	flag_v <= '1' when (A_ext(15) = operand2(15)) and (bufferout(15) /= A_ext(15)) else '0';
	flag_z <= '1' when bufferout(15 downto 0) = X"0000" else '0';
	flag_c <= bufferout(16);
	flag_s <= bufferout(15);

	AOut <= bufferout(15 downto 0);

end Behavioral;

