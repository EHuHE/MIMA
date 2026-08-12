library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.all;

entity tb_sb is
end entity;

architecture test of tb_sb is
    signal input_value : std_logic_vector(5 downto 0) := (others => '0');
    signal output_value : std_logic_vector(5 downto 0);
    type truth_table_type is array (0 to 63) of natural range 0 to 63;
    constant expected : truth_table_type := (
        16#00#, 16#36#, 16#30#, 16#0d#, 16#0f#, 16#12#, 16#35#, 16#23#,
        16#19#, 16#3f#, 16#2d#, 16#34#, 16#03#, 16#14#, 16#29#, 16#21#,
        16#3b#, 16#24#, 16#02#, 16#22#, 16#0a#, 16#08#, 16#39#, 16#25#,
        16#3c#, 16#13#, 16#2a#, 16#0e#, 16#32#, 16#1a#, 16#3a#, 16#18#,
        16#27#, 16#1b#, 16#15#, 16#11#, 16#10#, 16#1d#, 16#01#, 16#3e#,
        16#2f#, 16#28#, 16#33#, 16#38#, 16#07#, 16#2b#, 16#2c#, 16#26#,
        16#1f#, 16#0b#, 16#04#, 16#1c#, 16#3d#, 16#2e#, 16#05#, 16#31#,
        16#09#, 16#06#, 16#17#, 16#20#, 16#1e#, 16#0c#, 16#37#, 16#16#
    );
begin
    dut : entity work.SB
        port map (input => input_value, output => output_value);

    stimulus : process
    begin
        for index in expected'range loop
            input_value <= std_logic_vector(to_unsigned(index, input_value'length));
            wait for 1 ns;
            assert to_integer(unsigned(output_value)) = expected(index)
                report "S-box mismatch at input " & integer'image(index)
                severity failure;
        end loop;
        report "All 64 S-box vectors passed" severity note;
        stop;
        wait;
    end process;
end architecture;
