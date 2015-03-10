----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:11:08 03/04/2015 
-- Design Name: 
-- Module Name:    ALU - Behavioral 
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


entity ALU is
	Port (
		A : in  STD_LOGIC_VECTOR(15 downto 0);
		B : in STD_LOGIC_VECTOR(15 downto 0);
		sel : in STD_LOGIC_VECTOR(4 downto 0);
		flagsout : out STD_LOGIC_VECTOR(3 downto 0);
		C : out STD_LOGIC_VECTOR(15 downto 0)
	);
end ALU;

architecture Behavioral of ALU is

	COMPONENT ArithU is
		PORT(
			A1 : IN std_logic_vector(15 downto 0);
			B1 : IN std_logic_vector(15 downto 0);
			sel : in STD_LOGIC_VECTOR(4 downto 0);
			flags1 : out std_logic_vector(3 downto 0);
			AOut : OUT std_logic_vector(15 downto 0)
		);
	END COMPONENT;

	COMPONENT ShiftU is
		
		PORT(
			A2 : IN std_logic_vector(15 downto 0);
			B2 : IN std_logic_vector(15 downto 0);  
			sel : in STD_LOGIC_VECTOR(4 downto 0);	
			flags2 : out std_logic_vector(3 downto 0);			
			SOut : OUT std_logic_vector(15 downto 0)
		);
	END COMPONENT;


	COMPONENT LogicU is
		
		PORT(
			A3 : IN std_logic_vector(15 downto 0);
			B3 : IN std_logic_vector(15 downto 0); 
			sel : in STD_LOGIC_VECTOR(4 downto 0);	
			flags3 : out std_logic_vector(3 downto 0);
			LOut : OUT std_logic_vector(15 downto 0)
		);
	END COMPONENT;


	signal arithOut: STD_LOGIC_VECTOR(15 downto 0);
	signal shiftOut: STD_LOGIC_VECTOR(15 downto 0);
	signal logicOut: STD_LOGIC_VECTOR(15 downto 0);
	signal flagsarith: STD_LOGIC_VECTOR(3 downto 0);
	signal flagsshift: STD_LOGIC_VECTOR(3 downto 0);
	signal flagslogic: STD_LOGIC_VECTOR(3 downto 0);

	
begin

	
	ArithU: ArithU  
	PORT MAP(
		A1 => A,
		B1 => B,
		sel => sel,
		flags1 => flagsarith,
		AOut => arithOut 
	);
	
	ShiftU: ShiftU PORT MAP(
		A2 => A,
		B2 => B,
		sel => sel,
		flags2 => flagsshift,
		SOut => shiftOut 
	);
	
	LogicU: LogicU PORT MAP(
		A3 => A,
		B3 => B,
		sel => sel,
		flags3 => flagslogic,
		LOut => logicOut 
	);
	

	with sel(4 downto 3) select flagsout <=
		flagsarith when "00",
		flagsshift when "01",
		flagslogic when others;
		
	with sel(4 downto 3) select C <=
		arithOut when "00",
		shiftOut when "01",
		logicOut when others;
		


end Behavioral;



