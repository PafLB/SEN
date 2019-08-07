--*********************************************************************************
--		GENERATEUR DE BRUIT
--*********************************************************************************


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use work.stimul_pack.all;


entity gene_bruit is
   
port(
	clke : in std_logic;
	bruit : out std_logic_vector(7 downto 0)
);
end gene_bruit;

architecture arch_gene_bruit of gene_bruit is

begin
   process(clke)
       variable s1 : integer :=1233;
       variable s2 : integer := 4798;
       variable v_bruit : real :=0.0;

       
   begin    
         if(rising_edge(clke))
               	then uniform(s1, s2, v_bruit);
		               v_bruit:=0.999*(v_bruit - 0.5);
		               
-- conversion real -> std_logic_vector sur 8 bit en virgule fixe 1.7
bruit <= std_logic_vector(to_signed(integer(round(128.0*v_bruit)),8));
         end if; 
end process;
end arch_gene_bruit;




