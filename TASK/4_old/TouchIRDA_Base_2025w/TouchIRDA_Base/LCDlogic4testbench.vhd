-- --------------------------------------------------------
-- -- The entity is intended only for using in testbenchV2_ControlPanel.vhd only
-- -- It replaces UserInterface by simulating its outputs
-- -------------------------------------------------------------------------
-- library ieee, work; use ieee.std_logic_1164.all; use ieee.numeric_std.all; 
-- use work.LCDpackV2.all; 
-- use work.TouchIRDApackV2.all; -- package for Touch and IRDA
-- use work.UIpack.all; -- definitiona releated to this ControlPanel solution

-- entity LCDlogic4testbench is 
--     port(xcolumn  : in  xy_t; -- x-coordinate of pixel (column index)
--          yrow     : in  xy_t; -- y-coordinate of pixel (row index)
--          XEND_N   : in  std_logic; -- '0' only when xcolumn=1023, otherwise '1', f=32227 Hz= 33e6/1024 
--          YEND_N   : in  std_logic; -- '0' only when yrow=524, otherwise '1', f=61.384 Hz = 33e6/(1024*525)
--          LCD_DE   : in  std_logic; -- DataEnable control signal of LCD controller
--          LCD_DCLK : in  std_logic; -- LCD data clock, exactly 33 MHz
--          RGBcolor : out RGB_t);         --  color data type RGB_t = std_logic_vector(23 downto 0), defined in LCDpackage
-- end entity;

-- architecture rtl OF LCDlogic4testbench IS 

-- component LCDlogicTask4 is
--     generic(IsTestbench:boolean:=FALSE);
--     port(xcolumn  : in  xy_t      := XY_ZERO; -- x-coordinate of pixel (column index)
--          yrow     : in  xy_t      := XY_ZERO; -- y-coordinate of pixel (row index)
--          XEND_N   : in  std_logic := '0'; -- '0' only when xcolumn=1023, otherwise '1', f=32227 Hz= 33e6/1024 
--          YEND_N   : in  std_logic := '0'; -- '0' only when yrow=524, otherwise '1', f=61.384 Hz = 33e6/(1024*525)
--          LCD_DE   : in  std_logic := '0'; -- DataEnable control signal of LCD controller
--          LCD_DCLK : in  std_logic := '0'; -- LCD data clock, exactly 33 MHz
--          touchCoordinates : in   TouchDataSlv_t := (others => '0'); -- coordinates packet to std_logic_vector 
--          commandStop        : in  std_logic:='0'; -- '1' if stopped
--          RGBcolor : out RGB_t:=BLACK);
-- end component;

-- signal touchCoordinates_s :  TouchDataSlv_t:=(others=>'0');
-- signal commandStop_s :  std_logic:='0';

-- begin 
--    -- we inserted the instance of LCDlogicTask4
-- iLogic : LCDlogicTask4
--     generic map(IsTestbench=>true)
--     port map(xcolumn=>xcolumn,  yrow=>yrow,  XEND_N=>XEND_N, YEND_N=>YEND_N,  LCD_DE=>LCD_DE, LCD_DCLK=>LCD_DCLK,
--              touchCoordinates=>touchCoordinates_s,   commandStop=>commandStop_s,
--              RGBcolor=>RGBcolor);         

--  -- we substitute UserInterface by generating its outputs

-- -- testGenerator : process(YEND_N)               
-- --    variable tr:TouchRecord_t:=TouchRecord_ZERO;
-- --    variable cntrSimStep:integer range 0 to 31;  -- for generating test signals  
-- --  begin
-- --       if falling_edge(YEND_N) then -- YEND_N='0' in the last row of LCD frames
-- --         -- At the beginning of the simulation, we emulate one touch only.
-- -- 		  tr.count:=1; tr.x1:=(cntrSimStep+1)*25; tr.y1:=(cntrSimStep+1)*15;

-- --         -- In the middle, we add the second touch
-- -- 		  if cntrSimStep>16 then tr.count:=2; tr.x2:=tr.x1/2; tr.y2:=LCD_HEIGHT-tr.y1/2;  end if;
        
