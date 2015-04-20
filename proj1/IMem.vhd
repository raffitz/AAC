-- program memory ROM
-- the program instructions are read from a file "imem.txt". This file must have one line per word of the ROM. Each instruction is represented as a string of 0s and 1s

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use std.textio.all;	-- for file operations

entity imem is
	port (
		ADDR : in std_logic_vector(15 downto 0);
		DATA : out std_logic_vector(15 downto 0));
end imem;

architecture Behavioural of IMem is
	type RomType is array (0 to 2**14 - 1) of std_logic_vector (15 downto 0);                 
	--signal ROM : RomType := (others => (others => '0'));

	-- init ROM with contents from a file
	impure function InitromFromFile (romFileName : in string) return romType is
		FILE romFile : text is in romFileName;
		variable romFileLine : line;
		variable rom : romType;
		variable good : boolean;
		variable temp_bv : bit_vector(15 downto 0);
	begin
		for i in romType'range loop
			readline (romFile, romFileLine);
			read (romFileLine, temp_bv, good);
			rom(i) := to_stdlogicvector(temp_bv);
		end loop;
		return rom;
	end function; 

--	signal ROM : RomType := InitRomFromFile("imem.txt");
	signal ROM : RomType := ("0110000000011101",
		"0101100000001111",
		"1001000000011100",
		"1001000000010100",
		"0000000000000000",
		"0000000000000000",
		"0000000000000000",
		"1001000000010100",
		"0010111111111111",
		others => (others => '0'));

begin

	DATA <= ROM(conv_integer(ADDR(13 downto 0)));
	
end Behavioural;
