library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all;

entity tb_StartStopFSM is end entity;

architecture rtl of tb_StartStopFSM is
signal START, STOP, CLK, CLRN, RUN :  std_logic :='0';
constant CStart : std_logic_vector := "01001111010111111011111110";
constant CStop : std_logic_vector :=  "01110010010011010001111000";
component StartStopFSM is 
port (START, STOP, CLK, CLRN : in std_logic;
      RUN : out std_logic);
end component;
begin
    CLK <= not CLK after 10 ns;  CLRN<='0', '1' after 50 ns;
	iFSM : entity work.StartStopFSM port map(START, STOP, CLK, CLRN, RUN);
	process(CLK)
	variable ix:integer range 0 to CStart'LENGTH:=0;
	variable switch : boolean :=false; -- CStop <-> CStart;
	begin
	  iFedge:if falling_edge(CLK) then 
	      if ix<CStart'LENGTH-1 then ix:=ix+1; 
		  else ix:=0; switch:= not switch; end if;
		  if switch then Stop<=CStart(ix); Start<=CStop(ix); 
		  else Stop<=CStop(ix); Start<=CStart(ix);  
		  end if;
	  end if iFedge;
   end process;
end architecture;
