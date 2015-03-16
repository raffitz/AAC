library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity reg is
	generic ( nbits : integer := 16 );		-- default value of 16 bits
	Port (
		en : in  STD_LOGIC;
		clk : in  STD_LOGIC;
		rst : in  STD_LOGIC;
		D : in  STD_LOGIC_VECTOR (nbits-1 downto 0);
		Q : out  STD_LOGIC_VECTOR (nbits-1 downto 0));
end reg;

architecture Behavioral of reg is
begin
	process(clk, rst, en)
	begin
		if(rst = '1') then
			Q <= (others => '0');
		elsif(clk'event and clk = '1' and en = '1') then
			Q <= D;
		end if;
	end process;
end Behavioral;
