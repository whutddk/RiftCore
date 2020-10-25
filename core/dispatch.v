/*
* @File name: dispatch
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-09-11 15:39:15
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-10-25 14:45:21
*/



module dispatch (

	input [63:0] dispat_pc,
	input [63:0] imm,
	input [5:0] shamt,
	input [5+RNBIT-1:0] rd,
	input [5+RNBIT-1:0] rs1,
	input [5+RNBIT-1:0] rs2,

	input [:] decode_microInstr,


	output  dispat_vaild,
	input iOrder_ready,
	input issueS_ready,

	output [:] iOrder_info_push,
	output [:] dispat_instr_info,

	
);




wire [] renaming_instr_info;
wire [] dispatch_instr_info;










gen_fifo dispatch_fifo (
	.DP(8)
	.DW()
) #
(

	.vaild_a, 
	.ready_a, 
	.data_a(renaming_instr),

	.vaild_b(dispatch_vaild), 
	.ready_b(dispatch_ready), 
	.data_b(dispatch_instr),

	.CLK,
	.RSTn
);




assign {} = dispatch_instr;


assign iOrder_info_push = {dispat_pc, rd};
assign dispat_instr_info = {dispatch_pc, imm, shamt, rd, rs1, rs2, decode_microInstr};






endmodule







