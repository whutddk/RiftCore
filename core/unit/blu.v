/*
* @File name: blu
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-09-20 16:41:01
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-10-19 11:54:40
*/

/*
// 会发生跳转的情况：
1.跳转指令（来自函数调用、返回、分支），均为指令形式由blu处理
2.中断，异常，无法预测
*/

module blu (



	input blu_jal,
	input blu_jalr,
	input blu_eq,
	input blu_ne,
	input blu_lt,
	input blu_gt,
	input blu_ltu,
	input blu_gtu,





	input  [63:0] op1,
	input  [63:0] op2,

	input [63:0] pc,
	input is_rvc_instr,
	input [63:0] imm,



	output blu_jalr_vaild,
	output [63:0] blu_jalr_pc,

	output blu_res_vaild,
	output blu_takenBranch,



	output [63:0] rd



);


wire take_eq = (blu_eq & (op1 == op2));
wire take_ne = (blu_ne & (op1 != op2));
wire take_lt = (blu_lt) & ($signed(op1) < $signed(op2));
wire take_gt = (blu_gt) & ($signed(op1) > $signed(op2));
wire take_ltu = (blu_ltu) & ($unsigned(op1) < $unsigned(op2));
wire take_gtu = (blu_gtu) & ($unsigned(op1) > $unsigned(op2));


wire blu_takenBranch = take_eq | take_ne | take_lt | take_gt | take_ltu | take_gtu;

assign blu_jalr_pc = op1 + imm;
assign blu_jalr_vaild = blu_jalr;


assign rd = {64{(blu_jal | blu_jalr)}} & ( pc + ( is_rvc_instr ? 64'd2 : 64'd4 ) );








endmodule






