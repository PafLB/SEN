--*********************************************************************************
--		COMPTEUR DU SEQUENCEUR
--**********************************************************************
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

--/////////////////////
--    A COMPLETER
--/////////////////////
entity compteur_seq is
  port( clk :  in std_logic;
        raz, en : in std_logic;
        cnt : out std_logic_vector(6 downto 0)	);
end compteur_seq;

architecture arch_compteur_seq of compteur_seq is
  signal tmp : integer range 64 downto 0;
  begin
     
     process(raz, clk, tmp)
      begin
        
        if raz = '1' then 
          tmp     <= 0;
          cnt <= (others => '0');
        else
          cnt <= std_logic_vector(to_unsigned(tmp,7));
        end if;
        
        if rising_edge(clk) and en = '1' then
            if tmp = 64 then tmp <= 0; 
              else tmp <= tmp+1;
            end if;
       end if;
   end process;
end arch_compteur_seq;