----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:04:28 04/26/2015 
-- Design Name: 
-- Module Name:    btb - Behavioral 
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
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity btb is
	Port(
		address : in  STD_LOGIC_VECTOR (15 downto 0);
		crush : in  STD_LOGIC;
		override_addr : in  STD_LOGIC_VECTOR (15 downto 0);
		clk : in  STD_LOGIC;
		rst : in  STD_LOGIC;
		hit : out  STD_LOGIC;
		oaddress : out  STD_LOGIC_VECTOR (15 downto 0)
	);
end btb;

architecture Behavioral of btb is
	type BTBtype is array (0 to 255) of std_logic_vector (24 downto 0);
	
	signal cache : BTBtype := (others=> (others=> '0'));
	signal prev_addr : std_logic_vector(15 downto 0);
	signal curline : std_logic_vector(24 downto 0);
begin
	
	process (clk,rst,crush)
	begin
		if (rst='1') then
			cache <= (others=> (others=> '0'));
		end if;
		if (clk'event and clk = '1') then
			if(crush='1') then
				cache(conv_integer(prev_addr(7 downto 0))) <= prev_addr(15 downto 8) & '1' & override_addr;
			end if;
			prev_addr <= address;
		end if;
	end process;
	
	curline <= cache(conv_integer(address(7 downto 0)));
	
	hit <= '1' when curline(24 downto 17) = address(15 downto 8) and curline(16) = '1' else '0';
	
	oaddress <= curline(15 downto 0);

end Behavioral;

