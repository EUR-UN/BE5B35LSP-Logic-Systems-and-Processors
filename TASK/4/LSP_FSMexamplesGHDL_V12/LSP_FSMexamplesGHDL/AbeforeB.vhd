library ieee; use ieee.std_logic_1164.all;
entity AbeforeB is port(A, B, CLK, RESET: in std_logic;  Y: out std_logic);
end entity;
architecture rtl of AbeforeB is
signal debugIxState:integer:=0;
begin
	iFSM: process(CLK)
	type state_t is (stR, stS, stTU);-- enumerated type for FSM
	variable state   : state_t:=stR; -- The current state
	begin
	   iRedge:if (rising_edge(CLK)) then
			if RESET = '1' or A = '0' then state := stR; 
			else
			case state is -- The next state function
				when stR=>    if B='0' then state :=stS; end if;
				when stS=>    if B='1' then state :=stTU; end if;
				when stTU=>   null;
			end case;
			end if;
	   end if iRedge; -- output is a combinational function - no delay
	  if state=stTU then Y<='1'; else Y<='0'; end if;
      debugIxState<=state_t'Pos(state);
end process; end architecture;
