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
		flagsin : in STD_LOGIC_VECTOR(3 downto 0);	-- S, C, Z, V
		flagsout : out STD_LOGIC_VECTOR(3 downto 0);	-- S, C, Z, V
		C : out STD_LOGIC_VECTOR(15 downto 0)
	);
end ALU;

architecture Behavioral of ALU is

	COMPONENT ArithU
		PORT(
			A1 : IN std_logic_vector(15 downto 0);
			B1 : IN std_logic_vector(15 downto 0);
			sel : IN std_logic_vector(4 downto 0);          
			flag_s : OUT std_logic;
			flag_c : OUT std_logic;
			flag_z : OUT std_logic;
			flag_v : OUT std_logic;
			AOut : OUT std_logic_vector(15 downto 0)
		);
	END COMPONENT;

	COMPONENT ShiftU
		PORT(
			A2 : IN std_logic_vector(15 downto 0);
			sel : IN std_logic_vector(4 downto 0);          
			flag_s : OUT std_logic;
			flag_c : OUT std_logic;
			flag_z : OUT std_logic;
			SOut : OUT std_logic_vector(15 downto 0)
		);
	END COMPONENT;

	COMPONENT LogicU
		PORT(
			A3 : IN std_logic_vector(15 downto 0);
			B3 : IN std_logic_vector(15 downto 0);
			sel : IN std_logic_vector(4 downto 0);          
			flag_z : OUT std_logic;
			flag_s : OUT std_logic;
			LOut : OUT std_logic_vector(15 downto 0)
		);
	END COMPONENT;

	signal arithOut: STD_LOGIC_VECTOR(15 downto 0);
	signal shiftOut: STD_LOGIC_VECTOR(15 downto 0);
	signal logicOut: STD_LOGIC_VECTOR(15 downto 0);
	signal flagsarith: STD_LOGIC_VECTOR(3 downto 0);
	signal flagsshift: STD_LOGIC_VECTOR(3 downto 0);
	signal flagslogic: STD_LOGIC_VECTOR(3 downto 0);
	signal flagslogicout : STD_LOGIC_VECTOR(3 downto 0);

begin
	
	Inst_ArithU: ArithU  
	PORT MAP(
		A1 => A,
		B1 => B,
		sel => sel,
		flag_s => flagsarith(3),
		flag_c => flagsarith(2),
		flag_z => flagsarith(1),
		flag_v => flagsarith(0),
		AOut => arithOut 
	);
	
	Inst_ShiftU: ShiftU PORT MAP(
		A2 => A,
		sel => sel,
		flag_s => flagsshift(3),
		flag_c => flagsshift(2),
		flag_z => flagsshift(1),
		SOut => shiftOut 
	);
	
	Inst_LogicU: LogicU PORT MAP(
		A3 => A,
		B3 => B,
		sel => sel,
		flag_s => flagslogic(3),
		flag_z => flagslogic(1),
		LOut => logicOut 
	);
	
	flagsshift(0) <= flagsin(0);
	flagslogic(0) <= flagsin(0);
	flagslogic(2) <= flagsin(2);
	flagslogicout(0) <= flagslogic(0);
	flagslogicout(2) <= flagslogic(2);
	with sel(3 downto 0) select flagslogicout(1) <=
		flagsin(1) when "0000",
		flagsin(1) when "0011",
		flagsin(1) when "1111",
		flagslogic(1) when others;
	
	with sel(3 downto 0) select flagslogicout(3) <=
		flagsin(3) when "0000",
		flagsin(3) when "0011",
		flagsin(3) when "1111",
		flagslogic(3) when others;
	
	with sel(4 downto 3) select flagsout <=
		flagsarith when "00",
		flagsshift when "01",
		flagslogicout when others;
		
	with sel(4 downto 3) select C <=
		arithOut when "00",
		shiftOut when "01",
		logicOut when others;
		
end Behavioral;

