LIBRARY IEEE;
USE ieee.std_logic_1164.ALL;

ENTITY somador_32 IS
    PORT (
        a, b : IN bit_vector(31 DOWNTO 0);
        enable : IN BIT;
        c : OUT bit_vector(31 DOWNTO 0);
        overflow : OUT BIT;
    );
END somador_32;

ARCHITECTURE Behave OF somador_32 IS
    SIGNAL sum : unsigned(32 DOWNTO 0);
BEGIN
    sum <= unsigned(a) + unsigned(b) WHEN enable = '1' ELSE
        (OTHERS => '0');
    c <= sum(31 DOWNTO 0);
    overflow <= sum(32);
END Behave;