# -*- coding: utf-8 -*-
# @Author: Ruige Lee
# @Date:   2020-11-18 15:37:18
# @Last Modified by:   Ruige Lee
# @Last Modified time: 2021-03-18 11:09:55


import sys
import os


CIReturn = 0

testList = [
	"rv64ui-p-simple",
	"rv64mi-p-ma_addr",
	"rv64mi-p-ma_fetch",
	"rv64ui-p-jal",
	"rv64ui-p-jalr",
	"rv64ui-p-beq",
	"rv64ui-p-bge",
	"rv64ui-p-bgeu",
	"rv64ui-p-blt",
	"rv64ui-p-bltu",
	"rv64ui-p-bne",
	"rv64ui-p-add",
	"rv64ui-p-addiw",
	"rv64ui-p-addw",
	"rv64ui-p-and",
	"rv64ui-p-andi",
	"rv64ui-p-auipc",
	"rv64ui-p-lb",
	"rv64ui-p-lbu",
	"rv64ui-p-ld",
	"rv64ui-p-lh",
	"rv64ui-p-lhu",
	"rv64ui-p-lui",
	"rv64ui-p-lw",
	"rv64ui-p-lwu",
	"rv64ui-p-or",
	"rv64ui-p-ori",
	"rv64ui-p-sb",
	"rv64ui-p-sd",
	"rv64ui-p-sh",
	"rv64ui-p-sll",
	"rv64ui-p-slli",
	"rv64ui-p-slliw",
	"rv64ui-p-sllw",
	"rv64ui-p-slt",
	"rv64ui-p-slti",
	"rv64ui-p-sltiu",
	"rv64ui-p-sltu",
	"rv64ui-p-sra",
	"rv64ui-p-srai",
	"rv64ui-p-sraiw",
	"rv64ui-p-sraw",
	"rv64ui-p-srl",
	"rv64ui-p-srli",
	"rv64ui-p-srliw",
	"rv64ui-p-srlw",
	"rv64ui-p-sub",
	"rv64ui-p-subw",
	"rv64ui-p-sw",
	"rv64ui-p-xor",
	"rv64ui-p-xori",
	"rv64mi-p-access",
	"rv64mi-p-illegal",
	"rv64mi-p-breakpoint",
	"rv64mi-p-csr",
	"rv64mi-p-mcsr",
	"rv64ui-p-fence_i",	
	"rv64uc-p-rvc",
	"rv64um-p-div",
	"rv64um-p-divu",
	"rv64um-p-divuw",
	"rv64um-p-divw",
	"rv64um-p-mul",
	"rv64um-p-mulh",
	"rv64um-p-mulhsu",
	"rv64um-p-mulhu",	
	"rv64um-p-mulw",
	"rv64um-p-rem",
	"rv64um-p-remu",
	"rv64um-p-remuw",
	"rv64um-p-remw"

			]





res = os.system("iverilog -Wall -o ./build/wave.iverilog  -y ../RiftChip/ -y ../RiftChip/riftCore/ -y ../RiftChip/riftCore/backend  -y ../RiftChip/riftCore/cache  -y ../RiftChip/riftCore/backend/issue  -y ../RiftChip/riftCore/backend/execute  -y ../RiftChip/riftCore/frontend  -y ../RiftChip/element -y ../RiftChip/SoC -y ../RiftChip/SoC/xilinx_IP/axi_full_Xbar -y ../RiftChip/debug -y ../tb  -I ../tb  -I ../RiftChip/  -I ../RiftChip/SoC/xilinx_IP/axi_full_Xbar ../tb/riftChip_CI.v  ")

if ( res == 0 ):
	print ("compile pass!")
else:
	print ("compile Fail!")
	CIReturn = -1
	sys.exit(-1)

for file in testList:
	cmd = "vvp -N ./build/wave.iverilog +./ci/"
	cmd = cmd + file
	cmd = cmd + ".verilog >> null"
	res = os.system(cmd)

	if (res == 0):
		print(file, "PASS!")
	else:

		CIReturn = -1
		print(file, "FAIL!!!!!!!!!!")

	jsonFile = "{\n\"schemaVersion\": 1,\n\"label\": \""
	jsonFile = jsonFile + file
	jsonFile = jsonFile + "\",\n\"message\": \""

	if ( res == 0 ):
		jsonFile = jsonFile + "PASS\",\n\"color\": \"blue\"\n}"

	else:
		jsonFile = jsonFile + "FAIL\",\n\"color\": \"red\"\n}"
	# print (jsonFile)

	with open("./ci/"+file+".json","w") as f:
		f.write(jsonFile)

# if (CIReturn):
# 	sys.exit(-1)






