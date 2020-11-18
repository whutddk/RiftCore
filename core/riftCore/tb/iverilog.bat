@REM @Author: Ruige Lee
@REM @Date:   2020-11-02 11:29:57
@REM @Last Modified by:   Ruige Lee
@REM Modified time: 2020-11-18 15:31:32




iverilog.exe -W all -o ../build/wave.iverilog -y ../ -y ../backend -y ../backend/issue -y ../backend/execute -y ../frontend -y ../element -y ../tb -I ../tb -I ../ ../tb/riftCore_TB.v 

@pause

vvp.exe  -N ../build/wave.iverilog +./rv64ui-p-addi.verilog -lxt2

rem @pause


