@REM @Author: Ruige Lee
@REM @Date:   2020-11-02 11:29:57
@REM @Last Modified by:   Ruige Lee
@REM Modified time: 2020-11-02 14:15:45




iverilog.exe -o wave -y ./ -y ./backend -y ./frontend -y element frontend.v

@pause

vvp.exe -n wave -lxt2

gtkwave.exe wave.vcd

rem @pause


