-------------------------------------------------------------
-- CTU-FFE Prague, Dept. of Control Eng. [Richard Susta], Published under GNU General Public License
-- LCDlogicTask4.vhd
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
	     RGBcolor : out RGB_t:=BLACK;  -- RGB color of pixel
         morse_index_in : in integer range 0 to 63 := 0;  -- current morse position
         current_speed_in : in integer range 1 to 16 := 5  -- playback speed
            );
end entity;

-- Basic LCD
architecture rtl of LCDlogicTask4 is
    -- Star and UI layout constants are shared in UIpack
   
   signal HS_rom_addr : std_logic_vector(14 downto 0);
   signal rom_q    : std_logic_vector(1 downto 0);
   signal MTEXT_rom_addr : std_logic_vector(13 downto 0);
   signal MTEXT_rom_q    : std_logic_vector(0 downto 0); -- 1 bit (black/white)

    signal s_draw_index_vec : unsigned(5 downto 0); -- send input to MorseYWZ
    signal s_draw_bit       : std_logic;            
    signal s_marker_index_vec : unsigned(5 downto 0);
    signal s_marker_bit       : std_logic;
    
  begin -- architecture
    -- H_Star ROM instance
     HSTAR_ROM : entity work.H_Star
      port map (
         clock   => LCD_DCLK,
         address => HS_rom_addr,
         q       => rom_q
      );

     Morse_TEXT_ROM: entity work.Morse_Text_YUANW
        port map (
         clock   => LCD_DCLK,
         address => MTEXT_rom_addr,
         q       => MTEXT_rom_q
      );
    MorseDrawer : entity work.MorseYWZ
      port map (
         X    => s_draw_index_vec, 
         Y    => s_draw_bit,       
         STOP => open     
      );
    MorseMarker : entity work.MorseYWZ
      port map (
         X    => s_marker_index_vec,
         Y    => s_marker_bit,
         STOP => open
      );



    -- [Task B] calc morse index: maps x to 0..63 range (ixMorse = x*M/2^N)
        p_MorseTextAddr : process(xcolumn, yrow, morse_index_in)
            variable base_idx : integer;
            variable final_idx : integer;
            variable img_x : integer;
            variable img_y : integer;
            variable Morse_TEXT_address : integer;
            variable x_wrap : integer;
        begin
            -- x*85/1024: maps 0..799 to ~0..66, close enough to 0..63
            base_idx := to_integer(xcolumn*MORSE_X_MAP_NUM)/2**integer(MORSE_X_MAP_SHIFT);
            -- Loop display
            final_idx := (base_idx + morse_index_in) mod 64;

            s_draw_index_vec <= to_unsigned(final_idx, 6);

            img_y := to_integer(yrow) - MORSE_TEXT_Y0;
            if img_y >= 0 and img_y < MORSE_TEXT_H then

                -- Avoid mod/div by 768 (Quartus would infer a divider).
                -- Wrap x into 0..MORSE_TEXT_W-1 using only compares and subtract.
                x_wrap := to_integer(xcolumn) + (morse_index_in*MORSE_SCROLL_STEP_X) - MORSE_SCROLL_X_BIAS;
                x_wrap := x_wrap + MORSE_TEXT_W; -- handle small negatives (e.g. -20)

                -- Subtract up to 3 times is enough here:
                -- x_wrap max ~ 1023 + 63*12 - 20 + 768 = 2527
                if x_wrap >= MORSE_TEXT_W then x_wrap := x_wrap - MORSE_TEXT_W; end if;
                if x_wrap >= MORSE_TEXT_W then x_wrap := x_wrap - MORSE_TEXT_W; end if;
                if x_wrap >= MORSE_TEXT_W then x_wrap := x_wrap - MORSE_TEXT_W; end if;

                img_x := x_wrap;
                Morse_TEXT_address := img_y*MORSE_TEXT_W + img_x;
                MTEXT_rom_addr <= std_logic_vector(to_unsigned(Morse_TEXT_address, MTEXT_rom_addr'length));
            else
                MTEXT_rom_addr <= (others => '0');
            end if;
        end process;

     p_MarkerIndex : process(morse_index_in)
        variable final_idx_m : integer;
    begin
        final_idx_m := (MORSE_MARKER_BASE_IDX + morse_index_in) mod 64;
        s_marker_index_vec <= to_unsigned(final_idx_m, 6);
    end process;


    -- Main LCD image process
    LSPimage : process(xcolumn,yrow,touchCoordinates,commandStop,current_speed_in, rom_q, MTEXT_rom_q, LCD_DE, s_draw_bit, s_marker_bit)
    
        variable RGB   : RGB_t     := BLACK; 
        variable x, y  : integer   := 0; -- integer xcolumn and yrow
        variable touchRecord                 : TouchRecord_t                     := TouchRecord_ZERO; -- Touch

        --draw touch circles variables copied from task 3
        variable dx1, dy1, dx2, dy2 : integer;
        variable in1, in2 : boolean;
        -- Star IMG variables
        variable hstar_x, hstar_y : integer;
        variable hstar_in : boolean;
        variable lstar_x, lstar_y : integer;
        variable lstar_in : boolean;
        variable rel_x, rel_y : integer;
        variable digit_val : integer; 


     begin                               
		  --------------------------------------------------------------------------------------------------------
        x := to_integer(xcolumn);   y := to_integer(yrow);          -- convert unsigned to integers
		  touchRecord := to_TouchRecord(touchCoordinates); -- to_TouchRecord() is defined in TouchIRDApackV2.vhd
        RGB := BLACK;
        ---------- Image from Task3 -------------------------
        -- draw background circles
        dx1 := x - CIRCLE_CX;
        dy1 := y - CIRCLE_CY_UPPER;
        dx2 := x - CIRCLE_CX;
        dy2 := y - CIRCLE_CY_LOWER;
        -- check inclusion in circles
        in1 := (dx1*dx1 + dy1*dy1 <= CIRCLE_R*CIRCLE_R);
        in2 := (dx2*dx2 + dy2*dy2 <= CIRCLE_R*CIRCLE_R);
        -- set colors based on circle inclusion
        if in1 and in2 then
            RGB := C_MIDDLE;
        elsif not (in1 and in2) and y < CIRCLE_UPPER_SPLIT_Y then
            RGB := C_UPPER;
        else
            RGB := C_LOWER;
        end if;
        
        ------------------------------------------------------------
        -- Check both stars and determine which ROM address to read
        hstar_x := x - HSTAR_X0;
        hstar_y := y - HSTAR_Y0;
        hstar_in := (hstar_x >= 0) and (hstar_x < IMG_W) and 
                    (hstar_y >= 0) and (hstar_y < IMG_H);
        
        lstar_x := x - LSTAR_X0;
        lstar_y := y - LSTAR_Y0;
        lstar_in := (lstar_x >= 0) and (lstar_x < IMG_W) and 
                    (lstar_y >= 0) and (lstar_y < IMG_H);
        
        -- Set ROM address
        if hstar_in then
            HS_rom_addr <= std_logic_vector(to_unsigned(hstar_y * IMG_W + hstar_x, HS_rom_addr'length));
        elsif lstar_in then
            -- Rotate L_Star 90 degrees clockwise: x' = y, y' = IMG_W-1-x
            HS_rom_addr <= std_logic_vector(to_unsigned((IMG_W - 1 - lstar_x) * IMG_W + lstar_y, HS_rom_addr'length));
        else
            HS_rom_addr <= (others => '0');
        end if;

        -- Draw stars with pulsating effect
        if (hstar_in or lstar_in) and rom_q /= "01" then
            -- Pulsating effect: controlled by Morse sync signal
            if s_marker_bit = '1' then
                RGB := Star_Parse(rom_q, is_lower => lstar_in);
            else
                RGB := OLIVE;
            end if;
        end if;


        -- [Task A] Start/Stop Button with play/pause icon
        if InLimit(x, BLINK_XLEFT, BLINK_SIZE) and InLimit(y, BLINK_YTOP, BLINK_SIZE) then
            rel_x := x - BLINK_XLEFT;
            rel_y := y - BLINK_YTOP;

            -- background color: yellow when playing, gray when stopped
            if commandStop = '1' then 
                RGB := GRAY;
            else 
                RGB := YELLOW;
            end if;

            -- icon
            if commandStop = '1' then
                -- pause icon two bars
                if ((rel_x > 20 and rel_x < 28) or (rel_x > 36 and rel_x < 44)) then
                    if rel_y > 15 and rel_y < 49 then
                        RGB := RED;
                    end if;
                end if;
            else
                -- play icon triangle
                if rel_x > 20 and rel_x < 54 then
                    if (rel_y > (15 + (rel_x - 20)/2)) and -- lower edge
                    (rel_y < (49 - (rel_x - 20)/2)) then -- upper edge
                        RGB := GREEN;
                    end if;
                end if;
            end if;
        end if;

        -- [Task B+C] Morse code area: text from ROM + dot-dash pattern below
        if (x > MORSE_TEXT_XLEFT and x < (MORSE_TEXT_XLEFT + MORSE_TEXT_W)) then
            -- [Task B] enlarged morse pattern (~96% LCD width)
            if (y > MORSE_DRAW_Y0 and y < (MORSE_DRAW_Y0 + MORSE_DRAW_H)) and s_draw_bit = '1' then 
                RGB := BLACK;            
            -- [Task C] scrolling text from Morse_Text ROM
            elsif (y >= MORSE_TEXT_Y0 and y < (MORSE_TEXT_Y0 + MORSE_TEXT_H)) and MTEXT_rom_q = "0" then 
                RGB := GREEN;  
            end if;
        end if;

        -- [Task C] Draw Marker Triangle at fixed position
        if (x >= MORSE_MARKER_X_POS - MORSE_MARKER_HALF_W) and (x <= MORSE_MARKER_X_POS + MORSE_MARKER_HALF_W) then
             if (y >= MORSE_DRAW_Y0 - MORSE_MARKER_H) and (y <= MORSE_DRAW_Y0) then
                 if (MORSE_DRAW_Y0 - y) >= abs(x - MORSE_MARKER_X_POS) then
                     RGB := RED; 
                 end if;
             end if;
        end if;

        -- [Task D] Draw Speed Bar
        if (x >= SPEED_BAR_X0) and (x < (SPEED_BAR_X0 + SPEED_BAR_W)) and (y >= SPEED_BAR_Y0) and (y < (SPEED_BAR_Y0 + SPEED_BAR_H)) then 
            RGB := WHITE;
            if (x - SPEED_BAR_X0) < (current_speed_in * SPEED_BAR_TICK_PX) then
                RGB := GREEN;
            end if;

            -- black lines every 16 pixels
            if ((x - SPEED_BAR_X0) mod SPEED_BAR_TICK_PX) = 0 then
                RGB := BLACK;
            end if;
        end if;

        -- [Task F] Draw Digital Numbers for Speed
        -- draw speed digits
        if (x >= SPEED_DIGITS_X0) and (x < (SPEED_DIGITS_X0 + 2*SPEED_DIGIT_W)) and (y >= SPEED_DIGITS_Y0) and (y < (SPEED_DIGITS_Y0 + SPEED_DIGIT_H)) then
            -- draw tens
            if current_speed_in >= 10 then
                if CheckSegment(1, x - SPEED_DIGITS_X0, y - SPEED_DIGITS_Y0) then RGB := FUCHSIA; end if;
            end if;
            -- draw units
            if current_speed_in >= 10 then --10 is not power of 2, so we do it manually
                digit_val := current_speed_in - 10;
            else
                digit_val := current_speed_in;
            end if;
            if CheckSegment(digit_val, x - (SPEED_DIGITS_X0 + SPEED_DIGIT_W), y - SPEED_DIGITS_Y0) then RGB := FUCHSIA; end if;
        end if;

		   ----- draw touch circles-------------------------------------------------------
	     if touchRecord.Count>0 and (x-touchRecord.x1)**2+(y-touchRecord.y1)**2<TCIRCLE**2 then RGB:=RED; end if;
	     if touchRecord.Count>1 and (x-touchRecord.x2)**2+(y-touchRecord.y2)**2<TCIRCLE**2 then RGB:=GREEN; end if;
        
        -- blanking area (Data Enable low)
        if LCD_DE = '0' then RGB := BLACK; end if;
        RGBcolor <= RGB;
        ---------------------------------------------------------------------------------------------------------------    
    end process;
-----------------------------------------------------------------------------------------------------------------


end architecture;

