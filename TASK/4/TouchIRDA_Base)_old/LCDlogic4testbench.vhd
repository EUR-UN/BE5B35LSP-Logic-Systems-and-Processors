--------------------------------------------------------
-- The entity is intended only for using in testbenchV2_ControlPanel.vhd only
-- It replaces UserInterface by simulating its outputs
-------------------------------------------------------------------------
library ieee, work; use ieee.std_logic_1164.all; use ieee.numeric_std.all; 
use work.LCDpackV2.all; 
use work.TouchIRDApackV2.all; -- package for Touch and IRDA
use work.UIpack.all; -- definitiona releated to this ControlPanel solution

entity LCDlogic4testbench is 
    port(xcolumn  : in  xy_t; -- x-coordinate of pixel (column index)
         yrow     : in  xy_t; -- y-coordinate of pixel (row index)
         XEND_N   : in  std_logic; -- '0' only when xcolumn=1023, otherwise '1', f=32227 Hz= 33e6/1024 
         YEND_N   : in  std_logic; -- '0' only when yrow=524, otherwise '1', f=61.384 Hz = 33e6/(1024*525)
         LCD_DE   : in  std_logic; -- DataEnable control signal of LCD controller
         LCD_DCLK : in  std_logic; -- LCD data clock, exactly 33 MHz
         RGBcolor : out RGB_t);         --  color data type RGB_t = std_logic_vector(23 downto 0), defined in LCDpackage
end entity;

architecture rtl OF LCDlogic4testbench IS 

component LCDlogicTask4 is
    generic(IsTestbench:boolean:=FALSE);
    port(xcolumn  : in  xy_t      := XY_ZERO; -- x-coordinate of pixel (column index)
         yrow     : in  xy_t      := XY_ZERO; -- y-coordinate of pixel (row index)
         XEND_N   : in  std_logic := '0'; -- '0' only when xcolumn=1023, otherwise '1', f=32227 Hz= 33e6/1024 
         YEND_N   : in  std_logic := '0'; -- '0' only when yrow=524, otherwise '1', f=61.384 Hz = 33e6/(1024*525)
         LCD_DE   : in  std_logic := '0'; -- DataEnable control signal of LCD controller
         LCD_DCLK : in  std_logic := '0'; -- LCD data clock, exactly 33 MHz
         touchCoordinates : in   TouchDataSlv_t := (others => '0'); -- coordinates packet to std_logic_vector 
         commandStop        : in  std_logic:='0'; -- '1' if stopped
         RGBcolor : out RGB_t:=BLACK);
end component;

signal touchCoordinates_s :  TouchDataSlv_t:=(others=>'0');
signal commandStop_s :  std_logic:='0';

begin 
   -- we inserted the instance of LCDlogicTask4
iLogic : LCDlogicTask4
    generic map(IsTestbench=>true)
    port map(xcolumn=>xcolumn,  yrow=>yrow,  XEND_N=>XEND_N, YEND_N=>YEND_N,  LCD_DE=>LCD_DE, LCD_DCLK=>LCD_DCLK,
             touchCoordinates=>touchCoordinates_s,   commandStop=>commandStop_s,
             RGBcolor=>RGBcolor);         

 -- we substitute UserInterface by generating its outputs

testGenerator : process(YEND_N)               
   variable tr:TouchRecord_t:=TouchRecord_ZERO;
   variable cntrSimStep:integer range 0 to 31;  -- for generating test signals  
 begin
      if falling_edge(YEND_N) then -- YEND_N='0' in the last row of LCD frames
        -- At the beginning of the simulation, we emulate one touch only.
		  tr.count:=1; tr.x1:=(cntrSimStep+1)*25; tr.y1:=(cntrSimStep+1)*15;

        -- In the middle, we add the second touch
		  if cntrSimStep>16 then tr.count:=2; tr.x2:=tr.x1/2; tr.y2:=LCD_HEIGHT-tr.y1/2;  end if;
        
		  -- We increment the simulation counter for 32 LCD frames
		  if cntrSimStep<31 then cntrSimStep:=cntrSimStep+1; end if;
       
		 -- We have copied the following expression from UserInterfaceV2.vhd
 	     if InLimit(tr.x1,BLINK_XLEFT-TCIRCLE,BLINK_SIZE+2*TCIRCLE) 
				  and InLimit(tr.y1,BLINK_YTOP-TCIRCLE,BLINK_SIZE+2*TCIRCLE) then
 	         commandStop_s<='1';  else   commandStop_s<='0';
 	     end if;

		end if; -- if falling_edge(YEND_N)
		
	  touchCoordinates_s<=to_TouchDataSlv(tr); -- pack tr of TouchRecord_t type to std_logic_vector 
  end process;

end architecture;