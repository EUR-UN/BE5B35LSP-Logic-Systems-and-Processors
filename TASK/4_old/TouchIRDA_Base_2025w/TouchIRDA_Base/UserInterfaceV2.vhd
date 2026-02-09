-----------------------------------
-- User interface version V2.B (simplified).  
-- It separates the processing of user inputs, 
-- so we can simulate LCDlogicTask4 using LCDlogicTask4testbench.vhd.  
---------------------------------------------------------
library ieee, work;use ieee.std_logic_1164.all;use ieee.numeric_std.all;
use work.LCDpackV2.all;         -- VeekMT2_LCDgenV2 definitions
use work.TouchIRDApackV2.all;   -- Touch and IRDA modules
use work.UIpack.all;      -- user's definitions related to this solution

entity UserInterfaceV2 is
  generic(IRDA_REPEAT_WAIT_MS : natural := 500);
  -- IRDA_REPEAT_WAIT_MS parameter specifies the waiting time in ms 
  -- before sending the repetition of a pressed key on an IRDA remote control.
 
 port(IRDA_RXD         : in    std_logic      := '0'; -- VeekMT2 board pin: InfraRed sensor 
       TOUCH_INT_n      : in    std_logic      := '0'; -- VeekMT2 board pin: LCD screen interrupt announced new coordinates
       CLOCK_50         : in    std_logic      := '0'; -- VeekMT2 board pin: 50 MHz clock
       -- VeekMT2_LCDgenV2 generator output signals
       LCD_DCLK         : in    std_logic      := '0'; -- LCD data clock, 33 MHz exactly
       YEND_N           : in    std_logic      := '0'; -- '0' when the last yrow
       CLRN             : in    std_logic      := '0'; -- connect to VeekMT2_genV2 pin
       -- I2C bus of Touch Module
       TOUCH_I2C_SDA    : inout std_logic      := '0'; -- VeekMT2 board pin: I2C data
       TOUCH_I2C_SCL    : out   std_logic      := '0'; -- VeekMT2 board pin: I2C clock (cca 160 kHz) active only when sending data
       -- to LCD logic
       touchCoordinates : out   TouchDataSlv_t := (others => '0'); -- coordinates packed into std_logic_vector 
       commandStop        : out   std_logic:='0'; -- stop blinking
       -- to morse code
       MORSE_OUT       : out   std_logic      := '0';  -- Morse code output (not used in this version)
       MORSE_INDEX     : out   integer range 0 to 63 := 0; -- Current Morse code index
       CURRENT_SPEED  : out   integer range 0 to 15 := 5  -- Current speed
       ); 
end entity;

architecture rtl of UserInterfaceV2 is
  -- The touch screen data processing
  signal touchDataSlv      : TouchDataSlv_t                := (others => '0');
  signal RDY_N             : std_logic                     := '0'; --from VeekMT2_I2CTouchLCD
  -- IRDA RDY-ACK protocol signals
  signal RDY_command       : std_logic                     := '0'; -- RDY-ACK handshake signal
  signal CommandIsRepeated : std_logic                     := '0'; -- RDY_command repeated by remote module key
  signal ACK_Command       : std_logic                     := '0'; -- RDY-ACK handshake signal
  signal AddressCommand    : std_logic_vector(15 downto 0) := (others => '0'); -- received IRDA data
  -- AddressCommand(15 downto 8) part contains a constant value, the identification of IRDA remote control, 
  -- AddressCommand(7 downto 0) part contains the code of a pressed remote key

  -- Signals for Morse code control(shared with the process)
  signal s_morse_speed     : integer range 0 to 15 := 5; -- internal Morse code speed(default 5, Max 15)
  signal s_vStop         : std_logic := '0'; -- internal stop signal
  signal s_morse_current_index : integer range 0 to 63 := 0; -- internal current index only for YEND_N process

 begin
  -- Inserting the instance of the I2C bus module for LCD Touches
 iTouch : entity work.VeekMT2_I2CTouchLCD
          port map(CLOCK_50, LCD_DCLK, CLRN, RDY_N, touchDataSlv, TOUCH_INT_n, TOUCH_I2C_SDA, TOUCH_I2C_SCL);
    
	 touchCoordinates <= touchDataSlv;     -- we are copying them to LCDlogicTask4

  -- Inserting the instance of the IRDA module ----------------------------------
  iIRDA : entity work.VeekMT2_IRDAv2
          generic map(IRDA_REPEAT_WAIT_MS=>500)
          port map(LCD_DCLK, CLRN, IRDA_RXD, AddressCommand, RDY_Command, ACK_Command, CommandIsRepeated);
  MORSE_OUT        <= '0';
  MORSE_INDEX      <= s_morse_current_index;
  CURRENT_SPEED   <= s_morse_speed;

  -- !!! All memorizable values must be assigned only inside tests of rising/falling edge of a clock.
  iReadTouchIrda : process(LCD_DCLK, YEND_N)
  
    variable Command     : std_logic_vector(7 downto 0)  := (others => '0'); -- key code from IRDA
    -- variable Repeat      : std_logic                     := '0'; -- Command is repeated
    variable isRDYWaiting:boolean:=false; -- FSM state: true - we wait for RDY, false sending ACK
