library ieee; use ieee.std_logic_1164.all;use ieee.numeric_std.all;
entity AttrOfStateType is
    port ( CLK : in std_logic;
		   ixR,valR,predR,succR,leftR,rightR:out unsigned(2 downto 0):=(others=>'U'));
end;
architecture rtl of AttrOfStateType is
begin
 process(CLK)
 type state_t is (s0, s1, s2, s3, s4);
 variable state: state_t:=s0;
 function State2uint(st:state_t) return unsigned is
 begin  
     return to_unsigned(state_t'POS(st),3); -- order number of state
 end function;
 variable ix:unsigned(ixR'RANGE);
 begin
	if rising_edge(CLK) then 
	  ix:=State2uint(state); ixR<=ix; -- the order number
	  valR<=State2uint(state_t'VAL(to_integer(ix))); -- state from the order
	  if state/=s0 then predR<=State2uint(state_t'PRED(state)); end if; -- previous state
	  if state/=s4 then state:=state_t'SUCC(state); end if;
	  succR<=State2uint(state); -- next state
	end if;  
	leftR<=State2uint(state_t'LEFT);  -- leftmost state in the definition
	rightR<=State2uint(state_t'RIGHT); -- rightmost state in the definition
  end process;
end architecture;