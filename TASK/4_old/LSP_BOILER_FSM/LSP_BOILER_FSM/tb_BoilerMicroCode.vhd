library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all;
library work;
entity tb_BoilerMicroCode is end entity;

architecture rtl OF tb_BoilerMicroCode is
signal reset,start,full,boiling,Chef:std_logic:='0';
signal water,fire,bell:std_logic:='0';
signal CLK:std_logic:='0';
 component BoilerFSM is
    port( CLK, RESET: in std_logic;
          start, full, boiling, Chef : in std_logic;
          water, fire, bell : out std_logic);
  end component;
type R_t is record D:std_logic_vector(0 to 4); T:TIME; 
end record;
type Stimul_t is array(natural range <>) of R_t;
-- compiler
function T2R(s:string;t:positive) return R_t is
variable result:R_t; 
variable v:std_logic_vector(result.D'RANGE);
begin v:="00000";
  iloop : for i in s'RANGE loop
             case s(i) is
               when 'R'=>v(0):='1';  when 'S'=>v(1):='1';
               when 'F'=>v(2):='1';  when 'B'=>v(3):='1';
               when 'C'=>v(4):='1';
               when others=> null;
            end case;
          end loop iloop;
          result.D:=v; result.T:=t*(1 sec); return result;
end function;
constant STIMULS:Stimul_t:=
(T2R("-",20),T2R("S",100),T2R("-",50), T2R("F",100),
 T2R("SF",40),T2R("-",40), T2R("F",50),T2R("FB",50),
 T2R("-",100), T2R("F",50),T2R("FB",50), T2R("FC",50),
 T2R("S",100),T2R("-",50), T2R("F",100), T2R("FR",50), 
 T2R("F",50), T2R("SF",50), T2R("FB",50),T2R("FC",50));

begin
   CLK <= not CLK after 1 sec;
    imc : entity work.BoilerFSM(microCode) 
       port map(CLK, RESET, start, full, boiling, Chef, water, fire, bell);
 
always : process -- onetime run only
    variable x:std_logic_vector(STIMULS(0).D'RANGE):=(others=>'0');
    begin
    irep: for j in 1 to 2 loop
     iloop:for ix in 0 to STIMULS'LENGTH-1 loop
             x:=STIMULS(ix).D;   
             RESET<=x(0); start<=x(1);full<=x(2);boiling <=x(3);Chef<=x(4);
            wait for j*STIMULS(ix).T;
      end loop iloop; 
    end loop irep;
    
    assert false report LF&":-) OK end"&LF severity failure;
    end process;
end architecture;
