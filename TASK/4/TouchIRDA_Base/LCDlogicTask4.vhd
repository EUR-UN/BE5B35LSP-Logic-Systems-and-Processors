-------------------------------------------------------------
-- CTU-FFE Prague, Dept. of Control Eng. [Richard Susta], Published under GNU General Public License
-------------------------------------------------------------

library ieee, work;
use ieee.std_logic_1164.all; use ieee.numeric_std.all;  -- for integer and unsigned types
use work.LCDpackV2.all;       -- its version 2.1 and higher
use work.TouchIRDApackV2.all; --defined TouchDataSlv_t 
use work.UIpack.all; 

entity LCDlogicTask4 is
    generic(IsTestbench:boolean:=FALSE); -- in testbench, we decrease frequency
    port( touchCoordinates : in   TouchDataSlv_t := (others => '0'); -- packet with coordinates 
         commandStop        : in  std_logic:='0'; -- '1' if stopped
         xcolumn  : in  xy_t      := XY_ZERO; -- x-coordinate of pixel (column index)
         yrow     : in  xy_t      := XY_ZERO; -- y-coordinate of pixel (row index)
         XEND_N   : in  std_logic := '0'; -- '0' only when xcolumn=1023, otherwise '1', f=32227 Hz= 33e6/1024 
         YEND_N   : in  std_logic := '0'; -- '0' only when yrow=524, otherwise '1', f=61.384 Hz = 33e6/(1024*525)
         LCD_DE   : in  std_logic := '0'; -- DataEnable control signal of LCD controller
         LCD_DCLK : in  std_logic := '0'; -- LCD data clock, exactly 33 MHz
			RGBcolor : out RGB_t:=BLACK);
end entity;

-- Basic LCD
architecture rtl of LCDlogicTask4 is
signal blinkOnOff:boolean:=false;   --
     
begin 
	 LSPimage : process(xcolumn,yrow,touchCoordinates,commandStop,blinkOnOff)
        variable RGB   : RGB_t     := BLACK; 
        variable x, y  : integer   := 0; -- integer xcolumn and yrow
        variable touchRecord                 : TouchRecord_t                     := TouchRecord_ZERO; -- Touch
     begin                               
		  --------------------------------------------------------------------------------------------------------
        x := to_integer(xcolumn);   y := to_integer(yrow);          -- convert unsigned to integers
		  touchRecord := to_TouchRecord(touchCoordinates); -- to_TouchRecord() is defined in TouchIRDApackV2.vhd
        
		  RGB := assignIf(IsTestbench,BLUE,NAVY); -- assignIf() is in Task4package
		  ---------------------------------------------
--		  -- InLimit() and constants are in Task4package
        if InLimit(x,BLINK_XLEFT,BLINK_SIZE) and InLimit(y,BLINK_YTOP,BLINK_SIZE) then
		     if commandStop then RGB:=GRAY; 
			  else RGB:=assignIf(blinkOnOff,YELLOW, VIOLET); 
			  end if;
		  end if;   
		   ----- draw touch circles-------------------------------------------------------
	     if touchRecord.Count>0 and (x-touchRecord.x1)**2+(y-touchRecord.y1)**2<TCIRCLE**2 then RGB:=RED; end if;
	     if touchRecord.Count>1 and (x-touchRecord.x2)**2+(y-touchRecord.y2)**2<TCIRCLE**2 then RGB:=GREEN; end if;

        RGBcolor <= RGB; 
        ---------------------------------------------------------------------------------------------------------------    
    end process;
-----------------------------------------------------------------------------------------------------------------
 iBlink: process(YEND_N) -- blinking timer
	 constant BLINK_FREQ:integer := assignIf(IsTestbench,2,61); -- assignIf is defined in Task4package
	 variable OnOff:boolean := true;
    variable cntr : integer range 0 to BLINK_FREQ:=0;
    begin
        if falling_edge(YEND_N) then 
	        if cntr<BLINK_FREQ then cntr:=cntr+1; else cntr:=0; OnOff:=not OnOff; end if;
        end if;
		  blinkOnOff <=  OnOff;
    end process;  

end architecture;

