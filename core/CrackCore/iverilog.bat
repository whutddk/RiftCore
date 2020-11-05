@REM @Author: Ruige Lee
@REM @Date:   2020-11-02 11:29:57
@REM @Last Modified by:   Ruige Lee
@REM Modified time: 2020-11-05 11:36:25




rem iverilog.exe -o ./build/wave.iverilog -y ./ -y ./backend -y ./frontend -y ./element -y ./tb -I ./tb ./tb/Crack_FrontEnd_TB.v

iverilog.exe -o ./build/wave.iverilog -y ./ -y ./backend -y ./backend/issue -y ./backend/execute -y ./frontend -y ./element -y ./tb -I ./tb -I ./ ./backEnd.v



@pause

vvp.exe -n ./build/wave.iverilog -lxt2

gtkwave.exe ./build/wave.vcd

rem @pause


