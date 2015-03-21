-- synchronous write, assynchronous read RAM

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity RAM is
	port
	(
		clk: in std_logic;
		data_in: in std_logic_vector (15 downto 0);
		addr : in std_logic_vector (15 downto 0);
		we: in std_logic;
		data_out : out std_logic_vector (15 downto 0)
	);
end RAM;

architecture behavioural of RAM is
	type mem is array(0 downto 2**14 - 1) of std_logic_vector(15 downto 0);
	signal ram_block : mem;

begin
	process (clk)
	begin
		if (clk'event and clk = '1') then
			if (we = '1') then
				ram_block(conv_integer(addr(13 downto 0))) <= data_in;
			end if;
		end if;
	end process;

	data_out <= ram_block(conv_integer(addr(13 downto 0)));

end behavioural;
