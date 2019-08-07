--*********************************************************************************
--		SEQUENCEUR
--*********************************************************************************
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use work.stimul_pack.all;


entity sequenceur is
port(
	reset : in std_logic;
	clke : in std_logic;
  s_44, s_100, s_144, s_255, s_299 : in std_logic;
  count_enable : out std_logic;
  
	raz_delta_f : out std_logic;

	inc_delta_f: out std_logic;
	raz_echantillon : out std_logic;

	choix : out etat_signal;

	ref : out std_logic
);
end sequenceur;

architecture arch_sequenceur of sequenceur is

type etats is (repos, initialisation_1, chirp_ref, zero_1, reception,  zero_2, pause_1, initialisation_2, bruit_1, reception_bruit, bruit_2, pause_2);
signal etat_cr, etat_sv : etats;


begin
  
etat_cr <= repos when reset ='1' else
		      etat_sv when rising_edge(clke) else
		      etat_cr;  



process(etat_cr,s_44, s_100, s_144, s_255, s_299)

begin

inc_delta_f <= '0';
raz_delta_f <= '0';
inc_delta_f <= '0';
raz_echantillon <= '0';
choix <= signal_zero;
ref <= '0';
count_enable <= '0';

etat_sv <=etat_cr ;


case etat_cr is

	when repos 		=>	etat_sv <= initialisation_1;
	  
	raz_delta_f <='1';
	raz_echantillon <='1';

	when initialisation_1	=>	etat_sv <= chirp_ref;
	                         choix <= signal_chirp; -- sortie Mealy
	
	inc_delta_f <='1';
	raz_echantillon <='1' ;
	count_enable <= '1';
	

	when chirp_ref		=>	if s_44='1' then etat_sv <= zero_1; else etat_sv <= chirp_ref; end if;  
	choix <= signal_chirp;
	ref <='1';
	count_enable <= '1';

	when zero_1		=>	if s_100='1' then etat_sv <= reception;
                                    choix <= signal_chirp; -- sortie Mealy
	                else etat_sv <= zero_1; end if;
	count_enable <= '1'; 
	
	when reception		=>	if s_144='1' then etat_sv <= zero_2; else etat_sv <= reception; end if;  
	choix <= signal_chirp;
	count_enable <= '1';

	when  zero_2		=>	if s_255='1' then etat_sv <= pause_1; else etat_sv <= zero_2; end if;
  count_enable <= '1';
  
	when pause_1		=>	if s_299='1' then etat_sv <= initialisation_2; else etat_sv <= pause_1; end if;
  count_enable <= '1';

	when initialisation_2	=> etat_sv <= bruit_1;  
	raz_echantillon <='1';
	count_enable <= '1';

	when bruit_1		=>	if s_44='1' then etat_sv <= reception_bruit; else etat_sv <= bruit_1; end if;  
	choix <= signal_bruit;
	count_enable <= '1';

	when reception_bruit	=>	if s_144='1' then etat_sv <= bruit_2; else etat_sv <= reception_bruit;
	                                                                   choix <= signal_chirp; -- sortie Mealy
	                                                                    end if;  
	choix <= signal_chirp_bruit;
	count_enable <= '1';

	when bruit_2		=>	if s_255='1' then etat_sv <= pause_2; else etat_sv <= bruit_2; end if;  
	choix <= signal_bruit;
	count_enable <= '1';

	when pause_2		=>	if s_299='1' then etat_sv <= initialisation_1; else etat_sv <= pause_2; end if;
  count_enable <= '1';

end case;
end process;


end arch_sequenceur;




