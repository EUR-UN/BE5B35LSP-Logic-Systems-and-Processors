library ieee; use ieee.std_logic_1164.all;
entity RFE_DFF is    
  port ( CLK, C, D, CLRN : in std_logic:='0';   Q : out std_logic);
end entity;
architecture rtl of RFE_DFF is
begin
    process (CLK)
    type state_t is (SInit, C0x, C1x);
    variable state : state_t:=SInit;
    variable m:std_logic;
    begin
      iRedge : if falling_edge(CLK) then
        iClrn:if CLRN='0' then state:=SInit; m:='0';
        else
          case state is
            when SInit => if C='1' then state:= C1x; else state:=C0x; end if;
            when C0x =>  if C='1' then state:= C1x; m:=D; end if;
            when C1x =>  if C='0' then state:= C0x; m:=D; end if;
         end case;
        end if  iClrn;
     end if iRedge;
     Q<=m;
   end process;
end architecture;

