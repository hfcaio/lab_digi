-------------------------------------------------------------Unidade de Controle-------------------------------------------------------------
LIBRARY ieee;
USE ieee.numeric_bit.ALL;

ENTITY UC IS
    PORT (
        clock : IN BIT;
        reset, tx_go, tx_done : IN BIT;
        state_bit : OUT BIT
    );

END uc;

ARCHITECTURE behave_uc OF UC IS

    TYPE state IS (Swait, Ssend);
    SIGNAL current_state, next_state : state := Swait;
BEGIN

    PROCESS (clock)
    BEGIN
        IF (clock'event AND clock = '1') THEN
            current_state <= next_state;
        END IF;
    END PROCESS;

    next_state <= Swait WHEN (reset = '1') ELSE
        Ssend WHEN (tx_go = '1') ELSE
        next_state;

    PROCESS (current_state)
    BEGIN
        CASE current_state IS
            WHEN Swait =>
                state_bit <= '0';
            WHEN Ssend =>
                state_bit <= '1';
        END CASE;
    END PROCESS;
END behave_uc;

-------------------------------------------------------------Fluxo de Dados-----------------------------------------------------

LIBRARY ieee;
USE ieee.numeric_bit.ALL;

ENTITY FD IS
    GENERIC (
        POLARITY : BOOLEAN := true;
        width : NATURAL := 7;
        parity : NATURAL := 1;
        stop_bits : NATURAL := 1
    );
    PORT (
        clock : IN BIT;
        state : IN BIT;
        tx_done : OUT BIT;
        data : IN bit_vector(width - 1 DOWNTO 0);
        serial_o : OUT BIT
    );
END FD;

ARCHITECTURE behave_fd OF FD IS
    SIGNAL start_bit : BIT;
    SIGNAL counter : INTEGER := 0;
    SIGNAL all_data : bit_vector (width + stop_bits + parity DOWNTO 0); -- with start bit
    SIGNAL parity_bit : BIT := '0';
    SIGNAL backwards_data : bit_vector(width - 1 DOWNTO 0);
BEGIN
    start_bit <= '1' WHEN NOT polarity ELSE
        '0';

    PROCESS (state)
    BEGIN
        IF (state'event) AND (state = '1') THEN
            FOR i IN 0 TO width - 1 LOOP
                backwards_data(i) <= data(width - i - 1);
                parity_bit <= data(i) XOR parity_bit;
            END LOOP;
        ELSIF state = '0' THEN
            parity_bit <= '0';
        END IF;
    END PROCESS;

    all_data (width + parity + stop_bits DOWNTO stop_bits) <= start_bit & backwards_data & NOT parity_bit WHEN state = '1' ELSE
    (OTHERS => '1');

    all_data (stop_bits - 1 DOWNTO 0) <= (OTHERS => '1');

    PROCESS (clock)
    BEGIN
        IF (clock'event AND clock = '1') THEN

            IF state = '1' THEN
                serial_o <= all_data(counter);
            ELSE
                serial_o <= '1';
            END IF;

            IF state = '0' THEN
                counter <= width + stop_bits + parity;
                tx_done <= '0';
            ELSIF counter > 0 THEN
                counter <= counter - 1;
            ELSIF counter = 0 THEN
                tx_done <= '1';
            END IF;

        END IF;
    END PROCESS;
END behave_fd;

-------------------------------------------------------------serial_out-------------------------------------------------------------
LIBRARY ieee;
USE ieee.numeric_bit.ALL;

ENTITY serial_out IS
    GENERIC (
        POLARITY : BOOLEAN := true;
        width : NATURAL := 7;
        parity : NATURAL := 1;
        stop_bits : NATURAL := 1
    );
    PORT (
        clock : IN BIT;
        reset, tx_go : IN BIT;
        tx_done : OUT BIT;
        data : IN bit_vector(width - 1 DOWNTO 0);
        serial_o : OUT BIT
    );
END serial_out;

ARCHITECTURE behave_serial_out OF serial_out IS
    COMPONENT UC IS
        PORT (
            clock : IN BIT;
            reset, tx_go, tx_done : IN BIT;
            state_bit : OUT BIT
        );

    END COMPONENT;
    COMPONENT FD IS
        GENERIC (
            POLARITY : BOOLEAN := true;
            width : NATURAL := 7;
            parity : NATURAL := 1;
            stop_bits : NATURAL := 1
        );
        PORT (
            clock : IN BIT;
            state : IN BIT;
            tx_done : OUT BIT;
            data : IN bit_vector(width - 1 DOWNTO 0);
            serial_o : OUT BIT
        );
    END COMPONENT;

    SIGNAL inverted_clock, state, done : BIT := '0';
BEGIN
    inverted_clock <= NOT clock;
    tx_done <= done;
    FD_instance : FD GENERIC MAP(polarity, width, parity, stop_bits) PORT MAP(clock => inverted_clock, tx_done => done, state => state, data => data, serial_o => serial_o);
    UC_instance : UC PORT MAP(clock => clock, reset => reset, tx_go => tx_go, tx_done => done, state_bit => state);

END behave_serial_out;