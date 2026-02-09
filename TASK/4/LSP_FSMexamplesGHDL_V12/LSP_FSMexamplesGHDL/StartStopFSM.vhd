library ieee;use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;
entity StartStopFSM is 
port (   START, STOP, CLK : in std_logic;
         CLRN : in std_logic;      -- FSMs prefer synchronous clear
         RUN : out std_logic);
end entity;
architecture rtl1 of StartStopFSM is 
begin -- architecture
ilog: process(CLK)
  begin  
     iRedge : if rising_edge(CLK) then
                if STOP='1' or CLRN='0' then RUN <='0';  
                elsif START ='1' then RUN <='1'; 
                end if;
           end if iRedge;

   end process;
end architecture;

architecture rtlFSM of StartStopFSM is  
begin
ifsm: process(CLK)
  type state_t is (ROFF, RON); -- enumerated types are reserved only for FSMs
  variable state: state_t:=ROFF;
  begin
      iRedge : if rising_edge(CLK) then
          iClrn: if CLRN='0'  then state:=ROFF; -- always clear
                 else
                     case state is
                        when ROFF => if START='1' and STOP='0' 
                                      then  state:=RON; end if;
                        when RON => if STOP='1' 
                                    then state:=ROFF; end if;
            end case; end if iClrn;
     end if iRedge;
     if state=RON then RUN<='1'; else RUN<='0'; end if; 
  end process; 
end architecture;
