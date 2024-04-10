LIBRARY ieee;
USE ieee.numeric_bit.ALL;

ENTITY serial_out_tb IS
END serial_out_tb;

ARCHITECTURE behavior OF serial_out_tb IS
    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT serial_out
        GENERIC (
            POLARITY : BOOLEAN := TRUE;
            WIDTH : NATURAL := 8;
            PARITY : NATURAL := 1;
            STOP_BITS : NATURAL := 1
        );
        PORT (
            clock : IN BIT;
            reset : IN BIT;
            tx_go : IN BIT;
            tx_done : OUT BIT;
            data : IN bit_vector(WIDTH - 1 DOWNTO 0);
            serial_o : OUT BIT
        );
    END COMPONENT;

    COMPONENT serial_out2
        GENERIC (
            POLARITY : BOOLEAN := TRUE;
            WIDTH : NATURAL := 8;
            PARITY : NATURAL := 1;
            STOP_BITS : NATURAL := 1
        );
        PORT (
            clock : IN BIT;
            reset : IN BIT;
            tx_go : IN BIT;
            tx_done : OUT BIT;
            data : IN bit_vector(WIDTH - 1 DOWNTO 0);
            serial_o : OUT BIT
        );
    END COMPONENT;

    --Inputs
    SIGNAL clock : BIT := '0';
    SIGNAL reset : BIT := '0';
    SIGNAL tx_go : BIT := '0';
    SIGNAL data : bit_vector(7 DOWNTO 0);

    --Outputs
    SIGNAL tx_done : BIT;
    SIGNAL serial_o : BIT;
    -- Control
    SIGNAL finished : BIT := '0';
    CONSTANT half_period : TIME := 10 ns;

