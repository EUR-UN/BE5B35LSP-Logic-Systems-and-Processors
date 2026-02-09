library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all;

entity tb_AbeforeB is end entity;

architecture rtl of tb_AbeforeB is
signal A, B, CLK, RESET, Y :  std_logic :='0';
constant AV : std_logic_vector := "01001111010111111011011100";
constant BV : std_logic_vector := "00111010010011010001111000";
begin
   CLK <= not CLK after 10 ns;  RESET<='1', '0' after 20 ns;
	iAB : entity work.AbeforeB port map(A,B,CLK,RESET,Y);
	process(CLK)
	variable ix:integer range 0 to AV'LENGTH:=0;
	variable switchAB : boolean :=false; -- A <-> B;
	begin
	  iFedge:if falling_edge(CLK) then 
	      if ix<AV'LENGTH-1 then ix:=ix+1; 
		  else ix:=0; switchAB:= not switchAB; end if;
		  -- we prolong the sequences by their switching
		  if switchAB then A<=BV(ix); B<=AV(ix); 
		  else A<=AV(ix); B<=BV(ix); 
		  end if;
	  end if iFedge;
   end process;
end architecture;
