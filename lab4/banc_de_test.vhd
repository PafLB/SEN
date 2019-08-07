--*********************************************************************************
--*********************************************************************************
--		TP2 : DESCRIPTION DU BANC DE TEST
--*********************************************************************************
--*********************************************************************************
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.stimul_pack.all;
use work.all;

--/////////////////////
--    A COMPLETER
--/////////////////////
entity banc_test is
  port( clke,reset,clk : in std_logic;
        SBanc : out std_logic_vector(19 downto 0));
   end banc_test;

architecture arch_banc_test of banc_test is
  signal ref : std_logic;
  signal data : std_logic_vector( 7 downto 0);

	begin
	  
stimulator: entity stimulateur port map (
                  reset => reset,
                  clke => clke,
                  d_out => data, 
                  ref => ref);

correllator: entity correlateur port map (
                  clke => clke,
                  clk => clk, 
                  reset => reset,
                  ref => ref,
                  d_in => data,
                  correll => SBanc);
	 	  	
end arch_banc_test;