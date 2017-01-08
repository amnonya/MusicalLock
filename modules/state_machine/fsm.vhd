-- Quartus II VHDL Template
-- Four-State Moore State Machine

-- A Moore machine's outputs are dependent only on the current state.
-- The output is written only when the state changes.  (State
-- transitions are synchronous.)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.std_logic_arith.all;
use work.utils.all;

entity fsm is
generic
(
    PASSWORD: ranged_count_array(0 to 6) :=
    (
        100, -100, 200, -200, 300, -300, 400
    )
);
port
(
    resetN: in std_logic;
    clk: in std_logic;
    valid: in std_logic;
    count: in ranged_count;
    unlock: out std_logic;
    blowup: out std_logic
);
end entity;

architecture arc_fsm of fsm is
    -- Build an enumerated type for the state machine
    type state_type is (idle, check_data, bomb, success);
    
    -- Register to hold the current state
    signal curr_state: state_type := idle;
    --signal next_state: state_type := idle;
    signal p: integer := 0;
begin

--proc_state_managment: process (clk)
--begin
--    if rising_edge(clk) then
--        curr_state <= next_state;
--    end if;
--end process;

proc_main: process (clk, resetN)
begin
    if resetN = '0' then
        curr_state <= idle;
    elsif rising_edge(clk) then
        case curr_state is
            when idle =>
                unlock <= '0';
                blowup <= '0';
                if valid = '1' then
                    curr_state <= check_data;
                else
                    curr_state <= idle;
                end if;
            when check_data =>
                unlock <= '0';
                blowup <= '0';
                if count = PASSWORD(p) then
                    if p = PASSWORD'length - 1 then
                        curr_state <= success;
                    else
                        curr_state <= idle;
                        p <= p + 1;
                    end if;
                else
                    curr_state <= bomb;
                end if;
            when bomb =>
                unlock <= '0';
                blowup <= '1';
                curr_state <= bomb;
            when success =>
                unlock <= '1';
                blowup <= '0';
                curr_state <= success;
            end case;
    end if;
end process;

end architecture;