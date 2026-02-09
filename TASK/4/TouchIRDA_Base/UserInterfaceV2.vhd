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
       commandStop        : out   std_logic:='0'); -- stop blinking
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

 begin
  -- Inserting the instance of the I2C bus module for LCD Touches
 iTouch : entity work.VeekMT2_I2CTouchLCD
          port map(CLOCK_50, LCD_DCLK, CLRN, RDY_N, touchDataSlv, TOUCH_INT_n, TOUCH_I2C_SDA, TOUCH_I2C_SCL);
    
	 touchCoordinates <= touchDataSlv;     -- we are copying them to LCDlogicTask4

  -- Inserting the instance of the IRDA module ----------------------------------
  iIRDA : entity work.VeekMT2_IRDAv2
          generic map(IRDA_REPEAT_WAIT_MS=>500)
          port map(LCD_DCLK, CLRN, IRDA_RXD, AddressCommand, RDY_Command, ACK_Command, CommandIsRepeated);

  -- !!! All memorizable values must be assigned only inside tests of rising/falling edge of a clock.
  iReadTouchIrda : process(LCD_DCLK, YEND_N)
  
    variable Command     : std_logic_vector(7 downto 0)  := (others => '0'); -- key code from IRDA
    variable Repeat      : std_logic                     := '0'; -- Command is repeated
    variable isRDYWaiting:boolean:=false; -- FSM state: true - we wait for RDY, false sending ACK
--------------------------------------------------------------------------------------------
    variable touchRecord : TouchRecord_t    := TouchRecord_ZERO; -- defined in TouchIRDApackV2
    variable isTouch, isTouchMem:boolean:=false; -- for testing of the beginning Touch
    variable vStop   : std_logic:='0';  -- variable storing the commandStop output value
 ------------------------------------- 
  begin
iRedge:if rising_edge(LCD_DCLK) then
			 
         ACK_Command <= '0';   -- we assign the default value to acknowledge of RDY
  iCLRN: if CLRN = '0' then
			  Command         := (others => '0');  -- the code of pressed key
			  Repeat          := '0';              -- '1', when a key code is repeated by remote control
			  isRDYWaiting    := true;             -- we wait for RDY from IRDA module
			  touchRecord     := TouchRecord_ZERO; -- unpacked touchCoordinates
			  isTouchMem:=false; isTouch:=false;
		  else -- if CLRN = '0' 
		  
		  touchRecord := to_TouchRecord(touchDataSlv); -- to_TouchRecord() is defined in TouchIRDApackV2.vhd
			  
			--******************************************************
			-- Here, we detect touches in our zones. 
			-- inLimit() function and the BLINK* and TCIRCLE constants are defined in Task4package.vhd
			------------------------------
         isTouch := touchRecord.Count > 0 -- is any touch
			          -- We increased the sensitive touch zones by finger sizes
              and inLimit(touchRecord.x1, BLINK_XLEFT-TCIRCLE, BLINK_SIZE+2*TCIRCLE) 
				  and inLimit(touchRecord.y1, BLINK_YTOP-TCIRCLE,  BLINK_SIZE+2*TCIRCLE); 
			-- we detect a new touch in the chosen area
			if(not isTouchMem and isTouch) then vStop:=not vStop; end if; 
           
			isTouchMem:=isTouch; -- updating the last touch state memory
			--******************************************************
		  
 
 -- The iFSM part is the two state Finite State Machine for processing RDY-ACK handshake protocol
 
iFSM: case isRDYWaiting is -- for clarity, we used case instead of if-else
		    ---------------------------------------------------
			 when true=> -- we are waiting RDY
            iRDY: if RDY_command='1' then -- if we received RDY
              
              Command         := AddressCommand(7 downto 0); -- key code
              Repeat          := CommandIsRepeated; -- IRDA module announces then key code i repeated

				  --******************************************************
				  -- Here, we are storing data of the received command
           iCommand : case to_integer(unsigned(Command)) is 
		              -- Note: numeric_base#number# literals are defined only for integers   
                    when 16#16# | 16#12# => vStop := not vStop; -- IRDA keys play and on/off
						  
                    when others => null;  -- no command yet
                 end case iCommand;
					--******************************************************  
				  
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
 
 -- the commandStop value will be stable for the whole frame
   if falling_edge(YEND_N) then commandStop <=  vStop; -- to LCDLogicTask4
   end if;
  end process;
	 
end architecture;
