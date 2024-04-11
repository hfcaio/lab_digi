LIBRARY ieee;
USE ieee.numeric_bit.ALL;

ENTITY clock_divisor IS
    PORT (
        clock_in : IN BIT;
        factor : IN INTEGER;
        clock_out : OUT BIT;
    );
END clock_divisor;

ARCHITECTURE behave_clock_divisor OF clock_divisor IS
    SIGNAL counter : INTEGER := 0;
BEGIN
    PROCESS (clock_in)
    BEGIN
        IF counter >= factor THEN
            counter <= 0;
            clock_out <= '1';
        ELSE
            counter <= counter + 1;
            clock_out <= '0';
        END IF;
    END PROCESS;
END behave_clock_divisor;