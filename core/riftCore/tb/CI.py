# -*- coding: utf-8 -*-
# @Author: Ruige Lee
# @Date:   2020-11-18 15:37:18
# @Last Modified by:   Ruige Lee
# @Last Modified time: 2020-11-18 16:19:07


import sys
import os

testList = [
	"./ci/rv64ui-p-add.verilog",
	"./ci/rv64ui-p-addiw.verilog",
	"./ci/rv64ui-p-addw.verilog",
	"./ci/rv64ui-p-and.verilog",
	"./ci/rv64ui-p-andi.verilog",
	"./ci/rv64ui-p-auipc.verilog",
	"./ci/rv64ui-p-beq.verilog",
	"./ci/rv64ui-p-bge.verilog",
	"./ci/rv64ui-p-bgeu.verilog",
	"./ci/rv64ui-p-blt.verilog",
	"./ci/rv64ui-p-bltu.verilog",
	"./ci/rv64ui-p-bne.verilog",
	"./ci/rv64ui-p-jal.verilog",
	"./ci/rv64ui-p-jalr.verilog",
	"./ci/rv64ui-p-lb.verilog",
	"./ci/rv64ui-p-lbu.verilog",
	"./ci/rv64ui-p-ld.verilog",
	"./ci/rv64ui-p-lh.verilog",
	"./ci/rv64ui-p-lhu.verilog",
	"./ci/rv64ui-p-lui.verilog",
	"./ci/rv64ui-p-lw.verilog",
	"./ci/rv64ui-p-lwu.verilog",
	"./ci/rv64ui-p-or.verilog",
	"./ci/rv64ui-p-ori.verilog",
	"./ci/rv64ui-p-sb.verilog",
	"./ci/rv64ui-p-sd.verilog",
	"./ci/rv64ui-p-sh.verilog",
	"./ci/rv64ui-p-sll.verilog",
	"./ci/rv64ui-p-slli.verilog",
	"./ci/rv64ui-p-slliw.verilog",
	"./ci/rv64ui-p-sllw.verilog",
	"./ci/rv64ui-p-slt.verilog",
	"./ci/rv64ui-p-slti.verilog",
	"./ci/rv64ui-p-sltiu.verilog",
	"./ci/rv64ui-p-sltu.verilog",
	"./ci/rv64ui-p-sra.verilog",
	"./ci/rv64ui-p-srai.verilog",
	"./ci/rv64ui-p-sraiw.verilog",
	"./ci/rv64ui-p-sraw.verilog",
	"./ci/rv64ui-p-srl.verilog",
	"./ci/rv64ui-p-srli.verilog",
	"./ci/rv64ui-p-srliw.verilog",
	"./ci/rv64ui-p-srlw.verilog",
	"./ci/rv64ui-p-sub.verilog",
	"./ci/rv64ui-p-subw.verilog",
	"./ci/rv64ui-p-sw.verilog",
	"./ci/rv64ui-p-xor.verilog",
	"./ci/rv64ui-p-xori.verilog"


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
	res = os.system(cmd)
	
	if (res == 0):
		print(file, "PASS!")
	else:
		print(file, "FAIL!")








