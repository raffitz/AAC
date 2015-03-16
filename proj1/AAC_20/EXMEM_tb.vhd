--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   22:25:35 03/15/2015
-- Design Name:   
-- Module Name:   C:/Users/miguel/Desktop/AAC/1/lab1/EXMEM_tb.vhd
-- Project Name:  lab1
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: ExMem
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
 
ENTITY EXMEM_tb IS
END EXMEM_tb;
 
ARCHITECTURE behavior OF EXMEM_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ExMem
    PORT(
         clk : IN  std_logic;
         mem_en : IN  std_logic;
         A : IN  std_logic_vector(15 downto 0);
         B : IN  std_logic_vector(15 downto 0);
         PC : IN  std_logic_vector(15 downto 0);
         imm : IN  std_logic_vector(15 downto 0);
         instr_in : IN  std_logic_vector(14 downto 0);
         instr_out : OUT  std_logic_vector(4 downto 0);
         mux_A : IN  std_logic;
         mux_B : IN  std_logic;
         ALU_op : IN  std_logic_vector(4 downto 0);
         flag_status : OUT  std_logic;
         mem_out : OUT  std_logic_vector(15 downto 0);
         ALU_out : OUT  std_logic_vector(15 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal mem_en : std_logic := '0';
   signal A : std_logic_vector(15 downto 0) := (others => '0');
   signal B : std_logic_vector(15 downto 0) := (others => '0');
   signal PC : std_logic_vector(15 downto 0) := (others => '0');
   signal imm : std_logic_vector(15 downto 0) := (others => '0');
   signal instr_in : std_logic_vector(14 downto 0) := (others => '0');
   signal mux_A : std_logic := '0';
   signal mux_B : std_logic := '0';
   signal ALU_op : std_logic_vector(4 downto 0) := (others => '0');

 	--Outputs
   signal instr_out : std_logic_vector(4 downto 0);
   signal flag_status : std_logic;
   signal mem_out : std_logic_vector(15 downto 0);
   signal ALU_out : std_logic_vector(15 downto 0);

   -- Clock period definitions
   constant clk_period : time := 30 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ExMem PORT MAP (
          clk => clk,
          mem_en => mem_en,
          A => A,
          B => B,
          PC => PC,
          imm => imm,
          instr_in => instr_in,
          instr_out => instr_out,
          mux_A => mux_A,
          mux_B => mux_B,
          ALU_op => ALU_op,
          flag_status => flag_status,
          mem_out => mem_out,
          ALU_out => ALU_out
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
		
		A <= X"0003";
		B <= X"0005";
	   imm <= X"000A";
		PC <= X"0001";
		
		mux_A <= '0';
		mux_B <= '0';
		instr_in <= "100000000000000";
		ALU_op <= "00000";
		mem_en <= '1';
		
		
		--TESTES ALU
	--	wait for clk_period*2;
	--	ALU_op <= "00001" ;
	--	wait for clk_period*2;
	--	ALU_op <= "00011" ;  
	--	wait for clk_period*2;
	--	ALU_op <= "00100" ; 
	--	wait for clk_period*2;
	--	ALU_op <= "00101" ; 
	--	wait for clk_period*2;
	--	ALU_op <= "00110" ; 
	--	wait for clk_period*2;
	--	ALU_op <= "01000" ; 
	--	wait for clk_period*2;
	--	ALU_op <= "01001" ; 
	--	wait for clk_period*2;
	--	ALU_op <= "10000" ; 
	--	wait for clk_period*2;
	--	ALU_op <= "10001" ; 
	--	wait for clk_period*2;
	--	ALU_op <= "10010" ;  
	--	wait for clk_period*2;
	--	ALU_op <= "10011" ; 
	--	wait for clk_period*2;
	--	ALU_op <= "10100" ;  
	--	wait for clk_period*2;
	--	ALU_op <= "10101" ; 
	--	wait for clk_period*2;
	--	ALU_op <= "10110" ; 
	--	wait for clk_period*2;
	-- ALU_op <= "10111" ; 
	--	wait for clk_period*2;
	--	ALU_op <= "11000" ;  
	--	wait for clk_period*2;
	--	ALU_op <= "11001" ; 
	--	wait for clk_period*2;
	--	ALU_op <= "11010" ; 
	--	wait for clk_period*2;
	--	ALU_op <= "11011" ; 
	--	wait for clk_period*2;
	--	ALU_op <= "11100" ; 
	--	wait for clk_period*2;
	--	ALU_op <= "11101" ; 
	--	wait for clk_period*2;
	--	ALU_op <= "11110" ; 
	--	wait for clk_period*2;
	--	ALU_op <= "11111" ; 
	--	wait for clk_period*2;
	
		--TESTES RAM
	--	wait for clk_period*2;
   -- mem_en <= '0';
	--	wait for clk_period*2;
	--	A <= X"0007";
	--	B <= X"000A";
	--	mem_en <= '1';
	--	wait for clk_period*2;
	--	mem_en <= '0';
	--	wait for clk_period*2;
	--	A <= X"0003";
		
		--TESTES LC
	-- wait for clk_period*2;
	-- instr_in <= "001000000000000";
	
	
		--TESTES LCL/LCH
	-- wait for clk_period*2;
	-- imm <= X"FF0A";
	-- wait for clk_period*2;
	-- instr_in <= "011000000000000";
	-- wait for clk_period*2;
	-- instr_in <= "111000000000000";	
	
		--TESTES COND
		
	 wait for clk_period*2;
	 instr_in <= "000000001000100";-- false negative
	 ALU_op <= "00000";
	 wait for clk_period*2;
	 instr_in <= "000000001010100";-- true negative
	 wait for clk_period*2;
	 instr_in <= "000000001000101";-- false zero
	 wait for clk_period*2;
	 instr_in <= "000000001010100";--true carry
	 wait for clk_period*2;
	 instr_in <= "000000001000111";--false neg|zero
	 
		
		
		
		
		
		
		

      wait;
   end process;

END;