BEGIN

    dut : serial_out GENERIC MAP(
        POLARITY => TRUE,
        WIDTH => 8,
        PARITY => 1,
        STOP_BITS => 1
    )
    PORT MAP(
        clock => clock,
        reset => reset,
        tx_go => tx_go,
        tx_done => tx_done,
        data => data,
        serial_o => serial_o
    );

    clock <= NOT clock AFTER half_period WHEN finished /= '1' ELSE
        '0';
    test : PROCESS
    BEGIN
        ASSERT false REPORT "Inicio testes";

        data <= "11010101"; --Paridade 0
        reset <= '1';
        WAIT FOR 4 * half_period;
        reset <= '0';
        tx_go <= '1';
        WAIT UNTIL rising_edge(clock);

        WAIT UNTIL falling_edge(clock); --Amostra no meio do bit
        WAIT FOR 1 ns;
        ASSERT serial_o = '0'
        REPORT "Start Bit falhou";

        tx_go <= '0';

        FOR i IN data'reverse_range LOOP
            WAIT UNTIL falling_edge(clock);
            WAIT FOR 1 ns;
            ASSERT serial_o = data(i)
            REPORT "serial:" & BIT'image(serial_o) & ", esperado:" & BIT'image(data(i)) & "idx:" & INTEGER'image(i);
        END LOOP;

        WAIT UNTIL falling_edge(clock);
        WAIT FOR 1 ns;
        ASSERT serial_o = '0'
        REPORT "Teste Paridade Falhou";
        WAIT UNTIL falling_edge(clock);
        WAIT FOR 1 ns;
        ASSERT serial_o = '1'
        REPORT "Stop Bit falhou";
        WAIT FOR 1 ns;
        ASSERT tx_done = '1'
        REPORT "Done Falhou";

        REPORT "Fim teste transmissao inicial";

        WAIT FOR 10 * half_period;

        ASSERT tx_done = '1'
        REPORT "Done Deve se manter ligado";
        data <= "11010101"; --Paridade 0
        reset <= '1';
        WAIT FOR 4 * half_period;

        reset <= '0';
        tx_go <= '1';
        WAIT UNTIL rising_edge(clock);

        WAIT UNTIL falling_edge(clock); --Amostra no meio do bit
        WAIT FOR 1 ns;
        ASSERT serial_o = '0'
        REPORT "Start Bit falhou";

        FOR i IN data'reverse_range LOOP
            WAIT UNTIL falling_edge(clock);
            WAIT FOR 1 ns;
            ASSERT serial_o = data(i)
            REPORT "serial:" & BIT'image(serial_o) & ", esperado:" & BIT'image(data(i)) & "idx:" & INTEGER'image(i);
        END LOOP;

        WAIT UNTIL falling_edge(clock);
        WAIT FOR 1 ns;
        ASSERT serial_o = '0'
        REPORT "Teste Paridade Falhou";
        WAIT UNTIL falling_edge(clock);
        WAIT FOR 1 ns;
        ASSERT serial_o = '1'
        REPORT "Stop Bit falhou";

        REPORT "Fim teste reset e transmissao";
        WAIT FOR 10 * half_period;

        REPORT "Inicio teste metralhadora";

        data <= "11010101"; --Paridade 0
        reset <= '1';
        WAIT FOR 4 * half_period;

        reset <= '0';
        tx_go <= '1';
        WAIT UNTIL rising_edge(clock);

        FOR i IN 0 TO 2 LOOP
            WAIT UNTIL falling_edge(clock); --Amostra no meio do bit
            WAIT FOR 1 ns;
            ASSERT serial_o = '0'
            REPORT "Start Bit falhou";

            IF i = 2 THEN
                tx_go <= '0';
            END IF;

            FOR i IN data'reverse_range LOOP
                WAIT UNTIL falling_edge(clock);
                WAIT FOR 1 ns;
                ASSERT serial_o = data(i)
                REPORT "serial:" & BIT'image(serial_o) & ", esperado:" & BIT'image(data(i)) & "idx:" & INTEGER'image(i);
            END LOOP;

            WAIT UNTIL falling_edge(clock);
            WAIT FOR 1 ns;
            ASSERT serial_o = '0'
            REPORT "Teste Paridade Falhou";
            WAIT UNTIL falling_edge(clock);
            WAIT FOR 1 ns;
            ASSERT serial_o = '1'
            REPORT "Stop Bit falhou";
        END LOOP;
        REPORT "Fim teste metralhadora";
        WAIT FOR 10 * half_period;

        REPORT "Inicio teste swap data";

        data <= "00000000"; --Paridade 1
        reset <= '1';
        WAIT FOR 4 * half_period;

        reset <= '0';
        tx_go <= '1';
        WAIT UNTIL rising_edge(clock);
        WAIT UNTIL falling_edge(clock); --Amostra no meio do bit
        WAIT FOR 1 ns;
        ASSERT serial_o = '0'
        REPORT "Start Bit falhou";
        WAIT UNTIL falling_edge(clock); --Amostra no meio do bit
        WAIT FOR 1 ns;
        ASSERT serial_o = '0'
        REPORT "1 Bit falhou";
        WAIT UNTIL falling_edge(clock); --Amostra no meio do bit
        WAIT FOR 1 ns;
        ASSERT serial_o = '0'
        REPORT "2 Bit falhou";

        data <= "01111111"; -- Paridade 0

        WAIT UNTIL falling_edge(clock); --Amostra no meio do bit
        WAIT FOR 1 ns;
        ASSERT serial_o = '0'
        REPORT "3 Bit falhou";
        WAIT UNTIL falling_edge(clock); --Amostra no meio do bit
        WAIT FOR 1 ns;
        ASSERT serial_o = '0'
        REPORT "4 Bit falhou";
        WAIT UNTIL falling_edge(clock); --Amostra no meio do bit
        WAIT FOR 1 ns;
        ASSERT serial_o = '0'
        REPORT "5 Bit falhou";
        WAIT UNTIL falling_edge(clock); --Amostra no meio do bit
        WAIT FOR 1 ns;
        ASSERT serial_o = '0'
        REPORT "6 Bit falhou";
        WAIT UNTIL falling_edge(clock); --Amostra no meio do bit
        WAIT FOR 1 ns;
        ASSERT serial_o = '0'
        REPORT "7 Bit falhou";
        WAIT UNTIL falling_edge(clock); --Amostra no meio do bit
        WAIT FOR 1 ns;
        ASSERT serial_o = '0'
        REPORT "8 Bit falhou";
        WAIT UNTIL falling_edge(clock); --Amostra no meio do bit
        WAIT FOR 1 ns;
        ASSERT serial_o = '1'
        REPORT "Paridade Falhou";
        WAIT UNTIL falling_edge(clock); --Amostra no meio do bit
        WAIT FOR 1 ns;
        ASSERT serial_o = '1'
        REPORT "Stopbit Falhou";
        REPORT "Fim teste swap data";

        finished <= '1';
        WAIT;
    END PROCESS;
END behavior;