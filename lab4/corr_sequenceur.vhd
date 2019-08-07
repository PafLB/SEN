

--*********************************************************************************
--		SEQUENCEUR du CORRELATEUR
--*********************************************************************************
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

--/////////////////////
--    A COMPLETER
--/////////////////////
entity sequenceur_corr is
  port( clk, reset, ref, clke : in std_logic;
        cnt : in std_logic_vector(6 downto 0	);
        calc, raz_pile_ref, ld_pile_rec, raz_pile_rec, ld_pile_ref, raz_reg_pdt, ld_reg_pdt, raz_reg_sum,
        ld_reg_sum, raz_cnt, en_cnt : out std_logic );
end sequenceur_corr;

architecture arch_sequenceur_corr of sequenceur_corr is

	type etat is (REPOS,ATTENTE_0,ATTENTE_1,ATTENTE_2,ATTENTE_3,CHARGMT_REF,CHARGMT_REC,CHARGMT_RES_INTER,DERNIER_PROD,SORTIE);
  signal etat_cr, etat_sv: etat;
  begin
    process(clk, reset)
      begin
        if reset = '1' then etat_cr <= REPOS;
        elsif rising_edge(clk) then etat_cr <= etat_sv;
        end if;
              end process;
              
              process(etat_cr,clke,ref,cnt)
               begin
                 
              calc <= '0'; raz_pile_ref <= '0'; ld_pile_rec <= '0'; raz_pile_rec <= '0'; 
              ld_pile_ref <= '0'; raz_reg_pdt  <= '0'; ld_reg_pdt <= '0';
              raz_reg_sum <= '0'; ld_reg_sum <= '0'; raz_cnt <= '0'; en_cnt <= '0'; etat_sv <= etat_cr;
       
              
              
                case etat_cr is
                  
			           when REPOS => raz_pile_rec <= '1';
			                         raz_pile_ref <= '1';
			                         raz_reg_sum <= '1';
			                         raz_reg_pdt <= '1';			                       
			                         if (ref = '1' AND clke = '1') then etat_sv <= CHARGMT_REF;
			                         end if;
			                
			           when CHARGMT_REF => ld_pile_ref <= '1';
			                               etat_sv <= ATTENTE_0; 
		                           		             
		                           		             
			           when ATTENTE_0 => if clke = '0' then etat_sv <= ATTENTE_1;
			                             end if;

			                           
			           when ATTENTE_1 => if (clke = '1'AND ref = '0') then etat_sv <= CHARGMT_REC;
			                             elsif (clke = '1' AND ref = '1') then etat_sv <= CHARGMT_REF; 
			                             end if;		                           
			                             
			                             
			           when CHARGMT_REC => ld_pile_rec <= '1'; 
			                               raz_reg_pdt <= '1'; 
			                               raz_reg_sum <= '1';
			                               raz_cnt <= '1';
			                               etat_sv <= CHARGMT_RES_INTER;		                                   	                                   
			                                   
			                                   
			           when CHARGMT_RES_INTER => en_cnt <= '1';
			                                     ld_reg_pdt <= '1';
			                                     ld_reg_sum <= '1';
			                                     calc <= '1';
			                                     if cnt = "0101011" then etat_sv <= DERNIER_PROD;
			                                     end if;
			                              
			                              
			           when DERNIER_PROD => ld_reg_pdt <= '1';
			                                ld_reg_sum <= '1';
			                                calc <= '1';
			                                etat_sv <= SORTIE;
		                              
		                              
			           when SORTIE  =>  ld_reg_sum <= '1';
			                            if clke = '1' then etat_sv <= ATTENTE_2;
			                            else etat_sv <= ATTENTE_3;
			                            end if;
			                             
			                             
			           when ATTENTE_2 => if clke = '0' then etat_sv <= ATTENTE_3;
			                             end if;   
			                                       
			                                                                            
                 when ATTENTE_3 =>  if (clke = '1' AND ref = '1') then etat_sv <= CHARGMT_REF;
                                    elsif (clke = '1' AND ref = '0') then etat_sv <= CHARGMT_REC;
			                              end if; 
			                    
			            end case;                 
			       end process;
			                          
end arch_sequenceur_corr;