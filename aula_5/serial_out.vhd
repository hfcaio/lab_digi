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

    next_state <= Swait WHEN (reset = '1') OR (tx_done = '1') ELSE
        Ssend WHEN (tx_go = '1');

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
    SIGNAL all_data : bit_vector (width + stop_bits DOWNTO 0);
    SIGNAL parity_bit : BIT := '0';
BEGIN
    start_bit <= '1' WHEN NOT polarity ELSE
        '0';

    PROCESS (data)
    BEGIN
        FOR i IN 0 TO width LOOP
            parity_bit <= data(i) XOR parity_bit;
        END LOOP;
    END PROCESS;

    all_data (width + stop_bits + parity DOWNTO stop_bits) <= start_bit & data & parity_bit WHEN state = '1' ELSE
    (OTHERS => '1');

    all_data (stop_bits - 1 DOWNTO 0) <= (OTHERS => '1');

    PROCESS (clock)
    BEGIN
        serial_o <= all_data(counter);
        IF state = '0' THEN
            counter <= 0;
        ELSE
            counter <= counter + 1;
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

    SIGNAL inverted_clock, state, done : BIT;
BEGIN
    inverted_clock <= NOT clock;

    FD_instance : FD GENERIC MAP(polarity, width, parity, stop_bits) PORT MAP(clock => inverted_clock, tx_done => done, state => state, data => data, serial_o => serial_o);
    UC_instance : UC PORT MAP(clock => clock, reset => reset, tx_go => tx_go, tx_done => done, state_bit => state);

END behave_serial_out;