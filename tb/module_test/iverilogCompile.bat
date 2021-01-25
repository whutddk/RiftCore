@REM @Author: Ruige Lee
@REM @Date:   2020-11-02 11:29:57
@REM @Last Modified by:   Ruige Lee
@REM Modified time: 2021-01-21 17:05:59




iverilog.exe -W all -o ../build/axi_ccm.iverilog    -y ../../RiftChip/element -y ../../RiftChip/Soc ./axi_ccm_tb.v 

@pause

vvp.exe  -N ../build/axi_ccm.iverilog -lxt2

rem @pause


rem gtkwave.exe ../build/axi_ccm.vcd



