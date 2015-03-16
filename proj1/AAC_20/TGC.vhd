----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:37:15 03/16/2015 
-- Design Name: 
-- Module Name:    TGC - Behavioral 
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

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity TGC is
	Port (
		clk : in  STD_LOGIC;
		rst : in  STD_LOGIC;
		IF_e : out  STD_LOGIC;
		IDRF_e : out  STD_LOGIC;
		EXM_e : out  STD_LOGIC;
		WB_e : out  STD_LOGIC
	);
end TGC;

architecture Behavioral of TGC is
	type state_type is (resetted, state_if,state_idrf,state_exm,state_wb); 
	signal state, next_state : state_type; 
begin
	
	
	SYNC_PROC: process (clk, rst)
	begin
		if (rst = '1') then
			state <= resetted;
		else
			if (clk'event and clk = '1') then
				state <= next_state;
			end if;
		end if;
	end process;
	
	OUTPUT_DECODE : process (state)
	begin
		case (state) is
			when state_if =>
				IF_e <= '1';
				IDRF_e <= '0';
				EXM_e <= '0';
				WB_e <= '0';
			when state_idrf =>
				IF_e <= '0';
				IDRF_e <= '1';
				EXM_e <= '0';
				WB_e <= '0';
			when state_exm =>
				IF_e <= '0';
				IDRF_e <= '0';
				EXM_e <= '1';
				WB_e <= '0';
			when state_wb =>
				IF_e <= '0';
				IDRF_e <= '0';
				EXM_e <= '0';
				WB_e <= '1';
			when others =>
				IF_e <= '0';
				IDRF_e <= '0';
				EXM_e <= '0';
				WB_e <= '0';
		end case;      
	end process;
	
	NEXT_STATE_DECODE: process (state)
	begin
		next_state <= state;
		case (state) is
			when state_if =>
				next_state <= state_idrf;
			when state_idrf =>
				next_state <= state_exm;
			when state_exm =>
				next_state <= state_wb;
			when others =>
				next_state <= state_if;
		end case;      
	end process;
	
end Behavioral;