-- -- 		  -- We increment the simulation counter for 32 LCD frames
-- -- 		  if cntrSimStep<31 then cntrSimStep:=cntrSimStep+1; end if;
       
-- -- 		 -- We have copied the following expression from UserInterfaceV2.vhd
-- --  	     if InLimit(tr.x1,BLINK_XLEFT-TCIRCLE,BLINK_SIZE+2*TCIRCLE) 
-- -- 				  and InLimit(tr.y1,BLINK_YTOP-TCIRCLE,BLINK_SIZE+2*TCIRCLE) then
-- --  	         commandStop_s<='1';  else   commandStop_s<='0';
-- --  	     end if;

-- -- 		end if; -- if falling_edge(YEND_N)
		
-- -- 	  touchCoordinates_s<=to_TouchDataSlv(tr); -- pack tr of TouchRecord_t type to std_logic_vector 
-- --   end process;
-- testGenerator : process(YEND_N)                
--    variable tr : TouchRecord_t := TouchRecord_ZERO;
--    variable cntrSimStep : integer range 0 to 63 := 0; -- 稍微加大一点仿真步数
--  begin
--       if falling_edge(YEND_N) then 
--         -- 1. 每一帧开始先默认“没触摸” (松手状态)
--         tr := TouchRecord_ZERO; 

--         -- 2. 定义触摸剧本：模拟点击“加速”按钮
--         -- 你的加速逻辑是检测上升沿(not isTouchMem and isTouch)，所以必须有“按-松-按”的过程

--         -- [第二次点击] 在第 15 帧再次按下
-- if cntrSimStep = 2 then 
--             tr.count := 1; 
--             tr.x1 := 400;  -- 中间位置 X
--             tr.y1 := 240;  -- 中间位置 Y
--         end if;
--                if cntrSimStep = 5  then 
--             tr.count := 1; 
--             tr.x1 := 750; 
--             tr.y1 := 50; 
--         end if;
--         -- [动作 B] 在第 6 帧：再次点击中间 Start/Stop 按钮
--         -- 预期效果：如果是暂停状态，会恢复运行
--         if cntrSimStep = 6 then 
--             tr.count := 1; 
--             tr.x1 := 400; 
--             tr.y1 := 240; 
--         end if;
--                if cntrSimStep = 7  then 
--             tr.count := 1; 
--             tr.x1 := 750; 
--             tr.y1 := 50; 
--         end if;
--         if cntrSimStep = 15  then 
--             tr.count := 1; 
--             tr.x1 := 750; 
--             tr.y1 := 50; 
--         end if;
        
--         -- [第三次点击] 在第 25 帧再次按下
--         if cntrSimStep = 25 then 
--             tr.count := 1; 
--             tr.x1 := 750; 
--             tr.y1 := 50; 
--         end if;

--         -- 3. 仿真计数器递增
--         if cntrSimStep < 63 then 
--             cntrSimStep := cntrSimStep + 1; 
--         end if;
        
-- -- 4. 模拟 commandStop 信号 
--         -- 注意：在 Testbench 中，我们需要根据触摸来反转这个信号，才能模拟 UI 的行为
--         -- 否则 LCDlogicTask4 接收到的 commandStop_s 永远是 0，你就看不到红竖线了。
--         -- 这里我们加一个简易的翻转逻辑：
--         if (cntrSimStep = 3) then -- 第2帧点完，第3帧生效变 Stop
--              commandStop_s <= '1'; 
--         elsif (cntrSimStep = 7) then -- 第6帧点完，第7帧生效变 Start
--              commandStop_s <= '0';
--         end if;

--         -- 5. 输出坐标给 LCDlogicTask4
--         touchCoordinates_s <= to_TouchDataSlv(tr); 
        
--   end if; -- falling_edge
--  end process;
-- end architecture;
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

