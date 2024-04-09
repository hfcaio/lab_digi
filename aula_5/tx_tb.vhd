LIBRARY ieee;
USE ieee.numeric_bit.ALL;

entity serial_out_tb is
end serial_out_tb;

architecture behavior of serial_out_tb is 
    -- Component Declaration for the Unit Under Test (UUT)
    component serial_out
    generic (
        POLARITY  : boolean := TRUE;
        WIDTH     : natural := 8;
        PARITY    : natural := 1;
        STOP_BITS : natural := 1
    );
    port (
        clock    : in  bit;
        reset    : in  bit;
        tx_go    : in  bit;
        tx_done  : out bit;
        data     : in  bit_vector(WIDTH-1 downto 0);
        serial_o : out bit
    );
    end component;

    component serial_out2
    generic (
        POLARITY  : boolean := TRUE;
        WIDTH     : natural := 8;
        PARITY    : natural := 1;
        STOP_BITS : natural := 1
    );
    port (
        clock    : in  bit;
        reset    : in  bit;
        tx_go    : in  bit;
        tx_done  : out bit;
        data     : in  bit_vector(WIDTH-1 downto 0);
        serial_o : out bit
    );
    end component;

    --Inputs
    signal clock : bit := '0';
    signal reset : bit := '0';
    signal tx_go : bit := '0';
    signal data : bit_vector(7 downto 0);

    --Outputs
    signal tx_done  : bit;
    signal serial_o : bit;
    

    -- Control
    signal finished: bit := '0';
    constant half_period : time := 10 ns;

begin

    dut: serial_out generic map (
            POLARITY  => TRUE,
            WIDTH     => 8,
            PARITY    => 1,
            STOP_BITS => 1
        )
        port map (
            clock    => clock,
            reset    => reset,
            tx_go    => tx_go,
            tx_done  => tx_done,
            data     => data,
            serial_o => serial_o
        );

    clock <= not clock after half_period when finished /= '1' else '0';


    test: process
    begin
        assert false report "Inicio testes";
        
        data  <= "11010101"; --Paridade 0
        reset <= '1';
        wait for 4*half_period;  
        reset <= '0'; 
        tx_go <= '1';
        wait until rising_edge(clock);

        wait until falling_edge(clock); --Amostra no meio do bit
        assert serial_o = '0'
        report "Start Bit falhou";

        tx_go <= '0';

        for i in data'reverse_range loop
            wait until falling_edge(clock);
            assert serial_o = data(i)
            report "serial:" & bit'image(serial_o) & ", esperado:" &bit'image(data(i))&"idx:"&integer'image(i);
        end loop;

        wait until falling_edge(clock);
        assert serial_o = '0'
        report "Teste Paridade Falhou";

        
        wait until falling_edge(clock);
        assert serial_o = '1'
        report "Stop Bit falhou";
        assert tx_done = '1'
        report "Done Falhou";

        report "Fim teste transmissao inicial";

        wait for 10*half_period;

        assert tx_done = '1'
        report "Done Deve se manter ligado";
        

        data  <= "11010101"; --Paridade 0
        reset <= '1';
        wait for 4*half_period;  
        
        reset <= '0'; 
        tx_go <= '1';
        wait until rising_edge(clock);

        wait until falling_edge(clock); --Amostra no meio do bit
        assert serial_o = '0'
        report "Start Bit falhou";

        for i in data'reverse_range loop
            wait until falling_edge(clock);
            assert serial_o = data(i)
            report "serial:" & bit'image(serial_o) & ", esperado:" &bit'image(data(i))&"idx:"&integer'image(i);
        end loop;

        wait until falling_edge(clock);
        assert serial_o = '0'
        report "Teste Paridade Falhou";
        wait until falling_edge(clock);
        assert serial_o = '1'
        report "Stop Bit falhou";

        report "Fim teste reset e transmissao";


        wait for 10*half_period;

        report "Inicio teste metralhadora";

        data  <= "11010101"; --Paridade 0
        reset <= '1';
        wait for 4*half_period;  
        
        reset <= '0'; 
        tx_go <= '1';
        wait until rising_edge(clock);

        for i in 0 to 2 loop
            wait until falling_edge(clock); --Amostra no meio do bit
            assert serial_o = '0'
            report "Start Bit falhou";

            if i = 2 then
                tx_go <= '0';
            end if;

            for i in data'reverse_range loop
                wait until falling_edge(clock);
                assert serial_o = data(i)
                report "serial:" & bit'image(serial_o) & ", esperado:" &bit'image(data(i))&"idx:"&integer'image(i);
            end loop;

            wait until falling_edge(clock);
            assert serial_o = '0'
            report "Teste Paridade Falhou";
            wait until falling_edge(clock);
            assert serial_o = '1'
            report "Stop Bit falhou";
        end loop;


        report "Fim teste metralhadora";


        wait for 10*half_period;

        report "Inicio teste swap data";

        data  <= "00000000"; --Paridade 1
        reset <= '1';
        wait for 4*half_period;  
        
        reset <= '0'; 
        tx_go <= '1';
        wait until rising_edge(clock);
        wait until falling_edge(clock); --Amostra no meio do bit
        assert serial_o = '0'
        report "Start Bit falhou";
        wait until falling_edge(clock); --Amostra no meio do bit
        assert serial_o = '0'
        report "1 Bit falhou";
        wait until falling_edge(clock); --Amostra no meio do bit
        assert serial_o = '0'
        report "2 Bit falhou";

        data <= "01111111"; -- Paridade 0

        wait until falling_edge(clock); --Amostra no meio do bit
        assert serial_o = '0'
        report "3 Bit falhou";
        wait until falling_edge(clock); --Amostra no meio do bit
        assert serial_o = '0'
        report "4 Bit falhou";
        wait until falling_edge(clock); --Amostra no meio do bit
        assert serial_o = '0'
        report "5 Bit falhou";
        wait until falling_edge(clock); --Amostra no meio do bit
        assert serial_o = '0'
        report "6 Bit falhou";
        wait until falling_edge(clock); --Amostra no meio do bit
        assert serial_o = '0'
        report "7 Bit falhou";
        wait until falling_edge(clock); --Amostra no meio do bit
        assert serial_o = '0'
        report "8 Bit falhou";
        wait until falling_edge(clock); --Amostra no meio do bit
        assert serial_o = '1'
        report "Paridade Falhou";
        wait until falling_edge(clock); --Amostra no meio do bit
        assert serial_o = '1'
        report "Stopbit Falhou";


        report "Fim teste swap data";

        finished <= '1';
        wait;
    end process;


end behavior;