--------------------------------------------------------------------------------------------
    variable touchRecord : TouchRecord_t    := TouchRecord_ZERO; -- defined in TouchIRDApackV2
    variable isTouch, isTouchMem:boolean:=false; -- for testing of the beginning Touch
 ------------------------------------- 
   variable frame_cnt : integer:=0;  
   variable speed_delay : integer:=0;
  begin

iRedge:if rising_edge(LCD_DCLK) then
			 
         ACK_Command <= '0';   -- we assign the default value to acknowledge of RDY
  iCLRN: if CLRN = '0' then
			  Command         := (others => '0');  -- the code of pressed key
			  -- Repeat          := '0';              -- '1', when a key code is repeated by remote control
			  isRDYWaiting    := true;             -- we wait for RDY from IRDA module
			  touchRecord     := TouchRecord_ZERO; -- unpacked touchCoordinates
			  isTouchMem:=false; isTouch:=false;
        s_vStop <= '0'; -- default stop
        s_morse_speed <= 5; -- default speed
		  else -- if CLRN = '1' 
		  
		  touchRecord := to_TouchRecord(touchDataSlv); -- to_TouchRecord() is defined in TouchIRDApackV2.vhd
			isTouch := touchRecord.Count > 0; -- is any touch

      if (not isTouchMem and isTouch) then 
               -- 检测是否点击了 "Start/Stop" 区域 (假设在左上角附近)
               -- 你需要根据实际画图位置调整这些坐标 
               if inLimit(touchRecord.x1, BLINK_XLEFT, BLINK_SIZE) and inLimit(touchRecord.y1, BLINK_YTOP, BLINK_SIZE) then 
                  s_vStop <= not s_vStop; -- Toggle global signal
               end if;
               
               -- [Task D] 检测是否点击了 "加速" 区域 (假设在右上角)
               if inLimit(touchRecord.x1, 200, 200) and inLimit(touchRecord.y1, 160, 140) then
                   if s_morse_speed < 15 then s_morse_speed <= s_morse_speed + 1; end if;
               end if;
               
                -- [Task D] 检测是否点击了 "减速" 区域 (假设在右上角下方)
               if inLimit(touchRecord.x1, 400, 200) and inLimit(touchRecord.y1, 160, 140) then
                   if s_morse_speed > 1 then s_morse_speed <= s_morse_speed - 1; end if;
               end if;
           end if;

           
			isTouchMem:=isTouch; -- updating the last touch state memory

		  
 
 -- The iFSM part is the two state Finite State Machine for processing RDY-ACK handshake protocol
 
iFSM: case isRDYWaiting is -- for clarity, we used case instead of if-else
		    ---------------------------------------------------
			 when true=> -- we are waiting RDY
            iRDY: if RDY_command='1' then -- if we received RDY
              
              Command         := AddressCommand(7 downto 0); -- key code
                iCommand :  case to_integer(unsigned(Command)) is 
                     when 16#16# | 16#12# =>  s_vStop <= not s_vStop; -- Play/Power 键切换暂停
                    when 16#01# => -- 按键 '1' 加速
                        if s_morse_speed < 15 then s_morse_speed <= s_morse_speed + 1; end if;
                     when 16#02# => -- 按键 '2' 减速
                        if s_morse_speed > 1 then s_morse_speed <= s_morse_speed - 1; end if;
                     when others => null; 
                  end case iCommand;
				      isRDYWaiting   := false; -- now, we must acknowledge RDY receiving
            end if iRDY;
			 --------------------------------------------------	
          when false=>  -- the confirmation of RDY
            ACK_Command <= '1';  -- we confirm receiving RDY (required!) by sending ACK in '1'
            
				if RDY_command='0' then  -- our ACK was received
				   isRDYWaiting:=true; end if; -- we return to waiting for the next RDY
        -------------------------------------------------------------------------------
		  end case iFSM; 
			
     end if iCLRN; 
  
	end if iRedge;
 
  iFrameUpdate:  if falling_edge(YEND_N) then 
        commandStop <=  s_vStop; -- output the state to LCD over signal field
        if CLRN = '0' then
          s_morse_current_index <= 0; 
          frame_cnt := 0;
        else
        if s_vStop = '0' then 

            speed_delay := 35 - (s_morse_speed * 2);
            if speed_delay < 2 then speed_delay := 2; end if;

            if frame_cnt < speed_delay then
                frame_cnt := frame_cnt + 1;
            else
                frame_cnt := 0;
                
                if  s_morse_current_index >= 49 then
                    s_morse_current_index <= 0;
                else
                    s_morse_current_index <= s_morse_current_index + 1;
                end if;
            end if;
            
        else
            
            frame_cnt := 0;
        end if;
        end if;
    end if iFrameUpdate;
  end process;
	 
end architecture;
