--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:41:28 03/21/2015
-- Design Name:   
-- Module Name:   D:/Dropbox/Public/IST/AAC/labs/proj1/proj1/imem_tb.vhd
-- Project Name:  proj1
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: imem
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
 
ENTITY imem_tb IS
END imem_tb;
 
ARCHITECTURE behavior OF imem_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT imem
    PORT(
         ADDR : IN  std_logic_vector(15 downto 0);
         DATA : OUT  std_logic_vector(15 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal ADDR : std_logic_vector(15 downto 0) := (others => '0');

 	--Outputs
   signal DATA : std_logic_vector(15 downto 0);
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: imem PORT MAP (
          ADDR => ADDR,
          DATA => DATA
        );

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      -- insert stimulus here 

	  ADDR <= X"0000",
		  X"0001" after 10 ns,
		  X"0002" after 20 ns,
		  X"0064" after 30 ns,	-- 100
		  X"03E8" after 40 ns;	-- 1000

      wait;
   end process;

END;
