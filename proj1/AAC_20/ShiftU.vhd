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
		sel : IN std_logic_vector(4 downto 0);
		flag_s : OUT std_logic;	-- negative
		flag_c : OUT std_logic;
		flag_z : OUT std_logic;
		SOut : OUT std_logic_vector(15 downto 0)
	);

end ShiftU;

architecture Behavioral of ShiftU is

	signal aux1, aux2, buffersout : std_logic_vector(15 downto 0);

begin

	aux1 <= A2(14 downto 0) & '0';
	aux2 <= A2(15) & A2(15 downto 1);

	buffersout <= aux1 when sel(0) = '0' else aux2;

	flag_s <= buffersout(15); 
	flag_c <= A2(15) when sel(0) = '0' else A2(0); 
	flag_z <= '1' when buffersout = X"0000" else '0';

	SOut <= buffersout;

end Behavioral;

