library ieee; use ieee.std_logic_1164.all;use ieee.numeric_std.all;
entity BoilerFSM is
    port( CLK, RESET: in std_logic;
 start, full, boiling, Chef : in std_logic;
 water, fire, bell : out std_logic);
end;
architecture rtl of BoilerFSM is
begin
 iboiler : process (CLK) 
   type state_t is (S0, S1, S2, S3);
   variable state : state_t:=S0;
   begin
iRedge :if rising_edge(clk) then
  iDelta: if RESET then  state := S0; else
     iNext: case state is
              when S0 =>	if start  then  state := S1; end if;
              when S1 =>	if full  then state := S2; end if;
              when S2 =>	if boiling  then  state := S3; end if;
              when S3 =>	if Chef then state := S0; end if;
            end case iNext;
       end if iDelta; 
     end if iRedge;
     water <= '0'; fire<='0'; bell <= '0';
     case state is  
        when S0=>null;  
        when S1=> water <= '1';
        when S2=> fire<='1';  
        when S3=> bell <= '1';  
     end case;
  end process; 
end architecture;


architecture controlUnit of BoilerFSM is
signal debugPC : integer :=0;
begin
  iboiler : process (CLK) 
    type cmd_t is record  
      CondIx: integer range 0 to 3;  -- index of input
      WFB: std_logic_vector(0 to 2); -- Water, Fire, Bell values
   end record; 
   type mem_t is array(natural range <>) of cmd_t;
   constant MEM : mem_t := ((0,"000"),(1,"100"),(2,"010"),(3,"001"));
   variable pc : integer range 0 to MEM'HIGH:=0; --Program Counter
   variable Binputs : std_logic_vector(0 to 3):=(others=>'0');
   variable instr:cmd_t:=(0,"000");
   begin -- process
iRedge:if rising_edge(CLK) then
   iDelta:if RESET then pc:=0; instr:=(0,"000"); else
 instr:=MEM(pc);
 BInputs:=start & full & boiling & Chef; 
 if BInputs(instr.CondIx) then 
     if pc<MEM'HIGH then pc:=pc+1; else  pc:=0; end if;
 end if;
             end if iDelta;
          end if iRedge;
  water<=instr.WFB(0); fire<=instr.WFB(1);  bell<=instr.WFB(2);
  debugPC<=pc;  
 end process;  
end architecture;

architecture microCode of BoilerFSM is
signal dbgPCm : integer :=0;
begin
  iboiler : process (CLK) 
    type cmd_t is record  
      CondIx: integer range 0 to 3;  -- index of input
      brOpt: unsigned(1 downto 0);  -- condition "0-" no, "10":on ='0', "11":on ='1'
      brCondIx: integer range 0 to 3; --the index of a tested input
      brAddr: integer range 0 to 15;  --
      WFB: std_logic_vector(0 to 2); -- Water, Fire, Bell values
   end record; 
   type mem_t is array(natural range <>) of cmd_t;
   constant MEM : mem_t := ((0,"00",0,0,"000"),(1,"00",0,0,"100"),(2,"10",1,1,"010"),(3,"10",1,1,"001"));
   variable pc : integer range 0 to MEM'HIGH:=0; --Program Counter
   variable Binputs : std_logic_vector(0 to 3):=(others=>'0');
   constant INIT:cmd_t:=(0,"00",0,0,"000");
   variable instr:cmd_t:=INIT;
   begin -- process
iRedge:if rising_edge(CLK) then
   iDelta:if RESET then pc:=0; instr:=INIT; else
           instr:=MEM(pc);
           BInputs:=start & full & boiling & Chef; 
           if BInputs(instr.CondIx) then 
              if pc<MEM'HIGH then pc:=pc+1; else  pc:=0; end if;
           elsif instr.brOpt(1)='1' and BInputs(instr.brCondIx)=instr.brOpt(0) then
                if instr.brAddr<MEM'LENGTH then pc:=instr.brAddr; end if;
           end if;
         end if iDelta;
      end if iRedge;
  water<=instr.WFB(0); fire<=instr.WFB(1);  bell<=instr.WFB(2);
  dbgPCm<=pc;  
 end process;  
end architecture;
