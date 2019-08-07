
library IEEE;
    use IEEE.std_logic_1164.all;
    use work.all;

package stimul_pack is
    
 type etat_signal is (signal_zero, signal_chirp, signal_bruit, signal_chirp_bruit);   
 
 -- Declaration de Constantes
constant retard : integer ;
constant recurrence : integer ;
constant teta : integer ;
constant fin : integer;

end stimul_pack;

package body stimul_pack is  
    
constant retard : integer :=100;
constant recurrence : integer :=255;
constant teta : integer := 44;
constant fin : integer:=299;

end stimul_pack;


--*********************************************************************************
--*********************************************************************************
--				STIMULATEUR
--*********************************************************************************
--*********************************************************************************

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.stimul_pack.all;
use work.all;


entity stimulateur is
port(

reset : in std_logic;
clke : in std_logic;
d_out : out std_logic_vector(7 downto 0);
ref : out std_logic

);
end stimulateur;

architecture arch_stimulateur of stimulateur is


signal chirp : std_logic_vector(7 downto 0);
signal bruit : std_logic_vector(7 downto 0);
signal  raz_delta, raz_ech, s_44, s_100, s_144, s_255, s_299, inc_delta_f, count_enable : std_logic;
signal choix : etat_signal;

begin

compt:      entity compt_seq_stim port map (  reset  => reset,
                                            clke => clke, 
                                            count_enable => count_enable,
                                        	   s_44=> s_44,
                                          	 s_100=> s_100, 
                                            s_144=> s_144,
                                            s_255=> s_255, 
                                            s_299 => s_299 );
                                              
seq:        entity sequenceur port map (reset => reset, 
                                        clke => clke,
                                        s_44=> s_44, 
                                        s_100 => s_100, 
                                        s_144 => s_144, 
                                        s_255 => s_255, 
                                        s_299 => s_299,
                                        count_enable => count_enable, 
                                        inc_delta_f => inc_delta_f,
                                        raz_delta_f => raz_delta, 
                                        raz_echantillon => raz_ech,
                                        choix => choix, 
                                        ref => ref);
                                        
mux :       entity multiplexeur port map(bruit => bruit, 
                                        chirp => chirp, 
                                        choix => choix, 
                                        d_out => d_out);
                                        
gen_bruit : entity gene_bruit port map(clke => clke , 
                                       bruit => bruit);
                                       
gen_chirp : entity gene_chirp port map( clke => clke, 
                                        choix=> choix, 
                                        inc_delta_f => inc_delta_f, 
                                        raz_delta_f => raz_delta, 
                                        chirp => chirp);

end arch_stimulateur;



