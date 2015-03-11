----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:01:15 03/11/2015 
-- Design Name: 
-- Module Name:    FT - Behavioral 
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

entity FT is
	Port (
		flags: in std_logic_vector(3 downto 0);
		enable_flags: in std_logic_vector(3 downto 0);
		cond: in std_logic_vector(3 downto 0);
		op: in std_logic_vector(1 downto 0);
		s: out std_logic
	);

end FT;

architecture Behavioral of FT is

	signal regcarry, regzero, regsign, regoverflow: std_logic;
	signal jtrue, jfalse, buffers: std_logic;

begin

	with cond select jtrue <=
		regsign when "100",
		regzero when "101",
		regcarry when "110",
		(regzero or regsign) when "111",
		1 when "000",
		regoverflow when others;
		
	with cond select jfalse <=
		not regsign when "100",
		not regzero when "101",
		not regcarry when "110",
		not (regzero or regsign) when "111",
		1 when "000",
		not regoverflow when others;
	
		
	with op select buffers <=
		jtrue when '0',
		jfalse when others;

	s <= buffers;

	process(clk)
	begin
		if rising_edge(clk) then 
			if enable(3)='1' then
				regsign <= flags(3);
			end if;
			if enable(2)='1' then
				regcarry <= flags(2);
			end if;
			if enable(1)='1' then
				regzero <= flags(1);
			end if;
			if enable(0)='1' then
				regoverflow <= flags(0);
			end if;
		end if;
	end process;

end Behavioral;

