-------------------------------------------------------------------------------
-- Author: Guilherme Fortunato Miranda
-- Module Name: main_functions_exp2
-- Description:
-- VHDL module to convert from hex (4b) to 7-segment
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

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
            overflow : OUT BIT;
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

    SIGNAL sum1, sum2, sum3, sum4, sum5, sum6 : unsigned(31 DOWNTO 0);
    SIGNAL overflow1, overflow2, overflow3, overflow4, overflow5, overflow6 : BIT;
    SIGNAL ch_out, sum1_out, maj_out, sum0_out : bit_vector(31 DOWNTO 0);

BEGIN
    sum1_port : somador PORT MAP(hi, '1', kpw, overflow1, sum1);
    sum2_port : somador PORT MAP(ch_out, '1', sum1, overflow2, sum2);
    sum3_port : somador PORT MAP(sum1_out, '1', sum2, overflow3, sum3);
    sum4_port : somador PORT MAP(di, '1', sum3, overflow4, sum4);
    sum5_port : somador PORT MAP(maj_out, '1', sum3, overflow5, sum5);
    sum6_port : somador PORT MAP(sum0_out, '1', sum5, overflow6, sum6);

    ch_port : ch PORT MAP(ei, fi, gi, ch_out);
    sum1_port : sum1 PORT MAP(ei, sum1_out);
    maj_port : maj PORT MAP(ai, bi, ci, maj_out);
    sum0_port : sum0 PORT MAP(ai, sum0_out);

    ao <= sum6;

    bo <= ai;
    co <= bi;
    do <= ci;
    eo <= sum4_out;
    fo <= ei;
    go <= fi;
    ho <= gi;

END ARCHITECTURE;