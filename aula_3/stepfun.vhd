-------------------------------------------------------------------------------
-- Author: Guilherme Fortunato Miranda
-- Module Name: main_functions_exp2
-- Description:
-- VHDL module to convert from hex (4b) to 7-segment
-------------------------------------------------------------------------------
LIBRARY IEEE;
USE ieee.numeric_std.ALL;

ENTITY somador_32 IS
    PORT (
        a, b : IN bit_vector(31 DOWNTO 0);
        enable : IN BIT;
        c : OUT bit_vector(31 DOWNTO 0);
        overflow : OUT BIT
    );
END somador_32;

ARCHITECTURE Behave OF somador_32 IS
    SIGNAL sum : unsigned(32 DOWNTO 0);
    SIGNAL a_extended, b_extended : bit_vector(32 DOWNTO 0);
BEGIN
    a_extended <= '0' & a(31 DOWNTO 0);
    b_extended <= '0' & b(31 DOWNTO 0);
    sum <= unsigned(TO_STDLOGICVECTOR(a_extended)) + unsigned(TO_STDLOGICVECTOR(b_extended)) WHEN enable = '1' ELSE
        (OTHERS => '0');
    c <= TO_BITVECTOR(STD_LOGIC_VECTOR(sum(31 DOWNTO 0)));
    overflow <= TO_BIT(sum(32));
END Behave;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY stepfun IS
    PORT (
        ai, bi, ci, di, ei, fi, gi, hi : IN bit_vector(31 DOWNTO 0);
        kpw : IN bit_vector(31 DOWNTO 0);
        ao, bo, co, do, eo, fo, go, ho : OUT bit_vector(31 DOWNTO 0)
    );
END stepfun;

ARCHITECTURE Behave OF stepfun IS
    COMPONENT somador_32 IS
        PORT (
            a, b : IN bit_vector(31 DOWNTO 0);
            enable : IN BIT;
            c : OUT bit_vector(31 DOWNTO 0);
            overflow : OUT BIT
        );
    END COMPONENT;

    COMPONENT ch IS
        PORT (
            x, y, z : IN bit_vector(31 DOWNTO 0);
            q : OUT bit_vector(31 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT maj IS
        PORT (
            x, y, z : IN bit_vector(31 DOWNTO 0);
            q : OUT bit_vector(31 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT sum0 IS
        PORT (
            x : IN bit_vector(31 DOWNTO 0);
            q : OUT bit_vector(31 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT sum1 IS
        PORT (
            x : IN bit_vector(31 DOWNTO 0);
            q : OUT bit_vector(31 DOWNTO 0)
        );
    END COMPONENT;

    SIGNAL sum1_output, sum2, sum3, sum4, sum5, sum6 : bit_vector(31 DOWNTO 0);
    SIGNAL overflow1, overflow2, overflow3, overflow4, overflow5, overflow6 : BIT;
    SIGNAL ch_out, sum1_out, maj_out, sum0_out : bit_vector(31 DOWNTO 0);

BEGIN
    sum1_port : somador_32 PORT MAP(hi, kpw, '1', sum1_output, overflow1);
    sum2_port : somador_32 PORT MAP(ch_out, sum1_output, '1', sum2, overflow2);
    sum3_port : somador_32 PORT MAP(sum1_out, sum2, '1', sum3, overflow3);
    sum4_port : somador_32 PORT MAP(di, sum3, '1', sum4, overflow4);
    sum5_port : somador_32 PORT MAP(maj_out, sum3, '1', sum5, overflow5);
    sum6_port : somador_32 PORT MAP(sum0_out, sum5, '1', sum6, overflow6);

    ch_port : ch PORT MAP(ei, fi, gi, ch_out);
    sum1_func_port : sum1 PORT MAP(ei, sum1_out);
    maj_port : maj PORT MAP(ai, bi, ci, maj_out);
    sum0_port : sum0 PORT MAP(ai, sum0_out);

    ao <= sum6;

    bo <= ai;
    co <= bi;
    do <= ci;
    eo <= sum4;
    fo <= ei;
    go <= fi;
    ho <= gi;

END ARCHITECTURE;
