
--*********************************************************************************
--		MULTIPLIEUR GENERIQUE
--*********************************************************************************
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


--/////////////////////
--    A COMPLETER
--/////////////////////
entity multiplicateur is
  port( A,B :  in std_logic_vector(7 downto 0);
        S: out  std_logic_vector(15 downto 0));
end multiplicateur;

architecture arch_multiplicateur of multiplicateur is
	begin
	  
	  S<=std_logic_vector((signed (A))*(signed(B)));

	 	  	
end arch_multiplicateur;
