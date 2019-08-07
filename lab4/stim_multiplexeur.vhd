

--*********************************************************************************
--		Multiplexeur
--*********************************************************************************
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use work.stimul_pack.all;


entity multiplexeur is
port(
	bruit, chirp : in std_logic_vector(7 downto 0);
	choix : in etat_signal;
	d_out : out std_logic_vector(7 downto 0)

);
end multiplexeur;

architecture arch_multiplexeur of multiplexeur is

signal d_out_real : real:=0.0;


begin

with choix select

	d_out <= bruit 		         when signal_bruit,
		       chirp 		         when signal_chirp,
		       std_logic_vector( signed(chirp) +signed (bruit)) when signal_chirp_bruit,
		       "00000000" 		     when others;		
 

-- Conversion flottant vers représentation 0.7

end arch_multiplexeur;





