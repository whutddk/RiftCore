@REM @Author: Ruige Lee
@REM @Date:   2020-11-02 11:29:57
@REM @Last Modified by:   Ruige Lee
@REM Modified time: 2021-03-11 11:34:52




iverilog.exe -W all ^
-o ./build/wave.iverilog  ^
-y ../RiftChip/ ^
-y ../RiftChip/riftCore/ ^
-y ../RiftChip/riftCore/backend  ^
-y ../RiftChip/riftCore/cache  ^
-y ../RiftChip/riftCore/backend/issue  ^
-y ../RiftChip/riftCore/backend/execute  ^
-y ../RiftChip/riftCore/frontend  ^
-y ../RiftChip/element ^
-y ../RiftChip/Soc ^
-y ../RiftChip/SoC/xilinx_IP/axi_full_Xbar ^
-y ../RiftChip/debug ^
-y ../tb  ^
-I ../tb  ^
-I ../RiftChip/  ^
-I ../RiftChip/SoC/xilinx_IP/axi_full_Xbar ^
../tb/riftChip_DS.v 

@pause

vvp.exe  -N ./build/wave.iverilog -lxt2

rem @pause


