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

  -- Background circles geometry (Task 3)
  constant CIRCLE_CX : integer := LCD_WIDTH / 2;
  constant CIRCLE_CY_UPPER : integer := -180;
  constant CIRCLE_CY_LOWER : integer := 640;
  constant CIRCLE_R : integer := 480;
  constant CIRCLE_UPPER_SPLIT_Y : integer := 230;

  -- Star images (shared by LCD drawing + touch hitboxes)
  -- NOTE: Keep these consistent with H_Star ROM geometry.
  constant IMG_W : integer := 143;  -- star width
  constant IMG_H : integer := 144;  -- star height
  constant HSTAR_X0 : integer := 600;  -- x position of higher star
  constant HSTAR_Y0 : integer := 50;   -- y position of higher star
  constant LSTAR_X0 : integer := 40;   -- x position of lower star
  constant LSTAR_Y0 : integer := 280;  -- y position of lower star

  -- Morse text/graphics layout
  constant MORSE_TEXT_W  : integer := 768;
  constant MORSE_TEXT_H  : integer := 20;
  constant MORSE_TEXT_Y0 : integer := 419;
  constant MORSE_TEXT_XLEFT : integer := 16;

  -- Mapping from screen X to Morse index (used by MorseYWZ addressing)
  -- Matches: base_idx := to_integer(xcolumn*MORSE_X_MAP_NUM)/2**MORSE_X_MAP_SHIFT
  constant MORSE_X_MAP_NUM   : natural := 85;
  constant MORSE_X_MAP_SHIFT : natural := 10;

  -- Scrolling parameters used when addressing Morse_Text_YUANW ROM
  constant MORSE_SCROLL_STEP_X : integer := 12;
  constant MORSE_SCROLL_X_BIAS : integer := 20;

  -- Morse drawing area below the text line
  constant MORSE_DRAW_Y0 : integer := 440;
  constant MORSE_DRAW_H  : integer := 30;

  -- Marker used for Morse sync/drawing (Task C)
  constant MORSE_MARKER_X_POS : integer := 150;
  constant MORSE_MARKER_HALF_W : integer := 4;
  constant MORSE_MARKER_H : integer := 10;

  -- Precomputed base index for the marker X position 64/800 = 0.08 is our expected value, we use 85/1024 ≈ 0.0830078125 for better calculation efficiency
  constant MORSE_MARKER_BASE_IDX : integer := (MORSE_MARKER_X_POS * integer(MORSE_X_MAP_NUM)) / 2**integer(MORSE_X_MAP_SHIFT);

  -- Speed bounds
  constant SPEED_MIN : integer := 1;
  constant SPEED_MAX : integer := 16;

  -- Frame-delay shaping for scrolling (higher speed => smaller delay)
  constant MORSE_FRAME_DELAY_BASE : integer := 35;
  constant MORSE_FRAME_DELAY_SLOPE : integer := 2;
  constant MORSE_FRAME_DELAY_MIN : integer := 2;

  -- Speed UI layout
  constant SPEED_BAR_X0 : integer := 30;
  constant SPEED_BAR_Y0 : integer := 20;
  constant SPEED_BAR_W  : integer := 256; -- 16 levels * 16 px
  constant SPEED_BAR_H  : integer := 20;
  constant SPEED_BAR_TICK_PX : integer := 16;

  constant SPEED_DIGITS_X0 : integer := 300;
  constant SPEED_DIGITS_Y0 : integer := 20;
  constant SPEED_DIGIT_W   : integer := 25;
  constant SPEED_DIGIT_H   : integer := 40;
 
 
end package;
----------------------------------------------------------------------------------------------------
package body UIpack is

end package body;

