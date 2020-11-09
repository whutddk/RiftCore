@REM @Author: Ruige Lee
@REM @Date:   2020-11-02 11:29:57
@REM @Last Modified by:   Ruige Lee
@REM Modified time: 2020-11-09 19:54:01




rem iverilog.exe -o ./build/wave.iverilog -y ./ -y ./backend -y ./frontend -y ./element -y ./tb -I ./tb ./tb/Crack_FrontEnd_TB.v

rem iverilog.exe -o ./build/wave.iverilog -y ./ -y ./backend -y ./backend/issue -y ./backend/execute -y ./frontend -y ./element -y ./tb -I ./tb -I ./ ./backEnd.v

iverilog.exe -W all -o ./build/wave.iverilog -y ./ -y ./backend -y ./backend/issue -y ./backend/execute -y ./frontend -y ./element -y ./tb -I ./tb -I ./ ./tb/crackCore_TB.v 

@pause

vvp.exe -n ./build/wave.iverilog -lxt2



rem @pause


