@REM @Author: Ruige Lee
@REM @Date:   2020-11-02 11:29:57
@REM @Last Modified by:   Ruige Lee
@REM Modified time: 2020-12-24 09:28:15




iverilog.exe -W all -o ../build/div_tb.iverilog    -y ../../element -I  -I ./div_tb.v 

@pause

vvp.exe  -N ../build/div_tb.iverilog -lxt2

rem @pause


rem gtkwave.exe ../build/div_tb.vcd


