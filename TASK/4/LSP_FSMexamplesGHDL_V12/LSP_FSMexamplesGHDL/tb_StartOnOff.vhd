library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all;

entity tb_StartOnOff is end entity;

architecture rtl of tb_StartOnOff is

component StartOnOff is 
generic(FCLK: positive:=50000000; ON_MS:positive:=2000; OFF_MS:positive:=500);
port (   START, CLK : in std_logic;
         CLRN : in std_logic;      -- FSMs prefer synchronous clear
         RUN : out std_logic);
end component;
signal START, CLK, CLRN, RUNonOnly :  std_logic :='0';
signal RUNonOff :  std_logic :='0';
type starr_t is array(integer range <>) of TIME;
constant STARR:starr_t(0 to 7):=(1 sec, 1 sec, 
                         1 sec, 3 sec, 
						 1 sec, 250 ms, 
						 500 ms, 700 ms );
begin
    CLK <= not CLK after 500 us;  CLRN<='0', '1' after 2 ms;
	iSonOnly : entity work.StartOnOff(rtlOnOnly) 
	            generic map(1,2000,500)
	            port map(START,CLK,CLRN, RUNonOnly);
	iSonoff : entity work.StartOnOff(rtlOnOff) 
	            generic map(1,2000,500)
	            port map(START,CLK,CLRN, RUNonOff);

	process
	variable ix:integer range 0 to STARR'LENGTH:=0;
	begin
    	wait for STARR(ix);
		START<=not START;
        if ix<STARR'LENGTH-1 then ix:=ix+1; else ix:=0; end if;
   end process;
end architecture;
