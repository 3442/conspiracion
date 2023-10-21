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

-- VHDL created from ip_fp_add_0002
-- VHDL created on Fri Oct 20 22:45:49 2023


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

entity ip_fp_add_0002 is
    port (
        a : in std_logic_vector(31 downto 0);  -- float32_m23
        b : in std_logic_vector(31 downto 0);  -- float32_m23
        q : out std_logic_vector(31 downto 0);  -- float32_m23
        clk : in std_logic;
        areset : in std_logic
    );
end ip_fp_add_0002;

architecture normal of ip_fp_add_0002 is

    attribute altera_attribute : string;
    attribute altera_attribute of normal : architecture is "-name AUTO_SHIFT_REGISTER_RECOGNITION OFF; -name PHYSICAL_SYNTHESIS_REGISTER_DUPLICATION ON; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 10037; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 15400; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 12020; -name MESSAGE_DISABLE 12030; -name MESSAGE_DISABLE 12010; -name MESSAGE_DISABLE 12110; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 13410; -name MESSAGE_DISABLE 113007";
    
    signal GND_q : STD_LOGIC_VECTOR (0 downto 0);
    signal VCC_q : STD_LOGIC_VECTOR (0 downto 0);
    signal expFracX_uid6_fpAddTest_b : STD_LOGIC_VECTOR (30 downto 0);
    signal expFracY_uid7_fpAddTest_b : STD_LOGIC_VECTOR (30 downto 0);
    signal xGTEy_uid8_fpAddTest_a : STD_LOGIC_VECTOR (32 downto 0);
    signal xGTEy_uid8_fpAddTest_b : STD_LOGIC_VECTOR (32 downto 0);
    signal xGTEy_uid8_fpAddTest_o : STD_LOGIC_VECTOR (32 downto 0);
    signal xGTEy_uid8_fpAddTest_n : STD_LOGIC_VECTOR (0 downto 0);
    signal fracY_uid9_fpAddTest_b : STD_LOGIC_VECTOR (22 downto 0);
    signal expY_uid10_fpAddTest_b : STD_LOGIC_VECTOR (7 downto 0);
    signal sigY_uid11_fpAddTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal ypn_uid12_fpAddTest_q : STD_LOGIC_VECTOR (31 downto 0);
    signal aSig_uid16_fpAddTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal aSig_uid16_fpAddTest_q : STD_LOGIC_VECTOR (31 downto 0);
    signal bSig_uid17_fpAddTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal bSig_uid17_fpAddTest_q : STD_LOGIC_VECTOR (31 downto 0);
    signal cstAllOWE_uid18_fpAddTest_q : STD_LOGIC_VECTOR (7 downto 0);
    signal cstZeroWF_uid19_fpAddTest_q : STD_LOGIC_VECTOR (22 downto 0);
    signal cstAllZWE_uid20_fpAddTest_q : STD_LOGIC_VECTOR (7 downto 0);
    signal exp_aSig_uid21_fpAddTest_in : STD_LOGIC_VECTOR (30 downto 0);
    signal exp_aSig_uid21_fpAddTest_b : STD_LOGIC_VECTOR (7 downto 0);
    signal frac_aSig_uid22_fpAddTest_in : STD_LOGIC_VECTOR (22 downto 0);
    signal frac_aSig_uid22_fpAddTest_b : STD_LOGIC_VECTOR (22 downto 0);
    signal excZ_aSig_uid16_uid23_fpAddTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal excZ_aSig_uid16_uid23_fpAddTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal expXIsMax_uid24_fpAddTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal expXIsMax_uid24_fpAddTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal fracXIsZero_uid25_fpAddTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal fracXIsZero_uid25_fpAddTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal fracXIsNotZero_uid26_fpAddTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excI_aSig_uid27_fpAddTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal excI_aSig_uid27_fpAddTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excN_aSig_uid28_fpAddTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal excN_aSig_uid28_fpAddTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal invExpXIsMax_uid29_fpAddTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal InvExpXIsZero_uid30_fpAddTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excR_aSig_uid31_fpAddTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal excR_aSig_uid31_fpAddTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal exp_bSig_uid35_fpAddTest_in : STD_LOGIC_VECTOR (30 downto 0);
    signal exp_bSig_uid35_fpAddTest_b : STD_LOGIC_VECTOR (7 downto 0);
    signal frac_bSig_uid36_fpAddTest_in : STD_LOGIC_VECTOR (22 downto 0);
    signal frac_bSig_uid36_fpAddTest_b : STD_LOGIC_VECTOR (22 downto 0);
    signal excZ_bSig_uid17_uid37_fpAddTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal excZ_bSig_uid17_uid37_fpAddTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal expXIsMax_uid38_fpAddTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal expXIsMax_uid38_fpAddTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal fracXIsZero_uid39_fpAddTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal fracXIsZero_uid39_fpAddTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal fracXIsNotZero_uid40_fpAddTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excI_bSig_uid41_fpAddTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal excI_bSig_uid41_fpAddTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excN_bSig_uid42_fpAddTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal excN_bSig_uid42_fpAddTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal invExpXIsMax_uid43_fpAddTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal InvExpXIsZero_uid44_fpAddTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excR_bSig_uid45_fpAddTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal excR_bSig_uid45_fpAddTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal sigA_uid50_fpAddTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal sigB_uid51_fpAddTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal effSub_uid52_fpAddTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal fracBz_uid56_fpAddTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal fracBz_uid56_fpAddTest_q : STD_LOGIC_VECTOR (22 downto 0);
    signal oFracB_uid59_fpAddTest_q : STD_LOGIC_VECTOR (23 downto 0);
    signal expAmExpB_uid60_fpAddTest_a : STD_LOGIC_VECTOR (8 downto 0);
    signal expAmExpB_uid60_fpAddTest_b : STD_LOGIC_VECTOR (8 downto 0);
    signal expAmExpB_uid60_fpAddTest_o : STD_LOGIC_VECTOR (8 downto 0);
    signal expAmExpB_uid60_fpAddTest_q : STD_LOGIC_VECTOR (8 downto 0);
    signal oFracA_uid64_fpAddTest_q : STD_LOGIC_VECTOR (23 downto 0);
    signal oFracAE_uid65_fpAddTest_q : STD_LOGIC_VECTOR (26 downto 0);
    signal oFracBR_uid67_fpAddTest_q : STD_LOGIC_VECTOR (26 downto 0);
    signal oFracBREX_uid68_fpAddTest_b : STD_LOGIC_VECTOR (26 downto 0);
    signal oFracBREX_uid68_fpAddTest_qi : STD_LOGIC_VECTOR (26 downto 0);
    signal oFracBREX_uid68_fpAddTest_q : STD_LOGIC_VECTOR (26 downto 0);
    signal oFracBREXC2_uid69_fpAddTest_a : STD_LOGIC_VECTOR (27 downto 0);
    signal oFracBREXC2_uid69_fpAddTest_b : STD_LOGIC_VECTOR (27 downto 0);
    signal oFracBREXC2_uid69_fpAddTest_o : STD_LOGIC_VECTOR (27 downto 0);
    signal oFracBREXC2_uid69_fpAddTest_q : STD_LOGIC_VECTOR (27 downto 0);
    signal oFracBREXC2_uid70_fpAddTest_in : STD_LOGIC_VECTOR (26 downto 0);
    signal oFracBREXC2_uid70_fpAddTest_b : STD_LOGIC_VECTOR (26 downto 0);
    signal fracAddResult_uid72_fpAddTest_a : STD_LOGIC_VECTOR (27 downto 0);
    signal fracAddResult_uid72_fpAddTest_b : STD_LOGIC_VECTOR (27 downto 0);
    signal fracAddResult_uid72_fpAddTest_o : STD_LOGIC_VECTOR (27 downto 0);
    signal fracAddResult_uid72_fpAddTest_q : STD_LOGIC_VECTOR (27 downto 0);
    signal fracAddResultNoSignExt_uid73_fpAddTest_in : STD_LOGIC_VECTOR (26 downto 0);
    signal fracAddResultNoSignExt_uid73_fpAddTest_b : STD_LOGIC_VECTOR (26 downto 0);
    signal cAmA_uid76_fpAddTest_q : STD_LOGIC_VECTOR (4 downto 0);
    signal aMinusA_uid77_fpAddTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal aMinusA_uid77_fpAddTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal expInc_uid78_fpAddTest_a : STD_LOGIC_VECTOR (8 downto 0);
    signal expInc_uid78_fpAddTest_b : STD_LOGIC_VECTOR (8 downto 0);
    signal expInc_uid78_fpAddTest_o : STD_LOGIC_VECTOR (8 downto 0);
    signal expInc_uid78_fpAddTest_q : STD_LOGIC_VECTOR (8 downto 0);
    signal expPostNorm_uid79_fpAddTest_a : STD_LOGIC_VECTOR (9 downto 0);
    signal expPostNorm_uid79_fpAddTest_b : STD_LOGIC_VECTOR (9 downto 0);
    signal expPostNorm_uid79_fpAddTest_o : STD_LOGIC_VECTOR (9 downto 0);
    signal expPostNorm_uid79_fpAddTest_q : STD_LOGIC_VECTOR (9 downto 0);
    signal fracPostNormRndRange_uid80_fpAddTest_in : STD_LOGIC_VECTOR (25 downto 0);
    signal fracPostNormRndRange_uid80_fpAddTest_b : STD_LOGIC_VECTOR (23 downto 0);
    signal expFracR_uid81_fpAddTest_q : STD_LOGIC_VECTOR (33 downto 0);
    signal wEP2AllOwE_uid82_fpAddTest_q : STD_LOGIC_VECTOR (9 downto 0);
    signal rndExp_uid83_fpAddTest_b : STD_LOGIC_VECTOR (9 downto 0);
    signal rOvf_uid84_fpAddTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal rOvf_uid84_fpAddTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal rUdf_uid85_fpAddTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal fracRPreExc_uid86_fpAddTest_in : STD_LOGIC_VECTOR (23 downto 0);
    signal fracRPreExc_uid86_fpAddTest_b : STD_LOGIC_VECTOR (22 downto 0);
    signal expRPreExc_uid87_fpAddTest_in : STD_LOGIC_VECTOR (31 downto 0);
    signal expRPreExc_uid87_fpAddTest_b : STD_LOGIC_VECTOR (7 downto 0);
    signal regInputs_uid88_fpAddTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excRZeroVInC_uid89_fpAddTest_q : STD_LOGIC_VECTOR (4 downto 0);
    signal excRZero_uid90_fpAddTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal rInfOvf_uid91_fpAddTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excRInfVInC_uid92_fpAddTest_q : STD_LOGIC_VECTOR (5 downto 0);
    signal excRInf_uid93_fpAddTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excRNaN2_uid94_fpAddTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excAIBISub_uid95_fpAddTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excRNaN_uid96_fpAddTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal concExc_uid97_fpAddTest_q : STD_LOGIC_VECTOR (2 downto 0);
    signal excREnc_uid98_fpAddTest_q : STD_LOGIC_VECTOR (1 downto 0);
    signal invAMinusA_uid99_fpAddTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal signRReg_uid100_fpAddTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal sigBBInf_uid101_fpAddTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal sigAAInf_uid102_fpAddTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal signRInf_uid103_fpAddTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excAZBZSigASigB_uid104_fpAddTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excBZARSigA_uid105_fpAddTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal signRZero_uid106_fpAddTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal signRInfRZRReg_uid107_fpAddTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal signRInfRZRReg_uid107_fpAddTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal invExcRNaN_uid108_fpAddTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal signRPostExc_uid109_fpAddTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal signRPostExc_uid109_fpAddTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal oneFracRPostExc2_uid110_fpAddTest_q : STD_LOGIC_VECTOR (22 downto 0);
    signal fracRPostExc_uid113_fpAddTest_s : STD_LOGIC_VECTOR (1 downto 0);
    signal fracRPostExc_uid113_fpAddTest_q : STD_LOGIC_VECTOR (22 downto 0);
    signal expRPostExc_uid117_fpAddTest_s : STD_LOGIC_VECTOR (1 downto 0);
    signal expRPostExc_uid117_fpAddTest_q : STD_LOGIC_VECTOR (7 downto 0);
    signal R_uid118_fpAddTest_q : STD_LOGIC_VECTOR (31 downto 0);
    signal zs_uid120_lzCountVal_uid74_fpAddTest_q : STD_LOGIC_VECTOR (15 downto 0);
    signal rVStage_uid121_lzCountVal_uid74_fpAddTest_b : STD_LOGIC_VECTOR (15 downto 0);
    signal vCount_uid122_lzCountVal_uid74_fpAddTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal mO_uid123_lzCountVal_uid74_fpAddTest_q : STD_LOGIC_VECTOR (4 downto 0);
    signal vStage_uid124_lzCountVal_uid74_fpAddTest_in : STD_LOGIC_VECTOR (10 downto 0);
    signal vStage_uid124_lzCountVal_uid74_fpAddTest_b : STD_LOGIC_VECTOR (10 downto 0);
    signal cStage_uid125_lzCountVal_uid74_fpAddTest_q : STD_LOGIC_VECTOR (15 downto 0);
    signal vStagei_uid127_lzCountVal_uid74_fpAddTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid127_lzCountVal_uid74_fpAddTest_q : STD_LOGIC_VECTOR (15 downto 0);
    signal vCount_uid130_lzCountVal_uid74_fpAddTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid133_lzCountVal_uid74_fpAddTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid133_lzCountVal_uid74_fpAddTest_q : STD_LOGIC_VECTOR (7 downto 0);
    signal zs_uid134_lzCountVal_uid74_fpAddTest_q : STD_LOGIC_VECTOR (3 downto 0);
    signal vCount_uid136_lzCountVal_uid74_fpAddTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid139_lzCountVal_uid74_fpAddTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid139_lzCountVal_uid74_fpAddTest_q : STD_LOGIC_VECTOR (3 downto 0);
    signal zs_uid140_lzCountVal_uid74_fpAddTest_q : STD_LOGIC_VECTOR (1 downto 0);
    signal vCount_uid142_lzCountVal_uid74_fpAddTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal vCount_uid142_lzCountVal_uid74_fpAddTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid145_lzCountVal_uid74_fpAddTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid145_lzCountVal_uid74_fpAddTest_q : STD_LOGIC_VECTOR (1 downto 0);
    signal rVStage_uid147_lzCountVal_uid74_fpAddTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal vCount_uid148_lzCountVal_uid74_fpAddTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal r_uid149_lzCountVal_uid74_fpAddTest_q : STD_LOGIC_VECTOR (4 downto 0);
    signal xMSB_uid151_alignmentShifter_uid71_fpAddTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal shiftedOut_uid154_alignmentShifter_uid71_fpAddTest_a : STD_LOGIC_VECTOR (10 downto 0);
    signal shiftedOut_uid154_alignmentShifter_uid71_fpAddTest_b : STD_LOGIC_VECTOR (10 downto 0);
    signal shiftedOut_uid154_alignmentShifter_uid71_fpAddTest_o : STD_LOGIC_VECTOR (10 downto 0);
    signal shiftedOut_uid154_alignmentShifter_uid71_fpAddTest_n : STD_LOGIC_VECTOR (0 downto 0);
    signal seMsb_to8_uid155_in : STD_LOGIC_VECTOR (7 downto 0);
    signal seMsb_to8_uid155_b : STD_LOGIC_VECTOR (7 downto 0);
    signal rightShiftStage0Idx1Rng8_uid156_alignmentShifter_uid71_fpAddTest_b : STD_LOGIC_VECTOR (18 downto 0);
    signal rightShiftStage0Idx1_uid157_alignmentShifter_uid71_fpAddTest_q : STD_LOGIC_VECTOR (26 downto 0);
    signal seMsb_to16_uid158_in : STD_LOGIC_VECTOR (15 downto 0);
    signal seMsb_to16_uid158_b : STD_LOGIC_VECTOR (15 downto 0);
    signal rightShiftStage0Idx2Rng16_uid159_alignmentShifter_uid71_fpAddTest_b : STD_LOGIC_VECTOR (10 downto 0);
    signal rightShiftStage0Idx2_uid160_alignmentShifter_uid71_fpAddTest_q : STD_LOGIC_VECTOR (26 downto 0);
    signal seMsb_to24_uid161_in : STD_LOGIC_VECTOR (23 downto 0);
    signal seMsb_to24_uid161_b : STD_LOGIC_VECTOR (23 downto 0);
    signal rightShiftStage0Idx3Rng24_uid162_alignmentShifter_uid71_fpAddTest_b : STD_LOGIC_VECTOR (2 downto 0);
    signal rightShiftStage0Idx3_uid163_alignmentShifter_uid71_fpAddTest_q : STD_LOGIC_VECTOR (26 downto 0);
    signal rightShiftStage0_uid165_alignmentShifter_uid71_fpAddTest_s : STD_LOGIC_VECTOR (1 downto 0);
    signal rightShiftStage0_uid165_alignmentShifter_uid71_fpAddTest_q : STD_LOGIC_VECTOR (26 downto 0);
    signal seMsb_to2_uid166_in : STD_LOGIC_VECTOR (1 downto 0);
    signal seMsb_to2_uid166_b : STD_LOGIC_VECTOR (1 downto 0);
    signal rightShiftStage1Idx1Rng2_uid167_alignmentShifter_uid71_fpAddTest_b : STD_LOGIC_VECTOR (24 downto 0);
    signal rightShiftStage1Idx1_uid168_alignmentShifter_uid71_fpAddTest_q : STD_LOGIC_VECTOR (26 downto 0);
    signal seMsb_to4_uid169_in : STD_LOGIC_VECTOR (3 downto 0);
    signal seMsb_to4_uid169_b : STD_LOGIC_VECTOR (3 downto 0);
    signal rightShiftStage1Idx2Rng4_uid170_alignmentShifter_uid71_fpAddTest_b : STD_LOGIC_VECTOR (22 downto 0);
    signal rightShiftStage1Idx2_uid171_alignmentShifter_uid71_fpAddTest_q : STD_LOGIC_VECTOR (26 downto 0);
    signal seMsb_to6_uid172_in : STD_LOGIC_VECTOR (5 downto 0);
    signal seMsb_to6_uid172_b : STD_LOGIC_VECTOR (5 downto 0);
    signal rightShiftStage1Idx3Rng6_uid173_alignmentShifter_uid71_fpAddTest_b : STD_LOGIC_VECTOR (20 downto 0);
    signal rightShiftStage1Idx3_uid174_alignmentShifter_uid71_fpAddTest_q : STD_LOGIC_VECTOR (26 downto 0);
    signal rightShiftStage1_uid176_alignmentShifter_uid71_fpAddTest_s : STD_LOGIC_VECTOR (1 downto 0);
    signal rightShiftStage1_uid176_alignmentShifter_uid71_fpAddTest_q : STD_LOGIC_VECTOR (26 downto 0);
    signal rightShiftStage2Idx1Rng1_uid177_alignmentShifter_uid71_fpAddTest_b : STD_LOGIC_VECTOR (25 downto 0);
    signal rightShiftStage2Idx1_uid178_alignmentShifter_uid71_fpAddTest_q : STD_LOGIC_VECTOR (26 downto 0);
    signal rightShiftStage2_uid180_alignmentShifter_uid71_fpAddTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal rightShiftStage2_uid180_alignmentShifter_uid71_fpAddTest_q : STD_LOGIC_VECTOR (26 downto 0);
    signal shiftOutConstant_to27_uid181_in : STD_LOGIC_VECTOR (26 downto 0);
    signal shiftOutConstant_to27_uid181_b : STD_LOGIC_VECTOR (26 downto 0);
    signal r_uid183_alignmentShifter_uid71_fpAddTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal r_uid183_alignmentShifter_uid71_fpAddTest_q : STD_LOGIC_VECTOR (26 downto 0);
    signal leftShiftStage0Idx1Rng8_uid188_fracPostNorm_uid75_fpAddTest_in : STD_LOGIC_VECTOR (18 downto 0);
    signal leftShiftStage0Idx1Rng8_uid188_fracPostNorm_uid75_fpAddTest_b : STD_LOGIC_VECTOR (18 downto 0);
    signal leftShiftStage0Idx1_uid189_fracPostNorm_uid75_fpAddTest_q : STD_LOGIC_VECTOR (26 downto 0);
    signal leftShiftStage0Idx2_uid192_fracPostNorm_uid75_fpAddTest_q : STD_LOGIC_VECTOR (26 downto 0);
    signal leftShiftStage0Idx3Pad24_uid193_fracPostNorm_uid75_fpAddTest_q : STD_LOGIC_VECTOR (23 downto 0);
    signal leftShiftStage0Idx3Rng24_uid194_fracPostNorm_uid75_fpAddTest_in : STD_LOGIC_VECTOR (2 downto 0);
    signal leftShiftStage0Idx3Rng24_uid194_fracPostNorm_uid75_fpAddTest_b : STD_LOGIC_VECTOR (2 downto 0);
    signal leftShiftStage0Idx3_uid195_fracPostNorm_uid75_fpAddTest_q : STD_LOGIC_VECTOR (26 downto 0);
    signal leftShiftStage0_uid197_fracPostNorm_uid75_fpAddTest_s : STD_LOGIC_VECTOR (1 downto 0);
    signal leftShiftStage0_uid197_fracPostNorm_uid75_fpAddTest_q : STD_LOGIC_VECTOR (26 downto 0);
    signal leftShiftStage1Idx1Rng2_uid199_fracPostNorm_uid75_fpAddTest_in : STD_LOGIC_VECTOR (24 downto 0);
    signal leftShiftStage1Idx1Rng2_uid199_fracPostNorm_uid75_fpAddTest_b : STD_LOGIC_VECTOR (24 downto 0);
    signal leftShiftStage1Idx1_uid200_fracPostNorm_uid75_fpAddTest_q : STD_LOGIC_VECTOR (26 downto 0);
    signal leftShiftStage1Idx2Rng4_uid202_fracPostNorm_uid75_fpAddTest_in : STD_LOGIC_VECTOR (22 downto 0);
    signal leftShiftStage1Idx2Rng4_uid202_fracPostNorm_uid75_fpAddTest_b : STD_LOGIC_VECTOR (22 downto 0);
    signal leftShiftStage1Idx2_uid203_fracPostNorm_uid75_fpAddTest_q : STD_LOGIC_VECTOR (26 downto 0);
    signal leftShiftStage1Idx3Pad6_uid204_fracPostNorm_uid75_fpAddTest_q : STD_LOGIC_VECTOR (5 downto 0);
    signal leftShiftStage1Idx3Rng6_uid205_fracPostNorm_uid75_fpAddTest_in : STD_LOGIC_VECTOR (20 downto 0);
    signal leftShiftStage1Idx3Rng6_uid205_fracPostNorm_uid75_fpAddTest_b : STD_LOGIC_VECTOR (20 downto 0);
    signal leftShiftStage1Idx3_uid206_fracPostNorm_uid75_fpAddTest_q : STD_LOGIC_VECTOR (26 downto 0);
    signal leftShiftStage1_uid208_fracPostNorm_uid75_fpAddTest_s : STD_LOGIC_VECTOR (1 downto 0);
    signal leftShiftStage1_uid208_fracPostNorm_uid75_fpAddTest_q : STD_LOGIC_VECTOR (26 downto 0);
    signal leftShiftStage2Idx1Rng1_uid210_fracPostNorm_uid75_fpAddTest_in : STD_LOGIC_VECTOR (25 downto 0);
    signal leftShiftStage2Idx1Rng1_uid210_fracPostNorm_uid75_fpAddTest_b : STD_LOGIC_VECTOR (25 downto 0);
    signal leftShiftStage2Idx1_uid211_fracPostNorm_uid75_fpAddTest_q : STD_LOGIC_VECTOR (26 downto 0);
    signal leftShiftStage2_uid213_fracPostNorm_uid75_fpAddTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal leftShiftStage2_uid213_fracPostNorm_uid75_fpAddTest_q : STD_LOGIC_VECTOR (26 downto 0);
    signal rightShiftStageSel4Dto3_uid164_alignmentShifter_uid71_fpAddTest_merged_bit_select_in : STD_LOGIC_VECTOR (4 downto 0);
    signal rightShiftStageSel4Dto3_uid164_alignmentShifter_uid71_fpAddTest_merged_bit_select_b : STD_LOGIC_VECTOR (1 downto 0);
    signal rightShiftStageSel4Dto3_uid164_alignmentShifter_uid71_fpAddTest_merged_bit_select_c : STD_LOGIC_VECTOR (1 downto 0);
    signal rightShiftStageSel4Dto3_uid164_alignmentShifter_uid71_fpAddTest_merged_bit_select_d : STD_LOGIC_VECTOR (0 downto 0);
    signal rVStage_uid129_lzCountVal_uid74_fpAddTest_merged_bit_select_b : STD_LOGIC_VECTOR (7 downto 0);
    signal rVStage_uid129_lzCountVal_uid74_fpAddTest_merged_bit_select_c : STD_LOGIC_VECTOR (7 downto 0);
    signal rVStage_uid135_lzCountVal_uid74_fpAddTest_merged_bit_select_b : STD_LOGIC_VECTOR (3 downto 0);
    signal rVStage_uid135_lzCountVal_uid74_fpAddTest_merged_bit_select_c : STD_LOGIC_VECTOR (3 downto 0);
    signal rVStage_uid141_lzCountVal_uid74_fpAddTest_merged_bit_select_b : STD_LOGIC_VECTOR (1 downto 0);
    signal rVStage_uid141_lzCountVal_uid74_fpAddTest_merged_bit_select_c : STD_LOGIC_VECTOR (1 downto 0);
    signal leftShiftStageSel4Dto3_uid196_fracPostNorm_uid75_fpAddTest_merged_bit_select_b : STD_LOGIC_VECTOR (1 downto 0);
    signal leftShiftStageSel4Dto3_uid196_fracPostNorm_uid75_fpAddTest_merged_bit_select_c : STD_LOGIC_VECTOR (1 downto 0);
    signal leftShiftStageSel4Dto3_uid196_fracPostNorm_uid75_fpAddTest_merged_bit_select_d : STD_LOGIC_VECTOR (0 downto 0);
    signal redist0_leftShiftStageSel4Dto3_uid196_fracPostNorm_uid75_fpAddTest_merged_bit_select_d_1_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist1_rVStage_uid141_lzCountVal_uid74_fpAddTest_merged_bit_select_b_1_q : STD_LOGIC_VECTOR (1 downto 0);
    signal redist2_rVStage_uid141_lzCountVal_uid74_fpAddTest_merged_bit_select_c_1_q : STD_LOGIC_VECTOR (1 downto 0);
    signal redist3_rightShiftStageSel4Dto3_uid164_alignmentShifter_uid71_fpAddTest_merged_bit_select_b_2_q : STD_LOGIC_VECTOR (1 downto 0);
    signal redist4_rightShiftStageSel4Dto3_uid164_alignmentShifter_uid71_fpAddTest_merged_bit_select_c_2_q : STD_LOGIC_VECTOR (1 downto 0);
    signal redist5_rightShiftStageSel4Dto3_uid164_alignmentShifter_uid71_fpAddTest_merged_bit_select_d_2_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist6_shiftedOut_uid154_alignmentShifter_uid71_fpAddTest_n_3_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist7_xMSB_uid151_alignmentShifter_uid71_fpAddTest_b_1_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist8_vCount_uid136_lzCountVal_uid74_fpAddTest_q_1_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist9_vCount_uid130_lzCountVal_uid74_fpAddTest_q_2_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist10_vStage_uid124_lzCountVal_uid74_fpAddTest_b_3_q : STD_LOGIC_VECTOR (10 downto 0);
    signal redist11_vCount_uid122_lzCountVal_uid74_fpAddTest_q_3_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist12_regInputs_uid88_fpAddTest_q_1_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist13_expRPreExc_uid87_fpAddTest_b_2_q : STD_LOGIC_VECTOR (7 downto 0);
    signal redist14_fracRPreExc_uid86_fpAddTest_b_2_q : STD_LOGIC_VECTOR (22 downto 0);
    signal redist15_fracAddResultNoSignExt_uid73_fpAddTest_b_1_q : STD_LOGIC_VECTOR (26 downto 0);
    signal redist16_fracAddResultNoSignExt_uid73_fpAddTest_b_4_q : STD_LOGIC_VECTOR (26 downto 0);
    signal redist17_oFracBREXC2_uid70_fpAddTest_b_1_q : STD_LOGIC_VECTOR (26 downto 0);
    signal redist18_effSub_uid52_fpAddTest_q_1_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist19_effSub_uid52_fpAddTest_q_10_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist20_sigB_uid51_fpAddTest_b_1_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist21_sigB_uid51_fpAddTest_b_10_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist22_sigA_uid50_fpAddTest_b_1_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist23_sigA_uid50_fpAddTest_b_10_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist24_InvExpXIsZero_uid44_fpAddTest_q_8_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist25_excN_bSig_uid42_fpAddTest_q_2_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist26_excI_bSig_uid41_fpAddTest_q_2_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist27_fracXIsZero_uid39_fpAddTest_q_8_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist28_expXIsMax_uid38_fpAddTest_q_9_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist29_excZ_bSig_uid17_uid37_fpAddTest_q_10_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist30_frac_bSig_uid36_fpAddTest_b_1_q : STD_LOGIC_VECTOR (22 downto 0);
    signal redist31_excN_aSig_uid28_fpAddTest_q_2_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist32_excI_aSig_uid27_fpAddTest_q_2_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist33_fracXIsZero_uid25_fpAddTest_q_4_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist34_excZ_aSig_uid16_uid23_fpAddTest_q_2_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist37_xIn_a_1_q : STD_LOGIC_VECTOR (31 downto 0);
    signal redist38_xIn_b_1_q : STD_LOGIC_VECTOR (31 downto 0);
    signal redist35_frac_aSig_uid22_fpAddTest_b_5_outputreg_q : STD_LOGIC_VECTOR (22 downto 0);
    signal redist35_frac_aSig_uid22_fpAddTest_b_5_mem_reset0 : std_logic;
    signal redist35_frac_aSig_uid22_fpAddTest_b_5_mem_ia : STD_LOGIC_VECTOR (22 downto 0);
    signal redist35_frac_aSig_uid22_fpAddTest_b_5_mem_aa : STD_LOGIC_VECTOR (1 downto 0);
    signal redist35_frac_aSig_uid22_fpAddTest_b_5_mem_ab : STD_LOGIC_VECTOR (1 downto 0);
    signal redist35_frac_aSig_uid22_fpAddTest_b_5_mem_iq : STD_LOGIC_VECTOR (22 downto 0);
    signal redist35_frac_aSig_uid22_fpAddTest_b_5_mem_q : STD_LOGIC_VECTOR (22 downto 0);
    signal redist35_frac_aSig_uid22_fpAddTest_b_5_rdcnt_q : STD_LOGIC_VECTOR (1 downto 0);
    signal redist35_frac_aSig_uid22_fpAddTest_b_5_rdcnt_i : UNSIGNED (1 downto 0);
    attribute preserve : boolean;
    attribute preserve of redist35_frac_aSig_uid22_fpAddTest_b_5_rdcnt_i : signal is true;
    signal redist35_frac_aSig_uid22_fpAddTest_b_5_rdcnt_eq : std_logic;
    attribute preserve of redist35_frac_aSig_uid22_fpAddTest_b_5_rdcnt_eq : signal is true;
    signal redist35_frac_aSig_uid22_fpAddTest_b_5_wraddr_q : STD_LOGIC_VECTOR (1 downto 0);
    signal redist35_frac_aSig_uid22_fpAddTest_b_5_mem_last_q : STD_LOGIC_VECTOR (1 downto 0);
    signal redist35_frac_aSig_uid22_fpAddTest_b_5_cmp_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist35_frac_aSig_uid22_fpAddTest_b_5_cmpReg_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist35_frac_aSig_uid22_fpAddTest_b_5_notEnable_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist35_frac_aSig_uid22_fpAddTest_b_5_nor_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist35_frac_aSig_uid22_fpAddTest_b_5_sticky_ena_q : STD_LOGIC_VECTOR (0 downto 0);
    attribute dont_merge : boolean;
    attribute dont_merge of redist35_frac_aSig_uid22_fpAddTest_b_5_sticky_ena_q : signal is true;
    signal redist35_frac_aSig_uid22_fpAddTest_b_5_enaAnd_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist36_exp_aSig_uid21_fpAddTest_b_8_outputreg_q : STD_LOGIC_VECTOR (7 downto 0);
    signal redist36_exp_aSig_uid21_fpAddTest_b_8_mem_reset0 : std_logic;
    signal redist36_exp_aSig_uid21_fpAddTest_b_8_mem_ia : STD_LOGIC_VECTOR (7 downto 0);
    signal redist36_exp_aSig_uid21_fpAddTest_b_8_mem_aa : STD_LOGIC_VECTOR (2 downto 0);
    signal redist36_exp_aSig_uid21_fpAddTest_b_8_mem_ab : STD_LOGIC_VECTOR (2 downto 0);
    signal redist36_exp_aSig_uid21_fpAddTest_b_8_mem_iq : STD_LOGIC_VECTOR (7 downto 0);
    signal redist36_exp_aSig_uid21_fpAddTest_b_8_mem_q : STD_LOGIC_VECTOR (7 downto 0);
    signal redist36_exp_aSig_uid21_fpAddTest_b_8_rdcnt_q : STD_LOGIC_VECTOR (2 downto 0);
    signal redist36_exp_aSig_uid21_fpAddTest_b_8_rdcnt_i : UNSIGNED (2 downto 0);
    attribute preserve of redist36_exp_aSig_uid21_fpAddTest_b_8_rdcnt_i : signal is true;
    signal redist36_exp_aSig_uid21_fpAddTest_b_8_rdcnt_eq : std_logic;
    attribute preserve of redist36_exp_aSig_uid21_fpAddTest_b_8_rdcnt_eq : signal is true;
    signal redist36_exp_aSig_uid21_fpAddTest_b_8_wraddr_q : STD_LOGIC_VECTOR (2 downto 0);
    signal redist36_exp_aSig_uid21_fpAddTest_b_8_mem_last_q : STD_LOGIC_VECTOR (3 downto 0);
    signal redist36_exp_aSig_uid21_fpAddTest_b_8_cmp_b : STD_LOGIC_VECTOR (3 downto 0);
    signal redist36_exp_aSig_uid21_fpAddTest_b_8_cmp_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist36_exp_aSig_uid21_fpAddTest_b_8_cmpReg_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist36_exp_aSig_uid21_fpAddTest_b_8_notEnable_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist36_exp_aSig_uid21_fpAddTest_b_8_nor_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist36_exp_aSig_uid21_fpAddTest_b_8_sticky_ena_q : STD_LOGIC_VECTOR (0 downto 0);
    attribute dont_merge of redist36_exp_aSig_uid21_fpAddTest_b_8_sticky_ena_q : signal is true;
    signal redist36_exp_aSig_uid21_fpAddTest_b_8_enaAnd_q : STD_LOGIC_VECTOR (0 downto 0);

