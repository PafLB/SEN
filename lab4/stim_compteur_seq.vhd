
--*********************************************************************************
--		COMPTEUR DU SEQUENCEUR
--**********************************************************************
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.stimul_pack.all;


entity compt_seq_stim is
  
  port(	
  
  reset, clke, count_enable : in std_logic;
	s_44, s_100, s_144, s_255, s_299 : out std_logic
	
	);
end compt_seq_stim;



architecture arch_compt_seq_stim of compt_seq_stim is	
	
	signal compteur : integer range 0 to 299;
	
	begin
	  
	  process(clke, reset)
	    
	    begin
	      
	      if reset='0' then 
	      
	         if rising_edge(clke) then
	        
	           if count_enable = '1' then
	        
	           if compteur =299 then compteur <= 0; else compteur <= compteur+1; end if;
	           end if;
	          end if;
	      
	      else compteur <= 0;
	      end if;
	
  end process;
  
  s_44 <= '1' when compteur=45  else '0';
  s_100<= '1' when compteur=100 else '0';
  s_144<= '1' when compteur=145 else '0'; 
  s_255<= '1' when compteur=255 else '0';
  s_299<= '1' when compteur=299 else '0';
  
end arch_compt_seq_stim;





