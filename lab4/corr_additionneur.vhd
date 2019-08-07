

--*********************************************************************************
--		ADDITIONNEUR GENERIQUE
--*********************************************************************************
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

--/////////////////////
--    A COMPLETER
--/////////////////////
entity additionneur is
  port( E1,E2 :  in std_logic_vector(19 downto 0);
        S: out  std_logic_vector(19 downto 0));
end additionneur;

architecture arch_additionneur of additionneur is
	begin
	  
	  S<=std_logic_vector((signed (E1))+(signed(E2)));

	 	  	
end arch_additionneur;