library ieee;use ieee.std_logic_1164.all; use ieee.numeric_std.all;
entity StartOnOff is 
generic(FCLK: positive:=50000000; ON_MS:positive:=2000; OFF_MS:positive:=500);
port (START, CLK, CLRN : in std_logic; RUN : out std_logic);
end entity;

architecture rtlOnOnly of StartOnOff is  
 signal isTiming, isOnTime:boolean:=false;
 signal debugStateIx:integer:=0; -- we see signals in the testbench
 begin -- architecture
  
ifsm: process(CLK)   
  type state_t is (ROFF, RONTIME, RON1, RON);
  variable state: state_t:=ROFF;
  variable vrun:std_logic:='0';
  begin 
    iRedge:if rising_edge(CLK) then 
               isTiming<=false; vrun:='0'; 
               debugStateIx<=state_t'Pos(state); 
           iCLRN: if CLRN='0'then state:=ROFF; 
               else 
                 case state is
                      when ROFF =>  if START='1' then state:=RONTIME; end if;
                      when RONTIME=> isTiming<=true; 
							  if START='0' then state:=ROFF; 
                                     elsif isOnTime then state:=RON1; 
                                     end if;
                      when RON1 => vrun:='1';
                           if START='0' then state:=RON; end if;
                      when RON => vrun:='1';
                           if START='1' then state:=ROFF; end if;
                  end case;
             end if iCLRN; 
      end if iRedge; --  if rising_edge(CLK) then 
      RUN<=vrun;
  end process;
  
  iTimer:process(CLK)
         constant MAXCOUNT:integer:=ON_MS;
         constant MSCOUNT : integer := (FCLK+500)/1000;
         variable cntrMS: integer range 0 to MSCOUNT:=0;
         variable cntr: integer range 0 to MAXCOUNT:=0;
         begin 
            iRedge:if rising_edge(CLK) then
                 iTiming:if not isTiming then cntr:=0; cntrMS:=0;
                      else 
                         if MSCOUNT>1 and cntrMS<MSCOUNT-1 
                         then cntrMS:=cntrMS+1; 
                         else cntrMS:=0; 
                              if cntr<MAXCOUNT then cntr:=cntr+1; end if;
                         end if;
                      end if iTiming;
                   end if iRedge;
                   isOnTime<=(cntr>=ON_MS);
         end process;

  end architecture;

architecture rtlOnOff of StartOnOff is  
   signal isTiming, isOnTime, isOffTime:boolean:=false;
   signal debugStateIx:integer:=0;
 begin -- architecture
  
ifsm: process(CLK)   
  type state_t is (ROFF, RONTIME, RON1, RON, ROFFTIME, ROFF1);
  variable state: state_t:=ROFF;
  variable vrun:std_logic:='0';
  begin 
    iRedge:if rising_edge(CLK) then 
               isTiming<=false; vrun:='0'; 
               debugStateIx<=state_t'Pos(state); 
           iCLRN: if CLRN='0'then state:=ROFF; 
               else 
                 case state is
                      when ROFF =>  if START='1' then state:=RONTIME; end if;
                      when RONTIME=> isTiming<=true; 
							         if START='0' then state:=ROFF; 
                                     elsif isOnTime then state:=RON1; 
                                      end if;
                      when RON1 => vrun:='1';
                           if START='0' then state:=RON; end if;
                      when RON => vrun:='1';
                           if START='1' then state:=ROFFTIME; end if;
                      when ROFFTIME=> vrun:='1'; isTiming<=true; 
							if START='0' then state:=RON; 
                            elsif isOffTime then state:=ROFF1; 
                            end if;
                      when ROFF1 => 
                           if START='0' then state:=ROFF; end if;
                 end case;
             end if iCLRN; 
      end if iRedge; --  if rising_edge(CLK) then 
      RUN<=vrun;
  end process;
  iTimer:process(CLK)
         function max(x,y:integer) return integer is
         begin if x>=y then return x; else return y; end if;
         end function;
         
         constant MAXCOUNT:integer:=max(ON_MS,OFF_MS);
         constant MSCOUNT : integer := (FCLK+500)/1000;
         variable cntrMS: integer range 0 to MSCOUNT:=0;
         variable cntr: integer range 0 to MAXCOUNT:=0;
         begin 
            iRedge:if rising_edge(CLK) then
                 iTiming:if not isTiming then cntr:=0; cntrMS:=0;
                      else 
                         if MSCOUNT>1 and cntrMS<MSCOUNT-1 
                         then cntrMS:=cntrMS+1; 
                         else cntrMS:=0; 
                              if cntr<MAXCOUNT then cntr:=cntr+1; end if;
                         end if;
                      end if iTiming;
                   end if iRedge;
                   isOnTime<=(cntr>=ON_MS);
                   isOffTime<=(cntr>=OFF_MS);
         end process;

  end architecture;

 