begin


    -- cAmA_uid76_fpAddTest(CONSTANT,75)
    cAmA_uid76_fpAddTest_q <= "11011";

    -- zs_uid120_lzCountVal_uid74_fpAddTest(CONSTANT,119)
    zs_uid120_lzCountVal_uid74_fpAddTest_q <= "0000000000000000";

    -- redist38_xIn_b_1(DELAY,257)
    redist38_xIn_b_1 : dspba_delay
    GENERIC MAP ( width => 32, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => b, xout => redist38_xIn_b_1_q, clk => clk, aclr => areset );

    -- sigY_uid11_fpAddTest(BITSELECT,10)@1
    sigY_uid11_fpAddTest_b <= STD_LOGIC_VECTOR(redist38_xIn_b_1_q(31 downto 31));

    -- expY_uid10_fpAddTest(BITSELECT,9)@1
    expY_uid10_fpAddTest_b <= redist38_xIn_b_1_q(30 downto 23);

    -- fracY_uid9_fpAddTest(BITSELECT,8)@1
    fracY_uid9_fpAddTest_b <= redist38_xIn_b_1_q(22 downto 0);

    -- ypn_uid12_fpAddTest(BITJOIN,11)@1
    ypn_uid12_fpAddTest_q <= sigY_uid11_fpAddTest_b & expY_uid10_fpAddTest_b & fracY_uid9_fpAddTest_b;

    -- redist37_xIn_a_1(DELAY,256)
    redist37_xIn_a_1 : dspba_delay
    GENERIC MAP ( width => 32, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => a, xout => redist37_xIn_a_1_q, clk => clk, aclr => areset );

    -- GND(CONSTANT,0)
    GND_q <= "0";

    -- expFracY_uid7_fpAddTest(BITSELECT,6)@0
    expFracY_uid7_fpAddTest_b <= b(30 downto 0);

    -- expFracX_uid6_fpAddTest(BITSELECT,5)@0
    expFracX_uid6_fpAddTest_b <= a(30 downto 0);

    -- xGTEy_uid8_fpAddTest(COMPARE,7)@0 + 1
    xGTEy_uid8_fpAddTest_a <= STD_LOGIC_VECTOR("00" & expFracX_uid6_fpAddTest_b);
    xGTEy_uid8_fpAddTest_b <= STD_LOGIC_VECTOR("00" & expFracY_uid7_fpAddTest_b);
    xGTEy_uid8_fpAddTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            xGTEy_uid8_fpAddTest_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            xGTEy_uid8_fpAddTest_o <= STD_LOGIC_VECTOR(UNSIGNED(xGTEy_uid8_fpAddTest_a) - UNSIGNED(xGTEy_uid8_fpAddTest_b));
        END IF;
    END PROCESS;
    xGTEy_uid8_fpAddTest_n(0) <= not (xGTEy_uid8_fpAddTest_o(32));

    -- bSig_uid17_fpAddTest(MUX,16)@1
    bSig_uid17_fpAddTest_s <= xGTEy_uid8_fpAddTest_n;
    bSig_uid17_fpAddTest_combproc: PROCESS (bSig_uid17_fpAddTest_s, redist37_xIn_a_1_q, ypn_uid12_fpAddTest_q)
    BEGIN
        CASE (bSig_uid17_fpAddTest_s) IS
            WHEN "0" => bSig_uid17_fpAddTest_q <= redist37_xIn_a_1_q;
            WHEN "1" => bSig_uid17_fpAddTest_q <= ypn_uid12_fpAddTest_q;
            WHEN OTHERS => bSig_uid17_fpAddTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- sigB_uid51_fpAddTest(BITSELECT,50)@1
    sigB_uid51_fpAddTest_b <= STD_LOGIC_VECTOR(bSig_uid17_fpAddTest_q(31 downto 31));

    -- redist20_sigB_uid51_fpAddTest_b_1(DELAY,239)
    redist20_sigB_uid51_fpAddTest_b_1 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => sigB_uid51_fpAddTest_b, xout => redist20_sigB_uid51_fpAddTest_b_1_q, clk => clk, aclr => areset );

    -- aSig_uid16_fpAddTest(MUX,15)@1
    aSig_uid16_fpAddTest_s <= xGTEy_uid8_fpAddTest_n;
    aSig_uid16_fpAddTest_combproc: PROCESS (aSig_uid16_fpAddTest_s, ypn_uid12_fpAddTest_q, redist37_xIn_a_1_q)
    BEGIN
        CASE (aSig_uid16_fpAddTest_s) IS
            WHEN "0" => aSig_uid16_fpAddTest_q <= ypn_uid12_fpAddTest_q;
            WHEN "1" => aSig_uid16_fpAddTest_q <= redist37_xIn_a_1_q;
            WHEN OTHERS => aSig_uid16_fpAddTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- sigA_uid50_fpAddTest(BITSELECT,49)@1
    sigA_uid50_fpAddTest_b <= STD_LOGIC_VECTOR(aSig_uid16_fpAddTest_q(31 downto 31));

    -- redist22_sigA_uid50_fpAddTest_b_1(DELAY,241)
    redist22_sigA_uid50_fpAddTest_b_1 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => sigA_uid50_fpAddTest_b, xout => redist22_sigA_uid50_fpAddTest_b_1_q, clk => clk, aclr => areset );

    -- effSub_uid52_fpAddTest(LOGICAL,51)@2
    effSub_uid52_fpAddTest_q <= redist22_sigA_uid50_fpAddTest_b_1_q xor redist20_sigB_uid51_fpAddTest_b_1_q;

    -- redist18_effSub_uid52_fpAddTest_q_1(DELAY,237)
    redist18_effSub_uid52_fpAddTest_q_1 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => effSub_uid52_fpAddTest_q, xout => redist18_effSub_uid52_fpAddTest_q_1_q, clk => clk, aclr => areset );

    -- cstAllZWE_uid20_fpAddTest(CONSTANT,19)
    cstAllZWE_uid20_fpAddTest_q <= "00000000";

    -- exp_bSig_uid35_fpAddTest(BITSELECT,34)@1
    exp_bSig_uid35_fpAddTest_in <= bSig_uid17_fpAddTest_q(30 downto 0);
    exp_bSig_uid35_fpAddTest_b <= exp_bSig_uid35_fpAddTest_in(30 downto 23);

    -- excZ_bSig_uid17_uid37_fpAddTest(LOGICAL,36)@1 + 1
    excZ_bSig_uid17_uid37_fpAddTest_qi <= "1" WHEN exp_bSig_uid35_fpAddTest_b = cstAllZWE_uid20_fpAddTest_q ELSE "0";
    excZ_bSig_uid17_uid37_fpAddTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => excZ_bSig_uid17_uid37_fpAddTest_qi, xout => excZ_bSig_uid17_uid37_fpAddTest_q, clk => clk, aclr => areset );

    -- InvExpXIsZero_uid44_fpAddTest(LOGICAL,43)@2
    InvExpXIsZero_uid44_fpAddTest_q <= not (excZ_bSig_uid17_uid37_fpAddTest_q);

    -- cstZeroWF_uid19_fpAddTest(CONSTANT,18)
    cstZeroWF_uid19_fpAddTest_q <= "00000000000000000000000";

    -- frac_bSig_uid36_fpAddTest(BITSELECT,35)@1
    frac_bSig_uid36_fpAddTest_in <= bSig_uid17_fpAddTest_q(22 downto 0);
    frac_bSig_uid36_fpAddTest_b <= frac_bSig_uid36_fpAddTest_in(22 downto 0);

    -- redist30_frac_bSig_uid36_fpAddTest_b_1(DELAY,249)
    redist30_frac_bSig_uid36_fpAddTest_b_1 : dspba_delay
    GENERIC MAP ( width => 23, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => frac_bSig_uid36_fpAddTest_b, xout => redist30_frac_bSig_uid36_fpAddTest_b_1_q, clk => clk, aclr => areset );

    -- fracBz_uid56_fpAddTest(MUX,55)@2
    fracBz_uid56_fpAddTest_s <= excZ_bSig_uid17_uid37_fpAddTest_q;
    fracBz_uid56_fpAddTest_combproc: PROCESS (fracBz_uid56_fpAddTest_s, redist30_frac_bSig_uid36_fpAddTest_b_1_q, cstZeroWF_uid19_fpAddTest_q)
    BEGIN
        CASE (fracBz_uid56_fpAddTest_s) IS
            WHEN "0" => fracBz_uid56_fpAddTest_q <= redist30_frac_bSig_uid36_fpAddTest_b_1_q;
            WHEN "1" => fracBz_uid56_fpAddTest_q <= cstZeroWF_uid19_fpAddTest_q;
            WHEN OTHERS => fracBz_uid56_fpAddTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- oFracB_uid59_fpAddTest(BITJOIN,58)@2
    oFracB_uid59_fpAddTest_q <= InvExpXIsZero_uid44_fpAddTest_q & fracBz_uid56_fpAddTest_q;

    -- oFracBR_uid67_fpAddTest(BITJOIN,66)@2
    oFracBR_uid67_fpAddTest_q <= GND_q & oFracB_uid59_fpAddTest_q & GND_q & GND_q;

    -- oFracBREX_uid68_fpAddTest(LOGICAL,67)@2 + 1
    oFracBREX_uid68_fpAddTest_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((26 downto 1 => effSub_uid52_fpAddTest_q(0)) & effSub_uid52_fpAddTest_q));
    oFracBREX_uid68_fpAddTest_qi <= oFracBR_uid67_fpAddTest_q xor oFracBREX_uid68_fpAddTest_b;
    oFracBREX_uid68_fpAddTest_delay : dspba_delay
    GENERIC MAP ( width => 27, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => oFracBREX_uid68_fpAddTest_qi, xout => oFracBREX_uid68_fpAddTest_q, clk => clk, aclr => areset );

    -- oFracBREXC2_uid69_fpAddTest(ADD,68)@3
    oFracBREXC2_uid69_fpAddTest_a <= STD_LOGIC_VECTOR("0" & oFracBREX_uid68_fpAddTest_q);
    oFracBREXC2_uid69_fpAddTest_b <= STD_LOGIC_VECTOR("000000000000000000000000000" & redist18_effSub_uid52_fpAddTest_q_1_q);
    oFracBREXC2_uid69_fpAddTest_o <= STD_LOGIC_VECTOR(UNSIGNED(oFracBREXC2_uid69_fpAddTest_a) + UNSIGNED(oFracBREXC2_uid69_fpAddTest_b));
    oFracBREXC2_uid69_fpAddTest_q <= oFracBREXC2_uid69_fpAddTest_o(27 downto 0);

    -- oFracBREXC2_uid70_fpAddTest(BITSELECT,69)@3
    oFracBREXC2_uid70_fpAddTest_in <= STD_LOGIC_VECTOR(oFracBREXC2_uid69_fpAddTest_q(26 downto 0));
    oFracBREXC2_uid70_fpAddTest_b <= STD_LOGIC_VECTOR(oFracBREXC2_uid70_fpAddTest_in(26 downto 0));

    -- redist17_oFracBREXC2_uid70_fpAddTest_b_1(DELAY,236)
    redist17_oFracBREXC2_uid70_fpAddTest_b_1 : dspba_delay
    GENERIC MAP ( width => 27, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => oFracBREXC2_uid70_fpAddTest_b, xout => redist17_oFracBREXC2_uid70_fpAddTest_b_1_q, clk => clk, aclr => areset );

    -- xMSB_uid151_alignmentShifter_uid71_fpAddTest(BITSELECT,150)@4
    xMSB_uid151_alignmentShifter_uid71_fpAddTest_b <= STD_LOGIC_VECTOR(redist17_oFracBREXC2_uid70_fpAddTest_b_1_q(26 downto 26));

    -- redist7_xMSB_uid151_alignmentShifter_uid71_fpAddTest_b_1(DELAY,226)
    redist7_xMSB_uid151_alignmentShifter_uid71_fpAddTest_b_1 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => xMSB_uid151_alignmentShifter_uid71_fpAddTest_b, xout => redist7_xMSB_uid151_alignmentShifter_uid71_fpAddTest_b_1_q, clk => clk, aclr => areset );

    -- shiftOutConstant_to27_uid181(BITSELECT,180)@5
    shiftOutConstant_to27_uid181_in <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((26 downto 1 => redist7_xMSB_uid151_alignmentShifter_uid71_fpAddTest_b_1_q(0)) & redist7_xMSB_uid151_alignmentShifter_uid71_fpAddTest_b_1_q));
    shiftOutConstant_to27_uid181_b <= STD_LOGIC_VECTOR(shiftOutConstant_to27_uid181_in(26 downto 0));

    -- rightShiftStage2Idx1Rng1_uid177_alignmentShifter_uid71_fpAddTest(BITSELECT,176)@4
    rightShiftStage2Idx1Rng1_uid177_alignmentShifter_uid71_fpAddTest_b <= rightShiftStage1_uid176_alignmentShifter_uid71_fpAddTest_q(26 downto 1);

    -- rightShiftStage2Idx1_uid178_alignmentShifter_uid71_fpAddTest(BITJOIN,177)@4
    rightShiftStage2Idx1_uid178_alignmentShifter_uid71_fpAddTest_q <= xMSB_uid151_alignmentShifter_uid71_fpAddTest_b & rightShiftStage2Idx1Rng1_uid177_alignmentShifter_uid71_fpAddTest_b;

    -- seMsb_to6_uid172(BITSELECT,171)@4
    seMsb_to6_uid172_in <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((5 downto 1 => xMSB_uid151_alignmentShifter_uid71_fpAddTest_b(0)) & xMSB_uid151_alignmentShifter_uid71_fpAddTest_b));
    seMsb_to6_uid172_b <= STD_LOGIC_VECTOR(seMsb_to6_uid172_in(5 downto 0));

    -- rightShiftStage1Idx3Rng6_uid173_alignmentShifter_uid71_fpAddTest(BITSELECT,172)@4
    rightShiftStage1Idx3Rng6_uid173_alignmentShifter_uid71_fpAddTest_b <= rightShiftStage0_uid165_alignmentShifter_uid71_fpAddTest_q(26 downto 6);

    -- rightShiftStage1Idx3_uid174_alignmentShifter_uid71_fpAddTest(BITJOIN,173)@4
    rightShiftStage1Idx3_uid174_alignmentShifter_uid71_fpAddTest_q <= seMsb_to6_uid172_b & rightShiftStage1Idx3Rng6_uid173_alignmentShifter_uid71_fpAddTest_b;

    -- seMsb_to4_uid169(BITSELECT,168)@4
    seMsb_to4_uid169_in <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((3 downto 1 => xMSB_uid151_alignmentShifter_uid71_fpAddTest_b(0)) & xMSB_uid151_alignmentShifter_uid71_fpAddTest_b));
    seMsb_to4_uid169_b <= STD_LOGIC_VECTOR(seMsb_to4_uid169_in(3 downto 0));

    -- rightShiftStage1Idx2Rng4_uid170_alignmentShifter_uid71_fpAddTest(BITSELECT,169)@4
    rightShiftStage1Idx2Rng4_uid170_alignmentShifter_uid71_fpAddTest_b <= rightShiftStage0_uid165_alignmentShifter_uid71_fpAddTest_q(26 downto 4);

    -- rightShiftStage1Idx2_uid171_alignmentShifter_uid71_fpAddTest(BITJOIN,170)@4
    rightShiftStage1Idx2_uid171_alignmentShifter_uid71_fpAddTest_q <= seMsb_to4_uid169_b & rightShiftStage1Idx2Rng4_uid170_alignmentShifter_uid71_fpAddTest_b;

    -- seMsb_to2_uid166(BITSELECT,165)@4
    seMsb_to2_uid166_in <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((1 downto 1 => xMSB_uid151_alignmentShifter_uid71_fpAddTest_b(0)) & xMSB_uid151_alignmentShifter_uid71_fpAddTest_b));
    seMsb_to2_uid166_b <= STD_LOGIC_VECTOR(seMsb_to2_uid166_in(1 downto 0));

    -- rightShiftStage1Idx1Rng2_uid167_alignmentShifter_uid71_fpAddTest(BITSELECT,166)@4
    rightShiftStage1Idx1Rng2_uid167_alignmentShifter_uid71_fpAddTest_b <= rightShiftStage0_uid165_alignmentShifter_uid71_fpAddTest_q(26 downto 2);

    -- rightShiftStage1Idx1_uid168_alignmentShifter_uid71_fpAddTest(BITJOIN,167)@4
    rightShiftStage1Idx1_uid168_alignmentShifter_uid71_fpAddTest_q <= seMsb_to2_uid166_b & rightShiftStage1Idx1Rng2_uid167_alignmentShifter_uid71_fpAddTest_b;

    -- seMsb_to24_uid161(BITSELECT,160)@4
    seMsb_to24_uid161_in <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((23 downto 1 => xMSB_uid151_alignmentShifter_uid71_fpAddTest_b(0)) & xMSB_uid151_alignmentShifter_uid71_fpAddTest_b));
    seMsb_to24_uid161_b <= STD_LOGIC_VECTOR(seMsb_to24_uid161_in(23 downto 0));

    -- rightShiftStage0Idx3Rng24_uid162_alignmentShifter_uid71_fpAddTest(BITSELECT,161)@4
    rightShiftStage0Idx3Rng24_uid162_alignmentShifter_uid71_fpAddTest_b <= redist17_oFracBREXC2_uid70_fpAddTest_b_1_q(26 downto 24);

    -- rightShiftStage0Idx3_uid163_alignmentShifter_uid71_fpAddTest(BITJOIN,162)@4
    rightShiftStage0Idx3_uid163_alignmentShifter_uid71_fpAddTest_q <= seMsb_to24_uid161_b & rightShiftStage0Idx3Rng24_uid162_alignmentShifter_uid71_fpAddTest_b;

    -- seMsb_to16_uid158(BITSELECT,157)@4
    seMsb_to16_uid158_in <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((15 downto 1 => xMSB_uid151_alignmentShifter_uid71_fpAddTest_b(0)) & xMSB_uid151_alignmentShifter_uid71_fpAddTest_b));
    seMsb_to16_uid158_b <= STD_LOGIC_VECTOR(seMsb_to16_uid158_in(15 downto 0));

    -- rightShiftStage0Idx2Rng16_uid159_alignmentShifter_uid71_fpAddTest(BITSELECT,158)@4
    rightShiftStage0Idx2Rng16_uid159_alignmentShifter_uid71_fpAddTest_b <= redist17_oFracBREXC2_uid70_fpAddTest_b_1_q(26 downto 16);

    -- rightShiftStage0Idx2_uid160_alignmentShifter_uid71_fpAddTest(BITJOIN,159)@4
    rightShiftStage0Idx2_uid160_alignmentShifter_uid71_fpAddTest_q <= seMsb_to16_uid158_b & rightShiftStage0Idx2Rng16_uid159_alignmentShifter_uid71_fpAddTest_b;

    -- seMsb_to8_uid155(BITSELECT,154)@4
    seMsb_to8_uid155_in <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((7 downto 1 => xMSB_uid151_alignmentShifter_uid71_fpAddTest_b(0)) & xMSB_uid151_alignmentShifter_uid71_fpAddTest_b));
    seMsb_to8_uid155_b <= STD_LOGIC_VECTOR(seMsb_to8_uid155_in(7 downto 0));

    -- rightShiftStage0Idx1Rng8_uid156_alignmentShifter_uid71_fpAddTest(BITSELECT,155)@4
    rightShiftStage0Idx1Rng8_uid156_alignmentShifter_uid71_fpAddTest_b <= redist17_oFracBREXC2_uid70_fpAddTest_b_1_q(26 downto 8);

    -- rightShiftStage0Idx1_uid157_alignmentShifter_uid71_fpAddTest(BITJOIN,156)@4
    rightShiftStage0Idx1_uid157_alignmentShifter_uid71_fpAddTest_q <= seMsb_to8_uid155_b & rightShiftStage0Idx1Rng8_uid156_alignmentShifter_uid71_fpAddTest_b;

    -- exp_aSig_uid21_fpAddTest(BITSELECT,20)@1
    exp_aSig_uid21_fpAddTest_in <= aSig_uid16_fpAddTest_q(30 downto 0);
    exp_aSig_uid21_fpAddTest_b <= exp_aSig_uid21_fpAddTest_in(30 downto 23);

    -- expAmExpB_uid60_fpAddTest(SUB,59)@1 + 1
    expAmExpB_uid60_fpAddTest_a <= STD_LOGIC_VECTOR("0" & exp_aSig_uid21_fpAddTest_b);
    expAmExpB_uid60_fpAddTest_b <= STD_LOGIC_VECTOR("0" & exp_bSig_uid35_fpAddTest_b);
    expAmExpB_uid60_fpAddTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            expAmExpB_uid60_fpAddTest_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            expAmExpB_uid60_fpAddTest_o <= STD_LOGIC_VECTOR(UNSIGNED(expAmExpB_uid60_fpAddTest_a) - UNSIGNED(expAmExpB_uid60_fpAddTest_b));
        END IF;
    END PROCESS;
    expAmExpB_uid60_fpAddTest_q <= expAmExpB_uid60_fpAddTest_o(8 downto 0);

    -- rightShiftStageSel4Dto3_uid164_alignmentShifter_uid71_fpAddTest_merged_bit_select(BITSELECT,214)@2
    rightShiftStageSel4Dto3_uid164_alignmentShifter_uid71_fpAddTest_merged_bit_select_in <= expAmExpB_uid60_fpAddTest_q(4 downto 0);
    rightShiftStageSel4Dto3_uid164_alignmentShifter_uid71_fpAddTest_merged_bit_select_b <= rightShiftStageSel4Dto3_uid164_alignmentShifter_uid71_fpAddTest_merged_bit_select_in(4 downto 3);
    rightShiftStageSel4Dto3_uid164_alignmentShifter_uid71_fpAddTest_merged_bit_select_c <= rightShiftStageSel4Dto3_uid164_alignmentShifter_uid71_fpAddTest_merged_bit_select_in(2 downto 1);
    rightShiftStageSel4Dto3_uid164_alignmentShifter_uid71_fpAddTest_merged_bit_select_d <= rightShiftStageSel4Dto3_uid164_alignmentShifter_uid71_fpAddTest_merged_bit_select_in(0 downto 0);

    -- redist3_rightShiftStageSel4Dto3_uid164_alignmentShifter_uid71_fpAddTest_merged_bit_select_b_2(DELAY,222)
    redist3_rightShiftStageSel4Dto3_uid164_alignmentShifter_uid71_fpAddTest_merged_bit_select_b_2 : dspba_delay
    GENERIC MAP ( width => 2, depth => 2, reset_kind => "ASYNC" )
    PORT MAP ( xin => rightShiftStageSel4Dto3_uid164_alignmentShifter_uid71_fpAddTest_merged_bit_select_b, xout => redist3_rightShiftStageSel4Dto3_uid164_alignmentShifter_uid71_fpAddTest_merged_bit_select_b_2_q, clk => clk, aclr => areset );

    -- rightShiftStage0_uid165_alignmentShifter_uid71_fpAddTest(MUX,164)@4
    rightShiftStage0_uid165_alignmentShifter_uid71_fpAddTest_s <= redist3_rightShiftStageSel4Dto3_uid164_alignmentShifter_uid71_fpAddTest_merged_bit_select_b_2_q;
    rightShiftStage0_uid165_alignmentShifter_uid71_fpAddTest_combproc: PROCESS (rightShiftStage0_uid165_alignmentShifter_uid71_fpAddTest_s, redist17_oFracBREXC2_uid70_fpAddTest_b_1_q, rightShiftStage0Idx1_uid157_alignmentShifter_uid71_fpAddTest_q, rightShiftStage0Idx2_uid160_alignmentShifter_uid71_fpAddTest_q, rightShiftStage0Idx3_uid163_alignmentShifter_uid71_fpAddTest_q)
    BEGIN
        CASE (rightShiftStage0_uid165_alignmentShifter_uid71_fpAddTest_s) IS
            WHEN "00" => rightShiftStage0_uid165_alignmentShifter_uid71_fpAddTest_q <= redist17_oFracBREXC2_uid70_fpAddTest_b_1_q;
            WHEN "01" => rightShiftStage0_uid165_alignmentShifter_uid71_fpAddTest_q <= rightShiftStage0Idx1_uid157_alignmentShifter_uid71_fpAddTest_q;
            WHEN "10" => rightShiftStage0_uid165_alignmentShifter_uid71_fpAddTest_q <= rightShiftStage0Idx2_uid160_alignmentShifter_uid71_fpAddTest_q;
            WHEN "11" => rightShiftStage0_uid165_alignmentShifter_uid71_fpAddTest_q <= rightShiftStage0Idx3_uid163_alignmentShifter_uid71_fpAddTest_q;
            WHEN OTHERS => rightShiftStage0_uid165_alignmentShifter_uid71_fpAddTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- redist4_rightShiftStageSel4Dto3_uid164_alignmentShifter_uid71_fpAddTest_merged_bit_select_c_2(DELAY,223)
    redist4_rightShiftStageSel4Dto3_uid164_alignmentShifter_uid71_fpAddTest_merged_bit_select_c_2 : dspba_delay
    GENERIC MAP ( width => 2, depth => 2, reset_kind => "ASYNC" )
    PORT MAP ( xin => rightShiftStageSel4Dto3_uid164_alignmentShifter_uid71_fpAddTest_merged_bit_select_c, xout => redist4_rightShiftStageSel4Dto3_uid164_alignmentShifter_uid71_fpAddTest_merged_bit_select_c_2_q, clk => clk, aclr => areset );

    -- rightShiftStage1_uid176_alignmentShifter_uid71_fpAddTest(MUX,175)@4
    rightShiftStage1_uid176_alignmentShifter_uid71_fpAddTest_s <= redist4_rightShiftStageSel4Dto3_uid164_alignmentShifter_uid71_fpAddTest_merged_bit_select_c_2_q;
    rightShiftStage1_uid176_alignmentShifter_uid71_fpAddTest_combproc: PROCESS (rightShiftStage1_uid176_alignmentShifter_uid71_fpAddTest_s, rightShiftStage0_uid165_alignmentShifter_uid71_fpAddTest_q, rightShiftStage1Idx1_uid168_alignmentShifter_uid71_fpAddTest_q, rightShiftStage1Idx2_uid171_alignmentShifter_uid71_fpAddTest_q, rightShiftStage1Idx3_uid174_alignmentShifter_uid71_fpAddTest_q)
    BEGIN
        CASE (rightShiftStage1_uid176_alignmentShifter_uid71_fpAddTest_s) IS
            WHEN "00" => rightShiftStage1_uid176_alignmentShifter_uid71_fpAddTest_q <= rightShiftStage0_uid165_alignmentShifter_uid71_fpAddTest_q;
            WHEN "01" => rightShiftStage1_uid176_alignmentShifter_uid71_fpAddTest_q <= rightShiftStage1Idx1_uid168_alignmentShifter_uid71_fpAddTest_q;
            WHEN "10" => rightShiftStage1_uid176_alignmentShifter_uid71_fpAddTest_q <= rightShiftStage1Idx2_uid171_alignmentShifter_uid71_fpAddTest_q;
            WHEN "11" => rightShiftStage1_uid176_alignmentShifter_uid71_fpAddTest_q <= rightShiftStage1Idx3_uid174_alignmentShifter_uid71_fpAddTest_q;
            WHEN OTHERS => rightShiftStage1_uid176_alignmentShifter_uid71_fpAddTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- redist5_rightShiftStageSel4Dto3_uid164_alignmentShifter_uid71_fpAddTest_merged_bit_select_d_2(DELAY,224)
    redist5_rightShiftStageSel4Dto3_uid164_alignmentShifter_uid71_fpAddTest_merged_bit_select_d_2 : dspba_delay
    GENERIC MAP ( width => 1, depth => 2, reset_kind => "ASYNC" )
    PORT MAP ( xin => rightShiftStageSel4Dto3_uid164_alignmentShifter_uid71_fpAddTest_merged_bit_select_d, xout => redist5_rightShiftStageSel4Dto3_uid164_alignmentShifter_uid71_fpAddTest_merged_bit_select_d_2_q, clk => clk, aclr => areset );

    -- rightShiftStage2_uid180_alignmentShifter_uid71_fpAddTest(MUX,179)@4 + 1
    rightShiftStage2_uid180_alignmentShifter_uid71_fpAddTest_s <= redist5_rightShiftStageSel4Dto3_uid164_alignmentShifter_uid71_fpAddTest_merged_bit_select_d_2_q;
    rightShiftStage2_uid180_alignmentShifter_uid71_fpAddTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            rightShiftStage2_uid180_alignmentShifter_uid71_fpAddTest_q <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (rightShiftStage2_uid180_alignmentShifter_uid71_fpAddTest_s) IS
                WHEN "0" => rightShiftStage2_uid180_alignmentShifter_uid71_fpAddTest_q <= rightShiftStage1_uid176_alignmentShifter_uid71_fpAddTest_q;
                WHEN "1" => rightShiftStage2_uid180_alignmentShifter_uid71_fpAddTest_q <= rightShiftStage2Idx1_uid178_alignmentShifter_uid71_fpAddTest_q;
                WHEN OTHERS => rightShiftStage2_uid180_alignmentShifter_uid71_fpAddTest_q <= (others => '0');
            END CASE;
        END IF;
    END PROCESS;

    -- shiftedOut_uid154_alignmentShifter_uid71_fpAddTest(COMPARE,153)@2 + 1
    shiftedOut_uid154_alignmentShifter_uid71_fpAddTest_a <= STD_LOGIC_VECTOR("00" & expAmExpB_uid60_fpAddTest_q);
    shiftedOut_uid154_alignmentShifter_uid71_fpAddTest_b <= STD_LOGIC_VECTOR("000000" & cAmA_uid76_fpAddTest_q);
    shiftedOut_uid154_alignmentShifter_uid71_fpAddTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            shiftedOut_uid154_alignmentShifter_uid71_fpAddTest_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            shiftedOut_uid154_alignmentShifter_uid71_fpAddTest_o <= STD_LOGIC_VECTOR(UNSIGNED(shiftedOut_uid154_alignmentShifter_uid71_fpAddTest_a) - UNSIGNED(shiftedOut_uid154_alignmentShifter_uid71_fpAddTest_b));
        END IF;
    END PROCESS;
    shiftedOut_uid154_alignmentShifter_uid71_fpAddTest_n(0) <= not (shiftedOut_uid154_alignmentShifter_uid71_fpAddTest_o(10));

    -- redist6_shiftedOut_uid154_alignmentShifter_uid71_fpAddTest_n_3(DELAY,225)
    redist6_shiftedOut_uid154_alignmentShifter_uid71_fpAddTest_n_3 : dspba_delay
    GENERIC MAP ( width => 1, depth => 2, reset_kind => "ASYNC" )
    PORT MAP ( xin => shiftedOut_uid154_alignmentShifter_uid71_fpAddTest_n, xout => redist6_shiftedOut_uid154_alignmentShifter_uid71_fpAddTest_n_3_q, clk => clk, aclr => areset );

    -- r_uid183_alignmentShifter_uid71_fpAddTest(MUX,182)@5 + 1
    r_uid183_alignmentShifter_uid71_fpAddTest_s <= redist6_shiftedOut_uid154_alignmentShifter_uid71_fpAddTest_n_3_q;
    r_uid183_alignmentShifter_uid71_fpAddTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            r_uid183_alignmentShifter_uid71_fpAddTest_q <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (r_uid183_alignmentShifter_uid71_fpAddTest_s) IS
                WHEN "0" => r_uid183_alignmentShifter_uid71_fpAddTest_q <= rightShiftStage2_uid180_alignmentShifter_uid71_fpAddTest_q;
                WHEN "1" => r_uid183_alignmentShifter_uid71_fpAddTest_q <= shiftOutConstant_to27_uid181_b;
                WHEN OTHERS => r_uid183_alignmentShifter_uid71_fpAddTest_q <= (others => '0');
            END CASE;
        END IF;
    END PROCESS;

    -- redist35_frac_aSig_uid22_fpAddTest_b_5_notEnable(LOGICAL,265)
    redist35_frac_aSig_uid22_fpAddTest_b_5_notEnable_q <= STD_LOGIC_VECTOR(not (VCC_q));

    -- redist35_frac_aSig_uid22_fpAddTest_b_5_nor(LOGICAL,266)
    redist35_frac_aSig_uid22_fpAddTest_b_5_nor_q <= not (redist35_frac_aSig_uid22_fpAddTest_b_5_notEnable_q or redist35_frac_aSig_uid22_fpAddTest_b_5_sticky_ena_q);

    -- redist35_frac_aSig_uid22_fpAddTest_b_5_mem_last(CONSTANT,262)
    redist35_frac_aSig_uid22_fpAddTest_b_5_mem_last_q <= "01";

    -- redist35_frac_aSig_uid22_fpAddTest_b_5_cmp(LOGICAL,263)
    redist35_frac_aSig_uid22_fpAddTest_b_5_cmp_q <= "1" WHEN redist35_frac_aSig_uid22_fpAddTest_b_5_mem_last_q = redist35_frac_aSig_uid22_fpAddTest_b_5_rdcnt_q ELSE "0";

    -- redist35_frac_aSig_uid22_fpAddTest_b_5_cmpReg(REG,264)
    redist35_frac_aSig_uid22_fpAddTest_b_5_cmpReg_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist35_frac_aSig_uid22_fpAddTest_b_5_cmpReg_q <= "0";
        ELSIF (clk'EVENT AND clk = '1') THEN
            redist35_frac_aSig_uid22_fpAddTest_b_5_cmpReg_q <= STD_LOGIC_VECTOR(redist35_frac_aSig_uid22_fpAddTest_b_5_cmp_q);
        END IF;
    END PROCESS;

    -- redist35_frac_aSig_uid22_fpAddTest_b_5_sticky_ena(REG,267)
    redist35_frac_aSig_uid22_fpAddTest_b_5_sticky_ena_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist35_frac_aSig_uid22_fpAddTest_b_5_sticky_ena_q <= "0";
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (redist35_frac_aSig_uid22_fpAddTest_b_5_nor_q = "1") THEN
                redist35_frac_aSig_uid22_fpAddTest_b_5_sticky_ena_q <= STD_LOGIC_VECTOR(redist35_frac_aSig_uid22_fpAddTest_b_5_cmpReg_q);
            END IF;
        END IF;
    END PROCESS;

    -- redist35_frac_aSig_uid22_fpAddTest_b_5_enaAnd(LOGICAL,268)
    redist35_frac_aSig_uid22_fpAddTest_b_5_enaAnd_q <= redist35_frac_aSig_uid22_fpAddTest_b_5_sticky_ena_q and VCC_q;

    -- redist35_frac_aSig_uid22_fpAddTest_b_5_rdcnt(COUNTER,260)
    -- low=0, high=2, step=1, init=0
    redist35_frac_aSig_uid22_fpAddTest_b_5_rdcnt_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist35_frac_aSig_uid22_fpAddTest_b_5_rdcnt_i <= TO_UNSIGNED(0, 2);
            redist35_frac_aSig_uid22_fpAddTest_b_5_rdcnt_eq <= '0';
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (redist35_frac_aSig_uid22_fpAddTest_b_5_rdcnt_i = TO_UNSIGNED(1, 2)) THEN
                redist35_frac_aSig_uid22_fpAddTest_b_5_rdcnt_eq <= '1';
            ELSE
                redist35_frac_aSig_uid22_fpAddTest_b_5_rdcnt_eq <= '0';
            END IF;
            IF (redist35_frac_aSig_uid22_fpAddTest_b_5_rdcnt_eq = '1') THEN
                redist35_frac_aSig_uid22_fpAddTest_b_5_rdcnt_i <= redist35_frac_aSig_uid22_fpAddTest_b_5_rdcnt_i + 2;
            ELSE
                redist35_frac_aSig_uid22_fpAddTest_b_5_rdcnt_i <= redist35_frac_aSig_uid22_fpAddTest_b_5_rdcnt_i + 1;
            END IF;
        END IF;
    END PROCESS;
    redist35_frac_aSig_uid22_fpAddTest_b_5_rdcnt_q <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR(RESIZE(redist35_frac_aSig_uid22_fpAddTest_b_5_rdcnt_i, 2)));

    -- frac_aSig_uid22_fpAddTest(BITSELECT,21)@1
    frac_aSig_uid22_fpAddTest_in <= aSig_uid16_fpAddTest_q(22 downto 0);
    frac_aSig_uid22_fpAddTest_b <= frac_aSig_uid22_fpAddTest_in(22 downto 0);

    -- redist35_frac_aSig_uid22_fpAddTest_b_5_wraddr(REG,261)
    redist35_frac_aSig_uid22_fpAddTest_b_5_wraddr_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist35_frac_aSig_uid22_fpAddTest_b_5_wraddr_q <= "10";
        ELSIF (clk'EVENT AND clk = '1') THEN
            redist35_frac_aSig_uid22_fpAddTest_b_5_wraddr_q <= STD_LOGIC_VECTOR(redist35_frac_aSig_uid22_fpAddTest_b_5_rdcnt_q);
        END IF;
    END PROCESS;

    -- redist35_frac_aSig_uid22_fpAddTest_b_5_mem(DUALMEM,259)
    redist35_frac_aSig_uid22_fpAddTest_b_5_mem_ia <= STD_LOGIC_VECTOR(frac_aSig_uid22_fpAddTest_b);
    redist35_frac_aSig_uid22_fpAddTest_b_5_mem_aa <= redist35_frac_aSig_uid22_fpAddTest_b_5_wraddr_q;
    redist35_frac_aSig_uid22_fpAddTest_b_5_mem_ab <= redist35_frac_aSig_uid22_fpAddTest_b_5_rdcnt_q;
    redist35_frac_aSig_uid22_fpAddTest_b_5_mem_reset0 <= areset;
    redist35_frac_aSig_uid22_fpAddTest_b_5_mem_dmem : altera_syncram
    GENERIC MAP (
        ram_block_type => "MLAB",
        operation_mode => "DUAL_PORT",
        width_a => 23,
        widthad_a => 2,
        numwords_a => 3,
        width_b => 23,
        widthad_b => 2,
        numwords_b => 3,
        lpm_type => "altera_syncram",
        width_byteena_a => 1,
        address_reg_b => "CLOCK0",
        indata_reg_b => "CLOCK0",
        rdcontrol_reg_b => "CLOCK0",
        byteena_reg_b => "CLOCK0",
        outdata_reg_b => "CLOCK1",
        outdata_aclr_b => "CLEAR1",
        clock_enable_input_a => "NORMAL",
        clock_enable_input_b => "NORMAL",
        clock_enable_output_b => "NORMAL",
        read_during_write_mode_mixed_ports => "DONT_CARE",
        power_up_uninitialized => "TRUE",
        intended_device_family => "Cyclone V"
    )
    PORT MAP (
        clocken1 => redist35_frac_aSig_uid22_fpAddTest_b_5_enaAnd_q(0),
        clocken0 => VCC_q(0),
        clock0 => clk,
        aclr1 => redist35_frac_aSig_uid22_fpAddTest_b_5_mem_reset0,
        clock1 => clk,
        address_a => redist35_frac_aSig_uid22_fpAddTest_b_5_mem_aa,
        data_a => redist35_frac_aSig_uid22_fpAddTest_b_5_mem_ia,
        wren_a => VCC_q(0),
        address_b => redist35_frac_aSig_uid22_fpAddTest_b_5_mem_ab,
        q_b => redist35_frac_aSig_uid22_fpAddTest_b_5_mem_iq
    );
    redist35_frac_aSig_uid22_fpAddTest_b_5_mem_q <= redist35_frac_aSig_uid22_fpAddTest_b_5_mem_iq(22 downto 0);

    -- redist35_frac_aSig_uid22_fpAddTest_b_5_outputreg(DELAY,258)
    redist35_frac_aSig_uid22_fpAddTest_b_5_outputreg : dspba_delay
    GENERIC MAP ( width => 23, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist35_frac_aSig_uid22_fpAddTest_b_5_mem_q, xout => redist35_frac_aSig_uid22_fpAddTest_b_5_outputreg_q, clk => clk, aclr => areset );

    -- oFracA_uid64_fpAddTest(BITJOIN,63)@6
    oFracA_uid64_fpAddTest_q <= VCC_q & redist35_frac_aSig_uid22_fpAddTest_b_5_outputreg_q;

    -- oFracAE_uid65_fpAddTest(BITJOIN,64)@6
    oFracAE_uid65_fpAddTest_q <= GND_q & oFracA_uid64_fpAddTest_q & GND_q & GND_q;

    -- fracAddResult_uid72_fpAddTest(ADD,71)@6
    fracAddResult_uid72_fpAddTest_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((27 downto 27 => oFracAE_uid65_fpAddTest_q(26)) & oFracAE_uid65_fpAddTest_q));
    fracAddResult_uid72_fpAddTest_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((27 downto 27 => r_uid183_alignmentShifter_uid71_fpAddTest_q(26)) & r_uid183_alignmentShifter_uid71_fpAddTest_q));
    fracAddResult_uid72_fpAddTest_o <= STD_LOGIC_VECTOR(SIGNED(fracAddResult_uid72_fpAddTest_a) + SIGNED(fracAddResult_uid72_fpAddTest_b));
    fracAddResult_uid72_fpAddTest_q <= fracAddResult_uid72_fpAddTest_o(27 downto 0);

    -- fracAddResultNoSignExt_uid73_fpAddTest(BITSELECT,72)@6
    fracAddResultNoSignExt_uid73_fpAddTest_in <= fracAddResult_uid72_fpAddTest_q(26 downto 0);
    fracAddResultNoSignExt_uid73_fpAddTest_b <= fracAddResultNoSignExt_uid73_fpAddTest_in(26 downto 0);

    -- redist15_fracAddResultNoSignExt_uid73_fpAddTest_b_1(DELAY,234)
    redist15_fracAddResultNoSignExt_uid73_fpAddTest_b_1 : dspba_delay
    GENERIC MAP ( width => 27, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => fracAddResultNoSignExt_uid73_fpAddTest_b, xout => redist15_fracAddResultNoSignExt_uid73_fpAddTest_b_1_q, clk => clk, aclr => areset );

    -- rVStage_uid121_lzCountVal_uid74_fpAddTest(BITSELECT,120)@7
    rVStage_uid121_lzCountVal_uid74_fpAddTest_b <= redist15_fracAddResultNoSignExt_uid73_fpAddTest_b_1_q(26 downto 11);

    -- vCount_uid122_lzCountVal_uid74_fpAddTest(LOGICAL,121)@7
    vCount_uid122_lzCountVal_uid74_fpAddTest_q <= "1" WHEN rVStage_uid121_lzCountVal_uid74_fpAddTest_b = zs_uid120_lzCountVal_uid74_fpAddTest_q ELSE "0";

    -- redist11_vCount_uid122_lzCountVal_uid74_fpAddTest_q_3(DELAY,230)
    redist11_vCount_uid122_lzCountVal_uid74_fpAddTest_q_3 : dspba_delay
    GENERIC MAP ( width => 1, depth => 3, reset_kind => "ASYNC" )
    PORT MAP ( xin => vCount_uid122_lzCountVal_uid74_fpAddTest_q, xout => redist11_vCount_uid122_lzCountVal_uid74_fpAddTest_q_3_q, clk => clk, aclr => areset );

    -- vStage_uid124_lzCountVal_uid74_fpAddTest(BITSELECT,123)@7
    vStage_uid124_lzCountVal_uid74_fpAddTest_in <= redist15_fracAddResultNoSignExt_uid73_fpAddTest_b_1_q(10 downto 0);
    vStage_uid124_lzCountVal_uid74_fpAddTest_b <= vStage_uid124_lzCountVal_uid74_fpAddTest_in(10 downto 0);

    -- mO_uid123_lzCountVal_uid74_fpAddTest(CONSTANT,122)
    mO_uid123_lzCountVal_uid74_fpAddTest_q <= "11111";

    -- cStage_uid125_lzCountVal_uid74_fpAddTest(BITJOIN,124)@7
    cStage_uid125_lzCountVal_uid74_fpAddTest_q <= vStage_uid124_lzCountVal_uid74_fpAddTest_b & mO_uid123_lzCountVal_uid74_fpAddTest_q;

    -- vStagei_uid127_lzCountVal_uid74_fpAddTest(MUX,126)@7 + 1
    vStagei_uid127_lzCountVal_uid74_fpAddTest_s <= vCount_uid122_lzCountVal_uid74_fpAddTest_q;
    vStagei_uid127_lzCountVal_uid74_fpAddTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            vStagei_uid127_lzCountVal_uid74_fpAddTest_q <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (vStagei_uid127_lzCountVal_uid74_fpAddTest_s) IS
                WHEN "0" => vStagei_uid127_lzCountVal_uid74_fpAddTest_q <= rVStage_uid121_lzCountVal_uid74_fpAddTest_b;
                WHEN "1" => vStagei_uid127_lzCountVal_uid74_fpAddTest_q <= cStage_uid125_lzCountVal_uid74_fpAddTest_q;
                WHEN OTHERS => vStagei_uid127_lzCountVal_uid74_fpAddTest_q <= (others => '0');
            END CASE;
        END IF;
    END PROCESS;

    -- rVStage_uid129_lzCountVal_uid74_fpAddTest_merged_bit_select(BITSELECT,215)@8
    rVStage_uid129_lzCountVal_uid74_fpAddTest_merged_bit_select_b <= vStagei_uid127_lzCountVal_uid74_fpAddTest_q(15 downto 8);
    rVStage_uid129_lzCountVal_uid74_fpAddTest_merged_bit_select_c <= vStagei_uid127_lzCountVal_uid74_fpAddTest_q(7 downto 0);

    -- vCount_uid130_lzCountVal_uid74_fpAddTest(LOGICAL,129)@8
    vCount_uid130_lzCountVal_uid74_fpAddTest_q <= "1" WHEN rVStage_uid129_lzCountVal_uid74_fpAddTest_merged_bit_select_b = cstAllZWE_uid20_fpAddTest_q ELSE "0";

    -- redist9_vCount_uid130_lzCountVal_uid74_fpAddTest_q_2(DELAY,228)
    redist9_vCount_uid130_lzCountVal_uid74_fpAddTest_q_2 : dspba_delay
    GENERIC MAP ( width => 1, depth => 2, reset_kind => "ASYNC" )
    PORT MAP ( xin => vCount_uid130_lzCountVal_uid74_fpAddTest_q, xout => redist9_vCount_uid130_lzCountVal_uid74_fpAddTest_q_2_q, clk => clk, aclr => areset );

    -- zs_uid134_lzCountVal_uid74_fpAddTest(CONSTANT,133)
    zs_uid134_lzCountVal_uid74_fpAddTest_q <= "0000";

    -- vStagei_uid133_lzCountVal_uid74_fpAddTest(MUX,132)@8 + 1
    vStagei_uid133_lzCountVal_uid74_fpAddTest_s <= vCount_uid130_lzCountVal_uid74_fpAddTest_q;
    vStagei_uid133_lzCountVal_uid74_fpAddTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            vStagei_uid133_lzCountVal_uid74_fpAddTest_q <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (vStagei_uid133_lzCountVal_uid74_fpAddTest_s) IS
                WHEN "0" => vStagei_uid133_lzCountVal_uid74_fpAddTest_q <= rVStage_uid129_lzCountVal_uid74_fpAddTest_merged_bit_select_b;
                WHEN "1" => vStagei_uid133_lzCountVal_uid74_fpAddTest_q <= rVStage_uid129_lzCountVal_uid74_fpAddTest_merged_bit_select_c;
                WHEN OTHERS => vStagei_uid133_lzCountVal_uid74_fpAddTest_q <= (others => '0');
            END CASE;
        END IF;
    END PROCESS;

    -- rVStage_uid135_lzCountVal_uid74_fpAddTest_merged_bit_select(BITSELECT,216)@9
    rVStage_uid135_lzCountVal_uid74_fpAddTest_merged_bit_select_b <= vStagei_uid133_lzCountVal_uid74_fpAddTest_q(7 downto 4);
    rVStage_uid135_lzCountVal_uid74_fpAddTest_merged_bit_select_c <= vStagei_uid133_lzCountVal_uid74_fpAddTest_q(3 downto 0);

    -- vCount_uid136_lzCountVal_uid74_fpAddTest(LOGICAL,135)@9
    vCount_uid136_lzCountVal_uid74_fpAddTest_q <= "1" WHEN rVStage_uid135_lzCountVal_uid74_fpAddTest_merged_bit_select_b = zs_uid134_lzCountVal_uid74_fpAddTest_q ELSE "0";

    -- redist8_vCount_uid136_lzCountVal_uid74_fpAddTest_q_1(DELAY,227)
    redist8_vCount_uid136_lzCountVal_uid74_fpAddTest_q_1 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => vCount_uid136_lzCountVal_uid74_fpAddTest_q, xout => redist8_vCount_uid136_lzCountVal_uid74_fpAddTest_q_1_q, clk => clk, aclr => areset );

    -- zs_uid140_lzCountVal_uid74_fpAddTest(CONSTANT,139)
    zs_uid140_lzCountVal_uid74_fpAddTest_q <= "00";

    -- vStagei_uid139_lzCountVal_uid74_fpAddTest(MUX,138)@9
    vStagei_uid139_lzCountVal_uid74_fpAddTest_s <= vCount_uid136_lzCountVal_uid74_fpAddTest_q;
    vStagei_uid139_lzCountVal_uid74_fpAddTest_combproc: PROCESS (vStagei_uid139_lzCountVal_uid74_fpAddTest_s, rVStage_uid135_lzCountVal_uid74_fpAddTest_merged_bit_select_b, rVStage_uid135_lzCountVal_uid74_fpAddTest_merged_bit_select_c)
    BEGIN
        CASE (vStagei_uid139_lzCountVal_uid74_fpAddTest_s) IS
            WHEN "0" => vStagei_uid139_lzCountVal_uid74_fpAddTest_q <= rVStage_uid135_lzCountVal_uid74_fpAddTest_merged_bit_select_b;
            WHEN "1" => vStagei_uid139_lzCountVal_uid74_fpAddTest_q <= rVStage_uid135_lzCountVal_uid74_fpAddTest_merged_bit_select_c;
            WHEN OTHERS => vStagei_uid139_lzCountVal_uid74_fpAddTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- rVStage_uid141_lzCountVal_uid74_fpAddTest_merged_bit_select(BITSELECT,217)@9
    rVStage_uid141_lzCountVal_uid74_fpAddTest_merged_bit_select_b <= vStagei_uid139_lzCountVal_uid74_fpAddTest_q(3 downto 2);
    rVStage_uid141_lzCountVal_uid74_fpAddTest_merged_bit_select_c <= vStagei_uid139_lzCountVal_uid74_fpAddTest_q(1 downto 0);

    -- vCount_uid142_lzCountVal_uid74_fpAddTest(LOGICAL,141)@9 + 1
    vCount_uid142_lzCountVal_uid74_fpAddTest_qi <= "1" WHEN rVStage_uid141_lzCountVal_uid74_fpAddTest_merged_bit_select_b = zs_uid140_lzCountVal_uid74_fpAddTest_q ELSE "0";
    vCount_uid142_lzCountVal_uid74_fpAddTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => vCount_uid142_lzCountVal_uid74_fpAddTest_qi, xout => vCount_uid142_lzCountVal_uid74_fpAddTest_q, clk => clk, aclr => areset );

    -- redist2_rVStage_uid141_lzCountVal_uid74_fpAddTest_merged_bit_select_c_1(DELAY,221)
    redist2_rVStage_uid141_lzCountVal_uid74_fpAddTest_merged_bit_select_c_1 : dspba_delay
    GENERIC MAP ( width => 2, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => rVStage_uid141_lzCountVal_uid74_fpAddTest_merged_bit_select_c, xout => redist2_rVStage_uid141_lzCountVal_uid74_fpAddTest_merged_bit_select_c_1_q, clk => clk, aclr => areset );

    -- redist1_rVStage_uid141_lzCountVal_uid74_fpAddTest_merged_bit_select_b_1(DELAY,220)
    redist1_rVStage_uid141_lzCountVal_uid74_fpAddTest_merged_bit_select_b_1 : dspba_delay
    GENERIC MAP ( width => 2, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => rVStage_uid141_lzCountVal_uid74_fpAddTest_merged_bit_select_b, xout => redist1_rVStage_uid141_lzCountVal_uid74_fpAddTest_merged_bit_select_b_1_q, clk => clk, aclr => areset );

    -- vStagei_uid145_lzCountVal_uid74_fpAddTest(MUX,144)@10
    vStagei_uid145_lzCountVal_uid74_fpAddTest_s <= vCount_uid142_lzCountVal_uid74_fpAddTest_q;
    vStagei_uid145_lzCountVal_uid74_fpAddTest_combproc: PROCESS (vStagei_uid145_lzCountVal_uid74_fpAddTest_s, redist1_rVStage_uid141_lzCountVal_uid74_fpAddTest_merged_bit_select_b_1_q, redist2_rVStage_uid141_lzCountVal_uid74_fpAddTest_merged_bit_select_c_1_q)
    BEGIN
        CASE (vStagei_uid145_lzCountVal_uid74_fpAddTest_s) IS
            WHEN "0" => vStagei_uid145_lzCountVal_uid74_fpAddTest_q <= redist1_rVStage_uid141_lzCountVal_uid74_fpAddTest_merged_bit_select_b_1_q;
            WHEN "1" => vStagei_uid145_lzCountVal_uid74_fpAddTest_q <= redist2_rVStage_uid141_lzCountVal_uid74_fpAddTest_merged_bit_select_c_1_q;
            WHEN OTHERS => vStagei_uid145_lzCountVal_uid74_fpAddTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- rVStage_uid147_lzCountVal_uid74_fpAddTest(BITSELECT,146)@10
    rVStage_uid147_lzCountVal_uid74_fpAddTest_b <= vStagei_uid145_lzCountVal_uid74_fpAddTest_q(1 downto 1);

    -- vCount_uid148_lzCountVal_uid74_fpAddTest(LOGICAL,147)@10
    vCount_uid148_lzCountVal_uid74_fpAddTest_q <= "1" WHEN rVStage_uid147_lzCountVal_uid74_fpAddTest_b = GND_q ELSE "0";

    -- r_uid149_lzCountVal_uid74_fpAddTest(BITJOIN,148)@10
    r_uid149_lzCountVal_uid74_fpAddTest_q <= redist11_vCount_uid122_lzCountVal_uid74_fpAddTest_q_3_q & redist9_vCount_uid130_lzCountVal_uid74_fpAddTest_q_2_q & redist8_vCount_uid136_lzCountVal_uid74_fpAddTest_q_1_q & vCount_uid142_lzCountVal_uid74_fpAddTest_q & vCount_uid148_lzCountVal_uid74_fpAddTest_q;

    -- aMinusA_uid77_fpAddTest(LOGICAL,76)@10 + 1
    aMinusA_uid77_fpAddTest_qi <= "1" WHEN r_uid149_lzCountVal_uid74_fpAddTest_q = cAmA_uid76_fpAddTest_q ELSE "0";
    aMinusA_uid77_fpAddTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => aMinusA_uid77_fpAddTest_qi, xout => aMinusA_uid77_fpAddTest_q, clk => clk, aclr => areset );

    -- invAMinusA_uid99_fpAddTest(LOGICAL,98)@11
    invAMinusA_uid99_fpAddTest_q <= not (aMinusA_uid77_fpAddTest_q);

    -- redist23_sigA_uid50_fpAddTest_b_10(DELAY,242)
    redist23_sigA_uid50_fpAddTest_b_10 : dspba_delay
    GENERIC MAP ( width => 1, depth => 9, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist22_sigA_uid50_fpAddTest_b_1_q, xout => redist23_sigA_uid50_fpAddTest_b_10_q, clk => clk, aclr => areset );

    -- cstAllOWE_uid18_fpAddTest(CONSTANT,17)
    cstAllOWE_uid18_fpAddTest_q <= "11111111";

    -- expXIsMax_uid38_fpAddTest(LOGICAL,37)@1 + 1
    expXIsMax_uid38_fpAddTest_qi <= "1" WHEN exp_bSig_uid35_fpAddTest_b = cstAllOWE_uid18_fpAddTest_q ELSE "0";
    expXIsMax_uid38_fpAddTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => expXIsMax_uid38_fpAddTest_qi, xout => expXIsMax_uid38_fpAddTest_q, clk => clk, aclr => areset );

    -- redist28_expXIsMax_uid38_fpAddTest_q_9(DELAY,247)
    redist28_expXIsMax_uid38_fpAddTest_q_9 : dspba_delay
    GENERIC MAP ( width => 1, depth => 8, reset_kind => "ASYNC" )
    PORT MAP ( xin => expXIsMax_uid38_fpAddTest_q, xout => redist28_expXIsMax_uid38_fpAddTest_q_9_q, clk => clk, aclr => areset );

    -- invExpXIsMax_uid43_fpAddTest(LOGICAL,42)@10
    invExpXIsMax_uid43_fpAddTest_q <= not (redist28_expXIsMax_uid38_fpAddTest_q_9_q);

    -- redist24_InvExpXIsZero_uid44_fpAddTest_q_8(DELAY,243)
    redist24_InvExpXIsZero_uid44_fpAddTest_q_8 : dspba_delay
    GENERIC MAP ( width => 1, depth => 8, reset_kind => "ASYNC" )
    PORT MAP ( xin => InvExpXIsZero_uid44_fpAddTest_q, xout => redist24_InvExpXIsZero_uid44_fpAddTest_q_8_q, clk => clk, aclr => areset );

    -- excR_bSig_uid45_fpAddTest(LOGICAL,44)@10 + 1
    excR_bSig_uid45_fpAddTest_qi <= redist24_InvExpXIsZero_uid44_fpAddTest_q_8_q and invExpXIsMax_uid43_fpAddTest_q;
    excR_bSig_uid45_fpAddTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => excR_bSig_uid45_fpAddTest_qi, xout => excR_bSig_uid45_fpAddTest_q, clk => clk, aclr => areset );

    -- redist36_exp_aSig_uid21_fpAddTest_b_8_notEnable(LOGICAL,276)
    redist36_exp_aSig_uid21_fpAddTest_b_8_notEnable_q <= STD_LOGIC_VECTOR(not (VCC_q));

    -- redist36_exp_aSig_uid21_fpAddTest_b_8_nor(LOGICAL,277)
    redist36_exp_aSig_uid21_fpAddTest_b_8_nor_q <= not (redist36_exp_aSig_uid21_fpAddTest_b_8_notEnable_q or redist36_exp_aSig_uid21_fpAddTest_b_8_sticky_ena_q);

    -- redist36_exp_aSig_uid21_fpAddTest_b_8_mem_last(CONSTANT,273)
    redist36_exp_aSig_uid21_fpAddTest_b_8_mem_last_q <= "0100";

    -- redist36_exp_aSig_uid21_fpAddTest_b_8_cmp(LOGICAL,274)
    redist36_exp_aSig_uid21_fpAddTest_b_8_cmp_b <= STD_LOGIC_VECTOR("0" & redist36_exp_aSig_uid21_fpAddTest_b_8_rdcnt_q);
    redist36_exp_aSig_uid21_fpAddTest_b_8_cmp_q <= "1" WHEN redist36_exp_aSig_uid21_fpAddTest_b_8_mem_last_q = redist36_exp_aSig_uid21_fpAddTest_b_8_cmp_b ELSE "0";

    -- redist36_exp_aSig_uid21_fpAddTest_b_8_cmpReg(REG,275)
    redist36_exp_aSig_uid21_fpAddTest_b_8_cmpReg_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist36_exp_aSig_uid21_fpAddTest_b_8_cmpReg_q <= "0";
        ELSIF (clk'EVENT AND clk = '1') THEN
            redist36_exp_aSig_uid21_fpAddTest_b_8_cmpReg_q <= STD_LOGIC_VECTOR(redist36_exp_aSig_uid21_fpAddTest_b_8_cmp_q);
        END IF;
    END PROCESS;

    -- redist36_exp_aSig_uid21_fpAddTest_b_8_sticky_ena(REG,278)
    redist36_exp_aSig_uid21_fpAddTest_b_8_sticky_ena_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist36_exp_aSig_uid21_fpAddTest_b_8_sticky_ena_q <= "0";
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (redist36_exp_aSig_uid21_fpAddTest_b_8_nor_q = "1") THEN
                redist36_exp_aSig_uid21_fpAddTest_b_8_sticky_ena_q <= STD_LOGIC_VECTOR(redist36_exp_aSig_uid21_fpAddTest_b_8_cmpReg_q);
            END IF;
        END IF;
    END PROCESS;

    -- redist36_exp_aSig_uid21_fpAddTest_b_8_enaAnd(LOGICAL,279)
    redist36_exp_aSig_uid21_fpAddTest_b_8_enaAnd_q <= redist36_exp_aSig_uid21_fpAddTest_b_8_sticky_ena_q and VCC_q;

    -- redist36_exp_aSig_uid21_fpAddTest_b_8_rdcnt(COUNTER,271)
    -- low=0, high=5, step=1, init=0
    redist36_exp_aSig_uid21_fpAddTest_b_8_rdcnt_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist36_exp_aSig_uid21_fpAddTest_b_8_rdcnt_i <= TO_UNSIGNED(0, 3);
            redist36_exp_aSig_uid21_fpAddTest_b_8_rdcnt_eq <= '0';
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (redist36_exp_aSig_uid21_fpAddTest_b_8_rdcnt_i = TO_UNSIGNED(4, 3)) THEN
                redist36_exp_aSig_uid21_fpAddTest_b_8_rdcnt_eq <= '1';
            ELSE
                redist36_exp_aSig_uid21_fpAddTest_b_8_rdcnt_eq <= '0';
            END IF;
            IF (redist36_exp_aSig_uid21_fpAddTest_b_8_rdcnt_eq = '1') THEN
                redist36_exp_aSig_uid21_fpAddTest_b_8_rdcnt_i <= redist36_exp_aSig_uid21_fpAddTest_b_8_rdcnt_i + 3;
            ELSE
                redist36_exp_aSig_uid21_fpAddTest_b_8_rdcnt_i <= redist36_exp_aSig_uid21_fpAddTest_b_8_rdcnt_i + 1;
            END IF;
        END IF;
    END PROCESS;
    redist36_exp_aSig_uid21_fpAddTest_b_8_rdcnt_q <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR(RESIZE(redist36_exp_aSig_uid21_fpAddTest_b_8_rdcnt_i, 3)));

    -- redist36_exp_aSig_uid21_fpAddTest_b_8_wraddr(REG,272)
    redist36_exp_aSig_uid21_fpAddTest_b_8_wraddr_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist36_exp_aSig_uid21_fpAddTest_b_8_wraddr_q <= "101";
        ELSIF (clk'EVENT AND clk = '1') THEN
            redist36_exp_aSig_uid21_fpAddTest_b_8_wraddr_q <= STD_LOGIC_VECTOR(redist36_exp_aSig_uid21_fpAddTest_b_8_rdcnt_q);
        END IF;
    END PROCESS;

    -- redist36_exp_aSig_uid21_fpAddTest_b_8_mem(DUALMEM,270)
    redist36_exp_aSig_uid21_fpAddTest_b_8_mem_ia <= STD_LOGIC_VECTOR(exp_aSig_uid21_fpAddTest_b);
    redist36_exp_aSig_uid21_fpAddTest_b_8_mem_aa <= redist36_exp_aSig_uid21_fpAddTest_b_8_wraddr_q;
    redist36_exp_aSig_uid21_fpAddTest_b_8_mem_ab <= redist36_exp_aSig_uid21_fpAddTest_b_8_rdcnt_q;
    redist36_exp_aSig_uid21_fpAddTest_b_8_mem_reset0 <= areset;
    redist36_exp_aSig_uid21_fpAddTest_b_8_mem_dmem : altera_syncram
    GENERIC MAP (
        ram_block_type => "MLAB",
        operation_mode => "DUAL_PORT",
        width_a => 8,
        widthad_a => 3,
        numwords_a => 6,
        width_b => 8,
        widthad_b => 3,
        numwords_b => 6,
        lpm_type => "altera_syncram",
        width_byteena_a => 1,
        address_reg_b => "CLOCK0",
        indata_reg_b => "CLOCK0",
        rdcontrol_reg_b => "CLOCK0",
        byteena_reg_b => "CLOCK0",
        outdata_reg_b => "CLOCK1",
        outdata_aclr_b => "CLEAR1",
        clock_enable_input_a => "NORMAL",
        clock_enable_input_b => "NORMAL",
        clock_enable_output_b => "NORMAL",
        read_during_write_mode_mixed_ports => "DONT_CARE",
        power_up_uninitialized => "TRUE",
        intended_device_family => "Cyclone V"
    )
    PORT MAP (
        clocken1 => redist36_exp_aSig_uid21_fpAddTest_b_8_enaAnd_q(0),
        clocken0 => VCC_q(0),
        clock0 => clk,
        aclr1 => redist36_exp_aSig_uid21_fpAddTest_b_8_mem_reset0,
        clock1 => clk,
        address_a => redist36_exp_aSig_uid21_fpAddTest_b_8_mem_aa,
        data_a => redist36_exp_aSig_uid21_fpAddTest_b_8_mem_ia,
        wren_a => VCC_q(0),
        address_b => redist36_exp_aSig_uid21_fpAddTest_b_8_mem_ab,
        q_b => redist36_exp_aSig_uid21_fpAddTest_b_8_mem_iq
    );
    redist36_exp_aSig_uid21_fpAddTest_b_8_mem_q <= redist36_exp_aSig_uid21_fpAddTest_b_8_mem_iq(7 downto 0);

    -- redist36_exp_aSig_uid21_fpAddTest_b_8_outputreg(DELAY,269)
    redist36_exp_aSig_uid21_fpAddTest_b_8_outputreg : dspba_delay
    GENERIC MAP ( width => 8, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist36_exp_aSig_uid21_fpAddTest_b_8_mem_q, xout => redist36_exp_aSig_uid21_fpAddTest_b_8_outputreg_q, clk => clk, aclr => areset );

    -- expXIsMax_uid24_fpAddTest(LOGICAL,23)@9 + 1
    expXIsMax_uid24_fpAddTest_qi <= "1" WHEN redist36_exp_aSig_uid21_fpAddTest_b_8_outputreg_q = cstAllOWE_uid18_fpAddTest_q ELSE "0";
    expXIsMax_uid24_fpAddTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => expXIsMax_uid24_fpAddTest_qi, xout => expXIsMax_uid24_fpAddTest_q, clk => clk, aclr => areset );

    -- invExpXIsMax_uid29_fpAddTest(LOGICAL,28)@10
    invExpXIsMax_uid29_fpAddTest_q <= not (expXIsMax_uid24_fpAddTest_q);

    -- excZ_aSig_uid16_uid23_fpAddTest(LOGICAL,22)@9 + 1
    excZ_aSig_uid16_uid23_fpAddTest_qi <= "1" WHEN redist36_exp_aSig_uid21_fpAddTest_b_8_outputreg_q = cstAllZWE_uid20_fpAddTest_q ELSE "0";
    excZ_aSig_uid16_uid23_fpAddTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => excZ_aSig_uid16_uid23_fpAddTest_qi, xout => excZ_aSig_uid16_uid23_fpAddTest_q, clk => clk, aclr => areset );

    -- InvExpXIsZero_uid30_fpAddTest(LOGICAL,29)@10
    InvExpXIsZero_uid30_fpAddTest_q <= not (excZ_aSig_uid16_uid23_fpAddTest_q);

    -- excR_aSig_uid31_fpAddTest(LOGICAL,30)@10 + 1
    excR_aSig_uid31_fpAddTest_qi <= InvExpXIsZero_uid30_fpAddTest_q and invExpXIsMax_uid29_fpAddTest_q;
    excR_aSig_uid31_fpAddTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => excR_aSig_uid31_fpAddTest_qi, xout => excR_aSig_uid31_fpAddTest_q, clk => clk, aclr => areset );

    -- signRReg_uid100_fpAddTest(LOGICAL,99)@11
    signRReg_uid100_fpAddTest_q <= excR_aSig_uid31_fpAddTest_q and excR_bSig_uid45_fpAddTest_q and redist23_sigA_uid50_fpAddTest_b_10_q and invAMinusA_uid99_fpAddTest_q;

    -- redist21_sigB_uid51_fpAddTest_b_10(DELAY,240)
    redist21_sigB_uid51_fpAddTest_b_10 : dspba_delay
    GENERIC MAP ( width => 1, depth => 9, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist20_sigB_uid51_fpAddTest_b_1_q, xout => redist21_sigB_uid51_fpAddTest_b_10_q, clk => clk, aclr => areset );

    -- redist29_excZ_bSig_uid17_uid37_fpAddTest_q_10(DELAY,248)
    redist29_excZ_bSig_uid17_uid37_fpAddTest_q_10 : dspba_delay
    GENERIC MAP ( width => 1, depth => 9, reset_kind => "ASYNC" )
    PORT MAP ( xin => excZ_bSig_uid17_uid37_fpAddTest_q, xout => redist29_excZ_bSig_uid17_uid37_fpAddTest_q_10_q, clk => clk, aclr => areset );

    -- redist34_excZ_aSig_uid16_uid23_fpAddTest_q_2(DELAY,253)
    redist34_excZ_aSig_uid16_uid23_fpAddTest_q_2 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => excZ_aSig_uid16_uid23_fpAddTest_q, xout => redist34_excZ_aSig_uid16_uid23_fpAddTest_q_2_q, clk => clk, aclr => areset );

    -- excAZBZSigASigB_uid104_fpAddTest(LOGICAL,103)@11
    excAZBZSigASigB_uid104_fpAddTest_q <= redist34_excZ_aSig_uid16_uid23_fpAddTest_q_2_q and redist29_excZ_bSig_uid17_uid37_fpAddTest_q_10_q and redist23_sigA_uid50_fpAddTest_b_10_q and redist21_sigB_uid51_fpAddTest_b_10_q;

    -- excBZARSigA_uid105_fpAddTest(LOGICAL,104)@11
    excBZARSigA_uid105_fpAddTest_q <= redist29_excZ_bSig_uid17_uid37_fpAddTest_q_10_q and excR_aSig_uid31_fpAddTest_q and redist23_sigA_uid50_fpAddTest_b_10_q;

    -- signRZero_uid106_fpAddTest(LOGICAL,105)@11
    signRZero_uid106_fpAddTest_q <= excBZARSigA_uid105_fpAddTest_q or excAZBZSigASigB_uid104_fpAddTest_q;

    -- fracXIsZero_uid39_fpAddTest(LOGICAL,38)@2 + 1
    fracXIsZero_uid39_fpAddTest_qi <= "1" WHEN cstZeroWF_uid19_fpAddTest_q = redist30_frac_bSig_uid36_fpAddTest_b_1_q ELSE "0";
    fracXIsZero_uid39_fpAddTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => fracXIsZero_uid39_fpAddTest_qi, xout => fracXIsZero_uid39_fpAddTest_q, clk => clk, aclr => areset );

    -- redist27_fracXIsZero_uid39_fpAddTest_q_8(DELAY,246)
    redist27_fracXIsZero_uid39_fpAddTest_q_8 : dspba_delay
    GENERIC MAP ( width => 1, depth => 7, reset_kind => "ASYNC" )
    PORT MAP ( xin => fracXIsZero_uid39_fpAddTest_q, xout => redist27_fracXIsZero_uid39_fpAddTest_q_8_q, clk => clk, aclr => areset );

    -- excI_bSig_uid41_fpAddTest(LOGICAL,40)@10 + 1
    excI_bSig_uid41_fpAddTest_qi <= redist28_expXIsMax_uid38_fpAddTest_q_9_q and redist27_fracXIsZero_uid39_fpAddTest_q_8_q;
    excI_bSig_uid41_fpAddTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => excI_bSig_uid41_fpAddTest_qi, xout => excI_bSig_uid41_fpAddTest_q, clk => clk, aclr => areset );

    -- sigBBInf_uid101_fpAddTest(LOGICAL,100)@11
    sigBBInf_uid101_fpAddTest_q <= redist21_sigB_uid51_fpAddTest_b_10_q and excI_bSig_uid41_fpAddTest_q;

    -- fracXIsZero_uid25_fpAddTest(LOGICAL,24)@6 + 1
    fracXIsZero_uid25_fpAddTest_qi <= "1" WHEN cstZeroWF_uid19_fpAddTest_q = redist35_frac_aSig_uid22_fpAddTest_b_5_outputreg_q ELSE "0";
    fracXIsZero_uid25_fpAddTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => fracXIsZero_uid25_fpAddTest_qi, xout => fracXIsZero_uid25_fpAddTest_q, clk => clk, aclr => areset );

    -- redist33_fracXIsZero_uid25_fpAddTest_q_4(DELAY,252)
    redist33_fracXIsZero_uid25_fpAddTest_q_4 : dspba_delay
    GENERIC MAP ( width => 1, depth => 3, reset_kind => "ASYNC" )
    PORT MAP ( xin => fracXIsZero_uid25_fpAddTest_q, xout => redist33_fracXIsZero_uid25_fpAddTest_q_4_q, clk => clk, aclr => areset );

    -- excI_aSig_uid27_fpAddTest(LOGICAL,26)@10 + 1
    excI_aSig_uid27_fpAddTest_qi <= expXIsMax_uid24_fpAddTest_q and redist33_fracXIsZero_uid25_fpAddTest_q_4_q;
    excI_aSig_uid27_fpAddTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => excI_aSig_uid27_fpAddTest_qi, xout => excI_aSig_uid27_fpAddTest_q, clk => clk, aclr => areset );

    -- sigAAInf_uid102_fpAddTest(LOGICAL,101)@11
    sigAAInf_uid102_fpAddTest_q <= redist23_sigA_uid50_fpAddTest_b_10_q and excI_aSig_uid27_fpAddTest_q;

    -- signRInf_uid103_fpAddTest(LOGICAL,102)@11
    signRInf_uid103_fpAddTest_q <= sigAAInf_uid102_fpAddTest_q or sigBBInf_uid101_fpAddTest_q;

    -- signRInfRZRReg_uid107_fpAddTest(LOGICAL,106)@11 + 1
    signRInfRZRReg_uid107_fpAddTest_qi <= signRInf_uid103_fpAddTest_q or signRZero_uid106_fpAddTest_q or signRReg_uid100_fpAddTest_q;
    signRInfRZRReg_uid107_fpAddTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => signRInfRZRReg_uid107_fpAddTest_qi, xout => signRInfRZRReg_uid107_fpAddTest_q, clk => clk, aclr => areset );

    -- fracXIsNotZero_uid40_fpAddTest(LOGICAL,39)@10
    fracXIsNotZero_uid40_fpAddTest_q <= not (redist27_fracXIsZero_uid39_fpAddTest_q_8_q);

    -- excN_bSig_uid42_fpAddTest(LOGICAL,41)@10 + 1
    excN_bSig_uid42_fpAddTest_qi <= redist28_expXIsMax_uid38_fpAddTest_q_9_q and fracXIsNotZero_uid40_fpAddTest_q;
    excN_bSig_uid42_fpAddTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => excN_bSig_uid42_fpAddTest_qi, xout => excN_bSig_uid42_fpAddTest_q, clk => clk, aclr => areset );

    -- redist25_excN_bSig_uid42_fpAddTest_q_2(DELAY,244)
    redist25_excN_bSig_uid42_fpAddTest_q_2 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => excN_bSig_uid42_fpAddTest_q, xout => redist25_excN_bSig_uid42_fpAddTest_q_2_q, clk => clk, aclr => areset );

    -- fracXIsNotZero_uid26_fpAddTest(LOGICAL,25)@10
    fracXIsNotZero_uid26_fpAddTest_q <= not (redist33_fracXIsZero_uid25_fpAddTest_q_4_q);

    -- excN_aSig_uid28_fpAddTest(LOGICAL,27)@10 + 1
    excN_aSig_uid28_fpAddTest_qi <= expXIsMax_uid24_fpAddTest_q and fracXIsNotZero_uid26_fpAddTest_q;
    excN_aSig_uid28_fpAddTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => excN_aSig_uid28_fpAddTest_qi, xout => excN_aSig_uid28_fpAddTest_q, clk => clk, aclr => areset );

    -- redist31_excN_aSig_uid28_fpAddTest_q_2(DELAY,250)
    redist31_excN_aSig_uid28_fpAddTest_q_2 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => excN_aSig_uid28_fpAddTest_q, xout => redist31_excN_aSig_uid28_fpAddTest_q_2_q, clk => clk, aclr => areset );

    -- excRNaN2_uid94_fpAddTest(LOGICAL,93)@12
    excRNaN2_uid94_fpAddTest_q <= redist31_excN_aSig_uid28_fpAddTest_q_2_q or redist25_excN_bSig_uid42_fpAddTest_q_2_q;

    -- redist19_effSub_uid52_fpAddTest_q_10(DELAY,238)
    redist19_effSub_uid52_fpAddTest_q_10 : dspba_delay
    GENERIC MAP ( width => 1, depth => 9, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist18_effSub_uid52_fpAddTest_q_1_q, xout => redist19_effSub_uid52_fpAddTest_q_10_q, clk => clk, aclr => areset );

    -- redist26_excI_bSig_uid41_fpAddTest_q_2(DELAY,245)
    redist26_excI_bSig_uid41_fpAddTest_q_2 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => excI_bSig_uid41_fpAddTest_q, xout => redist26_excI_bSig_uid41_fpAddTest_q_2_q, clk => clk, aclr => areset );

    -- redist32_excI_aSig_uid27_fpAddTest_q_2(DELAY,251)
    redist32_excI_aSig_uid27_fpAddTest_q_2 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => excI_aSig_uid27_fpAddTest_q, xout => redist32_excI_aSig_uid27_fpAddTest_q_2_q, clk => clk, aclr => areset );

    -- excAIBISub_uid95_fpAddTest(LOGICAL,94)@12
    excAIBISub_uid95_fpAddTest_q <= redist32_excI_aSig_uid27_fpAddTest_q_2_q and redist26_excI_bSig_uid41_fpAddTest_q_2_q and redist19_effSub_uid52_fpAddTest_q_10_q;

    -- excRNaN_uid96_fpAddTest(LOGICAL,95)@12
    excRNaN_uid96_fpAddTest_q <= excAIBISub_uid95_fpAddTest_q or excRNaN2_uid94_fpAddTest_q;

    -- invExcRNaN_uid108_fpAddTest(LOGICAL,107)@12
    invExcRNaN_uid108_fpAddTest_q <= not (excRNaN_uid96_fpAddTest_q);

    -- VCC(CONSTANT,1)
    VCC_q <= "1";

    -- signRPostExc_uid109_fpAddTest(LOGICAL,108)@12 + 1
    signRPostExc_uid109_fpAddTest_qi <= invExcRNaN_uid108_fpAddTest_q and signRInfRZRReg_uid107_fpAddTest_q;
    signRPostExc_uid109_fpAddTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => signRPostExc_uid109_fpAddTest_qi, xout => signRPostExc_uid109_fpAddTest_q, clk => clk, aclr => areset );

    -- expInc_uid78_fpAddTest(ADD,77)@9 + 1
    expInc_uid78_fpAddTest_a <= STD_LOGIC_VECTOR("0" & redist36_exp_aSig_uid21_fpAddTest_b_8_outputreg_q);
    expInc_uid78_fpAddTest_b <= STD_LOGIC_VECTOR("00000000" & VCC_q);
    expInc_uid78_fpAddTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            expInc_uid78_fpAddTest_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            expInc_uid78_fpAddTest_o <= STD_LOGIC_VECTOR(UNSIGNED(expInc_uid78_fpAddTest_a) + UNSIGNED(expInc_uid78_fpAddTest_b));
        END IF;
    END PROCESS;
    expInc_uid78_fpAddTest_q <= expInc_uid78_fpAddTest_o(8 downto 0);

    -- expPostNorm_uid79_fpAddTest(SUB,78)@10 + 1
    expPostNorm_uid79_fpAddTest_a <= STD_LOGIC_VECTOR("0" & expInc_uid78_fpAddTest_q);
    expPostNorm_uid79_fpAddTest_b <= STD_LOGIC_VECTOR("00000" & r_uid149_lzCountVal_uid74_fpAddTest_q);
    expPostNorm_uid79_fpAddTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            expPostNorm_uid79_fpAddTest_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            expPostNorm_uid79_fpAddTest_o <= STD_LOGIC_VECTOR(UNSIGNED(expPostNorm_uid79_fpAddTest_a) - UNSIGNED(expPostNorm_uid79_fpAddTest_b));
        END IF;
    END PROCESS;
    expPostNorm_uid79_fpAddTest_q <= expPostNorm_uid79_fpAddTest_o(9 downto 0);

    -- leftShiftStage2Idx1Rng1_uid210_fracPostNorm_uid75_fpAddTest(BITSELECT,209)@11
    leftShiftStage2Idx1Rng1_uid210_fracPostNorm_uid75_fpAddTest_in <= leftShiftStage1_uid208_fracPostNorm_uid75_fpAddTest_q(25 downto 0);
    leftShiftStage2Idx1Rng1_uid210_fracPostNorm_uid75_fpAddTest_b <= leftShiftStage2Idx1Rng1_uid210_fracPostNorm_uid75_fpAddTest_in(25 downto 0);

    -- leftShiftStage2Idx1_uid211_fracPostNorm_uid75_fpAddTest(BITJOIN,210)@11
    leftShiftStage2Idx1_uid211_fracPostNorm_uid75_fpAddTest_q <= leftShiftStage2Idx1Rng1_uid210_fracPostNorm_uid75_fpAddTest_b & GND_q;

    -- leftShiftStage1Idx3Rng6_uid205_fracPostNorm_uid75_fpAddTest(BITSELECT,204)@10
    leftShiftStage1Idx3Rng6_uid205_fracPostNorm_uid75_fpAddTest_in <= leftShiftStage0_uid197_fracPostNorm_uid75_fpAddTest_q(20 downto 0);
    leftShiftStage1Idx3Rng6_uid205_fracPostNorm_uid75_fpAddTest_b <= leftShiftStage1Idx3Rng6_uid205_fracPostNorm_uid75_fpAddTest_in(20 downto 0);

    -- leftShiftStage1Idx3Pad6_uid204_fracPostNorm_uid75_fpAddTest(CONSTANT,203)
    leftShiftStage1Idx3Pad6_uid204_fracPostNorm_uid75_fpAddTest_q <= "000000";

    -- leftShiftStage1Idx3_uid206_fracPostNorm_uid75_fpAddTest(BITJOIN,205)@10
    leftShiftStage1Idx3_uid206_fracPostNorm_uid75_fpAddTest_q <= leftShiftStage1Idx3Rng6_uid205_fracPostNorm_uid75_fpAddTest_b & leftShiftStage1Idx3Pad6_uid204_fracPostNorm_uid75_fpAddTest_q;

    -- leftShiftStage1Idx2Rng4_uid202_fracPostNorm_uid75_fpAddTest(BITSELECT,201)@10
    leftShiftStage1Idx2Rng4_uid202_fracPostNorm_uid75_fpAddTest_in <= leftShiftStage0_uid197_fracPostNorm_uid75_fpAddTest_q(22 downto 0);
    leftShiftStage1Idx2Rng4_uid202_fracPostNorm_uid75_fpAddTest_b <= leftShiftStage1Idx2Rng4_uid202_fracPostNorm_uid75_fpAddTest_in(22 downto 0);

    -- leftShiftStage1Idx2_uid203_fracPostNorm_uid75_fpAddTest(BITJOIN,202)@10
    leftShiftStage1Idx2_uid203_fracPostNorm_uid75_fpAddTest_q <= leftShiftStage1Idx2Rng4_uid202_fracPostNorm_uid75_fpAddTest_b & zs_uid134_lzCountVal_uid74_fpAddTest_q;

    -- leftShiftStage1Idx1Rng2_uid199_fracPostNorm_uid75_fpAddTest(BITSELECT,198)@10
    leftShiftStage1Idx1Rng2_uid199_fracPostNorm_uid75_fpAddTest_in <= leftShiftStage0_uid197_fracPostNorm_uid75_fpAddTest_q(24 downto 0);
    leftShiftStage1Idx1Rng2_uid199_fracPostNorm_uid75_fpAddTest_b <= leftShiftStage1Idx1Rng2_uid199_fracPostNorm_uid75_fpAddTest_in(24 downto 0);

    -- leftShiftStage1Idx1_uid200_fracPostNorm_uid75_fpAddTest(BITJOIN,199)@10
    leftShiftStage1Idx1_uid200_fracPostNorm_uid75_fpAddTest_q <= leftShiftStage1Idx1Rng2_uid199_fracPostNorm_uid75_fpAddTest_b & zs_uid140_lzCountVal_uid74_fpAddTest_q;

    -- leftShiftStage0Idx3Rng24_uid194_fracPostNorm_uid75_fpAddTest(BITSELECT,193)@10
    leftShiftStage0Idx3Rng24_uid194_fracPostNorm_uid75_fpAddTest_in <= redist16_fracAddResultNoSignExt_uid73_fpAddTest_b_4_q(2 downto 0);
    leftShiftStage0Idx3Rng24_uid194_fracPostNorm_uid75_fpAddTest_b <= leftShiftStage0Idx3Rng24_uid194_fracPostNorm_uid75_fpAddTest_in(2 downto 0);

    -- leftShiftStage0Idx3Pad24_uid193_fracPostNorm_uid75_fpAddTest(CONSTANT,192)
    leftShiftStage0Idx3Pad24_uid193_fracPostNorm_uid75_fpAddTest_q <= "000000000000000000000000";

    -- leftShiftStage0Idx3_uid195_fracPostNorm_uid75_fpAddTest(BITJOIN,194)@10
    leftShiftStage0Idx3_uid195_fracPostNorm_uid75_fpAddTest_q <= leftShiftStage0Idx3Rng24_uid194_fracPostNorm_uid75_fpAddTest_b & leftShiftStage0Idx3Pad24_uid193_fracPostNorm_uid75_fpAddTest_q;

    -- redist10_vStage_uid124_lzCountVal_uid74_fpAddTest_b_3(DELAY,229)
    redist10_vStage_uid124_lzCountVal_uid74_fpAddTest_b_3 : dspba_delay
    GENERIC MAP ( width => 11, depth => 3, reset_kind => "ASYNC" )
    PORT MAP ( xin => vStage_uid124_lzCountVal_uid74_fpAddTest_b, xout => redist10_vStage_uid124_lzCountVal_uid74_fpAddTest_b_3_q, clk => clk, aclr => areset );

    -- leftShiftStage0Idx2_uid192_fracPostNorm_uid75_fpAddTest(BITJOIN,191)@10
    leftShiftStage0Idx2_uid192_fracPostNorm_uid75_fpAddTest_q <= redist10_vStage_uid124_lzCountVal_uid74_fpAddTest_b_3_q & zs_uid120_lzCountVal_uid74_fpAddTest_q;

    -- leftShiftStage0Idx1Rng8_uid188_fracPostNorm_uid75_fpAddTest(BITSELECT,187)@10
    leftShiftStage0Idx1Rng8_uid188_fracPostNorm_uid75_fpAddTest_in <= redist16_fracAddResultNoSignExt_uid73_fpAddTest_b_4_q(18 downto 0);
    leftShiftStage0Idx1Rng8_uid188_fracPostNorm_uid75_fpAddTest_b <= leftShiftStage0Idx1Rng8_uid188_fracPostNorm_uid75_fpAddTest_in(18 downto 0);

    -- leftShiftStage0Idx1_uid189_fracPostNorm_uid75_fpAddTest(BITJOIN,188)@10
    leftShiftStage0Idx1_uid189_fracPostNorm_uid75_fpAddTest_q <= leftShiftStage0Idx1Rng8_uid188_fracPostNorm_uid75_fpAddTest_b & cstAllZWE_uid20_fpAddTest_q;

    -- redist16_fracAddResultNoSignExt_uid73_fpAddTest_b_4(DELAY,235)
    redist16_fracAddResultNoSignExt_uid73_fpAddTest_b_4 : dspba_delay
    GENERIC MAP ( width => 27, depth => 3, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist15_fracAddResultNoSignExt_uid73_fpAddTest_b_1_q, xout => redist16_fracAddResultNoSignExt_uid73_fpAddTest_b_4_q, clk => clk, aclr => areset );

    -- leftShiftStage0_uid197_fracPostNorm_uid75_fpAddTest(MUX,196)@10
    leftShiftStage0_uid197_fracPostNorm_uid75_fpAddTest_s <= leftShiftStageSel4Dto3_uid196_fracPostNorm_uid75_fpAddTest_merged_bit_select_b;
    leftShiftStage0_uid197_fracPostNorm_uid75_fpAddTest_combproc: PROCESS (leftShiftStage0_uid197_fracPostNorm_uid75_fpAddTest_s, redist16_fracAddResultNoSignExt_uid73_fpAddTest_b_4_q, leftShiftStage0Idx1_uid189_fracPostNorm_uid75_fpAddTest_q, leftShiftStage0Idx2_uid192_fracPostNorm_uid75_fpAddTest_q, leftShiftStage0Idx3_uid195_fracPostNorm_uid75_fpAddTest_q)
    BEGIN
        CASE (leftShiftStage0_uid197_fracPostNorm_uid75_fpAddTest_s) IS
            WHEN "00" => leftShiftStage0_uid197_fracPostNorm_uid75_fpAddTest_q <= redist16_fracAddResultNoSignExt_uid73_fpAddTest_b_4_q;
            WHEN "01" => leftShiftStage0_uid197_fracPostNorm_uid75_fpAddTest_q <= leftShiftStage0Idx1_uid189_fracPostNorm_uid75_fpAddTest_q;
            WHEN "10" => leftShiftStage0_uid197_fracPostNorm_uid75_fpAddTest_q <= leftShiftStage0Idx2_uid192_fracPostNorm_uid75_fpAddTest_q;
            WHEN "11" => leftShiftStage0_uid197_fracPostNorm_uid75_fpAddTest_q <= leftShiftStage0Idx3_uid195_fracPostNorm_uid75_fpAddTest_q;
            WHEN OTHERS => leftShiftStage0_uid197_fracPostNorm_uid75_fpAddTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- leftShiftStageSel4Dto3_uid196_fracPostNorm_uid75_fpAddTest_merged_bit_select(BITSELECT,218)@10
    leftShiftStageSel4Dto3_uid196_fracPostNorm_uid75_fpAddTest_merged_bit_select_b <= r_uid149_lzCountVal_uid74_fpAddTest_q(4 downto 3);
    leftShiftStageSel4Dto3_uid196_fracPostNorm_uid75_fpAddTest_merged_bit_select_c <= r_uid149_lzCountVal_uid74_fpAddTest_q(2 downto 1);
    leftShiftStageSel4Dto3_uid196_fracPostNorm_uid75_fpAddTest_merged_bit_select_d <= r_uid149_lzCountVal_uid74_fpAddTest_q(0 downto 0);

    -- leftShiftStage1_uid208_fracPostNorm_uid75_fpAddTest(MUX,207)@10 + 1
    leftShiftStage1_uid208_fracPostNorm_uid75_fpAddTest_s <= leftShiftStageSel4Dto3_uid196_fracPostNorm_uid75_fpAddTest_merged_bit_select_c;
    leftShiftStage1_uid208_fracPostNorm_uid75_fpAddTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            leftShiftStage1_uid208_fracPostNorm_uid75_fpAddTest_q <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (leftShiftStage1_uid208_fracPostNorm_uid75_fpAddTest_s) IS
                WHEN "00" => leftShiftStage1_uid208_fracPostNorm_uid75_fpAddTest_q <= leftShiftStage0_uid197_fracPostNorm_uid75_fpAddTest_q;
                WHEN "01" => leftShiftStage1_uid208_fracPostNorm_uid75_fpAddTest_q <= leftShiftStage1Idx1_uid200_fracPostNorm_uid75_fpAddTest_q;
                WHEN "10" => leftShiftStage1_uid208_fracPostNorm_uid75_fpAddTest_q <= leftShiftStage1Idx2_uid203_fracPostNorm_uid75_fpAddTest_q;
                WHEN "11" => leftShiftStage1_uid208_fracPostNorm_uid75_fpAddTest_q <= leftShiftStage1Idx3_uid206_fracPostNorm_uid75_fpAddTest_q;
                WHEN OTHERS => leftShiftStage1_uid208_fracPostNorm_uid75_fpAddTest_q <= (others => '0');
            END CASE;
        END IF;
    END PROCESS;

    -- redist0_leftShiftStageSel4Dto3_uid196_fracPostNorm_uid75_fpAddTest_merged_bit_select_d_1(DELAY,219)
    redist0_leftShiftStageSel4Dto3_uid196_fracPostNorm_uid75_fpAddTest_merged_bit_select_d_1 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => leftShiftStageSel4Dto3_uid196_fracPostNorm_uid75_fpAddTest_merged_bit_select_d, xout => redist0_leftShiftStageSel4Dto3_uid196_fracPostNorm_uid75_fpAddTest_merged_bit_select_d_1_q, clk => clk, aclr => areset );

    -- leftShiftStage2_uid213_fracPostNorm_uid75_fpAddTest(MUX,212)@11
    leftShiftStage2_uid213_fracPostNorm_uid75_fpAddTest_s <= redist0_leftShiftStageSel4Dto3_uid196_fracPostNorm_uid75_fpAddTest_merged_bit_select_d_1_q;
    leftShiftStage2_uid213_fracPostNorm_uid75_fpAddTest_combproc: PROCESS (leftShiftStage2_uid213_fracPostNorm_uid75_fpAddTest_s, leftShiftStage1_uid208_fracPostNorm_uid75_fpAddTest_q, leftShiftStage2Idx1_uid211_fracPostNorm_uid75_fpAddTest_q)
    BEGIN
        CASE (leftShiftStage2_uid213_fracPostNorm_uid75_fpAddTest_s) IS
            WHEN "0" => leftShiftStage2_uid213_fracPostNorm_uid75_fpAddTest_q <= leftShiftStage1_uid208_fracPostNorm_uid75_fpAddTest_q;
            WHEN "1" => leftShiftStage2_uid213_fracPostNorm_uid75_fpAddTest_q <= leftShiftStage2Idx1_uid211_fracPostNorm_uid75_fpAddTest_q;
            WHEN OTHERS => leftShiftStage2_uid213_fracPostNorm_uid75_fpAddTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- fracPostNormRndRange_uid80_fpAddTest(BITSELECT,79)@11
    fracPostNormRndRange_uid80_fpAddTest_in <= leftShiftStage2_uid213_fracPostNorm_uid75_fpAddTest_q(25 downto 0);
    fracPostNormRndRange_uid80_fpAddTest_b <= fracPostNormRndRange_uid80_fpAddTest_in(25 downto 2);

    -- expFracR_uid81_fpAddTest(BITJOIN,80)@11
    expFracR_uid81_fpAddTest_q <= expPostNorm_uid79_fpAddTest_q & fracPostNormRndRange_uid80_fpAddTest_b;

    -- expRPreExc_uid87_fpAddTest(BITSELECT,86)@11
    expRPreExc_uid87_fpAddTest_in <= expFracR_uid81_fpAddTest_q(31 downto 0);
    expRPreExc_uid87_fpAddTest_b <= expRPreExc_uid87_fpAddTest_in(31 downto 24);

    -- redist13_expRPreExc_uid87_fpAddTest_b_2(DELAY,232)
    redist13_expRPreExc_uid87_fpAddTest_b_2 : dspba_delay
    GENERIC MAP ( width => 8, depth => 2, reset_kind => "ASYNC" )
    PORT MAP ( xin => expRPreExc_uid87_fpAddTest_b, xout => redist13_expRPreExc_uid87_fpAddTest_b_2_q, clk => clk, aclr => areset );

    -- wEP2AllOwE_uid82_fpAddTest(CONSTANT,81)
    wEP2AllOwE_uid82_fpAddTest_q <= "0011111111";

    -- rndExp_uid83_fpAddTest(BITSELECT,82)@11
    rndExp_uid83_fpAddTest_b <= expFracR_uid81_fpAddTest_q(33 downto 24);

    -- rOvf_uid84_fpAddTest(LOGICAL,83)@11 + 1
    rOvf_uid84_fpAddTest_qi <= "1" WHEN rndExp_uid83_fpAddTest_b = wEP2AllOwE_uid82_fpAddTest_q ELSE "0";
    rOvf_uid84_fpAddTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => rOvf_uid84_fpAddTest_qi, xout => rOvf_uid84_fpAddTest_q, clk => clk, aclr => areset );

    -- regInputs_uid88_fpAddTest(LOGICAL,87)@11
    regInputs_uid88_fpAddTest_q <= excR_aSig_uid31_fpAddTest_q and excR_bSig_uid45_fpAddTest_q;

    -- redist12_regInputs_uid88_fpAddTest_q_1(DELAY,231)
    redist12_regInputs_uid88_fpAddTest_q_1 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => regInputs_uid88_fpAddTest_q, xout => redist12_regInputs_uid88_fpAddTest_q_1_q, clk => clk, aclr => areset );

    -- rInfOvf_uid91_fpAddTest(LOGICAL,90)@12
    rInfOvf_uid91_fpAddTest_q <= redist12_regInputs_uid88_fpAddTest_q_1_q and rOvf_uid84_fpAddTest_q;

    -- excRInfVInC_uid92_fpAddTest(BITJOIN,91)@12
    excRInfVInC_uid92_fpAddTest_q <= rInfOvf_uid91_fpAddTest_q & redist25_excN_bSig_uid42_fpAddTest_q_2_q & redist31_excN_aSig_uid28_fpAddTest_q_2_q & redist26_excI_bSig_uid41_fpAddTest_q_2_q & redist32_excI_aSig_uid27_fpAddTest_q_2_q & redist19_effSub_uid52_fpAddTest_q_10_q;

    -- excRInf_uid93_fpAddTest(LOOKUP,92)@12
    excRInf_uid93_fpAddTest_combproc: PROCESS (excRInfVInC_uid92_fpAddTest_q)
    BEGIN
        -- Begin reserved scope level
        CASE (excRInfVInC_uid92_fpAddTest_q) IS
            WHEN "000000" => excRInf_uid93_fpAddTest_q <= "0";
            WHEN "000001" => excRInf_uid93_fpAddTest_q <= "0";
            WHEN "000010" => excRInf_uid93_fpAddTest_q <= "1";
            WHEN "000011" => excRInf_uid93_fpAddTest_q <= "1";
            WHEN "000100" => excRInf_uid93_fpAddTest_q <= "1";
            WHEN "000101" => excRInf_uid93_fpAddTest_q <= "1";
            WHEN "000110" => excRInf_uid93_fpAddTest_q <= "1";
            WHEN "000111" => excRInf_uid93_fpAddTest_q <= "0";
            WHEN "001000" => excRInf_uid93_fpAddTest_q <= "0";
            WHEN "001001" => excRInf_uid93_fpAddTest_q <= "0";
            WHEN "001010" => excRInf_uid93_fpAddTest_q <= "0";
            WHEN "001011" => excRInf_uid93_fpAddTest_q <= "0";
            WHEN "001100" => excRInf_uid93_fpAddTest_q <= "0";
            WHEN "001101" => excRInf_uid93_fpAddTest_q <= "0";
            WHEN "001110" => excRInf_uid93_fpAddTest_q <= "0";
            WHEN "001111" => excRInf_uid93_fpAddTest_q <= "0";
            WHEN "010000" => excRInf_uid93_fpAddTest_q <= "0";
            WHEN "010001" => excRInf_uid93_fpAddTest_q <= "0";
            WHEN "010010" => excRInf_uid93_fpAddTest_q <= "0";
            WHEN "010011" => excRInf_uid93_fpAddTest_q <= "0";
            WHEN "010100" => excRInf_uid93_fpAddTest_q <= "0";
            WHEN "010101" => excRInf_uid93_fpAddTest_q <= "0";
            WHEN "010110" => excRInf_uid93_fpAddTest_q <= "0";
            WHEN "010111" => excRInf_uid93_fpAddTest_q <= "0";
            WHEN "011000" => excRInf_uid93_fpAddTest_q <= "0";
            WHEN "011001" => excRInf_uid93_fpAddTest_q <= "0";
            WHEN "011010" => excRInf_uid93_fpAddTest_q <= "0";
            WHEN "011011" => excRInf_uid93_fpAddTest_q <= "0";
            WHEN "011100" => excRInf_uid93_fpAddTest_q <= "0";
            WHEN "011101" => excRInf_uid93_fpAddTest_q <= "0";
            WHEN "011110" => excRInf_uid93_fpAddTest_q <= "0";
            WHEN "011111" => excRInf_uid93_fpAddTest_q <= "0";
            WHEN "100000" => excRInf_uid93_fpAddTest_q <= "1";
            WHEN "100001" => excRInf_uid93_fpAddTest_q <= "0";
            WHEN "100010" => excRInf_uid93_fpAddTest_q <= "0";
            WHEN "100011" => excRInf_uid93_fpAddTest_q <= "0";
            WHEN "100100" => excRInf_uid93_fpAddTest_q <= "0";
            WHEN "100101" => excRInf_uid93_fpAddTest_q <= "0";
            WHEN "100110" => excRInf_uid93_fpAddTest_q <= "0";
            WHEN "100111" => excRInf_uid93_fpAddTest_q <= "0";
            WHEN "101000" => excRInf_uid93_fpAddTest_q <= "0";
            WHEN "101001" => excRInf_uid93_fpAddTest_q <= "0";
            WHEN "101010" => excRInf_uid93_fpAddTest_q <= "0";
            WHEN "101011" => excRInf_uid93_fpAddTest_q <= "0";
            WHEN "101100" => excRInf_uid93_fpAddTest_q <= "0";
            WHEN "101101" => excRInf_uid93_fpAddTest_q <= "0";
            WHEN "101110" => excRInf_uid93_fpAddTest_q <= "0";
            WHEN "101111" => excRInf_uid93_fpAddTest_q <= "0";
            WHEN "110000" => excRInf_uid93_fpAddTest_q <= "0";
            WHEN "110001" => excRInf_uid93_fpAddTest_q <= "0";
            WHEN "110010" => excRInf_uid93_fpAddTest_q <= "0";
            WHEN "110011" => excRInf_uid93_fpAddTest_q <= "0";
            WHEN "110100" => excRInf_uid93_fpAddTest_q <= "0";
            WHEN "110101" => excRInf_uid93_fpAddTest_q <= "0";
            WHEN "110110" => excRInf_uid93_fpAddTest_q <= "0";
            WHEN "110111" => excRInf_uid93_fpAddTest_q <= "0";
            WHEN "111000" => excRInf_uid93_fpAddTest_q <= "0";
            WHEN "111001" => excRInf_uid93_fpAddTest_q <= "0";
            WHEN "111010" => excRInf_uid93_fpAddTest_q <= "0";
            WHEN "111011" => excRInf_uid93_fpAddTest_q <= "0";
            WHEN "111100" => excRInf_uid93_fpAddTest_q <= "0";
            WHEN "111101" => excRInf_uid93_fpAddTest_q <= "0";
            WHEN "111110" => excRInf_uid93_fpAddTest_q <= "0";
            WHEN "111111" => excRInf_uid93_fpAddTest_q <= "0";
            WHEN OTHERS => -- unreachable
                           excRInf_uid93_fpAddTest_q <= (others => '-');
        END CASE;
        -- End reserved scope level
    END PROCESS;

    -- rUdf_uid85_fpAddTest(BITSELECT,84)@11
    rUdf_uid85_fpAddTest_b <= STD_LOGIC_VECTOR(expFracR_uid81_fpAddTest_q(33 downto 33));

    -- excRZeroVInC_uid89_fpAddTest(BITJOIN,88)@11
    excRZeroVInC_uid89_fpAddTest_q <= aMinusA_uid77_fpAddTest_q & rUdf_uid85_fpAddTest_b & regInputs_uid88_fpAddTest_q & redist29_excZ_bSig_uid17_uid37_fpAddTest_q_10_q & redist34_excZ_aSig_uid16_uid23_fpAddTest_q_2_q;

    -- excRZero_uid90_fpAddTest(LOOKUP,89)@11 + 1
    excRZero_uid90_fpAddTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            excRZero_uid90_fpAddTest_q <= "0";
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (excRZeroVInC_uid89_fpAddTest_q) IS
                WHEN "00000" => excRZero_uid90_fpAddTest_q <= "0";
                WHEN "00001" => excRZero_uid90_fpAddTest_q <= "0";
                WHEN "00010" => excRZero_uid90_fpAddTest_q <= "0";
                WHEN "00011" => excRZero_uid90_fpAddTest_q <= "1";
                WHEN "00100" => excRZero_uid90_fpAddTest_q <= "0";
                WHEN "00101" => excRZero_uid90_fpAddTest_q <= "0";
                WHEN "00110" => excRZero_uid90_fpAddTest_q <= "0";
                WHEN "00111" => excRZero_uid90_fpAddTest_q <= "0";
                WHEN "01000" => excRZero_uid90_fpAddTest_q <= "0";
                WHEN "01001" => excRZero_uid90_fpAddTest_q <= "0";
                WHEN "01010" => excRZero_uid90_fpAddTest_q <= "0";
                WHEN "01011" => excRZero_uid90_fpAddTest_q <= "1";
                WHEN "01100" => excRZero_uid90_fpAddTest_q <= "1";
                WHEN "01101" => excRZero_uid90_fpAddTest_q <= "0";
                WHEN "01110" => excRZero_uid90_fpAddTest_q <= "0";
                WHEN "01111" => excRZero_uid90_fpAddTest_q <= "0";
                WHEN "10000" => excRZero_uid90_fpAddTest_q <= "0";
                WHEN "10001" => excRZero_uid90_fpAddTest_q <= "0";
                WHEN "10010" => excRZero_uid90_fpAddTest_q <= "0";
                WHEN "10011" => excRZero_uid90_fpAddTest_q <= "1";
                WHEN "10100" => excRZero_uid90_fpAddTest_q <= "1";
                WHEN "10101" => excRZero_uid90_fpAddTest_q <= "0";
                WHEN "10110" => excRZero_uid90_fpAddTest_q <= "0";
                WHEN "10111" => excRZero_uid90_fpAddTest_q <= "0";
                WHEN "11000" => excRZero_uid90_fpAddTest_q <= "0";
                WHEN "11001" => excRZero_uid90_fpAddTest_q <= "0";
                WHEN "11010" => excRZero_uid90_fpAddTest_q <= "0";
                WHEN "11011" => excRZero_uid90_fpAddTest_q <= "1";
                WHEN "11100" => excRZero_uid90_fpAddTest_q <= "1";
                WHEN "11101" => excRZero_uid90_fpAddTest_q <= "0";
                WHEN "11110" => excRZero_uid90_fpAddTest_q <= "0";
                WHEN "11111" => excRZero_uid90_fpAddTest_q <= "0";
                WHEN OTHERS => -- unreachable
                               excRZero_uid90_fpAddTest_q <= (others => '-');
            END CASE;
        END IF;
    END PROCESS;

    -- concExc_uid97_fpAddTest(BITJOIN,96)@12
    concExc_uid97_fpAddTest_q <= excRNaN_uid96_fpAddTest_q & excRInf_uid93_fpAddTest_q & excRZero_uid90_fpAddTest_q;

    -- excREnc_uid98_fpAddTest(LOOKUP,97)@12 + 1
    excREnc_uid98_fpAddTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            excREnc_uid98_fpAddTest_q <= "01";
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (concExc_uid97_fpAddTest_q) IS
                WHEN "000" => excREnc_uid98_fpAddTest_q <= "01";
                WHEN "001" => excREnc_uid98_fpAddTest_q <= "00";
                WHEN "010" => excREnc_uid98_fpAddTest_q <= "10";
                WHEN "011" => excREnc_uid98_fpAddTest_q <= "10";
                WHEN "100" => excREnc_uid98_fpAddTest_q <= "11";
                WHEN "101" => excREnc_uid98_fpAddTest_q <= "11";
                WHEN "110" => excREnc_uid98_fpAddTest_q <= "11";
                WHEN "111" => excREnc_uid98_fpAddTest_q <= "11";
                WHEN OTHERS => -- unreachable
                               excREnc_uid98_fpAddTest_q <= (others => '-');
            END CASE;
        END IF;
    END PROCESS;

    -- expRPostExc_uid117_fpAddTest(MUX,116)@13
    expRPostExc_uid117_fpAddTest_s <= excREnc_uid98_fpAddTest_q;
    expRPostExc_uid117_fpAddTest_combproc: PROCESS (expRPostExc_uid117_fpAddTest_s, cstAllZWE_uid20_fpAddTest_q, redist13_expRPreExc_uid87_fpAddTest_b_2_q, cstAllOWE_uid18_fpAddTest_q)
    BEGIN
        CASE (expRPostExc_uid117_fpAddTest_s) IS
            WHEN "00" => expRPostExc_uid117_fpAddTest_q <= cstAllZWE_uid20_fpAddTest_q;
            WHEN "01" => expRPostExc_uid117_fpAddTest_q <= redist13_expRPreExc_uid87_fpAddTest_b_2_q;
            WHEN "10" => expRPostExc_uid117_fpAddTest_q <= cstAllOWE_uid18_fpAddTest_q;
            WHEN "11" => expRPostExc_uid117_fpAddTest_q <= cstAllOWE_uid18_fpAddTest_q;
            WHEN OTHERS => expRPostExc_uid117_fpAddTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- oneFracRPostExc2_uid110_fpAddTest(CONSTANT,109)
    oneFracRPostExc2_uid110_fpAddTest_q <= "00000000000000000000001";

    -- fracRPreExc_uid86_fpAddTest(BITSELECT,85)@11
    fracRPreExc_uid86_fpAddTest_in <= expFracR_uid81_fpAddTest_q(23 downto 0);
    fracRPreExc_uid86_fpAddTest_b <= fracRPreExc_uid86_fpAddTest_in(23 downto 1);

    -- redist14_fracRPreExc_uid86_fpAddTest_b_2(DELAY,233)
    redist14_fracRPreExc_uid86_fpAddTest_b_2 : dspba_delay
    GENERIC MAP ( width => 23, depth => 2, reset_kind => "ASYNC" )
    PORT MAP ( xin => fracRPreExc_uid86_fpAddTest_b, xout => redist14_fracRPreExc_uid86_fpAddTest_b_2_q, clk => clk, aclr => areset );

    -- fracRPostExc_uid113_fpAddTest(MUX,112)@13
    fracRPostExc_uid113_fpAddTest_s <= excREnc_uid98_fpAddTest_q;
    fracRPostExc_uid113_fpAddTest_combproc: PROCESS (fracRPostExc_uid113_fpAddTest_s, cstZeroWF_uid19_fpAddTest_q, redist14_fracRPreExc_uid86_fpAddTest_b_2_q, oneFracRPostExc2_uid110_fpAddTest_q)
    BEGIN
        CASE (fracRPostExc_uid113_fpAddTest_s) IS
            WHEN "00" => fracRPostExc_uid113_fpAddTest_q <= cstZeroWF_uid19_fpAddTest_q;
            WHEN "01" => fracRPostExc_uid113_fpAddTest_q <= redist14_fracRPreExc_uid86_fpAddTest_b_2_q;
            WHEN "10" => fracRPostExc_uid113_fpAddTest_q <= cstZeroWF_uid19_fpAddTest_q;
            WHEN "11" => fracRPostExc_uid113_fpAddTest_q <= oneFracRPostExc2_uid110_fpAddTest_q;
            WHEN OTHERS => fracRPostExc_uid113_fpAddTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- R_uid118_fpAddTest(BITJOIN,117)@13
    R_uid118_fpAddTest_q <= signRPostExc_uid109_fpAddTest_q & expRPostExc_uid117_fpAddTest_q & fracRPostExc_uid113_fpAddTest_q;

    -- xOut(GPOUT,4)@13
    q <= R_uid118_fpAddTest_q;

END normal;
