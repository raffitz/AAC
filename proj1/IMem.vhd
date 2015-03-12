-- program memory ROM

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity imem is
	port (
		CLK : in std_logic;
		ADDR : in std_logic_vector(15 downto 0);
		DATA : out std_logic_vector(15 downto 0));
end imem;

architecture Behavioural of IMem is
	type rom_type is array (2**14 - 1 downto 0) of std_logic_vector (15 downto 0);                 
	signal ROM : rom_type := (others => (others => '0'));

begin

	DATA <= ROM(conv_integer(ADDR(13 downto 0)));

end Behavioural;
