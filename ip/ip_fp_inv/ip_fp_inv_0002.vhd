-- ------------------------------------------------------------------------- 
-- High Level Design Compiler for Intel(R) FPGAs Version 20.1 (Release Build #720)
-- Quartus Prime development tool and MATLAB/Simulink Interface
-- 
-- Legal Notice: Copyright 2020 Intel Corporation.  All rights reserved.
-- Your use of  Intel Corporation's design tools,  logic functions and other
-- software and  tools, and its AMPP partner logic functions, and any output
-- files any  of the foregoing (including  device programming  or simulation
-- files), and  any associated  documentation  or information  are expressly
-- subject  to the terms and  conditions of the  Intel FPGA Software License
-- Agreement, Intel MegaCore Function License Agreement, or other applicable
-- license agreement,  including,  without limitation,  that your use is for
-- the  sole  purpose of  programming  logic devices  manufactured by  Intel
-- and  sold by Intel  or its authorized  distributors. Please refer  to the
-- applicable agreement for further details.
-- ---------------------------------------------------------------------------

-- VHDL created from ip_fp_inv_0002
-- VHDL created on Tue Oct 31 07:43:54 2023


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;
use IEEE.MATH_REAL.all;
use std.TextIO.all;
use work.dspba_library_package.all;

LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;
LIBRARY altera_lnsim;
USE altera_lnsim.altera_lnsim_components.altera_syncram;
LIBRARY lpm;
USE lpm.lpm_components.all;

entity ip_fp_inv_0002 is
    port (
        a : in std_logic_vector(15 downto 0);  -- float16_m10
        en : in std_logic_vector(0 downto 0);  -- ufix1
        q : out std_logic_vector(15 downto 0);  -- float16_m10
        clk : in std_logic;
        areset : in std_logic
    );
end ip_fp_inv_0002;

architecture normal of ip_fp_inv_0002 is

    attribute altera_attribute : string;
    attribute altera_attribute of normal : architecture is "-name AUTO_SHIFT_REGISTER_RECOGNITION OFF; -name PHYSICAL_SYNTHESIS_REGISTER_DUPLICATION ON; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 10037; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 15400; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 12020; -name MESSAGE_DISABLE 12030; -name MESSAGE_DISABLE 12010; -name MESSAGE_DISABLE 12110; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 13410; -name MESSAGE_DISABLE 113007";
    
    signal GND_q : STD_LOGIC_VECTOR (0 downto 0);
    signal VCC_q : STD_LOGIC_VECTOR (0 downto 0);
    signal expX_uid6_fpInverseTest_b : STD_LOGIC_VECTOR (4 downto 0);
    signal fracX_uid7_fpInverseTest_b : STD_LOGIC_VECTOR (9 downto 0);
    signal singX_uid8_fpInverseTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal cstAllOWE_uid9_fpInverseTest_q : STD_LOGIC_VECTOR (4 downto 0);
    signal cstAllZWF_uid10_fpInverseTest_q : STD_LOGIC_VECTOR (9 downto 0);
    signal cstNaNWF_uid11_fpInverseTest_q : STD_LOGIC_VECTOR (9 downto 0);
    signal cstAllZWE_uid12_fpInverseTest_q : STD_LOGIC_VECTOR (4 downto 0);
    signal cst2BiasM1_uid13_fpInverseTest_q : STD_LOGIC_VECTOR (4 downto 0);
    signal cst2Bias_uid14_fpInverseTest_q : STD_LOGIC_VECTOR (4 downto 0);
    signal excZ_x_uid21_fpInverseTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal expXIsMax_uid22_fpInverseTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal fracXIsZero_uid23_fpInverseTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal fracXIsZero_uid23_fpInverseTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal fracXIsNotZero_uid24_fpInverseTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excI_x_uid25_fpInverseTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal excI_x_uid25_fpInverseTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excN_x_uid26_fpInverseTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal excN_x_uid26_fpInverseTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal invExpXIsMax_uid27_fpInverseTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal InvExpXIsZero_uid28_fpInverseTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excR_x_uid29_fpInverseTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal oFracX_uid30_fpInverseTest_q : STD_LOGIC_VECTOR (10 downto 0);
    signal updatedY_uid32_fpInverseTest_q : STD_LOGIC_VECTOR (10 downto 0);
    signal fracXIsZero_uid31_fpInverseTest_a : STD_LOGIC_VECTOR (10 downto 0);
    signal fracXIsZero_uid31_fpInverseTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal fracXIsZero_uid31_fpInverseTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal y_uid34_fpInverseTest_in : STD_LOGIC_VECTOR (9 downto 0);
    signal y_uid34_fpInverseTest_b : STD_LOGIC_VECTOR (9 downto 0);
    signal expRCompExt_uid39_fpInverseTest_a : STD_LOGIC_VECTOR (5 downto 0);
    signal expRCompExt_uid39_fpInverseTest_b : STD_LOGIC_VECTOR (5 downto 0);
    signal expRCompExt_uid39_fpInverseTest_o : STD_LOGIC_VECTOR (5 downto 0);
    signal expRCompExt_uid39_fpInverseTest_q : STD_LOGIC_VECTOR (5 downto 0);
    signal expRComp_uid40_fpInverseTest_in : STD_LOGIC_VECTOR (4 downto 0);
    signal expRComp_uid40_fpInverseTest_b : STD_LOGIC_VECTOR (4 downto 0);
    signal udf_uid41_fpInverseTest_in : STD_LOGIC_VECTOR (6 downto 0);
    signal udf_uid41_fpInverseTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal expRCompYIsOneExt_uid42_fpInverseTest_a : STD_LOGIC_VECTOR (5 downto 0);
    signal expRCompYIsOneExt_uid42_fpInverseTest_b : STD_LOGIC_VECTOR (5 downto 0);
    signal expRCompYIsOneExt_uid42_fpInverseTest_o : STD_LOGIC_VECTOR (5 downto 0);
    signal expRCompYIsOneExt_uid42_fpInverseTest_q : STD_LOGIC_VECTOR (5 downto 0);
    signal expRCompYIsOne_uid43_fpInverseTest_in : STD_LOGIC_VECTOR (4 downto 0);
    signal expRCompYIsOne_uid43_fpInverseTest_b : STD_LOGIC_VECTOR (4 downto 0);
    signal fxpInverseRes_uid44_fpInverseTest_in : STD_LOGIC_VECTOR (15 downto 0);
    signal fxpInverseRes_uid44_fpInverseTest_b : STD_LOGIC_VECTOR (10 downto 0);
    signal fxpInverseResFrac_uid46_fpInverseTest_in : STD_LOGIC_VECTOR (9 downto 0);
    signal fxpInverseResFrac_uid46_fpInverseTest_b : STD_LOGIC_VECTOR (9 downto 0);
    signal fracRCalc_uid47_fpInverseTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal fracRCalc_uid47_fpInverseTest_q : STD_LOGIC_VECTOR (9 downto 0);
    signal expRCalc_uid48_fpInverseTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal expRCalc_uid48_fpInverseTest_q : STD_LOGIC_VECTOR (4 downto 0);
    signal xRegAndUdf_uid49_fpInverseTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal xRegAndUdf_uid49_fpInverseTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal xIOrXRUdf_uid50_fpInverseTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excSelBits_uid51_fpInverseTest_q : STD_LOGIC_VECTOR (2 downto 0);
    signal outMuxSelEnc_uid52_fpInverseTest_q : STD_LOGIC_VECTOR (1 downto 0);
    signal fracRPostExc_uid54_fpInverseTest_s : STD_LOGIC_VECTOR (1 downto 0);
    signal fracRPostExc_uid54_fpInverseTest_q : STD_LOGIC_VECTOR (9 downto 0);
    signal expRPostExc_uid55_fpInverseTest_s : STD_LOGIC_VECTOR (1 downto 0);
    signal expRPostExc_uid55_fpInverseTest_q : STD_LOGIC_VECTOR (4 downto 0);
    signal invExcRNaN_uid56_fpInverseTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal signR_uid57_fpInverseTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal R_uid58_fpInverseTest_q : STD_LOGIC_VECTOR (15 downto 0);
    signal memoryC0_uid60_inverseTables_q : STD_LOGIC_VECTOR (9 downto 0);
    signal memoryC0_uid61_inverseTables_q : STD_LOGIC_VECTOR (5 downto 0);
    signal os_uid62_inverseTables_q : STD_LOGIC_VECTOR (15 downto 0);
    signal memoryC1_uid64_inverseTables_q : STD_LOGIC_VECTOR (8 downto 0);
    signal lowRangeB_uid71_invPolyEval_in : STD_LOGIC_VECTOR (1 downto 0);
    signal lowRangeB_uid71_invPolyEval_b : STD_LOGIC_VECTOR (1 downto 0);
    signal highBBits_uid72_invPolyEval_b : STD_LOGIC_VECTOR (8 downto 0);
    signal s1sumAHighB_uid73_invPolyEval_a : STD_LOGIC_VECTOR (16 downto 0);
    signal s1sumAHighB_uid73_invPolyEval_b : STD_LOGIC_VECTOR (16 downto 0);
    signal s1sumAHighB_uid73_invPolyEval_o : STD_LOGIC_VECTOR (16 downto 0);
    signal s1sumAHighB_uid73_invPolyEval_q : STD_LOGIC_VECTOR (16 downto 0);
    signal s1_uid74_invPolyEval_q : STD_LOGIC_VECTOR (18 downto 0);
    signal prodXY_uid76_pT1_uid70_invPolyEval_a0 : STD_LOGIC_VECTOR (3 downto 0);
    signal prodXY_uid76_pT1_uid70_invPolyEval_b0 : STD_LOGIC_VECTOR (8 downto 0);
    signal prodXY_uid76_pT1_uid70_invPolyEval_s1 : STD_LOGIC_VECTOR (12 downto 0);
    signal prodXY_uid76_pT1_uid70_invPolyEval_pr : SIGNED (13 downto 0);
    signal prodXY_uid76_pT1_uid70_invPolyEval_q : STD_LOGIC_VECTOR (12 downto 0);
    signal osig_uid77_pT1_uid70_invPolyEval_b : STD_LOGIC_VECTOR (10 downto 0);
    signal yAddr_uid36_fpInverseTest_merged_bit_select_b : STD_LOGIC_VECTOR (5 downto 0);
    signal yAddr_uid36_fpInverseTest_merged_bit_select_c : STD_LOGIC_VECTOR (3 downto 0);
    signal redist0_yAddr_uid36_fpInverseTest_merged_bit_select_b_1_q : STD_LOGIC_VECTOR (5 downto 0);
    signal redist1_fxpInverseResFrac_uid46_fpInverseTest_b_1_q : STD_LOGIC_VECTOR (9 downto 0);
    signal redist2_fracXIsZero_uid31_fpInverseTest_q_2_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist3_fracXIsZero_uid31_fpInverseTest_q_3_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist4_fracXIsZero_uid23_fpInverseTest_q_2_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist5_excZ_x_uid21_fpInverseTest_q_1_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist6_singX_uid8_fpInverseTest_b_3_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist7_expX_uid6_fpInverseTest_b_2_q : STD_LOGIC_VECTOR (4 downto 0);

begin


    -- fracX_uid7_fpInverseTest(BITSELECT,6)@0
    fracX_uid7_fpInverseTest_b <= a(9 downto 0);

    -- cstAllZWF_uid10_fpInverseTest(CONSTANT,9)
    cstAllZWF_uid10_fpInverseTest_q <= "0000000000";

    -- fracXIsZero_uid23_fpInverseTest(LOGICAL,22)@0 + 1
    fracXIsZero_uid23_fpInverseTest_qi <= "1" WHEN cstAllZWF_uid10_fpInverseTest_q = fracX_uid7_fpInverseTest_b ELSE "0";
    fracXIsZero_uid23_fpInverseTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => fracXIsZero_uid23_fpInverseTest_qi, xout => fracXIsZero_uid23_fpInverseTest_q, ena => en(0), clk => clk, aclr => areset );

    -- redist4_fracXIsZero_uid23_fpInverseTest_q_2(DELAY,83)
    redist4_fracXIsZero_uid23_fpInverseTest_q_2 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => fracXIsZero_uid23_fpInverseTest_q, xout => redist4_fracXIsZero_uid23_fpInverseTest_q_2_q, ena => en(0), clk => clk, aclr => areset );

    -- fracXIsNotZero_uid24_fpInverseTest(LOGICAL,23)@2
    fracXIsNotZero_uid24_fpInverseTest_q <= not (redist4_fracXIsZero_uid23_fpInverseTest_q_2_q);

    -- cstAllOWE_uid9_fpInverseTest(CONSTANT,8)
    cstAllOWE_uid9_fpInverseTest_q <= "11111";

    -- expX_uid6_fpInverseTest(BITSELECT,5)@0
    expX_uid6_fpInverseTest_b <= a(14 downto 10);

    -- redist7_expX_uid6_fpInverseTest_b_2(DELAY,86)
    redist7_expX_uid6_fpInverseTest_b_2 : dspba_delay
    GENERIC MAP ( width => 5, depth => 2, reset_kind => "ASYNC" )
    PORT MAP ( xin => expX_uid6_fpInverseTest_b, xout => redist7_expX_uid6_fpInverseTest_b_2_q, ena => en(0), clk => clk, aclr => areset );

    -- expXIsMax_uid22_fpInverseTest(LOGICAL,21)@2
    expXIsMax_uid22_fpInverseTest_q <= "1" WHEN redist7_expX_uid6_fpInverseTest_b_2_q = cstAllOWE_uid9_fpInverseTest_q ELSE "0";

    -- excN_x_uid26_fpInverseTest(LOGICAL,25)@2 + 1
    excN_x_uid26_fpInverseTest_qi <= expXIsMax_uid22_fpInverseTest_q and fracXIsNotZero_uid24_fpInverseTest_q;
    excN_x_uid26_fpInverseTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => excN_x_uid26_fpInverseTest_qi, xout => excN_x_uid26_fpInverseTest_q, ena => en(0), clk => clk, aclr => areset );

    -- invExcRNaN_uid56_fpInverseTest(LOGICAL,55)@3
    invExcRNaN_uid56_fpInverseTest_q <= not (excN_x_uid26_fpInverseTest_q);

    -- singX_uid8_fpInverseTest(BITSELECT,7)@0
    singX_uid8_fpInverseTest_b <= STD_LOGIC_VECTOR(a(15 downto 15));

    -- redist6_singX_uid8_fpInverseTest_b_3(DELAY,85)
    redist6_singX_uid8_fpInverseTest_b_3 : dspba_delay
    GENERIC MAP ( width => 1, depth => 3, reset_kind => "ASYNC" )
    PORT MAP ( xin => singX_uid8_fpInverseTest_b, xout => redist6_singX_uid8_fpInverseTest_b_3_q, ena => en(0), clk => clk, aclr => areset );

    -- signR_uid57_fpInverseTest(LOGICAL,56)@3
    signR_uid57_fpInverseTest_q <= redist6_singX_uid8_fpInverseTest_b_3_q and invExcRNaN_uid56_fpInverseTest_q;

    -- cst2Bias_uid14_fpInverseTest(CONSTANT,13)
    cst2Bias_uid14_fpInverseTest_q <= "11110";

    -- expRCompYIsOneExt_uid42_fpInverseTest(SUB,41)@2
    expRCompYIsOneExt_uid42_fpInverseTest_a <= STD_LOGIC_VECTOR("0" & cst2Bias_uid14_fpInverseTest_q);
    expRCompYIsOneExt_uid42_fpInverseTest_b <= STD_LOGIC_VECTOR("0" & redist7_expX_uid6_fpInverseTest_b_2_q);
    expRCompYIsOneExt_uid42_fpInverseTest_o <= STD_LOGIC_VECTOR(UNSIGNED(expRCompYIsOneExt_uid42_fpInverseTest_a) - UNSIGNED(expRCompYIsOneExt_uid42_fpInverseTest_b));
    expRCompYIsOneExt_uid42_fpInverseTest_q <= expRCompYIsOneExt_uid42_fpInverseTest_o(5 downto 0);

    -- expRCompYIsOne_uid43_fpInverseTest(BITSELECT,42)@2
    expRCompYIsOne_uid43_fpInverseTest_in <= expRCompYIsOneExt_uid42_fpInverseTest_q(4 downto 0);
    expRCompYIsOne_uid43_fpInverseTest_b <= expRCompYIsOne_uid43_fpInverseTest_in(4 downto 0);

    -- cst2BiasM1_uid13_fpInverseTest(CONSTANT,12)
    cst2BiasM1_uid13_fpInverseTest_q <= "11101";

    -- expRCompExt_uid39_fpInverseTest(SUB,38)@2
    expRCompExt_uid39_fpInverseTest_a <= STD_LOGIC_VECTOR("0" & cst2BiasM1_uid13_fpInverseTest_q);
    expRCompExt_uid39_fpInverseTest_b <= STD_LOGIC_VECTOR("0" & redist7_expX_uid6_fpInverseTest_b_2_q);
    expRCompExt_uid39_fpInverseTest_o <= STD_LOGIC_VECTOR(UNSIGNED(expRCompExt_uid39_fpInverseTest_a) - UNSIGNED(expRCompExt_uid39_fpInverseTest_b));
    expRCompExt_uid39_fpInverseTest_q <= expRCompExt_uid39_fpInverseTest_o(5 downto 0);

    -- expRComp_uid40_fpInverseTest(BITSELECT,39)@2
    expRComp_uid40_fpInverseTest_in <= expRCompExt_uid39_fpInverseTest_q(4 downto 0);
    expRComp_uid40_fpInverseTest_b <= expRComp_uid40_fpInverseTest_in(4 downto 0);

    -- GND(CONSTANT,0)
    GND_q <= "0";

    -- updatedY_uid32_fpInverseTest(BITJOIN,31)@0
    updatedY_uid32_fpInverseTest_q <= GND_q & cstAllZWF_uid10_fpInverseTest_q;

    -- fracXIsZero_uid31_fpInverseTest(LOGICAL,32)@0 + 1
    fracXIsZero_uid31_fpInverseTest_a <= STD_LOGIC_VECTOR("0" & fracX_uid7_fpInverseTest_b);
    fracXIsZero_uid31_fpInverseTest_qi <= "1" WHEN fracXIsZero_uid31_fpInverseTest_a = updatedY_uid32_fpInverseTest_q ELSE "0";
    fracXIsZero_uid31_fpInverseTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => fracXIsZero_uid31_fpInverseTest_qi, xout => fracXIsZero_uid31_fpInverseTest_q, ena => en(0), clk => clk, aclr => areset );

    -- redist2_fracXIsZero_uid31_fpInverseTest_q_2(DELAY,81)
    redist2_fracXIsZero_uid31_fpInverseTest_q_2 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => fracXIsZero_uid31_fpInverseTest_q, xout => redist2_fracXIsZero_uid31_fpInverseTest_q_2_q, ena => en(0), clk => clk, aclr => areset );

    -- expRCalc_uid48_fpInverseTest(MUX,47)@2 + 1
    expRCalc_uid48_fpInverseTest_s <= redist2_fracXIsZero_uid31_fpInverseTest_q_2_q;
    expRCalc_uid48_fpInverseTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            expRCalc_uid48_fpInverseTest_q <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (en = "1") THEN
                CASE (expRCalc_uid48_fpInverseTest_s) IS
                    WHEN "0" => expRCalc_uid48_fpInverseTest_q <= expRComp_uid40_fpInverseTest_b;
                    WHEN "1" => expRCalc_uid48_fpInverseTest_q <= expRCompYIsOne_uid43_fpInverseTest_b;
                    WHEN OTHERS => expRCalc_uid48_fpInverseTest_q <= (others => '0');
                END CASE;
            END IF;
        END IF;
    END PROCESS;

    -- cstAllZWE_uid12_fpInverseTest(CONSTANT,11)
    cstAllZWE_uid12_fpInverseTest_q <= "00000";

    -- excZ_x_uid21_fpInverseTest(LOGICAL,20)@2
    excZ_x_uid21_fpInverseTest_q <= "1" WHEN redist7_expX_uid6_fpInverseTest_b_2_q = cstAllZWE_uid12_fpInverseTest_q ELSE "0";

    -- redist5_excZ_x_uid21_fpInverseTest_q_1(DELAY,84)
    redist5_excZ_x_uid21_fpInverseTest_q_1 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => excZ_x_uid21_fpInverseTest_q, xout => redist5_excZ_x_uid21_fpInverseTest_q_1_q, ena => en(0), clk => clk, aclr => areset );

    -- udf_uid41_fpInverseTest(BITSELECT,40)@2
    udf_uid41_fpInverseTest_in <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((6 downto 6 => expRCompExt_uid39_fpInverseTest_q(5)) & expRCompExt_uid39_fpInverseTest_q));
    udf_uid41_fpInverseTest_b <= STD_LOGIC_VECTOR(udf_uid41_fpInverseTest_in(6 downto 6));

    -- invExpXIsMax_uid27_fpInverseTest(LOGICAL,26)@2
    invExpXIsMax_uid27_fpInverseTest_q <= not (expXIsMax_uid22_fpInverseTest_q);

    -- InvExpXIsZero_uid28_fpInverseTest(LOGICAL,27)@2
    InvExpXIsZero_uid28_fpInverseTest_q <= not (excZ_x_uid21_fpInverseTest_q);

    -- excR_x_uid29_fpInverseTest(LOGICAL,28)@2
    excR_x_uid29_fpInverseTest_q <= InvExpXIsZero_uid28_fpInverseTest_q and invExpXIsMax_uid27_fpInverseTest_q;

    -- xRegAndUdf_uid49_fpInverseTest(LOGICAL,48)@2 + 1
    xRegAndUdf_uid49_fpInverseTest_qi <= excR_x_uid29_fpInverseTest_q and udf_uid41_fpInverseTest_b;
    xRegAndUdf_uid49_fpInverseTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => xRegAndUdf_uid49_fpInverseTest_qi, xout => xRegAndUdf_uid49_fpInverseTest_q, ena => en(0), clk => clk, aclr => areset );

    -- excI_x_uid25_fpInverseTest(LOGICAL,24)@2 + 1
    excI_x_uid25_fpInverseTest_qi <= expXIsMax_uid22_fpInverseTest_q and redist4_fracXIsZero_uid23_fpInverseTest_q_2_q;
    excI_x_uid25_fpInverseTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => excI_x_uid25_fpInverseTest_qi, xout => excI_x_uid25_fpInverseTest_q, ena => en(0), clk => clk, aclr => areset );

    -- xIOrXRUdf_uid50_fpInverseTest(LOGICAL,49)@3
    xIOrXRUdf_uid50_fpInverseTest_q <= excI_x_uid25_fpInverseTest_q or xRegAndUdf_uid49_fpInverseTest_q;

    -- excSelBits_uid51_fpInverseTest(BITJOIN,50)@3
    excSelBits_uid51_fpInverseTest_q <= excN_x_uid26_fpInverseTest_q & redist5_excZ_x_uid21_fpInverseTest_q_1_q & xIOrXRUdf_uid50_fpInverseTest_q;

    -- outMuxSelEnc_uid52_fpInverseTest(LOOKUP,51)@3
    outMuxSelEnc_uid52_fpInverseTest_combproc: PROCESS (excSelBits_uid51_fpInverseTest_q)
    BEGIN
        -- Begin reserved scope level
        CASE (excSelBits_uid51_fpInverseTest_q) IS
            WHEN "000" => outMuxSelEnc_uid52_fpInverseTest_q <= "01";
            WHEN "001" => outMuxSelEnc_uid52_fpInverseTest_q <= "00";
            WHEN "010" => outMuxSelEnc_uid52_fpInverseTest_q <= "10";
            WHEN "011" => outMuxSelEnc_uid52_fpInverseTest_q <= "01";
            WHEN "100" => outMuxSelEnc_uid52_fpInverseTest_q <= "11";
            WHEN "101" => outMuxSelEnc_uid52_fpInverseTest_q <= "01";
            WHEN "110" => outMuxSelEnc_uid52_fpInverseTest_q <= "01";
            WHEN "111" => outMuxSelEnc_uid52_fpInverseTest_q <= "01";
            WHEN OTHERS => -- unreachable
                           outMuxSelEnc_uid52_fpInverseTest_q <= (others => '-');
        END CASE;
        -- End reserved scope level
    END PROCESS;

    -- expRPostExc_uid55_fpInverseTest(MUX,54)@3
    expRPostExc_uid55_fpInverseTest_s <= outMuxSelEnc_uid52_fpInverseTest_q;
    expRPostExc_uid55_fpInverseTest_combproc: PROCESS (expRPostExc_uid55_fpInverseTest_s, en, cstAllZWE_uid12_fpInverseTest_q, expRCalc_uid48_fpInverseTest_q, cstAllOWE_uid9_fpInverseTest_q)
    BEGIN
        CASE (expRPostExc_uid55_fpInverseTest_s) IS
            WHEN "00" => expRPostExc_uid55_fpInverseTest_q <= cstAllZWE_uid12_fpInverseTest_q;
            WHEN "01" => expRPostExc_uid55_fpInverseTest_q <= expRCalc_uid48_fpInverseTest_q;
            WHEN "10" => expRPostExc_uid55_fpInverseTest_q <= cstAllOWE_uid9_fpInverseTest_q;
            WHEN "11" => expRPostExc_uid55_fpInverseTest_q <= cstAllOWE_uid9_fpInverseTest_q;
            WHEN OTHERS => expRPostExc_uid55_fpInverseTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- cstNaNWF_uid11_fpInverseTest(CONSTANT,10)
    cstNaNWF_uid11_fpInverseTest_q <= "0000000001";

    -- memoryC1_uid64_inverseTables(LOOKUP,63)@0
    memoryC1_uid64_inverseTables_combproc: PROCESS (yAddr_uid36_fpInverseTest_merged_bit_select_b)
    BEGIN
        -- Begin reserved scope level
        CASE (yAddr_uid36_fpInverseTest_merged_bit_select_b) IS
            WHEN "000000" => memoryC1_uid64_inverseTables_q <= "100000011";
            WHEN "000001" => memoryC1_uid64_inverseTables_q <= "100001100";
            WHEN "000010" => memoryC1_uid64_inverseTables_q <= "100010011";
            WHEN "000011" => memoryC1_uid64_inverseTables_q <= "100011010";
            WHEN "000100" => memoryC1_uid64_inverseTables_q <= "100100000";
            WHEN "000101" => memoryC1_uid64_inverseTables_q <= "100100111";
            WHEN "000110" => memoryC1_uid64_inverseTables_q <= "100101101";
            WHEN "000111" => memoryC1_uid64_inverseTables_q <= "100110011";
            WHEN "001000" => memoryC1_uid64_inverseTables_q <= "100111001";
            WHEN "001001" => memoryC1_uid64_inverseTables_q <= "100111110";
            WHEN "001010" => memoryC1_uid64_inverseTables_q <= "101000011";
            WHEN "001011" => memoryC1_uid64_inverseTables_q <= "101001000";
            WHEN "001100" => memoryC1_uid64_inverseTables_q <= "101001100";
            WHEN "001101" => memoryC1_uid64_inverseTables_q <= "101010001";
            WHEN "001110" => memoryC1_uid64_inverseTables_q <= "101010110";
            WHEN "001111" => memoryC1_uid64_inverseTables_q <= "101011010";
            WHEN "010000" => memoryC1_uid64_inverseTables_q <= "101011110";
            WHEN "010001" => memoryC1_uid64_inverseTables_q <= "101100010";
            WHEN "010010" => memoryC1_uid64_inverseTables_q <= "101100110";
            WHEN "010011" => memoryC1_uid64_inverseTables_q <= "101101010";
            WHEN "010100" => memoryC1_uid64_inverseTables_q <= "101101101";
            WHEN "010101" => memoryC1_uid64_inverseTables_q <= "101110001";
            WHEN "010110" => memoryC1_uid64_inverseTables_q <= "101110011";
            WHEN "010111" => memoryC1_uid64_inverseTables_q <= "101111000";
            WHEN "011000" => memoryC1_uid64_inverseTables_q <= "101111011";
            WHEN "011001" => memoryC1_uid64_inverseTables_q <= "101111101";
            WHEN "011010" => memoryC1_uid64_inverseTables_q <= "110000000";
            WHEN "011011" => memoryC1_uid64_inverseTables_q <= "110000010";
            WHEN "011100" => memoryC1_uid64_inverseTables_q <= "110000110";
            WHEN "011101" => memoryC1_uid64_inverseTables_q <= "110001000";
            WHEN "011110" => memoryC1_uid64_inverseTables_q <= "110001010";
            WHEN "011111" => memoryC1_uid64_inverseTables_q <= "110001110";
            WHEN "100000" => memoryC1_uid64_inverseTables_q <= "110001111";
            WHEN "100001" => memoryC1_uid64_inverseTables_q <= "110010010";
            WHEN "100010" => memoryC1_uid64_inverseTables_q <= "110010011";
            WHEN "100011" => memoryC1_uid64_inverseTables_q <= "110010101";
            WHEN "100100" => memoryC1_uid64_inverseTables_q <= "110011000";
            WHEN "100101" => memoryC1_uid64_inverseTables_q <= "110011010";
            WHEN "100110" => memoryC1_uid64_inverseTables_q <= "110011100";
            WHEN "100111" => memoryC1_uid64_inverseTables_q <= "110011110";
            WHEN "101000" => memoryC1_uid64_inverseTables_q <= "110100000";
            WHEN "101001" => memoryC1_uid64_inverseTables_q <= "110100010";
            WHEN "101010" => memoryC1_uid64_inverseTables_q <= "110100100";
            WHEN "101011" => memoryC1_uid64_inverseTables_q <= "110100101";
            WHEN "101100" => memoryC1_uid64_inverseTables_q <= "110100111";
            WHEN "101101" => memoryC1_uid64_inverseTables_q <= "110101000";
            WHEN "101110" => memoryC1_uid64_inverseTables_q <= "110101011";
            WHEN "101111" => memoryC1_uid64_inverseTables_q <= "110101011";
            WHEN "110000" => memoryC1_uid64_inverseTables_q <= "110101101";
            WHEN "110001" => memoryC1_uid64_inverseTables_q <= "110101111";
            WHEN "110010" => memoryC1_uid64_inverseTables_q <= "110110000";
            WHEN "110011" => memoryC1_uid64_inverseTables_q <= "110110001";
            WHEN "110100" => memoryC1_uid64_inverseTables_q <= "110110011";
            WHEN "110101" => memoryC1_uid64_inverseTables_q <= "110110100";
            WHEN "110110" => memoryC1_uid64_inverseTables_q <= "110110110";
            WHEN "110111" => memoryC1_uid64_inverseTables_q <= "110110111";
            WHEN "111000" => memoryC1_uid64_inverseTables_q <= "110111000";
            WHEN "111001" => memoryC1_uid64_inverseTables_q <= "110111001";
            WHEN "111010" => memoryC1_uid64_inverseTables_q <= "110111010";
            WHEN "111011" => memoryC1_uid64_inverseTables_q <= "110111011";
            WHEN "111100" => memoryC1_uid64_inverseTables_q <= "110111101";
            WHEN "111101" => memoryC1_uid64_inverseTables_q <= "110111101";
            WHEN "111110" => memoryC1_uid64_inverseTables_q <= "110111110";
            WHEN "111111" => memoryC1_uid64_inverseTables_q <= "111000000";
            WHEN OTHERS => -- unreachable
                           memoryC1_uid64_inverseTables_q <= (others => '-');
        END CASE;
        -- End reserved scope level
    END PROCESS;

    -- VCC(CONSTANT,1)
    VCC_q <= "1";

    -- oFracX_uid30_fpInverseTest(BITJOIN,29)@0
    oFracX_uid30_fpInverseTest_q <= VCC_q & fracX_uid7_fpInverseTest_b;

    -- y_uid34_fpInverseTest(BITSELECT,33)@0
    y_uid34_fpInverseTest_in <= oFracX_uid30_fpInverseTest_q(9 downto 0);
    y_uid34_fpInverseTest_b <= y_uid34_fpInverseTest_in(9 downto 0);

    -- yAddr_uid36_fpInverseTest_merged_bit_select(BITSELECT,78)@0
    yAddr_uid36_fpInverseTest_merged_bit_select_b <= y_uid34_fpInverseTest_b(9 downto 4);
    yAddr_uid36_fpInverseTest_merged_bit_select_c <= y_uid34_fpInverseTest_b(3 downto 0);

    -- prodXY_uid76_pT1_uid70_invPolyEval(MULT,75)@0 + 2
    prodXY_uid76_pT1_uid70_invPolyEval_pr <= SIGNED(signed(resize(UNSIGNED(prodXY_uid76_pT1_uid70_invPolyEval_a0),5)) * SIGNED(prodXY_uid76_pT1_uid70_invPolyEval_b0));
    prodXY_uid76_pT1_uid70_invPolyEval_component: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            prodXY_uid76_pT1_uid70_invPolyEval_a0 <= (others => '0');
            prodXY_uid76_pT1_uid70_invPolyEval_b0 <= (others => '0');
            prodXY_uid76_pT1_uid70_invPolyEval_s1 <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (en = "1") THEN
                prodXY_uid76_pT1_uid70_invPolyEval_a0 <= yAddr_uid36_fpInverseTest_merged_bit_select_c;
                prodXY_uid76_pT1_uid70_invPolyEval_b0 <= STD_LOGIC_VECTOR(memoryC1_uid64_inverseTables_q);
                prodXY_uid76_pT1_uid70_invPolyEval_s1 <= STD_LOGIC_VECTOR(resize(prodXY_uid76_pT1_uid70_invPolyEval_pr,13));
            END IF;
        END IF;
    END PROCESS;
    prodXY_uid76_pT1_uid70_invPolyEval_q <= prodXY_uid76_pT1_uid70_invPolyEval_s1;

    -- osig_uid77_pT1_uid70_invPolyEval(BITSELECT,76)@2
    osig_uid77_pT1_uid70_invPolyEval_b <= STD_LOGIC_VECTOR(prodXY_uid76_pT1_uid70_invPolyEval_q(12 downto 2));

    -- highBBits_uid72_invPolyEval(BITSELECT,71)@2
    highBBits_uid72_invPolyEval_b <= STD_LOGIC_VECTOR(osig_uid77_pT1_uid70_invPolyEval_b(10 downto 2));

    -- redist0_yAddr_uid36_fpInverseTest_merged_bit_select_b_1(DELAY,79)
    redist0_yAddr_uid36_fpInverseTest_merged_bit_select_b_1 : dspba_delay
    GENERIC MAP ( width => 6, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => yAddr_uid36_fpInverseTest_merged_bit_select_b, xout => redist0_yAddr_uid36_fpInverseTest_merged_bit_select_b_1_q, ena => en(0), clk => clk, aclr => areset );

    -- memoryC0_uid61_inverseTables(LOOKUP,60)@1 + 1
    memoryC0_uid61_inverseTables_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            memoryC0_uid61_inverseTables_q <= "010000";
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (en = "1") THEN
                CASE (redist0_yAddr_uid36_fpInverseTest_merged_bit_select_b_1_q) IS
                    WHEN "000000" => memoryC0_uid61_inverseTables_q <= "010000";
                    WHEN "000001" => memoryC0_uid61_inverseTables_q <= "001111";
                    WHEN "000010" => memoryC0_uid61_inverseTables_q <= "001111";
                    WHEN "000011" => memoryC0_uid61_inverseTables_q <= "001111";
                    WHEN "000100" => memoryC0_uid61_inverseTables_q <= "001111";
                    WHEN "000101" => memoryC0_uid61_inverseTables_q <= "001110";
                    WHEN "000110" => memoryC0_uid61_inverseTables_q <= "001110";
                    WHEN "000111" => memoryC0_uid61_inverseTables_q <= "001110";
                    WHEN "001000" => memoryC0_uid61_inverseTables_q <= "001110";
                    WHEN "001001" => memoryC0_uid61_inverseTables_q <= "001110";
                    WHEN "001010" => memoryC0_uid61_inverseTables_q <= "001101";
                    WHEN "001011" => memoryC0_uid61_inverseTables_q <= "001101";
                    WHEN "001100" => memoryC0_uid61_inverseTables_q <= "001101";
                    WHEN "001101" => memoryC0_uid61_inverseTables_q <= "001101";
                    WHEN "001110" => memoryC0_uid61_inverseTables_q <= "001101";
                    WHEN "001111" => memoryC0_uid61_inverseTables_q <= "001100";
                    WHEN "010000" => memoryC0_uid61_inverseTables_q <= "001100";
                    WHEN "010001" => memoryC0_uid61_inverseTables_q <= "001100";
                    WHEN "010010" => memoryC0_uid61_inverseTables_q <= "001100";
                    WHEN "010011" => memoryC0_uid61_inverseTables_q <= "001100";
                    WHEN "010100" => memoryC0_uid61_inverseTables_q <= "001100";
                    WHEN "010101" => memoryC0_uid61_inverseTables_q <= "001100";
                    WHEN "010110" => memoryC0_uid61_inverseTables_q <= "001011";
                    WHEN "010111" => memoryC0_uid61_inverseTables_q <= "001011";
                    WHEN "011000" => memoryC0_uid61_inverseTables_q <= "001011";
                    WHEN "011001" => memoryC0_uid61_inverseTables_q <= "001011";
                    WHEN "011010" => memoryC0_uid61_inverseTables_q <= "001011";
                    WHEN "011011" => memoryC0_uid61_inverseTables_q <= "001011";
                    WHEN "011100" => memoryC0_uid61_inverseTables_q <= "001011";
                    WHEN "011101" => memoryC0_uid61_inverseTables_q <= "001011";
                    WHEN "011110" => memoryC0_uid61_inverseTables_q <= "001010";
                    WHEN "011111" => memoryC0_uid61_inverseTables_q <= "001010";
                    WHEN "100000" => memoryC0_uid61_inverseTables_q <= "001010";
                    WHEN "100001" => memoryC0_uid61_inverseTables_q <= "001010";
                    WHEN "100010" => memoryC0_uid61_inverseTables_q <= "001010";
                    WHEN "100011" => memoryC0_uid61_inverseTables_q <= "001010";
                    WHEN "100100" => memoryC0_uid61_inverseTables_q <= "001010";
                    WHEN "100101" => memoryC0_uid61_inverseTables_q <= "001010";
                    WHEN "100110" => memoryC0_uid61_inverseTables_q <= "001010";
                    WHEN "100111" => memoryC0_uid61_inverseTables_q <= "001001";
                    WHEN "101000" => memoryC0_uid61_inverseTables_q <= "001001";
                    WHEN "101001" => memoryC0_uid61_inverseTables_q <= "001001";
                    WHEN "101010" => memoryC0_uid61_inverseTables_q <= "001001";
                    WHEN "101011" => memoryC0_uid61_inverseTables_q <= "001001";
                    WHEN "101100" => memoryC0_uid61_inverseTables_q <= "001001";
                    WHEN "101101" => memoryC0_uid61_inverseTables_q <= "001001";
                    WHEN "101110" => memoryC0_uid61_inverseTables_q <= "001001";
                    WHEN "101111" => memoryC0_uid61_inverseTables_q <= "001001";
                    WHEN "110000" => memoryC0_uid61_inverseTables_q <= "001001";
                    WHEN "110001" => memoryC0_uid61_inverseTables_q <= "001001";
                    WHEN "110010" => memoryC0_uid61_inverseTables_q <= "001000";
                    WHEN "110011" => memoryC0_uid61_inverseTables_q <= "001000";
                    WHEN "110100" => memoryC0_uid61_inverseTables_q <= "001000";
                    WHEN "110101" => memoryC0_uid61_inverseTables_q <= "001000";
                    WHEN "110110" => memoryC0_uid61_inverseTables_q <= "001000";
                    WHEN "110111" => memoryC0_uid61_inverseTables_q <= "001000";
                    WHEN "111000" => memoryC0_uid61_inverseTables_q <= "001000";
                    WHEN "111001" => memoryC0_uid61_inverseTables_q <= "001000";
                    WHEN "111010" => memoryC0_uid61_inverseTables_q <= "001000";
                    WHEN "111011" => memoryC0_uid61_inverseTables_q <= "001000";
                    WHEN "111100" => memoryC0_uid61_inverseTables_q <= "001000";
                    WHEN "111101" => memoryC0_uid61_inverseTables_q <= "001000";
                    WHEN "111110" => memoryC0_uid61_inverseTables_q <= "001000";
                    WHEN "111111" => memoryC0_uid61_inverseTables_q <= "001000";
                    WHEN OTHERS => -- unreachable
                                   memoryC0_uid61_inverseTables_q <= (others => '-');
                END CASE;
            END IF;
        END IF;
    END PROCESS;

    -- memoryC0_uid60_inverseTables(LOOKUP,59)@1 + 1
    memoryC0_uid60_inverseTables_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            memoryC0_uid60_inverseTables_q <= "0000000100";
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (en = "1") THEN
                CASE (redist0_yAddr_uid36_fpInverseTest_merged_bit_select_b_1_q) IS
                    WHEN "000000" => memoryC0_uid60_inverseTables_q <= "0000000100";
                    WHEN "000001" => memoryC0_uid60_inverseTables_q <= "1100000111";
                    WHEN "000010" => memoryC0_uid60_inverseTables_q <= "1000010011";
                    WHEN "000011" => memoryC0_uid60_inverseTables_q <= "0100100110";
                    WHEN "000100" => memoryC0_uid60_inverseTables_q <= "0001000000";
                    WHEN "000101" => memoryC0_uid60_inverseTables_q <= "1101100000";
                    WHEN "000110" => memoryC0_uid60_inverseTables_q <= "1010000111";
                    WHEN "000111" => memoryC0_uid60_inverseTables_q <= "0110110100";
                    WHEN "001000" => memoryC0_uid60_inverseTables_q <= "0011100111";
                    WHEN "001001" => memoryC0_uid60_inverseTables_q <= "0000100000";
                    WHEN "001010" => memoryC0_uid60_inverseTables_q <= "1101011110";
                    WHEN "001011" => memoryC0_uid60_inverseTables_q <= "1010100001";
                    WHEN "001100" => memoryC0_uid60_inverseTables_q <= "0111101001";
                    WHEN "001101" => memoryC0_uid60_inverseTables_q <= "0100110110";
                    WHEN "001110" => memoryC0_uid60_inverseTables_q <= "0010000111";
                    WHEN "001111" => memoryC0_uid60_inverseTables_q <= "1111011101";
                    WHEN "010000" => memoryC0_uid60_inverseTables_q <= "1100110111";
                    WHEN "010001" => memoryC0_uid60_inverseTables_q <= "1010010101";
                    WHEN "010010" => memoryC0_uid60_inverseTables_q <= "0111110111";
                    WHEN "010011" => memoryC0_uid60_inverseTables_q <= "0101011101";
                    WHEN "010100" => memoryC0_uid60_inverseTables_q <= "0011000111";
                    WHEN "010101" => memoryC0_uid60_inverseTables_q <= "0000110100";
                    WHEN "010110" => memoryC0_uid60_inverseTables_q <= "1110100101";
                    WHEN "010111" => memoryC0_uid60_inverseTables_q <= "1100011000";
                    WHEN "011000" => memoryC0_uid60_inverseTables_q <= "1010001111";
                    WHEN "011001" => memoryC0_uid60_inverseTables_q <= "1000001010";
                    WHEN "011010" => memoryC0_uid60_inverseTables_q <= "0110000111";
                    WHEN "011011" => memoryC0_uid60_inverseTables_q <= "0100000111";
                    WHEN "011100" => memoryC0_uid60_inverseTables_q <= "0010001001";
                    WHEN "011101" => memoryC0_uid60_inverseTables_q <= "0000001111";
                    WHEN "011110" => memoryC0_uid60_inverseTables_q <= "1110010111";
                    WHEN "011111" => memoryC0_uid60_inverseTables_q <= "1100100001";
                    WHEN "100000" => memoryC0_uid60_inverseTables_q <= "1010101111";
                    WHEN "100001" => memoryC0_uid60_inverseTables_q <= "1000111110";
                    WHEN "100010" => memoryC0_uid60_inverseTables_q <= "0111010000";
                    WHEN "100011" => memoryC0_uid60_inverseTables_q <= "0101100100";
                    WHEN "100100" => memoryC0_uid60_inverseTables_q <= "0011111010";
                    WHEN "100101" => memoryC0_uid60_inverseTables_q <= "0010010010";
                    WHEN "100110" => memoryC0_uid60_inverseTables_q <= "0000101100";
                    WHEN "100111" => memoryC0_uid60_inverseTables_q <= "1111001000";
                    WHEN "101000" => memoryC0_uid60_inverseTables_q <= "1101100110";
                    WHEN "101001" => memoryC0_uid60_inverseTables_q <= "1100000110";
                    WHEN "101010" => memoryC0_uid60_inverseTables_q <= "1010101000";
                    WHEN "101011" => memoryC0_uid60_inverseTables_q <= "1001001100";
                    WHEN "101100" => memoryC0_uid60_inverseTables_q <= "0111110001";
                    WHEN "101101" => memoryC0_uid60_inverseTables_q <= "0110011000";
                    WHEN "101110" => memoryC0_uid60_inverseTables_q <= "0101000000";
                    WHEN "101111" => memoryC0_uid60_inverseTables_q <= "0011101011";
                    WHEN "110000" => memoryC0_uid60_inverseTables_q <= "0010010110";
                    WHEN "110001" => memoryC0_uid60_inverseTables_q <= "0001000011";
                    WHEN "110010" => memoryC0_uid60_inverseTables_q <= "1111110010";
                    WHEN "110011" => memoryC0_uid60_inverseTables_q <= "1110100010";
                    WHEN "110100" => memoryC0_uid60_inverseTables_q <= "1101010011";
                    WHEN "110101" => memoryC0_uid60_inverseTables_q <= "1100000110";
                    WHEN "110110" => memoryC0_uid60_inverseTables_q <= "1010111010";
                    WHEN "110111" => memoryC0_uid60_inverseTables_q <= "1001101111";
                    WHEN "111000" => memoryC0_uid60_inverseTables_q <= "1000100110";
                    WHEN "111001" => memoryC0_uid60_inverseTables_q <= "0111011110";
                    WHEN "111010" => memoryC0_uid60_inverseTables_q <= "0110010111";
                    WHEN "111011" => memoryC0_uid60_inverseTables_q <= "0101010001";
                    WHEN "111100" => memoryC0_uid60_inverseTables_q <= "0100001100";
                    WHEN "111101" => memoryC0_uid60_inverseTables_q <= "0011001001";
                    WHEN "111110" => memoryC0_uid60_inverseTables_q <= "0010000110";
                    WHEN "111111" => memoryC0_uid60_inverseTables_q <= "0001000100";
                    WHEN OTHERS => -- unreachable
                                   memoryC0_uid60_inverseTables_q <= (others => '-');
                END CASE;
            END IF;
        END IF;
    END PROCESS;

    -- os_uid62_inverseTables(BITJOIN,61)@2
    os_uid62_inverseTables_q <= memoryC0_uid61_inverseTables_q & memoryC0_uid60_inverseTables_q;

    -- s1sumAHighB_uid73_invPolyEval(ADD,72)@2
    s1sumAHighB_uid73_invPolyEval_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((16 downto 16 => os_uid62_inverseTables_q(15)) & os_uid62_inverseTables_q));
    s1sumAHighB_uid73_invPolyEval_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((16 downto 9 => highBBits_uid72_invPolyEval_b(8)) & highBBits_uid72_invPolyEval_b));
    s1sumAHighB_uid73_invPolyEval_o <= STD_LOGIC_VECTOR(SIGNED(s1sumAHighB_uid73_invPolyEval_a) + SIGNED(s1sumAHighB_uid73_invPolyEval_b));
    s1sumAHighB_uid73_invPolyEval_q <= s1sumAHighB_uid73_invPolyEval_o(16 downto 0);

    -- lowRangeB_uid71_invPolyEval(BITSELECT,70)@2
    lowRangeB_uid71_invPolyEval_in <= osig_uid77_pT1_uid70_invPolyEval_b(1 downto 0);
    lowRangeB_uid71_invPolyEval_b <= lowRangeB_uid71_invPolyEval_in(1 downto 0);

    -- s1_uid74_invPolyEval(BITJOIN,73)@2
    s1_uid74_invPolyEval_q <= s1sumAHighB_uid73_invPolyEval_q & lowRangeB_uid71_invPolyEval_b;

    -- fxpInverseRes_uid44_fpInverseTest(BITSELECT,43)@2
    fxpInverseRes_uid44_fpInverseTest_in <= s1_uid74_invPolyEval_q(15 downto 0);
    fxpInverseRes_uid44_fpInverseTest_b <= fxpInverseRes_uid44_fpInverseTest_in(15 downto 5);

    -- fxpInverseResFrac_uid46_fpInverseTest(BITSELECT,45)@2
    fxpInverseResFrac_uid46_fpInverseTest_in <= fxpInverseRes_uid44_fpInverseTest_b(9 downto 0);
    fxpInverseResFrac_uid46_fpInverseTest_b <= fxpInverseResFrac_uid46_fpInverseTest_in(9 downto 0);

    -- redist1_fxpInverseResFrac_uid46_fpInverseTest_b_1(DELAY,80)
    redist1_fxpInverseResFrac_uid46_fpInverseTest_b_1 : dspba_delay
    GENERIC MAP ( width => 10, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => fxpInverseResFrac_uid46_fpInverseTest_b, xout => redist1_fxpInverseResFrac_uid46_fpInverseTest_b_1_q, ena => en(0), clk => clk, aclr => areset );

    -- redist3_fracXIsZero_uid31_fpInverseTest_q_3(DELAY,82)
    redist3_fracXIsZero_uid31_fpInverseTest_q_3 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist2_fracXIsZero_uid31_fpInverseTest_q_2_q, xout => redist3_fracXIsZero_uid31_fpInverseTest_q_3_q, ena => en(0), clk => clk, aclr => areset );

    -- fracRCalc_uid47_fpInverseTest(MUX,46)@3
    fracRCalc_uid47_fpInverseTest_s <= redist3_fracXIsZero_uid31_fpInverseTest_q_3_q;
    fracRCalc_uid47_fpInverseTest_combproc: PROCESS (fracRCalc_uid47_fpInverseTest_s, en, redist1_fxpInverseResFrac_uid46_fpInverseTest_b_1_q, cstAllZWF_uid10_fpInverseTest_q)
    BEGIN
        CASE (fracRCalc_uid47_fpInverseTest_s) IS
            WHEN "0" => fracRCalc_uid47_fpInverseTest_q <= redist1_fxpInverseResFrac_uid46_fpInverseTest_b_1_q;
            WHEN "1" => fracRCalc_uid47_fpInverseTest_q <= cstAllZWF_uid10_fpInverseTest_q;
            WHEN OTHERS => fracRCalc_uid47_fpInverseTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- fracRPostExc_uid54_fpInverseTest(MUX,53)@3
    fracRPostExc_uid54_fpInverseTest_s <= outMuxSelEnc_uid52_fpInverseTest_q;
    fracRPostExc_uid54_fpInverseTest_combproc: PROCESS (fracRPostExc_uid54_fpInverseTest_s, en, cstAllZWF_uid10_fpInverseTest_q, fracRCalc_uid47_fpInverseTest_q, cstNaNWF_uid11_fpInverseTest_q)
    BEGIN
        CASE (fracRPostExc_uid54_fpInverseTest_s) IS
            WHEN "00" => fracRPostExc_uid54_fpInverseTest_q <= cstAllZWF_uid10_fpInverseTest_q;
            WHEN "01" => fracRPostExc_uid54_fpInverseTest_q <= fracRCalc_uid47_fpInverseTest_q;
            WHEN "10" => fracRPostExc_uid54_fpInverseTest_q <= cstAllZWF_uid10_fpInverseTest_q;
            WHEN "11" => fracRPostExc_uid54_fpInverseTest_q <= cstNaNWF_uid11_fpInverseTest_q;
            WHEN OTHERS => fracRPostExc_uid54_fpInverseTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- R_uid58_fpInverseTest(BITJOIN,57)@3
    R_uid58_fpInverseTest_q <= signR_uid57_fpInverseTest_q & expRPostExc_uid55_fpInverseTest_q & fracRPostExc_uid54_fpInverseTest_q;

    -- xOut(GPOUT,4)@3
    q <= R_uid58_fpInverseTest_q;

END normal;
