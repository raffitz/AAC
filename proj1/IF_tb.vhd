--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   00:03:37 03/11/2015
-- Design Name:   
-- Module Name:   D:/Dropbox/Public/IST/AAC/labs/proj1/proj/IF_tb.vhd
-- Project Name:  proj
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: IFetch
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;

ENTITY IF_tb IS
	END IF_tb;

ARCHITECTURE behavior OF IF_tb IS 

	-- Component Declaration for the Unit Under Test (UUT)

	COMPONENT IFetch
		PORT(
			clk : IN  std_logic;
			jaddr : IN  std_logic_vector(15 downto 0);
			jsel : IN  std_logic;
			pc_en : IN  std_logic;
			pc_rst : IN  std_logic;
			addr_sel : IN  std_logic;
			addr : OUT  std_logic_vector(15 downto 0);
			irout : OUT  std_logic_vector(15 downto 0)
		);
	END COMPONENT;


	--Inputs
	signal clk : std_logic := '0';
	signal jaddr : std_logic_vector(15 downto 0) := (others => '0');
	signal jsel : std_logic := '0';
	signal pc_en : std_logic := '0';
	signal pc_rst : std_logic := '0';
	signal addr_sel : std_logic := '0';

	--Outputs
	signal addr : std_logic_vector(15 downto 0);
	signal irout : std_logic_vector(15 downto 0);

	-- Clock period definitions
	constant clk_period : time := 10 ns;

BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut: IFetch PORT MAP (
		clk => clk,
		jaddr => jaddr,
		jsel => jsel,
		pc_en => pc_en,
		pc_rst => pc_rst,
		addr_sel => addr_sel,
		addr => addr,
		irout => irout
	);

	-- Clock process definitions
	clk_process :process
	begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
	end process;


	-- Stimulus process
	stim_proc: process
	begin		
		-- hold reset state for 100 ns.
		wait for 100 ns;	

		wait for clk_period*10;

		-- insert stimulus here 

		pc_rst <= '1',
			'0' after clk_period;

		pc_en <= '1';

		jaddr <= X"abcd";

		jsel <= '0',
			'1' after 10*clk_period,
			'0' after 15*clk_period;

		addr_sel <= '0',
			'1' after 20*clk_period;

		wait;
	end process;

END;
