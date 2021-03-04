@REM @Author: Ruige Lee
@REM @Date:   2020-11-02 11:29:57
@REM @Last Modified by:   Ruige Lee
@REM Modified time: 2021-03-04 15:04:38




iverilog.exe -W all -o ../build/icache_tb.iverilog ^
-y ../../RiftChip/ ^
-y ../../RiftChip/riftCore/ ^
-y ../../RiftChip/riftCore/backend  ^
-y ../../RiftChip/riftCore/backend/issue ^
-y ../../RiftChip/riftCore/backend/execute  ^
-y ../../RiftChip/riftCore/frontend  ^
-y ../../RiftChip/riftCore/cache  ^
-y ../../RiftChip/element ^
-y ../../RiftChip/Soc ^
-y ../../RiftChip/Soc/xilinx_IP/axi_Xbar ^
-y ../../RiftChip/debug ^
-y ../../tb  ^
-y ../../tb/module_test  ^
-I ../../tb  ^
-I ../../RiftChip ^
./icache_tb.v 

@pause

vvp.exe  -N ../build/icache_tb.iverilog -lxt2

rem @pause


rem gtkwave.exe ../build/axi_ccm.vcd



