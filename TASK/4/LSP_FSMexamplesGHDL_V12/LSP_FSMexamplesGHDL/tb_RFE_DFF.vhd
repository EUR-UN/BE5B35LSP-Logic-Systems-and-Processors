library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all;

entity tb_RFE_DFF is end entity;

architecture rtl of tb_RFE_DFF is
signal C, CLK, D, CLRN, Q :  std_logic :='0';
constant DATA : std_logic_vector := "1110011111110000001111110000";
constant CARR : std_logic_vector :=    "0111000011100011111100111000";
component RFE_DFF is 
    port ( CLK, C, D, CLRN : in std_logic:='0';   
             Q : out std_logic);  
end  component;
begin
    CLK <= not CLK after 10 ns;  CLRN<='0', '1' after 50 ns;
	iFSM : entity work.RFE_DFF port map(CLK, C, D, CLRN, Q);
	process(CLK)
	variable ix:integer range 0 to DATA'LENGTH:=0;
	variable switch : boolean :=false; -- CStop <-> CStart;
	begin
	  iRedge:if rising_edge(CLK) then 
	      if ix<DATA'LENGTH-1 then ix:=ix+1; 
		  else ix:=0; switch:= not switch; end if;
		  if switch then C<=DATA(ix); D<=CARR(ix); 
		  else C<=CARR(ix); D<=DATA(ix);  
		  end if;
	  end if iRedge;
   end process;
end architecture;
