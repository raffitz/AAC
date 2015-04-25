-- synchronous write, assynchronous read RAM

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use std.textio.all;	-- for file operations

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
	type RamType is array(0 to 2**14 - 1) of std_logic_vector(15 downto 0);
	-- signal RAM : RamType;

	-- init ram with contents from a file
	impure function InitramFromFile (ramFileName : in string) return ramType is
		FILE ramFile : text is in ramFileName;
		variable ramFileLine : line;
		variable ram : ramType;
		variable good : boolean;
		variable temp_bv : bit_vector(15 downto 0);
	begin
		for i in ramType'range loop
			readline (ramFile, ramFileLine);
			read (ramFileLine, temp_bv, good);
			ram(i) := to_stdlogicvector(temp_bv);
		end loop;
		return ram;
	end function; 

	signal ram : ramType := InitramFromFile("imem.txt");

--	signal ram : ramType := (others => (others => '0'));

begin
	process (clk)
	begin
		if (clk'event and clk = '1') then
			if (we = '1') then
				RAM(conv_integer(addr(13 downto 0))) <= data_in;
			end if;
		end if;
	end process;

	data_out <= RAM(conv_integer(addr(13 downto 0)));

end behavioural;
