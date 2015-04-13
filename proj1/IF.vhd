----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:24:13 03/02/2015 
-- Design Name: 
-- Module Name:    IF - Behavioral 
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

entity IFetch is
	Port (
		clk : in  STD_LOGIC;
		rst : in STD_LOGIC;
		jaddr : in STD_LOGIC_VECTOR(15 downto 0);
		jsel : in STD_LOGIC;
		pc_en : in STD_LOGIC;
		addr : out STD_LOGIC_VECTOR(15 downto 0);
		irout : out STD_LOGIC_VECTOR(15 downto 0)
	);
end IFetch;

architecture Behavioral of IFetch is

	COMPONENT IMem
		PORT(
			ADDR : IN std_logic_vector(15 downto 0);          
			DATA : OUT std_logic_vector(15 downto 0)
		);
	END COMPONENT;

	COMPONENT reg
	GENERIC(
		nbits : integer
	);
	PORT(
		en : IN std_logic;
		clk : IN std_logic;
		rst : IN std_logic;
		D : IN std_logic_vector(nbits-1 downto 0);          
		Q : OUT std_logic_vector(nbits-1 downto 0)
	);
	END COMPONENT;


	signal en : STD_LOGIC;
	signal pcout : STD_LOGIC_VECTOR(15 downto 0);
	signal pc_inc : STD_LOGIC_VECTOR(15 downto 0);
	signal pcin : STD_LOGIC_VECTOR(15 downto 0);
begin

	Inst_IMem: IMem PORT MAP(
		ADDR => pcout,
		DATA => irout
	);

	en <= pc_en;
	PC : reg
	generic map (
		nbits => 16
	)
	PORT MAP(
		en => en,
		clk => clk,
		rst => rst,
		D => pcin,
		Q => pcout
	);
	pc_inc <= pcout + 1;
	pcin <= pc_inc when jsel = '0' else jaddr;
	addr <= pc_inc;

end Behavioral;
