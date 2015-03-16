----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:24:00 03/08/2015 
-- Design Name: 
-- Module Name:    RF - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RF is
	Port (
		Aaddr: in STD_LOGIC_VECTOR(2 downto 0);
		Baddr : in STD_LOGIC_VECTOR(2 downto 0);
		A: out  STD_LOGIC_VECTOR(15 downto 0);
		B: out  STD_LOGIC_VECTOR(15 downto 0);
		Daddr: in STD_LOGIC_VECTOR(2 downto 0);
		DATA: in STD_LOGIC_VECTOR(15 downto 0);
		WE: in STD_LOGIC;
		clk: in STD_LOGIC;
		rst: in STD_LOGIC
	);

end RF;

architecture Behavioral of RF is

	type registersFile is array(0 to 7) of std_logic_vector(15 downto 0);
	signal registers: registersFile;

begin
	
	A <= registers(conv_integer(Aaddr));
	B <= registers(conv_integer(Baddr));

	
	process(clk, rst, WE)
	begin
		if (rst = '1') then
			registers <= (others => (others => '0'));
		else
			if (rising_edge(clk) and WE='1') then
				registers(conv_integer(Daddr)) <= DATA;
			end if;
		end if;
	end process;

end Behavioral;

