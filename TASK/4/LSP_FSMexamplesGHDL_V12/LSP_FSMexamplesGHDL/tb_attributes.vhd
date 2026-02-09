library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all;

entity tb_attributes is end entity;

architecture rtl of tb_attributes is
component AttrOfStateType is
    port ( CLK : in std_logic;
		   ixR,valR,predR,succR,leftR,rightR:out unsigned(2 downto 0));
end component;
signal CLK :  std_logic :='0';
signal  ixR,valR,predR,succR,leftR,rightR:unsigned(2 downto 0);
begin
   CLK <= not CLK after 10 ns;  
   iAB : entity work.AttrOfStateType port map(CLK,ixR,valR,predR,succR,leftR,rightR);
end architecture;
