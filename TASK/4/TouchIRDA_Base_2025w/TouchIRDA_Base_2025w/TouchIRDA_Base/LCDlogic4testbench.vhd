library ieee, work; use ieee.std_logic_1164.all; use ieee.numeric_std.all; 
use work.LCDpackV2.all; 
use work.TouchIRDApackV2.all; 
use work.UIpack.all; 

entity LCDlogic4testbench is 
    port(xcolumn  : in  xy_t; 
         yrow     : in  xy_t; 
         XEND_N   : in  std_logic; 
         YEND_N   : in  std_logic; 
         LCD_DE   : in  std_logic; 
         LCD_DCLK : in  std_logic; 
         RGBcolor : out RGB_t);           
end entity;

architecture rtl OF LCDlogic4testbench IS 

-- Component declaration (keep consistent with LCDlogicTask4)
component LCDlogicTask4 is
    generic(IsTestbench:boolean:=FALSE);
    port(xcolumn  : in  xy_t      := XY_ZERO; 
         yrow     : in  xy_t      := XY_ZERO; 
         XEND_N   : in  std_logic := '0'; 
         YEND_N   : in  std_logic := '0'; 
         LCD_DE   : in  std_logic := '0'; 
         LCD_DCLK : in  std_logic := '0'; 
         touchCoordinates : in   TouchDataSlv_t := (others => '0'); 
         commandStop      : in  std_logic:='0'; 
         RGBcolor : out RGB_t:=BLACK;
         -- Added ports
         morse_index_in : in integer range 0 to 63 := 0;
         current_speed_in : in integer range 1 to 16 := 5 -- keep consistent with the main design
         );
end component;

signal touchCoordinates_s :  TouchDataSlv_t:=(others=>'0');
signal commandStop_s :  std_logic:='0';

-- Signal ranges must cover all possible values
signal s_sim_index : integer range 0 to 63 := 0;
signal s_sim_speed : integer range 1 to 16 := 5; -- keep within 1..16

begin 
    -- Instantiate DUT
   iLogic : LCDlogicTask4
    generic map(IsTestbench=>true)
    port map(xcolumn=>xcolumn,  yrow=>yrow,  XEND_N=>XEND_N, YEND_N=>YEND_N,  
             LCD_DE=>LCD_DE, LCD_DCLK=>LCD_DCLK,
             touchCoordinates=>touchCoordinates_s,    
             commandStop=>commandStop_s,
             RGBcolor=>RGBcolor,
             -- Connect simulated inputs
             morse_index_in => s_sim_index,
             current_speed_in => s_sim_speed
             );           

 -- Test generator
 testGenerator : process(YEND_N)                 
    variable tr : TouchRecord_t := TouchRecord_ZERO;
    variable cntrSimStep : integer range 0 to 63 := 0; 
  begin
       if falling_edge(YEND_N) then 
         tr := TouchRecord_ZERO; 

         --  Auto-scroll Morse text
         if commandStop_s = '0' then 
             if s_sim_index < 63 then
                 s_sim_index <= s_sim_index + 1;
             else
                 s_sim_index <= 0;
             end if;
         end if;

         --  Simple script: speed up on selected frames
         
         -- Frame 2: tap center (pause)
         if cntrSimStep = 2 then 
             tr.count := 1; tr.x1 := 400; tr.y1 := 240; 
             commandStop_s <= '1'; -- enter stopped state
         end if;

         -- =======================================================
         --  Frame 4/6: tap upper-right star (speed up)
         -- The higher star is around (600, 50) with size ~144x144.
         -- =======================================================
         if cntrSimStep = 4 or cntrSimStep = 6 then 
             tr.count := 1; tr.x1 := 650; tr.y1 := 100; 
             -- Increase simulated speed
             if s_sim_speed < 16 then s_sim_speed <= s_sim_speed + 1; end if;
         end if;

         -- Frame 6: tap center (resume)
         if cntrSimStep = 6 then 
             tr.count := 1; tr.x1 := 400; tr.y1 := 240; 
             commandStop_s <= '0'; -- resume
         end if;
 
         -- =======================================================
         --  Frame 8+: tap upper-right star again (speed up)
         -- =======================================================
         if cntrSimStep = 8 then 
             tr.count := 1; tr.x1 := 650; tr.y1 := 100; 
             -- Increase simulated speed again
             if s_sim_speed < 16 then s_sim_speed <= s_sim_speed + 1; end if;
         end if;
         if cntrSimStep = 10 then 
             tr.count := 1; tr.x1 := 650; tr.y1 := 100; 
             -- Increase simulated speed again
             if s_sim_speed < 16 then s_sim_speed <= s_sim_speed + 1; end if;
         end if;
         if cntrSimStep = 12 then 
             tr.count := 1; tr.x1 := 650; tr.y1 := 100; 
             -- Increase simulated speed again
             if s_sim_speed < 16 then s_sim_speed <= s_sim_speed + 1; end if;
         end if;        
         if cntrSimStep = 13 then 
             tr.count := 1; tr.x1 := 650; tr.y1 := 100; 
             -- Increase simulated speed again
             if s_sim_speed < 16 then s_sim_speed <= s_sim_speed + 1; end if;
         end if;
         if cntrSimStep = 15 then 
             tr.count := 1; tr.x1 := 650; tr.y1 := 100; 
             -- Increase simulated speed again
             if s_sim_speed < 16 then s_sim_speed <= s_sim_speed + 1; end if;
         end if;
         if cntrSimStep = 21 then 
             tr.count := 1; tr.x1 := 650; tr.y1 := 100; 
             -- Increase simulated speed again (clamped to 16)
             if s_sim_speed < 16 then s_sim_speed <= s_sim_speed + 1; end if;
         end if;                 
         -- Increment frame counter
         if cntrSimStep < 63 then 
             cntrSimStep := cntrSimStep + 1; 
         end if;
         
         -- Drive output touchCoordinates
         touchCoordinates_s <= to_TouchDataSlv(tr);

   end if; -- falling_edge
  end process;

end architecture;