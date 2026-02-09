-------------------------------------------------------------------------------
-- The definitions here are shared by UserInterface and LCDlogicTask4
--*********************************************************
-- The packages are explained:
--cz: kapitola 7 v  https://dcenet.fel.cvut.cz/edu/fpga/doc/UvodDoVHDL1_concurrent_V20.pdf
--eng: Chapter 7 in https://dcenet.fel.cvut.cz/edu/fpga/doc/CircuitDesignWithVHDL_dataflow_and_structural_eng_V10.pdf 
---------------------------------------------------------------
library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all; 
use work.LCDpackV2.all;

package UIpack is

  -- the square button for stop/run
  constant BLINK_SIZE : integer := 64;   -- its size
  constant BLINK_XLEFT: integer :=(LCD_WIDTH-BLINK_SIZE)/2; -- distance from left 
  constant BLINK_YTOP : integer :=(LCD_HEIGHT-BLINK_SIZE)/2; -- distance fromtop
 
  -- the touch circles size
  constant TCIRCLE :integer := 16; -- touch circles
 
 
end package;
----------------------------------------------------------------------------------------------------
package body UIpack is
 

	 
end package body;

