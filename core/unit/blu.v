/*
* @File name: blu
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-09-20 16:41:01
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-09-20 17:17:55
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


	input 



	output [63:0] blu_res,
	output blu_mispredit
	
);





wire take_the_branch = blu_jal
					| blu_jalr
					| (blu_eq & (op1 == op2))
					| (blu_ne & (op1 != op2))
					| ( (blu_lt) & ($signed(op1) < $signed(op2)) )
					| ( (blu_gt) & ($signed(op1) > $signed(op2)) )
					| ( (blu_ltu) & ($unsigned(op1) < $unsigned(op2)) )
					| ( (blu_gtu) & ($unsigned(op1) > $unsigned(op2)) );


wire [63:0] blu_next_pc = is_rvc_instr ? (pc + 64'd2) : (pc + 64'd4);
wire [63:0] blu_jump_base = blu_jalr ? op1 : pc;
wire [63:0] blu_target_addr = blu_jump_base + imm;






endmodule






