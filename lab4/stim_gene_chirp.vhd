--*********************************************************************************
--		GENERATEUR DE CHIRP
--*********************************************************************************
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use work.stimul_pack.all;
use work.all;

entity gene_chirp is
port(
	clke : in std_logic;
	choix : in etat_signal;
	inc_delta_f : in std_logic;
	raz_delta_f : in std_logic;
	chirp : out std_logic_vector(7 downto 0)

);
end gene_chirp;

architecture arch_gene_chirp of gene_chirp is


	signal delta_f, chirp_interne : real;

	function f_chirp(n_ech:real ; delta_f : real) return real is
	variable phase : real :=0.0;
	begin
	phase:=((math_pi*delta_f)*((n_ech*n_ech/44.0) - n_ech));
	return 0.499*cos(phase);
	end f_chirp;
	
	

begin

process(clke)
variable numero_ech : real;
variable compt_delta_f : real;
begin

if(rising_edge(clke)) then


if(raz_delta_f='1') then delta_f <= 0.0; compt_delta_f:=0.0;-- attention initialisation 
elsif (inc_delta_f = '1') then      compt_delta_f := compt_delta_f + 1.0;
                                    delta_f<= (compt_delta_f mod 12.0)*0.05;

end if;

	if (choix=signal_chirp or choix=signal_chirp_bruit) then

							chirp_interne<= f_chirp(numero_ech, delta_f); 
							numero_ech := numero_ech + 1.0;

							else numero_ech := 0.0;
							     chirp_interne<=0.0;

	end if;
end if;

end process;
chirp <= std_logic_vector(to_signed(integer(round(128.0*chirp_interne)),8));
end arch_gene_chirp;






