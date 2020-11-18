# -*- coding: utf-8 -*-
# @Author: Ruige Lee
# @Date:   2020-11-18 15:37:18
# @Last Modified by:   Ruige Lee
# @Last Modified time: 2020-11-18 16:02:03


import sys
import os

testList = [
	"rv64ui-p-add.verilog",
	"rv64ui-p-addiw.verilog",
	"rv64ui-p-addw.verilog",
	"rv64ui-p-and.verilog",
	"rv64ui-p-andi.verilog",
	"rv64ui-p-auipc.verilog",
	"rv64ui-p-beq.verilog",
	"rv64ui-p-bge.verilog",
	"rv64ui-p-bgeu.verilog",
	"rv64ui-p-blt.verilog",
	"rv64ui-p-bltu.verilog",
	"rv64ui-p-bne.verilog",
	"rv64ui-p-jal.verilog",
	"rv64ui-p-jalr.verilog",
	"rv64ui-p-lb.verilog",
	"rv64ui-p-lbu.verilog",
	"rv64ui-p-ld.verilog",
	"rv64ui-p-lh.verilog",
	"rv64ui-p-lhu.verilog",
	"rv64ui-p-lui.verilog",
	"rv64ui-p-lw.verilog",
	"rv64ui-p-lwu.verilog",
	"rv64ui-p-or.verilog",
	"rv64ui-p-ori.verilog",
	"rv64ui-p-sb.verilog",
	"rv64ui-p-sd.verilog",
	"rv64ui-p-sh.verilog",
	"rv64ui-p-sll.verilog",
	"rv64ui-p-slli.verilog",
	"rv64ui-p-slliw.verilog",
	"rv64ui-p-sllw.verilog",
	"rv64ui-p-slt.verilog",
	"rv64ui-p-slti.verilog",
	"rv64ui-p-sltiu.verilog",
	"rv64ui-p-sltu.verilog",
	"rv64ui-p-sra.verilog",
	"rv64ui-p-srai.verilog",
	"rv64ui-p-sraiw.verilog",
	"rv64ui-p-sraw.verilog",
	"rv64ui-p-srl.verilog",
	"rv64ui-p-srli.verilog",
	"rv64ui-p-srliw.verilog",
	"rv64ui-p-srlw.verilog",
	"rv64ui-p-sub.verilog",
	"rv64ui-p-subw.verilog",
	"rv64ui-p-sw.verilog",
	"rv64ui-p-xor.verilog",
	"rv64ui-p-xori.verilog"


			]

res = os.system("iverilog.exe -W all -o ../build/wave.iverilog -y ../ -y ../backend -y ../backend/issue -y ../backend/execute -y ../frontend -y ../element -y ../tb -I ../tb -I ../ ../tb/riftCore_CI.v ")

if ( res == 0 ):
	print ("compile pass!")
else:
	print ("compile Fail!")

for file in testList:
	cmd = "vvp.exe -N ../build/wave.iverilog +"
	cmd = cmd + file
	cmd = cmd + " >> null"
	res = os.system("vvp.exe -N ../build/wave.iverilog +./rv64ui-p-addi.verilog -lxt2 >> null")
	
	if (res == 0):
		print(file, "PASS!")
	else:
		print(file, "FAIL!")








