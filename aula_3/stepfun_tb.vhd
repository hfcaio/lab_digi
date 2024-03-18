ENTITY testbench IS
END testbench;

ARCHITECTURE behave OF testbench IS
    COMPONENT stepfun IS
        PORT (
            ai, bi, ci, di, ei, fi, gi, hi : IN bit_vector(31 DOWNTO 0);
            kpw : IN bit_vector(31 DOWNTO 0);
            ao, bo, co, do, eo, fo, go, ho : OUT bit_vector(31 DOWNTO 0)
        );
    END COMPONENT;

    TYPE pattern IS RECORD
        x : bit_vector(7 DOWNTO 0);
        ao, eo, ho : bit_vector(31 DOWNTO 0);
    END RECORD;

    TYPE pattern_array IS ARRAY (NATURAL RANGE <>) OF pattern;
    CONSTANT test_case : pattern_array := (
    ("11111111", "11111111111111111111111111111001", "11111111111111111111111111111011", "11111111111111111111111111111111"),
        ("00000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000"),
        ("10101010", "01010101010101010101010101010001", "01010101010101010101010101010010", "10101010101010101010101010101010"),
        ("01010101", "10101010101010101010101010101000", "10101010101010101010101010101001", "01010101010101010101010101010101"),
        ("01110100", "00011011000110110001101100011000", "00110111001101110011011100110101", "01110100011101000111010001110100")
    );

    SIGNAL ai : bit_vector(31 DOWNTO 0);
    SIGNAL ao, bo, co, do, eo, fo, go, ho : bit_vector(31 DOWNTO 0);

BEGIN
    dut : stepfun PORT MAP(ai, ai, ai, ai, ai, ai, ai, ai, ai, ao, bo, co, do, eo, fo, go, ho);

    stimulus : PROCESS
    BEGIN
        FOR i IN test_case'RANGE LOOP
            WAIT FOR 1 ns;
            ai <= test_case(i).x & test_case(i).x & test_case(i).x & test_case(i).x;
            WAIT FOR 1 ns;
            ASSERT (ao /= test_case(i).ao AND eo /= test_case(i).eo AND ho /= test_case(i).ho)
            REPORT INTEGER'image(i) & ".ok" SEVERITY note;
            ASSERT (ao = test_case(i).ao OR eo = test_case(i).eo OR ho = test_case(i).ho)
            REPORT INTEGER'image(i) & ".error" SEVERITY error;
        END LOOP;

        ASSERT false REPORT "simulation ended" SEVERITY note;
        WAIT;
    END PROCESS;
END behave;