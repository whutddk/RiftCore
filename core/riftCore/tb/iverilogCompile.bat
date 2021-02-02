@REM @Author: Ruige Lee
@REM @Date:   2020-11-02 11:29:57
@REM @Last Modified by:   Ruige Lee
@REM Modified time: 2021-02-02 15:19:32




iverilog.exe -W all -o ./build/wave.iverilog -y ../ -y ../backend -y ../backend/issue -y ../backend/execute -y ../frontend -y ../element -y ../tb -I ../tb -I ../ ../tb/riftChip_DS.v 

@pause

vvp.exe  -N ./build/wave.iverilog -lxt2

rem @pause