-- Component 声明必须与 LCDlogicTask4.vhd 完全一致
component LCDlogicTask4 is
    generic(IsTestbench:boolean:=FALSE);
    port(xcolumn  : in  xy_t      := XY_ZERO; 
         yrow     : in  xy_t      := XY_ZERO; 
         XEND_N   : in  std_logic := '0'; 
         YEND_N   : in  std_logic := '0'; 
         LCD_DE   : in  std_logic := '0'; 
         LCD_DCLK : in  std_logic := '0'; 
         touchCoordinates : in   TouchDataSlv_t := (others => '0'); 
         commandStop        : in  std_logic:='0'; 
         RGBcolor : out RGB_t:=BLACK;
         -- 新增端口
         morse_in : in std_logic := '0';
         morse_index_in : in integer range 0 to 63 := 0;
         current_speed_in : in integer range 1 to 15 := 5
         );
end component;

signal touchCoordinates_s :  TouchDataSlv_t:=(others=>'0');
signal commandStop_s :  std_logic:='0';

-- [修正点] 信号声明必须加上 range 约束，与端口完全匹配！
signal s_sim_index : integer range 0 to 63 := 0;
signal s_sim_speed : integer range 1 to 15 := 5;

begin 
   -- 实例化
   iLogic : LCDlogicTask4
    generic map(IsTestbench=>true)
    port map(xcolumn=>xcolumn,  yrow=>yrow,  XEND_N=>XEND_N, YEND_N=>YEND_N,  
             LCD_DE=>LCD_DE, LCD_DCLK=>LCD_DCLK,
             touchCoordinates=>touchCoordinates_s,   
             commandStop=>commandStop_s,
             RGBcolor=>RGBcolor,
             -- 连接模拟信号
             morse_in => '1', -- 让方块底色常亮(或者你想闪烁也可以写逻辑)
             morse_index_in => s_sim_index,
             current_speed_in => s_sim_speed
             );          

 -- 测试生成器
 testGenerator : process(YEND_N)                
    variable tr : TouchRecord_t := TouchRecord_ZERO;
    variable cntrSimStep : integer range 0 to 63 := 0; 
  begin
       if falling_edge(YEND_N) then 
         tr := TouchRecord_ZERO; 

         -- [模拟逻辑 1] 让摩尔斯码滚动 (每帧 +1)
         if commandStop_s = '0' then 
             if s_sim_index < 63 then
                 s_sim_index <= s_sim_index + 1;
             else
                 s_sim_index <= 0;
             end if;
         end if;

         -- [模拟逻辑 2] 定义触摸剧本
         
         -- Frame 2: 点击中间 (暂停)
         if cntrSimStep = 2 then 
             tr.count := 1; tr.x1 := 400; tr.y1 := 240; 
             commandStop_s <= '1'; -- 模拟 UI 变成了停止状态
         end if;

         -- Frame 6: 点击中间 (恢复)
         if cntrSimStep = 6 then 
             tr.count := 1; tr.x1 := 400; tr.y1 := 240; 
             commandStop_s <= '0'; -- 模拟 UI 恢复运行
         end if;
         
         -- Frame 15: 点击右上角 (加速)
         if cntrSimStep = 9 then 
             tr.count := 1; tr.x1 := 650; tr.y1 := 50; 
             if s_sim_speed < 10 then s_sim_speed <= s_sim_speed + 5; end if; 
         end if;

                  -- Frame 15: 点击右上角 (加速)
         if cntrSimStep = 12 then 
             tr.count := 1; tr.x1 := 650; tr.y1 := 50; 
             if s_sim_speed < 10 then s_sim_speed <= s_sim_speed + 5; end if; 
         end if;

                  -- Frame 15: 点击右上角 (加速)
         if cntrSimStep = 15 then 
             tr.count := 1; tr.x1 := 650; tr.y1 := 50; 
             if s_sim_speed < 10 then s_sim_speed <= s_sim_speed + 5; end if; 
         end if;

         -- 步数计数
         if cntrSimStep < 63 then 
             cntrSimStep := cntrSimStep + 1; 
         end if;
         
         touchCoordinates_s <= to_TouchDataSlv(tr); 
         
   end if; -- falling_edge
  end process;

end architecture;